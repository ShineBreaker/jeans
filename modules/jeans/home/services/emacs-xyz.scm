;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;; SPDX-FileCopyrightText: 2026 Hilton Chain <hako@ultrarare.space>
;;;
;;; SPDX-License-Identifier: GPL-3.0-or-later

;; Guix Home service for Neomacs, adapted from Rosenthal's
;; home-emacs-service-type by Hilton Chain
;; (modules/rosenthal/home/services/emacs.scm of
;; https://codeberg.org/ferllings/rosenthal, itself inspired by
;; https://codeberg.org/guix/guix/pulls/2395).
;;
;; The Rosenthal mechanism is kept: neomacs and the extensions manifest
;; are combined into an internal profile; a program-file wrapper sets
;; the profile's aggregated search paths (EMACSLOADPATH et al.) and
;; execs the profile entry matching argv[0]'s basename (neomacs or
;; neomacsclient); a trivial wrapper package exposes those entry points
;; plus the desktop entry and icon, repointed at the wrapper.  This way
;; every launch path -- shell, desktop file, daemon -- sees the
;; extensions, regardless of whether the profile environment was
;; sourced.  Deviation from the original: the wrapper propagates the
;; child's exit status (system* returns a raw wait status; Rosenthal
;; leaves it as the script's unused return value, always exiting 0), so
;; e.g. neomacsclient used as $EDITOR reports failures to its caller.
;;
;; Unlike the Rosenthal original there is deliberately no shepherd
;; daemon extension: Neomacs' daemon mode is still experimental
;; upstream (verified against 0.0.16):
;;
;;   * `--fg-daemon=NAME' never creates its server socket;
;;   * the unnamed daemon binds $XDG_RUNTIME_DIR/emacs/server, the same
;;     socket a GNU Emacs daemon uses, so the two cannot coexist;
;;   * daemon start-up builds the GUI event loop right away and dies
;;     without a live Wayland/X11 compositor, racing shepherd's
;;     login-time start.
;;
;; Revisit once upstream daemon mode matures.

(define-module (jeans home services emacs-xyz)
  ;; Utilities
  #:use-module (guix gexp)
  #:use-module (guix modules)
  #:use-module (guix packages)
  #:use-module (guix profiles)
  #:use-module (guix records)
  #:use-module (guix search-paths)
  ;; Guix System - services
  #:use-module (gnu services)
  #:use-module (gnu services configuration)
  ;; Guix Home - services
  #:use-module (gnu home services)
  ;; Guix build systems
  #:use-module (guix build-system trivial)
  ;; Jeans packages
  #:autoload   (jeans packages emacs-xyz) (neomacs-bin)
  #:export (home-neomacs-service-type
            home-neomacs-configuration
            home-neomacs-configuration?))

;;;
;;; Configuration record.
;;;

(define-configuration/no-serialization home-neomacs-configuration
  (neomacs
   (file-like neomacs-bin)
   "The Neomacs package to use.")
  (packages
   (manifest (manifest '()))
   "A manifest (@pxref{Writing Manifests,,, guix, GNU Guix Reference Manual})
of Emacs Lisp extensions to install alongside Neomacs.  Extensions
byte-compiled by GNU Emacs load fine (Neomacs reads standard .elc); the
@code{site-start.el} shipped by @code{neomacs-bin} picks up their
versioned @file{share/emacs/site-lisp} directories through
@code{EMACSLOADPATH}."))

;;;
;;; Wrapper package.
;;;

(define home-neomacs-package
  (match-record-lambda <home-neomacs-configuration>
      (neomacs packages)
    (let* ((home-neomacs-profile
            (profile
              (name "home-neomacs-profile")
              (content (manifest
                         (cons (package->manifest-entry neomacs)
                               (manifest-entries packages))))))
           (home-neomacs-search-paths
            (map search-path-specification->sexp
                 (manifest-search-paths
                  (profile-content home-neomacs-profile))))
           (home-neomacs-program
            (program-file "home-neomacs-program"
              (with-imported-modules
                  (source-module-closure
                   '((guix search-paths)
                     (guix build utils)))
                #~(begin
                    (use-modules (ice-9 match)
                                 (guix search-paths)
                                 (guix build utils))
                    (let ((profile #$home-neomacs-profile))
                      ;; See also (@ (guix profiles) load-profile).
                      (for-each
                       (match-lambda
                         ((($ <search-path-specification> variable _ separator) . value)
                          (let ((current (getenv variable)))
                            (setenv variable
                                    (if current
                                        (if separator
                                            (string-append value separator current)
                                            value)
                                        value)))))
                       (evaluate-search-paths
                        (map sexp->search-path-specification
                             '#$home-neomacs-search-paths)
                        (list profile)))
                      (match (command-line)
                        ((cmd . args)
                         (let ((status
                                (apply system*
                                       (string-append profile "/bin/"
                                                      (basename cmd))
                                       args)))
                           (exit (cond
                                  ((status:exit-val status))
                                  ((status:term-sig status)
                                   => (lambda (sig) (+ 128 sig)))
                                  (else 1))))))))))))
      (package
        (inherit neomacs)
        (name "neomacs-wrapper")
        (source #f)                         ;nothing to unpack
        (build-system trivial-build-system)
        (arguments
         (list #:modules '((guix build utils))
               #:builder
               #~(begin
                   (use-modules (guix build utils))
                   (let ((bin (in-vicinity #$output "bin")))
                     (mkdir-p bin)
                     ;; The runtime mode derives from argv[0]'s basename
                     ;; (neomacs vs. neomacsclient), so name the symlinks
                     ;; after the real entry points.
                     (with-directory-excursion bin
                       (for-each (lambda (name)
                                   (symlink #$home-neomacs-program name))
                                 '("neomacs" "neomacsclient"))))
                   (for-each
                    (lambda (path)
                      (let ((src (in-vicinity #$home-neomacs-profile path))
                            (dst (in-vicinity #$output path)))
                        (mkdir-p (dirname dst))
                        ;; The profile is a symlink farm: single-provider
                        ;; directories, and the files inside merged ones,
                        ;; are symlinks into the entries.  Follow them, or
                        ;; the desktop file below would stay a symlink into
                        ;; the read-only store and substitute* could not
                        ;; rewrite it.
                        (copy-recursively src dst #:follow-symlinks? #t)))
                    ;; Unlike Emacs, the .deb ships no info or man pages,
                    ;; so these two are all there is to mirror.
                    '("share/applications"
                      "share/icons"))
                   ;; Repoint the desktop entry at the wrapper, so that
                   ;; launching from a menu goes through the program that
                   ;; sets the search paths.  The pattern is used as a
                   ;; regexp verbatim (as in Rosenthal); the store path's
                   ;; dots match themselves, which is all we need.
                   (let ((applications
                          (in-vicinity #$output "share/applications")))
                     (substitute* (find-files applications "\\.desktop$")
                       ((#$neomacs) #$output))))))
        (native-inputs '())
        (inputs '())
        (propagated-inputs '())
        (outputs '("out"))))))

;;;
;;; Service type.
;;;

(define home-neomacs-service-type
  (service-type
    (name 'home-neomacs)
    (extensions
     (list (service-extension home-profile-service-type
                              (compose list home-neomacs-package))))
    (default-value (home-neomacs-configuration))
    (description "Install Neomacs, together with the Emacs Lisp extensions
of the configured manifest, into the home profile.")))

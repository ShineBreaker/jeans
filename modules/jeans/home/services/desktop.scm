;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-or-later

;; Guix Home services for desktop components.
;;
;; The nosdshell Shepherd service moved to the nosd-pkgs channel
;; ((nosd home services desktop) — home-nosdshell-service-type); the
;; MSIME providers below remain.

(define-module (jeans home services desktop)
  ;; Utilities
  #:use-module (guix gexp)
  #:use-module (guix records)
  ;; Guix System - services
  #:use-module (gnu services)
  #:use-module (gnu services configuration)
  ;; Guix Home - services
  #:use-module (gnu home services)
  #:use-module (gnu home services shepherd)
  ;; Jeans packages
  #:autoload   (jeans packages desktop) (msime-bin)
  #:export (home-msime-configuration
            home-msime-service-type))

;;;
;;; MSIME (水杉输入法) providers.
;;;
;; Upstream ships three systemd user units: two socket-activated providers
;; (online candidates/translation, voice input) and a long-running clipboard
;; history monitor.  Guix has no systemd, so the units are not installed with
;; the package; without systemd nothing ever starts those socket listeners and
;; the corresponding features stay dark.  These Shepherd services provide the
;; same long-running processes, started eagerly instead of by socket
;; activation -- each provider binds its own $XDG_RUNTIME_DIR socket on
;; startup, so eager startup is equivalent from the input method host's point
;; of view.
;;
;; Environment: Shepherd starts at TTY login, so its own environment carries
;; XDG_RUNTIME_DIR (set by elogind) but neither WAYLAND_DISPLAY nor DISPLAY;
;; home-wayland-service-type and home-x11-service-type putenv the display
;; into Shepherd only when their probe succeeds.  #:environment-variables
;; (environ) is evaluated inside the start thunk, so a service that waits for
;; one of those provisions inherits the variable, whereas the
;; make-forkexec-constructor default environment is captured before the
;; service starts and would miss it.  The online and voice providers need only
;; XDG_RUNTIME_DIR; the clipboard monitor needs a display, hence
;; clipboard-requirement.

(define-configuration/no-serialization home-msime-configuration
  (msime
   (file-like msime-bin)
   "File-like object providing @command{msime-linux-provider-session} and
@command{msime-linux-clipboard-monitor}.")
  (online?
   (boolean #t)
   "Whether to run the online candidate and translation provider.")
  (voice?
   (boolean #t)
   "Whether to run the voice input provider.")
  (clipboard?
   (boolean #f)
   "Whether to run the clipboard history monitor.  It captures clipboard
text only while the history preference is enabled, so it is safe to keep
running.")
  (clipboard-requirement
   (list-of-symbols '(wayland-display))
   "Shepherd provisions the clipboard history monitor must wait for before it
starts.  The monitor shells out to @command{wl-paste} or @command{xclip}, so
it needs @code{WAYLAND_DISPLAY} or @code{DISPLAY} in its environment; Shepherd
starts at TTY login with neither, and only
@code{home-wayland-service-type} or @code{home-x11-service-type} sets them
later.  Keep @code{'(wayland-display)} for a Wayland session, use
@code{'(x11-display)} for X11, or @code{'()} to start the monitor right away
when you provide the display environment yourself.  The online and voice
providers need no display and carry no requirement.")
  (auto-start?
   (boolean #t)
   "Whether to start the providers with the user Shepherd."))

(define* (home-msime-provider-service msime provision program arguments log-file
                                      auto-start? #:optional (requirement '()))
  "Return a Shepherd service running PROGRAM from MSIME with ARGUMENTS."
  (shepherd-service
   (documentation (string-append "Run the MSIME " (symbol->string provision)
                                 " provider."))
   (provision (list provision))
   (requirement requirement)
   (modules '((shepherd support)))       ;for '%user-log-dir'
   (auto-start? auto-start?)
   (start
    #~(lambda args
        ((make-forkexec-constructor
          (cons #$(file-append msime (string-append "/bin/" program))
                #$arguments)
          #:log-file (in-vicinity %user-log-dir #$log-file)
          ;; Providers read XDG_RUNTIME_DIR and the user's MSIME_* overrides
          ;; from the environment, the same way the input method hosts do.
          #:environment-variables (environ))
         args)))
   (stop #~(make-kill-destructor))))

(define (home-msime-shepherd-services config)
  (match-record config <home-msime-configuration>
      (msime online? voice? clipboard? clipboard-requirement auto-start?)
    (append
     (if online?
         (list (home-msime-provider-service
                msime 'msime-online "msime-linux-provider-session"
                #~(list "online")
                "msime-online.log" auto-start?))
         '())
     (if voice?
         (list (home-msime-provider-service
                msime 'msime-voice "msime-linux-provider-session"
                #~(list "voice")
                "msime-voice.log" auto-start?))
         '())
     (if clipboard?
         (list (home-msime-provider-service
                msime 'msime-clipboard "msime-linux-clipboard-monitor"
                ;; The monitor takes the runtime-options file the input
                ;; method hosts also read, under the user's XDG config dir.
                #~(list (string-append
                         (or (getenv "XDG_CONFIG_HOME")
                             (string-append (or (getenv "HOME") "/tmp")
                                            "/.config"))
                         "/msime-client/runtime-options.json"))
                "msime-clipboard.log" auto-start? clipboard-requirement))
         '()))))

(define home-msime-service-type
  (service-type
    (name 'home-msime)
    (extensions
     (list (service-extension home-profile-service-type
                              (compose list home-msime-configuration-msime))
           (service-extension home-shepherd-service-type
                              home-msime-shepherd-services)))
    (default-value (home-msime-configuration))
    (description
     "Run the MSIME input method's optional providers -- online candidates
and translation, voice input, and the clipboard history monitor -- as user
Shepherd services.  Guix has no systemd, so the systemd user units shipped by
upstream are not used; these services start the same provider processes
eagerly.  The input method hosts themselves (IBus engine, Fcitx5 addon) are
started by their respective frameworks and need no service here.")))

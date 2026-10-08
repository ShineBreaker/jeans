;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;; SPDX-FileCopyrightText: 2026 Hilton Chain <hako@ultrarare.space>
;;;
;;; SPDX-License-Identifier: GPL-3.0-or-later

;; Guix Home service for nosDshell, modeled on Rosenthal's
;; home-noctalia-service-type
;; (modules/rosenthal/home/services/desktop.scm of
;; https://codeberg.org/hako/rosenthal): the shell runs as a forkexec'd
;; user Shepherd service and inherits the Shepherd environment (environ),
;; so it picks up WAYLAND_DISPLAY once the graphical-session target's
;; wayland-display waiter has putenv'd it.
;;
;; Deviation from the Rosenthal original: this module deliberately does
;; not ship home-graphical-session-service-type.  The nosdshell service
;; requires the 'graphical-session and 'dbus provisions, which that
;; service (already instantiated in configs alongside Rosenthal's
;; channel) provides; shipping a second copy here would create duplicate
;; graphical-session provisions in configs that load both channels.

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
  #:autoload   (jeans packages desktop) (nosdshell)
  #:export (home-nosdshell-configuration
            home-nosdshell-service-type))

;;;
;;; Configuration record.
;;;

(define-configuration/no-serialization home-nosdshell-configuration
  (nosdshell
   (file-like nosdshell)
   "File-like object to provide @command{/bin/nosdshell}.")
  (auto-start?
   (boolean #t)
   "Whether to start the shell when the graphical session target is up."))

;;;
;;; Shepherd service.
;;;

(define (home-nosdshell-shepherd-service config)
  (match-record config <home-nosdshell-configuration>
      (nosdshell auto-start?)
    (list (shepherd-service
           (documentation "Start nosDshell.")
           (provision '(nosdshell))
           (requirement '(dbus graphical-session))
           (modules '((shepherd support))) ;for '%user-log-dir'
           (auto-start? auto-start?)
           (start
            #~(lambda args
                ((make-forkexec-constructor
                  (list #$(file-append nosdshell "/bin/nosdshell"))
                  #:log-file (in-vicinity %user-log-dir "nosdshell.log")
                  ;; Inherit graphical session environment.
                  #:environment-variables (environ))
                 args)))
           (stop #~(make-kill-destructor))))))

;;;
;;; Service type.
;;;

(define home-nosdshell-service-type
  (service-type
    (name 'home-nosdshell)
    (extensions
     (list (service-extension home-profile-service-type
                              (compose list
                                       home-nosdshell-configuration-nosdshell))
           (service-extension home-shepherd-service-type
                              home-nosdshell-shepherd-service)))
    (default-value (home-nosdshell-configuration))
    (description
     "Run nosDshell, a quickshell-based Wayland desktop shell, as a user
Shepherd service.  Requires the @code{graphical-session} and @code{dbus}
Shepherd provisions; with Rosenthal's
@code{home-graphical-session-service-type} configured for Wayland, the
shell starts once @code{wayland-display} is up.")))

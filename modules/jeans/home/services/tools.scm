;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-only

;; Guix Home service for Sunshine, counterpart to sunshine-service-type.
;; Mirrors the Arch/NixOS user unit (start after the graphical session, restart
;; on failure): the daemon runs as the logged-in user so it can reach the
;; user's GPU nodes, Wayland/X11 sockets and ~/.config/sunshine.  First-run
;; pairing and settings happen through the local web UI; no config file is
;; generated, so the Web UI stays editable (same as NixOS with empty settings).

(define-module (jeans home services tools)
  #:use-module (gnu home services)
  #:use-module (gnu home services shepherd)
  #:use-module (gnu services)
  #:use-module (guix gexp)
  #:use-module (guix records)
  #:autoload (jeans packages tools) (sunshine-bin)
  #:export (home-sunshine-configuration
            home-sunshine-configuration?
            home-sunshine-service-type))

(define-record-type* <home-sunshine-configuration>
  home-sunshine-configuration make-home-sunshine-configuration
  home-sunshine-configuration?
  (package home-sunshine-configuration-package
           (default sunshine-bin))
  (auto-start? home-sunshine-configuration-auto-start?
               (default #t)))

(define (home-sunshine-shepherd-services config)
  "Return a user shepherd service running the Sunshine daemon."
  (match-record config <home-sunshine-configuration>
    (package auto-start?)
    (let* ((sunshine (file-append package "/bin/sunshine"))
           (command #~(list #$sunshine)))
      (list (shepherd-service
             (documentation "Self-hosted game stream host for Moonlight.")
             (provision '(sunshine))
             ;; Starting before the Wayland session is up makes Sunshine
             ;; abort with "Unable to find display or encoder" and, worse,
             ;; every respawn cycle creates and destroys its libvirtualhid
             ;; uinput devices, which trips evdev watchers (e.g. kanata)
             ;; into constant device rescans.  Follow the upstream pattern
             ;; (redshift requires x11-display): depend on the display
             ;; waiter instead.  'wayland-display' is provided by upstream
             ;; Guix's home-wayland-service-type; Rosenthal's
             ;; home-graphical-session-service-type (wayland? #t)
             ;; provisions it as well, so either satisfies the link.
             (requirement '(wayland-display))
             (modules '((shepherd support))) ;for '%user-log-dir'
             (auto-start? auto-start?)
             (start #~(lambda args
                        ((make-forkexec-constructor
                          #$command
                          ;; Inherit the graphical session environment:
                          ;; shepherd's own default environment predates
                          ;; wayland-display's setenv, so WAYLAND_DISPLAY
                          ;; must be picked up at start time.
                          #:environment-variables (environ)
                          #:log-file (string-append %user-log-dir
                                                    "/sunshine.log"))
                         args)))
             (stop #~(make-kill-destructor)))))))

(define home-sunshine-service-type
  (service-type
   (name 'home-sunshine)
   (description "Run the Sunshine game stream host for Moonlight as a user
shepherd service.  Pair clients and change settings through the local web UI.
Requires the @code{wayland-display} Shepherd provision, provided by upstream
Guix's @code{home-wayland-service-type} (Rosenthal's
@code{home-graphical-session-service-type} with @code{wayland?} also
provisions it); also requires @code{sunshine-service-type} on the system for
udev rules and kernel modules.")
   (extensions
    (list (service-extension home-shepherd-service-type
                             home-sunshine-shepherd-services)
          (service-extension home-profile-service-type
                             (lambda (config)
                               (list (home-sunshine-configuration-package
                                      config))))))
   (default-value (home-sunshine-configuration))))

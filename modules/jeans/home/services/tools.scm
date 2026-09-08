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
           (command #~(list #$sunshine))
           (log-file #~(string-append %user-log-dir "/sunshine.log")))
      (list (shepherd-service
             (documentation "Self-hosted game stream host for Moonlight.")
             (provision '(sunshine))
             (modules '((shepherd support))) ;for '%user-log-dir'
             (auto-start? auto-start?)
             (start #~(make-forkexec-constructor #$command
                                                 #:log-file #$log-file))
             (stop #~(make-kill-destructor)))))))

(define home-sunshine-service-type
  (service-type
   (name 'home-sunshine)
   (description "Run the Sunshine game stream host for Moonlight as a user
shepherd service.  Pair clients and change settings through the local web UI.
Requires @code{sunshine-service-type} on the system for udev rules and kernel
modules.")
   (extensions
    (list (service-extension home-shepherd-service-type
                             home-sunshine-shepherd-services)
          (service-extension home-profile-service-type
                             (lambda (config)
                               (list (home-sunshine-configuration-package
                                      config))))))
   (default-value (home-sunshine-configuration))))

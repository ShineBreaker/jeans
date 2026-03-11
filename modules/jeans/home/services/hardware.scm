;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-only

(define-module (jeans home services hardware)
  #:use-module (gnu home services)
  #:use-module (gnu home services shepherd)
  #:use-module (gnu packages)
  #:use-module (gnu services configuration)
  #:use-module (guix gexp)
  #:use-module (guix records)
  #:use-module (jeans packages hardware)
  #:export (home-opentabletdriver-service-type
            home-opentabletdriver-configuration
            home-opentabletdriver-configuration?
            home-opentabletdriver-service))

(define-record-type* <home-opentabletdriver-configuration>
  home-opentabletdriver-configuration make-home-opentabletdriver-configuration
  home-opentabletdriver-configuration?
  (package home-opentabletdriver-configuration-package
           (default opentabletdriver-bin)))

(define (home-opentabletdriver-shepherd-service config)
  (list (shepherd-service
         (provision '(opentabletdriver))
         (documentation "OpenTabletDriver daemon")
         (start #~(make-forkexec-constructor
                   (list #$(file-append
                            (home-opentabletdriver-configuration-package config)
                            "/bin/otd-daemon"))))
         (stop #~(make-kill-destructor)))))

(define home-opentabletdriver-service-type
  (service-type
   (name 'home-opentabletdriver)
   (description "Run OpenTabletDriver daemon in user session.")
   (extensions
    (list (service-extension home-shepherd-service-type
                             home-opentabletdriver-shepherd-service)))
   (default-value (home-opentabletdriver-configuration))))

(define* (home-opentabletdriver-service #:key (package opentabletdriver-bin))
  "Return a service that runs OpenTabletDriver daemon in user session."
  (service home-opentabletdriver-service-type
           (home-opentabletdriver-configuration
            (package package))))

;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-only

(define-module (jeans services hardware)
  #:use-module (gnu services)
  #:use-module (gnu services base)
  #:use-module (gnu services linux)
  #:use-module (guix gexp)
  #:use-module (guix records)
  #:use-module (jeans packages hardware)
  #:export (opentabletdriver-service-type
            opentabletdriver-configuration
            opentabletdriver-configuration?
            opentabletdriver-service))

(define-record-type* <opentabletdriver-configuration>
  opentabletdriver-configuration make-opentabletdriver-configuration
  opentabletdriver-configuration?
  (package opentabletdriver-configuration-package
           (default opentabletdriver-udev-rules)))

(define opentabletdriver-service-type
  (service-type
   (name 'opentabletdriver)
   (description "OpenTabletDriver service with udev rules and kernel module configuration.")
   (extensions
    (list (service-extension udev-service-type
                             (lambda (config)
                               (list (opentabletdriver-configuration-package config))))
          (service-extension kernel-module-loader-service-type
                             (lambda (config)
                               '("uinput")))))
   (default-value (opentabletdriver-configuration))))

(define* (opentabletdriver-service #:key (package opentabletdriver-udev-rules))
  "Return a service that sets up OpenTabletDriver with udev rules and kernel modules."
  (service opentabletdriver-service-type
           (opentabletdriver-configuration
            (package package))))

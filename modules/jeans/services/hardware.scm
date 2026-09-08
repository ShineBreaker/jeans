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

;; System service for OpenTabletDriver.  Mirrors NixOS
;; hardware.opentabletdriver (nixos/modules/hardware/opentabletdriver.nix):
;; udev rules + conflicting kernel modules blacklisted + driver binaries
;; in the system profile.  Two deliberate deviations:
;;
;;   * Blacklist is Guix-native: Guix has kernel-module-loader-service-type
;;     but no blacklist service type, so the wacom/hid_uclogic blacklist
;;     ships as /etc/modprobe.d/99-opentabletdriver.conf via
;;     etc-service-type.  `blacklist' lines are used instead of the .deb's
;;     `install ... /usr/bin/true' overrides (Debian paths absent on Guix).
;;   * No user daemon here: Guix System has no systemd user services.
;;     The otd-daemon user unit maps to home-opentabletdriver-service-type
;;     (jeans home services hardware), a home shepherd service, instead of
;;     NixOS's systemd user service bound to graphical-session.target.
(define-record-type* <opentabletdriver-configuration>
  opentabletdriver-configuration make-opentabletdriver-configuration
  opentabletdriver-configuration?
  (package opentabletdriver-configuration-package
           (default opentabletdriver-udev-rules))
  (driver opentabletdriver-configuration-driver
          (default opentabletdriver-bin)))

(define %opentabletdriver-modprobe-conf
  (plain-file "99-opentabletdriver.conf"
              "# Blacklist kernel modules known to conflict with OpenTabletDriver.\n# (NixOS default blacklistedKernelModules: hid-uclogic, wacom.)\nblacklist wacom\nblacklist hid_uclogic\n"))

(define opentabletdriver-service-type
  (service-type
   (name 'opentabletdriver)
   (description "OpenTabletDriver service with udev rules, driver binaries,
kernel module configuration and conflicting-module blacklist.")
   (extensions
    (list (service-extension udev-service-type
                             (lambda (config)
                               (list (opentabletdriver-configuration-package config))))
          (service-extension kernel-module-loader-service-type
                             (lambda (config)
                               '("uinput")))
          (service-extension profile-service-type
                             (lambda (config)
                               (list (opentabletdriver-configuration-driver config))))
          (service-extension etc-service-type
                             (lambda (config)
                               `(("modprobe.d/99-opentabletdriver.conf"
                                  ,%opentabletdriver-modprobe-conf))))))
   (default-value (opentabletdriver-configuration))))

(define* (opentabletdriver-service #:key (package opentabletdriver-udev-rules)
                                   (driver opentabletdriver-bin))
  "Return a service that sets up OpenTabletDriver with udev rules, driver
binaries, uinput kernel module and conflicting-module blacklist."
  (service opentabletdriver-service-type
           (opentabletdriver-configuration
            (package package)
            (driver driver))))

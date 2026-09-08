;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-only

;; Guix Home service for OpenTabletDriver: installs the driver binaries
;; into the home profile and runs otd-daemon as a home shepherd service.
;;
;; This is the Guix counterpart of two things:
;;
;;   * the otd-daemon systemd user unit shipped in the upstream .deb
;;     (PartOf/After graphical-session.target, Restart=always), and
;;   * NixOS's hardware.opentabletdriver.daemon, which enables that unit
;;     as a systemd user service by default.
;;
;; Guix System has no systemd user services, so the daemon maps to
;; home-shepherd-service-type (respawn on failure, auto-start at login).
;; Deliberate deviation from NixOS: no graphical-session gating
;; (ConditionEnvironment=WAYLAND_DISPLAY/DISPLAY plus the GDM-greeter
;; ExecStartPre workaround).  The daemon is headless-safe -- without a
;; tablet it just scans and waits (verified 2026-09-08) -- so starting it
;; at login unconditionally is harmless.  Set daemon? to #f to skip it
;; and launch otd-daemon or otd-gui manually instead.
;;
;; Pair with opentabletdriver-service-type (jeans services hardware) on
;; Guix System for udev rules, the uinput module, the wacom/hid_uclogic
;; blacklist and system-wide binaries.

(define-module (jeans home services hardware)
  #:use-module (guix gexp)
  #:use-module (gnu services)
  #:use-module (gnu services configuration)
  #:use-module (gnu home services)
  #:use-module (gnu home services shepherd)
  #:autoload (jeans packages hardware) (opentabletdriver-bin)
  #:export (home-opentabletdriver-service-type
            home-opentabletdriver-configuration
            home-opentabletdriver-configuration?))

(define-configuration/no-serialization home-opentabletdriver-configuration
  (package
   (file-like opentabletdriver-bin)
   "The OpenTabletDriver package to use.")
  (daemon?
   (boolean #t)
   "Whether to run @command{otd-daemon} as a home shepherd service."))

(define (home-opentabletdriver-shepherd-service config)
  (list (shepherd-service
         (documentation "Run the OpenTabletDriver tablet driver daemon.")
         (provision '(opentabletdriver-daemon))
         (requirement '())
         (start #~(make-forkexec-constructor
                   (list #$(file-append
                            (home-opentabletdriver-configuration-package config)
                            "/bin/otd-daemon"))))
         (stop #~(make-kill-destructor))
         (respawn? #t))))

(define home-opentabletdriver-service-type
  (service-type
   (name 'home-opentabletdriver)
   (extensions
    (list (service-extension home-profile-service-type
                             (compose list
                                      home-opentabletdriver-configuration-package))
          (service-extension home-shepherd-service-type
                             (lambda (config)
                               (if (home-opentabletdriver-configuration-daemon? config)
                                   (home-opentabletdriver-shepherd-service config)
                                   '())))))
   (default-value (home-opentabletdriver-configuration))
   (description "Install OpenTabletDriver and optionally run its
@command{otd-daemon} as a home shepherd service.")))

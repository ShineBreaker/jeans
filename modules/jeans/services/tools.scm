;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-only

;; Guix System service for Sunshine (see sunshine-bin in
;; jeans/packages/tools.scm).  Mirrors the NixOS sunshine module
;; (nixos/modules/services/networking/sunshine.nix):
;;
;; - udev rules come from the package itself (lib/udev/rules.d), like
;;   NixOS `services.udev.packages = [ cfg.package ]`.  They grant the
;;   logged-in user access to /dev/uinput, /dev/uhid and the libvirtualhid
;;   gamepad nodes.
;; - uhid (gamepad emulation) and uinput (keyboard/mouse) kernel modules are
;;   loaded, like the Arch modules-load.d/60-sunshine.conf plus NixOS
;;   `hardware.uinput.enable`.
;; - cap-sys-admin? maps to NixOS `capSysAdmin`: file capabilities for DRM/KMS
;;   capture.  The capability is set on the REAL binary
;;   (lib/sunshine/usr/bin/sunshine), never on the bin/sunshine shell wrapper
;;   (capabilities on scripts are ignored by the kernel).
;;
;; Deliberately NOT handled here (documented prerequisites instead):
;;
;; - The sunshine daemon itself runs as a per-user home shepherd service
;;   (home-sunshine-service-type), like NixOS's systemd user unit bound to
;;   graphical-session.target.  Running it as a root shepherd service would
;;   detach it from the user's GPU/render nodes and Wayland socket.
;; - mDNS discovery needs avahi-service-type with publish/user-services
;;   enabled (NixOS sets it via mkDefault); a Guix service cannot force-enable
;;   another service, so add it to your operating-system definition.
;; - Firewall: Guix System runs no firewall by default (NixOS default is
;;   closed too).  With the default base port 47989 Moonlight needs TCP
;;   47984, 47989, 47990, 48010 and UDP 47998, 47999, 48000, 48002, 48010.
;; - The streaming user should be in the `video' (and `render' if present)
;;   groups for GPU capture, and first-run configuration happens through the
;;   local web UI (https://localhost:47990).

(define-module (jeans services tools)
  #:use-module (gnu services)
  #:use-module (gnu services base)
  #:use-module (gnu services linux)
  #:use-module (gnu system privilege)
  #:use-module (guix gexp)
  #:use-module (guix records)
  #:autoload (jeans packages tools) (sunshine-bin)
  #:export (sunshine-configuration
            sunshine-configuration?
            sunshine-service-type
            sunshine-service))

(define-record-type* <sunshine-configuration>
  sunshine-configuration make-sunshine-configuration
  sunshine-configuration?
  (package sunshine-configuration-package
           (default sunshine-bin))
  (cap-sys-admin? sunshine-configuration-cap-sys-admin?
                  (default #f)))

(define (sunshine-privileged-programs config)
  "Return file capabilities for the Sunshine binary when requested."
  (if (sunshine-configuration-cap-sys-admin? config)
      (list (privileged-program
             (program (file-append (sunshine-configuration-package config)
                                   "/lib/sunshine/usr/bin/sunshine"))
             (capabilities "cap_sys_admin=ep")))
      '()))

(define sunshine-service-type
  (service-type
   (name 'sunshine)
   (description "Run the Sunshine game stream host prerequisites: udev rules
for virtual input devices, uhid/uinput kernel modules, and optionally file
capabilities for DRM/KMS capture.  The daemon itself is managed per-user via
@code{home-sunshine-service-type}.")
   (extensions
    (list (service-extension udev-service-type
                             (lambda (config)
                               (list (sunshine-configuration-package config))))
          (service-extension kernel-module-loader-service-type
                             (lambda (config)
                               '("uhid" "uinput")))
          (service-extension privileged-program-service-type
                             sunshine-privileged-programs)
          (service-extension profile-service-type
                             (lambda (config)
                               (list (sunshine-configuration-package config))))))
   (default-value (sunshine-configuration))))

(define* (sunshine-service #:key (package sunshine-bin) (cap-sys-admin? #f))
  "Return a service that sets up Sunshine with udev rules and kernel modules."
  (service sunshine-service-type
           (sunshine-configuration
            (package package)
            (cap-sys-admin? cap-sys-admin?))))

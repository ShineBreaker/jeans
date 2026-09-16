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
;; NixOS gates that unit on graphical-session.target and relies on the
;; systemd user manager having imported the session environment; the
;; Guix-home counterpart is the wait-for-display wrapper below.  Shepherd
;; itself starts at TTY login, so its environment carries neither
;; WAYLAND_DISPLAY nor DISPLAY (observed 2026-09-16: XDG_SESSION_TYPE=tty
;; only), and OTD's env-var-driven display pick then falls back to
;; XScreen, whose construction fails and leaves every output mode dead
;; ("Unable to construct object ... LinuxArtistMode").  The wrapper
;; defers exec until a compositor socket exists.  Set daemon? to #f to
;; skip it and launch otd-daemon or otd-gui manually instead.
;;
;; Pair with opentabletdriver-service-type (jeans services hardware) on
;; Guix System for udev rules, the uinput module, the wacom/hid_uclogic
;; blacklist and system-wide binaries.

(define-module (jeans home services hardware)
  #:use-module (guix gexp)
  #:use-module (gnu packages bash)
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

;; Session wrapper used as the shepherd service program.  Inherited
;; WAYLAND_DISPLAY/DISPLAY win; otherwise poll for a live display socket
;; (newest wayland-* under XDG_RUNTIME_DIR, i.e. the running compositor,
;; then /tmp/.X11-unix/X*) and export the derived variable before exec.
;; Pure POSIX sh plus [ -nt ] so only bash-minimal is needed.
(define %otd-daemon-wait-for-display
  (plain-file "otd-daemon-wait-for-display"
    "\
# Wait for a graphical session, then exec the daemon passed as $1.
[ -n \"${XDG_RUNTIME_DIR:-}\" ] || {
  echo \"otd-daemon: XDG_RUNTIME_DIR is not set\" >&2; exit 1; }
while [ -z \"${WAYLAND_DISPLAY:-}\" ] && [ -z \"${DISPLAY:-}\" ]; do
  newest=
  for s in \"$XDG_RUNTIME_DIR\"/wayland-*; do
    if [ -S \"$s\" ] && { [ -z \"$newest\" ] || [ \"$s\" -nt \"$newest\" ]; }; then
      newest=$s
    fi
  done
  if [ -n \"$newest\" ]; then
    WAYLAND_DISPLAY=\"${newest##*/}\"
    export WAYLAND_DISPLAY
    exec \"$1\"
  fi
  for x in /tmp/.X11-unix/X*; do
    if [ -S \"$x\" ]; then
      DISPLAY=\":${x##*X}\"
      export DISPLAY
      exec \"$1\"
    fi
  done
  sleep 2
done
exec \"$1\"
"))

(define (home-opentabletdriver-shepherd-service config)
  (list (shepherd-service
         (documentation "Run the OpenTabletDriver tablet driver daemon.")
         (provision '(opentabletdriver-daemon))
         (requirement '())
         (start #~(make-forkexec-constructor
                   (list #$(file-append bash-minimal "/bin/sh")
                         #$%otd-daemon-wait-for-display
                         #$(file-append
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

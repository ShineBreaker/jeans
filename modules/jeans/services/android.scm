;;; SPDX-FileCopyrightText: 2024 Jakob Kirsch <jakob.kirsch@web.de>
;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-only

(define-module (jeans services android)
  #:use-module (gnu services)
  #:use-module (gnu services dbus)
  #:use-module (gnu services shepherd)
  #:use-module (guix gexp)
  #:use-module (guix records)
  #:use-module (jeans packages android)
  #:export (waydroid-configuration
            waydroid-configuration?
            waydroid-service-type))

;;; Modeled after the waydroid-service-type in lauras-channel
;;; <https://github.com/laura240406/lauras-channel> (laura/services/utils.scm).
;;;
;;; The waydroid container daemon must run as root: it mounts binderfs and
;;; starts the LXC container.  Guix System needs two things for that:
;;;
;;;   * the package's D-Bus policy and activation files have to be merged
;;;     into /etc/dbus-1, otherwise root cannot own the id.waydro.Container
;;;     name and the daemon cannot start at all;
;;;   * the daemon has to be started.  With AUTOSTART? (the default) a
;;;     shepherd service starts it at boot; without it the daemon is left
;;;     to D-Bus activation, which starts it on the first
;;;     `waydroid session start'.
;;;
;;; `waydroid init' is deliberately not run from the activation script:
;;; it downloads the system and vendor images (hundreds of megabytes), and
;;; a network failure there would abort `guix system reconfigure'.  It is
;;; a one-time, user-initiated step instead.

(define-record-type* <waydroid-configuration>
  waydroid-configuration make-waydroid-configuration
  waydroid-configuration?
  (waydroid waydroid-configuration-waydroid
            (default waydroid))
  (autostart? waydroid-configuration-autostart?
              (default #t)))

(define (waydroid-shepherd-services config)
  "Return a shepherd service running the waydroid container daemon, or the
empty list when AUTOSTART? is false."
  (let ((package (waydroid-configuration-waydroid config)))
    (if (waydroid-configuration-autostart? config)
        (list (shepherd-service
               (provision '(waydroid))
               (requirement '(loopback dbus-system))
               (documentation "Run the waydroid container daemon.")
               (start #~(make-forkexec-constructor
                         (list #$(file-append package "/bin/waydroid")
                               "container" "start")
                         #:log-file "/var/log/waydroid-container.log"))
               (stop #~(make-kill-destructor))))
        '())))

(define waydroid-service-type
  (service-type
   (name 'waydroid)
   (description "Run the waydroid Android container runtime.  Its D-Bus
policy and activation files are installed system-wide.  When
@code{autostart?} is true (the default), a shepherd service starts the
container daemon at boot; otherwise the daemon is started on demand through
D-Bus.  Run @command{waydroid init} once before the first session.")
   (extensions
    (list (service-extension dbus-root-service-type
                             (lambda (config)
                               (list (waydroid-configuration-waydroid config))))
          (service-extension shepherd-root-service-type
                             waydroid-shepherd-services)))
   (default-value (waydroid-configuration))))

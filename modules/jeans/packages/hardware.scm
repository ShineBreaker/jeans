;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-only

(define-module (jeans packages hardware)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages elf)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages web)
  #:use-module (gnu packages xorg)
  #:use-module (nongnu packages dotnet)
  #:use-module (guix build utils)
  #:use-module (guix build-system copy)
  #:use-module (guix build-system gnu)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix gexp)
  #:use-module (guix packages))

(define-public opentabletdriver-udev-rules
  (package
    (name "opentabletdriver-udev-rules")
    (version "0.6.6.2")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/OpenTabletDriver/OpenTabletDriver")
               (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256
          (base32 "1r9q1qmhca5q90kwd80cqbajkdx5crsiafywjy5zhq5gswasis1r"))))
    (build-system gnu-build-system)
    (arguments
      (list #:modules '((guix build utils)
                        (guix build gnu-build-system)
                        (ice-9 popen)
                        (ice-9 textual-ports))
            #:phases
            #~(modify-phases %standard-phases
                (delete 'configure)
                (delete 'check)
                (replace 'build
                  (lambda _
                    (let* ((pipe (open-input-pipe "bash generate-rules.sh"))
                           (output (get-string-all pipe)))
                      (close-pipe pipe)
                      (call-with-output-file "70-opentabletdriver.rules"
                        (lambda (port)
                          (put-string port output))))))
                (replace 'install
                  (lambda _
                    (install-file "70-opentabletdriver.rules"
                                  (string-append #$output "/lib/udev/rules.d")))))))
    (native-inputs (list bash-minimal jq))
    (home-page "https://opentabletdriver.net")
    (synopsis "UDev rules for OpenTabletDriver")
    (description "Open source, cross-platform, user-mode tablet driver")
    (license license:lgpl3+)))

(define-public opentabletdriver-bin
  (package
    (name "opentabletdriver-bin")
    (version "0.6.6.2")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/OpenTabletDriver/OpenTabletDriver/releases/download/"
             "v" version "/opentabletdriver-" version "-x64.tar.gz"))
       (sha256
        (base32 "0kp3yhrr959rkw1l4pi5ysw014kd7dnrs78g189hp47mja6vqi59"))))
    (build-system copy-build-system)
    (arguments
     (list
      #:strip-binaries? #f
      #:validate-runpath? #f
      #:install-plan
      #~'(("usr/local/lib/opentabletdriver" "lib/opentabletdriver")
          ("usr/local/share/pixmaps/otd.png" "share/pixmaps/otd.png")
          ("etc/udev/rules.d/70-opentabletdriver.rules"
           "lib/udev/rules.d/70-opentabletdriver.rules"))
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'install 'install-bin
            (lambda* (#:key inputs outputs #:allow-other-keys)
              (let* ((out (assoc-ref outputs "out"))
                     (bin (string-append out "/bin"))
                     (lib (string-append out "/lib/opentabletdriver"))
                     (dynamic-linker (search-input-file inputs "/lib/ld-linux-x86-64.so.2"))
                     (gcc-lib (dirname (search-input-file inputs "/lib/libstdc++.so.6")))
                     (gtk-lib (string-append (assoc-ref inputs "gtk+") "/lib"))
                     (dotnet-root (string-append (assoc-ref inputs "dotnet")
                                                 "/share/dotnet")))
                (mkdir-p bin)
                ;; otd (console)
                (call-with-output-file (string-append bin "/otd")
                  (lambda (port)
                    (display (string-append "#!" (assoc-ref inputs "bash-minimal")
                                            "/bin/sh\n"
                                            "ln -sf " dynamic-linker " /tmp/ld-linux-x86-64.so.2\n"
                                            "export DOTNET_ROOT=" dotnet-root "\n"
                                            "export LD_LIBRARY_PATH=" gcc-lib ":" gtk-lib ":${LD_LIBRARY_PATH:-}\n"
                                            "exec " lib "/OpenTabletDriver.Console \"$@\"\n")
                             port)))
                (chmod (string-append bin "/otd") #o555)
                ;; otd-daemon
                (call-with-output-file (string-append bin "/otd-daemon")
                  (lambda (port)
                    (display (string-append "#!" (assoc-ref inputs "bash-minimal")
                                            "/bin/sh\n"
                                            "ln -sf " dynamic-linker " /tmp/ld-linux-x86-64.so.2\n"
                                            "export DOTNET_ROOT=" dotnet-root "\n"
                                            "export LD_LIBRARY_PATH=" gcc-lib ":" gtk-lib ":${LD_LIBRARY_PATH:-}\n"
                                            "exec " lib "/OpenTabletDriver.Daemon \"$@\"\n")
                             port)))
                (chmod (string-append bin "/otd-daemon") #o555)
                ;; otd-gui
                (call-with-output-file (string-append bin "/otd-gui")
                  (lambda (port)
                    (display (string-append "#!" (assoc-ref inputs "bash-minimal")
                                            "/bin/sh\n"
                                            "ln -sf " dynamic-linker " /tmp/ld-linux-x86-64.so.2\n"
                                            "export DOTNET_ROOT=" dotnet-root "\n"
                                            "export LD_LIBRARY_PATH=" gcc-lib ":" gtk-lib ":${LD_LIBRARY_PATH:-}\n"
                                            "exec " lib "/OpenTabletDriver.UX.Gtk \"$@\"\n")
                             port)))
                (chmod (string-append bin "/otd-gui") #o555))))
          (add-after 'install-bin 'patch-interpreter
            (lambda* (#:key outputs #:allow-other-keys)
              (let* ((out (assoc-ref outputs "out"))
                     (lib (string-append out "/lib/opentabletdriver")))
                (for-each
                 (lambda (file)
                   (invoke "patchelf"
                           "--set-interpreter" "/tmp/ld-linux-x86-64.so.2"
                           (string-append lib "/" file)))
                 '("OpenTabletDriver.Console"
                   "OpenTabletDriver.Daemon"
                   "OpenTabletDriver.UX.Gtk")))))
          (add-after 'install-bin 'install-desktop
            (lambda _
              (let ((apps (string-append #$output "/share/applications")))
                (mkdir-p apps)
                (make-desktop-entry-file (string-append apps "/opentabletdriver.desktop")
                                         #:name "OpenTabletDriver"
                                         #:generic-name "Tablet driver settings"
                                         #:comment "A cross-platform open-source tablet driver"
                                         #:exec "otd-gui"
                                         #:icon "otd"
                                         #:categories '("HardwareSettings" "Settings" "GTK")
                                         #:startup-w-m-class "OpenTabletDriver.UX")))))))
    (inputs (list bash-minimal dotnet gtk+ `(,gcc "lib")))
    (native-inputs (list patchelf))
    (home-page "https://opentabletdriver.net")
    (synopsis "Open source, cross-platform, user-mode tablet driver")
    (description
     "OpenTabletDriver is an open source, cross-platform, user-mode tablet driver.
It supports many different tablets and provides a GUI for configuration.")
    (license license:lgpl3+)))

;; Keep the historical package name for channel users.
(define-public opentabletdriver opentabletdriver-bin)

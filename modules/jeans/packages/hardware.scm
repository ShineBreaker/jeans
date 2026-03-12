;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-only

(define-module (jeans packages hardware)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages elf)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages libusb)
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

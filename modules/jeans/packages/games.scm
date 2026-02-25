;;; SPDX-FileCopyrightText: 2024, 2025 Murilo <murilo@disroot.org>
;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-only

(define-module (jeans packages games)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages bootstrap)
  #:use-module (gnu packages commencement)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages elf)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages gl)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages gnuzilla)
  #:use-module (gnu packages gstreamer)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages icu4c)
  #:use-module (gnu packages image)
  #:use-module (gnu packages instrumentation)
  #:use-module (gnu packages libevent)
  #:use-module (gnu packages libffi)
  #:use-module (gnu packages linphone)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages nss)
  #:use-module (gnu packages pciutils)
  #:use-module (gnu packages pulseaudio)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages video)
  #:use-module (gnu packages vulkan)
  #:use-module (gnu packages web)
  #:use-module (gnu packages webkit)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages xorg)
  #:use-module (guix build utils)
  #:use-module (guix build-system cargo)
  #:use-module (guix build-system copy)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system trivial)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix packages)
  #:use-module (guix utils))

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

(define-public osu-lazer-tachyon-bin
  (package
    (name "osu-lazer-tachyon-bin")
    (version "2026.209.0-tachyon")
    (source
      (origin
        (method url-fetch)
        (uri
          (string-append "https://github.com/ppy/osu/releases/download/"
                         version
                         "/osu.AppImage"))
        (sha256
          (base32 "0i6ir1f7xv600qlbh3s4117ln4346hwdzzzyc0aaj3b0qqrsdksa"))))
    (build-system copy-build-system)
    (arguments
      (list #:install-plan
            #~'(("usr/share/" "share/")
                ("usr/bin/" "lib/osu/")
                ("osu!.desktop" "share/applications/"))
            #:modules '((guix build utils)
                        (guix build copy-build-system)
                        (ice-9 format))
            #:phases
            #~(modify-phases %standard-phases
                (add-after 'unpack 'extract-appimage
                  (lambda _
                    (invoke "7z" "x" "osu.AppImage")))
                (add-after 'extract-appimage 'remove-unused-files
                  (lambda _
                    (map delete-file '("usr/bin/UpdateNix"))))
                (add-after 'install 'patch-elf
                  (lambda* (#:key inputs #:allow-other-keys)
                    (let ((ld.so (string-append #$(this-package-input "glibc")
                                                #$(glibc-dynamic-linker)))
                          (rpath (string-join
                                   (cons*
                                     (string-append #$output "/lib/osu")
                                     (map
                                       (lambda (input)
                                         (string-append (cdr input) "/lib"))
                                       inputs))
                                   ":")))
                      ;; Got this proc from hako's Rosenthal, thanks
                      (define (patch-elf file)
                        (format #t "Patching ~a ..." file)
                        (unless (string-contains file ".so")
                          (invoke "patchelf" "--set-interpreter" ld.so file))
                        (invoke "patchelf" "--set-rpath" rpath file)
                        (display " done\n"))
                      (for-each
                        (lambda (binary)
                          (patch-elf binary))
                        (append
                          (map
                            (lambda (binary)
                              (string-append #$output "/lib/osu/" binary))
                            '("osu!"))
                          (find-files (string-append #$output "/lib/osu") ".*\\.so.*"))))))
                (add-after 'patch-elf 'wrap-program
                  (lambda _
                    (let* ((bin (string-append #$output "/lib/osu/osu!"))
                           (wrapper (string-append #$output "/bin/osu!")))
                      (mkdir-p (dirname wrapper))
                      (symlink bin wrapper)
                      (wrap-program wrapper
                        `("OSU_EXTERNAL_UPDATE_PROVIDER" = ("1"))
                        `("SDL_VIDEODRIVER" = ("wayland"))
                        `("LD_LIBRARY_PATH" prefix (,(string-append #$output "/lib/osu")))))))
                (add-after 'wrap-program 'fix-so
                  (lambda _
                    (symlink (string-append #$(this-package-input "lttng-ust") "/lib/liblttng-ust.so")
                             (string-append #$output "/lib/osu/liblttng-ust.so.0"))
                    (symlink (string-append #$(this-package-input "eudev") "/lib/libudev.so.1.6.3")
                             (string-append #$output "/lib/osu/libudev.so.0"))))
                (add-after 'wrap-program 'make-files-executable
                  (lambda _
                    (let* ((lib-osu (string-append #$output "/lib/osu")))
                      (map (lambda (file)
                             (chmod file #o555))
                           (cons* (string-append lib-osu "/osu!")
                                  (append (find-files lib-osu ".*\\.dll")
                                          (find-files lib-osu ".*\\.so.*")))))))
                (add-after 'install 'install-udev-rules
                  (lambda _
                    (let* ((relative-rules.d "/lib/udev/rules.d")
                           (otd-rules (string-append #$(this-package-native-input "opentabletdriver-udev-rules")
                                                     relative-rules.d
                                                     "/70-opentabletdriver.rules"))
                           (rules.d (string-append #$output relative-rules.d)))
                      (install-file otd-rules rules.d)))))))
    (native-inputs (list p7zip patchelf opentabletdriver-udev-rules))
    (inputs
      (list alsa-lib
            dbus
            elfutils
            eudev
            gcc-toolchain
            glib
            glibc
            icu4c
            libdrm
            libxcb
            libxext
            libxkbcommon
            lttng-ust
            mesa
            openssl
            vulkan-loader
            wayland
            zlib))
    (home-page "https://osu.ppy.sh/")
    (synopsis "rhythm is just a *click* away!")
    (description "A free-to-win rhythm game. This is the future – and final
– iteration of the osu! game client which marks the beginning of an open era!
Currently known by and released under the release codename lazer. As in
sharper than cutting-edge.")
    (properties '((upstream-name  . "osu")))
    (license license:expat)))

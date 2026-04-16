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
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages java)
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
  #:use-module (guix utils)
  #:use-module (jeans packages hardware))



;; OpenJFX 17 SDK (binary) — required by beatoraja for the JavaFX launcher.
;; JavaFX was removed from the JDK as of Java 11,
;; so it must be provided separately.
;; The pre-built native libraries (.so) depend on GTK3, GL, X11, etc.
;; We skip validate-runpath because patchelf-ing every JavaFX .so is impractical
;; and the library resolution happens at JVM level via --module-path.
(define openjfx17-sdk
  (package
    (name "openjfx17-sdk")
    (version "17.0.13")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://download2.gluonhq.com/openjfx/" version
             "/openjfx-" version "_linux-x64_bin-sdk.zip"))
       (sha256
        (base32 "16d1w8haw5mimrji7vpqg50g9hdn721jg68y10kil7c36ckyyc6h"))))
    (build-system gnu-build-system)
    (arguments
     (list
      #:tests? #f
      #:validate-runpath? #f
      #:modules '((guix build gnu-build-system)
                  (guix build utils))
      #:phases
      #~(modify-phases %standard-phases
          (delete 'configure)
          (delete 'build)
          (replace 'unpack
            (lambda _
              (invoke "unzip" #$source)))
          (replace 'install
            (lambda _
              (let ((out #$output)
                    (sdk-dir (string-append "javafx-sdk-" #$version)))
                (copy-recursively (string-append sdk-dir "/lib")
                                  (string-append out "/lib"))))))))
    (native-inputs (list unzip))
    (inputs (list gtk+ gdk-pixbuf glib pango cairo freetype fontconfig
                  libx11 libxrandr libxrender libxtst libxxf86vm
                   mesa libffi alsa-lib `(,gcc "lib")))
    (home-page "https://openjfx.io/")
    (synopsis "OpenJFX 17 SDK (binary, Linux x86_64)")
    (description "This package provides the Gluon OpenJFX 17 SDK
for Linux x86_64, containing the JavaFX runtime libraries
(JARs and native .so files).")
    (license (license:non-copyleft "file://legal/javafx.base/LICENSE"))))

(define-public beatoraja-bin
  (package
    (name "beatoraja-bin")
    (version "0.8.8")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://mocha-repository.info/download/beatoraja" version ".zip"))
       (sha256
        (base32 "1lk2ip2khgy129gg82277xgii4nx4iz1hfqkz7904b092ww64ij9"))))
    (build-system gnu-build-system)
    (arguments
     (list
      #:tests? #f
      #:modules '((guix build gnu-build-system)
                  (guix build utils))
      #:phases
      #~(modify-phases %standard-phases
          (delete 'configure)
          (delete 'build)
          (replace 'unpack
            (lambda _
              (invoke "unzip" #$source)))
          (replace 'install
            (lambda _
              (let* ((out #$output)
                     (share (string-append out "/share/beatoraja"))
                     (bin (string-append out "/bin"))
                     (pkg-dir (string-append "beatoraja" #$version))
                     (jfx-lib (string-append #$openjfx17-sdk "/lib")))
                (mkdir-p share)
                (install-file (string-append pkg-dir "/beatoraja.jar") share)
                (copy-recursively (string-append pkg-dir "/font")
                                  (string-append share "/font"))
                (copy-recursively (string-append pkg-dir "/ir")
                                  (string-append share "/ir"))
                (mkdir-p bin)
                (let ((wrapper (string-append bin "/beatoraja")))
                  (call-with-output-file wrapper
                    (lambda (port)
                      (format port "#!~a/bin/bash~%"
                                #$bash-minimal)
                     (format port
                       "mkdir -p \
\"${XDG_DATA_HOME:-$HOME/.local/share}/beatoraja\" \
|| exit 1~%")
                     (format port
                       "cd \
\"${XDG_DATA_HOME:-$HOME/.local/share}/beatoraja\" \
|| exit 1~%")
                      (format port "exec ~a/bin/java \
-Xms1g -Xmx4g \
-Dsun.java2d.opengl=true \
-Dawt.useSystemAAFontSettings=on \
-Dswing.aatext=true \
--module-path ~a \
--add-modules javafx.controls,javafx.fxml \
-jar ~a/share/beatoraja/beatoraja.jar \"$@\"~%"
                              #$openjdk17 jfx-lib out)))
                  (chmod wrapper #o755))
                ;; Desktop entry for application menu.
                (let ((apps (string-append out "/share/applications")))
                  (mkdir-p apps)
                  (call-with-output-file
                      (string-append apps "/beatoraja.desktop")
                    (lambda (port)
                      (format port
                        "[Desktop Entry]~@
                         Name=beatoraja~@
                         Comment=Cross-platform BMS rhythm game~@
                         Exec=~a/bin/beatoraja~@
                         Icon=beatoraja~@
                         Terminal=false~@
                         Type=Application~@
                         Categories=Game;ArcadeGame;~%"
                          out)))))))
           (add-after 'install 'wrap-beatoraja
             (lambda _
               (let ((wrapper
                       (string-append #$output "/bin/beatoraja"))
                     (jfx-lib
                       (string-append #$openjfx17-sdk "/lib"))
                     (lib-dirs
                       (list (string-append #$gtk+ "/lib")
                             (string-append #$gdk-pixbuf "/lib")
                             (string-append #$glib "/lib")
                             (string-append #$pango "/lib")
                             (string-append #$cairo "/lib")
                             (string-append #$freetype "/lib")
                             (string-append #$fontconfig "/lib")
                             (string-append #$libx11 "/lib")
                             (string-append #$libxrandr "/lib")
                             (string-append #$libxrender "/lib")
                             (string-append #$libxtst "/lib")
                             (string-append #$libxxf86vm "/lib")
                             (string-append #$mesa "/lib")
                             (string-append #$libffi "/lib")
                             (string-append #$alsa-lib "/lib")
                             (string-append #$gcc:lib "/lib"))))
                 (wrap-program wrapper
                   `("LD_LIBRARY_PATH" ":" prefix
                     ,(cons jfx-lib lib-dirs))
                   `("GDK_PIXBUF_MODULE_FILE" =
                     (,(string-append
                         #$gdk-pixbuf
                         "/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache")))
                    `("XDG_DATA_DIRS" ":" prefix
                      (,(string-append #$output "/share")
                       ,(string-append #$gdk-pixbuf "/share")
                       ,(string-append #$gtk+ "/share"))))))))))
    (inputs (list openjdk17 openjfx17-sdk bash-minimal
                  gtk+ gdk-pixbuf glib pango cairo freetype fontconfig
                  libx11 libxrandr libxrender libxtst libxxf86vm
                    mesa libffi alsa-lib `(,gcc "lib")))
    (native-inputs (list unzip))
    (home-page "https://mocha-repository.info/")
    (synopsis "Cross-platform BMS rhythm game based on Java and libGDX")
    (description "beatoraja is a cross-platform rhythm game
(BMS player) based on Java and libGDX.  It supports various
BMS formats including bmson, offers multiple groove gauge types,
long note modes, and real-time play speed control.  The game
requires OpenGL 3.1+ and is recommended to run with
Java 17 64-bit.")
    (license license:gpl3)))

(define-public osu-lazer-bin
  (package
    (name "osu-lazer-bin")
    (version "2026.406.0-lazer")
    (source
      (origin
        (method url-fetch)
        (uri
          (string-append "https://github.com/ppy/osu/releases/download/"
                         version
                         "/osu.AppImage"))
        (sha256
          (base32 "0bgiy77y0r4067b9yngf27dsbqnv0n4cgxc2fmxq21bpbxzs38j4"))))
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

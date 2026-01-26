;;; SPDX-FileCopyrightText: 2024, 2025 Murilo <murilo@disroot.org>
;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-only

(define-module (jeans packages binaries)
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

(define-public zen-browser-bin
  (package
    (name "zen-browser-bin")
    (version "1.18.1b")
    (source
      (origin
        (method url-fetch)
        (uri (string-append
                "https://github.com/zen-browser/desktop/releases/download/"
                version
                "/zen.linux-x86_64.tar.xz"))
        (sha256
          (base32 "0y476zd2sxax2j7ncqcyglcyn22v3anqjbqqkfpv0qaww9crvvqk"))))
    (build-system copy-build-system)
    (arguments
      (list #:install-plan
            #~'(("." "lib/zen"))
            #:modules `((ice-9 regex)
                        (ice-9 string-fun)
                        (ice-9 ftw)
                        (srfi srfi-1)
                        (srfi srfi-26)
                        (rnrs bytevectors)
                        (rnrs io ports)
                        (guix elf)
                        (guix build gremlin)
                        ,@%copy-build-system-modules
                        ,@%default-gnu-imported-modules)
            #:phases
            #~(modify-phases (@@ (guix build copy-build-system) %standard-phases)
                (add-after 'install 'wrap-program
                  (lambda* (#:key inputs outputs #:allow-other-keys)
                    (define (runpath-of lib)
                      (call-with-input-file lib
                        (compose elf-dynamic-info-runpath
                                 elf-dynamic-info
                                 parse-elf
                                 get-bytevector-all)))
                    (define (runpaths-of-input label)
                      (let* ((dir (string-append (assoc-ref inputs label) "/lib"))
                             (libs (find-files dir "\\.so$")))
                        (append-map runpath-of libs)))
                    (let* ((out (assoc-ref outputs "out"))
                           (lib (string-append out "/lib"))
                           ; ;; TODO: make me a loop again
                           (mesa-lib (string-append (assoc-ref inputs "mesa") "/lib"))
                           ;; For the integration of native notifications
                           (libnotify-lib (string-append (assoc-ref inputs "libnotify")
                                                         "/lib"))
                           ;; For hardware video acceleration via VA-API
                           (libva-lib (string-append (assoc-ref inputs "libva")
                                                     "/lib"))
                           ;; Needed for video acceleration (via libdrm which mesa
                           ;; and libva depend on).
                           (pciaccess-lib (string-append (assoc-ref inputs "libpciaccess")
                                                         "/lib"))
                           ;; VA-API is run in the RDD (Remote Data Decoder) sandbox
                           ;; and must be explicitly given access to files it needs.
                           ;; Rather than adding the whole store (as Nix had
                           ;; upstream do, see
                           ;; <https://github.com/NixOS/nixpkgs/pull/165964> and
                           ;; linked upstream patches), we can just follow the
                           ;; runpaths of the needed libraries to add everything to
                           ;; LD_LIBRARY_PATH.  These will then be accessible in the
                           ;; RDD sandbox.
                           ;; TODO: Properly handle the runpath of libraries needed
                           ;; (for RDD) recursively, so the explicit libpciaccess
                           ;; can be removed.
                           (rdd-whitelist
                            (map (cut string-append <> "/")
                                 (delete-duplicates
                                  (append-map runpaths-of-input
                                              '("mesa" "ffmpeg")))))
                           (pulseaudio-lib (string-append (assoc-ref inputs "pulseaudio")
                                                          "/lib"))
                           ;; For sharing on Wayland
                           (pipewire-lib (string-append (assoc-ref inputs "pipewire")
                                                        "/lib"))
                           ;; For U2F and WebAuthn
                           (eudev-lib (string-append (assoc-ref inputs "eudev")
                                                     "/lib"))
                           (gtk-share (string-append (assoc-ref inputs "gtk+")
                                                     "/share")))
                      (wrap-program (car (find-files lib "^zen$"))
                        `("LD_LIBRARY_PATH" prefix (
                                                    ,mesa-lib
                                                    ,libnotify-lib
                                                    ,libva-lib
                                                    ,pciaccess-lib
                                                    ,pulseaudio-lib
                                                    ,eudev-lib
                                                    ,@rdd-whitelist
                                                    ,pipewire-lib))
                        `("XDG_DATA_DIRS" prefix (,gtk-share))
                        `("MOZ_LEGACY_PROFILES" = ("1"))
                        `("MOZ_ALLOW_DOWNGRADE" = ("1"))))))
                (add-after 'install 'patch-elf
                  (lambda* (#:key inputs #:allow-other-keys)
                    (let ((ld.so (string-append #$(this-package-input "glibc")
                                                #$(glibc-dynamic-linker)))
                          (rpath (string-join
                                   (cons*
                                     (string-append #$output "/lib/zen")
                                     (string-append #$output "/lib/zen/gmp-clearkey/0.1")
                                     (string-append #$(this-package-input "gtk+") "/share")
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
                              (string-append #$output "/lib/zen/" binary))
                            '("glxtest" "updater" "vaapitest" "zen" "zen-bin" "pingsender"))
                          (find-files (string-append #$output "/lib/zen") ".*\\.so.*"))))))
                (add-after 'patch-elf 'install-bin
                  (lambda _
                    (let* ((zen (string-append #$output "/lib/zen/zen"))
                           (bin-zen (string-append #$output "/bin/zen")))
                      (mkdir (string-append #$output "/bin"))
                      (symlink zen bin-zen))))
                (add-after 'install-bin 'install-desktop
                  (lambda _
                    (let* ((share-applications (string-append #$output "/share/applications"))
                           (desktop (string-append share-applications "/zen.desktop")))
                      (mkdir-p share-applications)
                      (make-desktop-entry-file desktop
                        #:name "Zen Browser"
                        #:icon "zen"
                        #:type "Application"
                        #:comment #$(package-synopsis this-package)
                        #:exec (string-append #$output "/bin/zen %u")
                        #:keywords '("Internet" "WWW" "Browser" "Web" "Explorer")
                        #:categories '("Network" "Browser")
                        ; #:actions '("new-window" "new-private-window" "profilemanager")
                        #:mime-type '("text/html"
                                      "text/xml"
                                      "application/xhtml+xml"
                                      "x-scheme-handler/http"
                                      "x-scheme-handler/https"
                                      "application/x-xpinstall"
                                      "application/pdf"
                                      "application/json")
                        #:startup-w-m-class "zen-alpha"))))
                (add-after 'install-desktop 'install-icons
                  (lambda _
                    (let* ((icon-source (string-append #$output "/lib/zen/browser/chrome/icons/default"))
                           (icon-target (string-append #$output "/share/icons/hicolor")))
                      ;; Check if icon directory exists
                      (when (file-exists? icon-source)
                        ;; Create target directories for different icon sizes
                        (for-each
                          (lambda (size)
                            (let* ((target-dir (string-append icon-target "/" size "/apps"))
                                   (icon-file (string-append icon-source "/default" size ".png")))
                              (when (file-exists? icon-file)
                                (mkdir-p target-dir)
                                (install-file icon-file target-dir
                                              #:rename "zen.png"))))
                          '("48x48" "64x64" "128x128" "256x256"))
                        ;; Also try to copy the default icon if it exists
                        (let* ((default-icon (string-append icon-source "/default.png"))
                               (fallback-dir (string-append icon-target "/48x48/apps")))
                          (when (file-exists? default-icon)
                            (mkdir-p fallback-dir)
                            (install-file default-icon fallback-dir
                                          #:rename "zen.png"))))))))))
    (native-inputs (list patchelf))
    (inputs (list alsa-lib
                  eudev
                  gcc-toolchain
                  icu4c
                  gtk+
                  glibc
                  libnotify
                  libva
                  pciutils
                  mesa
                  ffmpeg-6
                  libpciaccess
                  pipewire
                  pulseaudio))
    (home-page "https://zen-browser.app/")
    (synopsis "Experience tranquillity while browsing the web without people
tracking you!")
    (description "Beautifully designed, privacy-focused, and packed with features.
We care about your experience, not your data.")
    (properties `((upstream-name . "zen")))
    (license (list license:mpl2.0))))

(define opentabletdriver-udev-rules
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
    (version "2026.124.0-tachyon")
    (source
      (origin
        (method url-fetch)
        (uri
          (string-append "https://github.com/ppy/osu/releases/download/"
                         version
                         "/osu.AppImage"))
        (sha256
          (base32 "1334n9pq28dh6a1a3m50gz1ih4lbp82x5lljzaz22gicdlvr27wp"))))
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

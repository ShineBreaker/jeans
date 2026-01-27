;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-only

(define-module (jeans packages desktop)
  #:use-module (gnu packages)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages bootstrap)
  #:use-module (gnu packages check)
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
  #:use-module (gnu packages networking)
  #:use-module (gnu packages nss)
  #:use-module (gnu packages pciutils)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages pulseaudio)
  #:use-module (gnu packages python)
  #:use-module (gnu packages python-build)
  #:use-module (gnu packages python-xyz)
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
  #:use-module (guix build-system python)
  #:use-module (guix build-system trivial)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module ((guix licenses) #:prefix license:))

(define-public waypaper
  (package
    (name "waypaper")
    (version "2.7")
    (source (origin
              (method url-fetch)
              (uri (string-append
                    "https://github.com/anufrievroman/waypaper/archive/refs/tags/"
                    version ".tar.gz"))
              (sha256
               (base32
                "18yxsic5pfxf3cxn5l5cmi72566qq5v74baa7fnc9g2kgm9m3czm"))))
    (build-system python-build-system)
    (arguments
     (list
      #:tests? #f
      #:phases
      #~(modify-phases %standard-phases
          (delete 'sanity-check)
          (add-after 'install 'wrap-gi-typelib
            (lambda* (#:key inputs outputs #:allow-other-keys)
              (let ((out (assoc-ref outputs "out"))
                    (gi-path (getenv "GI_TYPELIB_PATH")))
                (wrap-program (string-append out "/bin/waypaper")
                  `("GI_TYPELIB_PATH" ":" prefix (,gi-path)))))))))
    (native-inputs
     (list python-setuptools-scm
           pkg-config
           gobject-introspection))
    (propagated-inputs
     (list gtk+
           python-pygobject
           python-platformdirs
           python-pillow
           python-imageio
           python-imageio-ffmpeg
           socat))
    (home-page "https://github.com/anufrievroman/waypaper")
    (synopsis "GUI wallpaper manager for Wayland and Xorg Linux systems")
    (description
     "Waypaper is a simple GUI wallpaper manager for Linux, supporting both Wayland
and Xorg.")
    (license license:gpl3)))

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
          (base32 "0g0xqgqs1mjfzq659rfziwm7kdhf55zby1p5bm8s3mbmn9g6djih"))))
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
                    (let* ((out #$output)
                           (icon-source (string-append out
                                                       "/lib/zen/browser/chrome/icons/default"))
                           (icon-target (string-append out
                                                       "/share/icons/hicolor"))
                           (icons '(("16"  . "16x16")
                                    ("32"  . "32x32")
                                    ("48"  . "48x48")
                                    ("64"  . "64x64")
                                    ("128" . "128x128"))))
                      (when (file-exists? icon-source)
                        (for-each
                          (lambda (entry)
                            (let* ((file-size (car entry))
                                   (dir-size  (cdr entry))
                                   (icon-file (string-append icon-source
                                                             "/default"
                                                             file-size
                                                             ".png"))
                                   (target-dir (string-append icon-target
                                                              "/"
                                                              dir-size
                                                              "/apps")))
                              (when (file-exists? icon-file)
                                (mkdir-p target-dir)
                                (copy-file icon-file
                                           (string-append target-dir "/zen.png")))))
                          icons))))))))
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

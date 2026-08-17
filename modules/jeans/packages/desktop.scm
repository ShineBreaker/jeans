;;; SPDX-FileCopyrightText: 2024, 2025 Murilo <murilo@disroot.org>
;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-only

(define-module (jeans packages desktop)
  #:use-module (gnu packages)
  #:use-module (gnu packages assembly)    ; nasm
  #:use-module (gnu packages backup)      ; libarchive
  #:use-module (gnu packages base)        ; glibc
  #:use-module (gnu packages bash)        ; bash-minimal
  #:use-module (gnu packages bootstrap)   ; glibc-dynamic-linker
  #:use-module (gnu packages compression) ; zlib, lz4
  #:use-module (gnu packages cups)        ; cups
  #:use-module (gnu packages elf)         ; patchelf
  #:use-module (gnu packages fontutils)   ; fontconfig, freetype
  #:use-module (gnu packages freedesktop) ; wayland, xdg-utils
  #:use-module (gnu packages gcc)         ; gcc:lib
  #:use-module (gnu packages gl)          ; mesa (libgbm), libglvnd
  #:use-module (gnu packages glib)        ; dbus, gobject-introspection
  #:use-module (gnu packages gtk)         ; gtk+, harfbuzz, cairo, pango, at-spi2-core
  #:use-module (gnu packages linux)       ; alsa-lib, eudev
  #:use-module (gnu packages networking)  ; socat
  #:use-module (gnu packages nss)         ; nss, nspr
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages python-build) ; python-setuptools-scm
  #:use-module (gnu packages python-xyz)  ; python-screeninfo, python-platformdirs, python-pillow, ...
  #:use-module (gnu packages video)       ; ffmpeg
  #:use-module (gnu packages vulkan)      ; vulkan-loader
  #:use-module (gnu packages xml)         ; expat
  #:use-module (gnu packages xdisorg)     ; libdrm, libxkbcommon
  #:use-module (gnu packages xorg)        ; libice, libsm, libx11, libxcb, libxcomposite, ...
  #:use-module (guix build-system copy)
  #:use-module (guix build-system python)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix packages)
  #:use-module (guix utils)               ; substitute-keyword-arguments
  #:use-module ((guix licenses)
                #:prefix license:))

(define-public waypaper
  (package
    (name "waypaper")
    (version "2.8")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/anufrievroman/waypaper")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0xd37qr6m2icjl0w0saq3318nw4g7i7zna5m1yr6ym3zp2byjdh5"))))
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
                  `("GI_TYPELIB_PATH" ":" prefix
                    (,gi-path)))))))))
    (native-inputs (list python-setuptools-scm pkg-config
                         gobject-introspection))
    (inputs `(("bash-minimal" ,bash-minimal)))
    (propagated-inputs (list gtk+
                             python-pygobject
                             python-platformdirs
                             python-pillow
                             python-imageio
                             python-imageio-ffmpeg
                             python-screeninfo
                             socat))
    (home-page "https://github.com/anufrievroman/waypaper")
    (synopsis "GUI wallpaper manager for Wayland and Xorg Linux systems")
    (description
     "Waypaper is a simple GUI wallpaper manager for Linux, supporting both Wayland
and Xorg.")
    (license license:gpl3)))

;; Waywallen bundles its entire Qt6/ffmpeg/Vulkan-stack in the AppImage
;; (usr/lib).  Only a handful of libraries are not bundled and must come from
;; Guix: the C runtime (glibc, libgcc_s), the Vulkan ICD loader, libgbm (mesa)
;; and libwayland-client.  The AppRun layout ($ORIGIN/../lib + qt.conf) is
;; preserved verbatim under lib/waywallen so Qt finds its plugins and QML
;; modules; patchelf only repoints the interpreter and appends the Guix store
;; dirs to RUNPATH.
(define-public waywallen-bin
  (package
    (name "waywallen-bin")
    (version "0.3.5")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/waywallen/waywallen/releases/download/v"
             version
             "/waywallen-" version "-x86_64.AppImage"))
       (sha256
        (base32 "1irim403q6xfbhp0bjf2lkqixrsiq4s1j0cq3jk1zhp6pwpnfm5k"))))
    (build-system copy-build-system)
    (arguments
     (list
      #:tests? #f
      #:validate-runpath? #f
      #:strip-binaries? #f
      #:install-plan
      #~'(("squashfs-root/usr/" "lib/waywallen/")
          ("squashfs-root/org.waywallen.waywallen.svg"
           "share/icons/hicolor/scalable/apps/org.waywallen.waywallen.svg"))
      #:modules '((guix build utils)
                  (guix build copy-build-system)
                  (ice-9 format)
                  (srfi srfi-26))
      #:phases
      #~(modify-phases %standard-phases
          (delete 'install-license-files)
          ;; The AppImage runtime extracts itself into ./squashfs-root.
          ;; Store paths are read-only, so copy the AppImage to the build
          ;; directory and make it executable before invoking its built-in
          ;; --appimage-extract handler.
          (replace 'unpack
            (lambda* (#:key source #:allow-other-keys)
              (copy-file source "waywallen.AppImage")
              (chmod "waywallen.AppImage" #o755)
              (invoke "./waywallen.AppImage" "--appimage-extract")))
          (add-after 'install 'patch-elf
            (lambda* (#:key inputs #:allow-other-keys)
              (let* ((ld.so (string-append (assoc-ref inputs "glibc")
                                           #$(glibc-dynamic-linker)))
                     (lib-dir (string-append #$output "/lib/waywallen/lib"))
                     ;; RUNPATH keeps the bundled Qt/ffmpeg stack first
                     ;; ($ORIGIN/../lib is already baked in) and appends the
                     ;; Guix store dirs for every input, so the non-bundled
                     ;; transitive deps (zlib, libdrm, dbus, fontconfig,
                     ;; freetype, libglvnd, harfbuzz, the X11/xcb/xkbcommon
                     ;; stack, glibc, gcc:lib, mesa, vulkan-loader, wayland)
                     ;; all resolve.  Build-side `inputs' preserves the
                     ;; sub-output path for "gcc:lib".
                     (rpath
                      (string-join
                       (cons* lib-dir
                              (map (lambda (input)
                                     (string-append (cdr input) "/lib"))
                                   inputs))
                       ":")))
                (define (patch-elf file)
                  (format #t "Patching ~a ..." file)
                  (unless (string-contains file ".so")
                    (invoke "patchelf" "--set-interpreter" ld.so file))
                  (invoke "patchelf" "--set-rpath" rpath file)
                  (display " done\n"))
                (for-each patch-elf
                          (find-files (string-append #$output "/lib/waywallen")
                                      (lambda (file stat)
                                        (and (eq? 'regular (stat:type stat))
                                             (elf-file? file))))))))
          (add-after 'patch-elf 'build-wrapper
            (lambda _
              ;; Reproduce the AppRun contract: expose the bundled Qt
              ;; plugins / QML modules and the bundled libs, then exec the
              ;; daemon which spawns the UI, renderers and layer shell.
              (let* ((bin (string-append #$output "/bin"))
                     (root (string-append #$output "/lib/waywallen"))
                     (wrapper (string-append bin "/waywallen")))
                (mkdir-p bin)
                (call-with-output-file wrapper
                  (lambda (port)
                    (format port "#!~a/bin/bash~%" #$bash-minimal)
                    (format port "set -e~%")
                    (format port "ROOT=\"~a\"~%" root)
                    (format port
                            "export LD_LIBRARY_PATH=\"")
                    (format port "$ROOT/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}\"~%")
                    (format port "export QT_PLUGIN_PATH=\"")
                    (format port "$ROOT/plugins${QT_PLUGIN_PATH:+:$QT_PLUGIN_PATH}\"~%")
                    (format port "export QML2_IMPORT_PATH=\"")
                    (format port "$ROOT/qml${QML2_IMPORT_PATH:+:$QML2_IMPORT_PATH}\"~%")
                    (format port "export QML_IMPORT_PATH=\"$QML2_IMPORT_PATH\"~%")
                    (format port "exec \"$ROOT/bin/waywallen\" \"$@\"~%")))
                (chmod wrapper #o755))))
          (add-after 'build-wrapper 'install-desktop-entry
            (lambda _
              (let ((apps (string-append #$output "/share/applications")))
                (mkdir-p apps)
                (call-with-output-file
                    (string-append apps "/org.waywallen.waywallen.desktop")
                  (lambda (port)
                    (format port "[Desktop Entry]~%")
                    (format port "Type=Application~%")
                    (format port "Name=Waywallen~%")
                    (format port "GenericName=Wallpaper Manager for Linux~%")
                    (format port "Comment=Dynamic wallpaper manager for Linux~%")
                    (format port "Exec=~a/bin/waywallen~%" #$output)
                    (format port "Icon=org.waywallen.waywallen~%")
                    (format port "Terminal=false~%")
                    (format port "Categories=Graphics;Qt;~%")
                    (format port "Keywords=wallpaper;pipewire;vulkan;~%")
                    (format port "StartupNotify=true~%")))))))))
    (native-inputs (list patchelf))
    ;; The AppImage bundles Qt6, ffmpeg and the codec stack; these inputs only
    ;; cover the libraries the bundle expects from the host (the C runtime,
    ;; GL/Vulkan dispatch, Wayland, X11/xcb/xkbcommon, and the font stack).
    (inputs
     `(("bash-minimal" ,bash-minimal)
       ("glibc" ,glibc)
       ("gcc:lib" ,gcc "lib")
       ("mesa" ,mesa)
       ("libglvnd" ,libglvnd)
       ("vulkan-loader" ,vulkan-loader)
       ("wayland" ,wayland)
       ("libdrm" ,libdrm)
       ("dbus" ,dbus)
       ("fontconfig-minimal" ,fontconfig)
       ("freetype" ,freetype)
       ("harfbuzz" ,harfbuzz)
       ("libice" ,libice)
       ("libsm" ,libsm)
       ("libx11" ,libx11)
       ("libxcb" ,libxcb)
       ("libxkbcommon" ,libxkbcommon)
       ("zlib" ,zlib)))
    ;; Release assets are waywallen-<version>-x86_64.AppImage; upstream-name is
    ;; the filename prefix before the version.
    (properties `((upstream-name . "waywallen")))
    (home-page "https://github.com/waywallen/waywallen")
    (synopsis "Dynamic wallpaper manager for Linux desktops")
    (description "Waywallen is a dynamic wallpaper manager for Linux that began
as a Wallpaper Engine plugin for KDE.  It renders image, video and web
wallpapers using Vulkan and VA-API hardware decoding, and integrates with the
desktop through a Wayland layer shell and a QtQuick interface.

This package ships the upstream AppImage verbatim; Qt6, ffmpeg and the codec
stack are bundled, while the Vulkan loader, libgbm and libwayland-client are
provided by Guix.")
    (license license:expat)
    (supported-systems '("x86_64-linux"))))

;;; Minimal shared-library ffmpeg 7.x.  Guix only ships ffmpeg 8.x/6.x/5.x/4.x
;;; (no 7.x), but the open-wallpaper-engine @code{wescene-renderer} is linked
;;; against the ffmpeg 7 sonames (libavformat.so.61, libavcodec.so.61,
;;; libavutil.so.59, libswscale.so.8, libswresample.so.5).  This private helper
;;; pins 7.1.5 and builds only the shared libraries with ffmpeg's native
;;; codecs (which is sufficient for *decoding* video wallpapers); external
;;; codec libraries are deliberately omitted to keep the build fast.
(define ffmpeg-7
  (package
    (inherit ffmpeg)
    (name "ffmpeg-7")
    (version "7.1.5")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://ffmpeg.org/releases/ffmpeg-"
                           version ".tar.xz"))
       (sha256
        (base32
         "13smbpyfdy9w5clq1l3fv733i5djzm0k8iv2s4y5xqzrr84qarny"))))
    (outputs '("out"))
    (inputs (list zlib))
    (native-inputs (list pkg-config nasm))
    ;; ffmpeg ships a hand-written configure (not autoconf) that rejects the
    ;; CONFIG_SHELL=/--build= arguments gnu-build-system's default phase adds;
    ;; the inherited package keeps ffmpeg's custom @code{configure} phase and
    ;; only the configure-flags/tests are overridden here.
    (arguments
     (substitute-keyword-arguments (package-arguments ffmpeg)
       ((#:tests? old #f) #f)
       ((#:configure-flags old '())
        #~(list "--enable-shared"
                "--disable-static"
                "--enable-gpl"
                "--disable-doc"
                "--disable-programs"
                "--enable-runtime-cpudetect"
                "--enable-zlib"))))))

;; Open Wallpaper Engine is a Waywallen plugin: a Vulkan scene renderer
;; (waywallen-wescene-renderer) plus a CEF-backed web renderer
;; (waywallen-weweb-renderer + libcef.so and the CEF runtime) and a Steam
;; Workshop source.  Upstream ships a single prebuilt zstd-zipped plugin tree
;; per architecture; this package installs it verbatim under the directory
;; Waywallen's plugin scanner searches for system plugins.
(define-public open-wallpaper-engine-bin
  (package
    (name "open-wallpaper-engine-bin")
    (version "0.2.5")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/waywallen/open-wallpaper-engine/releases/download/v"
             version
             "/org.waywallen.open-wallpaper-engine-" version
             "-linux-x86_64.zip"))
       (sha256
        (base32 "1hgfp6fikch4aq4g88590qlwffqzl5w86di6sdcxzs8igfv231g2"))))
    (build-system copy-build-system)
    (arguments
     (list
      #:tests? #f
      #:validate-runpath? #f
      #:strip-binaries? #f
      #:modules '((guix build utils)
                  (guix build copy-build-system)
                  (ice-9 format))
      #:phases
      #~(modify-phases %standard-phases
          (delete 'install-license-files)
          ;; The upstream archive uses zstd compression (PK 6.3), which the
          ;; system unzip cannot read; libarchive's bsdtar handles it.
          (replace 'unpack
            (lambda* (#:key source #:allow-other-keys)
              (invoke "bsdtar" "-xf" source)))
          ;; The release zip is already laid out as a plugin directory
          ;; (plugin.toml, main.lua, files.txt, wallpaper_engine/*.lua and
          ;; bin/).  Install it verbatim under the id Waywallen indexes it by.
          (replace 'install
            (lambda* (#:key outputs #:allow-other-keys)
              (let* ((out (assoc-ref outputs "out"))
                     (dest (string-append
                            out "/share/waywallen/plugins/"
                            "org.waywallen.open-wallpaper-engine")))
                (mkdir-p dest)
                (copy-recursively "bin" (string-append dest "/bin"))
                (copy-recursively "wallpaper_engine"
                                  (string-append dest "/wallpaper_engine"))
                (for-each (lambda (f) (install-file f dest))
                          '("main.lua" "plugin.toml" "files.txt"))
                (for-each
                 (lambda (f) (chmod (string-append dest "/" f) #o755))
                 '("bin/waywallen-wescene-renderer"
                   "bin/weweb/waywallen-weweb-renderer")))))
          ;; Repoint the interpreter and RUNPATH of every ELF in the plugin
          ;; tree.  The bundled CEF libraries (libcef.so, libGLESv2.so,
          ;; libEGL.so, libvk_swiftshader.so, libvulkan.so.1) keep finding
          ;; each other through $ORIGIN; the Guix store directories cover
          ;; every external dependency of both renderers and of libcef.so
          ;; (ffmpeg 7, Vulkan/GBM, the X11/cairo/pango/nss stack, etc.).
          ;; Build-side `inputs' preserves the sub-output path for "gcc:lib".
          (add-after 'install 'patch-elf
            (lambda* (#:key inputs #:allow-other-keys)
              (let* ((ld.so (string-append (assoc-ref inputs "glibc")
                                           #$(glibc-dynamic-linker)))
                     (root (string-append
                            #$output "/share/waywallen/plugins/"
                            "org.waywallen.open-wallpaper-engine"))
                     (rpath
                      (string-join
                       (cons "$ORIGIN"
                             (map (lambda (input)
                                    (string-append (cdr input) "/lib"))
                                  inputs))
                       ":")))
                (define (patch-elf file)
                  (format #t "Patching ~a ..." file)
                  (unless (string-contains file ".so")
                    (invoke "patchelf" "--set-interpreter" ld.so file))
                  (invoke "patchelf" "--set-rpath" rpath file)
                  (display " done\n"))
                (for-each patch-elf
                          (find-files root
                                      (lambda (file stat)
                                        (and (eq? 'regular (stat:type stat))
                                             (elf-file? file)))))))))))
    (native-inputs (list patchelf libarchive))
    ;; The plugin bundles CEF (Chromium) and the scene/web renderer binaries;
    ;; these inputs cover only the libraries those binaries expect from the
    ;; host.  ffmpeg-7 supplies the libav*/libsw* sonames the wescene-renderer
    ;; is linked against (Guix has no ffmpeg 7.x).
    (inputs
     `(("glibc" ,glibc)
       ("gcc:lib" ,gcc "lib")
       ("mesa" ,mesa)
       ("vulkan-loader" ,vulkan-loader)
       ("freetype" ,freetype)
       ("fontconfig-minimal" ,fontconfig)
       ("lz4" ,lz4)
       ("ffmpeg-7" ,ffmpeg-7)
       ("at-spi2-core" ,at-spi2-core)
       ("glib" ,glib)
       ("nss" ,nss)
       ("nspr" ,nspr)
       ("dbus" ,dbus)
       ("cups" ,cups)
       ("libx11" ,libx11)
       ("libxcomposite" ,libxcomposite)
       ("libxdamage" ,libxdamage)
       ("libxext" ,libxext)
       ("libxfixes" ,libxfixes)
       ("libxrandr" ,libxrandr)
       ("libxcb" ,libxcb)
       ("libxkbcommon" ,libxkbcommon)
       ("expat" ,expat)
       ("cairo" ,cairo)
       ("pango" ,pango)
       ("eudev" ,eudev)
       ("alsa-lib" ,alsa-lib)))
    ;; Release assets are org.waywallen.open-wallpaper-engine-<ver>-linux-*.zip;
    ;; upstream-name is the filename prefix before the version, tags use v*.
    (properties
     `((upstream-name . "org.waywallen.open-wallpaper-engine")
       (release-tag-prefix . "^v")))
    (home-page "https://github.com/waywallen/open-wallpaper-engine")
    (synopsis "Wallpaper Engine plugin for the Waywallen wallpaper daemon")
    (description
     "Open Wallpaper Engine is an open-source scene and web renderer plus a Steam
Workshop source plugin for the Waywallen wallpaper daemon.  It renders
Wallpaper Engine scene (@code{.pkg}), video and web wallpapers using Vulkan,
and ships two Waywallen renderer subprocesses: the @code{wescene} Vulkan
scene/video renderer and the @code{weweb} CEF-backed web renderer.

This package installs the upstream prebuilt plugin under
@file{share/waywallen/plugins/org.waywallen.open-wallpaper-engine/}.  Waywallen
discovers plugins from @file{$XDG_DATA_HOME/waywallen/plugins/} (or via
@option{--plugin @var{PATH}}); to activate it, symlink the plugin directory
there, or launch Waywallen with @option{--plugin} pointing at it.  The host
daemon is provided by the @code{waywallen-bin} package.")
    (license license:gpl2)
    (supported-systems '("x86_64-linux"))))

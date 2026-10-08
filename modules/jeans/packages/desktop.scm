;;; SPDX-FileCopyrightText: 2024, 2025 Murilo <murilo@disroot.org>
;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-only

(define-module (jeans packages desktop)
  #:use-module (gnu packages)
  #:use-module (gnu packages admin)       ; fastfetch-minimal
  #:use-module (gnu packages assembly)    ; nasm
  #:use-module (gnu packages audio)       ; cava
  #:use-module (gnu packages backup)      ; libarchive
  #:use-module (gnu packages base)        ; glibc
  #:use-module (gnu packages bash)        ; bash-minimal
  #:use-module (gnu packages bootstrap)   ; glibc-dynamic-linker
  #:use-module (gnu packages calendar)    ; khal
  #:use-module (gnu packages compression) ; zlib, lz4
  #:use-module (gnu packages cups)        ; cups
  #:use-module (gnu packages elf)         ; patchelf
  #:use-module (gnu packages fontutils)   ; fontconfig, freetype
  #:use-module (gnu packages freedesktop) ; wayland, xdg-utils
  #:use-module (gnu packages gcc)         ; gcc:lib
  #:use-module (gnu packages gl)          ; mesa (libgbm), libglvnd
  #:use-module (gnu packages glib)        ; dbus, gobject-introspection
  #:use-module (gnu packages gnome)       ; network-manager
  #:use-module (gnu packages gtk)         ; gtk+, harfbuzz, cairo, pango, at-spi2-core
  #:use-module (gnu packages guile)       ; guile-3.0
  #:use-module (gnu packages hardware)    ; ddcutil
  #:use-module (gnu packages imagemagick) ; imagemagick
  #:use-module (gnu packages linux)       ; alsa-lib, eudev
  #:use-module (gnu packages maths)       ; glm
  #:use-module (gnu packages multiprecision) ; gmp
  #:use-module (gnu packages networking)  ; socat
  #:use-module (gnu packages nss)         ; nss, nspr
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages pulseaudio)  ; pulseaudio
  #:use-module (gnu packages python)      ; python-minimal
  #:use-module (gnu packages python-build) ; python-setuptools-scm
  #:use-module (gnu packages python-xyz)  ; python-screeninfo, python-platformdirs, python-pillow, ...
  #:use-module (gnu packages qt)          ; qtbase, qtsvg
  #:use-module (gnu packages sdl)         ; sdl2
  #:use-module (gnu packages video)       ; ffmpeg, mpv
  #:use-module (gnu packages version-control) ; git-minimal
  #:use-module (gnu packages vulkan)      ; vulkan-loader
  #:use-module (gnu packages window-management) ; quickshell
  #:use-module (gnu packages xml)         ; expat
  #:use-module (gnu packages xdisorg)     ; libdrm, libxkbcommon
  #:use-module (gnu packages xorg)        ; libice, libsm, libx11, libxcb, libxcomposite, ...
  #:use-module (guix build-system cargo)
  #:use-module (guix build-system cmake)
  #:use-module (guix build-system copy)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system python)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix packages)
  #:use-module (jeans build-system binary)
  #:use-module (jeans packages rust-crates)
  #:use-module (guix utils)               ; substitute-keyword-arguments
  #:use-module ((guix licenses)
                #:prefix license:))

(define-public waypaper
  (package
    (name "waypaper")
    (version "2.9")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/anufrievroman/waypaper")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0m0j6r9knz2by7ajnp6lvkm56lgwkyrx4lg5myk1h93yal1mpfss"))))
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

;; ai-usagebar is a Rust waybar widget that reports Claude/GPT/GLM/OpenRouter
;; plan usage.  The release tarball ships two dynamically-linked glibc ELFs
;; (ai-usagebar CLI + ai-usagebar-tui) with no bundled libraries; the only
;; external program it may spawn (grok) is located via an absolute path in
;; config.toml, so no PATH wrapper is needed.  Patch the interpreter and
;; append a RUNPATH covering glibc and libgcc_s, then install both binaries.
;; 已迁移到 jeans-binary-build-system（纯参数迁移，等价 RPATH）。
(define-public ai-usagebar-bin
  (package
    (name "ai-usagebar-bin")
    (version "1.32.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/akitaonrails/ai-usagebar/releases/download/"
             "v" version "/ai-usagebar-linux-x86_64.tar.gz"))
       (sha256
        (base32 "19bfvn81krdgv5kvhiwbixaa57sm4zajd773l7q174v6ainrghl0"))))
    (build-system jeans-binary-build-system)
    (arguments
     (list
      #:unpack-method 'tar
      #:install-plan
      #~'(("ai-usagebar" "bin/ai-usagebar")
          ("ai-usagebar-tui" "bin/ai-usagebar-tui"))
      #:patchelf-plan
      #~'(("bin/ai-usagebar")
          ("bin/ai-usagebar-tui"))))
    (inputs
     `(("glibc" ,glibc)
       ("gcc:lib" ,gcc "lib")))
    ;; Release assets are ai-usagebar-linux-x86_64.tar.gz; upstream-name is
    ;; the filename prefix before the version, tags use v*.
    (properties `((upstream-name . "ai-usagebar")))
    (home-page "https://github.com/akitaonrails/ai-usagebar")
    (synopsis "Waybar widget for AI coding assistant usage")
    (description "AI UsageBar is a Rust waybar widget that monitors plans and
credits of AI coding assistants: Claude, Codex, GLM, Kimi, Grok, Cursor,
OpenRouter and more.  It reads each vendor's local credential or state files,
queries usage endpoints where needed, and renders a compact bar text with
percentage, reset timer and tooltip for the waybar panel.  It ships both the
@command{ai-usagebar} CLI (JSON output for custom widgets) and an interactive
@command{ai-usagebar-tui}.  This package provides the prebuilt binary
release.")
    (license license:expat)
    (supported-systems '("x86_64-linux"))))


;; Waywallen bundles its entire Qt6/ffmpeg/Vulkan-stack in the AppImage
;; (usr/lib).  Only a handful of libraries are not bundled and must come from
;; Guix: the C runtime (glibc, libgcc_s), the Vulkan ICD loader, libgbm (mesa)
;; and libwayland-client.  The AppRun layout ($ORIGIN/../lib + qt.conf) is
;; preserved verbatim under lib/waywallen so Qt finds its plugins and QML
;; modules; patchelf only repoints the interpreter and appends the Guix store
;; dirs to RUNPATH.
;;
;; The wrapper additionally covers two bundle gaps: it appends Guix's qtsvg
;; plugin dir to QT_PLUGIN_PATH (the bundle ships no SVG icon engine, so
;; themed SVG icons would render blank) and bridges plugin discovery —
;; upstream scans only <exec>/../share/waywallen and $XDG_DATA_HOME/waywallen,
;; never XDG_DATA_DIRS, so every XDG_DATA_DIRS entry containing a
;; waywallen/plugins/ tree is passed as a --plugin root.
;; 已迁移到 jeans-binary-build-system：解包/install/patchelf 走参数（目录条目），
;; 手写 Qt wrapper 与 desktop 入口保留自定义 phase。
(define-public waywallen-bin
  (package
    (name "waywallen-bin")
    (version "0.4.3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/waywallen/waywallen/releases/download/v"
             version
             "/waywallen-" version "-x86_64.AppImage"))
       (sha256
        (base32 "0klp29grlb21v5l87sn1gbk62i1ad3l3787pizlxs4hl9a799ikq"))))
    (build-system jeans-binary-build-system)
    (arguments
     (list
      #:unpack-method 'appimage-7z
      #:install-plan
      #~'(("usr/" "lib/waywallen/")
          ;; The AppImage root carries org.waywallen.waywallen.svg as a
          ;; relative symlink into usr/, which would dangle once installed;
          ;; copy the real file instead.
          ("usr/share/icons/hicolor/scalable/apps/org.waywallen.waywallen.svg"
           "share/icons/hicolor/scalable/apps/"))
      ;; lib-dir 必须指向旧 RPATH 首项 lib/waywallen/lib，故 app-dir 取嵌套路径。
      #:app-dir "waywallen/lib"
      ;; 无 SPEC 条目：RPATH 取 lib-dir + 全部 inputs 的 /lib（与旧逻辑一致，
      ;; 旧逻辑里不存在 /lib 的 input 本就是死条目）。
      #:patchelf-plan
      #~'(("lib/waywallen"))
      #:modules '((jeans build binary)
                  (guix build utils)
                  (ice-9 format)
                  (srfi srfi-26))
      #:phases
      #~(modify-phases %standard-phases
          ;; 解包/install/patchelf 已由上参数承担；此处只保留手写 Qt
          ;; wrapper 与 desktop 入口。
          (add-after 'patchelf 'build-wrapper
            (lambda _
              ;; Reproduce the AppRun contract: expose the bundled Qt
              ;; plugins / QML modules and the bundled libs, then exec the
              ;; daemon which spawns the UI, renderers and layer shell.
              ;; The bundled Qt ships no iconengines/ (no libqsvgicon.so),
              ;; so themed SVG icons would all render blank; qtsvg's plugin
              ;; dir is appended to QT_PLUGIN_PATH to provide the engine
              ;; (the wrapper's LD_LIBRARY_PATH keeps the bundled Qt 6.x
              ;; libraries first, so the plugin resolves against them).
              ;; The UI embeds its Material Symbols icon font as .woff2 in
              ;; its resources; decoding WOFF2 requires a brotli-enabled
              ;; freetype, so the freetype input is freetype-with-brotli
              ;; and its lib dir goes into LD_LIBRARY_PATH right after
              ;; $ROOT/lib — otherwise the plain freetype pulled in
              ;; transitively (e.g. via fontconfig's RUNPATH) wins the
              ;; soname race and every icon falls back to rendering its
              ;; ligature name as text ("check", "delete", ...).
              (let* ((bin (string-append #$output "/bin"))
                     (root (string-append #$output "/lib/waywallen"))
                     (qtsvg-plugins
                      (string-append #$(this-package-input "qtsvg")
                                     "/lib/qt6/plugins"))
                     (freetype-lib
                      (string-append #$(this-package-input
                                        "freetype-with-brotli")
                                     "/lib"))
                     (wrapper (string-append bin "/waywallen")))
                (mkdir-p bin)
                (call-with-output-file wrapper
                  (lambda (port)
                    (format port "#!~a/bin/bash~%" #$bash-minimal)
                    (format port "set -e~%")
                    (format port "ROOT=\"~a\"~%" root)
                    (format port
                            "export LD_LIBRARY_PATH=\"")
                    (format port "$ROOT/lib:~a" freetype-lib)
                    (format port "${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}\"~%")
                    (format port "export QT_PLUGIN_PATH=\"")
                    (format port "$ROOT/plugins:~a" qtsvg-plugins)
                    (format port "${QT_PLUGIN_PATH:+:$QT_PLUGIN_PATH}\"~%")
                    (format port "export QML2_IMPORT_PATH=\"")
                    (format port "$ROOT/qml${QML2_IMPORT_PATH:+:$QML2_IMPORT_PATH}\"~%")
                    (format port "export QML_IMPORT_PATH=\"$QML2_IMPORT_PATH\"~%")
                    ;; Waywallen only scans <exec>/../share/waywallen and
                    ;; $XDG_DATA_HOME/waywallen for plugins — it never reads
                    ;; XDG_DATA_DIRS, which is how Guix profiles expose their
                    ;; share/ tree.  Bridge the two: every XDG_DATA_DIRS entry
                    ;; containing waywallen/plugins/ is passed as a --plugin
                    ;; root (upstream expects the prefix dir and the flag is
                    ;; repeatable), so profile-installed plugins are found.
                    (format port "seen=\"\"~%")
                    (format port "xdg_ifs=$IFS~%")
                    (format port "IFS=:~%")
                    (format port "for d in $XDG_DATA_DIRS; do~%")
                    (format port "  IFS=$xdg_ifs~%")
                    (format port "  [ -d \"$d/waywallen/plugins\" ] || continue~%")
                    (format port "  case \" $seen \" in *\" $d \"*) continue;; esac~%")
                    (format port "  seen=\"$seen $d\"~%")
                    (format port "  set -- \"$@\" --plugin \"$d/waywallen\"~%")
                    (format port "  IFS=:~%")
                    (format port "done~%")
                    (format port "IFS=$xdg_ifs~%")
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
    (native-inputs (list p7zip))
    ;; The AppImage bundles Qt6, ffmpeg and the codec stack; these inputs only
    ;; cover the libraries the bundle expects from the host (the C runtime,
    ;; GL/Vulkan dispatch, Wayland, X11/xcb/xkbcommon, and the font stack).
    ;; freetype is the brotli-enabled variant: the UI's Material Symbols icon
    ;; font is an embedded .woff2 that a plain freetype cannot decode.
    (inputs
     `(("bash-minimal" ,bash-minimal)
       ("glibc" ,glibc)
       ("gcc:lib" ,gcc "lib")
       ("qtsvg" ,qtsvg)
       ("mesa" ,mesa)
       ("libglvnd" ,libglvnd)
       ("vulkan-loader" ,vulkan-loader)
       ("wayland" ,wayland)
       ("libdrm" ,libdrm)
       ("dbus" ,dbus)
       ("fontconfig-minimal" ,fontconfig)
       ("freetype-with-brotli" ,freetype-with-brotli)
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
desktop through a Wayland layer shell and a QtQuick interface.")
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
;; 已迁移到 jeans-binary-build-system：install-plan 逐项落盘 + 目录 patchelf-plan
;;（#:preserve-rpath? #t 保 $ORIGIN 首项）+ renderer chmod 小 phase。
(define-public open-wallpaper-engine-bin
  (package
    (name "open-wallpaper-engine-bin")
    (version "0.3.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/waywallen/open-wallpaper-engine/releases/download/v"
             version
             "/org.waywallen.open-wallpaper-engine-" version
             "-linux-x86_64.zip"))
       (sha256
        (base32 "12bmmqjf7s3xrpph4034r8h769fwiyy4d5lm1qsmczz7mvrkmi9f"))))
    (build-system jeans-binary-build-system)
    (arguments
     (list
      ;; zstd 压缩的 zip（PK 6.3），系统 unzip 读不了，走 bsdtar。
      #:unpack-method 'bsdtar
      #:install-plan
      #~'(("bin" "share/waywallen/plugins/org.waywallen.open-wallpaper-engine/bin")
          ("lib" "share/waywallen/plugins/org.waywallen.open-wallpaper-engine/lib")
          ("wallpaper_engine"
           "share/waywallen/plugins/org.waywallen.open-wallpaper-engine/wallpaper_engine")
          ("i18n" "share/waywallen/plugins/org.waywallen.open-wallpaper-engine/i18n")
          ("main.lua"
           "share/waywallen/plugins/org.waywallen.open-wallpaper-engine/main.lua")
          ("plugin.toml"
           "share/waywallen/plugins/org.waywallen.open-wallpaper-engine/plugin.toml")
          ("files.txt"
           "share/waywallen/plugins/org.waywallen.open-wallpaper-engine/files.txt"))
      ;; 目录条目递归整棵插件树；#:preserve-rpath? #t 保留 $ORIGIN 首项，
      ;; 使 bundled CEF 库互相找到（旧逻辑 $ORIGIN 写死首项）。
      #:preserve-rpath? #t
      #:patchelf-plan
      #~'(("share/waywallen/plugins/org.waywallen.open-wallpaper-engine"))
      #:modules '((jeans build binary)
                  (guix build utils))
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'install 'make-executable
            (lambda _
              (for-each
               (lambda (f) (chmod (string-append #$output "/" f) #o755))
               (list (string-append "share/waywallen/plugins/"
                                    "org.waywallen.open-wallpaper-engine/bin/"
                                    "waywallen-wescene-renderer")
                     (string-append "share/waywallen/plugins/"
                                    "org.waywallen.open-wallpaper-engine/lib/weweb/"
                                    "waywallen-weweb-renderer"))))))))
    (native-inputs (list libarchive))
    ;; The plugin bundles CEF (Chromium) and the scene/web renderer binaries;
    ;; these inputs cover only the libraries those binaries expect from the
    ;; host.  ffmpeg-7 supplies the libav*/libsw* sonames the wescene-renderer
    ;; is linked against (Guix has no ffmpeg 7.x).  libva covers the VA-API
    ;; sonames and pulseaudio libpulse.so.0 (scene audio); without the latter
    ;; the renderer dies with exit 127 before IPC connect.
    (inputs
     `(("glibc" ,glibc)
       ("gcc:lib" ,gcc "lib")
       ("mesa" ,mesa)
       ("vulkan-loader" ,vulkan-loader)
       ("freetype" ,freetype)
       ("fontconfig-minimal" ,fontconfig)
       ("lz4" ,lz4)
       ("ffmpeg-7" ,ffmpeg-7)
       ("libva" ,libva)
       ("pulseaudio" ,pulseaudio)
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
scene/video renderer and the @code{weweb} CEF-backed web renderer.  The host
daemon is provided by the @code{waywallen-bin} package; installing both in the
same Guix profile is enough for Waywallen to discover the plugin.")
    (license license:gpl2)
    (supported-systems '("x86_64-linux"))))

;;; The web renderer of linux-wallpaperengine needs the CEF (Chromium Embedded
;;; Framework) binary distribution.  Upstream's CMakeLists.txt pins the exact
;;; CEF version (CEF_VERSION) and downloads it at configure time; here the
;;; tarball is an extra origin input dropped where DownloadCEF looks for it,
;;; so the download logic itself is left untouched.  Keep %cef-version, the
;;; URL-encoded URI and both hashes in sync when bumping the commit.
(define %cef-version "135.0.17+gcbc1c5b+chromium-135.0.7049.52")

(define cef-binary
  (origin
    (method url-fetch)
    (uri (string-append
          "https://cef-builds.spotifycdn.com/cef_binary_"
          "135.0.17%2Bgcbc1c5b%2Bchromium-135.0.7049.52"
          "_linux64_minimal.tar.bz2"))
    (file-name (string-append "cef_binary_" %cef-version
                              "_linux64_minimal.tar.bz2"))
    (sha256
     (base32 "1ijdxh9pyfabp5nprr1pig6xqw679fyxcdy3lapb3rrbws01kb14"))))

;; Almamu's Wallpaper Engine renderer: an OpenGL reimplementation that plays
;; Steam Wallpaper Engine wallpapers on X11 and Wayland.  Built from a fixed
;; upstream commit (upstream tags are release-branch only and behind main);
;; commit tracking is handled by the Python updater.
(define-public linux-wallpaperengine
  (let ((commit "b016d7d1fdcf4e5fd2f9c9fa420a8aaa07fee02d")
        (revision "0"))
    (package
      (name "linux-wallpaperengine")
      (version (git-version "0.0.1" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/Almamu/linux-wallpaperengine")
               (commit commit)
               (recursive? #t)))        ; glslang, quickjs, nlohmann/json, ...
         (file-name (git-file-name name version))
         (sha256
          (base32 "0lmnbdy7p3gm55imi7ldgs860jsb59k0pzbl9ngygi883w84bdam"))))
      (build-system cmake-build-system)
      (arguments
       (list
        #:tests? #f                   ; Catch2 harness, not wired to CTest
        ;; CEF's cmake picks the binary dir per build type
        ;; (<cef>/RelWithDebInfo/ does not exist in the distribution)
        #:build-type "Release"
        ;; CEF loads its resources from the executable directory, so
        ;; everything is installed flat under lib/<pkg>/ and bin/ only
        ;; exposes a wrapper.
        #:configure-flags
        #~(list "-DENABLE_GLSLANG_BINARIES=OFF" ; tools need Python3, unused
               ;; kissfft's option() clears the normal variables set by the
               ;; parent project (CMP0077 OLD), so disable via the cache;
               ;; its tests would require fftw3.
               "-DKISSFFT_TEST=OFF"
               "-DKISSFFT_TOOLS=OFF"
               ;; Static: upstream only installs the output directory, so a
               ;; shared kissfft would leave unresolved NEEDED entries.
               "-DKISSFFT_STATIC=ON"
               ;; libcef.so resolves its host libraries (glib/nss/cups/...)
               ;; at load time via the RUNPATH this package sets on every
               ;; ELF; the static check at exe link time cannot see them.
               "-DCMAKE_EXE_LINKER_FLAGS=-Wl,--allow-shlib-undefined"
               (string-append "-DCMAKE_INSTALL_PREFIX="
                              #$output "/lib/linux-wallpaperengine"))
        #:phases
        #~(modify-phases %standard-phases
            (add-after 'unpack 'use-system-glfw
              (lambda _
                ;; Upstream links the bare library name "glfw" without a
                ;; find_package call and includes <GLFW/glfw3.h> and
                ;; <glm/*.hpp> as system headers; resolve them explicitly
                ;; for non-/usr prefixes.
                (substitute* "CMakeLists.txt"
                  (("find_package\\(Freetype REQUIRED\\)" line)
                   (string-append
                    line "\nfind_path(GLFW_INCLUDE_DIR GLFW/glfw3.h)"
                    "\nfind_library(GLFW_LIBRARY glfw)"
                    "\nfind_path(GLM_INCLUDE_DIR glm/glm.hpp)"))
                  (("\\$\\{MPV_INCLUDE_DIR\\}" line)
                   (string-append "${GLFW_INCLUDE_DIR}\n    "
                                  "${GLM_INCLUDE_DIR}\n    " line))
                  (("^    glfw$" line)
                   ;; gmp/gmpxx are used via bare system headers too, but
                   ;; unlike glfw are not even listed by upstream — link them
                   ;; or the shared library ships with undefined symbols.
                   "    ${GLFW_LIBRARY}\n    gmpxx\n    gmp"))))
            (add-after 'unpack 'supply-cef-tarball
              (lambda* (#:key inputs #:allow-other-keys)
                ;; DownloadCEF skips the download when the tarball already
                ;; sits in its download dir and just extracts it.  The dir
                ;; is moved to the (writable) source tree because cmake's
                ;; configure phase insists on creating the build directory
                ;; itself.
                (substitute* "CMakeLists.txt"
                  (("\\$\\{CMAKE_CURRENT_BINARY_DIR\\}/cef")
                   "${CMAKE_CURRENT_SOURCE_DIR}/cef")
                  ;; The sandbox helper needs a setuid binary, which cannot
                  ;; work from the store anyway; upstream runs CEF with
                  ;; no_sandbox, so drop it like upstream drops libvulkan
                  ;; (also avoids a spurious copy_if_different failure).
                  (("list\\(REMOVE_ITEM CEF_BINARY_FILES libvulkan.so.1\\)"
                    line)
                   (string-append
                    line "\nlist(REMOVE_ITEM CEF_BINARY_FILES chrome-sandbox)")))
                (mkdir "cef")
                (copy-file (assoc-ref inputs "cef-binary")
                           (string-append "cef/cef_binary_"
                                          #$%cef-version
                                          "_linux64_minimal.tar.bz2"))))
            (add-after 'install 'prune-subproject-artifacts
              (lambda _
                (let ((root (string-append #$output
                                           "/lib/linux-wallpaperengine")))
                  ;; quickjs's test tools and the vendored subprojects' own
                  ;; install rules leak development artifacts into the
                  ;; otherwise flat runtime layout
                  (for-each
                   (lambda (f)
                     (delete-file-recursively (string-append root "/" f)))
                   '("api-test" "run-test262" "function_source" "spirv-cross"
                     "qjs" "qjsc"
                     "bin" "include" "lib" "share")))))
            (add-after 'prune-subproject-artifacts 'patch-cef-elfs
              (lambda* (#:key inputs #:allow-other-keys)
                ;; libcef.so and friends ship without a RUNPATH; point every
                ;; installed ELF at $ORIGIN plus the Guix store libraries so
                ;; both validate-runpath and runtime loading resolve (this
                ;; also covers libcef.so's nss/cups/atk/... host deps).
                (let* ((root (string-append #$output
                                            "/lib/linux-wallpaperengine"))
                       (ld.so (string-append (assoc-ref inputs "glibc")
                                             #$(glibc-dynamic-linker)))
                       (rpath
                        (string-join
                         (cons* "$ORIGIN"
                                ;; Guix's nss keeps its libraries in lib/nss/
                                (string-append
                                 (assoc-ref inputs "nss") "/lib/nss")
                                (map (lambda (input)
                                       (string-append (cdr input) "/lib"))
                                     inputs))
                         ":")))
                  (define (patch-elf file)
                    (unless (string-contains file ".so")
                      (invoke "patchelf" "--set-interpreter" ld.so file))
                    (invoke "patchelf" "--set-rpath" rpath file))
                  (for-each patch-elf
                            (find-files root
                                        (lambda (file stat)
                                          (and (eq? 'regular (stat:type stat))
                                               (elf-file? file))))))))
            (add-after 'patch-cef-elfs 'link-binary
              (lambda _
                (let* ((bin (string-append #$output "/bin"))
                       (real (string-append
                              #$output
                              "/lib/linux-wallpaperengine/linux-wallpaperengine"))
                       (wrapper (string-append bin "/linux-wallpaperengine")))
                  ;; A symlink would make validate-runpath expand $ORIGIN
                  ;; against bin/, where the CEF libraries do not live;
                  ;; exec'ing through a shell wrapper keeps the real binary
                  ;; as /proc/self/exe (which is what CEF spawns, too).
                  (mkdir-p bin)
                  (call-with-output-file wrapper
                    (lambda (port)
                      (display (string-append
                                "#!" #$bash-minimal "/bin/bash\n"
                                "exec \"" real "\" \"$@\"\n")
                               port)))
                  (chmod wrapper #o755)))))))
      (native-inputs (list pkg-config patchelf))
      ;; Build dependencies first, then the host libraries libcef.so needs.
      (inputs
       `(("bash-minimal" ,bash-minimal)
         ("sdl2" ,sdl2)
         ("mpv" ,mpv)
         ("ffmpeg" ,ffmpeg)
         ("pulseaudio" ,pulseaudio)
         ("glew" ,glew)
         ("freeglut" ,freeglut)
         ("glfw" ,glfw)
         ("glm" ,glm)
         ("gmp" ,gmp)
         ("freetype" ,freetype)
         ("zlib" ,zlib)
         ("lz4" ,lz4)
         ("dbus" ,dbus)
         ("mesa" ,mesa)
         ("libx11" ,libx11)
         ("libxrandr" ,libxrandr)
         ("libxxf86vm" ,libxxf86vm)
         ("wayland" ,wayland)
         ("wayland-protocols" ,wayland-protocols)
         ("cef-binary" ,cef-binary)
         ("glibc" ,glibc)
         ("gcc:lib" ,gcc "lib")
         ("glib" ,glib)
         ("at-spi2-core" ,at-spi2-core)
         ("cairo" ,cairo)
         ("pango" ,pango)
         ("nss" ,nss)
         ("nspr" ,nspr)
         ("cups" ,cups)
         ("expat" ,expat)
         ("alsa-lib" ,alsa-lib)
         ("eudev" ,eudev)
         ("libxcb" ,libxcb)
         ("libxkbcommon" ,libxkbcommon)
         ("libxcomposite" ,libxcomposite)
         ("libxdamage" ,libxdamage)
         ("libxext" ,libxext)
         ("libxfixes" ,libxfixes)))
      (properties `((with-latest-git-commit . #t)))
      (home-page "https://github.com/Almamu/linux-wallpaperengine")
      (synopsis "Run Wallpaper Engine wallpapers on the Linux desktop")
      (description
       "Linux Wallpaper Engine is an OpenGL reimplementation of Wallpaper Engine
for Linux.  It renders scene, video and web wallpapers from Steam's Wallpaper
Engine on X11 and Wayland desktops: scenes are drawn through its own GLSLang-
and SPIRV-Cross-based shader translation, videos are decoded by a dedicated
libmpv pipeline, and web wallpapers run inside an embedded Chromium (CEF)
renderer.  Audio playback, fullscreen pausing and audio-triggered visualisers
are supported.

Wallpapers require assets from the official Wallpaper Engine release, which
must be owned and installed through Steam; the assets are auto-detected from
the usual Steam library locations or can be pointed at with
@option{--assets-dir}.  The package is built from source, but the CEF web
renderer relies on the upstream Chromium binary distribution.")
      (license (list license:gpl3 license:bsd-3))
      (supported-systems '("x86_64-linux")))))


;;;
;;; nosDshell: a quickshell-based Wayland desktop shell and its Rust helpers.
;;;

;; The three helper crates and the shell share one git checkout: the
;; tools/ sub-trees evolve with the shell repository, so pinning them
;; separately makes no sense.  Auto-update only maintains the nosdshell
;; version/hash; the helpers follow the shared origin object.
(define %nosdshell-version "1.0.2")
(define %nosdshell-commit "f47127c28247a14ad56989ba926f2500daacdee6")

(define %nosdshell-source
  (origin
    (method git-fetch)
    (uri (git-reference
          (url "https://github.com/ShineBreaker/nosDshell")
          (commit %nosdshell-commit)))
    (file-name (git-file-name "nosdshell" %nosdshell-version))
    (sha256
     (base32
      "1nk1jnx5zbqkbsg98khjfsq4vb22wcq2l5kcfida0nc672mkw9r6"))))

;; Our quickshell fork (ShineBreaker/quickshell-nosd): upstream master at
;; the version 0.3.2 commit plus the two pipewire use-after-free fixes the
;; archived noctalia-qs fork carried and upstream never merged — dangling
;; raw PwNode pointers in the default-device tracker (903a70a) and in the
;; PwNodeIface-bound volume/peak readers (08e6406).  Both crash the shell
;; when a pipewire node (USB audio, headphones) disappears; they are now
;; real commits in the fork rather than patches applied here.
;;
;; Upstream's adjacent destructor-order fixes (36517a2, 91dcb41, 13fe9b0)
;; do not remove the dangling-pointer windows, so both fixes are still
;; needed.  The fork carries no tags; bump it by hand after rebasing onto
;; a new quickshell release.
(define quickshell/nosd
  (package
    (inherit quickshell)
    (name "quickshell-nosd")
    (version "0.3.2")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/ShineBreaker/quickshell-nosd")
             (commit "903a70a9cc7a98834e79db25a8c708acfcffd248")))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "0b2gb4cb9w8x71r7ik0s9sl5jm1smgs3chfd9halcr8pd549820w"))))))

(define-public nosd-blur
  (package
    (name "nosd-blur")
    (version %nosdshell-version)
    (source %nosdshell-source)
    (build-system cargo-build-system)
    (arguments
     (list #:install-source? #f
           ;; The crate lives in tools/nosd-blur inside the shared checkout.
           #:phases #~(modify-phases %standard-phases
                        (add-after 'unpack 'chdir
                          (lambda _ (chdir "tools/nosd-blur"))))))
    (inputs (cargo-inputs 'nosd-blur #:module '(jeans packages rust-crates)))
    (home-page "https://github.com/ShineBreaker/nosDshell")
    (synopsis "Pre-blur wallpapers for nosDshell")
    (description
     "nosd-blur produces a cover-resized, blurred variant of a wallpaper at
exact screen size, so nosDshell surfaces (lock screen, launcher, session
menu) can skip a live blur pass and just draw the cached image.")
    (license license:expat)))

(define-public nosd-helpers
  (package
    (name "nosd-helpers")
    (version %nosdshell-version)
    (source %nosdshell-source)
    (build-system cargo-build-system)
    (arguments
     (list #:install-source? #f
           #:phases #~(modify-phases %standard-phases
                        (add-after 'unpack 'chdir
                          (lambda _ (chdir "tools/nosd-helpers"))))))
    (inputs (cargo-inputs 'nosd-helpers #:module '(jeans packages rust-crates)))
    (home-page "https://github.com/ShineBreaker/nosDshell")
    (synopsis "Small helper tools for nosDshell")
    (description
     "nosd-helpers is the single Rust binary behind nosDshell's helper
subcommands (vscode-themes, kde-apply-scheme, gtk-refresh, khal-events,
bluetooth-pair, eds-check, eds-calendars, eds-events, apply, wl-probe,
vinput).  QML callers require it; the Scripts/python and Scripts/bash
helpers were removed after the ports reached parity.")
    (license license:gpl3+)))

(define-public nosd-theme
  (package
    (name "nosd-theme")
    (version %nosdshell-version)
    (source %nosdshell-source)
    (build-system cargo-build-system)
    (arguments
     (list #:install-source? #f
           #:phases #~(modify-phases %standard-phases
                        (add-after 'unpack 'chdir
                          (lambda _ (chdir "tools/nosd-theme"))))))
    (inputs (cargo-inputs 'nosd-theme #:module '(jeans packages rust-crates)))
    (home-page "https://github.com/ShineBreaker/nosDshell")
    (synopsis "Material theme processor for nosDshell")
    (description
     "nosd-theme is the Rust port of the former nosDshell theming tree:
wallpaper color extraction, Material tonal schemes and Matugen-compatible
template rendering.")
    (license license:gpl3+)))

(define-public nosdshell
  (package
    (name "nosdshell")
    (version %nosdshell-version)
    (source %nosdshell-source)
    (build-system copy-build-system)
    (arguments
     (list
      #:install-plan
      #~'(("." "etc/xdg/quickshell/nosdshell"))
      #:imported-modules
      `((guix build qt-utils)
        ,@%copy-build-system-modules)
      #:modules
      '((srfi srfi-26)
        (guix build copy-build-system)
        (guix build qt-utils)
        (guix build utils))
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'reduce-output-size
            (lambda _
              (delete-file-recursively "Assets/Screenshots")))
          (add-after 'install 'embed-rfkill-path
            (lambda* (#:key inputs #:allow-other-keys)
              ;; rfkill lives in util-linux/sbin, which the wrapper PATH
              ;; does not cover; point the unblock call at the store path.
              (substitute* (string-append
                            #$output
                            "/etc/xdg/quickshell/nosdshell"
                            "/Services/Networking/BluetoothService.qml")
                (("\\[\"rfkill\", \"unblock\", \"bluetooth\"\\]")
                 (string-append "[\"" (search-input-file inputs "sbin/rfkill")
                                "\", \"unblock\", \"bluetooth\"]")))))
          (add-after 'install 'make-wrapper
            (lambda* (#:key inputs #:allow-other-keys)
              (let ((script "nosdshell"))
                (with-output-to-file script
                  (lambda ()
                    (format #t "~
#!~a
exec ~a --config ~a/etc/xdg/quickshell/nosdshell \"$@\"~%"
                            (search-input-file inputs "bin/sh")
                            (search-input-file inputs "bin/quickshell")
                            #$output)))
                (wrap-script script
                  `("PATH"
                    suffix
                    ,(map (compose dirname
                                   (cut search-input-file inputs <>))
                          '("bin/bluetoothctl"
                            "bin/brightnessctl"
                            "bin/cava"
                            "bin/cliphist"
                            "bin/convert"
                            "bin/ddcutil"
                            "bin/dbus-send"
                            "bin/elogind-inhibit"
                            "bin/fastfetch"
                            "bin/fc-list"
                            "bin/find"
                            "bin/getent"
                            "bin/git"
                            "bin/grep"
                            "bin/khal"
                            "bin/ls"
                            "bin/nmcli"
                            "bin/nosd-blur"
                            "bin/nosd-helpers"
                            "bin/nosd-theme"
                            "bin/pgrep"
                            "bin/pkill"
                            "bin/python3"
                            "bin/sh"
                            "bin/which"
                            "bin/wl-paste"
                            "bin/wlsunset"
                            "bin/wtype"))))
                (chmod script #o555)
                (install-file script (in-vicinity #$output "bin")))))
          (add-after 'make-wrapper 'qt-wrap
            (lambda args
              (apply wrap-all-qt-programs
                     #:qtbase #$(this-package-input "qtbase")
                     args))))))
    (inputs
     (list bash-minimal
           bluez
           brightnessctl
           cava
           cliphist
           coreutils-minimal
           ddcutil
           dbus
           elogind
           fastfetch-minimal
           findutils
           fontconfig
           git-minimal
           glibc
           grep
           guile-3.0
           imagemagick
           khal
           network-manager
           nosd-blur
           nosd-helpers
           nosd-theme
           procps
           python-minimal
           qtbase
           qtdeclarative
           qtmultimedia
           qtwayland
           quickshell/nosd
           util-linux
           which
           wl-clipboard
           wlsunset
           wtype))
    (home-page "https://github.com/ShineBreaker/nosDshell")
    (properties `((upstream-name . "nosDshell")
                  (release-tag-prefix . "^v")))
    (synopsis "Wayland desktop shell in the DDE 15 visual language")
    (description
     "nosDshell is a desktop shell for Wayland built on the @code{quickshell}
framework, derived from Noctalia v4.  It renders every part of the shell —
taskbar, launcher, control center, notifications, OSD, lock screen — in the
visual language of deepin 15 (DDE 15).  It supports compositors like
@code{niri}, @code{hyprland}, and @code{sway}.")
    (license license:gpl3+)))

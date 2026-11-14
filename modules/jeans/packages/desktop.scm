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
  #:use-module (gnu packages sqlite)      ; sqlite-next
  #:use-module (gnu packages elf)         ; patchelf
  #:use-module (gnu packages fcitx5)      ; fcitx5
  #:use-module (gnu packages fontutils)   ; fontconfig, freetype
  #:use-module (gnu packages freedesktop) ; wayland, xdg-utils
  #:use-module (gnu packages gcc)         ; gcc:lib
  #:use-module (gnu packages gettext)     ; gettext-minimal
  #:use-module (gnu packages gl)          ; mesa (libgbm), libglvnd
  #:use-module (gnu packages glib)        ; dbus, gobject-introspection
  #:use-module (gnu packages gnome)       ; network-manager
  #:use-module (gnu packages gtk)         ; gtk+, harfbuzz, cairo, pango, at-spi2-core
  #:use-module (gnu packages guile)       ; guile-3.0
  #:use-module (gnu packages hardware)    ; ddcutil
  #:use-module (gnu packages ibus)        ; ibus
  #:use-module (gnu packages image)       ; libheif
  #:use-module (gnu packages imagemagick) ; imagemagick
  #:use-module (gnu packages linux)       ; alsa-lib, eudev
  #:use-module (gnu packages maths)       ; glm
  #:use-module (gnu packages multiprecision) ; gmp
  #:use-module (gnu packages networking)  ; socat
  #:use-module (gnu packages nss)         ; nss, nspr
  #:use-module (gnu packages pdf)         ; poppler
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages pulseaudio)  ; pulseaudio
  #:use-module (gnu packages python)      ; python-minimal
  #:use-module (gnu packages python-build) ; python-setuptools-scm
  #:use-module (gnu packages python-xyz)  ; python-screeninfo, python-platformdirs, python-pillow, ...
  #:use-module (gnu packages qt)          ; qtbase, qtsvg
  #:use-module (gnu packages rust)        ; rust
  #:use-module (gnu packages sdl)         ; sdl2
  #:use-module (gnu packages tcl)         ; expect
  #:use-module (gnu packages video)       ; ffmpeg, mpv
  #:use-module (gnu packages version-control) ; git-minimal
  #:use-module (gnu packages vulkan)      ; vulkan-loader
  #:use-module (gnu packages webkit)      ; webkitgtk-for-gtk3
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
;; 已迁移到 binary-build-system（纯参数迁移，等价 RPATH）。
(define-public ai-usagebar-bin
  (package
    (name "ai-usagebar-bin")
    (version "1.52.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/akitaonrails/ai-usagebar/releases/download/"
             "v" version "/ai-usagebar-linux-x86_64.tar.gz"))
       (sha256
        (base32 "07zihs1ynz43pzx0j6x9isg90svnd4aimjs2ayh9c36f27p14qch"))))
    (build-system binary-build-system)
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

;;; ai-usagebar (source build): same upstream as ai-usagebar-bin.  Single
;;; crate, three [[bin]] targets; ai-usagebar-tray is a stub on Linux (the
;;; WebView popover build in build.rs only runs on Windows/macOS), so all
;;; three install without extra inputs.  The test suite contains live
;;; network e2e tests (anthropic_e2e, live, public_api), hence #:tests? #f.

(define-public ai-usagebar
  (package
    (name "ai-usagebar")
    (version "1.52.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/akitaonrails/ai-usagebar")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0sfrnllnviq0vvzqh4nm967ry1hxdifsb941dsmgc0ak1n1xyzj0"))))
    (build-system cargo-build-system)
    (arguments
     (list #:install-source? #f
           #:tests? #f))
    ;; rusqlite 链接系统 sqlite3（-lsqlite3），非 bundled feature。
    ;; 用 sqlite-next（3.53）而非 sqlite（3.39）：rusqlite 0.39 引用
    ;; sqlite3_set_clientdata，该 API 自 SQLite 3.44 才引入。
    (inputs (cons sqlite-next
                  (cargo-inputs 'ai-usagebar #:module '(jeans packages rust-crates))))
    (home-page "https://github.com/akitaonrails/ai-usagebar")
    (synopsis "Waybar widget for AI coding assistant usage")
    (description "AI UsageBar is a Rust waybar widget that monitors plans and
credits of AI coding assistants: Claude, Codex, GLM, Kimi, Grok, Cursor,
OpenRouter and more.  It reads each vendor's local credential or state files,
queries usage endpoints where needed, and renders a compact bar text with
percentage, reset timer and tooltip for the waybar panel.  It ships both the
@command{ai-usagebar} CLI (JSON output for custom widgets) and an interactive
@command{ai-usagebar-tui}.")
    (license license:expat)))


;; Satty 上游（Satty-org/Satty，MPL-2.0）在 GitHub Releases 发布 x86_64 与
;; aarch64 预编译 tarball。本通道分发 x86_64 预编译产物、不从源码构建，故加
;; -bin（对应的源码包 satty 另行定义）。主二进制为动态 PIE ELF，走标准
;; GTK4 + libadwaita 栈：NEEDED 覆盖 gtk/libadwaita/pango/gdk-pixbuf/
;; glib(gio、gobject)/fontconfig/gcc:lib/glibc，patchelf 设 interpreter 与
;; RUNPATH。GTK GUI 运行时需要 gsettings schema 与 hicolor 图标，wrapper 以
;; prefix 语义补 GSETTINGS_SCHEMA_DIR 与 XDG_DATA_DIRS（保留系统原值）。
;; tarball 自带的 bin / desktop / 图标 / man / shell completions 一律按上游
;; 原名安装，-bin 记号只留在 Guix 包名与 share/doc 命名空间。
;; 版本锁定 0.20.1：上游自 0.21 起改用带 glibc 2.43 的构建环境，其预编译
;; 二进制的 GLIBC_2.43 verneed 超过 Guix 的 glibc 2.41，运行即报
;; "version GLIBC_2.43 not found"，patchelf/wrapper 均无法修复；0.20.1 最高
;; 只需 GLIBC_2.39，可正常运行。故 pin 0.20.1 并排除自动更新（否则 CI 升到
;; 0.21+ 会再撞墙）；0.20.1 的 tarball 不含 man page。
;; 资产文件名 satty-x86_64-unknown-linux-gnu.tar.gz 不含版本号，tag 为
;; v0.20.1，upstream-name 取资产前缀 "satty"。
(define-public satty-bin
  (package
    (name "satty-bin")
    (version "0.20.1")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/Satty-org/Satty/releases/download/"
             "v" version "/satty-x86_64-unknown-linux-gnu.tar.gz"))
       (sha256
        (base32 "14k06i8pkpkmybb4p9j3f234vzmvij70jadjxjq6p436q0xmlnpa"))))
    (build-system binary-build-system)
    (arguments
     (list
      #:unpack-method 'tar
      #:install-plan
      #~'(("satty" "bin/satty")
          ("satty.desktop" "share/applications/satty.desktop")
          ("assets/satty.svg"
           "share/icons/hicolor/scalable/apps/satty.svg")
          ("completions/satty.bash"
           "share/bash-completion/completions/satty")
          ("completions/_satty" "share/zsh/site-functions/_satty")
          ("completions/satty.fish"
           "share/fish/vendor_completions.d/satty.fish")
          ("completions/satty.elv" "share/elvish/lib/satty.elv")
          ("completions/satty.nu"
           "share/nushell/vendor/autoload/satty.nu"))
      #:patchelf-plan
      #~'(("bin/satty"))
      #:desktop-files
      #~'(("share/applications/satty.desktop" "bin/satty" "satty"))
      ;; 上游 tarball 是散装根且带 assets/、completions/、man/ 等子目录，
      ;; gnu-unpack 的 first-subdirectory 会误 chdir 进首个小子目录，令
      ;; install-plan 的相对 SRC 落空；改为原地 tar 解压、不切换目录。
      #:phases
      #~(modify-phases %standard-phases
           (replace 'unpack
             (lambda* (#:key source #:allow-other-keys)
               (invoke "tar" "xvf" source))))
      #:wrap-plan
      #~(list
         (list "bin/satty"
               (list "GSETTINGS_SCHEMA_DIR" ":" 'prefix
                     (list (string-append #$gtk
                                          "/share/glib-2.0/schemas")
                           (string-append #$libadwaita
                                          "/share/glib-2.0/schemas")))
               (list "XDG_DATA_DIRS" ":" 'prefix
                     (list (string-append #$output "/share")))))))
    (inputs
     `(("gtk" ,gtk)
       ("libadwaita" ,libadwaita)
       ("pango" ,pango)
       ("gdk-pixbuf" ,gdk-pixbuf)
       ("glib" ,glib)
       ("fontconfig-minimal" ,fontconfig)
       ("gcc:lib" ,gcc "lib")
       ("glibc" ,glibc)))
    (properties `((upstream-name . "satty")))
    (home-page "https://github.com/Satty-org/Satty")
    (synopsis "Modern screenshot annotation tool")
    (description
     "Satty is a modern screenshot annotation tool for Wayland and X11.  It
reads an image from a file or standard input, lets you annotate it with
arrows, text, shapes, numbered markers, highlights and blur, then copies the
result to the clipboard or saves it to a file.  This package provides the
prebuilt upstream binary release.")
    (license license:mpl2.0)
    (supported-systems '("x86_64-linux"))))


;;; satty (source build): same upstream as satty-bin, built from the git tree
;;; at 0.22.0.  Building from source lifts the binary package's 0.20.1 pin —
;;; upstream's 0.21+ prebuilt ELFs carry a GLIBC_2.43 verneed that exceeds
;;; Guix's glibc 2.41, whereas the source build links Guix's own glibc and
;;; runs on current releases.
;;;
;;; Cargo workspace: root `satty` (GTK4/relm4 GUI) plus the path member `cli`
;;; (satty_cli, a library); edition 2024.  build.rs is pure-Rust codegen (clap
;;; shell completions, a man page and the relm4-icons bundle).  With the
;;; upstream `ci-release` feature it writes completions/ and man/satty.1 into
;;; the source root, which install-assets then installs exactly as the
;;; upstream Makefile does.  #:install-source? #f also skips `cargo package`,
;;; which a path-member workspace cannot run cleanly.
;;;
;;; The -sys crates probe system libraries through pkg-config: gtk4/gdk4/gsk4
;;; (gtk), libadwaita, pango, gdk-pixbuf, glib/gio/gobject, cairo, graphene,
;;; fontconfig (yeslogic-fontconfig-sys) and libepoxy (epoxy).  OpenGL is
;;; dlopened at runtime by glow/femtovg; libglvnd supplies the libGL/libEGL
;;; dispatch so no system GL is required.  The wrapper mirrors satty-bin:
;;; GSETTINGS_SCHEMA_DIR (gtk + libadwaita) and XDG_DATA_DIRS (output/share),
;;; both with prefix semantics so the system values survive.

(define-public satty
  (package
    (name "satty")
    (version "0.22.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/Satty-org/Satty")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "05j3vdvdwwdmzf0ky52kliy7di0klkj4jdbbn4v8qyjaa1k7i8pg"))))
    (build-system cargo-build-system)
    (arguments
     (list #:install-source? #f
           #:tests? #f
           #:features ''("ci-release")
           ;; workspace：cargo-build-system 的 has-executable-target? 取
           ;; cargo metadata 的 packages[0]，这里是 lib 成员 satty_cli（无
           ;; bin），会误判无二进制目标而跳过 cargo install。显式指定
           ;; 安装根包 "."，装出 bin/satty。
           #:cargo-install-paths ''(".")
           #:phases
           #~(modify-phases %standard-phases
               (add-after 'install 'install-assets
                 (lambda* (#:key outputs #:allow-other-keys)
                   (let* ((out (assoc-ref outputs "out"))
                          (share (string-append out "/share"))
                          (install-to
                           (lambda (src dest)
                             (mkdir-p (dirname dest))
                             (copy-file src dest))))
                     (install-to "satty.desktop"
                                 (string-append share "/applications/satty.desktop"))
                     (install-to "assets/satty.svg"
                                 (string-append
                                  share "/icons/hicolor/scalable/apps/satty.svg"))
                     (install-to "completions/satty.bash"
                                 (string-append
                                  share "/bash-completion/completions/satty"))
                     (install-to "completions/_satty"
                                 (string-append share "/zsh/site-functions/_satty"))
                     (install-to "completions/satty.fish"
                                 (string-append
                                  share "/fish/vendor_completions.d/satty.fish"))
                     (install-to "completions/satty.elv"
                                 (string-append share "/elvish/lib/satty.elv"))
                     (install-to "completions/satty.nu"
                                 (string-append
                                  share "/nushell/vendor/autoload/satty.nu"))
                     (install-to "completions/satty.ts"
                                 (string-append share "/fig/autocomplete/satty.ts"))
                     (install-to "man/satty.1"
                                 (string-append share "/man/man1/satty.1")))))
               (add-after 'install-assets 'wrap
                 (lambda* (#:key inputs outputs #:allow-other-keys)
                   (let* ((out (assoc-ref outputs "out"))
                          (gtk (assoc-ref inputs "gtk"))
                          (libadwaita (assoc-ref inputs "libadwaita")))
                     (wrap-program (string-append out "/bin/satty")
                       `("GSETTINGS_SCHEMA_DIR" ":" prefix
                         (,(string-append gtk "/share/glib-2.0/schemas")
                          ,(string-append libadwaita "/share/glib-2.0/schemas")))
                       `("XDG_DATA_DIRS" ":" prefix
                         (,(string-append out "/share"))))))))))
    (native-inputs (list pkg-config))
    (inputs
     (append (list bash-minimal
                   gtk
                   libadwaita
                   pango
                   gdk-pixbuf
                   glib
                   cairo
                   graphene
                   fontconfig
                   libepoxy
                   libglvnd)
             (cargo-inputs 'satty #:module '(jeans packages rust-crates))))
    (home-page "https://github.com/Satty-org/Satty")
    (synopsis "Modern screenshot annotation tool")
    (description
     "Satty is a modern screenshot annotation tool for Wayland and X11.  It
reads an image from a file or standard input, lets you annotate it with
arrows, text, shapes, numbered markers, highlights and blur, then copies the
result to the clipboard or saves it to a file.  This package builds Satty
from source.")
    (license license:mpl2.0)))


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
;; 已迁移到 binary-build-system：解包/install/patchelf 走参数（目录条目），
;; 手写 Qt wrapper 与 desktop 入口保留自定义 phase。
(define-public waywallen-bin
  (package
    (name "waywallen-bin")
    (version "0.6.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/waywallen/waywallen/releases/download/v"
             version
             "/waywallen-" version "-x86_64.AppImage"))
       (sha256
        (base32 "1zaindd2bq4qchl79yn6pnl1amf77n1k9pxakrln46dbf731jzni"))))
    (build-system binary-build-system)
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
;; 已迁移到 binary-build-system：install-plan 逐项落盘 + 目录 patchelf-plan
;;（#:preserve-rpath? #t 保 $ORIGIN 首项）+ renderer chmod 小 phase。
(define-public open-wallpaper-engine-bin
  (package
    (name "open-wallpaper-engine-bin")
    (version "0.3.3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/waywallen/open-wallpaper-engine/releases/download/v"
             version
             "/org.waywallen.open-wallpaper-engine-" version
             "-linux-x86_64.zip"))
       (sha256
        (base32 "1qrhrnhggkpwjccrlawnbn26ggryciw6wxg9rramammhxgsyci09"))))
    (build-system binary-build-system)
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
           "share/waywallen/plugins/org.waywallen.open-wallpaper-engine/files.txt")
          ;; [plugin.probe] entry = "probe.lua" for scene types. files.txt
          ;; lists it; omitting it makes the plugin fail the file check.
          ("probe.lua"
           "share/waywallen/plugins/org.waywallen.open-wallpaper-engine/probe.lua"))
      ;; 目录条目递归整棵插件树；#:preserve-rpath? #t 保留 $ORIGIN 首项，
      ;; 使 bundled CEF 库互相找到（旧逻辑 $ORIGIN 写死首项）。
      #:preserve-rpath? #t
      #:patchelf-plan
      ;; SPEC 显式指向 waywallen-bin 的嵌套 lib 目录：0.3.1 起 renderer
      ;; NEEDED 宿主 daemon 提供的 libwaywallen-bridge.so，该库在
      ;; waywallen-bin 的 lib/waywallen/lib/ 下（非顶层 /lib，
      ;; auto-lib-dirs 收集不到）。
      #~'(("share/waywallen/plugins/org.waywallen.open-wallpaper-engine"
           ("waywallen-bin" "/lib/waywallen/lib")
           ;; Guix 的 nss 把库装在 lib/nss/ 子目录而非顶层 /lib，
           ;; 0.3.2 起 bundled libcef.so 新增传递依赖 libnss3.so，
           ;; auto-lib-dirs 收不到，必须显式补。
           ("nss" "/lib/nss")))
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
    ;; the renderer dies with exit 127 before IPC connect.  waywallen-bin
    ;; supplies libwaywallen-bridge.so (0.3.1+: the renderers link the host
    ;; daemon's bridge ABI; the plugin zip no longer bundles it).
    (inputs
     `(("glibc" ,glibc)
       ("waywallen-bin" ,waywallen-bin)
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
  (let ((commit "a0ddce586e9ff12e9d31ca6b103f6036cc1b68fe")
        (revision "2"))
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
          (base32 "0l9nr8si0ry5968p7la7ffkkjj9062am45fb4hs12v160cagcwsr"))))
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
;;
;; The source is pinned to the release tag (vX.Y.Z), not to a raw commit:
;; %nosdshell-version is the only version value, and the git-reference
;; commit is derived from it, so the updater only bumps the version and
;; the hash.  Guix refresh does not manage this package (see the CI
;; workflow): the shared-variable layout leaves it no literal version or
;; hash inside the package form to rewrite.
(define %nosdshell-version "1.7.6.1")

(define %nosdshell-source
  (origin
    (method git-fetch)
    (uri (git-reference
          (url "https://github.com/nosDshell/nosDshell")
          (commit (string-append "v" %nosdshell-version))))
    (file-name (git-file-name "nosdshell" %nosdshell-version))
    (sha256
     (base32 "0zm6658sg2wzc6mxdd7xlajj3vcfi9pnscvh1n95gfz7qyhrnvdy"))))

;; Our quickshell fork (nosDshell/quickshell-nosd): upstream master
;; kept linear on top of the version 0.3.2 commit by a daily CI sync
;; (baseline cherry-pick; the baseline sits in .github/upstream-sync-base).
;; Beyond upstream it carries:
;;
;;   - the two pipewire use-after-free fixes the archived noctalia-qs
;;     fork carried and upstream never merged — dangling raw PwNode
;;     pointers in the default-device tracker (903a70a, plus b0a8a7f
;;     making it compile on Qt 6.6) and in the PwNodeIface-bound
;;     volume/peak readers (08e6406).  Both crash the shell when a
;;     pipewire node (USB audio, headphones) disappears.
;;   - PR_SET_PDEATHSIG for managed child processes (5ff26dc): the
;;     long-lived helpers (wl-paste watchers, niri event-stream, nmcli
;;     monitor, udevadm monitor) must not outlive the shell.
;;   - allocator bounds for a long-lived shell (92a7978): mallopt caps
;;     glibc arenas and pins mmap/trim thresholds at startup, and a
;;     QTimer calls malloc_trim every five minutes.  Explicit MALLOC_*
;;     environment (nosdshell's wrapper sets the same values) wins.
;;
;; The fork carries no tags; bump it by hand together with the commit
;; hash in the wrapper's --version line below.
(define quickshell/nosd
  (package
    (inherit quickshell)
    (name "quickshell-nosd")
    (version "0.3.2")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/nosDshell/quickshell-nosd")
             (commit "472047177d881d0e89c16576601087cd19bff9c9")))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "0p1jrly6y1i64w7cjygm8rcv6880w07d0dxiq3k0qxyli0yp0j36"))))
    ;; The keyring prompter builds the org.gnome.keyring.SystemPrompter side
    ;; of oo7's unlock flow on libgcr's GcrSystemPrompter (gcr 4).
    (inputs
     (modify-inputs (package-inputs quickshell)
       (prepend gcr)))))

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
    (home-page "https://github.com/nosDshell/nosDshell")
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
           #:phases
           #~(modify-phases %standard-phases
               (add-after 'unpack 'chdir
                 (lambda _ (chdir "tools/nosd-helpers")))
               ;; `portal run` is a darkman-compatible portal Settings
               ;; backend; shipping the activatable name plus the portal
               ;; descriptor makes `Settings=nosdshell` work out of the box
               ;; for any consumer that installs this package.
               (add-after 'install 'install-portal-files
                 (lambda _
                   (let ((services (in-vicinity
                                    #$output "share/dbus-1/services"))
                         (portals (in-vicinity
                                   #$output
                                   "share/xdg-desktop-portal/portals"))
                         (dbus-name
                          "org.freedesktop.impl.portal.desktop.nosdshell"))
                     (mkdir-p services)
                     (call-with-output-file
                         (in-vicinity services
                                      (string-append dbus-name ".service"))
                       (lambda (p)
                         (format p "[D-BUS Service]~%\
Name=org.freedesktop.impl.portal.desktop.nosdshell~%\
Exec=~a/bin/nosd-helpers portal run~%"
                                 #$output)))
                     (mkdir-p portals)
                     (call-with-output-file
                         (in-vicinity portals "nosdshell.portal")
                       (lambda (p)
                         (format p "[portal]~%\
DBusName=org.freedesktop.impl.portal.desktop.nosdshell~%\
Interfaces=org.freedesktop.impl.portal.Settings~%\
UseIn=niri;sway;Hyprland;labwc;scroll;mangowc;~%")))))))))
    (inputs (cargo-inputs 'nosd-helpers #:module '(jeans packages rust-crates)))
    (home-page "https://github.com/nosDshell/nosDshell")
    (synopsis "Small helper tools for nosDshell")
    (description
     "nosd-helpers is the single Rust binary behind nosDshell's helper
subcommands (vscode-themes, kde-apply-scheme, gtk-refresh, khal-events,
bluetooth-pair, eds-check, eds-calendars, eds-events, apply, wl-probe,
vinput, portal).  QML callers require it; the Scripts/python and
Scripts/bash helpers were removed after the ports reached parity.  The
portal subcommand additionally ships a darkman-compatible
xdg-desktop-portal Settings backend.")
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
    (home-page "https://github.com/nosDshell/nosDshell")
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
          (add-after 'install 'install-completions
            (lambda* (#:key source #:allow-other-keys)
              ;; completions/ holds one file per shell; install each under its
              ;; standard name so profiles pick it up automatically.
              (let ((share (string-append #$output "/share")))
                (mkdir-p (string-append share "/bash-completion/completions"))
                (mkdir-p (string-append share "/zsh/site-functions"))
                (mkdir-p (string-append share "/fish/vendor_completions.d"))
                (copy-file (string-append source "/completions/nosdshell.bash")
                           (string-append share "/bash-completion/completions/nosdshell"))
                (copy-file (string-append source "/completions/_nosdshell")
                           (string-append share "/zsh/site-functions/_nosdshell"))
                (copy-file
                 (string-append source "/completions/nosdshell.fish")
                 (string-append share "/fish/vendor_completions.d"
                                "/nosdshell.fish")))))
          (add-after 'install 'make-wrapper
            (lambda* (#:key inputs #:allow-other-keys)
              ;; Write the wrapper straight into the output: the checkout
              ;; root holds a nosdshell/ directory (channel module path),
              ;; so a same-named scratch file here no longer works.
              (let ((script (in-vicinity #$output "bin/nosdshell")))
                (mkdir-p (dirname script))
                ;; --version/-V prints the shell and quickshell versions without
                ;; starting the shell (lowercase -v is quickshell's verbose flag
                ;; and must fall through).  The nosdshell part follows
                ;; %nosdshell-version; keep the quickshell part in sync with
                ;; quickshell/nosd above.  The MALLOC block mirrors the wrapper
                ;; nosDshell's own nosdshell.scm generates — the fork binary
                ;; mallopts the same defaults in-process, so the env vars are
                ;; the user-facing override path (glibc reads them at startup,
                ;; hence before exec).
                (with-output-to-file script
                  (lambda ()
                    (format #t "~
#!~a
if [ \"$1\" = \"--version\" ] || [ \"$1\" = \"-V\" ]; then
  echo \"nosdshell v~a (with quickshell v0.3.2 4720471)\"
  exit 0
fi
: \"${MALLOC_ARENA_MAX:=4}\"
: \"${MALLOC_MMAP_THRESHOLD_:=131072}\"
: \"${MALLOC_TRIM_THRESHOLD_:=131072}\"
export MALLOC_ARENA_MAX MALLOC_MMAP_THRESHOLD_ MALLOC_TRIM_THRESHOLD_
exec ~a --config ~a/etc/xdg/quickshell/nosdshell \"$@\"~%"
                            (search-input-file inputs "bin/sh")
                            #$%nosdshell-version
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
                (chmod script #o555))))
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
    (home-page "https://github.com/nosDshell/nosDshell")
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

;; MSIME（水杉输入法）的 Linux 桌面发布物：IBus 宿主与 Fcitx5 插件是两条并列的
;; 系统入口，链接同一份 libmsime_host_api。
;;
;; 安装布局刻意保持上游的 /usr 前缀形状：Linux 宿主按自身可执行文件路径推导
;; install_prefix，再取 <prefix>/share/msime-client；装进 $out/bin 后该推导自然
;; 落在 $out/share/msime-client。上游给 bin/ 下的 ELF 写的是
;; $ORIGIN/../lib/x86_64-linux-gnu/msime-client，fcitx5 插件写的是
;; $ORIGIN/../msime-client，与 $out 布局重合，故 preserve-rpath? 保留相对段，
;; 只附加 Guix 库路径。
;;
;; 发行版前缀写死在 IBus 组件 XML、Fcitx5 addon 的 Library=、desktop 条目里，
;; 装完统一改写为 $out 绝对路径。
;;
;; 上游用 systemd 用户单元托管三个常驻 provider（online.socket/.service、
;; voice.socket/.service、clipboard.service），其中 online 与 voice 由 socket
;; 激活。Guix 没有 systemd，这些单元文件装进去永远不会被消费，所以不安装；
;; 同等能力由 jeans home services 的 home-msime-service-type 起成用户 Shepherd
;; 服务（见 modules/jeans/home/services/desktop.scm）。没有该服务时，上游
;; msime-linux-setup 会提示用 msime-linux-provider-session online|voice 手动启动。
;;
;; 主词库（msime-pinyin.db、msime-wubi.db 等，合计约 320 MiB）不在发布物内，
;; 由 msime-linux-setup 在用户首次配置时下载。
(define-public msime-bin
  (package
    (name "msime-bin")
    (version "0.16.1")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/metasequoiaime/msime/releases/download/"
             "linux-v" version "/msime-linux-" version
             "-linux-x86_64.tar.gz"))
       (sha256
        (base32 "0ki12ax0vnyvh5q2sb2pw2jlvvr5xsic701310k6iirlwwjr3mhb"))))
    (build-system binary-build-system)
    (arguments
     (list
      #:unpack-method 'tar
      #:install-plan
      #~'(("usr/bin/" "bin/")
          ("usr/lib/x86_64-linux-gnu/" "lib/x86_64-linux-gnu/")
          ;; 逐目录安装而不是整棵 usr/share，是为了排除上游的 systemd 用户单元
          ;; （usr/share/systemd）与 systemctl 驱动的 autostart 条目
          ;; （etc/xdg/autostart）；两者在 Guix 下都没有消费者。
          ("usr/share/applications/" "share/applications/")
          ("usr/share/doc/" "share/doc/")
          ("usr/share/fcitx5/" "share/fcitx5/")
          ("usr/share/ibus/" "share/ibus/")
          ("usr/share/icons/" "share/icons/")
          ("usr/share/msime-client/" "share/msime-client/"))
      #:patchelf-plan
      #~'(("bin")
          ("lib/x86_64-linux-gnu"))
      #:preserve-rpath? #t
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'install 'rewrite-absolute-paths
            (lambda* (#:key outputs #:allow-other-keys)
              (let ((out (assoc-ref outputs "out")))
                ;; IBus 组件的 exec 必须指向 store 内的启动器。
                (substitute* (string-append
                              out "/share/ibus/component/msime-linux.xml")
                  (("/usr/bin/") (string-append out "/bin/"))
                  (("/etc/msime-client/")
                   (string-append out "/etc/msime-client/")))
                ;; Fcitx5 按 addon.conf 的 Library= 绝对路径加载插件。
                (substitute* (string-append out "/share/fcitx5/addon/msime.conf")
                  (("Library=/usr/lib/x86_64-linux-gnu/fcitx5/")
                   (string-append "Library=" out
                                  "/lib/x86_64-linux-gnu/fcitx5/")))
                (substitute* (string-append
                              out "/share/applications/msime-linux.desktop")
                  (("/usr/bin/") (string-append out "/bin/")))
                ;; 两个启动脚本里的系统级配置回退路径。
                (for-each (lambda (script)
                            (substitute* script
                              (("/etc/msime-client/")
                               (string-append out "/etc/msime-client/"))))
                          (list (string-append out "/bin/msime-linux-settings")
                                (string-append
                                 out "/bin/msime-linux-ibus-launcher")))))))))
    (inputs
     `(("glibc" ,glibc)
       ("gcc:lib" ,gcc "lib")
       ("alsa-lib" ,alsa-lib)
       ("gtk+" ,gtk+)
       ("gtk" ,gtk)
       ("gdk-pixbuf" ,gdk-pixbuf)
       ("cairo" ,cairo)
       ("pango" ,pango)
       ("glib" ,glib)
       ("dbus" ,dbus)
       ("webkitgtk-for-gtk3" ,webkitgtk-for-gtk3)
       ("libsoup" ,libsoup)
       ("ibus" ,ibus)
       ("fcitx5" ,fcitx5)
       ("libxkbcommon" ,libxkbcommon)
       ("wayland" ,wayland)
       ("libx11" ,libx11)
       ("libxext" ,libxext)
       ("libxfixes" ,libxfixes)
       ("libxrandr" ,libxrandr)
       ("python" ,python)))
    (properties `((upstream-name . "msime")
                  (release-tag-prefix . "^linux-v")))
    (home-page "https://github.com/metasequoiaime/msime")
    (synopsis "Chinese input method with IBus and Fcitx5 engines")
    (description
     "MSIME (Metasequoia IME) is a Chinese input method for Android, iOS,
macOS, Linux, Windows and HarmonyOS built on one shared input engine.  This
package provides the prebuilt Linux desktop release: the IBus engine host,
the Fcitx5 addon and the Tauri settings application, plus the bundled offline
dictionaries, sound packs and the online/voice provider services.

The main typing dictionaries (@file{msime-pinyin.db}, @file{msime-wubi.db}
and the bigram model, about 320 MiB in total) are not part of the release;
the first-run page downloads them into the user data directory.  The optional
online, voice and clipboard providers are not started by the package: enable
them with the @code{home-msime-service-type} Guix Home service, or run
@command{msime-linux-provider-session online} (or @code{voice}) by hand.  This
package provides the prebuilt upstream Linux release.")
    (license license:gpl3)
    (supported-systems '("x86_64-linux"))))

;;; flea (prebuilt release): the 0.4.2 window is a GPUI application, so the
;;; binary pair is Rust throughout and links no Qt; the QML tree is still
;;; shipped as data, but FLEA_FRONTEND=qml is refused at startup.  The
;;; binaries look their data up as FLEA_UI, FLEA_SHELF, FLEA_I18N,
;;; FLEA_UDISKS first (paths.rs, shelfplugin.rs, i18n/mod.rs,
;;; backend/flashhelper.rs) and fall back to /usr/share/flea or
;;; /usr/lib/flea, hence the wrapper.  libexec/flea holds five helper
;;; programs started by D-Bus or by flea itself; the two D-Bus service files
;;; carry absolute Exec paths and are patched below, together with the
;;; /usr/bin/flea fallback in the two Python portal helpers.  Omarchy is
;;; optional: the shelf plugin, its bar widget and the omarchy-* commands are
;;; only touched when the shelf is enabled in Settings.

(define-public flea-bin
  (package
    (name "flea-bin")
    (version "0.4.3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/thisisgm/flea/releases/download/v" version
             "/flea-v" version "-linux-x86_64.tar.gz"))
       (sha256
        (base32 "0jpd6jrm0754r7kldnn75p0wha93adwhyzwzaj32s4mlvk6plhlq"))))
    (build-system binary-build-system)
    (arguments
     (let ((python-version
            (version-major+minor (package-version python))))
       (list
        #:unpack-method 'tar
        #:install-plan
        ;; 'tar 解包后 gnu-unpack-source 已 chdir 进唯一顶层目录。
        #~'(("flea" "bin/flea")
            ("flea-gui" "bin/flea-gui")
            ("tools/" "libexec/flea/")
            ("ui/" "share/flea/ui/")
            ("shelf/" "share/flea/shelf/")
            ("i18n/" "share/flea/i18n/")
            ("packaging/com.thisisgm.flea.desktop"
             "share/applications/com.thisisgm.flea.desktop")
            ("packaging/com.thisisgm.flea.svg"
             "share/icons/hicolor/scalable/apps/com.thisisgm.flea.svg")
            ("packaging/flea.portal"
             "share/xdg-desktop-portal/portals/flea.portal")
            ("packaging/org.freedesktop.impl.portal.desktop.flea.service"
             "share/dbus-1/services/org.freedesktop.impl.portal.desktop.flea.service")
            ("packaging/com.thisisgm.flea.FileManager1.service"
             "share/dbus-1/services/com.thisisgm.flea.FileManager1.service")
            ("LICENSE" "share/doc/flea-bin/LICENSE")
            ("THIRD-PARTY-LICENSES.txt"
             "share/doc/flea-bin/THIRD-PARTY-LICENSES.txt"))
        #:patchelf-plan
        #~'(("bin/flea") ("bin/flea-gui"))
        #:wrap-plan
        #~(let ((python-path (list (string-append #$python "/lib/python"
                                                  #$python-version
                                                  "/site-packages")
                                   (string-append #$python-pygobject
                                                  "/lib/python" #$python-version
                                                  "/site-packages")))
                (typelib (list (string-append #$glib
                                              "/lib/girepository-1.0"))))
            (list
             (list "bin/flea"
                   (list "FLEA_UI" "=" '=
                         (list (string-append #$output "/share/flea/ui")))
                   (list "FLEA_SHELF" "=" '=
                         (list (string-append #$output "/share/flea/shelf")))
                   (list "FLEA_UDISKS" "=" '=
                         (list (string-append #$output "/libexec/flea/flea-udisks"))))
             (list "bin/flea-gui"
                   (list "FLEA_UI" "=" '=
                         (list (string-append #$output "/share/flea/ui"))))
             (list "libexec/flea/flea-portal"
                   (list "PYTHONPATH" ":" 'prefix python-path)
                   (list "GI_TYPELIB_PATH" ":" 'prefix typelib))
             (list "libexec/flea/flea-filemanager1"
                   (list "PYTHONPATH" ":" 'prefix python-path)
                   (list "GI_TYPELIB_PATH" ":" 'prefix typelib))
             (list "libexec/flea/flea-mpris"
                   (list "PYTHONPATH" ":" 'prefix python-path)
                   (list "GI_TYPELIB_PATH" ":" 'prefix typelib))
             (list "libexec/flea/flea-udisks"
                   (list "PYTHONPATH" ":" 'prefix python-path)
                   (list "GI_TYPELIB_PATH" ":" 'prefix typelib))))
        #:desktop-files
        #~(list (list "share/applications/com.thisisgm.flea.desktop"
                      (string-append #$output "/bin/flea")
                      "com.thisisgm.flea"))
        #:phases
        #~(modify-phases %standard-phases
            (add-after 'unpack 'patch-absolute-paths
              (lambda* (#:key outputs #:allow-other-keys)
                (let* ((out (assoc-ref outputs "out"))
                       (flea (string-append out "/bin/flea")))
                  (substitute*
                      '("packaging/org.freedesktop.impl.portal.desktop.flea.service")
                    (("/usr/lib/flea/flea-portal")
                     (string-append out "/libexec/flea/flea-portal")))
                  (substitute*
                      '("packaging/com.thisisgm.flea.FileManager1.service")
                    (("/usr/lib/flea/flea-filemanager1")
                     (string-append out "/libexec/flea/flea-filemanager1")))
                  ;; Both D-Bus helpers open windows by exec'ing the CLI name.
                  (substitute* '("tools/flea-portal" "tools/flea-filemanager1")
                    (("/usr/bin/flea") flea)))))))))
    (inputs
     `(("bash-minimal" ,bash-minimal)
       ("expect" ,expect)
       ("fontconfig-minimal" ,fontconfig)
       ("gcc:lib" ,gcc "lib")
       ("gdk-pixbuf" ,gdk-pixbuf)
       ("glib" ,glib)
       ("glibc" ,glibc)
       ("libglvnd" ,libglvnd)
       ("libheif" ,libheif)
       ("libxcb" ,libxcb)
       ("libxkbcommon" ,libxkbcommon)
       ("mpv" ,mpv)
       ("poppler" ,poppler)
       ("python" ,python)
       ("python-pygobject" ,python-pygobject)
       ("vulkan-loader" ,vulkan-loader)
       ("wayland" ,wayland)))
    ;; Release assets are flea-v<ver>-linux-x86_64.tar.gz; upstream-name is
    ;; the filename prefix before the version, tags use v*.
    (properties `((upstream-name . "flea")))
    (home-page "https://github.com/thisisgm/flea")
    (synopsis "Fast, keyboard-first file manager")
    (description
     "Flea is a keyboard-first graphical file manager: columns, tabs, a
searchable path bar, previews for images, media, PDF, Markdown and archives,
a trash browser and a drop shelf.  This package provides the prebuilt
upstream Linux release, which has two entry points: @command{flea} for the
CLI and the window, and @command{flea-gui} for the window alone.

The file-manager window is a GPU-rendered native application and does not
require a desktop shell.  Optional integrations look for their host programs
on @env{PATH}: media and PDF previews use @command{mpv} and Poppler's GObject
library, HTML previews call @command{qml6}, content search uses
@command{ripgrep}, archive work uses @command{7z}, and the Omarchy shelf
plugin runs the @command{omarchy-*} commands only when it is enabled in
Settings.  The two D-Bus services (@code{org.freedesktop.impl.portal.desktop.flea}
and @code{org.freedesktop.FileManager1}) are installed under
@file{share/dbus-1/services}; they need @code{python-pygobject} and the Python
GI typelibs supplied by this package.  This package provides the prebuilt
upstream Linux release.")
    (license license:expat)
    (supported-systems '("x86_64-linux"))))

;;; gpui-omarchy is the Omarchy fork of gpui that flea pins in its workspace
;;; dependencies.  It is a virtual workspace (crates/gpui-pre and 15 siblings
;;; with path dependencies between them), so the crates cannot be vendored
;;; individually: the whole checkout is an input and the two git declarations
;;; in flea's Cargo.toml become path dependencies, the helix-steel pattern.
(define flea-gpui-omarchy
  (origin
    (method git-fetch)
    (uri (git-reference
          (url "https://github.com/thisisgm/gpui-omarchy")
          (commit "c1643efcf27498cb516c0831fd15f66ff9b1c811")))
    (file-name (git-file-name "gpui-omarchy" "0.3.9"))
    (sha256 (base32 "0bkf093sqbn9rvjc1b5lhm310v6qw1805aycvr8n0d6zmmxgfdml"))))

;;; flea (source build): the same upstream release tree as flea-bin, built
;;; with cargo-build-system from the tarball upstream's CI publishes (it
;;; carries the i18n catalogs and ui/ tree, which are data, not build
;;; inputs).  Two crates produce binaries: the workspace root (flea) and
;;; crates/flea-gui, hence both cargo install paths.  The 616 vendored
;;; crates come from `guix import crate --lockfile`; gpui-omarchy is the
;;; only git dependency and is rewritten to its checkout in patch-gpui.
;;; tests? is #f: the suite needs bubblewrap namespaces, ffmpegthumbnailer,
;;; glycin and 40 GiB of free space, none of which a sandboxed build has.
;;; The data install phase mirrors upstream's Makefile, with lib/flea
;;; replaced by libexec/flea and the absolute /usr paths patched.
(define-public flea
  (package
    (name "flea")
    (version "0.4.2")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/thisisgm/flea/releases/download/v" version
             "/flea-v" version ".tar.gz"))
       (sha256
        (base32 "0hxqhl4p4kkb20f7x5gndz0mcj1gcizb3sf6j17zpyhjhgr9zsz4"))))
    (build-system cargo-build-system)
    (arguments
     (let ((python-version (version-major+minor (package-version python))))
       (list
        #:rust rust
        #:install-source? #f
        #:tests? #f
        #:cargo-install-paths ''("." "crates/flea-gui")
        #:phases
        #~(modify-phases %standard-phases
            (add-after 'unpack 'patch-gpui-git-dependency
              (lambda* (#:key inputs #:allow-other-keys)
                (let* ((gpui (assoc-ref inputs
                                        "gpui-omarchy-0.3.9-checkout"))
                       (gpui-git
                        (string-append
                         "gpui = \\{ package = \"gpui-pre\", git = \"[^\"]+\","
                         " rev = \"[0-9a-f]+\" \\}"))
                       (platform-git
                        (string-append
                         "gpui_platform = \\{ package = \"gpui-pre-platform\","
                         " git = \"[^\"]+\", rev = \"[0-9a-f]+\","
                         " features = \\[\"font-kit\", \"x11\", \"wayland\","
                         " \"runtime_shaders\"\\] \\}"))
                       (gpui-path (string-append
                                   "gpui = { package = \"gpui-pre\", path = \""
                                   gpui "/crates/gpui-pre\" }"))
                       (platform-path
                        (string-append
                         "gpui_platform = { package = \"gpui-pre-platform\","
                         " path = \"" gpui "/crates/gpui-pre-platform\","
                         " features = [\"font-kit\", \"x11\", \"wayland\","
                         " \"runtime_shaders\"] }")))
                  (substitute* "Cargo.toml"
                    ((gpui-git) gpui-path)
                    ((platform-git) platform-path)))))
            (add-after 'patch-gpui-git-dependency 'patch-absolute-paths
              (lambda* (#:key inputs outputs #:allow-other-keys)
                (let* ((out (assoc-ref outputs "out"))
                       (flea (string-append out "/bin/flea"))
                       (libexec (string-append out "/libexec/flea")))
                  ;; The two D-Bus helpers are activated by absolute Exec path.
                  (substitute*
                      '("packaging/org.freedesktop.impl.portal.desktop.flea.service")
                    (("/usr/lib/flea/flea-portal")
                     (string-append libexec "/flea-portal")))
                  (substitute*
                      '("packaging/com.thisisgm.flea.FileManager1.service")
                    (("/usr/lib/flea/flea-filemanager1")
                     (string-append libexec "/flea-filemanager1")))
                  ;; Both D-Bus helpers open windows by exec'ing the CLI name.
                  (substitute* '("tools/flea-portal" "tools/flea-filemanager1")
                    (("/usr/bin/flea") flea))
                  ;; These are not under bin/ or libexec/, so the standard
                  ;; patch-shebangs phase never visits them.
                  (substitute* '("tools/flea-portal" "tools/flea-filemanager1"
                                 "tools/flea-mpris" "tools/flea-udisks")
                    (("#!/usr/bin/python3")
                     (string-append "#!" #$(this-package-input "python") "/bin/python3")))
                  (substitute* "tools/flea-gio-auth"
                    (("#!/usr/bin/expect -f")
                     (string-append "#!" #$(this-package-input "expect")
                                    "/bin/expect -f"))))))
            (add-after 'install 'install-data
              (lambda* (#:key outputs #:allow-other-keys)
                (let* ((out (assoc-ref outputs "out"))
                       (share (string-append out "/share/flea"))
                       (libexec (string-append out "/libexec/flea")))
                  ;; The QML tree is data the binary resolves through FLEA_UI;
                  ;; 0.4.2 still ships it even though the GPUI window is the
                  ;; only frontend.
                  (copy-recursively "ui" (string-append share "/ui"))
                  (copy-recursively "shelf" (string-append share "/shelf"))
                  (for-each
                   (lambda (file)
                     (let* ((rel (substring file (string-length "i18n/")))
                            (lang (dirname rel)))
                       (install-file file (string-append share "/i18n/" lang))))
                   (find-files "i18n" "^flea\\.json$"))
                  (for-each
                   (lambda (file)
                     (install-file file libexec))
                   (find-files
                    "tools"
                    "^flea-(portal|filemanager1|mpris|udisks|gio-auth)$"))
                  (install-file "packaging/com.thisisgm.flea.desktop"
                                (string-append out "/share/applications"))
                  (install-file "packaging/com.thisisgm.flea.svg"
                                (string-append
                                 out "/share/icons/hicolor/scalable/apps"))
                  (install-file "packaging/flea.portal"
                                (string-append out "/share/xdg-desktop-portal/portals"))
                  (install-file
                   "packaging/org.freedesktop.impl.portal.desktop.flea.service"
                   (string-append out "/share/dbus-1/services"))
                  (install-file "packaging/com.thisisgm.flea.FileManager1.service"
                                (string-append out "/share/dbus-1/services"))
                  (install-file "LICENSE"
                                (string-append out "/share/doc/flea"))
                  (install-file "THIRD-PARTY-LICENSES.txt"
                                (string-append out "/share/doc/flea"))
                  ;; Exec must be absolute in a store profile.
                  (substitute* (string-append out "/share/applications/"
                                              "com.thisisgm.flea.desktop")
                    (("^Exec=flea ")
                     (string-append "Exec=" out "/bin/flea "))))))
            (add-after 'install-data 'add-gui-runpath
              (lambda* (#:key inputs outputs #:allow-other-keys)
                ;; rustc embeds only the -L paths its build scripts report;
                ;; gdk-pixbuf and glib are linked through LIBRARY_PATH and
                ;; never enter the RUNPATH, so validate-runpath fails.  This
                ;; is the documented cargo-build-system gap for dlopened or
                ;; indirectly linked system libraries.
                (use-modules (ice-9 popen) (ice-9 rdelim))
                (let* ((out (assoc-ref outputs "out"))
                       (bin (string-append out "/bin/flea-gui"))
                       (gdk (assoc-ref inputs "gdk-pixbuf"))
                       (glib (assoc-ref inputs "glib"))
                       (pipe (open-pipe* OPEN_READ "patchelf" "--print-rpath" bin))
                       (rpath (read-line pipe)))
                  (close-pipe pipe)
                  (invoke "patchelf" "--set-rpath"
                          (string-append rpath ":" gdk "/lib:" glib "/lib")
                          bin))))
            (add-after 'add-gui-runpath 'wrap-programs
              (lambda* (#:key outputs #:allow-other-keys)
                (let* ((out (assoc-ref outputs "out"))
                       (python-path
                        (list (string-append #$python "/lib/python"
                                             #$python-version "/site-packages")
                              (string-append #$python-pygobject
                                             "/lib/python" #$python-version
                                             "/site-packages")))
                       (typelib (list (string-append #$glib
                                                     "/lib/girepository-1.0"))))
                  (for-each
                   (lambda (prog)
                     (wrap-program (string-append out prog)
                       `("PYTHONPATH" ":" prefix ,python-path)
                       `("GI_TYPELIB_PATH" ":" prefix ,typelib)))
                   '("/libexec/flea/flea-portal"
                     "/libexec/flea/flea-filemanager1"
                     "/libexec/flea/flea-mpris"
                     "/libexec/flea/flea-udisks"))
                  (for-each
                   (lambda (prog)
                     (wrap-program (string-append out prog)
                       (list "FLEA_UI" "=" '=
                             (list (string-append out "/share/flea/ui")))
                       (list "FLEA_SHELF" "=" '=
                             (list (string-append out "/share/flea/shelf")))
                       (list "FLEA_UDISKS" "=" '=
                             (list (string-append out
                                                  "/libexec/flea/flea-udisks")))))
                   '("/bin/flea" "/bin/flea-gui")))))))))
    (native-inputs (list pkg-config patchelf))
    (inputs
     (cons* flea-gpui-omarchy
            bash-minimal
            expect
            fontconfig
            freetype
            gdk-pixbuf
            glib
            libglvnd
            libxcb
            libxkbcommon
            python
            python-pygobject
            vulkan-loader
            wayland
            zlib
            (cargo-inputs 'flea #:module '(jeans packages rust-crates))))
    (properties `((upstream-name . "flea")))
    (home-page "https://github.com/thisisgm/flea")
    (synopsis "Fast, keyboard-first file manager")
    (description
     "Flea is a keyboard-first graphical file manager: columns, tabs, a
searchable path bar, previews for images, media, PDF, Markdown and archives,
a trash browser and a drop shelf.  This package builds both entry points from
source: @command{flea} for the CLI and the window, and @command{flea-gui} for
the window alone.

The file-manager window is a GPU-rendered native application and does not
require a desktop shell.  Optional integrations look for their host programs
on @env{PATH}: media and PDF previews use @command{mpv} and Poppler's GObject
library, HTML previews call @command{qml6}, content search uses
@command{ripgrep}, archive work uses @command{7z}, and the Omarchy shelf
plugin runs the @command{omarchy-*} commands only when it is enabled in
Settings.  The two D-Bus services (@code{org.freedesktop.impl.portal.desktop.flea}
and @code{org.freedesktop.FileManager1}) are installed under
@file{share/dbus-1/services} and run the Python GI helpers shipped here.")
    (license license:expat)
    (supported-systems '("x86_64-linux"))))

;;; oo7 --- freedesktop Secret Service 的服务端实现（org.freedesktop.secrets）。
;;;
;;; 上游是 cargo workspace：server（oo7-daemon + 登录 helper）、cli、portal、
;;; git-credential、cargo-credential、kwallet 读取工具，另有 pyo3 绑定
;;; （python/）不从本包构建。上游的 meson 只负责安装 data 与编译 po，这里
;;; 改用 cargo-build-system 的 workspace 支持：build 阶段只构建要安装的
;;; 成员，install 阶段手工摆放 libexec/、lib/security/ 与 share/ 下的描述
;;; 文件。
;;;
;;; 两处偏离上游原样的适配：
;;;  - pam_oo7.so 用 option_env!("OO7_DAEMON_LOGIN_PATH") 在编译期嵌入
;;;    login helper 的绝对路径（上游默认 /usr/libexec/oo7-daemon-login），
;;;    所以 build-pam 阶段先把它指向本包的 libexec，否则 PAM 会话解锁会去
;;;    调一个不存在的路径。
;;;  - 上游 portal 的 D-Bus 激活文件写作 Exec=/bin/false + SystemdService，
;;;    只在 systemd 管 D-Bus 激活时成立；Guix 不用 systemd，改写成直接执行
;;;    libexec 里的 portal。daemon 的 systemd unit 同理不安装。
(define-public oo7
  (package
    (name "oo7")
    (version "0.7.1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/linux-credentials/oo7")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "01m6pyjpslnjm8bj5qacdgc0rb15qfampx22kckl76papl58q2cv"))))
    (build-system cargo-build-system)
    (arguments
     (list
      #:install-source? #f
      ;; 上游测试要连会话 D-Bus 总线、起临时 keyring，Guix 构建环境里没有。
      #:tests? #f
      #:cargo-install-paths
      ''("cli" "server" "portal" "git-credential" "cargo-credential"
         "kwallet/cli")
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'build 'build-pam
            (lambda* (#:key outputs #:allow-other-keys)
              (setenv "OO7_DAEMON_LOGIN_PATH"
                      (string-append (assoc-ref outputs "out")
                                     "/libexec/oo7-daemon-login"))
              (invoke "cargo" "build" "--offline" "--release" "-p" "oo7-pam")))
          (replace 'install
            (lambda* (#:key outputs #:allow-other-keys)
              (let* ((out (assoc-ref outputs "out"))
                     (bin (string-append out "/bin"))
                     (libexec (string-append out "/libexec"))
                     (security (string-append out "/lib/security"))
                     (share (string-append out "/share"))
                     (target "target/release")
                     (install-from
                      (lambda (file dir)
                        (install-file (string-append target "/" file) dir))))
                (for-each (lambda (file) (install-from file bin))
                          '("oo7-cli" "git-credential-oo7"
                            "cargo-credential-oo7" "kwallet-cli"))
                (for-each (lambda (file) (install-from file libexec))
                          '("oo7-daemon" "oo7-daemon-login"
                            "oo7-portal"))
                ;; PAM 按 pam_<service>.so 的名字查找模块。
                (mkdir-p security)
                (copy-file (string-append target "/libpam_oo7.so")
                           (string-append security "/pam_oo7.so"))
                ;; portal 的 .portal 描述与 .desktop 启动器带 meson 变量。
                (let ((portals (string-append share "/xdg-desktop-portal/portals"))
                      (apps (string-append share "/applications")))
                  (mkdir-p portals)
                  (mkdir-p apps)
                  (copy-file "portal/data/oo7-portal.portal.in"
                             (string-append portals "/oo7-portal.portal"))
                  (substitute* (string-append portals "/oo7-portal.portal")
                    (("@dbus_name@") "org.freedesktop.impl.portal.desktop.oo7"))
                  (copy-file "portal/data/oo7-portal.desktop.in"
                             (string-append apps "/oo7-portal.desktop"))
                  (substitute*
                      (string-append apps "/oo7-portal.desktop")
                    (("@libexecdir@/@bin_name@")
                     (string-append libexec "/oo7-portal"))))
                ;; D-Bus 激活描述文件：portal 与 daemon 各一个。
                (let ((services (string-append share "/dbus-1/services")))
                  (mkdir-p services)
                  (call-with-output-file
                      (string-append services
                                     "/org.freedesktop.impl.portal.desktop.oo7.service")
                    (lambda (port)
                      (format port "[D-BUS Service]~%Name=~a~%Exec=~a~%"
                              "org.freedesktop.impl.portal.desktop.oo7"
                              (string-append libexec "/oo7-portal"))))
                  (call-with-output-file
                      (string-append services "/org.freedesktop.secrets.service")
                    (lambda (port)
                      (format port "[D-BUS Service]~%Name=~a~%Exec=~a~%"
                              "org.freedesktop.secrets"
                              (string-append libexec "/oo7-daemon")))))
                ;; daemon 的 gettext domain 是 oo7-daemon（上游 meson 的
                ;; i18n.gettext 用项目名）。
                (for-each
                 (lambda (po)
                   (let* ((lang (basename po ".po"))
                          (dir (string-append share "/locale/" lang
                                              "/LC_MESSAGES")))
                     (mkdir-p dir)
                     (invoke "msgfmt" "-o"
                             (string-append dir "/oo7-daemon.mo") po)))
                 (find-files "server/po" "\\.po$"))))))))
    (native-inputs (list gettext-minimal))
    ;; pam 的 build.rs 无条件声明 rustc-link-lib=pam，需要 Linux-PAM 的头
    ;; 与 libpam.so。
    (inputs
     (cons linux-pam
           (cargo-inputs 'oo7 #:module '(jeans packages rust-crates))))
    (properties `((upstream-name . "oo7")))
    (home-page "https://github.com/linux-credentials/oo7")
    (synopsis "Freedesktop Secret Service implementation")
    (description
     "oo7 implements the @code{org.freedesktop.secrets} D-Bus API and the
@code{org.freedesktop.impl.portal.Secret} portal backend, and replaces the
@command{secret-tool} command line with @command{oo7-cli}.

The package installs the daemon (@command{oo7-daemon}) and its login helper
under @file{libexec}, the PAM module as @file{lib/security/pam_oo7.so}, the
portal backend, and D-Bus activation files for both services.  The PAM module
receives the login password and hands it to the daemon so the login keyring
can be unlocked without prompting; systems without systemd should start the
daemon from their service manager and add @code{pam_oo7.so} to the PAM stack.

The @command{git-credential-oo7} and
@command{cargo-credential-oo7} helpers are installed for Git and Cargo
registry authentication.")
    (license license:expat)
    (supported-systems '("x86_64-linux"))))

;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-only

;;; AI agent packages: prebuilt coding-agent binaries (CLI and desktop)
;;; and AI-powered editors, consolidated from tools.scm and desktop.scm.

(define-module (jeans packages agent)
  #:export (disable-electron-updater-phase
            prefer-electron-wayland-phase
            prefer-electron-wayland-hint-phase)
  #:use-module (gnu packages)
  #:use-module (gnu packages audio)        ; alsa-lib
  #:use-module (gnu packages backup)       ; libarchive
  #:use-module (gnu packages base)         ; glibc, binutils, coreutils, tar, sed
  #:use-module (gnu packages bash)         ; bash-minimal
  #:use-module (gnu packages bootstrap)    ; glibc-dynamic-linker
  #:use-module (gnu packages compression)  ; xz, gzip
  #:use-module (gnu packages cups)         ; cups
  #:use-module (gnu packages elf)          ; patchelf
  #:use-module (gnu packages fontutils)    ; fontconfig
  #:use-module (gnu packages freedesktop)  ; libappindicator
  #:use-module (gnu packages gcc)          ; gcc "lib"
  #:use-module (gnu packages gl)           ; mesa
  #:use-module (gnu packages glib)         ; glib, dbus
  #:use-module (gnu packages gnome)        ; libsoup, gnome-keyring, libsecret
  #:use-module (gnu packages golang)       ; go
  #:use-module (gnu packages gtk)          ; gtk+, cairo, gdk-pixbuf, at-spi2-core
  #:use-module (gnu packages image)        ; libjpeg-turbo, libpng
  #:use-module (gnu packages linux)        ; eudev
  #:use-module (gnu packages nss)          ; nss, nss-certs
  #:use-module (gnu packages ncurses)
  #:use-module (gnu packages node)         ; node
  #:use-module (gnu packages pulseaudio)   ; pulseaudio
  #:use-module (gnu packages rust-apps)    ; ripgrep
  #:use-module (gnu packages tls)          ; openssl
  #:use-module (gnu packages version-control) ; git
  #:use-module (gnu packages vulkan)       ; vulkan-loader
  #:use-module (gnu packages web)          ; json-c
  #:use-module (gnu packages webkit)       ; webkitgtk-for-gtk3
  #:use-module (gnu packages xdisorg)      ; libxkbcommon
  #:use-module (gnu packages xml)          ; expat
  #:use-module (gnu packages xorg)         ; libx11, libxcb, libxcomposite, ...
  #:use-module (guix build-system copy)    ; opencode-bin
  #:use-module (guix build-system gnu)     ; the rest
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (jeans build-system binary)
  #:use-module (jeans build-system electron)
  #:use-module ((guix licenses)
                #:prefix license:)
  #:use-module ((nonguix licenses)
                #:prefix license:))

;;; NOTE: 三个 Electron phase helper 已有新家 (jeans build electron)
;;; （builder 侧直调 procedure，shell 负载与此处逐行同形，staging 由 gexp
;;; 工厂改为 #:key 直读）。此处三处 define 暂时保留，供未迁移包向后兼容；
;;; 新包请用 electron-build-system，不再各写各的。

(define (disable-electron-updater-phase application-directory)
  #~(lambda _
      ;; electron-updater treats "package-type" as permission to replace the
      ;; application with a downloaded .deb.  Guix owns package upgrades.
      (let ((package-type
             (string-append #$output "/lib/" #$application-directory
                            "/resources/package-type")))
        (when (file-exists? package-type)
          (delete-file package-type)))))

(define (prefer-electron-wayland-phase program)
  #~(lambda _
      (let ((wrapper (string-append #$output "/bin/" #$program)))
        (substitute* wrapper
          (("^exec -a ")
           (string-append
            "case \"${ELECTRON_OZONE_PLATFORM_HINT:-auto}\" in\n"
            "  auto|wayland)\n"
            "    if [ -n \"${WAYLAND_DISPLAY:-}\" ]; then\n"
            "      set -- --ozone-platform=wayland "
            "--enable-features=UseOzonePlatform,WaylandWindowDecorations "
            "\"$@\"\n"
            "    fi\n"
            "    ;;\n"
            "esac\n"
            "exec -a "))))))

;; Variant for Electron apps whose own argv parser rejects Chromium's
;; --ozone-platform flags (Paseo): prefer Wayland by exporting Electron's
;; native ELECTRON_OZONE_PLATFORM_HINT instead of injecting flags.  Only
;; applied when the user has not chosen a platform themselves.
(define (prefer-electron-wayland-hint-phase program)
  #~(lambda _
      (let ((wrapper (string-append #$output "/bin/" #$program)))
        (substitute* wrapper
          (("^exec -a ")
           (string-append
            "if [ -z \"${ELECTRON_OZONE_PLATFORM_HINT:-}\" ] "
            "&& [ -n \"${WAYLAND_DISPLAY:-}\" ]; then\n"
            "  export ELECTRON_OZONE_PLATFORM_HINT=wayland\n"
            "fi\n"
            "exec -a "))))))

;;; CodeWhale: multi-provider AI coding agent for the terminal (Rust).
;;;
;;; The upstream tar.gz ships two statically-linked (static-pie) Rust
;;; ELF binaries with no interpreter and no NEEDED entries:
;;;   - codewhale      ; the entrypoint launcher (also serves as the TUI)
;;;   - codew          ; short alias of codewhale
;;;
;;; Upstream dropped the separate codewhale-tui binary in v0.9.5; the
;;; installer only refreshes a legacy codewhale-tui if one already exists.
;;; Being fully static, no patchelf or ld-linux wrapper is needed — just
;;; unpack the archive, restore the executable bit (the tarball stores the
;;; binaries as 0644) and install both into bin/.

(define-public codewhale-bin
  (package
    (name "codewhale-bin")
    (version "0.10.2")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/Hmbown/CodeWhale/releases/download/"
             "v" version "/codewhale-linux-x64.tar.gz"))
       (sha256
        (base32 "1nbh1x8h501r26j7rmvjg7lw6lsmglgc025q5f99qm25v1qn8rpd"))))
    (build-system binary-build-system)
    (arguments
     (list
      #:unpack-method 'tar
      #:install-plan
      #~'(("codewhale" "bin/codewhale")
          ("codew" "bin/codew"))
      ;; Fully static: no patchelf.  The archive stores the binaries as
      ;; 0644, so restore the executable bit before install.
      #:patchelf? #f
      #:phases
      #~(modify-phases %standard-phases
          (add-before 'install 'fix-permissions
            (lambda _
              (for-each (lambda (b) (chmod b #o755))
                        '("codewhale" "codew")))))))
    (properties `((upstream-name . "codewhale")))
    (home-page "https://codewhale.net")
    (synopsis "Multi-provider AI coding agent for the terminal")
    (description
     "CodeWhale is a coding agent for the terminal that works with any model.
It reads code, edits files, runs commands, checks the results, and keeps going
until a task is done or it needs you.  It ships a TUI for interactive work and
@code{codewhale exec} for scripts and CI, supports 30+ providers (DeepSeek,
Claude, GPT, Kimi, GLM, OpenRouter, vLLM, Ollama, ...) through one runtime,
runs durable multi-worker fleets, and gates risk with OS sandboxing,
per-tool-call hooks and side-git snapshots.  Written in Rust, MIT-licensed,
and runs entirely on your machine.  This package provides the prebuilt binary
release.")
    (license license:expat)
    (supported-systems '("x86_64-linux"))))

;;; Cindy: open-source AI agent desktop client (Electron, Apache-2.0).
;;;
;;; The upstream .deb (data.tar.zst, unlike the xz used by opencode/paseo)
;;; installs an Electron bundle under /usr/lib/cindy:
;;;   - Cindy                 the Electron main executable (GUI entry)
;;;   - chrome-sandbox        setuid sandbox helper; installed but not
;;;                           setuid-root (namespace sandbox suffices)
;;;   - resources/app.asar.unpacked/node_modules/...  native addons
;;;     (better-sqlite3, node-pty, sharp) in nested directories; sharp
;;;     carries its own $ORIGIN-relative RPATH pointing at the bundled
;;;     libvips, so patchelf must --prepend-rpath (existing RPATH kept)
;;;     rather than --set-rpath.
;;;   - resources/tools/ripgrep/rg   statically linked, shipped as-is.
;;;   - resources/tools/remote-desktop/cindy-linux-desktop-{capture,
;;;     clipboard,input}  Wayland 远程桌面 sidecar，NEEDED
;;;     libwayland-client/libturbojpeg/libpng——对应 wayland、
;;;     libjpeg-turbo、libpng 三个 input，升级时重查。
;;;
;;; @img/ 子树（sharp 的预编译 libvips 与 .node）自包含：$ORIGIN RPATH
;;; 已自足，patchelf-exclude 原样保留。libvips-cpp.so 的 .init 紧贴
;;; ELF 头（vaddr 0x25c），patchelf 扩 phdr 将其移位后不更新 DT_INIT，
;;; patch 即变砖（ld.so 调旧址段错误，0.1.103 实证）。
;;;
;;; Sidecars proxy.mjs / cc-mgr.mjs are "#!/usr/bin/env node" scripts;
;;; Electron spawns them via ELECTRON_RUN_AS_NODE, so no Node.js input.
;;; electron-updater: no resources/package-type file in this bundle, so
;;; the disable-electron-updater phase is unnecessary.

(define-public cindy-cn-bin
  (package
    (name "cindy-cn-bin")
    (version "0.1.136")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/makecindy/cindy/releases/download/"
             "v" version "/cindy-" version "-linux-x64-cn.deb"))
       (sha256
        (base32 "0qqwv82v0pz7z20i4d90abl2gjmzhprqql1nc154b6zny5hzbi20"))))
    (build-system electron-build-system)
    (arguments
     (list
      #:program "cindy"
      #:app-dir "lib/cindy"
      #:application-directory "cindy"
      ;; safeStorage 凭据持久化需要会话 secrets 服务：inputs 能定位到 gdbus /
      ;; gnome-keyring-daemon / gcr-prompter（即含 glib:bin / gnome-keyring /
      ;; gcr-3 三个输入）便自动启用 build/electron.scm 的
      ;; ensure-secret-service-phase（探测在位就不动，缺服务才兜底拉
      ;; gnome-keyring；用户显式 --password-store 永远最优先）。
      #:unpack-method 'deb-zst
      #:install-plan
      #~'(("usr/lib/cindy" "lib/cindy")
          ("usr/share/applications/cindy.desktop"
           "share/applications/cindy.desktop")
          ("usr/share/pixmaps/cindy.png"
           "share/pixmaps/cindy.png"))
      ;; sharp's .node addons carry $ORIGIN-relative RPATH resolving the
      ;; bundled libvips: prepend instead of replacing.
      #:preserve-rpath? #t
      ;; @img/：$ORIGIN RPATH 自足，patch 反而触发 DT_INIT 失步 bug（见包
      ;; 上方注释）。
      #:patchelf-exclude
      #~'("lib/cindy/resources/app.asar.unpacked/node_modules/@img/")
      #:desktop-files
      #~'(("share/applications/cindy.desktop"
           "bin/cindy"
           "share/pixmaps/cindy.png"))
      #:modules '((guix build utils))
      #:phases
      #~(modify-phases (@ (jeans build electron) %standard-phases)
          (add-after 'patchelf 'install-bin
            (lambda _
              (let* ((out #$output)
                     (bin (string-append out "/bin"))
                     (exe (string-append out "/lib/cindy/Cindy")))
                (mkdir-p bin)
                (symlink exe (string-append bin "/cindy"))))))))
    (native-inputs (list binutils tar xz zstd))
    (inputs `(("alsa-lib" ,alsa-lib)
              ("at-spi2-core" ,at-spi2-core)
              ("bash-minimal" ,bash-minimal)
              ("nss-certs" ,nss-certs)
              ("cairo" ,cairo)
              ("cups" ,cups)
              ("dbus" ,dbus)
              ("eudev" ,eudev)
              ("expat" ,expat)
              ("fontconfig-minimal" ,fontconfig)
              ("gcc:lib" ,gcc "lib")
              ("gcr-3" ,gcr-3)
              ("glibc" ,glibc)
              ("glib" ,glib)
              ("glib:bin" ,glib "bin")
              ("gnome-keyring" ,gnome-keyring)
              ("gtk+" ,gtk+)
              ("json-c" ,json-c)
              ("libx11" ,libx11)
              ("libxcb" ,libxcb)
              ("libxcomposite" ,libxcomposite)
              ("libxdamage" ,libxdamage)
              ("libxext" ,libxext)
              ("libxfixes" ,libxfixes)
              ("libjpeg-turbo" ,libjpeg-turbo)
              ("libpng" ,libpng)
              ("libsecret" ,libsecret)
              ("libxkbcommon" ,libxkbcommon)
              ("libxrandr" ,libxrandr)
              ("mesa" ,mesa)
              ("nspr" ,nspr)
              ("nss" ,nss)
              ("pango" ,pango)
              ("wayland" ,wayland)))
    (properties `((upstream-name . "cindy")
                  (release-tag-prefix . "^v")))
    (home-page "https://github.com/makecindy/cindy")
    (synopsis "Open-source AI agent desktop client")
    (description
     "Cindy is an open-source AI agent desktop client that works out of the
box.  It provides task orchestration with multiple AI models, remote device
control, and a companion system.")
    (license license:asl2.0)
    (supported-systems '("x86_64-linux"))))

;;; GitHub Copilot app: agent-native desktop client (Tauri + WebKitGTK).
;;;
;;; The upstream .deb bundles a 668 MB Tauri ELF (`github') plus a small
;;; `git-credential-copilot' helper, resources under usr/lib/GitHub Copilot/
;;; (onnxruntime .so, pulse audio plugin, copilot-sdk JS, terminal
;;; integration scripts, icons, sounds), and a .desktop entry + hicolor
;;; icons.  The data.tar is zstd-compressed, hence libarchive (bsdtar) is
;;; used for unpacking.
;;;
;;; Do not patchelf the giant binary: launch it via the Guix ld-linux
;;; wrapper with a --library-path assembled from every input's /lib.
;;; libsoup, javascriptcore and the rest come transitively from
;;; webkitgtk-for-gtk3.

;;; 跳过迁移：Tauri 包。resource_dir/sidecar 按 exe_dir 基准解析，基座通用
;;; install-plan 会打散布局；且主程序走手写 ld-linux wrapper（非 wrap-program），
;;; 基座表达不了，保留现状。
(define-public github-copilot
  (package
    (name "github-copilot")
    (version "1.4.1")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/github/app/releases/download/"
             "v" version "/GitHub-Copilot-linux-x64.deb"))
       (sha256
        (base32 "0g3v555808pf3nvccjp19qpqjnni5ni306rlcbjdb2hbznz3my2s"))))
    (build-system gnu-build-system)
    (arguments
     (list
      #:tests? #f
      #:validate-runpath? #f
      #:strip-binaries? #f
      #:modules '((guix build gnu-build-system)
                  (guix build utils))
      #:phases
      #~(modify-phases %standard-phases
          (delete 'configure)
          (delete 'build)
          (replace 'unpack
            (lambda _
              (invoke "bsdtar" "xf" #$source)
              (invoke "bsdtar" "xf" "data.tar.zst")))
          (replace 'install
            (lambda* (#:key inputs #:allow-other-keys)
              (let* ((out #$output)
                     (libexec (string-append out "/libexec/github-copilot"))
                     (bin (string-append out "/bin"))
                     ;; ld-linux dynamic loader from glibc.
                     (ld.so (string-append (assoc-ref inputs "glibc")
                                           #$(glibc-dynamic-linker)))
                     ;; Flat library-path of every input's /lib.
                     (lib-path (string-join
                                (map (lambda (input)
                                       (string-append (cdr input) "/lib"))
                                     inputs)
                                ":"))
                     (glib-lib (string-append (assoc-ref inputs "glib") "/lib"))
                     (gtk-lib (string-append (assoc-ref inputs "gtk+") "/lib"))
                     (gtk-share (string-append (assoc-ref inputs "gtk+") "/share"))
                     (webkitgtk-lib (string-append
                                     (assoc-ref inputs "webkitgtk-for-gtk3")
                                     "/lib"))
                     (webkitgtk-share (string-append
                                       (assoc-ref inputs "webkitgtk-for-gtk3")
                                       "/share"))
                     (gdk-pixbuf (assoc-ref inputs "gdk-pixbuf"))
                     (fontconf #$(this-package-input "fontconfig-minimal"))
                     (sh #$(this-package-input "bash-minimal")))
                ;; Main binary + credential helper.
                (mkdir-p libexec)
                (copy-file "usr/bin/github"
                           (string-append libexec "/github"))
                (chmod (string-append libexec "/github") #o755)
                (copy-file "usr/bin/git-credential-copilot"
                           (string-append libexec "/git-credential-copilot"))
                (chmod (string-append libexec "/git-credential-copilot") #o755)
                ;; Runtime resources (onnxruntime, native plugins, copilot-sdk,
                ;; terminal integration, icons, sounds).
                (copy-recursively "usr/lib/GitHub Copilot"
                                  (string-append libexec "/resources"))
                ;; ld-linux wrapper for the main app.
                (mkdir-p bin)
                (with-output-to-file (string-append bin "/github")
                  (lambda ()
                    (display
                     (string-append
                      "#!" sh "/bin/sh\n"
                      "export FONTCONFIG_FILE=" fontconf
                      "/etc/fonts/fonts.conf\n"
                      ;; Use prefix (not =) so the system XDG_DATA_DIRS
                      ;; (guix-home, current-system, shared-mime-info, ...)
                      ;; is preserved.  Overwriting it breaks gdk-pixbuf's
                      ;; loader/mime resolution: GTK aborts with
                      ;; "Unrecognized image file format (gdk-pixbuf-error-quark, 3)"
                      ;; before any window appears.
                      "export XDG_DATA_DIRS=" out "/share:"
                      gtk-share ":" webkitgtk-share
                      "${XDG_DATA_DIRS:+:$XDG_DATA_DIRS}\n"
                      "export GI_TYPELIB_PATH=" glib-lib "/girepository-1.0:"
                      gtk-lib "/girepository-1.0:"
                      webkitgtk-lib "/girepository-1.0:"
                      gdk-pixbuf "/lib/girepository-1.0\n"
                      "export GIO_EXTRA_MODULES=" glib-lib "/gio/modules\n"
                      ;; Let gdk-pixbuf pick up loaders via the Guix profile
                      ;; hook (GUIX_GDK_PIXBUF_MODULE_FILES) inherited from
                      ;; the environment, rather than pointing the upstream
                      ;; GDK_PIXBUF_MODULE_FILE at this package's partial
                      ;; 11-loader cache (no png/jpeg).
                      ;; The app dlopens native plugins / onnxruntime from its
                      ;; resource dir; keep it on the library path too.
                      "export LD_LIBRARY_PATH=" libexec "/resources"
                      "${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}\n"
                      "exec " ld.so " --argv0 " libexec "/github"
                      " --library-path " lib-path ":" libexec "/resources"
                      " " libexec "/github \"$@\"\n"))))
                (chmod (string-append bin "/github") #o755)
                ;; git-credential-copilot also needs ld-linux + libgcc_s.
                (with-output-to-file (string-append bin "/git-credential-copilot")
                  (lambda ()
                    (display
                     (string-append
                      "#!" sh "/bin/sh\n"
                      "exec " ld.so " --argv0 " libexec "/git-credential-copilot"
                      " --library-path " lib-path
                      " " libexec "/git-credential-copilot \"$@\"\n"))))
                (chmod (string-append bin "/git-credential-copilot") #o755))))
          (add-after 'install 'install-desktop-entry
            (lambda _
              (let* ((out #$output)
                     (apps (string-append out "/share/applications")))
                (mkdir-p apps)
                (copy-file "usr/share/applications/GitHub Copilot.desktop"
                           (string-append apps "/github-copilot.desktop"))
                (substitute* (string-append apps "/github-copilot.desktop")
                  (("Exec=github")
                   (string-append "Exec=" out "/bin/github"))
                  (("Icon=github")
                   "Icon=github")))))
          (add-after 'install-desktop-entry 'install-icons
            (lambda _
              (let* ((out #$output)
                     (icon-src "usr/share/icons/hicolor")
                     (icon-dst (string-append out "/share/icons/hicolor")))
                (copy-recursively icon-src icon-dst)))))))
    (native-inputs (list libarchive))
    (inputs `(("gcc:lib" ,gcc "lib")
              ("alsa-lib" ,alsa-lib)
              ("bash-minimal" ,bash-minimal)
              ("fontconfig-minimal" ,fontconfig)
              ("glibc" ,glibc)
              ("glib" ,glib)
              ("gtk+" ,gtk+)
              ("gdk-pixbuf" ,gdk-pixbuf)
              ;; tray-icon (used by Tauri for the taskbar tray) dlopens
              ;; libayatana-appindicator3.so.1 / libappindicator3.so.1 at
              ;; startup; missing it panics the whole app before any window
              ;; appears (see ~/.copilot/crash-reports/*).
              ("libappindicator" ,libappindicator)
              ("libsoup" ,libsoup)
              ("mesa" ,mesa)
              ("openssl" ,openssl)
              ("pulseaudio" ,pulseaudio)
              ("webkitgtk-for-gtk3" ,webkitgtk-for-gtk3)))
    (properties `((upstream-name . "GitHub-Copilot")))
    (home-page "https://github.com/github/app")
    (synopsis "Agent-native GitHub Copilot desktop application")
    (description
     "The GitHub Copilot app is an agent-native desktop experience for
finding, running, steering, and landing software work across your GitHub
repositories.  It provides a single control center for starting and
steering local and cloud agent sessions, reviewing progress on shared
canvases, and tracking issues and pull requests.  Each local session runs
in its own isolated git worktree so multiple agents can work in parallel.
This is the unofficial Guix packaging of the prebuilt Linux x86_64
release; the application itself is proprietary.")
    (license (license:nonfree "https://github.com/github/app"))
    (supported-systems '("x86_64-linux"))))

;;; Herdr: terminal workspace manager that orchestrates multiple AI
;;; coding agents (Rust static-pie binary).
;;;
;;; The upstream release ships a single statically-linked (static-pie)
;;; Rust ELF binary with no interpreter and no NEEDED entries.  Being
;;; fully static, no patchelf or ld-linux wrapper is needed — just copy
;;; the raw binary to bin/ and make it executable (same approach as
;;; codewhale-bin).

(define-public herdr-bin
  (package
    (name "herdr-bin")
    (version "0.9.5")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/ogulcancelik/herdr/releases/download/"
             "v" version "/herdr-linux-x86_64"))
       (sha256
        (base32 "17cjb6gxh2wna8vv4bil82dz0qflfrpjcckwswc037jaifyfin8l"))))
    (build-system binary-build-system)
    (arguments
     (list
      ;; Fully static raw ELF: 'file unpack restores the exec bit.
      #:unpack-method 'file
      #:install-plan
      #~'(("herdr-linux-x86_64" "bin/herdr"))
      #:patchelf? #f))
    (home-page "https://herdr.dev")
    (synopsis "Terminal workspace manager for AI coding agents")
    (description
     "Herdr is an agent multiplexer that lives in your terminal, orchestrating
multiple AI coding agents (Claude Code, Codex, and others) from a single
tmux-style session.  It owns persistent PTYs so sessions survive restarts and
can be reattached locally or over SSH, and exposes a Unix-domain socket API so
agents can spawn panes, run commands, read output and wait on each other.
This package provides the prebuilt binary release.")
    (license license:agpl3+)
    (properties `((upstream-name . "herdr")))
    (supported-systems '("x86_64-linux"))))

;;; MiniMax Code: open-source AI coding agent for the terminal
;;; (MiniMax-AI/minimax-code, MIT).
;;;
;;; The upstream tarball is a self-contained npm-style distribution: a
;;; "package/" tree whose cli.js entry runs on Node (engines: >=22.19<23
;;; or >=24.2<27) with all JavaScript bundled into cli.js + chunks/.
;;; The Linux payload ships no native addons — SQLite goes through
;;; Node's built-in node:sqlite and the only Linux ELF
;;; (vendor/seccomp/*/apply-seccomp) is statically linked — so the tree
;;; installs verbatim, with no patchelf and no ld-linux wrapper.  The
;;; bundle carries no @vscode/ripgrep Linux binary and falls back to
;;; `rg` from PATH, hence the wrapper export.  bin/mcode execs cli.js
;;; through the store node.

(define-public minimax-code-bin
  (package
    (name "minimax-code-bin")
    (version "0.7.2")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/MiniMax-AI/minimax-code/releases/download/"
             "v" version "/minimax-code-" version ".tar.gz"))
       (sha256
        (base32 "1r7lf7gabj74bnzqnncas3j2h56y6n4792rgnsx6qa25d5lmn1da"))))
    (build-system binary-build-system)
    (arguments
     (list
      ;; npm-style tree installs verbatim; nothing dynamic to patch.
      #:unpack-method 'tar
      #:install-plan #~'(("." "lib/minimax-code"))
      #:patchelf? #f
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'install 'install-wrapper
            (lambda _
              (let* ((out #$output)
                     (bin (string-append out "/bin"))
                     (sh #$(this-package-input "bash-minimal"))
                     (node #$(this-package-input "node"))
                     ;; The bundle ships no @vscode/ripgrep Linux binary
                     ;; and falls back to `rg` from PATH.
                     (rg (string-append #$(this-package-input "ripgrep")
                                        "/bin")))
                (mkdir-p bin)
                (with-output-to-file (string-append bin "/mcode")
                  (lambda ()
                    (display
                     (string-append
                      "#!" sh "/bin/sh\n"
                      "export PATH=" rg ":${PATH}\n"
                      "exec " node "/bin/node "
                      out "/lib/minimax-code/cli.js \"$@\"\n"))))
                (chmod (string-append bin "/mcode") #o755)))))))
    (inputs `(("bash-minimal" ,bash-minimal)
              ("node" ,node)
              ("ripgrep" ,ripgrep)))
    (properties `((upstream-name . "minimax-code")))
    (home-page "https://github.com/MiniMax-AI/minimax-code")
    (synopsis "Open-source coding agent for your terminal, powered by MiniMax")
    (description
     "MiniMax Code (command @command{mcode}) is an open-source terminal
coding agent powered by MiniMax models.  It reads, edits and searches a
local code base, runs shell commands and drives sub-agents from an
interactive TUI, and authenticates with MiniMax or any custom
OpenAI-compatible endpoint.  This package installs the upstream
prebuilt distribution and launches it with the store Node.js runtime.")
    (license license:expat)))

(define-public opencode-desktop-bin
  (package
    (name "opencode-desktop-bin")
    (version "2.3.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/anomalyco/opencode/releases/download/"
             "v" version "/opencode-desktop-linux-amd64.deb"))
       (sha256
        (base32 "15j4ph2vzx83lwb7ss3wr5r58migzizpzjqf16xvmzldnj5ww04q"))))
    (build-system electron-build-system)
    (arguments
     (list
      #:program "opencode-desktop"
      #:app-dir "lib/opencode-desktop"
      #:application-directory "opencode-desktop"
      #:unpack-method 'deb-xz
      #:install-plan
      #~'(("opt/OpenCode" "lib/opencode-desktop"))
      ;; install-bin symlink, generated desktop entry and per-size icon
      ;; rename are beyond install-plan/desktop-files: kept as small
      ;; escape-hatch phases on top of the electron defaults.
      #:modules '((guix build utils)
                  (ice-9 ftw)
                  (ice-9 regex)
                  (srfi srfi-26))
      #:imported-modules '((guix build utils))
      #:phases
      #~(modify-phases (@ (jeans build electron) %standard-phases)
          (add-after 'patchelf 'install-bin
            (lambda _
              (let* ((out #$output)
                     (bin (string-append out "/bin"))
                     (exe (string-append
                           out "/lib/opencode-desktop/ai.opencode")))
                (mkdir-p bin)
                (symlink exe (string-append bin "/opencode-desktop")))))
          (add-after 'install-bin 'install-desktop
            (lambda _
              (let* ((out #$output)
                     (apps (string-append out "/share/applications")))
                (mkdir-p apps)
                (make-desktop-entry-file
                 (string-append apps "/opencode-desktop.desktop")
                 #:name "OpenCode"
                 #:type "Application"
                 #:comment #$(package-synopsis this-package)
                 #:exec (string-append #$output "/bin/opencode-desktop %U")
                 #:icon "opencode-desktop"
                 #:categories '("Development")
                 #:mime-type '("x-scheme-handler/opencode")
                 #:startup-w-m-class "OpenCode"))))
          (add-after 'install-desktop 'install-icons
            (lambda _
              (let* ((out #$output)
                     (icon-src "usr/share/icons/hicolor")
                     (icon-dst (string-append out "/share/icons/hicolor")))
                (when (file-exists? icon-src)
                  (copy-recursively icon-src icon-dst)
                  (for-each
                   (lambda (old)
                     (let ((new (string-append
                                 (string-append out "/share/icons/hicolor/"
                                                (match:substring
                                                 (string-match "/([0-9]+x[0-9]+)/apps/"
                                                               old) 1)
                                                "/apps/opencode-desktop.png"))))
                       (when (file-exists? old)
                         (copy-file old new))))
                   (find-files icon-dst "ai\\.opencode\\.png$")))))))))
    (native-inputs (list binutils tar xz))
    (inputs `(("alsa-lib" ,alsa-lib)
              ("at-spi2-core" ,at-spi2-core)
              ("bash-minimal" ,bash-minimal)
              ("nss-certs" ,nss-certs)
              ("cups" ,cups)
              ("dbus" ,dbus)
              ("eudev" ,eudev)
              ("expat" ,expat)
              ("fontconfig-minimal" ,fontconfig)
              ("gcc:lib" ,gcc "lib")
              ("glibc" ,glibc)
              ("glib" ,glib)
              ("gtk+" ,gtk+)
              ("libx11" ,libx11)
              ("libxcb" ,libxcb)
              ("libxcomposite" ,libxcomposite)
              ("libxdamage" ,libxdamage)
              ("libxext" ,libxext)
              ("libxfixes" ,libxfixes)
              ("libxkbcommon" ,libxkbcommon)
              ("libxrandr" ,libxrandr)
              ("mesa" ,mesa)
              ("nss" ,nss)))
    (properties `((upstream-name . "opencode-desktop")))
    (home-page "https://opencode.ai")
    (synopsis "AI coding agent desktop application")
    (description
     "OpenCode is a terminal-based AI coding agent with a desktop GUI built
with Electron.  It supports multiple LLM providers and offers an interactive
coding experience with context awareness.")
    (license license:expat)
    (supported-systems '("x86_64-linux"))))

;;; Paseo: self-hosted orchestrator for coding agents (Electron).
;;;
;;; The upstream .deb installs an Electron bundle under /opt/Paseo.  The
;;; bundle keeps its upstream layout under lib/paseo:
;;;   - Paseo                  POSIX launcher script (since 0.9.2, when the
;;;                            Electron binary moved to Paseo.bin).  Resolves
;;;                            its executable as "${0}.bin" via readlink, picks
;;;                            a sandbox strategy, then execs it.
;;;   - Paseo.bin              the Electron main executable (GUI entry)
;;;   - resources/bin/paseo    upstream CLI launcher; runs Paseo.bin with
;;;                            ELECTRON_RUN_AS_NODE=1.  Kept internal
;;;                            (not on PATH), matching the upstream .deb,
;;;                            which also leaves it out of /usr/bin.
;;;   - resources/app.asar.unpacked/node_modules/...  native addons
;;;     (node-pty pty.node, sherpa-onnx) in nested directories.  RPATH
;;;     entries therefore include $ORIGIN so addons resolve sibling
;;;     libraries (e.g. sherpa-onnx.node -> libsherpa-onnx-c-api.so)
;;;     without dragging their exact paths into the build recipe.
;;;
;;; Both shell launchers rely on commands from the host PATH (readlink,
;;; dirname, unshare, stat, findmnt, grep), so only their shebang is rewritten;
;;; they keep assuming a POSIX userland like the rest of the Electron bundle.
;;;
;;; License note: this release ships under Apache-2.0 (LICENSE at tag
;;; v0.7.0 is the full Apache text).  v0.6.1 shipped AGPLv3; upstream
;;; relicensed in commit a8734a9 (2026-08-27).

(define-public paseo-bin
  (package
    (name "paseo-bin")
    (version "0.15.4")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/getpaseo/paseo/releases/download/"
             "v" version "/Paseo-" version "-amd64.deb"))
       (sha256
        (base32 "0k8rrp56k35d5pxiqbf2xxhswgmw8wycc01f9chbzkjn6199nqxv"))))
    (build-system electron-build-system)
    (arguments
     (list
      #:program "paseo"
      #:app-dir "lib/paseo"
      #:application-directory "paseo"
      ;; Paseo's argv parser rejects injected --ozone-platform flags
      ;; ("error: unknown option"), so use the env-hint variant.
      #:wayland? 'hint-env
      #:unpack-method 'deb-xz
      #:install-plan
      #~'(("opt/Paseo" "lib/paseo"))
      ;; $ORIGIN-first RPATH so .node addons resolve sibling libraries
      ;; (e.g. sherpa-onnx.node -> libsherpa-onnx-c-api.so).
      #:preserve-rpath? #t
      ;; install-bin symlink, generated desktop/icons and the launcher
      ;; argv[0] fixup stay as escape-hatch phases on top of the electron
      ;; defaults.  The launcher scripts' #!/bin/sh shebangs are covered by
      ;; the retained patch-shebangs phase instead of a custom one.
      #:modules '((guix build utils)
                  (ice-9 ftw)
                  (ice-9 regex)
                  (srfi srfi-26))
      #:imported-modules '((guix build utils))
      #:phases
      #~(modify-phases (@ (jeans build electron) %standard-phases)
          (add-after 'patchelf 'install-bin
            (lambda _
              (let* ((out #$output)
                     (bin (string-append out "/bin"))
                     (exe (string-append out "/lib/paseo/Paseo")))
                (mkdir-p bin)
                (symlink exe (string-append bin "/paseo")))))
          (add-after 'install-bin 'install-desktop
            (lambda _
              (let* ((out #$output)
                     (apps (string-append out "/share/applications")))
                (mkdir-p apps)
                (make-desktop-entry-file
                 (string-append apps "/paseo.desktop")
                 #:name "Paseo"
                 #:type "Application"
                 #:comment #$(package-synopsis this-package)
                 #:exec (string-append #$output "/bin/paseo %U")
                 #:icon "paseo"
                 #:categories '("Development")
                 #:mime-type '("x-scheme-handler/paseo")
                 #:startup-w-m-class "Paseo"))))
          (add-after 'install-desktop 'install-icons
            (lambda _
              (let* ((icon-src "usr/share/icons/hicolor")
                     (icon-dst (string-append #$output
                                              "/share/icons/hicolor")))
                (for-each
                 (lambda (old)
                   (let* ((size (match:substring
                                  (string-match "/([0-9]+x[0-9]+)/apps/"
                                                old)
                                  1))
                          (new (string-append icon-dst "/" size
                                              "/apps/paseo.png")))
                     (mkdir-p (dirname new))
                     (copy-file old new)))
                 (find-files icon-src "Paseo\\.png$")))))
          (add-after 'prefer-wayland-hint 'point-wrapper-at-launcher
            ;; wrap-program passes a bare basename as argv[0]
            ;; (`exec -a "${0##*/}"`).  The launcher script derives its
            ;; Electron binary as "${0}.bin", so a basename would be resolved
            ;; against the caller's CWD; hand it the launcher's real path.
            (lambda _
              (substitute* (string-append #$output "/bin/paseo")
                (("exec -a \"[^\"]*\" ")
                 (string-append "exec -a \"" #$output
                                "/lib/paseo/Paseo\" "))))))))
    (native-inputs (list binutils tar xz))
    (inputs `(("alsa-lib" ,alsa-lib)
              ("at-spi2-core" ,at-spi2-core)
              ("bash-minimal" ,bash-minimal)
              ("nss-certs" ,nss-certs)
              ("cairo" ,cairo)
              ("cups" ,cups)
              ("dbus" ,dbus)
              ("eudev" ,eudev)
              ("expat" ,expat)
              ("fontconfig-minimal" ,fontconfig)
              ("gcc:lib" ,gcc "lib")
              ("glibc" ,glibc)
              ("glib" ,glib)
              ("gtk+" ,gtk+)
              ("libnotify" ,libnotify)
              ("libsecret" ,libsecret)
              ("libx11" ,libx11)
              ("libxcb" ,libxcb)
              ("libxcomposite" ,libxcomposite)
              ("libxdamage" ,libxdamage)
              ("libxext" ,libxext)
              ("libxfixes" ,libxfixes)
              ("libxkbcommon" ,libxkbcommon)
              ("libxrandr" ,libxrandr)
              ("libxscrnsaver" ,libxscrnsaver)
              ("libxtst" ,libxtst)
              ("mesa" ,mesa)
              ("nss" ,nss)
              ("pango" ,pango)
              ("util-linux:lib" ,util-linux "lib")))
    (properties `((upstream-name . "Paseo")))
    (home-page "https://paseo.sh")
    (synopsis "Self-hosted desktop client for orchestrating coding agents")
    (description
     "Paseo is a self-hosted orchestrator for coding agents such as Claude
Code, Codex, Copilot, OpenCode, and Pi.  It runs a local daemon that manages
the agents on your own machine with your own tools and configuration, and
connects desktop, web, mobile, and CLI clients to it.  Agents run in
parallel, tasks can be dictated through voice mode, and Paseo ships no
telemetry or forced log-ins.")
    (license license:asl2.0)
    (supported-systems '("x86_64-linux"))))

;;; ThinkRail: JetBrains' AI coding environment ("Vibe code with pi"),
;;; shipped as an Electrobun desktop application (Apache-2.0).
;;;
;;; The release publishes the same tree twice: thinkrail-desktop-linux-x64
;;; .tar.gz wraps it in a Zig self-extractor that installs into
;;; ~/.local/share, while the plain "stable" update bundle
;;; (stable-linux-x64-ThinkRail-<version>.tar.zst, covered by the release's
;;; SHA256SUMS) is the bare application directory.  This package uses the
;;; latter (file lists verified identical):
;;;   bin/launcher              native GTK/WebKit host entry point (Zig)
;;;   bin/bun                   Bun runtime that executes Resources/main.js
;;;   bin/libElectrobunCore.so  core library, dlopen'd by main.js
;;;   bin/libNativeWrapper.so   GTK/WebKit window and tray layer
;;;   Resources/                app code (bun/index.js), views, skills, ...
;;;
;;; Packaging notes:
;;;  - launcher resolves Resources/ and bin/bun from its own path
;;;    (/proc/self/exe) and chdirs into bin/ before spawning bun, so the
;;;    upstream bin/ + Resources/ sibling layout is preserved under
;;;    lib/thinkrail/ (an ld-linux wrapper would break that lookup).
;;;    The directory keeps the upstream name: -bin is only the Guix
;;;    package name, and nothing the app resolves may carry it.
;;;    launcher gets the Guix interpreter plus an RPATH; bun only gets the
;;;    interpreter, because patchelf --set-rpath rewrites the dynamic
;;;    section and breaks the file-offset lookups into Bun's embedded blob
;;;    (SIGSEGV, reproduced with bun 1.4.0).  bun and the dlopen'd
;;;    libraries resolve their dependencies via the wrapper's
;;;    LD_LIBRARY_PATH, which every child process inherits.
;;;  - libNativeWrapper.so needs libayatana-appindicator3.so.1, which Guix
;;;    does not ship.  Guix's libappindicator exports the same unversioned
;;;    app_indicator_* symbols (all five referenced ones included), so the
;;;    NEEDED entry is repointed with patchelf.
;;;  - The bundled self-updater and uninstaller (bin/bspatch, bin/zig-zstd,
;;;    Resources/uninstall) are removed: upgrades are owned by the channel.
;;;    The upstream ThinkRail.desktop is dropped too: its Exec=launcher
;;;    would resolve wrongly here, and this package installs its own file.

;;; 跳过迁移：bun 自定位混合体。launcher 要 interpreter+RPATH 而 bun 只能动
;;; interpreter（动 RPATH 会破坏内嵌 .bun 段）；另需 replace-needed 改 soname、
;;; 手写 LD_LIBRARY_PATH wrapper、删除自带 updater。基座 patch-one 按文件类型
;;; 一刀切，做不到“同包内不同 ELF 不同打法”，保留现状。
(define-public thinkrail-bin
  (package
    (name "thinkrail-bin")
    (version "0.4.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/JetBrains/thinkrail/releases/download/"
             "v" version "/stable-linux-x64-ThinkRail-" version ".tar.zst"))
       (sha256
        (base32 "1syv1khaqvxi42ca6vmac94ag665ad8cmcjglk3nkd5lqk68ym5q"))))
    (build-system gnu-build-system)
    (arguments
     (list
      #:tests? #f
      #:validate-runpath? #f
      #:strip-binaries? #f
      #:modules '((guix build gnu-build-system)
                  (guix build utils))
      #:phases
      #~(modify-phases %standard-phases
          (delete 'configure)
          (delete 'build)
          (replace 'unpack
            (lambda _
              (invoke "tar" "--zstd" "-xf" #$source)))
          (replace 'install
            (lambda _
              (let* ((out #$output)
                     (libdir (string-append out "/lib/thinkrail"))
                     (bindir (string-append libdir "/bin")))
                (copy-recursively "ThinkRail" libdir)
                ;; Upgrades are owned by the channel, not the app, and the
                ;; upstream desktop file points at a bare "launcher" name.
                (for-each delete-file
                          (list (string-append bindir "/bspatch")
                                (string-append bindir "/zig-zstd")
                                (string-append libdir "/Resources/uninstall")
                                (string-append libdir "/ThinkRail.desktop")))
                ;; wrap-program rewrites this symlink into a wrapper around
                ;; the real launcher; /proc/self/exe then still resolves to
                ;; the launcher itself.
                (mkdir-p (string-append out "/bin"))
                (symlink (string-append bindir "/launcher")
                         (string-append out "/bin/thinkrail")))))
          (add-after 'install 'patch-elf
            (lambda* (#:key inputs #:allow-other-keys)
              (let* ((out #$output)
                     (libdir (string-append out "/lib/thinkrail"))
                     (bindir (string-append libdir "/bin"))
                     (ld.so (string-append #$(this-package-input "glibc")
                                           #$(glibc-dynamic-linker)))
                     ;; Flat RPATH of the runtime inputs only: taking every
                     ;; #:inputs entry would pull build tools (and even the
                     ;; source tarball) into the package's references.
                     (rpath (string-join
                             (cons* "$ORIGIN" bindir
                                    (map (lambda (name)
                                           (string-append
                                            (assoc-ref inputs name) "/lib"))
                                         '("cairo" "fontconfig-minimal"
                                           "gcc:lib" "gdk-pixbuf" "glib"
                                           "glibc" "gtk+" "libappindicator"
                                           "libsoup" "mesa"
                                           "webkitgtk-for-gtk3")))
                             ":")))
                ;; launcher is an ordinary Zig executable: interpreter + RPATH.
                (invoke "patchelf" "--set-interpreter" ld.so
                        "--set-rpath" rpath (string-append bindir "/launcher"))
                ;; bun keeps its dynamic section untouched: patchelf
                ;; --set-rpath rewrites it and breaks the file-offset
                ;; lookups into Bun's embedded blob (SIGSEGV; verified
                ;; against bun 1.4.0, while the interpreter alone is safe).
                (invoke "patchelf" "--set-interpreter" ld.so
                        (string-append bindir "/bun"))
                ;; libNativeWrapper.so's tray layer links against the
                ;; ayatana fork's soname, which Guix does not ship.  Guix's
                ;; libappindicator exports the same five unversioned
                ;; app_indicator_* symbols; the shorter replacement name is
                ;; rewritten in place.  The remaining shared libraries
                ;; (libElectrobunCore, libasar, librust_pty) are left
                ;; untouched and resolve everything via LD_LIBRARY_PATH.
                (invoke "patchelf" "--replace-needed"
                        "libayatana-appindicator3.so.1"
                        "libappindicator3.so.1"
                        (string-append bindir "/libNativeWrapper.so")))))
          (add-after 'patch-elf 'install-desktop
            (lambda _
              (let* ((out #$output)
                     (apps (string-append out "/share/applications")))
                (mkdir-p apps)
                (make-desktop-entry-file
                 (string-append apps "/thinkrail.desktop")
                 #:name "ThinkRail"
                 #:comment #$(package-synopsis this-package)
                 #:exec (string-append out "/bin/thinkrail")
                 #:icon "thinkrail"
                 #:categories '("Development" "IDE")
                 #:startup-w-m-class "ThinkRail"))))
          (add-after 'install-desktop 'install-icons
            (lambda _
              (let* ((src (string-append #$output "/lib/thinkrail"
                                         "/Resources/appIcon.png"))
                     (dst (string-append #$output "/share/icons/hicolor"
                                         "/512x512/apps/thinkrail.png")))
                (mkdir-p (dirname dst))
                (copy-file src dst))))
          (add-after 'install-icons 'wrap-program
            (lambda* (#:key inputs outputs #:allow-other-keys)
              (let* ((out (assoc-ref outputs "out"))
                     (libdir (string-append out "/lib/thinkrail"))
                     (fontconfig (assoc-ref inputs "fontconfig-minimal"))
                     (runtime-dirs
                      (map (lambda (name) (assoc-ref inputs name))
                           '("cairo" "fontconfig-minimal" "gcc:lib"
                             "gdk-pixbuf" "glib" "glibc" "gtk+"
                             "libappindicator" "libsoup" "mesa"
                             "webkitgtk-for-gtk3")))
                     (lib-paths (map (lambda (dir)
                                       (string-append dir "/lib"))
                                     runtime-dirs))
                     (share-paths (map (lambda (dir)
                                         (string-append dir "/share"))
                                       runtime-dirs)))
                (wrap-program (string-append out "/bin/thinkrail")
                  `("LD_LIBRARY_PATH" prefix
                    (,(string-append libdir "/bin") ,libdir ,@lib-paths))
                  ;; Keep the system value (prefix semantics): overwriting
                  ;; XDG_DATA_DIRS breaks gdk-pixbuf loader/mime resolution.
                  `("XDG_DATA_DIRS" prefix
                    (,(string-append out "/share") ,@share-paths))
                  `("GI_TYPELIB_PATH" prefix
                    (,(string-append (assoc-ref inputs "glib")
                                     "/lib/girepository-1.0")
                     ,(string-append (assoc-ref inputs "gtk+")
                                     "/lib/girepository-1.0")
                     ,(string-append
                       (assoc-ref inputs "webkitgtk-for-gtk3")
                       "/lib/girepository-1.0")))
                  `("GIO_EXTRA_MODULES" prefix
                    (,(string-append (assoc-ref inputs "glib")
                                     "/lib/gio/modules")))
                  `("FONTCONFIG_FILE" =
                    (,(string-append fontconfig "/etc/fonts/fonts.conf"))))))))))
    (native-inputs (list patchelf tar zstd))
    (inputs `(("bash-minimal" ,bash-minimal)
              ("cairo" ,cairo)
              ("fontconfig-minimal" ,fontconfig)
              ("gcc:lib" ,gcc "lib")
              ("gdk-pixbuf" ,gdk-pixbuf)
              ("glib" ,glib)
              ("glibc" ,glibc)
              ("gtk+" ,gtk+)
              ;; libNativeWrapper.so's tray layer links against the
              ;; ayatana fork's soname; repointed to this implementation.
              ("libappindicator" ,libappindicator)
              ("libsoup" ,libsoup)
              ("mesa" ,mesa)
              ("webkitgtk-for-gtk3" ,webkitgtk-for-gtk3)))
    ;; The github updater matches the release asset URL against
    ;; "<name>-<version>"-style patterns, so upstream-name must be the
    ;; asset filename prefix that precedes the version: the source asset is
    ;; stable-linux-x64-ThinkRail-<version>.tar.zst.  With "thinkrail" here,
    ;; guix refresh reports "no updater" and the package never gets updates.
    (properties `((upstream-name . "stable-linux-x64-ThinkRail")))
    (home-page "https://thinkrail.ai/")
    (synopsis "JetBrains' lightweight AI coding IDE with the pi agent")
    (description
     "ThinkRail is a desktop coding environment from JetBrains that pairs a
lightweight IDE with the pi coding agent.  The agent can read code, edit
files, run commands, and review its own results, while projects stay in
regular local git repositories and connect to the LLM providers you
configure.  This package provides the prebuilt desktop release.")
    (license license:asl2.0)
    (supported-systems '("x86_64-linux"))))

(define-public zcode
  (package
    (name "zcode")
    (version "3.18.2")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://cdn-zcode.z.ai/zcode/electron/releases/"
             version "/linux-x64/ZCode-" version "-linux-x64.deb"))
       (sha256
        (base32 "0wsgjzx0qqm04lsiz6vnfsczq812d79lv8a66m05xl8qn3p6dq57"))))
    (build-system electron-build-system)
    (arguments
     (list
      #:program "zcode"
      #:app-dir "lib/zcode"
      #:application-directory "zcode"
      #:unpack-method 'deb-xz
      #:install-plan
      #~'(("opt/ZCode" "lib/zcode"))
      ;; install-bin symlink, generated desktop entry and the hicolor
      ;; icon copy are beyond install-plan: kept as small escape-hatch
      ;; phases on top of the electron defaults.
      #:modules '((guix build utils)
                  (ice-9 ftw)
                  (ice-9 regex)
                  (srfi srfi-26))
      #:imported-modules '((guix build utils))
      #:phases
      #~(modify-phases (@ (jeans build electron) %standard-phases)
          (add-after 'patchelf 'install-bin
            (lambda _
              (let* ((out #$output)
                     (bin (string-append out "/bin"))
                     (exe (string-append out "/lib/zcode/zcode")))
                (mkdir-p bin)
                (symlink exe (string-append bin "/zcode")))))
          (add-after 'install-bin 'install-desktop
            (lambda _
              (let* ((out #$output)
                     (apps (string-append out "/share/applications")))
                (mkdir-p apps)
                (make-desktop-entry-file
                 (string-append apps "/zcode.desktop")
                 #:name "ZCode"
                 #:type "Application"
                 #:comment #$(package-synopsis this-package)
                 #:exec (string-append #$output "/bin/zcode %U")
                 #:icon "zcode"
                 #:categories '("Development")
                 #:mime-type '("x-scheme-handler/zcode")
                 #:startup-w-m-class "ZCode"))))
          (add-after 'install-desktop 'install-icons
            (lambda _
              (let* ((out #$output)
                     (icon-src "usr/share/icons/hicolor")
                     (icon-dst (string-append out "/share/icons/hicolor")))
                ;; Upstream hicolor icons are already named zcode.png, which is
                ;; what Icon=zcode looks up.  Copying each file onto that
                ;; same path and then deleting every zcode.png removes them.
                (when (file-exists? icon-src)
                  (copy-recursively icon-src icon-dst))))))))
    (native-inputs (list binutils tar xz))
    (inputs `(("alsa-lib" ,alsa-lib)
              ("at-spi2-core" ,at-spi2-core)
              ("bash-minimal" ,bash-minimal)
              ("nss-certs" ,nss-certs)
              ("cups" ,cups)
              ("dbus" ,dbus)
              ("eudev" ,eudev)
              ("expat" ,expat)
              ("fontconfig-minimal" ,fontconfig)
              ("gcc:lib" ,gcc "lib")
              ("glibc" ,glibc)
              ("glib" ,glib)
              ("gtk+" ,gtk+)
              ("libx11" ,libx11)
              ("libxcb" ,libxcb)
              ("libxcomposite" ,libxcomposite)
              ("libxdamage" ,libxdamage)
              ("libxext" ,libxext)
              ("libxfixes" ,libxfixes)
              ("libxkbcommon" ,libxkbcommon)
              ("libxrandr" ,libxrandr)
              ("mesa" ,mesa)
              ("nss" ,nss)))
    (home-page "https://zcode.z.ai/")
    (synopsis "Desktop application for agent-assisted development")
    (description
     "Simple, Fast, Vibe‑Ready ! -- ZCode combines the best AI agents
with your existing tools so you can plan, code, review, and deploy
without friction.")
    (license (license:nonfree "https://zcode.z.ai/"))
    (supported-systems '("x86_64-linux"))))

;;; ZCode Proxy: local OpenAI/Anthropic-compatible proxy spending Z.AI and
;;; BigModel GLM coding-plan quotas (MIT, bun --compile single-file release).
;;;
;;; Upstream builds each release asset with `bun build --compile` (see the
;;; build:* scripts in package.json), so the linux-x64 asset is a self-contained
;;; binary with an embedded `.bun` section: `readelf -S` shows a PROGBITS `.bun`
;;; segment, and strings show bun's "Error writing .bun section to ELF"
;;; self-extraction message.  Rewriting the interpreter/RPATH with patchelf
;;; would shift the ELF layout and corrupt that section, and a Guix ld-linux
;;; wrapper would redirect /proc/self/exe away from the real binary — both are
;;; forbidden for this category (see conventions-prebuilt.md "自定位二进制").  The
;;; binary is therefore installed unpatched and runs through the system-wide
;;; nix-ld-service-type, whose default library list already covers the only
;;; NEEDED entries (`readelf -d`: libc.so.6, ld-linux-x86-64.so.2,
;;; libpthread.so.0, libdl.so.2, libm.so.6 — all glibc).
;;;
;;; No exe-relative resources: the release is a single file with no sidecars,
;;; config lives in ./config.yaml (auto-generated on first start) and every
;;; credential/cache path is homedir-relative (~/.zcode-proxy, ~/.zcode,
;;; ~/.zcode-captcha-cdn-cache — verified against src/), so installing the
;;; binary directly to bin/ under its upstream name is safe.
;;;
;;; License evidence: the repo carries no LICENSE file and package.json has
;;; no license field, but README.md ends with "## License / MIT".  Release
;;; evidence: tag v4.6.7 (stable, not prerelease), asset zcode-proxy-linux-x64
;;; (85 MB).  Tags are a single v* series, so no release-tag-prefix is needed;
;;; upstream-name matches the version-less asset filename prefix (same shape
;;; as herdr-bin).

(define-public zcode-proxy-bin
  (package
    (name "zcode-proxy-bin")
    (version "4.8.9")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/TriDefender/zcode-api/releases/download/"
             "v" version "/zcode-proxy-linux-x64"))
       (sha256
        (base32 "02xxb0cjvdifqm8qp755riabh9ls3w3qn1iq2rl1p2aq9vnv3fvh"))))
    (build-system binary-build-system)
    (arguments
     (list
      ;; bun --compile self-locating single file: install unpatched and
      ;; unwrapped, runs through the system-wide nix-ld service.
      #:unpack-method 'file
      #:install-plan
      #~'(("zcode-proxy-linux-x64" "bin/zcode-proxy"))
      #:patchelf? #f
      #:wrap? #f))
    (properties `((upstream-name . "zcode-proxy")))
    (home-page "https://github.com/TriDefender/zcode-api")
    (synopsis "Local proxy exposing GLM coding plans as OpenAI/Anthropic APIs")
    (description
     "ZCode Proxy is a local proxy that exposes Z.AI and BigModel GLM
coding-plan quotas through standard OpenAI, Anthropic, and Responses (Codex)
interfaces on @code{http://127.0.0.1:8080}, so tools such as Claude Code and
Codex CLI can spend plan quotas.  It ships an interactive terminal panel for
login and start/stop control, a built-in @code{/webui} chat page, and an
Android companion app.  This package provides the prebuilt @code{linux-x64}
release and needs the @code{nix-ld} system service to run.")
    (license license:expat)
    (supported-systems '("x86_64-linux"))))

;;; OmO is an AI coding-agent CLI built on the pi agent core (memory
;;; system, CodeMode, Anthropic subscriptions, installable extensions).
;;; Upstream naming is split three ways: the GitHub repo is
;;; oh-my-openagent, the npm package still carries the pre-rename name
;;; oh-my-opencode, while the product, release assets and CLI all say
;;; OmO/omo -- hence package name omo-bin with upstream-name "omo"
;;; (the release asset filename prefix).
;;;
;;; Upstream builds the release asset with `bun build --compile`:
;;; readelf -S shows the self-locating `.bun` / `.bun_builtins` sections,
;;; so patchelf and ld-linux wrappers are both forbidden here
;;; (conventions-prebuilt.md "自定位二进制").  Installed unpatched; runs
;;; through the system-wide nix-ld-service-type, whose default library
;;; list already covers the only NEEDED entries (readelf -d: libc.so.6,
;;; ld-linux-x86-64.so.2, libpthread.so.0, libdl.so.2, libm.so.6 -- all
;;; glibc).  The senpi-desktop-engine sidecar ships embedded in bunfs
;;; (/$bunfs/root/omo-runtime/native/prebuilds/linux-x64/...) and every
;;; config path is homedir-relative (~/.omo), so one file in bin/ is the
;;; whole runtime.
;;;
;;; License evidence: LICENSE.md is the Sustainable Use License 1.0 (the
;;; n8n model; package.json license field "SUL-1.0") -- source-visible
;;; but nonfree, so -bin naming with nonguix nonfree.  Release evidence:
;;; tag v5.1.28 (stable, GitHub Latest), asset omo-linux-x64 (150 MB).
;;; guix refresh handles the whole update cycle despite the version-less
;;; asset filename (verified end-to-end: with the package downgraded to
;;; 5.1.27, `refresh -u` rebuilt the download URL, recomputed the hash
;;; and restored 5.1.28), so it belongs on the auto-update workflow's
;;; refresh list.

(define-public omo-bin
  (package
    (name "omo-bin")
    (version "5.1.70")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/code-yeongyu/oh-my-openagent/releases/download/"
             "v" version "/omo-linux-x64"))
       (sha256
        (base32
         "0aldljy0h2431hb5n70mb09pnf42xh20lvxz5kbqyv6wyqs7zjvd"))))
    (build-system binary-build-system)
    (arguments
     (list
      ;; bun --compile self-locating single file: install unpatched and
      ;; unwrapped, runs through the system-wide nix-ld service.
      #:unpack-method 'file
      #:install-plan
      #~'(("omo-linux-x64" "bin/omo"))
      #:patchelf? #f
      #:wrap? #f))
    (properties `((upstream-name . "omo")))
    (home-page "https://github.com/code-yeongyu/oh-my-openagent")
    (synopsis "AI coding agent CLI with memory system and extensions")
    (description
     "OmO is an AI coding agent command-line interface built on the pi
agent core: it drives multi-model coding sessions with read, bash, edit
and write tools, a built-in memory system, durable scheduled prompts, and
installable extension packages (@command{omo install}).  Configuration
lives in @file{~/.omo}; on first start it migrates a pre-existing
@file{~/.pi/agent} directory.  This package provides the prebuilt
@code{linux-x64} release and needs the @code{nix-ld} system service to
run.")
    (license (license:nonfree
              "https://github.com/code-yeongyu/oh-my-openagent/blob/main/LICENSE.md"))
    (supported-systems '("x86_64-linux"))))

;;; cua-driver is the computer-use automation driver from the trycua/cua
;;; monorepo (MIT).  The release tarball ships an FHS dynamic ELF set that
;;; needs libX11/libXi/libxkbcommon and libgcc_s; every ELF gets the Guix
;;; interpreter and an explicit RPATH.  The payload lives in
;;; libexec/cua-driver/ mirroring the upstream release directory layout
;;; (cua-driver resolves its sibling cua-cursor-theme and wayland-helper
;;; helpers there), and bin/cua-driver is a thin wrapper that enables the
;;; native Wayland backend only when WAYLAND_DISPLAY is set (X11 capture
;;; is broken on pure-Wayland compositors like niri) and disables the
;;; default PostHog telemetry.
(define-public cua-driver-bin
  (package
    (name "cua-driver-bin")
    (version "0.49.9")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/trycua/cua/releases/download/"
             "cua-driver-rs-v" version
             "/cua-driver-rs-" version "-linux-x86_64-binary.tar.gz"))
       (sha256
        (base32 "1jkiwdd50l2j9m8a0agkkqjxq79caifzdclhnbhmhrlzlh2r30vm"))))
    (build-system binary-build-system)
    (arguments
     (list
      ;; Flat tarball (no top-level dir); FHS ELF set with a thin
      ;; hand-written launcher.  wayland-helper/ installs verbatim and
      ;; stays unpatched, as before.
      #:unpack-method 'tar
      #:install-plan
      #~'(("cua-driver" "libexec/cua-driver/cua-driver")
          ("cua-cursor-theme" "libexec/cua-driver/cua-cursor-theme")
          ("libcua_driver_sdk.so" "libexec/cua-driver/libcua_driver_sdk.so")
          ("cua_driver_node_runtime.node"
           "libexec/cua-driver/cua_driver_node_runtime.node")
          ("wayland-helper" "libexec/cua-driver/wayland-helper"))
      #:patchelf-plan
      #~'(("libexec/cua-driver/cua-driver"
           "libx11" "libxi" "libxkbcommon" "gcc:lib")
          ("libexec/cua-driver/cua-cursor-theme"
           "libx11" "libxi" "libxkbcommon" "gcc:lib")
          ("libexec/cua-driver/libcua_driver_sdk.so"
           "libx11" "libxi" "libxkbcommon" "gcc:lib")
          ("libexec/cua-driver/cua_driver_node_runtime.node"
           "libx11" "libxi" "libxkbcommon" "gcc:lib"))
      #:phases
      #~(modify-phases %standard-phases
          ;; Flat tarball: several top-level files plus wayland-helper/.  The
          ;; default unpack would chdir into wayland-helper, so unpack flat.
          (replace 'unpack
            (lambda _
              (invoke "tar" "xvf" #$source)))
          (add-after 'install 'install-wrapper
            (lambda _
              (let* ((out #$output)
                     (bin (string-append out "/bin"))
                     (libexec (string-append out "/libexec/cua-driver")))
                (mkdir-p bin)
                (call-with-output-file (string-append bin "/cua-driver")
                  (lambda (port)
                    (format port "#!~a/bin/bash
if [ -n \"${WAYLAND_DISPLAY:-}\" ]; then
  export CUA_DRIVER_RS_ENABLE_WAYLAND=1
fi
export CUA_DRIVER_RS_TELEMETRY_ENABLED=0
exec ~a \"$@\""
                            #$(this-package-input "bash-minimal")
                            (string-append libexec "/cua-driver"))))
                (chmod (string-append bin "/cua-driver") #o555)))))))
    (inputs `(("bash-minimal" ,bash-minimal)
              ("gcc:lib" ,gcc "lib")
              ("glibc" ,glibc)
              ("libx11" ,libx11)
              ("libxi" ,libxi)
              ("libxkbcommon" ,libxkbcommon)))
    (home-page "https://github.com/trycua/cua")
    (synopsis "Cross-platform computer-use automation driver")
    (description
     "Cua is a computer-use automation driver that exposes screenshot
capture, window discovery, and keyboard/mouse input injection through a
stdio MCP server (cua-driver mcp).  It backs the computer_use toolset of
AI agent runtimes and speaks both X11 and native Wayland on Linux.
Runtime state lives in ~/.cua-driver; upgrades are owned by the channel
so the bundled self-updater should not be used.")
    (properties `((upstream-name . "cua-driver-rs")
                  (release-tag-prefix . "^cua-driver-rs-v")))
    (license license:expat)
    (supported-systems '("x86_64-linux"))))

;;; Magpie: menu-bar hub that routes AI coding agents to any model
;;; (yetone/magpie, MIT).
;;;
;;; The Linux release is a single dynamically-linked Go ELF built with
;;; Wails (GTK3 + webkit2gtk-4.1, same stack as Tauri).  All web assets
;;; are embedded in the binary (Go embed) and no sidecar files ship in
;;; the release.
;;;
;;; patchelf must not touch this ELF: --set-interpreter/--set-rpath
;;; rewrite the program headers and leave the .note/.dynsym sections
;;; outside any PT_LOAD, after which the dynamic loader segfaults in
;;; dl_main before main() runs (gdb: "Loadable section outside of ELF
;;; segments"; the unpatched binary runs fine).  Same category as the
;;; bun --compile lesson — instead of patching, the unmodified ELF is
;;; installed under its upstream name in libexec/ and launched through
;;; the Guix ld-linux wrapper with --argv0 and --library-path (the
;;; github-copilot pattern).
;;;
;;; NEEDED at 0.1.1203 (re-check with `patchelf --print-needed` on
;;; upgrades; Go rebuilds can add or drop entries): libgtk-3, libgdk-3,
;;; libgdk_pixbuf-2.0, libgio-2.0, libgobject-2.0, libglib-2.0,
;;; libfontconfig (new in 0.1.1167 — must sit in --library-path),
;;; libX11, libwebkit2gtk-4.1, libsoup-3.0, libjavascriptcoregtk-4.1,
;;; libc.
;;;
;;; The Wails self-updater (wails:updater:* IPC) is runtime-only —
;;; there is no package-type file to remove — and upgrades are owned by
;;; the channel.  Plugins and sign-in state live under the user's XDG
;;; data dirs, which the wrapper leaves untouched (prefix semantics).
;;;
;;; Desktop integration mirrors upstream's install.sh: a menu entry
;;; claiming the x-scheme-handler/magpie MIME type (magpie://import
;;; links) plus a 256x256 icon.  The release ships neither, so the
;;; entry is generated and the icon is fetched from the very URL the
;;; installer downloads it from.
;;;
;;; magpie also keeps a copy of that entry in the user's XDG_DATA_HOME,
;;; rewritten on every start with os.Executable() as the command --
;;; which under this launcher is ld.so, so the copy cannot start
;;; anything.  It nevertheless decides what the menu runs, because
;;; launchers walk XDG_DATA_HOME before XDG_DATA_DIRS and keep the
;;; first entry they see for a given desktop file id.  The wrapper
;;; therefore re-seals that copy read-only whenever it is missing,
;;; stale or writable; see the comment there.
(define magpie-icon
  (origin
    (method url-fetch)
    (uri "https://usemagpie.ai/img/icon-256.png")
    (sha256
     (base32 "0167a1hh5mv99m35vqwzns3fs05a6308hhidqk7qynp0jrjpqhsp"))))

(define-public magpie-bin
  (package
    (name "magpie-bin")
    (version "0.1.4152")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/yetone/magpie-releases/releases/download/"
             "v" version "/magpie-linux-amd64"))
       (sha256
        (base32 "0fy19hvabb8r154nrflfiq34wbyxpxdf29pfb3cfm4y37ijnb83j"))))
    (build-system binary-build-system)
    (arguments
     (list
      ;; Single raw ELF, no archive; unpatched — see the comment above.
      #:unpack-method 'file
      #:install-plan
      #~'(("magpie-linux-amd64" "libexec/magpie/magpie"))
      #:patchelf? #f
      #:wrap? #f
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'install 'install-wrapper
            (lambda* (#:key inputs #:allow-other-keys)
              (let* ((out #$output)
                     (bin (string-append out "/bin"))
                     (real (string-append out "/libexec/magpie/magpie"))
                     (ld.so (string-append (assoc-ref inputs "glibc")
                                           #$(glibc-dynamic-linker)))
                     (libs (string-join
                            (map (lambda (name)
                                   (string-append
                                    (assoc-ref inputs name) "/lib"))
                                 '("fontconfig-minimal" "gdk-pixbuf"
                                   "glib" "glibc" "gtk+" "libx11"
                                   "libsoup" "wayland"
                                   "webkitgtk-for-gtk3"))
                            ":"))
                     (fontconf (assoc-ref inputs "fontconfig-minimal"))
                     (gtk-share (string-append (assoc-ref inputs "gtk+")
                                               "/share"))
                     (webkit-share
                      (string-append
                       (assoc-ref inputs "webkitgtk-for-gtk3") "/share")))
                (mkdir-p bin)
                (call-with-output-file (string-append bin "/magpie")
                  (lambda (port)
                    (format port "#!~a/bin/bash
export FONTCONFIG_FILE=~a/etc/fonts/fonts.conf
# Prefix (not =) so the system XDG_DATA_DIRS is kept behind the bundle.
export XDG_DATA_DIRS=~a:~a${XDG_DATA_DIRS:+:$XDG_DATA_DIRS}
# magpie rewrites the user-level magpie.desktop on every start: it opens
# the file, replaces its Exec= line with os.Executable() -- ld.so under
# this launcher -- and writes it back.  That copy beats the one this
# package installs, because launchers walk XDG_DATA_HOME before
# XDG_DATA_DIRS.  Seal the file read-only (the rewrite's open then
# fails) and re-seal it whenever it went missing, writable or stale.
# The bare command name keeps the entry valid across package upgrades.
d=\"${XDG_DATA_HOME:-$HOME/.local/share}/applications\"
f=\"$d/magpie.desktop\"
want=$(cat <<'SEALED'
# Sealed by the magpie-bin Guix wrapper: left writable, magpie replaces
# this file's Exec line with os.Executable() (ld.so) on every start.
[Desktop Entry]
Type=Application
Name=magpie
Comment=Every agent's model. One place.
Exec=magpie %u
Icon=magpie
StartupWMClass=magpie
Categories=Development;Utility;
MimeType=x-scheme-handler/magpie;
Terminal=false
SEALED
)
if [ \"$(cat \"$f\" 2>/dev/null)\" != \"$want\" ] || [ -w \"$f\" ]; then
  mkdir -p \"$d\" 2>/dev/null
  chmod u+w \"$f\" 2>/dev/null
  printf '%s\\n' \"$want\" > \"$f\" 2>/dev/null
  chmod 444 \"$f\" 2>/dev/null
fi
exec ~a --argv0 ~a --library-path ~a ~a \"$@\""
                            (assoc-ref inputs "bash-minimal")
                            fontconf
                            gtk-share
                            webkit-share
                            ld.so real libs real)))
                (chmod (string-append bin "/magpie") #o555))))
          (add-after 'install 'install-desktop-entry
            (lambda _
              (let ((apps (string-append #$output "/share/applications"))
                    (icons (string-append #$output
                                          "/share/icons/hicolor/256x256/apps")))
                (mkdir-p apps)
                (mkdir-p icons)
                (copy-file #$magpie-icon (string-append icons "/magpie.png"))
                (make-desktop-entry-file
                 (string-append apps "/magpie.desktop")
                 #:name "magpie"
                 #:comment "Every agent's model. One place."
                 #:exec (string-append #$output "/bin/magpie %u")
                 #:icon "magpie"
                 #:categories '("Development" "Utility")
                 #:mime-type "x-scheme-handler/magpie"
                 #:startup-w-m-class "magpie"
                 #:terminal #f
                 #:startup-notify #f)))))))
    (inputs `(("bash-minimal" ,bash-minimal)
              ("fontconfig-minimal" ,fontconfig)
              ("gdk-pixbuf" ,gdk-pixbuf)
              ("glib" ,glib)
              ("glibc" ,glibc)
              ("gtk+" ,gtk+)
              ("libx11" ,libx11)
              ("libsoup" ,libsoup)
              ("wayland" ,wayland)
              ("webkitgtk-for-gtk3" ,webkitgtk-for-gtk3)))
    (properties `((upstream-name . "magpie")))
    (home-page "https://usemagpie.ai")
    (synopsis "Menu-bar hub that routes AI coding agents to any model")
    (description
     "Magpie is a menu-bar companion for AI coding agents: it connects
agents such as Codex CLI and Claude Code to the provider of your choice
(DeepSeek, Kimi, GLM, Copilot, OpenRouter, and many more), keeps their
credentials and usage in one place, and exposes its own
OpenAI-compatible proxy endpoint.  This package provides the prebuilt
binary release.")
    (license license:expat)
    (supported-systems '("x86_64-linux"))))

;;; WorkBuddy（中国版）：腾讯的 AI 办公智能体桌面端，闭源 Electron 应用。
;;;
;;; 版本信号。官网 Linux 一栏只写「到统信 UOS/银河麒麟应用商店下载」，官方
;;; 桌面更新通道却直接提供 Linux 构建：主信号取与产物同域的清单
;;;   https://download.codebuddy.cn/workbuddy/saas/version.json
;;; （linux-x64-deb.stable.version），备用信号取
;;;   https://copilot.tencent.com/v2/update?platform=workbuddy-linux-x64-deb
;;; 清单里的版本就是完整文件名主体（<semver>.<build>-<commit>），故 version
;;; 保留 commit 后缀：上游会用同一数字版本重切构建并换后缀，只留数字版本的
;;; 包永远等不到重钉。自动更新见 scripts/check-updates/handlers/workbuddy_cn.py。
;;;
;;; 源站。download.codebuddy.cn 是 CDN，上游会原地重传同名文件，重传窗口内
;;; 大陆与海外边缘可能给出不同字节；本包 hash 固定，故固定 COS 桶的全球加速
;;; 端点（同一对象、各处同字节），与 flatpark 的 resolve-update.sh 同款处理。
;;; 路径与文件名和 CDN 完全一致，只换主机。
;;;
;;; 布局。deb 把整棵 electron-builder 产物放在 /opt/WorkBuddy，里面另有捆绑的
;;; Node 与 CPython 运行时供智能体调用工具。主二进制 workbuddy 的 DT_RPATH 是
;;; $ORIGIN，NEEDED 里带同目录的 libffmpeg.so——#:preserve-rpath? 必须为 #t，
;;; 否则 RPATH 被换成 store 路径后 libffmpeg 解析失败，启动即挂。
;;;
;;; 数据目录。应用不读 XDG 变量：账号状态、插件、日志与它自己下载的运行时都
;;; 在 ~/.workbuddy，任务工作区在 ~/WorkBuddy，凭据回退密钥在
;;; ~/.workbuddy-key-fallback。

(define-public workbuddy-cn
  (package
    (name "workbuddy-cn")
    (version "5.6.2.40046327-c7b525f3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://acc-1258344699.cos.accelerate.myqcloud.com/"
             "workbuddy/saas/linux-x64-deb/"
             "WorkBuddy-linux-x64-deb-" version ".deb"))
       (sha256
        (base32 "08vmi4cp17mfn6cxlyj2jn08ss3xhb3n53rd0vaqyx6dq3c9l50j"))))
    (build-system electron-build-system)
    (arguments
     (list
      #:program "workbuddy"
      ;; 安装路径用上游原名：-cn 只是本通道区分区域版本的记号，上游不认识它
      ;; （scripts/check-package-paths.py 的规则，cindy-cn-bin 同为 lib/cindy）。
      #:app-dir "lib/workbuddy"
      #:application-directory "workbuddy"
      #:unpack-method 'deb-xz
      ;; 捆绑的 .so/.node 用 $ORIGIN 定位同目录依赖（libffmpeg、pty.node 等），
      ;; RPATH 被替换即失效。
      #:preserve-rpath? #t
      #:install-plan
      #~'(("opt/WorkBuddy" "lib/workbuddy")
          ("usr/share/applications/workbuddy.desktop"
           "share/applications/workbuddy.desktop")
          ("usr/share/icons/hicolor" "share/icons/hicolor"))
      #:desktop-files
      #~'(("share/applications/workbuddy.desktop"
           "bin/workbuddy"
           "share/icons/hicolor/512x512/apps/workbuddy.png"))
      #:modules '((guix build utils))
      #:phases
      #~(modify-phases (@ (jeans build electron) %standard-phases)
          (add-after 'patchelf 'install-bin
            (lambda _
              (let ((bin (string-append #$output "/bin")))
                (mkdir-p bin)
                (symlink (string-append #$output "/lib/workbuddy/workbuddy")
                         (string-append bin "/workbuddy"))))))))
    (inputs `(("alsa-lib" ,alsa-lib)
              ("at-spi2-core" ,at-spi2-core)
              ("bash-minimal" ,bash-minimal)
              ("cups" ,cups)
              ("dbus" ,dbus)
              ("eudev" ,eudev)
              ("expat" ,expat)
              ("fontconfig-minimal" ,fontconfig)
              ("gcc:lib" ,gcc "lib")
              ("glib" ,glib)
              ("glibc" ,glibc)
              ("gtk+" ,gtk+)
              ;; 登录凭据走系统 secrets 服务（Electron safeStorage 运行时
              ;; dlopen libsecret-1.so.0，NEEDED 看不见）。
              ("libsecret" ,libsecret)
              ("libx11" ,libx11)
              ("libxcb" ,libxcb)
              ("libxcomposite" ,libxcomposite)
              ("libxdamage" ,libxdamage)
              ("libxext" ,libxext)
              ("libxfixes" ,libxfixes)
              ("libxkbcommon" ,libxkbcommon)
              ("libxrandr" ,libxrandr)
              ("mesa" ,mesa)
              ("nss" ,nss)
              ("nss-certs" ,nss-certs)))
    (home-page "https://www.workbuddy.cn/")
    (synopsis "AI agent desktop workspace from Tencent")
    (description
     "WorkBuddy is an Electron desktop application in which an AI agent plans
and carries out office work: it reads documents, edits files, drives
applications and reports progress while running.  This is the China build
distributed through Tencent's own update channel; signing in requires a
Tencent account.")
    (license (license:nonfree "https://www.workbuddy.cn/"))
    (supported-systems '("x86_64-linux"))))

;;; Qoder CN: Alibaba's agent workbench for human and AI software teams
;;; (closed-source Electron desktop client).
;;;
;;; 版本通道（2026-11-07 摸清）：上游不发 GitHub release，Linux .deb 只挂在
;;; 阿里云 OSS 上。官网和下载页给的是
;;;   .../qoder-app/releases/latest/Qoder-CN-linux-amd64.deb
;;; ——那是 OSS 里一次 CopyObject 出来的副本，每次发版被同名对象原地覆盖，
;;; 对 Guix 不可用（同一 URL 的内容会变，hash 必然漂移）。可固定的是桌面端
;;; 自更新通道的 electron-builder generic provider 清单，以及按版本归档的
;;; 资产目录：
;;;   https://static.qoder.com.cn/qoder-app/releases/latest-linux.yml
;;;   https://static.qoder.com.cn/qoder-app/releases/<version>/Qoder-CN-linux-amd64.deb
;;; 历史版本目录一直保留（0.3.0 起各版本实测仍可下载），所以 URI 指向
;;; releases/<version>/ 后，同一版本号的内容就是稳定的。版本发现交给
;;; scripts/check-updates/handlers/qoder_cn.py（读清单；同版本按清单 sha256
;;; 重钉，防上游原地重传）。
;;;
;;; 包内是 Electron 43（Chrome 150）的标准 /opt 布局：
;;;   - qoder-cn        主程序，RPATH=$ORIGIN 用于找同目录的 libffmpeg.so /
;;;                     libEGL / libGLESv2 / libvulkan / libvk_swiftshader
;;;   - chrome-sandbox  安装但非 setuid-root：Guix 下靠 user namespace
;;;                     sandbox（cindy-cn-bin 同一处理）
;;;   - resources/app.asar.unpacked/node_modules/ 原生模块：keytar 运行期
;;;                     dlopen libsecret-1.so.0（NEEDED 里看不见）、node-pty、
;;;                     sharp（自带 libvips-cpp.so，$ORIGIN RPATH 自足）、
;;;                     @napi-rs/canvas
;;;   - resources/package-type 是 electron-updater 的替换许可，由
;;;                     electron-build-system 的 disable-updater phase 删掉
;;;
;;; 登录链（2026-11-09 实证）：safeStorage/keytar dlopen libsecret-1.so.0 +
;;; 会话里的 org.freedesktop.secrets 服务，缺服务即退 basic_text 后端、
;;; isEncryptionAvailable() 报 false、应用拒绝持久化凭据（niri 下每次启动
;;; 都要重新登录）。wrapper 的 ensure-secret-service phase 在 exec 前补
;;; 服务并固定 --password-store=gnome-libsecret（cindy-cn-bin 同款）。
;;;
;;; 远程控制链（2026-11-09 实证）：utilityProcess.fork 用过滤后的 env
;;; （仅 HOME/PATH/LANG 等）重新 exec process.execPath，LD_LIBRARY_PATH
;;; 丢失；Guix 的 nss 库在 <nss>/lib/nss/，wrapper 的 LD_LIBRARY_PATH 特判
;;; 了它而 RUNPATH 没有 ⇒ 子进程 libnss3.so cannot open、退出 127。
;;; 基座 auto-lib-dirs 对 nss input 追加 /lib/nss 后自足。
;;;
;;; 闭源（.deb 的 License 字段为 unknown，随包只有 Electron/Chromium 的许可
;;; 文本），按通道惯例不加 -bin 后缀。

(define-public qoder-cn
  (package
    (name "qoder-cn")
    (version "0.5.11")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://static.qoder.com.cn/qoder-app/releases/"
             version "/Qoder-CN-linux-amd64.deb"))
       (sha256
        (base32 "1mk1cqjvdi59xsr557lji7b47bqymbh3zi0hhjy6aqbvz8i5cm4j"))))
    (build-system electron-build-system)
    (arguments
     (list
      #:program "qoder-cn"
      #:app-dir "lib/qoder-cn"
      #:application-directory "qoder-cn"
      ;; safeStorage 凭据持久化需要会话 secrets 服务：inputs 能定位到 gdbus /
      ;; gnome-keyring-daemon / gcr-prompter（即含 glib:bin / gnome-keyring /
      ;; gcr-3 三个输入）便自动启用 build/electron.scm 的
      ;; ensure-secret-service-phase（探测在位就不动，缺服务才兜底拉
      ;; gnome-keyring；用户显式 --password-store 永远最优先）。
      #:unpack-method 'deb-xz
      ;; 主程序 RPATH=$ORIGIN 用来找同目录 libffmpeg.so 等；sharp 的 .node
      ;; 也靠 $ORIGIN 相对路径找自带的 libvips。prepend 而不是替换。
      #:preserve-rpath? #t
      ;; @img/ 子树（sharp 的 .node 与自带 libvips-cpp.so）自包含，patch
      ;; 反而有 DT_INIT 失步风险（cindy-cn-bin 实证），整体跳过。
      #:patchelf-exclude
      #~'("lib/qoder-cn/resources/app.asar.unpacked/node_modules/@img/")
      #:install-plan
      #~'(("opt/Qoder-CN" "lib/qoder-cn")
          ("usr/share/applications/qoder-cn.desktop"
           "share/applications/qoder-cn.desktop")
          ("usr/share/icons/hicolor" "share/icons/hicolor")
          ("usr/share/doc/qoder-cn" "share/doc/qoder-cn"))
      #:desktop-files
      #~'(("share/applications/qoder-cn.desktop"
           "bin/qoder-cn"
           "share/icons/hicolor/256x256/apps/qoder-cn.png"))
      #:modules '((guix build utils))
      #:phases
      #~(modify-phases (@ (jeans build electron) %standard-phases)
          (add-after 'patchelf 'install-bin
            (lambda _
              (let* ((out #$output)
                     (bin (string-append out "/bin")))
                (mkdir-p bin)
                (symlink (string-append out "/lib/qoder-cn/qoder-cn")
                         (string-append bin "/qoder-cn"))))))))    (native-inputs (list binutils tar xz))
    (inputs `(("alsa-lib" ,alsa-lib)
              ("at-spi2-core" ,at-spi2-core)
              ("bash-minimal" ,bash-minimal)
              ("cairo" ,cairo)
              ("cups" ,cups)
              ("dbus" ,dbus)
              ("eudev" ,eudev)
              ("expat" ,expat)
              ("fontconfig-minimal" ,fontconfig)
              ("gcc:lib" ,gcc "lib")
              ("gcr-3" ,gcr-3)
              ("glibc" ,glibc)
              ("glib" ,glib)
              ("glib:bin" ,glib "bin")
              ("gnome-keyring" ,gnome-keyring)
              ("gtk+" ,gtk+)
              ;; keytar 运行期 dlopen libsecret-1.so.0（NEEDED 里看不见）；
              ;; 登录凭据由系统 secrets 服务提供。
              ("libsecret" ,libsecret)
              ("libx11" ,libx11)
              ("libxcb" ,libxcb)
              ("libxcomposite" ,libxcomposite)
              ("libxdamage" ,libxdamage)
              ("libxext" ,libxext)
              ("libxfixes" ,libxfixes)
              ("libxkbcommon" ,libxkbcommon)
              ("libxrandr" ,libxrandr)
              ("mesa" ,mesa)
              ("nss" ,nss)
              ("nss-certs" ,nss-certs)
              ("pango" ,pango)))
    (home-page "https://qoder.com")
    (synopsis "Agent workbench for human and AI software teams")
    (description
     "Qoder is an AI coding workspace in which an agent plans, reads code,
edits files, runs commands and reports progress while working.  This is the
China build distributed through Qoder's own update channel; signing in
requires a Qoder account.")
    (license (license:nonfree "https://qoder.com"))
    (supported-systems '("x86_64-linux"))))

;;; CrommaCode: proprietary agent terminal / desktop (GPUI + wgpu, not
;;; Electron).  Upstream deb layout:
;;;   /opt/crommacode/cromma-bees      main program (103 MB, stripped)
;;;   /opt/crommacode/bees             swarm CLI (6 MB)
;;;   /usr/bin/crommacode              symlink to the main program
;;;   /usr/share/applications/ai.cromma.bees.desktop
;;;   /usr/share/icons/hicolor/*/apps/ai.cromma.bees.png
;;;
;;; Two layout constraints drive the install plan:
;;;
;;; 1. bees must sit next to the main binary.  cromma-bees resolves it from
;;;    the current_exe parent directory ("cromma-bees: no `bees` next to ")
;;;    and only then falls back to PATH.  wrap-program renames the real ELF
;;;    to .cromma-bees-real, which keeps current_exe inside lib/crommacode/,
;;;    so both ELFs are installed there; bin/bees is an extra symlink for
;;;    plain shells.
;;;
;;; 2. wgpu dlopen()s libEGL.so.1, libvulkan.so.1, libwayland-client.so.0
;;;    and libwayland-egl.so.1.  Only libxcb, libxkbcommon, libxkbcommon-x11,
;;;    libasound, libgcc_s and libc are NEEDED, so RPATH covers those while
;;;    the wrapper's LD_LIBRARY_PATH supplies the dlopen'd set.
;;;
;;; 3. The UI is GPUI, whose fontdb reads FONTCONFIG_FILE (and a few
;;;    homedir-relative paths) but never XDG_DATA_DIRS.  Guix has no
;;;    /etc/fonts/fonts.conf, so a launcher-started session without that
;;;    variable would panic in resolve_font; the wrapper therefore supplies
;;;    a default and keeps any value the session already set.
;;;
;;; Runtime state lives in ~/.cromma-bees (0600 credential file) and the
;;; bees hive, both homedir-relative and independent of the install prefix.

(define-public crommacode
  (package
    (name "crommacode")
    (version "0.3.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://dl.cromma.ai/code/artifacts/" version
             "/CrommaCode-" version "-linux-amd64.deb"))
       (sha256
        (base32 "130wwlvv8phinri3fx3yp53sybdksp098z9h6c3f8zvggr7hgw6y"))))
    (build-system binary-build-system)
    (arguments
     (list
      #:unpack-method 'deb-xz
      #:app-dir "crommacode"
      ;; opt/crommacode/ contents (bees included) land in lib/crommacode/.
      ;; The deb's /usr/bin/crommacode is an absolute /opt symlink, so it is
      ;; skipped and recreated below.
      #:install-plan
      #~'(("opt/crommacode/" "lib/crommacode/")
          ("usr/share/applications/ai.cromma.bees.desktop"
           "share/applications/")
          ("usr/share/icons/hicolor/" "share/icons/hicolor/"))
      #:wrap-plan
      #~'(("lib/crommacode/cromma-bees"
           ("LD_LIBRARY_PATH" ":" prefix
            (#$(file-append libglvnd "/lib")
             #$(file-append vulkan-loader "/lib")
             #$(file-append wayland "/lib")))))
      #:desktop-files
      #~'(("share/applications/ai.cromma.bees.desktop" "bin/crommacode"))
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'wrap 'wrap-fontconfig
            (lambda _
              ;; fontdb only looks at FONTCONFIG_FILE; keep a session-supplied
              ;; value and fall back to fontconfig's own default otherwise.
              (substitute*
                  (string-append #$output "/lib/crommacode/cromma-bees")
                (("^exec -a ")
                 (string-append
                  "export FONTCONFIG_FILE=\"${FONTCONFIG_FILE:-"
                  #$(file-append fontconfig "/etc/fonts/fonts.conf")
                  "}\"\n"
                  "exec -a ")))))
          (add-after 'desktop-files 'install-bin
            (lambda _
              (let ((bin (string-append #$output "/bin")))
                (mkdir-p bin)
                (symlink (string-append #$output "/lib/crommacode/cromma-bees")
                         (string-append bin "/crommacode"))
                (symlink (string-append #$output "/lib/crommacode/bees")
                         (string-append bin "/bees"))))))))
    (inputs `(("alsa-lib" ,alsa-lib)
              ("fontconfig-minimal" ,fontconfig)
              ("gcc:lib" ,gcc "lib")
              ("glibc" ,glibc)
              ("libglvnd" ,libglvnd)
              ("libxcb" ,libxcb)
              ("libxkbcommon" ,libxkbcommon)
              ("vulkan-loader" ,vulkan-loader)
              ("wayland" ,wayland)))
    (home-page "https://cromma.ai/code")
    (synopsis "Terminal that turns coding-agent work into a watchable game")
    (description
     "CrommaCode is a desktop terminal for coding agents such as Claude Code
and Codex.  It runs an agent in a real terminal and renders the session as a
side-view game console, turning tool calls, plans and sub-agents into
watchable activity.  Its @command{bees} helper flies parallel workers, each in
its own git worktree and branch, and collects them back into the hive.
This package installs the vendor's prebuilt Linux release; an account is
required for the hosted features.")
    (license (license:nonfree "https://vibeloft.ai/terms"))
    (supported-systems '("x86_64-linux"))))

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
  #:use-module (gnu packages gnome)        ; libsoup
  #:use-module (gnu packages golang)       ; go
  #:use-module (gnu packages gtk)          ; gtk+, cairo, gdk-pixbuf, at-spi2-core
  #:use-module (gnu packages linux)        ; eudev
  #:use-module (gnu packages nss)          ; nss
  #:use-module (gnu packages ncurses)
  #:use-module (gnu packages node)         ; node
  #:use-module (gnu packages pulseaudio)   ; pulseaudio
  #:use-module (gnu packages rust-apps)    ; ripgrep
  #:use-module (gnu packages tls)          ; openssl
  #:use-module (gnu packages version-control) ; git
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
;;; 新包请用 jeans-electron-build-system，不再各写各的。

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
    (version "0.10.1")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/Hmbown/CodeWhale/releases/download/"
             "v" version "/codewhale-linux-x64.tar.gz"))
       (sha256
        (base32 "1h0bhz4p2xkzln8fyqg2y7ci9z859d0lbba1a7a8rwk0pjbk668h"))))
    (build-system jeans-binary-build-system)
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
;;;   - chrome-sandbox        setuid sandbox helper; Guix users run with
;;;                           --no-sandbox via kernel namespace sandbox,
;;;                           installed but not setuid-root
;;;   - resources/app.asar.unpacked/node_modules/...  native addons
;;;     (better-sqlite3, node-pty, sharp) in nested directories; sharp
;;;     carries its own $ORIGIN-relative RPATH pointing at the bundled
;;;     libvips, so patchelf must --prepend-rpath (existing RPATH kept)
;;;     rather than --set-rpath.
;;;   - resources/tools/ripgrep/rg   statically linked, shipped as-is.
;;;
;;; Sidecars proxy.mjs / cc-mgr.mjs are "#!/usr/bin/env node" scripts;
;;; Electron spawns them via ELECTRON_RUN_AS_NODE, so no Node.js input.
;;; electron-updater: no resources/package-type file in this bundle, so
;;; the disable-electron-updater phase is unnecessary.

(define-public cindy-bin
  (package
    (name "cindy-bin")
    (version "0.1.101")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/makecindy/cindy/releases/download/"
             "v" version "/cindy-" version "-linux-x64-cn.deb"))
       (sha256
        (base32 "1sy7wqcz7xd6cv4yhbiah0qx3b5w4fxmi658krpbmn784vm02fdb"))))
    (build-system jeans-electron-build-system)
    (arguments
     (list
      #:program "cindy"
      #:app-dir "lib/cindy"
      #:application-directory "cindy"
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
              ("libx11" ,libx11)
              ("libxcb" ,libxcb)
              ("libxcomposite" ,libxcomposite)
              ("libxdamage" ,libxdamage)
              ("libxext" ,libxext)
              ("libxfixes" ,libxfixes)
              ("libxkbcommon" ,libxkbcommon)
              ("libxrandr" ,libxrandr)
              ("mesa" ,mesa)
              ("nspr" ,nspr)
              ("nss" ,nss)
              ("pango" ,pango)))
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

;;; Crush: AI-powered coding assistant (Go TUI binary).
;;;
;;; The upstream .deb ships a single Go ELF binary:
;;;   - crush        (<= 0.77.x: dynamically linked to glibc;
;;;                   >= 0.78.0: statically linked Go build, no .interp)
;;;
;;; Probe linkage via `patchelf --print-interpreter` and only patch
;;; the ELF interpreter when dynamic; statically linked binaries are
;;; left untouched.  Wrap with PATH so crush can find git and other
;;; runtime tools regardless.
;;; 已迁移到 jeans-binary-build-system（首试点，纯参数迁移）。

(define-public crush-bin
  (package
    (name "crush-bin")
    (version "0.98.1")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/charmbracelet/crush/releases/download/"
             "v" version "/crush_" version "_amd64.deb"))
       (sha256
        (base32 "0rp290mb2kmbv0xlijcjcxw8qfz5bnc1spr10n6bb6m4ipbxq639"))))
    (build-system jeans-binary-build-system)
    (arguments
     (list
      #:unpack-method 'deb
      #:install-plan
      #~'(("usr/bin/crush" "bin/crush")
          ("etc/bash_completion.d/crush"
           "share/bash-completion/completions/crush")
          ("usr/share/fish/vendor_completions.d/crush.fish"
           "share/fish/vendor_completions.d/crush.fish")
          ("usr/share/zsh/site-functions/_crush"
           "share/zsh/site-functions/_crush")
          ("usr/share/man/man1/crush.1.gz"
           "share/man/man1/crush.1.gz"))
      #:patchelf-plan
      #~'(("bin/crush"))
      #:wrap-plan
      #~'(("bin/crush"
           ("PATH" ":" prefix
            (#$(file-append bash-minimal "/bin")
             #$(file-append coreutils-minimal "/bin")
             #$(file-append git "/bin")
             #$(file-append go "/bin")))))))
    (native-inputs (list binutils))
    (inputs
     `(("bash-minimal" ,bash-minimal)
       ("glibc" ,glibc)
       ("git" ,git)
       ("coreutils-minimal" ,coreutils-minimal)
       ("go" ,go)))
    (properties `((upstream-name . "crush")))
    (home-page "https://github.com/charmbracelet/crush")
    (synopsis "AI-powered coding assistant for the CLI")
    (description "Crush is an AI-powered coding assistant that runs in the terminal.
It supports multiple LLM providers, MCP servers, LSP integration, and provides
tools for file editing, shell command execution, web fetching, and more.
This package provides the prebuilt binary release.")
    (license
     (license:nonfree
      "https://github.com/charmbracelet/crush/blob/main/LICENSE.md"))))

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
    (version "1.1.28")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/github/app/releases/download/"
             "v" version "/GitHub-Copilot-linux-x64.deb"))
       (sha256
        (base32 "0c2fva3f85p0y7w2slnmw5l6rp7wxm8dajy6yz3vkd8z605x35q1"))))
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
;;; codewhale-bin / reasonix-bin).

(define-public herdr-bin
  (package
    (name "herdr-bin")
    (version "0.9.3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/ogulcancelik/herdr/releases/download/"
             "v" version "/herdr-linux-x86_64"))
       (sha256
        (base32 "19yvyj3l0gqrisknzx3cy3313nfgl7g5chrlhic4iyn2y5jxra0q"))))
    (build-system jeans-binary-build-system)
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
    (version "0.6.5")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/MiniMax-AI/minimax-code/releases/download/"
             "v" version "/minimax-code-" version ".tar.gz"))
       (sha256
        (base32 "00lzvbz39j23srkzxhfh675895c5vjsiwy8ax990f73f5plpldqn"))))
    (build-system jeans-binary-build-system)
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
    (version "1.18.35")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/anomalyco/opencode/releases/download/"
             "v" version "/opencode-desktop-linux-amd64.deb"))
       (sha256
        (base32 "19jgqygwncncyyikcwgh5vyiqn1z5w1gyalazq2qdh1s3vwbyhr2"))))
    (build-system jeans-electron-build-system)
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
      #:imported-modules '((guix build utils)
                           (ice-9 ftw)
                           (ice-9 regex)
                           (srfi srfi-26))
      #:phases
      #~(modify-phases (@ (jeans build electron) %standard-phases)
          (add-after 'patchelf 'install-bin
            (lambda _
              (let* ((out #$output)
                     (bin (string-append out "/bin"))
                     (exe (string-append
                           out "/lib/opencode-desktop/ai.opencode.desktop")))
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
                   (find-files icon-dst "ai\\.opencode\\.desktop\\.png$")))))))))
    (native-inputs (list binutils tar xz))
    (inputs `(("alsa-lib" ,alsa-lib)
              ("at-spi2-core" ,at-spi2-core)
              ("bash-minimal" ,bash-minimal)
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
    (license license:expat)))

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
    (version "0.11.2")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/getpaseo/paseo/releases/download/"
             "v" version "/Paseo-" version "-amd64.deb"))
       (sha256
        (base32 "1a4ix78rzd2yjd609vm3zira8gnwnr635nfd10hg34nc0ws5gd09"))))
    (build-system jeans-electron-build-system)
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
      #:imported-modules '((guix build utils)
                           (ice-9 ftw)
                           (ice-9 regex)
                           (srfi srfi-26))
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

;;; Reasonix: DeepSeek-native AI coding agent (Go static binary).
;;;
;;; The upstream tar.gz ships a single statically-linked Go ELF binary:
;;;   - reasonix       (CGO_ENABLED=0, no interpreter, no NEEDED)
;;;
;;; No patchelf or ld-linux wrapper needed — just extract and install.

(define-public reasonix-bin
  (package
    (name "reasonix-bin")
    (version "2.33.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/esengine/DeepSeek-Reasonix/releases/download/"
             "v" version "/reasonix-linux-amd64.tar.gz"))
       (sha256
        (base32 "0m8nabh3mszhwj77b9zdrnmy1m4ymk8v80w1xyvv5wb6458xfjdy"))))
    (build-system jeans-binary-build-system)
    (arguments
     (list
      ;; Single static Go binary: default unpack layout + plain install.
      #:unpack-method 'tar
      #:install-plan
      #~'(("reasonix" "bin/reasonix"))
      #:patchelf? #f))
    (home-page "https://github.com/esengine/DeepSeek-Reasonix")
    (synopsis "DeepSeek-native AI coding agent for the terminal")
    (description
     "Reasonix is a config- and plugin-driven AI coding agent written in Go,
designed around DeepSeek's prefix cache to keep token costs low across long
sessions.
It supports multi-model composition, external tools via MCP-compatible JSON-RPC,
and ships as a single static binary with no runtime dependencies.")
    (properties `((upstream-name . "reasonix") (release-tag-prefix . "^v")))
    (license license:expat)
    (supported-systems '("x86_64-linux"))))


;;; Reasonix Studio: DeepSeek-native AI coding agent desktop app (Electron).
;;;
;;; Upstream renamed the desktop line to Studio (studio-v* tags) and deleted
;;; the desktop-v1.38.4+ releases, so the old Wails-based reasonix-desktop-bin
;;; is replaced by this package.  The .deb ships an Electron tree:
;;;   - opt/Reasonix Studio/reasonix-studio-electron  (main Electron binary)
;;;   - opt/Reasonix Studio/resources/bin/reasonix-studio-host
;;;     (Go sidecar serving the loopback host; statically linked since
;;;     2.22.0, previously dynamically linked against libc)
;;;   - opt/Reasonix Studio/resources/app.asar  (frontend)
;;;
;;; The polkit update helper (/usr/lib/reasonix-studio/...) only serves
;;; in-app .deb upgrades, which Guix owns here, so it is not shipped.
;;; Same Electron treatment as zcode: copy the tree to lib/, patchelf every
;;; ELF, symlink bin/, wrap with LD_LIBRARY_PATH.
(define-public reasonix-studio-bin
  (package
    (name "reasonix-studio-bin")
    (version "2.33.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/esengine/DeepSeek-Reasonix/releases/download/"
             "studio-v" version "/ReasonixStudio-linux-amd64.deb"))
       (sha256
        (base32 "0pazjp3hi0p0yrvmc9s90pgh76nx8g67qb670s93bq5bls84a892"))))
    (build-system jeans-electron-build-system)
    (arguments
     (list
      #:program "reasonix-studio"
      #:app-dir "lib/reasonix-studio"
      #:application-directory "reasonix-studio"
      #:unpack-method 'deb-xz
      #:install-plan
      #~'(("opt/Reasonix Studio" "lib/reasonix-studio"))
      ;; install-bin symlink, generated desktop entry and icon rename are
      ;; beyond install-plan: kept as small escape-hatch phases.  The static
      ;; Go sidecar is auto-skipped by the builder's link probe.
      #:modules '((guix build utils)
                  (ice-9 ftw)
                  (ice-9 regex)
                  (srfi srfi-26))
      #:imported-modules '((guix build utils)
                           (ice-9 ftw)
                           (ice-9 regex)
                           (srfi srfi-26))
      #:phases
      #~(modify-phases (@ (jeans build electron) %standard-phases)
          (add-after 'patchelf 'install-bin
            (lambda _
              (let* ((out #$output)
                     (bin (string-append out "/bin"))
                     (exe (string-append
                            out "/lib/reasonix-studio/reasonix-studio-electron")))
                (mkdir-p bin)
                (symlink exe (string-append bin "/reasonix-studio")))))
          (add-after 'install-bin 'install-desktop
            (lambda _
              (let* ((out #$output)
                     (apps (string-append out "/share/applications")))
                (mkdir-p apps)
                (make-desktop-entry-file
                 (string-append apps "/reasonix-studio.desktop")
                 #:name "Reasonix Studio"
                 #:type "Application"
                 #:comment #$(package-synopsis this-package)
                 #:exec (string-append #$output "/bin/reasonix-studio %U")
                 #:icon "reasonix-studio"
                 #:categories '("Development")
                 #:startup-w-m-class "Reasonix Studio"))))
          (add-after 'install-desktop 'install-icons
            (lambda _
              (let* ((out #$output)
                     (src (string-append "usr/share/icons/hicolor/512x512/apps/"
                                      "reasonix-studio-electron.png"))
                     (dst (string-append
                            out "/share/icons/hicolor/512x512/apps/reasonix-studio.png")))
                (mkdir-p (dirname dst))
                (copy-file src dst)))))))
    (native-inputs (list binutils tar xz))
    (inputs `(("alsa-lib" ,alsa-lib)
              ("at-spi2-core" ,at-spi2-core)
              ("bash-minimal" ,bash-minimal)
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
    (home-page "https://github.com/esengine/DeepSeek-Reasonix")
    (synopsis "Desktop GUI for the Reasonix AI coding agent")
    (description
     "Reasonix Studio is the desktop companion to Reasonix, a DeepSeek-native
AI coding agent tuned around DeepSeek's prefix cache so token costs stay low
across long sessions.
This package provides the prebuilt Electron shell with its bundled loopback
host and frontend.  The harness is config- and plugin-driven with support
for multiple LLM providers.")
    (properties `((upstream-name . "ReasonixStudio") (release-tag-prefix . "^studio-v")))
    (license license:expat)
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
;;;    lib/thinkrail-bin/ (an ld-linux wrapper would break that lookup).
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
    (version "0.1.6")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/JetBrains/thinkrail/releases/download/"
             "v" version "/stable-linux-x64-ThinkRail-" version ".tar.zst"))
       (sha256
        (base32 "08mfigg4rvfvvskqijrmcp1xbdpkn7nl9kqy7jrfsdjxsi3ssvj9"))))
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
                     (libdir (string-append out "/lib/thinkrail-bin"))
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
                     (libdir (string-append out "/lib/thinkrail-bin"))
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
                 (string-append apps "/thinkrail-bin.desktop")
                 #:name "ThinkRail"
                 #:comment #$(package-synopsis this-package)
                 #:exec (string-append out "/bin/thinkrail")
                 #:icon "thinkrail"
                 #:categories '("Development" "IDE")
                 #:startup-w-m-class "ThinkRail"))))
          (add-after 'install-desktop 'install-icons
            (lambda _
              (let* ((src (string-append #$output "/lib/thinkrail-bin"
                                         "/Resources/appIcon.png"))
                     (dst (string-append #$output "/share/icons/hicolor"
                                         "/512x512/apps/thinkrail.png")))
                (mkdir-p (dirname dst))
                (copy-file src dst))))
          (add-after 'install-icons 'wrap-program
            (lambda* (#:key inputs outputs #:allow-other-keys)
              (let* ((out (assoc-ref outputs "out"))
                     (libdir (string-append out "/lib/thinkrail-bin"))
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
    (version "3.14.5")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://cdn-zcode.z.ai/zcode/electron/releases/"
             version "/linux-x64/ZCode-" version "-linux-x64.deb"))
       (sha256
        (base32 "1ksvzk16nh184sm9y5mskjr427dshk0fb8a8y4851n2vlv5qs6mc"))))
    (build-system jeans-electron-build-system)
    (arguments
     (list
      #:program "zcode"
      #:app-dir "lib/zcode"
      #:application-directory "zcode"
      #:unpack-method 'deb-xz
      #:install-plan
      #~'(("opt/ZCode" "lib/zcode"))
      ;; install-bin symlink, generated desktop entry and the quirky
      ;; icon rename+prune are beyond install-plan: kept as small
      ;; escape-hatch phases on top of the electron defaults.
      #:modules '((guix build utils)
                  (ice-9 ftw)
                  (ice-9 regex)
                  (srfi srfi-26))
      #:imported-modules '((guix build utils)
                           (ice-9 ftw)
                           (ice-9 regex)
                           (srfi srfi-26))
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
                (when (file-exists? icon-src)
                  (copy-recursively icon-src icon-dst)
                  (for-each
                   (lambda (old)
                     (let ((new (string-append
                                 (string-append out "/share/icons/hicolor/"
                                                (match:substring
                                                 (string-match "/([0-9]+x[0-9]+)/apps/"
                                                               old) 1)
                                                "/apps/zcode.png"))))
                       (when (file-exists? old)
                         (copy-file old new))))
                   (find-files icon-dst "zcode\\.png$"))
                  (for-each delete-file
                           (find-files icon-dst "zcode\\.png$")))))))))
    (native-inputs (list binutils tar xz))
    (inputs `(("alsa-lib" ,alsa-lib)
              ("at-spi2-core" ,at-spi2-core)
              ("bash-minimal" ,bash-minimal)
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
;;; forbidden for this category (see jeans-conventions.md "自定位二进制").  The
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
    (version "4.7.6")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/TriDefender/zcode-api/releases/download/"
             "v" version "/zcode-proxy-linux-x64"))
       (sha256
        (base32 "0pw5cxpn90wwq2j1vzm99bcp4civimmbsqfchf4h862cv06h7mkm"))))
    (build-system jeans-binary-build-system)
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
    (version "0.34.1")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/trycua/cua/releases/download/"
             "cua-driver-rs-v" version
             "/cua-driver-rs-" version "-linux-x86_64-binary.tar.gz"))
       (sha256
        (base32 "1vmgiza691gamj88pc671j774x89dgqp9h4lqlfm197frfyy47x4"))))
    (build-system jeans-binary-build-system)
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
;;; NEEDED at 0.1.1084 (re-check with `patchelf --print-needed` on
;;; upgrades; Go rebuilds can add or drop entries): libgtk-3, libgdk-3,
;;; libgdk_pixbuf-2.0, libgio-2.0, libgobject-2.0, libglib-2.0, libX11,
;;; libwebkit2gtk-4.1, libsoup-3.0, libjavascriptcoregtk-4.1, libc.
;;;
;;; The Wails self-updater (wails:updater:* IPC) is runtime-only —
;;; there is no package-type file to remove — and upgrades are owned by
;;; the channel.  Plugins and sign-in state live under the user's XDG
;;; data dirs, which the wrapper leaves untouched (prefix semantics).
(define-public magpie-bin
  (package
    (name "magpie-bin")
    (version "0.1.1157")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/yetone/magpie-releases/releases/download/"
             "v" version "/magpie-linux-amd64"))
       (sha256
        (base32 "1sg55s8lx7s4mj69bdfgc9md2d9jnwszy69xx77rk4q2b1ln911n"))))
    (build-system jeans-binary-build-system)
    (arguments
     (list
      ;; Single raw ELF, no archive; unpatched — see the comment above.
      #:unpack-method 'file
      #:install-plan
      #~'(("magpie-linux-amd64" "libexec/magpie-bin/magpie"))
      #:patchelf? #f
      #:wrap? #f
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'install 'install-wrapper
            (lambda* (#:key inputs #:allow-other-keys)
              (let* ((out #$output)
                     (bin (string-append out "/bin"))
                     (real (string-append out "/libexec/magpie-bin/magpie"))
                     (ld.so (string-append (assoc-ref inputs "glibc")
                                           #$(glibc-dynamic-linker)))
                     (libs (string-join
                            (map (lambda (name)
                                   (string-append
                                    (assoc-ref inputs name) "/lib"))
                                 '("gdk-pixbuf" "glib" "glibc" "gtk+"
                                   "libx11" "libsoup"
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
exec ~a --argv0 ~a --library-path ~a ~a \"$@\""
                            (assoc-ref inputs "bash-minimal")
                            fontconf
                            gtk-share
                            webkit-share
                            ld.so real libs real)))
                (chmod (string-append bin "/magpie") #o555)))))))
    (inputs `(("bash-minimal" ,bash-minimal)
              ("fontconfig-minimal" ,fontconfig)
              ("gdk-pixbuf" ,gdk-pixbuf)
              ("glib" ,glib)
              ("glibc" ,glibc)
              ("gtk+" ,gtk+)
              ("libx11" ,libx11)
              ("libsoup" ,libsoup)
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

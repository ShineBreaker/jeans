;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-only

;;; AI agent packages: prebuilt coding-agent binaries (CLI and desktop)
;;; and AI-powered editors, consolidated from tools.scm and desktop.scm.

(define-module (jeans packages agent)
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
  #:use-module (gnu packages pulseaudio)   ; pulseaudio
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
  #:use-module ((guix licenses)
                #:prefix license:)
  #:use-module ((nonguix licenses)
                #:prefix license:))


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
    (version "0.9.11")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/Hmbown/CodeWhale/releases/download/"
             "v" version "/codewhale-linux-x64.tar.gz"))
       (sha256
        (base32 "1gqh8xd00dc0zldi9wcz62rsjs9azq66cb8mbnz3dglzk4zkixj0"))))
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
              (invoke "tar" "xzf" #$source)
              ;; The archive stores the binaries as 0644; restore the
              ;; executable bit so install-file (and the user) can run them.
              (for-each (lambda (b) (chmod b #o755))
                        '("codewhale-linux-x64/codewhale"
                          "codewhale-linux-x64/codew"))))
          (replace 'install
            (lambda _
              (let ((bin (string-append #$output "/bin")))
                (mkdir-p bin)
                (for-each (lambda (b)
                            (install-file b bin))
                          '("codewhale-linux-x64/codewhale"
                            "codewhale-linux-x64/codew"))))))))
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

(define-public crush-bin
  (package
    (name "crush-bin")
    (version "0.92.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/charmbracelet/crush/releases/download/"
             "v" version "/crush_" version "_amd64.deb"))
       (sha256
        (base32 "0876pglqwsy4mvrmgsbls2gs6kd2cv3xqa3hng9rc2f2hinscfls"))))
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
              (let ((debdir (string-append "crush-" #$version)))
                (mkdir debdir)
                (with-directory-excursion debdir
                  (invoke "ar" "x" #$source)
                  (invoke "tar" "xzf" "data.tar.gz"))
                (chdir debdir))))
          (replace 'install
            (lambda* (#:key inputs #:allow-other-keys)
              (let* ((out #$output)
                     (bin (string-append out "/bin"))
                     (share (string-append out "/share"))
                     (patchelf-bin
                      (string-append (assoc-ref inputs "patchelf")
                                     "/bin/patchelf"))
                     (ldso (string-append (assoc-ref inputs "glibc")
                                          "/lib/ld-linux-x86-64.so.2"))
                     (crush-target (string-append bin "/crush")))
                (mkdir-p bin)
                (install-file "usr/bin/crush" bin)

                ;; crush >= 0.78.0 ships a statically linked Go binary
                ;; (no .interp section); patchelf --set-interpreter
                ;; errors out on such binaries with "cannot find
                ;; section '.interp'".  Probe via --print-interpreter
                ;; (exits 0 for dynamic, non-zero for static) and only
                ;; patch when dynamic linkage is present.
                (when (zero? (system* patchelf-bin
                                     "--print-interpreter"
                                     crush-target))
                  (invoke patchelf-bin "--set-interpreter" ldso
                          crush-target))

                (wrap-program crush-target
                  `("PATH" ":" prefix
                    ,(list (string-append #$bash-minimal "/bin")
                           (string-append #$coreutils-minimal "/bin")
                           (string-append #$git "/bin")
                           (string-append #$go "/bin"))))

                (mkdir-p (string-append share "/bash-completion/completions"))
                (copy-file "etc/bash_completion.d/crush"
                           (string-append share "/bash-completion/completions/crush"))

                (mkdir-p (string-append share "/fish/vendor_completions.d"))
                (copy-file "usr/share/fish/vendor_completions.d/crush.fish"
                           (string-append share "/fish/vendor_completions.d/crush.fish"))

                (mkdir-p (string-append share "/zsh/site-functions"))
                (copy-file "usr/share/zsh/site-functions/_crush"
                           (string-append share "/zsh/site-functions/_crush"))

                (mkdir-p (string-append share "/man/man1"))
                (copy-file "usr/share/man/man1/crush.1.gz"
                           (string-append share "/man/man1/crush.1.gz"))))))))
    (native-inputs (list patchelf binutils))
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
;;; Same approach as reasonix-desktop-bin: do not patchelf the giant
;;; binary, instead launch it via the Guix ld-linux wrapper with a
;;; --library-path assembled from every input's /lib.  WebKitGTK,
;;; libsoup, javascriptcore and the rest come transitively from
;;; webkitgtk-for-gtk3.

(define-public github-copilot
  (package
    (name "github-copilot")
    (version "1.1.14")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/github/app/releases/download/"
             "v" version "/GitHub-Copilot-linux-x64.deb"))
       (sha256
        (base32 "1l02w23nz5bybv67sc9365i36zl2v9v6clsh9dz8q9v3afsjbb6j"))))
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
    (version "0.8.2")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/ogulcancelik/herdr/releases/download/"
             "v" version "/herdr-linux-x86_64"))
       (sha256
        (base32 "1x7cda775xin16wjs63bwc97zdnzn9z1lbpa8fr983299nhm0qcp"))))
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
              ;; The source is a raw ELF, not an archive: copy it in
              ;; place and restore the executable bit.
              (copy-file #$source "herdr")
              (chmod "herdr" #o755)))
          (replace 'install
            (lambda _
              (let ((bin (string-append #$output "/bin")))
                (mkdir-p bin)
                (install-file "herdr" bin)))))))
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

(define-public opencode-desktop-bin
  (package
    (name "opencode-desktop-bin")
    (version "1.18.25")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/anomalyco/opencode/releases/download/"
             "v" version "/opencode-desktop-linux-amd64.deb"))
       (sha256
        (base32 "0ar1v3iad9l4bpmrb52lms1qdlnskf1f39jj5fb6ndbzk8bri49i"))))
    (build-system gnu-build-system)
    (arguments
     (list
      #:tests? #f
      #:validate-runpath? #f
      #:strip-binaries? #f
      #:modules '((guix build gnu-build-system)
                  (guix build utils)
                  (ice-9 ftw)
                  (ice-9 regex)
                  (srfi srfi-26))
      #:phases
      #~(modify-phases %standard-phases
          (delete 'configure)
          (delete 'build)
          (replace 'unpack
            (lambda _
              (invoke "ar" "x" #$source)
              (invoke "tar" "xf" "data.tar.xz")))
          (replace 'install
            (lambda _
              (let ((out #$output))
                (copy-recursively "opt/OpenCode"
                                  (string-append out "/lib/opencode-desktop"))
                #t)))
          (add-after 'install 'disable-electron-updater
            #$(disable-electron-updater-phase "opencode-desktop"))
          (add-after 'install 'patch-elf
            (lambda* (#:key inputs #:allow-other-keys)
              (let* ((ld.so (string-append #$(this-package-input "glibc")
                                           #$(glibc-dynamic-linker)))
                     (rpath (string-join
                             (cons* (string-append #$output "/lib/opencode-desktop")
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
                          (append (find-files (string-append #$output
                                                             "/lib/opencode-desktop")
                                              ".*\\.so(\\.[0-9]+)?$")
                                  (map (lambda (binary)
                                         (string-append #$output
                                                        "/lib/opencode-desktop/"
                                                        binary))
                                       '("ai.opencode.desktop"
                                         "chrome_crashpad_handler"
                                         "chrome-sandbox")))))))
          (add-after 'patch-elf 'install-bin
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
                   (find-files icon-dst "ai\\.opencode\\.desktop\\.png$"))))))
          (add-after 'install-icons 'wrap-program
            (lambda* (#:key inputs outputs #:allow-other-keys)
              (let* ((out (assoc-ref outputs "out"))
                     (lib (string-append out "/lib/opencode-desktop"))
                     (mesa-lib (string-append (assoc-ref inputs "mesa") "/lib"))
                     (nss-lib (string-append (assoc-ref inputs "nss") "/lib/nss")))
                (wrap-program (string-append out "/bin/opencode-desktop")
                  `("LD_LIBRARY_PATH" prefix
                    (,lib ,mesa-lib ,nss-lib))
                  `("FONTCONFIG_FILE" =
                    (,(string-append #$(this-package-input "fontconfig-minimal")
                                     "/etc/fonts/fonts.conf")))
                  `("XDG_DATA_DIRS" prefix
                    (,(string-append out "/share")))))))
          (add-after 'wrap-program 'prefer-wayland
            #$(prefer-electron-wayland-phase "opencode-desktop")))))
    (native-inputs (list binutils patchelf tar xz))
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
;;;   - Paseo                  the Electron main executable (GUI entry)
;;;   - resources/bin/paseo    upstream CLI launcher; runs the main binary
;;;                            with ELECTRON_RUN_AS_NODE=1.  Kept internal
;;;                            (not on PATH), matching the upstream .deb,
;;;                            which also leaves it out of /usr/bin.
;;;   - resources/app.asar.unpacked/node_modules/...  native addons
;;;     (node-pty pty.node, sherpa-onnx) in nested directories.  RPATH
;;;     entries therefore include $ORIGIN so addons resolve sibling
;;;     libraries (e.g. sherpa-onnx.node -> libsherpa-onnx-c-api.so)
;;;     without dragging their exact paths into the build recipe.
;;;
;;; License note: this release ships under Apache-2.0 (LICENSE at tag
;;; v0.7.0 is the full Apache text).  v0.6.1 shipped AGPLv3; upstream
;;; relicensed in commit a8734a9 (2026-08-27).

(define-public paseo-bin
  (package
    (name "paseo-bin")
    (version "0.7.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/getpaseo/paseo/releases/download/"
             "v" version "/Paseo-" version "-amd64.deb"))
       (sha256
        (base32 "0bn4b0i1qrpl15y1q1072da4qzw7b2ql7986nqn5p2clca5wb691"))))
    (build-system gnu-build-system)
    (arguments
     (list
      #:tests? #f
      #:validate-runpath? #f
      #:strip-binaries? #f
      #:modules '((guix build gnu-build-system)
                  (guix build utils)
                  (ice-9 ftw)
                  (ice-9 regex)
                  (srfi srfi-26))
      #:phases
      #~(modify-phases %standard-phases
          (delete 'configure)
          (delete 'build)
          (replace 'unpack
            (lambda _
              (invoke "ar" "x" #$source)
              (invoke "tar" "xf" "data.tar.xz")))
          (replace 'install
            (lambda _
              (copy-recursively "opt/Paseo"
                                (string-append #$output "/lib/paseo"))
              #t))
          (add-after 'install 'disable-electron-updater
            #$(disable-electron-updater-phase "paseo"))
          (add-after 'disable-electron-updater 'patch-cli-shebang
            (lambda* (#:key inputs #:allow-other-keys)
              (substitute* (string-append #$output
                                         "/lib/paseo/resources/bin/paseo")
                (("#!/bin/sh")
                 (string-append "#!"
                                (search-input-file inputs
                                                   "bin/bash"))))))
          (add-after 'patch-cli-shebang 'patch-elf
            (lambda* (#:key inputs #:allow-other-keys)
              (let* ((ld.so (string-append #$(this-package-input "glibc")
                                           #$(glibc-dynamic-linker)))
                     (rpath (string-join
                             (cons* "$ORIGIN"
                                    (string-append #$output "/lib/paseo")
                                    (map (lambda (input)
                                           (string-append (cdr input) "/lib"))
                                         inputs))
                             ":")))
                (define (patch-elf file patch-interp?)
                  (format #t "Patching ~a ..." file)
                  (when patch-interp?
                    (invoke "patchelf" "--set-interpreter" ld.so file))
                  (invoke "patchelf" "--set-rpath" rpath file)
                  (display " done\n"))
                ;; Electron executables get a new interpreter; shared
                ;; libraries and .node addons have no PT_INTERP and only
                ;; get RPATH.
                (for-each (lambda (file) (patch-elf file #t))
                          (map (lambda (binary)
                                 (string-append #$output "/lib/paseo/"
                                                binary))
                               '("Paseo"
                                 "chrome_crashpad_handler"
                                 "chrome-sandbox")))
                (for-each (lambda (file) (patch-elf file #f))
                          (append (find-files (string-append #$output
                                                             "/lib/paseo")
                                              ".*\\.so(\\.[0-9]+)?$")
                                  (find-files (string-append #$output
                                                             "/lib/paseo")
                                              ".*\\.node$"))))))
          (add-after 'patch-elf 'install-bin
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
          (add-after 'install-icons 'wrap-program
            (lambda* (#:key inputs outputs #:allow-other-keys)
              (let* ((out (assoc-ref outputs "out"))
                     (lib (string-append out "/lib/paseo"))
                     (mesa-lib (string-append (assoc-ref inputs "mesa")
                                              "/lib"))
                     (nss-lib (string-append (assoc-ref inputs "nss")
                                             "/lib/nss")))
                (wrap-program (string-append out "/bin/paseo")
                  `("LD_LIBRARY_PATH" prefix
                    (,lib ,mesa-lib ,nss-lib))
                  `("FONTCONFIG_FILE" =
                    (,(string-append
                       #$(this-package-input "fontconfig-minimal")
                       "/etc/fonts/fonts.conf")))
                  `("XDG_DATA_DIRS" prefix
                    (,(string-append out "/share")))))))
          (add-after 'wrap-program 'prefer-wayland
            ;; Paseo's argv parser rejects injected --ozone-platform flags
            ;; ("error: unknown option"), so use the env-hint variant.
            #$(prefer-electron-wayland-hint-phase "paseo")))))
    (native-inputs (list binutils patchelf tar xz))
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
    (version "1.35.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/esengine/DeepSeek-Reasonix/releases/download/"
             "v" version "/reasonix-linux-amd64.tar.gz"))
       (sha256
        (base32 "0bssp6agg7k44l3xdqhl4xwxppj4qmdwh4j27i57y6wl0k0gb9rn"))))
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
          (replace 'install
            (lambda _
              (let ((bin (string-append #$output "/bin")))
                (mkdir-p bin)
                (install-file "reasonix" bin)))))))
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


(define-public reasonix-desktop-bin
  (package
    (name "reasonix-desktop-bin")
    (version "1.35.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/esengine/DeepSeek-Reasonix/releases/download/"
             "desktop-v" version "/Reasonix-linux-amd64.deb"))
       (sha256
        (base32 "1zn9lyr3bf3j5s3psvf56yvph4yca9y553d1hjjc2chwqaxjpj6a"))))
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
              (invoke "tar" "xzf" "data.tar.gz")))
          (replace 'install
            (lambda* (#:key inputs #:allow-other-keys)
              (let* ((out #$output)
                     (libexec (string-append out "/libexec/reasonix-desktop"))
                     (bin (string-append out "/bin"))
                     (ld.so (string-append (assoc-ref inputs "glibc")
                                           #$(glibc-dynamic-linker)))
                     (lib-path (string-join
                                (map (lambda (input)
                                       (string-append (cdr input) "/lib"))
                                     inputs)
                                ":"))
                     (glib-lib (string-append (assoc-ref inputs "glib") "/lib"))
                     (gtk-lib (string-append (assoc-ref inputs "gtk+") "/lib"))
                     (gtk-share (string-append (assoc-ref inputs "gtk+") "/share"))
                     (webkitgtk-lib
                      (string-append
                       (assoc-ref inputs "webkitgtk-for-gtk3") "/lib"))
                     (webkitgtk-share
                      (string-append
                       (assoc-ref inputs "webkitgtk-for-gtk3") "/share"))
                     (gdk-pixbuf (assoc-ref inputs "gdk-pixbuf")))
                (mkdir-p libexec)
                (copy-file "usr/bin/reasonix-desktop"
                           (string-append libexec "/reasonix-desktop"))
                (chmod (string-append libexec "/reasonix-desktop") #o755)
                (mkdir-p bin)
                (with-output-to-file (string-append bin "/reasonix-desktop")
                  (lambda ()
                    (display
                     (string-append
                      "#!" #$(this-package-input "bash-minimal") "/bin/sh\n"
                      "export FONTCONFIG_FILE="
                      #$(this-package-input "fontconfig-minimal")
                      "/etc/fonts/fonts.conf\n"
                      "export XDG_DATA_DIRS=" out "/share:" gtk-share ":"
                      webkitgtk-share
                      "${XDG_DATA_DIRS:+:$XDG_DATA_DIRS}\n"
                      "export GI_TYPELIB_PATH=" glib-lib "/girepository-1.0:"
                      gtk-lib "/girepository-1.0:"
                      webkitgtk-lib "/girepository-1.0:"
                      gdk-pixbuf "/lib/girepository-1.0\n"
                      "export GIO_EXTRA_MODULES=" glib-lib "/gio/modules\n"
                      "exec " ld.so " --argv0 "
                      libexec "/reasonix-desktop"
                      " --library-path " lib-path " " libexec
                      "/reasonix-desktop \"$@\"\n"))))
                (chmod (string-append bin "/reasonix-desktop") #o755))))
          (add-after 'install 'install-desktop-entry
            (lambda _
              (let* ((out #$output)
                     (apps (string-append out "/share/applications"))
                     (pixmaps (string-append out "/share/pixmaps")))
                (mkdir-p apps)
                (mkdir-p pixmaps)
                (copy-file "usr/share/applications/reasonix.desktop"
                           (string-append apps "/reasonix-desktop.desktop"))
                ;; Upstream's desktop entry launches reasonix-launcher, a
                ;; versioning shim that resolves the active build via
                ;; current.json.  That mechanism is irrelevant in the
                ;; immutable Guix store, so point straight at our wrapper.
                (substitute* (string-append apps "/reasonix-desktop.desktop")
                  (("Exec=reasonix-launcher")
                   (string-append "Exec=" out "/bin/reasonix-desktop")))
                (copy-file "usr/share/pixmaps/reasonix-desktop.png"
                           (string-append pixmaps "/reasonix-desktop.png"))))))))
    (native-inputs (list libarchive tar gzip))
    (propagated-inputs (list reasonix-bin))
    (inputs `(("gcc:lib" ,gcc "lib")
              ("bash-minimal" ,bash-minimal)
              ("fontconfig-minimal" ,fontconfig)
              ("glibc" ,glibc)
              ("glib" ,glib)
              ("gtk+" ,gtk+)
              ("gdk-pixbuf" ,gdk-pixbuf)
              ("libsoup" ,libsoup)
              ("mesa" ,mesa)
              ("webkitgtk-for-gtk3" ,webkitgtk-for-gtk3)))
    (home-page "https://github.com/esengine/DeepSeek-Reasonix")
    (synopsis "DeepSeek-native AI coding agent with desktop GUI")
    (description
     "Reasonix is a DeepSeek-native AI coding agent for your terminal,
tuned around DeepSeek's prefix cache so token costs stay low across long
sessions.
This is the desktop version with a graphical interface built with Wails
(Go + WebKitGTK).  It provides a config- and plugin-driven harness with
support for multiple LLM providers.")
    (properties `((upstream-name . "Reasonix") (release-tag-prefix . "^desktop-v")))
    (license license:expat)
    (supported-systems '("x86_64-linux"))))

(define-public zcode
  (package
    (name "zcode")
    (version "3.10.2")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://cdn-zcode.z.ai/zcode/electron/releases/"
             version "/linux-x64/ZCode-" version "-linux-x64.deb"))
       (sha256
        (base32 "1h7hdgfkl3gbjb18j8xv06w9ihj1qif5cl19dqd8lz4g1jkwy65n"))))
    (build-system gnu-build-system)
    (arguments
     (list
      #:tests? #f
      #:validate-runpath? #f
      #:strip-binaries? #f
      #:modules '((guix build gnu-build-system)
                  (guix build utils)
                  (ice-9 ftw)
                  (ice-9 regex)
                  (srfi srfi-26))
      #:phases
      #~(modify-phases %standard-phases
          (delete 'configure)
          (delete 'build)
          (replace 'unpack
            (lambda _
              (invoke "ar" "x" #$source)
              (invoke "tar" "xf" "data.tar.xz")))
          (replace 'install
            (lambda _
              (let ((out #$output))
                (copy-recursively "opt/ZCode"
                                  (string-append out "/lib/zcode"))
                #t)))
          (add-after 'install 'disable-electron-updater
            #$(disable-electron-updater-phase "zcode"))
          (add-after 'install 'patch-elf
            (lambda* (#:key inputs #:allow-other-keys)
              (let* ((ld.so (string-append #$(this-package-input "glibc")
                                           #$(glibc-dynamic-linker)))
                     (rpath (string-join
                             (cons* (string-append #$output "/lib/zcode")
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
                          (append (find-files (string-append #$output
                                                             "/lib/zcode")
                                              ".*\\.so(\\.[0-9]+)?$")
                                  (map (lambda (binary)
                                         (string-append #$output
                                                        "/lib/zcode/"
                                                        binary))
                                       '("zcode"
                                         "chrome_crashpad_handler"
                                         "chrome-sandbox")))))))
          (add-after 'patch-elf 'install-bin
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
                           (find-files icon-dst "zcode\\.png$"))))))
          (add-after 'install-icons 'wrap-program
            (lambda* (#:key inputs outputs #:allow-other-keys)
              (let* ((out (assoc-ref outputs "out"))
                     (lib (string-append out "/lib/zcode"))
                     (mesa-lib (string-append (assoc-ref inputs "mesa") "/lib"))
                     (nss-lib (string-append (assoc-ref inputs "nss") "/lib/nss"))
                     (fontconfig-file (string-append
                                      (assoc-ref inputs "fontconfig-minimal")
                                      "/etc/fonts/fonts.conf")))
                (wrap-program (string-append out "/bin/zcode")
                  `("LD_LIBRARY_PATH" prefix
                    (,lib ,mesa-lib ,nss-lib))
                  `("FONTCONFIG_FILE" =
                    (,fontconfig-file))
                  `("XDG_DATA_DIRS" prefix
                    (,(string-append out "/share")))))))
          (add-after 'wrap-program 'prefer-wayland
            #$(prefer-electron-wayland-phase "zcode")))))
    (native-inputs (list binutils patchelf tar xz))
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

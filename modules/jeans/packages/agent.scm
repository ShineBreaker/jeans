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
    (version "0.84.1")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/charmbracelet/crush/releases/download/"
             "v" version "/crush_" version "_amd64.deb"))
       (sha256
        (base32 "1w4rw4sqkhrdal2lzcdy65w7d4ligr97bryd1jaynlyq8mix014v"))))
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
                           (string-append #$coreutils "/bin")
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
     (list bash-minimal glibc git coreutils go))
    (home-page "https://github.com/charmbracelet/crush")
    (synopsis "AI-powered coding assistant for the CLI")
    (description "Crush is an AI-powered coding assistant that runs in the terminal.
It supports multiple LLM providers, MCP servers, LSP integration, and provides
tools for file editing, shell command execution, web fetching, and more.
This package provides the prebuilt binary release.")
    (license (license:nonfree "https://github.com/charmbracelet/crush/blob/main/LICENSE.md"))))


(define-public opencode-bin
  (package
    (name "opencode-bin")
    (version "1.17.20")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/anomalyco/opencode/releases/download/"
             "v" version "/opencode-linux-x64.tar.gz"))
       (sha256
        (base32 "0r65k7hl2rr3b54bdp2nskxw3zd63513n4lmsljvl3wqs050q45p"))))
    (build-system copy-build-system)
    (arguments
     (list
      #:validate-runpath? #f
      #:strip-binaries? #f
      #:install-plan
      #~'(("opencode" "libexec/opencode"))
      #:phases
      #~(modify-phases %standard-phases
          (delete 'install-license-files)
          (add-after 'unpack 'patch-proc-self-exe
            (lambda _
              ;; Replace /proc/self/exe with /proc/self/ex_ to force Bun
              ;; to fall back to argv[0] for finding the embedded modules.
              (invoke "sed" "-i" "s|/proc/self/exe|/proc/self/ex_|g"
                      "opencode")))
          (add-after 'install 'make-binary-executable
            (lambda _
              (chmod (string-append #$output "/libexec/opencode") #o555)))
          (add-after 'make-binary-executable 'create-wrapper
            (lambda* (#:key inputs #:allow-other-keys)
              (let ((bin (string-append #$output "/bin"))
                    (libexec (string-append #$output "/libexec/opencode"))
                    (ld.so (string-append (assoc-ref inputs "glibc")
                                          #$(glibc-dynamic-linker)))
                    (lib-path (string-join (list (string-append (assoc-ref
                                                                 inputs
                                                                 "glibc")
                                                                "/lib")
                                                 (string-append (assoc-ref
                                                                 inputs "gcc:lib")
                                                                "/lib")) ":")))
                (mkdir-p bin)
                (call-with-output-file (string-append bin "/opencode")
                  (lambda (port)
                    (format port
                            "#!~a\nexec ~a --argv0 ~a --library-path ~a ~a \"$@\"\n"
                            #$(file-append bash-minimal "/bin/sh")
                            ld.so
                            libexec
                            lib-path
                            libexec)))
                (chmod (string-append bin "/opencode") #o755)))))))
    (native-inputs (list sed))
    (inputs `(("bash-minimal" ,bash-minimal)
              ("glibc" ,glibc)
              ("gcc:lib" ,gcc "lib")))
    (home-page "https://opencode.ai")
    (synopsis "The open source AI coding agent.")
    (description "OpenCode is an open source agent that helps you
 write code in your terminal.")
    (license license:expat)))


;;; MiMoCode: Xiaomi's terminal-native AI coding agent.
;;;
;;; MiMoCode is a fork of opencode, shipped as a single Bun-compiled
;;; ELF binary embedding the JS/TS code and the Bun runtime.  The
;;; linkage and /proc/self/exe behaviour are identical to opencode-bin,
;;; so this package mirrors its copy-build-system + ld-linux wrapper
;;; strategy.

(define-public mimocode-bin
  (package
    (name "mimocode-bin")
    (version "0.1.5")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/XiaomiMiMo/MiMo-Code/releases/download/"
             "v" version "/mimocode-linux-x64.tar.gz"))
       (sha256
        (base32 "1mv3falwr98hnb5qc7kx64fkqy2zy6p955a90wpy97gdai5ffmx9"))))
    (build-system copy-build-system)
    (arguments
     (list
      #:validate-runpath? #f
      #:strip-binaries? #f
      #:install-plan
      #~'(("mimo" "libexec/mimocode"))
      #:phases
      #~(modify-phases %standard-phases
          (delete 'install-license-files)
          (add-after 'unpack 'patch-proc-self-exe
            (lambda _
              ;; Replace /proc/self/exe with /proc/self/ex_ to force Bun
              ;; to fall back to argv[0] for finding the embedded modules.
              (invoke "sed" "-i" "s|/proc/self/exe|/proc/self/ex_|g"
                      "mimo")))
          (add-after 'install 'make-binary-executable
            (lambda _
              (chmod (string-append #$output "/libexec/mimocode") #o555)))
          (add-after 'make-binary-executable 'create-wrapper
            (lambda* (#:key inputs #:allow-other-keys)
              (let ((bin (string-append #$output "/bin"))
                    (libexec (string-append #$output "/libexec/mimocode"))
                    (ld.so (string-append (assoc-ref inputs "glibc")
                                          #$(glibc-dynamic-linker)))
                    (lib-path (string-join (list (string-append (assoc-ref
                                                                 inputs
                                                                 "glibc")
                                                                "/lib")
                                                 (string-append (assoc-ref
                                                                 inputs "gcc:lib")
                                                                "/lib")) ":")))
                (mkdir-p bin)
                (call-with-output-file (string-append bin "/mimocode")
                  (lambda (port)
                    (format port
                            "#!~a\nexec ~a --argv0 ~a --library-path ~a ~a \"$@\"\n"
                            #$(file-append bash-minimal "/bin/sh")
                            ld.so
                            libexec
                            lib-path
                            libexec)))
                (chmod (string-append bin "/mimocode") #o755)))))))
    (native-inputs (list sed))
    (inputs `(("bash-minimal" ,bash-minimal)
              ("glibc" ,glibc)
              ("gcc:lib" ,gcc "lib")))
    (home-page "https://mimo.xiaomi.com/coder")
    (synopsis "Terminal-native AI coding agent from Xiaomi")
    (description "MiMoCode is a terminal-native AI coding assistant.  It can
read and write code, run commands, manage Git, and use a persistent memory
system to keep a deep understanding of your project across sessions while
continuously improving itself.  MiMo Auto is built in as a free channel, and
MiMoCode also supports connecting to any mainstream LLM provider API.  This
package provides the prebuilt binary release.")
    (license license:expat)
    (supported-systems '("x86_64-linux"))))

;;; Open Interpreter (Rust edition): prebuilt musl package.
;;;
;;; The upstream tarball bundles:
;;;   bin/interpreter, bin/i            ; main static-musl ELF (identical content)
;;;   codex-path/rg                     ; bundled ripgrep (static-musl)
;;;   codex-resources/bwrap             ; bundled bubblewrap (static-musl)
;;;   codex-resources/zsh/bin/zsh       ; bundled sandbox shell — DYNAMICALLY linked,
;;;                                     ;   needs /lib64/ld-linux-x86-64.so.2 +
;;;                                     ;   libtinfo.so.6, libm.so.6, libc.so.6
;;;   codex-package.json                ; layout manifest (entrypoint = bin/interpreter)
;;;
;;; Strategy: install the whole tree under lib/<pkg>/ to preserve the layout the
;;; interpreter expects (it locates rg/zsh/bwrap relative to its own binary), then
;;; symlink the two entry binaries into bin/.  The three static binaries need no
;;; patching; only the bundled zsh is patchelf'd (interpreter + RPATH) and given a
;;; libtinfo.so.6 -> libncursesw.so.6 shim, since Guix ships terminfo symbols inside
;;; libncursesw rather than a separate libtinfo.
(define-public open-interpreter-bin
  (package
    (name "open-interpreter-bin")
    (version "0.0.21")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/openinterpreter/openinterpreter/releases/download/"
             "rust-v" version
             "/open-interpreter-package-x86_64-unknown-linux-musl.tar.gz"))
       (sha256
        (base32 "1z6dggrdxyidzjzm63y2l5crbgx8lfgw7rj37brrckcsgk18hdqg"))))
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
            (lambda* (#:key inputs #:allow-other-keys)
              (let ((dir "open-interpreter-bin"))
                (mkdir dir)
                (with-directory-excursion dir
                  (invoke "tar" "xzf" #$source))
                (chdir dir))))
          (replace 'install
            (lambda* (#:key inputs outputs #:allow-other-keys)
              (let* ((out (assoc-ref outputs "out"))
                     (bindir (string-append out "/bin"))
                     (pkgdir (string-append out "/lib/open-interpreter-bin"))
                     (patchelf-bin
                      (string-append (assoc-ref inputs "patchelf")
                                     "/bin/patchelf"))
                     (ldso (string-append (assoc-ref inputs "glibc")
                                          "/lib/ld-linux-x86-64.so.2"))
                     ;; RPATH for the bundled zsh: glibc (ld-linux, libc, libm)
                     ;; and ncurses (terminfo symbols live in libncursesw).
                     (rpath
                      (string-join
                       (list (string-append (assoc-ref inputs "glibc") "/lib")
                             (string-append (assoc-ref inputs "ncurses") "/lib"))
                       ":")))
                ;; Install the whole tree verbatim so the interpreter can
                ;; locate its resources (rg, zsh, bwrap) by relative path.
                (mkdir-p pkgdir)
                (copy-recursively "." pkgdir)

                ;; Provide libtinfo.so.6 for the bundled zsh.  Guix's ncurses
                ;; folds terminfo into libncursesw, so a SONAME shim suffices
                ;; (a "no version information available" warning at runtime is
                ;; benign — the loader resolves the unversioned symbols).
                (let* ((zsh-lib (string-append pkgdir "/codex-resources/zsh/lib"))
                       (zsh (string-append pkgdir "/codex-resources/zsh/bin/zsh")))
                  (mkdir-p zsh-lib)
                  (symlink (string-append (assoc-ref inputs "ncurses")
                                          "/lib/libncursesw.so.6")
                           (string-append zsh-lib "/libtinfo.so.6"))

                  ;; Patch the bundled zsh ELF: set the Guix interpreter and an
                  ;; RPATH that covers the shim above plus glibc and ncurses.
                  (invoke patchelf-bin "--set-interpreter" ldso zsh)
                  (invoke patchelf-bin "--set-rpath"
                          (string-append zsh-lib ":" rpath) zsh))

                ;; Expose the two entry binaries (identical content) in bin/.
                (mkdir-p bindir)
                (symlink (string-append pkgdir "/bin/interpreter")
                         (string-append bindir "/interpreter"))
                (symlink (string-append pkgdir "/bin/i")
                         (string-append bindir "/i"))))))))
    (native-inputs (list patchelf))
    (inputs
     `(("glibc" ,glibc)
       ("ncurses" ,ncurses)))
    (home-page "https://github.com/openinterpreter/openinterpreter")
    (synopsis "AI coding agent that runs code on your machine")
    (description "Open Interpreter is an AI agent that writes and runs code
locally to accomplish tasks.  The Rust edition is a fast, self-contained
rewrite that bundles a sandboxed shell (zsh), ripgrep and bubblewrap in its
package layout so it can execute commands and search files without external
runtime dependencies.  This package installs the official prebuilt musl
release verbatim and only patches the bundled zsh to run under Guix.")
    (license license:asl2.0)
    (supported-systems '("x86_64-linux"))))

(define-public opencode-desktop-bin
  (package
    (name "opencode-desktop-bin")
    (version "1.17.20")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/anomalyco/opencode/releases/download/"
             "v" version "/opencode-desktop-linux-amd64.deb"))
       (sha256
        (base32 "06llqf8ana3ypawk4dnb1pay2q48jgn3r4wjw2mfkhb6hgwbvi79"))))
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
                     (exe (string-append out "/lib/opencode-desktop/ai.opencode.desktop")))
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
                    (,(string-append out "/share"))))))))))
    (native-inputs (list binutils patchelf tar xz))
    (inputs `(("alsa-lib" ,alsa-lib)
              ("at-spi2-core" ,at-spi2-core)
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
    (home-page "https://opencode.ai")
    (synopsis "AI coding agent desktop application")
    (description
     "OpenCode is a terminal-based AI coding agent with a desktop GUI built
with Electron.  It supports multiple LLM providers and offers an interactive
coding experience with context awareness.")
    (license license:expat)))


;;; Orca (orca-ide): AI orchestrator desktop app for parallel agentic
;;; development, shipping a prebuilt Electron .deb for x86_64.
;;;
;;; The upstream .deb bundles a Chromium-based Electron app under opt/Orca
;;; with a single 216 MB `orca-ide' ELF plus bundled .so files (libEGL,
;;; libGLESv2, libffmpeg, libvulkan, ...).  Same packaging approach as
;;; opencode-desktop-bin: unpack the .deb with ar/tar, copy the tree into
;;; lib/orca-ide, patchelf the interpreter + rpath, wrap LD_LIBRARY_PATH.

(define-public orca-ide-bin
  (package
    (name "orca-ide-bin")
    (version "1.4.138")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/stablyai/orca/releases/download/"
             "v" version "/orca-ide_" version "_amd64.deb"))
       (sha256
        (base32 "1p36vvm4lqa365v5p5mr1cqcgiyk0828cpvvinbybfszalgz8g6j"))))
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
                (copy-recursively "opt/Orca"
                                  (string-append out "/lib/orca-ide"))
                #t)))
          (add-after 'install 'patch-elf
            (lambda* (#:key inputs #:allow-other-keys)
              (let* ((ld.so (string-append #$(this-package-input "glibc")
                                           #$(glibc-dynamic-linker)))
                     (rpath (string-join
                             (cons* (string-append #$output "/lib/orca-ide")
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
                                                             "/lib/orca-ide")
                                              ".*\\.so(\\.[0-9]+)?$")
                                  (map (lambda (binary)
                                         (string-append #$output
                                                        "/lib/orca-ide/"
                                                        binary))
                                       '("orca-ide"
                                         "chrome_crashpad_handler"
                                         "chrome-sandbox"
                                         "resources/agent-browser-linux-x64")))))))
          (add-after 'patch-elf 'install-bin
            (lambda _
              (let* ((out #$output)
                     (bin (string-append out "/bin"))
                     (exe (string-append out "/lib/orca-ide/orca-ide")))
                (mkdir-p bin)
                (symlink exe (string-append bin "/orca-ide")))))
          (add-after 'install-bin 'install-desktop
            (lambda _
              (let* ((out #$output)
                     (apps (string-append out "/share/applications")))
                (mkdir-p apps)
                (make-desktop-entry-file
                 (string-append apps "/orca-ide.desktop")
                 #:name "Orca"
                 #:type "Application"
                 #:comment #$(package-synopsis this-package)
                 #:exec (string-append #$output "/bin/orca-ide %U")
                 #:icon "orca-ide"
                 #:categories '("Development")
                 #:mime-type '("x-scheme-handler/orca")
                 #:startup-w-m-class "orca"))))
          (add-after 'install-desktop 'install-icons
            (lambda _
              (let* ((out #$output)
                     (icon-src "usr/share/icons/hicolor")
                     (icon-dst (string-append out "/share/icons/hicolor")))
                (when (file-exists? icon-src)
                  (copy-recursively icon-src icon-dst)))))
          (add-after 'install-icons 'wrap-program
            (lambda* (#:key inputs outputs #:allow-other-keys)
              (let* ((out (assoc-ref outputs "out"))
                     (lib (string-append out "/lib/orca-ide"))
                     (mesa-lib (string-append (assoc-ref inputs "mesa") "/lib"))
                     (nss-lib (string-append (assoc-ref inputs "nss") "/lib/nss")))
                (wrap-program (string-append out "/bin/orca-ide")
                  `("LD_LIBRARY_PATH" prefix
                    (,lib ,mesa-lib ,nss-lib))
                  `("FONTCONFIG_FILE" =
                    (,(string-append #$(this-package-input "fontconfig-minimal")
                                     "/etc/fonts/fonts.conf")))
                  `("XDG_DATA_DIRS" prefix
                    (,(string-append out "/share"))))))))))
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
    (home-page "https://onorca.dev")
    (synopsis "AI orchestrator desktop app for parallel agentic development")
    (description
     "Orca is an AI orchestrator desktop application built with Electron.  It
runs coding agents such as Codex, Claude Code, OpenCode and Pi side-by-side,
each in its own git worktree, with progress tracked in a single unified
interface.  Features include a mobile companion app, parallel worktrees and
agent orchestration.")
    (license license:expat)
    (supported-systems '("x86_64-linux"))))


;;; oh-my-pi (OMP): prebuilt AI coding agent with IDE integration.
;;;
;;; The upstream release is a single self-contained ELF binary (~530 MB)
;;; that embeds a Bun runtime, native Rust addons, and all JS/TS code.
;;; It is dynamically linked but has zero NEEDED entries — only the
;;; ELF interpreter (/lib64/ld-linux-x86-64.so.2) must be redirected.
;;;
;;; Strategy: copy binary to libexec/, create a bin/ wrapper that
;;; invokes it through Guix's ld-linux (same pattern as opencode-bin).

(define-public oh-my-pi-bin
  (package
    (name "oh-my-pi-bin")
    (version "16.5.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/can1357/oh-my-pi/releases/download/"
             "v" version "/omp-linux-x64"))
       (sha256
        (base32 "103aq1x6ifj4nnnr5nda5hwq1cdag9qpmm0hzwls02pykrj2m207"))))
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
              (copy-file #$source "omp")
              (chmod "omp" #o755)))
          (replace 'install
            (lambda* (#:key inputs #:allow-other-keys)
              (let* ((out #$output)
                     (bin (string-append out "/bin"))
                     (libexec (string-append out "/libexec"))
                     (ld.so (string-append (assoc-ref inputs "glibc")
                                           #$(glibc-dynamic-linker)))
                     (lib-path (string-join
                                (list (string-append (assoc-ref inputs "glibc") "/lib")
                                      (string-append (assoc-ref inputs "gcc:lib") "/lib"))
                                ":")))
                (mkdir-p libexec)
                (install-file "omp" libexec)
                (mkdir-p bin)
                (call-with-output-file (string-append bin "/omp")
                  (lambda (port)
                    (format port
                            "#!~a\nexec ~a --argv0 ~a/omp --library-path ~a ~a/omp \"$@\"\n"
                            #$(file-append bash-minimal "/bin/sh")
                            ld.so
                            libexec
                            lib-path
                            libexec)))
                (chmod (string-append bin "/omp") #o755)))))))
    (inputs `(("bash-minimal" ,bash-minimal)
              ("glibc" ,glibc)
              ("gcc:lib" ,gcc "lib")))
    (home-page "https://omp.sh")
    (synopsis "AI coding agent with IDE integration")
    (description "oh-my-pi (OMP) is a coding agent with deep IDE integration,
featuring support for 40+ AI providers, 32 built-in tools, 13 LSP operations,
27 DAP operations, subagents, web search, browser automation, and more.
It is a fork of the Pi project by Mario Zechner, extended with
batteries-included coding workflow features.  This package provides
the prebuilt binary release.")
    (license license:expat)
    (supported-systems '("x86_64-linux"))))


;;; kimi-code: Moonshot AI's terminal-native AI coding agent.
;;;
;;; The upstream release is a single Node.js Single Executable
;;; Application (SEA) ELF (~157 MB) embedding the Node runtime and all
;;; JS/TS code, shipped inside a zip archive.  It is dynamically linked
;;; against glibc/gcc and embeds a node-pty native addon for PTY-based
;;; tool execution (loaded via dlopen at runtime, hence the gcc:lib
;;; dependency even though it has no RPATH).
;;;
;;; Strategy: unzip the binary to libexec/, create a bin/ wrapper that
;;; invokes it through Guix's ld-linux (same pattern as oh-my-pi-bin).

(define-public kimi-code-bin
  (package
    (name "kimi-code-bin")
    (version "0.23.6")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/MoonshotAI/kimi-code/releases/download/"
             "%40moonshot-ai%2Fkimi-code%40" version
             "/kimi-code-linux-x64.zip"))
       (sha256
        (base32 "134fh1qkv1gw25kl3m3ajmb9qmig1h65f8qlvyaqqz368jnhrcrq"))))
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
              (invoke "unzip" #$source)
              (chmod "kimi" #o755)))
          (replace 'install
            (lambda* (#:key inputs #:allow-other-keys)
              (let* ((out #$output)
                     (bin (string-append out "/bin"))
                     (libexec (string-append out "/libexec"))
                     (ld.so (string-append (assoc-ref inputs "glibc")
                                           #$(glibc-dynamic-linker)))
                     (lib-path (string-join
                                (list (string-append (assoc-ref inputs "glibc") "/lib")
                                      (string-append (assoc-ref inputs "gcc:lib") "/lib"))
                                ":")))
                (mkdir-p libexec)
                (install-file "kimi" libexec)
                (mkdir-p bin)
                (call-with-output-file (string-append bin "/kimi")
                  (lambda (port)
                    (format port
                            "#!~a\nexec ~a --argv0 ~a/kimi --library-path ~a ~a/kimi \"$@\"\n"
                            #$(file-append bash-minimal "/bin/sh")
                            ld.so
                            libexec
                            lib-path
                            libexec)))
                (chmod (string-append bin "/kimi") #o755)))))))
    (native-inputs (list unzip))
    (inputs `(("bash-minimal" ,bash-minimal)
              ("glibc" ,glibc)
              ("gcc:lib" ,gcc "lib")))
    (home-page "https://github.com/MoonshotAI/kimi-code")
    (synopsis "Terminal-native AI coding agent from Moonshot AI")
    (description "Kimi Code is a terminal-native AI coding agent.  It can read
and write code, execute shell commands, retrieve files and fetch web pages,
and autonomously decide the next step based on feedback.  It works with the
Kimi model from Moonshot AI out of the box and can also target other
compatible providers.  This package provides the prebuilt binary release.")
    (license license:expat)
    (supported-systems '("x86_64-linux"))))


;;; CodeWhale: multi-provider AI coding agent for the terminal (Rust).
;;;
;;; The upstream tar.gz ships three statically-linked (static-pie) Rust
;;; ELF binaries with no interpreter and no NEEDED entries:
;;;   - codewhale      ; the entrypoint launcher
;;;   - codewhale-tui  ; the interactive TUI runtime
;;;   - codew          ; short alias of codewhale
;;;
;;; Being fully static, no patchelf or ld-linux wrapper is needed — just
;;; unpack the archive, restore the executable bit (the tarball stores the
;;; binaries as 0644) and install all three into bin/.

(define-public codewhale-bin
  (package
    (name "codewhale-bin")
    (version "0.8.67")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/Hmbown/CodeWhale/releases/download/"
             "v" version "/codewhale-linux-x64.tar.gz"))
       (sha256
        (base32 "1j6fd44hk7kyqa7vpkw37fzyx356kbchdsxff5kzqnl8nk8himgw"))))
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
              ;; The archive stores the three binaries as 0644; restore the
              ;; executable bit so install-file (and the user) can run them.
              (for-each (lambda (b) (chmod b #o755))
                        '("codewhale-linux-x64/codewhale"
                          "codewhale-linux-x64/codewhale-tui"
                          "codewhale-linux-x64/codew"))))
          (replace 'install
            (lambda _
              (let ((bin (string-append #$output "/bin")))
                (mkdir-p bin)
                (for-each (lambda (b)
                            (install-file b bin))
                          '("codewhale-linux-x64/codewhale"
                            "codewhale-linux-x64/codewhale-tui"
                            "codewhale-linux-x64/codew"))))))))
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


;;; Reasonix: DeepSeek-native AI coding agent (Go static binary).
;;;
;;; The upstream tar.gz ships a single statically-linked Go ELF binary:
;;;   - reasonix       (CGO_ENABLED=0, no interpreter, no NEEDED)
;;;
;;; No patchelf or ld-linux wrapper needed — just extract and install.

(define-public reasonix-bin
  (package
    (name "reasonix-bin")
    (version "1.17.12")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/esengine/DeepSeek-Reasonix/releases/download/"
             "v" version "/reasonix-linux-amd64.tar.gz"))
       (sha256
        (base32 "0chx6qyzd0b6cw8n2n4kq86c6jnj8xgz07xbv9f1lkp243wi90wz"))))
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
designed around DeepSeek's prefix cache to keep token costs low across long sessions.
It supports multi-model composition, external tools via MCP-compatible JSON-RPC,
and ships as a single static binary with no runtime dependencies.")
    (license license:expat)
    (supported-systems '("x86_64-linux"))))


(define-public reasonix-desktop-bin
  (package
    (name "reasonix-desktop-bin")
    (version "1.17.12")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/esengine/DeepSeek-Reasonix/releases/download/"
             "desktop-v" version "/Reasonix-linux-amd64.deb"))
       (sha256
        (base32 "1qdz7q9hc63sxhaigx9s6krf6hbcwkcyi5ximwvd1dpfvvym2g6d"))))
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
                     (webkitgtk-lib (string-append (assoc-ref inputs "webkitgtk-for-gtk3")
                                                   "/lib"))
                     (webkitgtk-share (string-append (assoc-ref inputs "webkitgtk-for-gtk3")
                                                     "/share"))
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
                      "export FONTCONFIG_FILE=" #$(this-package-input "fontconfig-minimal") "/etc/fonts/fonts.conf\n"
                      "export XDG_DATA_DIRS=" out "/share:" gtk-share ":" webkitgtk-share "${XDG_DATA_DIRS:+:$XDG_DATA_DIRS}\n"
                      "export GI_TYPELIB_PATH=" glib-lib "/girepository-1.0:"
                      gtk-lib "/girepository-1.0:"
                      webkitgtk-lib "/girepository-1.0:"
                      gdk-pixbuf "/lib/girepository-1.0\n"
                      "export GIO_EXTRA_MODULES=" glib-lib "/gio/modules\n"
                      "exec " ld.so " --argv0 " libexec "/reasonix-desktop"
                      " --library-path " lib-path " " libexec "/reasonix-desktop \"$@\"\n"))))
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
                (substitute* (string-append apps "/reasonix-desktop.desktop")
                  (("Exec=reasonix-desktop")
                   (string-append "Exec=" out "/bin/reasonix-desktop")))
                (copy-file "usr/share/pixmaps/reasonix-desktop.png"
                           (string-append pixmaps "/reasonix-desktop.png"))))))))
    (native-inputs (list libarchive tar gzip))
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
tuned around DeepSeek's prefix cache so token costs stay low across long sessions.
This is the desktop version with a graphical interface built with Wails
(Go + WebKitGTK).  It provides a config- and plugin-driven harness with
support for multiple LLM providers.")
    (license license:expat)
    (supported-systems '("x86_64-linux"))))


(define-public zcode
  (package
    (name "zcode")
    (version "3.3.5")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://cdn-zcode.z.ai/zcode/electron/releases/"
             version "/ZCode-" version "-linux-x64.deb"))
       (sha256
        (base32 "10nkkd77nxlr6ccp7havpp86f0y5dd7yc6qgpmi497i2ssx51vp8"))))
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
                    (,(string-append out "/share"))))))))))
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
    (synopsis "ZCode Desktop App")
    (description
     "Simple, Fast, Vibe‑Ready ! -- ZCode combines the best AI agents
with your existing tools so you can plan, code, review, and deploy
without friction.")
    (license (license:nonfree "https://zcode.z.ai/"))
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
;;; Same approach as reasonix-desktop-bin: do not patchelf the giant
;;; binary, instead launch it via the Guix ld-linux wrapper with a
;;; --library-path assembled from every input's /lib.  WebKitGTK,
;;; libsoup, javascriptcore and the rest come transitively from
;;; webkitgtk-for-gtk3.

(define-public github-copilot
  (package
    (name "github-copilot")
    (version "1.0.22")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/github/app/releases/download/"
             "v" version "/GitHub-Copilot-linux-x64.deb"))
       (sha256
        (base32 "09a4xqdh5s0ww134mwlw5s6dh599dcf97rp3ga0dhvyr920yvxhg"))))
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

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
    (version "0.81.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/charmbracelet/crush/releases/download/"
             "v" version "/crush_" version "_amd64.deb"))
       (sha256
        (base32 "1919sv1fmkq78pd1291i3csim7j5nmrkmrmkx494xyvmn2k99ajy"))))
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
    (version "1.17.13")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/anomalyco/opencode/releases/download/"
             "v" version "/opencode-linux-x64.tar.gz"))
       (sha256
        (base32 "0j5kkgjy81kgsh41h83b3xx976qi4v3rmq8cvrr9738skllglyhm"))))
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
                                                                 inputs "gcc")
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
    (inputs (list bash-minimal glibc
                  `(,gcc "lib")))
    (home-page "https://opencode.ai")
    (synopsis "The open source AI coding agent.")
    (description "OpenCode is an open source agent that helps you
 write code in your terminal.")
    (license license:expat)))


(define-public opencode-desktop-bin
  (package
    (name "opencode-desktop-bin")
    (version "1.17.13")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/anomalyco/opencode/releases/download/"
             "v" version "/opencode-desktop-linux-amd64.deb"))
       (sha256
        (base32 "06jl20db37fzrp1x723y19wmhmc7l34kzcdy1cxqrsz44rbg1llw"))))
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
    (inputs (list alsa-lib
                  at-spi2-core
                  cups
                  dbus
                  eudev
                  expat
                  fontconfig
                  `(,gcc "lib")
                  glibc
                  glib
                  gtk+
                  libx11
                  libxcb
                  libxcomposite
                  libxdamage
                  libxext
                  libxfixes
                  libxkbcommon
                  libxrandr
                  mesa
                  nss))
    (home-page "https://opencode.ai")
    (synopsis "AI coding agent desktop application")
    (description
     "OpenCode is a terminal-based AI coding agent with a desktop GUI built
with Electron.  It supports multiple LLM providers and offers an interactive
coding experience with context awareness.")
    (license license:expat)))


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
    (version "16.3.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/can1357/oh-my-pi/releases/download/"
             "v" version "/omp-linux-x64"))
       (sha256
        (base32 "0iyvhvi4qbzmmhkim7jcg6rd0j9glyqm7xrx6rw56da86903b8m2"))))
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
                                      (string-append (assoc-ref inputs "gcc") "/lib"))
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
    (inputs (list bash-minimal glibc `(,gcc "lib")))
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


;;; Reasonix: DeepSeek-native AI coding agent (Go static binary).
;;;
;;; The upstream tar.gz ships a single statically-linked Go ELF binary:
;;;   - reasonix       (CGO_ENABLED=0, no interpreter, no NEEDED)
;;;
;;; No patchelf or ld-linux wrapper needed — just extract and install.

(define-public reasonix-bin
  (package
    (name "reasonix-bin")
    (version "1.15.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/esengine/DeepSeek-Reasonix/releases/download/"
             "v" version "/reasonix-linux-amd64.tar.gz"))
       (sha256
        (base32 "1jykv714fkgqhyarp75s7irfdwnlvfygjvgpyfj3mvpz25rkh04q"))))
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
    (version "1.15.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/esengine/DeepSeek-Reasonix/releases/download/"
             "desktop-v" version "/Reasonix-linux-amd64.deb"))
       (sha256
        (base32 "07azhpxvhygazph2drnmfa1308fdpf6q098rlib98haczskfr8h1"))))
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
                      "export XDG_DATA_DIRS=" out "/share:" gtk-share ":" webkitgtk-share "\n"
                      "export GI_TYPELIB_PATH=" glib-lib "/girepository-1.0:"
                      gtk-lib "/girepository-1.0:"
                      webkitgtk-lib "/girepository-1.0:"
                      gdk-pixbuf "/lib/girepository-1.0\n"
                      "export GIO_EXTRA_MODULES=" glib-lib "/gio/modules\n"
                      "export GDK_PIXBUF_MODULE_FILE=" gdk-pixbuf "/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache\n"
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
    (inputs (list `(,gcc "lib")
                  bash-minimal
                  fontconfig
                  glibc
                  glib
                  gtk+
                  gdk-pixbuf
                  libsoup
                  mesa
                  webkitgtk-for-gtk3))
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
    (version "3.2.3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://cdn-zcode.z.ai/zcode/electron/releases/"
             version "/ZCode-" version "-linux-x64.deb"))
       (sha256
        (base32 "1zxhgzmwfqr2jj659sl6nl8gpiag9jb49bbdlv9hj14xcdwib4j2"))))
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
    (inputs (list alsa-lib
                  at-spi2-core
                  cups
                  dbus
                  eudev
                  expat
                  fontconfig
                  `(,gcc "lib")
                  glibc
                  glib
                  gtk+
                  libx11
                  libxcb
                  libxcomposite
                  libxdamage
                  libxext
                  libxfixes
                  libxkbcommon
                  libxrandr
                  mesa
                  nss))
    (home-page "https://zcode.z.ai/")
    (synopsis "ZCode Desktop App")
    (description
     "Simple, Fast, Vibe‑Ready ! -- ZCode combines the best AI agents
with your existing tools so you can plan, code, review, and deploy
without friction.")
    (license (license:nonfree "https://zcode.z.ai/"))
    (supported-systems '("x86_64-linux"))))

;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-only

(define-module (jeans packages tools)
  #:use-module (ice-9 match)
  #:use-module (guix packages)
  #:use-module (guix build-system cargo)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system copy)
  #:use-module (guix build-system gnu)
  #:use-module (guix gexp)
  #:use-module (gnu packages bootstrap)  ; glibc-dynamic-linker
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module ((nonguix licenses) #:prefix license:)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages python)
  #:use-module (gnu packages java)
  #:use-module (gnu packages rdesktop)
  #:use-module (gnu packages gtk)      ; yad, cairo, gdk-pixbuf, pango, at-spi2-core
  #:use-module (gnu packages linux)    ; iproute
  #:use-module (gnu packages admin)    ; netcat-openbsd
  #:use-module (gnu packages gnome)    ; libnotify, libsoup
  #:use-module (gnu packages ncurses)  ; dialog
  #:use-module (gnu packages elf)      ; patchelf
  #:use-module (gnu packages webkit)   ; webkitgtk-for-gtk3
  #:use-module (gnu packages base)     ; binutils (ar)
  #:use-module (gnu packages glib)     ; glib
  #:use-module (gnu packages freedesktop) ; libappindicator
  #:use-module (gnu packages gcc)         ; gcc:lib
  #:use-module (gnu packages rust)        ; rust
  #:use-module (gnu packages tls)          ; openssl
  #:use-module (gnu packages compression) ; xz
  #:use-module (gnu packages version-control) ; git
  #:use-module (gnu packages audio)       ; alsa-lib
  #:use-module (gnu packages curl)        ; curl
  #:use-module (gnu packages fontutils)   ; fontconfig
  #:use-module (gnu packages gl)          ; libglvnd, mesa
  #:use-module (gnu packages xdisorg)     ; libxkbcommon
  #:use-module (gnu packages xorg)        ; libx11, libxcb, libxcursor, libxi
  #:use-module (gnu packages vulkan)      ; vulkan-loader
  #:use-module (gnu packages nss)          ; nss
  #:use-module (gnu packages cups)         ; cups
  #:use-module (gnu packages xml)          ; expat
  #:use-module (gnu packages golang))         ; go

;;; Crush: AI-powered coding assistant (Go TUI binary).
;;;
;;; The upstream .deb ships a single Go ELF binary:
;;;   - crush        (dynamically linked, only needs glibc: libc, libdl, libpthread)
;;;
;;; Patch the ELF interpreter to Guix's ld-linux, then wrap with PATH
;;; so crush can find git and other runtime tools.

(define-public crush-bin
  (package
    (name "crush-bin")
    (version "0.75.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/charmbracelet/crush/releases/download/"
             "v" version "/crush_" version "_amd64.deb"))
       (sha256
        (base32 "1sw7700mnszwgpz3k4liciw6iqn271k083pnj6jfw9jbcqfd5lki"))))
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
                                          "/lib/ld-linux-x86-64.so.2")))
                (mkdir-p bin)
                (install-file "usr/bin/crush" bin)

                (invoke patchelf-bin "--set-interpreter" ldso
                        (string-append bin "/crush"))

                (wrap-program (string-append bin "/crush")
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

(define-public winapps
  (package
    (name "winapps")
    (version "0-unstable-2026-06-02")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/winapps-org/winapps")
             (commit "3c1e7e148703d3ddce375f7a893f669be6e95222")))
       (file-name (git-file-name name version))
       (sha256 (base32 "06axrzlximkhzhns4sdc256wn9l6p726f6x75cvgwr4kkw0j4wfy"))
       (patches (list (local-file (search-path %load-path "jeans/patches/WinApps.patch"))))))
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
          (add-after 'unpack 'patch-paths
            (lambda _
              (substitute* '("bin/winapps" "setup.sh")
                (("@out@") #$output))
              (substitute* "install/inquirer.sh"
                (("#!/bin/bash") (string-append "#!" #$bash "/bin/bash")))))
          (replace 'install
            (lambda _
              (let ((bin (string-append #$output "/bin"))
                    (src (string-append #$output "/src")))
                (mkdir-p bin)
                (mkdir-p src)
                (copy-recursively "." src)
                (install-file "bin/winapps" bin)
                (copy-file "setup.sh" (string-append bin "/winapps-setup"))
                (chmod (string-append bin "/winapps") #o755)
                (chmod (string-append bin "/winapps-setup") #o755)

                (call-with-output-file (string-append bin "/xfreerdp3")
                  (lambda (port)
                    (format port "#!~a/bin/bash~%exec ~a/bin/xfreerdp \"$@\"~%"
                            #$bash #$freerdp-3)))
                (chmod (string-append bin "/xfreerdp3") #o755))))
          (add-after 'install 'wrap-programs
            (lambda _
              (let ((bin (string-append #$output "/bin")))
                (for-each
                 (lambda (prog)
                   (wrap-program (string-append bin "/" prog)
                     `("LIBVIRT_DEFAULT_URI" = ("qemu:///system"))
                     `("PATH" ":" prefix
                       ,(list bin
                              (string-append #$bash "/bin")
                              (string-append #$freerdp-3 "/bin")
                              (string-append #$libnotify "/bin")
                              (string-append #$dialog "/bin")
                              (string-append #$netcat-openbsd "/bin")
                              (string-append #$iproute "/bin")))))
                 '("winapps" "winapps-setup"))))))))
    (inputs
     (list bash freerdp-3 dialog libnotify netcat-openbsd iproute))
    (home-page "https://github.com/winapps-org/winapps")
    (synopsis "Run Windows applications on GNU/Linux")
    (description "Run Windows applications (including Microsoft 365
     and Adobe Creative Cloud) on GNU/Linux with KDE, GNOME or XFCE,
     integrated seamlessly as if they were native to the OS.")
    (license license:agpl3+)))

(define-public jdtls-bin
  (package
    (name "jdtls-bin")
    (version "1.57.0")
    (source
      (origin
        (method url-fetch)
        (uri (string-append
              "https://download.eclipse.org/jdtls/milestones/"
              version
              "/jdt-language-server-"
              version
              "-202602261110.tar.gz"))
        (sha256
          (base32 "07k008iypk0dv9c75dkdwpb85i95rp6rgp8kmifskgmvw4zskzzp"))))
    (build-system gnu-build-system)
    (arguments
      (list
        #:tests? #f
        #:phases
        #~(modify-phases %standard-phases
            (delete 'configure)
            (delete 'build)
            (replace 'unpack
              (lambda _
                (let ((srcdir (string-append "jdtls-" #$version)))
                  (mkdir srcdir)
                  (with-directory-excursion srcdir
                    (invoke "tar" "xzf" #$source))
                  (chdir srcdir))))
            (replace 'install
              (lambda _
                (let ((share (string-append #$output "/share/jdtls")))
                  (mkdir-p share)
                  (for-each
                    (lambda (dir)
                      (when (file-exists? dir)
                        (copy-recursively dir (string-append share "/" dir))))
                    '("bin" "plugins" "features"
                      "config_linux" "config_ss_linux"))
                  (chmod (string-append share "/bin/jdtls") #o755)
                  (wrap-program (string-append share "/bin/jdtls")
                    `("PATH" ":" prefix
                      ,(list (string-append #$openjdk "/bin")
                             (string-append #$python "/bin")))
                    `("JAVA_HOME" = (,(string-append #$openjdk))))
                  (mkdir-p (string-append #$output "/bin"))
                  (symlink (string-append share "/bin/jdtls")
                           (string-append #$output "/bin/jdtls"))))))))
    (inputs (list openjdk python bash))
    (synopsis "Java language server")
    (description "The Eclipse JDT Language Server is a Java language specific implementation of
the Language Server Protocol and can be used with any editor that supports the
protocol, to offer good support for the Java Language.")
    (home-page "https://github.com/eclipse/eclipse.jdt.ls")
    (license license:expat)))

;;; Motrix-Next: prebuilt binary download manager (Tauri/WebKitGTK app).
;;;
;;; The upstream .deb ships two ELF binaries:
;;;   - motrix-next        (Tauri app, dynamically linked to webkit2gtk-4.1, gtk3, etc.)
;;;   - motrix-next-engine (statically linked aria2 RPC helper, renamed from motrixnext-aria2c in v3.9.0)
;;;
;;; Because this is a prebuilt binary compiled on Ubuntu, we must:
;;;   1. Use patchelf to set the ELF interpreter to Guix's ld-linux.
;;;   2. Use patchelf to set RPATH so the binary finds all shared libs in the store.

(define-public motrix-next-bin
  (package
    (name "motrix-next-bin")
    (version "3.9.3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/AnInsomniacy/motrix-next/releases/download/"
             "v" version "/MotrixNext_" version "_amd64.deb"))
       (sha256
        (base32 "0bcvv129nzvrq3j1ka9i3y108lwcgbzh0hqvg1ji7ifi2hl0cadf"))))
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
              (let ((debdir (string-append "motrix-next-" #$version)))
                (mkdir debdir)
                (with-directory-excursion debdir
                  (invoke "ar" "x" #$source)
                  (invoke "tar" "xzf" "data.tar.gz"))
                (chdir debdir))))
          (replace 'install
            (lambda* (#:key inputs #:allow-other-keys)
              (let* ((out #$output)
                     (bin (string-append out "/bin"))
                     (lib-resource (string-append out "/lib/MotrixNext"))
                     (lib-binaries (string-append lib-resource "/binaries"))
                     (share (string-append out "/share"))
                     (patchelf-bin
                      (string-append (assoc-ref inputs "patchelf")
                                     "/bin/patchelf"))
                     (ldso (string-append (assoc-ref inputs "glibc")
                                          "/lib/ld-linux-x86-64.so.2"))
                     (rpath
                      (string-join
                       (map (lambda (pkg)
                              (string-append (assoc-ref inputs pkg) "/lib"))
                             '("webkitgtk-for-gtk3" "gtk+" "glib" "cairo"
                               "gdk-pixbuf" "libsoup" "glibc" "gcc"
                               "libappindicator"))
                       ":")))
                ;; Place the main ELF binary directly in bin/.  wrap-program
                ;; will rename it to .motrix-next-real and create a wrapper
                ;; script.  When the wrapper execs the real binary, /proc/self/exe
                ;; points to bin/.motrix-next-real, so Tauri's resource_dir()
                ;; computes:  exe_dir/../lib/<identifier>/
                ;;           = bin/../lib/MotrixNext/
                ;;           = lib/MotrixNext/          ✅
                (mkdir-p bin)
                (install-file "usr/bin/motrix-next" bin)

                ;; Place the aria2c sidecar in bin/ as well.  Tauri sidecar
                ;; resolution takes the basename of the externalBin entry and
                ;; searches in the executable's directory (exe_dir = bin/).
                (install-file "usr/bin/motrix-next-engine" bin)

                ;; Install aria2.conf into lib/MotrixNext/binaries/.
                ;; Tauri resolves BaseDirectory::Resource to resource_dir()
                ;; (= lib/MotrixNext/), then appends "binaries/aria2.conf".
                (mkdir-p lib-binaries)
                (install-file "usr/lib/MotrixNext/binaries/aria2.conf"
                              lib-binaries)

                ;; Patch ELF interpreter and RPATH for motrix-next.
                (invoke patchelf-bin "--set-interpreter" ldso
                        (string-append bin "/motrix-next"))
                (invoke patchelf-bin "--set-rpath" rpath
                        (string-append bin "/motrix-next"))

                ;; wrap-program renames the real binary to .motrix-next-real
                ;; and creates a bash wrapper that sets env vars before exec.
                (wrap-program (string-append bin "/motrix-next")
                  `("XDG_DATA_DIRS" ":" prefix
                    ,(list (string-append out "/share")
                           (string-append #$gtk+ "/share")
                           (string-append #$glib "/share")
                           (string-append #$gdk-pixbuf "/share"))))

                ;; Install desktop entry.
                (mkdir-p (string-append share "/applications"))
                (copy-file "usr/share/applications/MotrixNext.desktop"
                           (string-append share "/applications/MotrixNext.desktop"))
                (substitute* (string-append share "/applications/MotrixNext.desktop")
                  (("Exec=motrix-next")
                   (string-append "Exec=" bin "/motrix-next")))

                ;; Install icons.
                (for-each
                 (lambda (size-dir)
                   (let ((icon-src
                          (string-append "usr/share/icons/hicolor/"
                                         size-dir "/apps/motrix-next.png"))
                         (icon-dst-dir
                          (string-append share "/icons/hicolor/"
                                         size-dir "/apps")))
                     (when (file-exists? icon-src)
                       (mkdir-p icon-dst-dir)
                       (copy-file icon-src
                                  (string-append icon-dst-dir
                                                 "/motrix-next.png")))))
                 '("32x32" "128x128" "256x256@2"))))))))
     (native-inputs (list patchelf binutils))
     (inputs
      (list bash-minimal
            glibc
            `(,gcc "lib")
            webkitgtk-for-gtk3
            gtk+
            glib
            cairo
            gdk-pixbuf
            libsoup
            libappindicator))
    (home-page "https://github.com/AnInsomniacy/motrix-next")
    (synopsis "Full-featured download manager")
    (description "Motrix-Next is a full-featured download manager that supports
downloading HTTP, FTP, BitTorrent, and Magnet links.  It is built with Tauri
and uses aria2 as the download backend.  This package provides the prebuilt
binary release.")
     (license license:expat)))

;;; CC-Switch: prebuilt binary for AI coding assistant manager (Tauri/WebKitGTK).
;;;
;;; The upstream .deb ships one ELF binary:
;;;   - cc-switch       (Tauri app, dynamically linked to webkit2gtk-4.1, gtk3, etc.)
;;;
;;; Because this is a prebuilt binary compiled on Ubuntu, we must:
;;;   1. Use patchelf to set the ELF interpreter to Guix's ld-linux.
;;;   2. Use patchelf to set RPATH so the binary finds all shared libs in the store.

(define-public cc-switch-bin
  (package
    (name "cc-switch-bin")
    (version "3.16.1")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/farion1231/cc-switch/releases/download/"
             "v" version "/CC-Switch-v" version "-Linux-x86_64.deb"))
       (sha256
        (base32 "0jpny3adri61pcza2pj3pddxzlcgwdhf2y10qqgqbjjs3w7x77dx"))))
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
              (let ((debdir (string-append "cc-switch-" #$version)))
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
                     (rpath
                      (string-join
                       (map (lambda (pkg)
                              (string-append (assoc-ref inputs pkg) "/lib"))
                            '("webkitgtk-for-gtk3" "gtk+" "glib" "cairo"
                              "gdk-pixbuf" "libsoup" "openssl" "xz"
                              "libappindicator" "glibc" "gcc"))
                       ":")))
                (mkdir-p bin)
                (install-file "usr/bin/cc-switch" bin)

                ;; Patch ELF interpreter and RPATH.
                (invoke patchelf-bin "--set-interpreter" ldso
                        (string-append bin "/cc-switch"))
                (invoke patchelf-bin "--set-rpath" rpath
                        (string-append bin "/cc-switch"))

                ;; Wrap program to set XDG_DATA_DIRS.
                (wrap-program (string-append bin "/cc-switch")
                  `("XDG_DATA_DIRS" ":" prefix
                    ,(list (string-append out "/share")
                           (string-append #$gtk+ "/share")
                           (string-append #$glib "/share")
                           (string-append #$gdk-pixbuf "/share"))))

                ;; Install desktop entry.
                (mkdir-p (string-append share "/applications"))
                (copy-file "usr/share/applications/CC Switch.desktop"
                           (string-append share "/applications/CC Switch.desktop"))
                (substitute* (string-append share "/applications/CC Switch.desktop")
                  (("Exec=cc-switch")
                   (string-append "Exec=" bin "/cc-switch")))

                ;; Install icons.
                (for-each
                 (lambda (size-dir)
                   (let ((icon-src
                          (string-append "usr/share/icons/hicolor/"
                                         size-dir "/apps/cc-switch.png"))
                         (icon-dst-dir
                          (string-append share "/icons/hicolor/"
                                         size-dir "/apps")))
                     (when (file-exists? icon-src)
                       (mkdir-p icon-dst-dir)
                       (copy-file icon-src
                                  (string-append icon-dst-dir
                                                 "/cc-switch.png")))))
                 '("32x32" "128x128" "256x256@2"))))))))
     (native-inputs (list patchelf binutils))
     (inputs
      (list bash-minimal
            glibc
            `(,gcc "lib")
            webkitgtk-for-gtk3
            gtk+
            glib
            cairo
            gdk-pixbuf
            libsoup
            openssl
            xz
            libappindicator))
     (home-page "https://github.com/farion1231/cc-switch")
     (synopsis "All-in-One assistant for Claude Code, Codex & Gemini CLI")
     (description "CC-Switch is a desktop application that provides an all-in-one
management tool for AI coding assistants including Claude Code, Codex, and
Gemini CLI.  It offers provider management, proxy configuration, session
handling, and usage monitoring.  This package provides the prebuilt
binary release.")
     (license license:expat)))

(define-public git-credential-keepassxc
  (package
    (name "git-credential-keepassxc")
    (version "0.14.2")
    (source
     (origin
       (method url-fetch)
       (uri (crate-uri "git-credential-keepassxc" version))
       (file-name (string-append name "-" version ".tar.gz"))
        (sha256
         (base32 "0mb3ms54is8jy8x441n4ki3if8ggkqjbdh5czahrgvxka0y482jv"))))
    (build-system cargo-build-system)
    (arguments
     (list
      #:rust rust-1.88
      #:install-source? #f))
    (inputs (cargo-inputs 'git-credential-keepassxc
                          #:module
                          '(jeans packages rust-crates)))
    (home-page "https://github.com/Frederick888/git-credential-keepassxc")
    (synopsis
     "Use KeePassXC as a command-line credential store")
    (description
     "@code{git-credential-keepassxc} is a @code{git} credential helper that
enables command-line applications to interact with @code{keepassxc} databases.")
    (license license:gpl3+)))

(define-public opencode-bin
  (package
    (name "opencode-bin")
    (version "1.15.13")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/anomalyco/opencode/releases/download/"
             "v" version "/opencode-linux-x64.tar.gz"))
       (sha256
        (base32 "0y9x9fnjwrzb8jy3zxq7rvd3717p1xd5q8x54m8prwh9q03mly2i"))))
    (build-system copy-build-system)
    (arguments
     (list
      #:validate-runpath? #f
      #:strip-binaries? #f
      #:install-plan
      #~'(("opencode" "libexec/opencode"))
      #:phases
      #~(modify-phases %standard-phases
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
    (version "15.9.3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/can1357/oh-my-pi/releases/download/"
             "v" version "/omp-linux-x64"))
       (sha256
        (base32 "05qrq3k3vgv3xnxvky7sim4g8dqaz8d2cbc7vq5cyl1yc74lbck0"))))
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

;;; APM (Amber Package Manager): container-based package manager using
;;; fuse-overlayfs and dpkg.  Installs shell scripts, helper binaries,
;;; and the ace-env container rootfs tarball.
;;;
;;; APM requires a writable @file{/var/lib/apm} at runtime for storing
;;; installed packages and overlayfs layers.  This directory must be
;;; created and initialised by the user (or a system service) before
;;; first use.  The Guix store copy under @file{share/apm/var-lib/}
;;; serves as the read-only seed that the init script copies into
;;; @file{/var/lib/apm}.

(define-public amber-pm
  (let ((commit "d5bb8f929cb92007c5a28f154aa4349368ac7b4d")
        (revision "0"))
    (package
      (name "amber-pm")
      (version (git-version "1.3.2" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://gitee.com/amber-ce/amber-pm")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "14iajm64090qw7flzn0ncazzmyn27rnw6mmrlz3d230zf2iws5j4"))))
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
                (copy-recursively #$source ".")))
            (add-after 'unpack 'substitute-paths
              (lambda _
                (let ((version #$(package-version this-package)))
                  (substitute* '("src/usr/libexec/apm/apm-main"
                                 "src/DEBIAN/control"
                                 "src/var/lib/apm/apm/files/feedback.sh")
                    (("@VERSION@") version))
                  (substitute* "src/usr/libexec/apm/apm-main"
                    (("/usr/libexec/apm/apm-eggs")
                     (string-append #$output "/libexec/apm/apm-eggs"))))))
            (replace 'install
              (lambda _
                (let* ((out #$output)
                       (bin (string-append out "/bin"))
                       (libexec (string-append out "/libexec/apm"))
                       (share (string-append out "/share/apm"))
                       (varlib (string-append share "/var-lib")))
                  (mkdir-p bin)
                  (mkdir-p libexec)

                  (install-file "src/usr/libexec/apm/apm-main" libexec)
                  (install-file "src/usr/libexec/apm/apm-eggs" libexec)
                  (chmod (string-append libexec "/apm-main") #o755)
                  (chmod (string-append libexec "/apm-eggs") #o755)

                  (symlink (string-append libexec "/apm-main")
                           (string-append bin "/apm"))

                  (for-each
                   (lambda (script)
                     (install-file (string-append "src/usr/bin/" script) bin)
                     (chmod (string-append bin "/" script) #o755))
                   '("amber-pm-app-launcher"
                     "amber-pm-app-uninstaller"
                     "amber-pm-configure-nvidia-host"
                     "amber-pm-convert"
                     "amber-pm-addons-maker"
                     "amber-pm-desktop-fix"
                     "amber-pm-dstore-patch"
                     "amber-pm-upgrade-notifier"))

                  (copy-recursively "src/var/lib/apm" varlib)

                  (let ((completions (string-append out "/share/bash-completion/completions")))
                    (mkdir-p completions)
                    (install-file "src/usr/share/bash-completion/completions/apm"
                                  completions))

                  (let ((zsh-fns (string-append out "/share/zsh/site-functions")))
                    (mkdir-p zsh-fns)
                    (install-file "src/usr/share/zsh/site-functions/_apm" zsh-fns))

                  (let ((icons (string-append out "/share/icons")))
                    (mkdir-p icons)
                    (install-file "src/usr/share/icons/apm.png" icons))

                  (let ((init-script (string-append bin "/amber-pm-init")))
                    (call-with-output-file init-script
                      (lambda (port)
                        (format port "#!~a/bin/bash
set -euo pipefail

APM_SEED=\"~a/share/apm/var-lib\"
APM_TARGET=\"/var/lib/apm\"

if [ \"$(id -u)\" -ne 0 ]; then
  echo \"ERROR: amber-pm-init must be run as root\" >&2
  exit 1
fi

if [ ! -d \"$APM_SEED\" ]; then
  echo \"ERROR: seed directory $APM_SEED not found\" >&2
  exit 1
fi

if [ -d \"$APM_TARGET/apm\" ] && [ -f \"$APM_TARGET/apm/files/ace-env.tar.xz\" ]; then
  echo \"APM data already initialised at $APM_TARGET — skipping.\"
  echo \"To reinitialise, remove $APM_TARGET and run again.\"
  exit 0
fi

echo \"Initialising APM data from $APM_SEED -> $APM_TARGET ...\"
mkdir -p \"$APM_TARGET\"
cp -rv \"$APM_SEED/\"* \"$APM_TARGET/\"

# ace-init expects to run inside the container; instead decompress here.
if [ -f \"$APM_TARGET/apm/files/ace-env.tar.xz\" ] && [ ! -d \"$APM_TARGET/apm/files/ace-env\" ]; then
  echo \"Decompressing ace-env.tar.xz ...\"
  tar -xJf \"$APM_TARGET/apm/files/ace-env.tar.xz\" -C \"$APM_TARGET/apm/files/\"
fi

echo \"APM initialised.  You may now use the 'apm' command.\"
"
                                #$bash-minimal
                                out)))
                    (chmod init-script #o755))))))))
      (inputs (list bash-minimal))
      (home-page "https://gitee.com/amber-ce/amber-pm")
      (synopsis "Container-based package manager using fuse-overlayfs")
      (description "APM (Amber Package Manager) is a package manager that
uses fuse-overlayfs, dpkg and AmberCE containers to run Debian-based
applications in isolated environments.  It supports converting regular
deb packages into APM format, managing container overlays, and
providing desktop integration.

APM requires a writable @file{/var/lib/apm} directory at runtime.
The seed data is installed under @file{share/apm/var-lib/} in the Guix
store and must be copied to @file{/var/lib/apm} before first use.")
      (license license:agpl3+))))

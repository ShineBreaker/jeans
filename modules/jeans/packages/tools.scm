;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-only

(define-module (jeans packages tools)
  #:use-module (ice-9 match)
  #:use-module (guix packages)
  #:use-module (guix build-system cargo)
  #:use-module (guix build-system pyproject)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system gnu)
  #:use-module (guix gexp)
  #:use-module (guix utils)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module ((nonguix licenses) #:prefix license:)
  #:use-module (gnu packages)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages python)
  #:use-module (gnu packages python-build) ; python-hatchling
  #:use-module (jeans packages python-xyz) ; python-jieba
  #:use-module (gnu packages java)
  #:use-module (gnu packages rdesktop)
  #:use-module (gnu packages gtk)      ; gtk+, cairo, gdk-pixbuf
  #:use-module (gnu packages linux)    ; iproute
  #:use-module (gnu packages admin)    ; netcat-openbsd
  #:use-module (gnu packages gnome)    ; libnotify, libsoup
  #:use-module (gnu packages ncurses)  ; dialog
  #:use-module (gnu packages elf)      ; patchelf
  #:use-module (gnu packages webkit)   ; webkitgtk-for-gtk3
  #:use-module (gnu packages base)     ; glibc, binutils, coreutils
  #:use-module (gnu packages glib)     ; glib
  #:use-module (gnu packages freedesktop) ; libappindicator
  #:use-module (gnu packages gcc)         ; gcc:lib
  #:use-module (gnu packages rust)        ; rust
  #:use-module (gnu packages tls)          ; openssl
  #:use-module (gnu packages compression) ; xz
  #:use-module (gnu packages version-control) ; git
  )

(define-public winapps
  ;; 上游不打 tag，追踪 main 分支 HEAD；由 guix refresh 的
  ;; latest-git-commit updater 自动更新 commit 和 revision。
  (let ((commit "77f7177b623aa0ee4e8fd97cad30b260ae6b35b4")
        (revision "1"))
    (package
      (name "winapps")
      (version (git-version "0" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/winapps-org/winapps")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "0pqi1fvrjipgq02jxvp2dn0h1av3wmf1kdqdk9mzglyzw16lqbqk"))
         (patches
          (map canonicalize-path
               (search-patches
                "jeans/patches/winapps-fix-install-paths.patch")))))
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
                  (("#!/bin/bash")
                   (string-append "#!" #$bash-minimal "/bin/bash")))))
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
                              #$bash-minimal #$freerdp-3)))
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
                                (string-append #$bash-minimal "/bin")
                                (string-append #$freerdp-3 "/bin")
                                (string-append #$libnotify "/bin")
                                (string-append #$dialog "/bin")
                                (string-append #$netcat-openbsd "/bin")
                                (string-append #$iproute "/bin")))))
                   '("winapps" "winapps-setup"))))))))
      (inputs
       `(("bash-minimal" ,bash-minimal)
         ("freerdp" ,freerdp-3)
         ("dialog" ,dialog)
         ("libnotify" ,libnotify)
         ("netcat-openbsd" ,netcat-openbsd)
         ("iproute2" ,iproute)))
      (home-page "https://github.com/winapps-org/winapps")
      (synopsis "Run Windows applications on GNU/Linux")
      (description "Run Windows applications (including Microsoft 365
       and Adobe Creative Cloud) on GNU/Linux with KDE, GNOME or XFCE,
       integrated seamlessly as if they were native to the OS.")
      (properties `((with-latest-git-commit . #t)))
      (license license:agpl3+))))

(define-public jdtls-bin
  (package
    (name "jdtls-bin")
    (version "1.60.0")
    (source
      (origin
        (method url-fetch)
        (uri (string-append
              "https://download.eclipse.org/jdtls/milestones/"
              version
              "/jdt-language-server-"
              version
              "-202606262232.tar.gz"))
        (sha256
          (base32 "07ggh6mb28pj1d0pha29qm98rl8zfww2fn03129pgycqh4yk0k79"))))
    (build-system gnu-build-system)
    (arguments
      (list
        #:tests? #f
        #:validate-runpath? #f
        #:strip-binaries? #f
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
    (inputs `(("openjdk" ,openjdk)
              ("python" ,python)
              ("bash-minimal" ,bash-minimal)))
    (synopsis "Java language server")
    (description "The Eclipse JDT Language Server is a Java-specific
implementation of the Language Server Protocol.  It can be used with any
editor that supports the protocol to provide Java language features.")
    (home-page "https://github.com/eclipse-jdtls/eclipse.jdt.ls")
    (license license:expat)))

;;; aria2-next: prebuilt binary of a maintained aria2 fork (GPL-2.0, same as aria2).
;;; This is the standalone CLI build; motrix-next-bin also wires it in as its
;;; download engine (placing it at lib/MotrixNext/binaries/motrix-next-engine).
;;;
;;; The upstream release ships a single raw ELF executable (dynamically linked
;;; against libssl/libcrypto/libstdc++/libgcc_s), so we use the bare-ELF pattern:
;;; install under lib/aria2-next/ with a bin/ symlink so patchelf's RPATH finds
;;; the store libs and the entry point is on PATH.

(define-public aria2-next-bin
  (package
    (name "aria2-next-bin")
    (version "2.5.6")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/AnInsomniacy/aria2-next/releases/download/"
             "v" version "/aria2-next-" version "-linux-x86_64"))
       (sha256
        (base32 "1ii0d1qyndzgjk0cxdcl2qdcqzyx3zy13yi7rv234dssiah061n1"))))
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
              ;; Source is a single raw ELF executable; just copy it into the
              ;; build dir so the install phase can place and patch it.
              (copy-file #$source "aria2-next")))
          (replace 'install
            (lambda* (#:key inputs #:allow-other-keys)
              (let* ((out #$output)
                     (bin (string-append out "/bin"))
                     (libexec (string-append out "/lib/aria2-next"))
                     (patchelf-bin
                      (string-append (assoc-ref inputs "patchelf")
                                     "/bin/patchelf"))
                     (ldso (string-append (assoc-ref inputs "glibc")
                                          "/lib/ld-linux-x86-64.so.2"))
                     (rpath
                      (string-join
                       (map (lambda (pkg)
                              (string-append (assoc-ref inputs pkg) "/lib"))
                            '("openssl" "glibc" "gcc:lib"))
                       ":")))
                ;; Install the real binary under libexec/ so RPATH lookups find
                ;; sibling libs, and expose it on PATH via a bin/ symlink.
                ;; install-file preserves the (read-only) source mode, so we
                ;; must chmod before patchelf can rewrite the ELF.
                (mkdir-p libexec)
                (install-file "aria2-next" libexec)
                (chmod (string-append libexec "/aria2-next") #o755)
                (mkdir-p bin)
                (symlink (string-append libexec "/aria2-next")
                         (string-append bin "/aria2-next"))

                ;; Patch ELF interpreter and RPATH.
                (invoke patchelf-bin "--set-interpreter" ldso
                        (string-append libexec "/aria2-next"))
                (invoke patchelf-bin "--set-rpath" rpath
                        (string-append libexec "/aria2-next"))))))))
     (native-inputs (list patchelf binutils))
     (inputs
      `(("bash-minimal" ,bash-minimal)
        ("glibc" ,glibc)
        ("gcc:lib" ,gcc "lib")
        ("openssl" ,openssl)))
     (properties `((upstream-name . "aria2-next")))
     (home-page "https://github.com/AnInsomniacy/aria2-next")
     (synopsis "Maintained aria2 fork with bug fixes and modernized architecture")
     (description "aria2-next is a maintained fork of aria2, the lightweight
multi-protocol & multi-source command-line download utility.  It supports
HTTP/HTTPS, FTP, SFTP, BitTorrent and Metalink.  This package provides the
prebuilt binary release.")
     (license license:gpl2)))

;;; Motrix-Next: prebuilt binary download manager (Tauri/WebKitGTK app).
;;;
;;; The upstream .deb ships:
;;;   - motrix-next        (Tauri app, dynamically linked to webkit2gtk-4.1, gtk3, etc.)
;;;   - motrix-next-engine (aria2 RPC helper; we replace it with aria2-next-bin, see below)
;;;   - lib/MotrixNext/{binaries,data}/ resource tree (aria2.conf, GeoIP db, ED2K bootstrap)
;;;
;;; Because this is a prebuilt binary compiled on Ubuntu, we must:
;;;   1. Use patchelf to set the ELF interpreter to Guix's ld-linux.
;;;   2. Use patchelf to set RPATH so the binary finds all shared libs in the store.
;;;
;;; The app resolves its resource dir via Tauri's resource_dir() (= lib/MotrixNext/),
;;; then loads `binaries/aria2.conf`, `data/dbip-country-lite.mmdb`,
;;; `data/ed2k-bootstrap/{server.met,nodes.dat}` relative to it.  Missing any of
;;; these data files crashes the engine at startup (see ED2K/GeoIP errors).
;;;
;;; The engine is a Tauri shell-plugin sidecar, resolved from the EXECUTABLE
;;; directory (bin/, via exe_dir of the real binary) by basename
;;; "motrix-next-engine" — NOT from the resource dir.  So we install
;;; aria2-next-bin into bin/ as motrix-next-engine (see install phase).

(define-public motrix-next-bin
  (package
    (name "motrix-next-bin")
    (version "3.9.7")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/AnInsomniacy/motrix-next/releases/download/"
             "v" version "/MotrixNext_" version "_amd64.deb"))
       (sha256
        (base32 "15bp7prj63r3f1hmcf9lc612x0i8g4dh1kn0n3nhx54gdvs8bp40"))))
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
                               "gdk-pixbuf" "libsoup" "glibc" "gcc:lib"
                               "openssl" "libappindicator"))
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

                ;; Install the entire deb resource tree (binaries/ + data/) under
                ;; lib/MotrixNext/ so every bundled asset is available relative to
                ;; resource_dir().  This is the fix for the runtime crashes:
                ;;   - data/dbip-country-lite.mmdb      (GeoIP db)
                ;;   - data/ed2k-bootstrap/server.met   (ED2K bootstrap)
                ;;   - data/ed2k-bootstrap/nodes.dat    (ED2K DHT nodes)
                ;;   - binaries/aria2.conf              (engine config)
                ;; copy-recursively preserves the dir structure; :keep-mode? #t is
                ;; unnecessary (these are data files, not executables).
                (mkdir-p lib-resource)
                (copy-recursively "usr/lib/MotrixNext" lib-resource)

                ;; Engine placement: the app uses Tauri's shell plugin to spawn its
                ;; aria2 sidecar, resolved from the EXECUTABLE directory (exe_dir =
                ;; bin/, because wrap-program execs bin/.motrix-next-real) by the
                ;; basename motrix-next-engine.  So the engine MUST live next to the
                ;; main binary in bin/, NOT under the resource dir.  Placing it under
                ;; lib/MotrixNext/binaries/ makes the spawn fail with os error 2
                ;; (confirmed by the live runtime log).  Replace the bundled engine
                ;; (v2.4.9) with aria2-next-bin (v2.5.x): copy its binary into bin/
                ;; under the sidecar name the app expects.
                (let ((engine-src
                       (string-append (assoc-ref inputs "aria2-next-bin")
                                      "/lib/aria2-next/aria2-next"))
                      (engine-dst
                       (string-append bin "/motrix-next-engine")))
                  (copy-file engine-src engine-dst)
                  ;; copy-file preserves the read-only source mode; patchelf
                  ;; needs write access to rewrite the ELF.
                  (chmod engine-dst #o755)
                  ;; Patch the engine copy's interpreter/RPATH.  It links against
                  ;; libssl/libcrypto/libstdc++/libgcc_s (same as the main binary's
                  ;; RPATH set, minus the GUI/webkit libs — but extra RPATH entries
                  ;; are harmless, so we reuse the same rpath).
                  (invoke patchelf-bin "--set-interpreter" ldso engine-dst)
                  (invoke patchelf-bin "--set-rpath" rpath engine-dst))

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
      `(("bash-minimal" ,bash-minimal)
        ("glibc" ,glibc)
        ("gcc:lib" ,gcc "lib")
        ("webkitgtk-for-gtk3" ,webkitgtk-for-gtk3)
        ("gtk+" ,gtk+)
        ("glib" ,glib)
        ("cairo" ,cairo)
        ("gdk-pixbuf" ,gdk-pixbuf)
        ("libsoup" ,libsoup)
        ("openssl" ,openssl)
        ("libappindicator" ,libappindicator)
        ;; aria2-next-bin provides the download engine, installed into the
        ;; resource dir as binaries/motrix-next-engine (see install phase).
        ("aria2-next-bin" ,aria2-next-bin)))
    (properties `((upstream-name . "MotrixNext")))
    (home-page "https://github.com/AnInsomniacy/motrix-next")
    (synopsis "Full-featured download manager")
    (description "Motrix-Next is a full-featured download manager that supports
downloading HTTP, FTP, BitTorrent, and Magnet links.  It is built with Tauri
and uses aria2-next as the download backend.  This package provides the prebuilt
binary release of the Tauri app and wires in aria2-next-bin as its engine.")
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
    (version "3.20.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/farion1231/cc-switch/releases/download/"
             "v" version "/CC-Switch-v" version "-Linux-x86_64.deb"))
       (sha256
        (base32 "1h2j5b6yvifa5nzd6sh4gjnmb5czrfkz7z8mbh9phag5hqnfw2nl"))))
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
                              "libappindicator" "glibc" "gcc:lib"))
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
      `(("bash-minimal" ,bash-minimal)
        ("glibc" ,glibc)
        ("gcc:lib" ,gcc "lib")
        ("webkitgtk-for-gtk3" ,webkitgtk-for-gtk3)
        ("gtk+" ,gtk+)
        ("glib" ,glib)
        ("cairo" ,cairo)
        ("gdk-pixbuf" ,gdk-pixbuf)
        ("libsoup" ,libsoup)
        ("openssl" ,openssl)
        ("xz" ,xz)
        ("libappindicator" ,libappindicator)))
     (properties `((upstream-name . "CC-Switch")))
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
  (let ((commit "068d91329fa1e9b1c661a7b3f6cc8ac6d20b48a8")
        (revision "1"))
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
          (base32 "147vhpmxq5k4804y7aczm8sy7l7xrvj6ssy3zzzq10d2gnkshq02"))))
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

                  (let ((completions
                         (string-append
                          out "/share/bash-completion/completions")))
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

if [ -d \"$APM_TARGET/apm\" ] && \\
   [ -f \"$APM_TARGET/apm/files/ace-env.tar.xz\" ]; then
  echo \"APM data already initialised at $APM_TARGET — skipping.\"
  echo \"To reinitialise, remove $APM_TARGET and run again.\"
  exit 0
fi

echo \"Initialising APM data from $APM_SEED -> $APM_TARGET ...\"
mkdir -p \"$APM_TARGET\"
cp -rv \"$APM_SEED/\"* \"$APM_TARGET/\"

# ace-init expects to run inside the container; instead decompress here.
if [ -f \"$APM_TARGET/apm/files/ace-env.tar.xz\" ] && \\
   [ ! -d \"$APM_TARGET/apm/files/ace-env\" ]; then
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
      (properties `((with-latest-git-commit . #t)))
      (license license:agpl3+))))

;;; agenote: cross-agent experience platform CLI.
;;;
;;; A pure-stdlib Python CLI (hatchling build backend) that manages a shared
;;; knowledge base of experience cards, memory, curation and workflow
;;; distillation across multiple AI coding agents.  Upstream publishes no git
;;; tags, so this tracks the main-branch HEAD via the latest-git-commit
;;; updater; the @code{jieba} extra (Chinese segmentation for the @code{dream}
;;; sub-command) is optional and not packaged here.

(define-public agenote
  (let ((commit "c9a3e80e0cead99b4399e25213809dbd76dc9f8e")
        (revision "1"))
    (package
      (name "agenote")
      (version (git-version "0.1.2" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/ShineBreaker/agenote")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "1p6qck1lv476m95c1rcylfa2p929klnbkbkil098nhkk8ja13z42"))))
      (build-system pyproject-build-system)
      (arguments
       (list
        ;; No upstream test suite.
        #:tests? #f))
      (native-inputs (list python-hatchling))
      ;; jieba (Chinese segmentation) is a hard runtime dependency since
      ;; 0.1.2: the @code{dream} sub-command imports it for real word
      ;; boundaries.  Propagated so it enters the profile of anything
      ;; depending on agenote; only the missing/corrupt case falls back
      ;; to the bundled 2-gram heuristic.
      (propagated-inputs (list python-jieba))
      (home-page "https://github.com/ShineBreaker/agenote")
      (synopsis "Cross-agent experience platform CLI")
      (description
       "agenote is a Python CLI for cross-agent knowledge management and
experience sharing.  It exposes a unified terminal API (29 sub-commands)
through which multiple AI coding agents can create, retrieve and curate
experience cards, maintain a shared memory system, run health and
curation checks, reconcile read-only indexes across agents, discover
heuristic candidates and distill workflows.  Three commands are
produced: @code{agenote} (main CLI), @code{agenote-cli} (lightweight
shim for hook extensions) and @code{orgfmt} (generic Org-mode
formatter).  Card data and runtime artefacts are written to a
configurable knowledge-base root (@env{KB_ROOT}, default
@file{~/Documents/Org}), not into the package itself.")
      (properties `((with-latest-git-commit . #t)))
      (license license:expat))))

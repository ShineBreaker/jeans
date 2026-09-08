;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-only

 (define-module (jeans packages hardware)
   #:use-module ((guix licenses) #:prefix license:)
   #:use-module (gnu packages base)
   #:use-module (gnu packages backup)
   #:use-module (gnu packages bash)
   #:use-module (gnu packages bootstrap)
   #:use-module (gnu packages compression)
   #:use-module (gnu packages elf)
   #:use-module (gnu packages gcc)
   #:use-module (gnu packages gnome)
   #:use-module (gnu packages gtk)
   #:use-module (gnu packages icu4c)
   #:use-module (gnu packages instrumentation)
   #:use-module (gnu packages kerberos)
   #:use-module (gnu packages libunwind)
   #:use-module (gnu packages tls)
   #:use-module (gnu packages web)
   #:use-module (gnu packages xorg)
   #:use-module (guix build utils)
   #:use-module (nonguix build-system binary)
   #:use-module (guix build-system gnu)
   #:use-module (guix download)
   #:use-module (guix git-download)
   #:use-module (guix gexp)
   #:use-module (guix packages))

(define-public opentabletdriver-udev-rules
  (package
    (name "opentabletdriver-udev-rules")
    (version "0.6.7")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
              (url "https://github.com/OpenTabletDriver/OpenTabletDriver")
              (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256
          (base32 "0q3wc7zv7fadc0w7iihzysc0g4xwalv6mfmk0qwpzxnq73advgcc"))))
    (build-system gnu-build-system)
    (arguments
      (list #:modules '((guix build utils)
                        (guix build gnu-build-system)
                        (ice-9 popen)
                        (ice-9 textual-ports))
            #:phases
            #~(modify-phases %standard-phases
                (delete 'configure)
                (delete 'check)
                (replace 'build
                  (lambda _
                    (let* ((pipe (open-input-pipe "bash generate-rules.sh"))
                           (output (get-string-all pipe)))
                      (close-pipe pipe)
                      (call-with-output-file "70-opentabletdriver.rules"
                        (lambda (port)
                          (put-string port output))))))
                (replace 'install
                  (lambda _
                    (install-file "70-opentabletdriver.rules"
                                  (string-append #$output "/lib/udev/rules.d")))))))
    (native-inputs (list bash-minimal jq))
    (home-page "https://opentabletdriver.net")
    (synopsis "UDev rules for OpenTabletDriver")
    (description "Open source, cross-platform, user-mode tablet driver.")
    (license license:lgpl3+)))
 ;;; OpenTabletDriver prebuilt .deb (https://github.com/OpenTabletDriver/OpenTabletDriver).
 ;;;
 ;;; License evidence: LGPL-3.0 (LICENSE at repo root, same as
 ;;; opentabletdriver-udev-rules above); open source + prebuilt => -bin.
 ;;; Release asset: opentabletdriver_<ver>-1_x64.deb, so
 ;;; upstream-name is "opentabletdriver" (lowercase asset prefix, not the
 ;;; mixed-case repo name) with release-tag-prefix "^v" (tags are v0.6.7).
 ;;;
 ;;; The three programs are framework-dependent .NET single-file bundles:
 ;;; managed assemblies are bundled in (no .dlls beside the ELFs) but the
 ;;; shared runtime is not -- running one without a runtime fails with
 ;;; "Failed to resolve libhostfxr.so" (verified 2026-09-08).  The
;;; embedded runtimeconfig demands Microsoft.NETCore.App 8.0.25, newer
;;; than nonguix's dotnet runtime (8.0.8), and roll-forward never selects
 ;;; a lower version, so a matching private runtime ships below.
 ;;; The runtime dlopen set (.NET host: ICU, OpenSSL, libunwind; daemon:
 ;;; libevdev; UX.Gtk: Gtk3) is absent from NEEDED, so those libraries go
 ;;; on RPATH alongside the static set.
 ;;;
 ;;; Upstream launches via sh wrappers (/usr/bin/otd* calling
 ;;; /usr/lib/opentabletdriver/*); reproduced as thin store-bash wrappers
 ;;; so the bundle keeps its exe-relative layout (no wrap-program rename).
 ;;; The wrappers point DOTNET_ROOT at the private runtime below.
 ;;; The .deb's modprobe install-overrides point at /usr/bin/true
 ;;; (Debian-only); the blacklist equivalent lives in
 ;;; opentabletdriver-service-type instead.
;;; Private .NET runtime matching OTD's embedded framework demand
;;; (Microsoft.NETCore.App 8.0.25; mirrors nonguix's dotnet patchelf plan
;;; for the runtime subset).  Not for general use: bump the version
;;; together with opentabletdriver-bin when its apphost demands newer
;;; (the "App host version" line in the libhostfxr error tells the target).
;;; Not on GitHub: guix refresh cannot track it.
 (define dotnet-runtime-8
   (package
     (name "dotnet-runtime-8")
     (version "8.0.25")
     (source
      (origin
        (method url-fetch/tarbomb)
        (uri (string-append
              "https://builds.dotnet.microsoft.com/dotnet/Runtime/"
              version "/dotnet-runtime-" version "-linux-x64.tar.gz"))
        (sha256
         (base32 "1q46wfbk8y5dcxr1yqf2h9giv2fg2s7jnwfq3mf2yhrkgiyyf102"))))
     (build-system binary-build-system)
    ;; NOTE: arguments MUST stay an outer-backquoted template (nonguix
    ;; shape): binary-build-system splices plan values into the builder
    ;; unquoted, so they have to arrive as quasiquote forms evaluated
    ;; build-side.  A (list ...) + gexp here serializes the evaluated
    ;; data into the builder as code ("Wrong type to apply", 2026-09-08).
    ;; Only ,, escapes (definition-time: package field `version').
     (arguments
      `(#:patchelf-plan
        `(("dotnet" ("gcc:lib" "zlib"))
          (,,(string-append "host/fxr/" version "/libhostfxr.so")
           ("gcc:lib"))
          (,,(string-append "shared/Microsoft.NETCore.App/" version "/createdump")
           ("gcc:lib"))
          (,,(string-append "shared/Microsoft.NETCore.App/" version "/libclrjit.so")
           ("gcc:lib"))
          (,,(string-append "shared/Microsoft.NETCore.App/" version "/libclrgc.so")
           ("gcc:lib"))
          (,,(string-append "shared/Microsoft.NETCore.App/" version "/libcoreclr.so")
           ("gcc:lib" "icu4c"))
          (,,(string-append "shared/Microsoft.NETCore.App/" version "/libcoreclrtraceptprovider.so")
           ("gcc:lib" "lttng-ust"))
          (,,(string-append "shared/Microsoft.NETCore.App/" version "/libhostpolicy.so")
           ("gcc:lib"))
          (,,(string-append "shared/Microsoft.NETCore.App/" version "/libmscordaccore.so")
           ("gcc:lib"))
          (,,(string-append "shared/Microsoft.NETCore.App/" version "/libmscordbi.so")
           ("gcc:lib"))
          (,,(string-append "shared/Microsoft.NETCore.App/" version "/libSystem.Native.so")
           ("gcc:lib"))
          (,,(string-append "shared/Microsoft.NETCore.App/" version "/libSystem.Globalization.Native.so")
           ("gcc:lib"))
          (,,(string-append "shared/Microsoft.NETCore.App/" version "/libSystem.IO.Compression.Native.so")
           ("zlib"))
          (,,(string-append "shared/Microsoft.NETCore.App/" version "/libSystem.Net.Security.Native.so")
           ("gcc:lib"))
          (,,(string-append "shared/Microsoft.NETCore.App/" version "/libSystem.Net.Security.Native.so")
           ("mit-krb5"))
          (,,(string-append "shared/Microsoft.NETCore.App/" version "/libSystem.Security.Cryptography.Native.OpenSsl.so")
           ("openssl")))
        #:install-plan
        `(("." "share/dotnet/"))
        #:phases
        (modify-phases %standard-phases
          (add-before 'patchelf 'patchelf-writable
            (lambda _
              (for-each make-file-writable (find-files ".")))))))
     (inputs
      `(("gcc:lib" ,gcc "lib")
        ("icu4c" ,icu4c)
        ("lttng-ust" ,lttng-ust)
        ("mit-krb5" ,mit-krb5)
        ("openssl" ,openssl)
        ("zlib" ,zlib)))
     (home-page "https://dotnet.microsoft.com/")
     (synopsis "Private .NET runtime for OpenTabletDriver")
     (description "Binary build of the .NET runtime matching the framework
 version demanded by OpenTabletDriver's bundled apphosts.  Private helper,
 not for general use.")
     (license license:expat)
     (supported-systems '("x86_64-linux"))))
 (define-public opentabletdriver-bin
  (package
    (name "opentabletdriver-bin")
    (version "0.6.7")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/OpenTabletDriver/OpenTabletDriver/releases/download/"
             "v" version "/opentabletdriver_" version "-1_x64.deb"))
       (sha256
        (base32 "1wvcm3zbklkhx4m09242wmgp71zy3lsa2sfgbkymxhfc7f9fdb5p"))))
    (build-system gnu-build-system)
    (arguments
     (list
      #:tests? #f
      #:validate-runpath? #f
      #:strip-binaries? #f
      #:modules '((guix build utils)
                  (guix build gnu-build-system)
                  (ice-9 match))
      #:phases
      #~(modify-phases %standard-phases
          (delete 'configure)
          (delete 'build)
          (replace 'unpack
            (lambda _
              ;; .deb = ar archive with zstd-compressed data.tar;
              ;; bsdtar handles both layers (neomacs-bin precedent).
              (invoke "bsdtar" "xf" #$source)
              (invoke "bsdtar" "xf" "data.tar.zst")))
          (replace 'install
            (lambda* (#:key inputs #:allow-other-keys)
              (let* ((out #$output)
                     (bin (string-append out "/bin"))
                     (libdir (string-append out "/lib/opentabletdriver"))
                     (bash-bin (string-append (assoc-ref inputs "bash-minimal")
                                              "/bin/sh"))
                     (dotnet-root (string-append (assoc-ref inputs "dotnet-runtime-8")
                                                 "/share/dotnet"))
                     (ldso (string-append (assoc-ref inputs "glibc")
                                          #$(glibc-dynamic-linker)))
                     (patchelf-bin
                      (string-append (assoc-ref inputs "patchelf")
                                     "/bin/patchelf"))
                     (rpath (string-join
                             (list (string-append (assoc-ref inputs "glibc") "/lib")
                                   (string-append (assoc-ref inputs "gcc:lib") "/lib")
                                   (string-append (assoc-ref inputs "libunwind") "/lib")
                                   (string-append (assoc-ref inputs "icu4c") "/lib")
                                   (string-append (assoc-ref inputs "openssl") "/lib")
                                   (string-append (assoc-ref inputs "zlib") "/lib")
                                   (string-append (assoc-ref inputs "libevdev") "/lib")
                                   (string-append (assoc-ref inputs "gtk+") "/lib"))
                             ":"))
                     ;; XDG_DATA_DIRS additions for the Gtk GUI only
                     (gui-data-dirs
                      (string-join
                       (list (string-append out "/share")
                             (string-append (assoc-ref inputs "gtk+") "/share")
                             (string-append (assoc-ref inputs "gsettings-desktop-schemas")
                                            "/share")
                             (string-append (assoc-ref inputs "hicolor-icon-theme")
                                            "/share"))
                       ":"))
                     ;; Pre-rendered so the wrapper writer stays short.
                     (gui-xdg-export
                      (string-append "export XDG_DATA_DIRS=\""
                                     gui-data-dirs
                                     ":${XDG_DATA_DIRS:+:$XDG_DATA_DIRS}\"")))
                ;; Private directory: the real single-file ELFs under
                ;; their real names (bundle lookup is exe-relative).
                (mkdir-p libdir)
                (for-each
                 (lambda (f)
                   (install-file (string-append "usr/lib/opentabletdriver/" f)
                                 libdir))
                 '("OpenTabletDriver.Console"
                   "OpenTabletDriver.Daemon"
                   "OpenTabletDriver.UX.Gtk"))
                ;; Thin wrappers mirroring upstream's /usr/bin/otd* scripts.
                (mkdir-p bin)
                (for-each
                 (match-lambda
                   ((wrapper . target)
                    (let ((file (string-append bin "/" wrapper)))
                      (call-with-output-file file
                        (lambda (port)
                          (format port "#!~a~%" bash-bin)
                          ;; Framework-dependent bundles: resolve the
                          ;; shared runtime without a system install.
                          ;; Telemetry opt-out mirrors nonguix's dotnet.
                          (format port "export DOTNET_ROOT=\"~a\"~%" dotnet-root)
                          (format port "export DOTNET_CLI_TELEMETRY_OPTOUT=\"1\"~%")
                          (when (string=? wrapper "otd-gui")
                            (display gui-xdg-export port)
                            (newline port))
                          (format port "exec ~a/~a \"$@\"~%"
                                  libdir target)))
                      (chmod file #o755))))
                 '(("otd" . "OpenTabletDriver.Console")
                   ("otd-daemon" . "OpenTabletDriver.Daemon")
                   ("otd-gui" . "OpenTabletDriver.UX.Gtk")))
                ;; udev rules, desktop entry, icons, man page, quirks.
                (install-file "usr/lib/udev/rules.d/70-opentabletdriver.rules"
                              (string-append out "/lib/udev/rules.d"))
                (let ((apps (string-append out "/share/applications")))
                  (mkdir-p apps)
                  (copy-file "usr/share/applications/opentabletdriver.desktop"
                             (string-append apps "/opentabletdriver.desktop"))
                  (substitute* (string-append apps "/opentabletdriver.desktop")
                    (("Exec=otd-gui")
                     (string-append "Exec=" out "/bin/otd-gui"))
                    (("Icon=/usr/share/pixmaps/otd.png")
                     (string-append "Icon=" out "/share/pixmaps/otd.png"))))
                (let ((pixmaps (string-append out "/share/pixmaps")))
                  (mkdir-p pixmaps)
                  (copy-file "usr/share/pixmaps/otd.png"
                             (string-append pixmaps "/otd.png"))
                  (copy-file "usr/share/pixmaps/otd.ico"
                             (string-append pixmaps "/otd.ico")))
                (let ((man (string-append out "/share/man/man8")))
                  (mkdir-p man)
                  (copy-file "usr/share/man/man8/opentabletdriver.8.gz"
                             (string-append man "/opentabletdriver.8.gz")))
                (let ((quirks (string-append out "/share/libinput")))
                  (mkdir-p quirks)
                  (copy-file "usr/share/libinput/30-vendor-opentabletdriver.quirks"
                             (string-append quirks "/30-vendor-opentabletdriver.quirks")))
                ;; Patch every ELF: interpreter + RPATH.
                (for-each
                 (lambda (elf)
                   (invoke patchelf-bin "--set-interpreter" ldso elf)
                   (invoke patchelf-bin "--set-rpath" rpath elf))
                 (map (lambda (f) (string-append libdir "/" f))
                      '("OpenTabletDriver.Console"
                        "OpenTabletDriver.Daemon"
                        "OpenTabletDriver.UX.Gtk")))))))))
    (native-inputs
     `(("libarchive" ,libarchive)
       ("patchelf" ,patchelf)))
    (inputs
     `(("bash-minimal" ,bash-minimal)
       ("dotnet-runtime-8" ,dotnet-runtime-8)
       ("glibc" ,glibc)
       ("gcc:lib" ,gcc "lib")
       ("libunwind" ,libunwind)
       ("icu4c" ,icu4c)
       ("openssl" ,openssl)
       ("zlib" ,zlib)
       ("libevdev" ,libevdev)
       ("gtk+" ,gtk+)
       ("gsettings-desktop-schemas" ,gsettings-desktop-schemas)
       ("hicolor-icon-theme" ,hicolor-icon-theme)))
    (home-page "https://opentabletdriver.net")
    (synopsis "User-mode tablet driver for drawing tablets")
    (description "OpenTabletDriver is an open source, cross-platform,
user-mode tablet driver with support for tablets from Wacom, Huion, XP-Pen,
XenceLabs, Gaomon, Veikk and others, configured through a graphical interface.")
    (properties `((upstream-name . "opentabletdriver")
                  (release-tag-prefix . "^v")))
    (license license:lgpl3+)
    (supported-systems '("x86_64-linux"))))

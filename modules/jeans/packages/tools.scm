;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-only

(define-module (jeans packages tools)
  #:use-module (ice-9 match)
  #:use-module (guix packages)
  #:use-module (guix build-system cargo)
  #:use-module (guix build-system copy)
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
  #:use-module (gnu packages bootstrap) ; glibc-dynamic-linker
  #:use-module (gnu packages glib)     ; glib
  #:use-module (gnu packages freedesktop) ; libappindicator
  #:use-module (gnu packages gcc)         ; gcc:lib
  #:use-module (gnu packages rust)        ; rust
  #:use-module (gnu packages tls)          ; openssl
  #:use-module (gnu packages compression) ; xz
  #:use-module (gnu packages version-control) ; git
  #:use-module (gnu packages node)        ; node
  #:use-module (gnu packages dns)         ; avahi
  #:use-module (gnu packages fontutils)   ; fontconfig, freetype, harfbuzz
  #:use-module (gnu packages gl)          ; mesa, libglvnd
  #:use-module (gnu packages gnupg)       ; libgpg-error
  #:use-module (gnu packages multiprecision) ; gmp
  #:use-module (gnu packages pulseaudio)  ; pipewire
  #:use-module (gnu packages video)       ; x265
  #:use-module (gnu packages xdisorg)     ; libdrm
  #:use-module (gnu packages xorg)        ; libx11, libxcb, libice, libsm
  #:use-module (gnu packages curl)        ; curl
  #:use-module (gnu packages nss)         ; nss-certs
  #:use-module (guix profiles)            ; ca-certificate-bundle
  #:use-module (guix store)
  #:use-module (guix monads)
  )

(define-public winapps
  ;; 上游不打 tag，追踪 main 分支 HEAD；由 guix refresh 的
  ;; latest-git-commit updater 自动更新 commit 和 revision。
  (let ((commit "42c7e8318280c6fc3426c7afebfc7f43b895f4c8")
        (revision "3"))
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
          (base32 "04b8fgq9kh2aa0py324ydyyd6p4595z3hgzxidzsypmxxdiha9br"))
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
                   (string-append "#!" #$bash-minimal "/bin/bash")))
                ;; bash-minimal 不支持 /dev/tcp 网络重定向，而 wrap 又把它
                ;; 置于用户 PATH 之前，等待循环的 RDP 端口探测恒失败，冷启动
                ;; 必然超时；改用已注入 PATH 的 netcat-openbsd 探测。
                (substitute* "bin/winapps"
                  (("timeout 1 bash -c \">/dev/tcp/\\$RDP_IP/\\$RDP_PORT\"")
                   "timeout 1 nc -z \"$RDP_IP\" \"$RDP_PORT\""))))
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
                              #$bash-minimal #$freerdp)))
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
                                (string-append #$freerdp "/bin")
                                (string-append #$libnotify "/bin")
                                (string-append #$dialog "/bin")
                                (string-append #$netcat-openbsd "/bin")
                                (string-append #$iproute "/bin")))))
                   '("winapps" "winapps-setup"))))))))
      (inputs
       `(("bash-minimal" ,bash-minimal)
         ("freerdp" ,freerdp)
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

;;; curl-url-fetch：origin 下载 method，用 curl 替代内置下载器抓取。
;;;
;;; download.eclipse.org 现在经由代理层返回 "Cache-Control: private,
;;; max-age=8m, no-transform"（max-age 按 RFC 9111 应为非负整数秒，8m 非法），
;;; 而 guile >= 3.0.10 为 Cache-Control 声明了严格解析器，内置 url-fetch
;;; 走 Guile HTTP 客户端，直接以 "Bad non-negative-integer header component:
;;; 8m" 拒绝下载。jdtls 的发行 tarball 只在 download.eclipse.org 独家分发
;;; （不在 Eclipse 镜像网络内），只能换用对响应头宽容的 curl；完整性仍由
;;; fixed-output derivation 的 sha256 校验保证。构建沙箱不一定挂宿主的
;;; /etc/ssl/certs（daemon 未配置 chroot-directory 时就没有），CA 用
;;; ca-certificate-bundle derivation 自带，不依赖宿主环境。
(define* (curl-url-fetch url hash-algo hash
                         #:optional name
                         #:key (system (%current-system))
                         (guile (default-guile)))
  (define file-name (basename url))
  (mlet %store-monad ((guile (package->derivation guile system))
                      (ca-bundle (ca-certificate-bundle
                                  (packages->manifest (list nss-certs))
                                  system)))
    (gexp->derivation (or name file-name)
      (with-imported-modules '((guix build utils))
        #~(begin
            (use-modules (guix build utils))
            (invoke (string-append #$curl "/bin/curl")
                    "--fail" "--location" "--retry" "3" "--retry-delay" "2"
                    "--output" #$output
                    "--cacert"
                    (string-append #$ca-bundle
                                   "/etc/ssl/certs/ca-certificates.crt")
                    #$url)))
      #:system system
      #:guile-for-build guile
      #:hash-algo hash-algo
      #:hash hash
      #:local-build? #t
      ;; 与内置 url-fetch 对齐：允许代理与 locale 设置进入构建环境。
      #:leaked-env-vars '("http_proxy" "https_proxy" "no_proxy"
                          "LC_ALL" "LC_MESSAGES" "LANG"))))

(define-public jdtls-bin
  (package
    (name "jdtls-bin")
    (version "1.61.0")
    (source
     (origin
       (method curl-url-fetch)
       (uri (string-append
             "https://download.eclipse.org/jdtls/milestones/"
             version
             "/jdt-language-server-"
             version
             "-202609031315.tar.gz"))
       (sha256
        (base32 "0r2cjfwgz6rhj8h380vw9vmn79sgsfh1jfa5l8dnadhqsrrpx3ik"))))
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
;;; This is the standalone CLI build; rayburst-bin bundles the same version as a
;;; Tauri sidecar, so the two packages no longer share a file.
;;;
;;; The upstream release ships a single raw ELF executable, dynamically linked
;;; against libstdc++/libgcc_s only (OpenSSL is statically linked in since 2.8.2),
;;; so we use the bare-ELF pattern: install under lib/aria2-next/ with a bin/
;;; symlink so patchelf's RPATH finds the store libs and the entry point is on PATH.

(define-public aria2-next-bin
  (package
    (name "aria2-next-bin")
    (version "2.8.2")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/AnInsomniacy/aria2-next/releases/download/"
             "v" version "/aria2-next-" version "-linux-x86_64"))
       (sha256
        (base32 "1gw52nnxcgq4dcl9cqcmrsdv07vdfc0y4yglss2khiqg92qxlrjw"))))
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
                            '("glibc" "gcc:lib"))
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
        ("gcc:lib" ,gcc "lib")))
     (properties `((upstream-name . "aria2-next")))
     (home-page "https://github.com/AnInsomniacy/aria2-next")
     (synopsis "Maintained aria2 fork with bug fixes and modernized architecture")
     (description "aria2-next is a maintained fork of aria2, the lightweight
multi-protocol & multi-source command-line download utility.  It supports
HTTP/HTTPS, FTP, SFTP, BitTorrent and Metalink.  This package provides the
prebuilt binary release.")
     (license license:gpl2)))

;;; Rayburst (formerly Motrix-Next): prebuilt binary download manager
;;; (Tauri/WebKitGTK app).
;;;
;;; Upstream renamed the project from motrix-next to rayburst for 4.0.0 —
;;; repository, release asset names, bundled binaries, desktop entry and icon
;;; all changed — so the Guix package name follows the new upstream name.
;;;
;;; The upstream .deb ships three dynamically linked ELFs, all of which must
;;; end up in bin/ (see the sidecar note below):
;;;   - rayburst                  (Tauri app, links webkit2gtk-4.1, gtk3, ...)
;;;   - aria2-next                (download engine, bundled upstream since 4.0.0;
;;;                                no longer replaced by our aria2-next-bin)
;;;   - rayburst-browser-launcher (native messaging host for the browser
;;;                                extension)
;;; plus the lib/Rayburst/ resource tree (data/ GeoIP db, BT peer blocklist,
;;; ED2K bootstrap; native-messaging/ browser manifests).
;;;
;;; Because this is a prebuilt binary compiled on Ubuntu, we must:
;;;   1. Use patchelf to set the ELF interpreter to Guix's ld-linux.
;;;   2. Use patchelf to set RPATH so the binaries find all shared libs in the
;;;      store (the main binary directly NEEDs libdbus-1, hence the dbus input).
;;;
;;; The app resolves its resource dir via Tauri's resource_dir() (= lib/Rayburst/),
;;; then loads `data/dbip-country-lite.mmdb`, `data/bt-peer-blocklist.txt` and
;;; `data/ed2k-bootstrap/{server.met,nodes.dat}` relative to it.
;;;
;;; The engine and the browser launcher are Tauri sidecars resolved from the
;;; EXECUTABLE directory (bin/, via exe_dir of the real binary) by basename —
;;; NOT from the resource dir — so both must sit next to the main binary in bin/.
;;;
;;; `lib/Rayburst/native-messaging/manifests/*.json` are installed verbatim:
;;; the Windows paths they carry in the upstream deb are templates the launcher
;;; rewrites at runtime, not something to fix here.
;;;
;;; NOTE: bin/aria2-next shares its basename with the standalone aria2-next-bin
;;; package, so a profile holding both reports a collision warning.  It is
;;; harmless: Tauri resolves the sidecar from *this* package's bin/, so the app
;;; always runs the engine it ships (both currently carry upstream 2.8.2).

(define-public rayburst-bin
  (package
    (name "rayburst-bin")
    (version "4.0.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/AnInsomniacy/rayburst/releases/download/"
             "v" version "/Rayburst_" version "_amd64.deb"))
       (sha256
        (base32 "0gpj2qi7z607b48yfyikfzfm98argsb6x5c42q2rh77ndhnm0a7m"))))
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
              (let ((debdir (string-append "rayburst-" #$version)))
                (mkdir debdir)
                (with-directory-excursion debdir
                  (invoke "ar" "x" #$source)
                  (invoke "tar" "xzf" "data.tar.gz"))
                (chdir debdir))))
          (replace 'install
            (lambda* (#:key inputs #:allow-other-keys)
              (let* ((out #$output)
                     (bin (string-append out "/bin"))
                     (lib-resource (string-append out "/lib/Rayburst"))
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
                               "gdk-pixbuf" "libsoup" "dbus" "glibc" "gcc:lib"
                               "libappindicator"))
                       ":")))
                ;; Place all three ELFs directly in bin/.  wrap-program
                ;; will rename the main binary to .rayburst-real and create a
                ;; wrapper script.  When the wrapper execs the real binary,
                ;; /proc/self/exe points to bin/.rayburst-real, so Tauri's
                ;; resource_dir() computes:  exe_dir/../lib/<identifier>/
                ;;                        = bin/../lib/Rayburst/
                ;;                        = lib/Rayburst/          ✅
                ;; and the engine/launcher sidecars are found in that same bin/.
                (mkdir-p bin)
                (install-file "usr/bin/rayburst" bin)
                (install-file "usr/bin/aria2-next" bin)
                (install-file "usr/bin/rayburst-browser-launcher" bin)

                ;; Install the entire deb resource tree (data/ + native-messaging/)
                ;; under lib/Rayburst/ so every bundled asset is available relative
                ;; to resource_dir():
                ;;   - data/dbip-country-lite.mmdb       (GeoIP db)
                ;;   - data/bt-peer-blocklist.txt        (BT peer blocklist seed)
                ;;   - data/ed2k-bootstrap/server.met    (ED2K bootstrap)
                ;;   - data/ed2k-bootstrap/nodes.dat     (ED2K DHT nodes)
                ;;   - native-messaging/manifests/*.json (browser host manifests)
                ;; copy-recursively preserves the dir structure; :keep-mode? #t is
                ;; unnecessary (these are data files, not executables).
                (mkdir-p lib-resource)
                (copy-recursively "usr/lib/Rayburst" lib-resource)

                ;; Patch ELF interpreter and RPATH on every shipped binary.
                ;; The engine and the launcher link against a subset of the store
                ;; libs the main binary needs (engine: libstdc++/libgcc_s;
                ;; launcher: libgcc_s — its OpenSSL is statically linked), and
                ;; extra RPATH entries are harmless, so one rpath covers all three.
                (for-each
                 (lambda (elf)
                   (invoke patchelf-bin "--set-interpreter" ldso elf)
                   (invoke patchelf-bin "--set-rpath" rpath elf))
                 (list (string-append bin "/rayburst")
                       (string-append bin "/aria2-next")
                       (string-append bin "/rayburst-browser-launcher")))

                ;; wrap-program renames the real binary to .rayburst-real
                ;; and creates a bash wrapper that sets env vars before exec.
                (wrap-program (string-append bin "/rayburst")
                  `("XDG_DATA_DIRS" ":" prefix
                    ,(list (string-append out "/share")
                           (string-append #$gtk+ "/share")
                           (string-append #$glib "/share")
                           (string-append #$gdk-pixbuf "/share"))))

                ;; Install desktop entry.
                (mkdir-p (string-append share "/applications"))
                (copy-file "usr/share/applications/Rayburst.desktop"
                           (string-append share "/applications/Rayburst.desktop"))
                (substitute* (string-append share "/applications/Rayburst.desktop")
                  (("Exec=rayburst")
                   (string-append "Exec=" bin "/rayburst")))

                ;; Install icons.
                (for-each
                 (lambda (size-dir)
                   (let ((icon-src
                          (string-append "usr/share/icons/hicolor/"
                                         size-dir "/apps/rayburst.png"))
                         (icon-dst-dir
                          (string-append share "/icons/hicolor/"
                                         size-dir "/apps")))
                     (when (file-exists? icon-src)
                       (mkdir-p icon-dst-dir)
                       (copy-file icon-src
                                  (string-append icon-dst-dir
                                                 "/rayburst.png")))))
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
        ("dbus" ,dbus)
        ("libappindicator" ,libappindicator)))
    (properties `((upstream-name . "Rayburst")))
    (home-page "https://github.com/AnInsomniacy/rayburst")
    (synopsis "Full-featured download manager")
    (description "Rayburst is a full-featured download manager that supports
downloading HTTP, FTP, BitTorrent, and Magnet links.  It is built with Tauri,
uses aria2 as the download backend, and integrates with browsers through a
companion extension.  This package provides the prebuilt binary release.")
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
    (version "3.20.3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/farion1231/cc-switch/releases/download/"
             "v" version "/CC-Switch-v" version "-Linux-x86_64.deb"))
       (sha256
        (base32 "1ifn3p24k5v0bk04a44brj9mky2lgrb2nj3cnr2hamq529gygkr2"))))
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

It requires a writable @file{/var/lib/apm} directory at runtime; run the
@command{amber-pm-init} script as root before first use to initialise it.")
      (properties `((with-latest-git-commit . #t)))
      (license license:agpl3+))))

;;; agenote: cross-agent experience platform CLI.
;;;
;;; A pure-stdlib Python CLI (hatchling build backend) that manages a shared
;;; knowledge base of experience cards, memory, curation and workflow
;;; distillation across multiple AI coding agents.  Upstream publishes
;;; v-prefixed git tags; this pins the latest release tag (the generic-git
;;; updater takes over from here).  The @code{jieba} extra (Chinese
;;; segmentation for the @code{dream} sub-command) is optional and not
;;; packaged here.

(define-public agenote
  (package
    (name "agenote")
    (version "2026-09-22")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/ShineBreaker/agenote")
             (commit "e136de0fe65e968a49cf04b14845d559c8a5988d")))
       (file-name (git-file-name name version))
       (sha256
        (base32 "101g2yhn04j0ghmq4kbd7aky4fa3j2akaa1vb12y35aqsw4gjpxx"))))
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
    (license license:expat)))

;;; Prettier: opinionated code formatter (MIT).  Upstream publishes no
;;; binary release assets on GitHub; the npm tarball on registry.npmjs.org
;;; is the official prebuilt distribution — a self-contained ES-module
;;; bundle with zero runtime dependencies, executed directly by node.
;;; Installed in the standard lib/node_modules layout; bin/prettier.cjs
;;; ships non-executable (npm convention) so we chmod before wrapping.
;;; guix refresh has no npm updater, so version bumps go through the
;;; Python updater's "prettier-bin" special handler (npm registry
;;; dist-tags; the URI embeds `version` so only the version field changes).
(define-public prettier-bin
  (package
    (name "prettier-bin")
    (version "3.9.8")
    (source
      (origin
        (method url-fetch)
        (uri (string-append
              "https://registry.npmjs.org/prettier/-/prettier-"
              version
              ".tgz"))
        (sha256
          (base32 "0kx4i97apjw3nh6r94s81aw8x1k9mifpbc2pqg5s9rc4ly81jgn3"))))
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
            ;; npm tarballs always unpack to a generic "package/" directory,
            ;; which the default unpack phase already chdirs into.
            (replace 'install
              (lambda _
                (let ((dir (string-append #$output "/lib/node_modules/prettier")))
                  (mkdir-p dir)
                  (copy-recursively "." dir)
                  (chmod (string-append dir "/bin/prettier.cjs") #o555)
                  (wrap-program (string-append dir "/bin/prettier.cjs")
                    `("PATH" ":" prefix
                      (,(string-append #$node "/bin"))))
                  (mkdir-p (string-append #$output "/bin"))
                  (symlink (string-append dir "/bin/prettier.cjs")
                           (string-append #$output "/bin/prettier"))))))))
    (inputs `(("node" ,node)
              ("bash-minimal" ,bash-minimal)))
    (synopsis "Opinionated multi-language code formatter")
    (description "Prettier is an opinionated code formatter.  It enforces a
consistent style by parsing code and re-printing it with its own rules,
supporting many languages including JavaScript, TypeScript, CSS, HTML,
JSON, YAML, Markdown and GraphQL.")
    (home-page "https://prettier.io")
    (license license:expat)))


;; Sunshine (GPL-3.0-only, LizardByte/Sunshine) is a self-hosted game stream
;; host for Moonlight.  Two prebuilt Linux shapes were evaluated for
;; v2026.906.222525, and only the AppImage is usable here:
;;
;; - The "sunshine.pkg.tar.gz" asset is just the Arch PKGBUILD recipe
;;   (3.5 KiB), not a binary.  Its sibling binary
;;   (sunshine-<ver>-1-x86_64.pkg.tar.zst) hardcodes SUNSHINE_ASSETS_DIR to
;;   /usr/share/sunshine (cmake/compile_definitions/unix.cmake prepends
;;   CMAKE_INSTALL_PREFIX) and needs Qt_6.11 symbols (readelf -V), newer
;;   than Guix's qtbase 6.9.2.
;; - The AppImage bundles its own Qt/ffmpeg/curl stack (108 .so) and its
;;   binary references assets as CWD-relative "./usr/share/sunshine", which
;;   is why upstream AppRun does `cd "$HERE"`.  Only stock system libraries
;;   stay external; the inputs below additionally cover transitive NEEDEDs
;;   of the bundled libs plus the dlopen()ed avahi-client, x265 and EGL/GL.
;;
;; The install preserves the AppRun layout verbatim under lib/sunshine and
;; bin/sunshine is a thin shell wrapper that only cds there before execing
;; (deliberately no wrap-program/LD_LIBRARY_PATH: the binary re-execs
;; /proc/self/exe on in-app restart, which would bypass wrapper-set env but
;; keeps the baked RPATH).  udev rules are copied to lib/udev/rules.d so the
;; sunshine-service-type picks them up; modules-load.d and the systemd user
;; unit ship in the payload for reference, Guix uses kernel-module-loader
;; and the home shepherd service instead.
(define-public sunshine-bin
  (package
    (name "sunshine-bin")
    (version "2026.914.233613")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/LizardByte/Sunshine/releases/download/v"
             version "/Sunshine_" version "_x86_64.AppImage"))
       (sha256
        (base32 "0ik841a9rhq43zp3v71adbcs9jd8q2sk3wag27d8rkrvhmx2k03g"))))
    (build-system copy-build-system)
    (arguments
     (list
      #:tests? #f
      #:validate-runpath? #f
      #:strip-binaries? #f
      #:modules '((guix build utils)
                  (guix build copy-build-system)
                  (ice-9 ftw)
                  (ice-9 format))
      #:install-plan
      #~'(("usr" "lib/sunshine/usr")
          ("usr/share/applications/" "share/applications/")
          ("usr/share/icons/" "share/icons/"))
      #:phases
      #~(modify-phases %standard-phases
          (delete 'install-license-files)
          ;; The source is a bare AppImage (not an archive): extract it with
          ;; 7z's static parsing, never the runtime's --appimage-extract
          ;; self-extraction (exec on the build tree is denied on CI).
          (add-after 'unpack 'extract-appimage
            (lambda _
              (invoke "7z" "x" #$source)))
          (add-after 'install 'patch-elf
            (lambda* (#:key inputs #:allow-other-keys)
              (let* ((ld.so (string-append (assoc-ref inputs "glibc")
                                           #$(glibc-dynamic-linker)))
                     (lib-dir (string-append #$output "/lib/sunshine/usr/lib"))
                     ;; Build-side `inputs' preserves the sub-output path
                     ;; for "gcc:lib"; the "fontconfig-minimal" label is the
                     ;; package's actual name, not the variable name.
                     (rpath
                      (string-join
                       (cons lib-dir
                             (map (lambda (label)
                                    (string-append
                                     (assoc-ref inputs label) "/lib"))
                                  '("glibc" "gcc:lib" "mesa" "libglvnd"
                                    "libdrm" "wayland" "libx11" "libxcb"
                                    "libice" "libsm" "pipewire"
                                    "fontconfig-minimal" "freetype" "harfbuzz"
                                    "zlib" "avahi" "x265" "e2fsprogs" "gmp"
                                    "libgpg-error")))
                       ":")))
                (define (patch-elf file)
                  (format #t "Patching ~a ..." file)
                  (unless (string-contains file ".so")
                    (invoke "patchelf" "--set-interpreter" ld.so file))
                  (invoke "patchelf" "--set-rpath" rpath file)
                  (display " done\n"))
                (for-each patch-elf
                          (find-files (string-append #$output "/lib/sunshine")
                                      (lambda (file stat)
                                        (and (eq? 'regular (stat:type stat))
                                             (elf-file? file))))))))
          (add-after 'patch-elf 'make-executable
            (lambda _
              (let ((root (string-append #$output "/lib/sunshine")))
                (chmod (string-append root "/usr/bin/sunshine") #o555)
                ;; The payload ships versioned .so symlinks; only chmod real
                ;; files, never follow (possibly dangling) links.
                (for-each (lambda (f)
                            (when (eq? 'regular (stat:type (lstat f)))
                              (chmod f #o555)))
                          (find-files root ".*\\.so.*")))))
          (add-after 'make-executable 'build-wrapper
            (lambda _
              ;; Mirror AppRun's contract: assets resolve as
              ;; "./usr/share/sunshine" against the working directory.
              (let* ((bin (string-append #$output "/bin"))
                     (root (string-append #$output "/lib/sunshine"))
                     (wrapper (string-append bin "/sunshine")))
                (mkdir-p bin)
                (call-with-output-file wrapper
                  (lambda (port)
                    (format port "#!~a/bin/bash~%" #$bash-minimal)
                    (format port "set -e~%")
                    (format port "ROOT=\"~a\"~%" root)
                    (format port "cd \"$ROOT\" || exit 1~%")
                    (format port "exec -a sunshine \"$ROOT/usr/bin/sunshine\" \"$@\"~%")))
                (chmod wrapper #o755))))
          (add-after 'build-wrapper 'install-udev-rules
            (lambda _
              (install-file
               (string-append #$output "/lib/sunshine/usr/share/sunshine/"
                              "udev/rules.d/60-sunshine.rules")
               (string-append #$output "/lib/udev/rules.d"))))
          (add-after 'install-udev-rules 'fix-desktop-entry
            (lambda _
              (substitute* (string-append #$output "/share/applications/"
                                          "dev.lizardbyte.app.Sunshine.desktop")
                (("^Exec=sunshine$")
                 (string-append "Exec=" #$output "/bin/sunshine"))))))))
    (native-inputs (list p7zip patchelf))
    (inputs
     `(("bash-minimal" ,bash-minimal)
       ("glibc" ,glibc)
       ("gcc:lib" ,gcc "lib")
       ("mesa" ,mesa)
       ("libglvnd" ,libglvnd)
       ("libdrm" ,libdrm)
       ("wayland" ,wayland)
       ("libx11" ,libx11)
       ("libxcb" ,libxcb)
       ("libice" ,libice)
       ("libsm" ,libsm)
       ("pipewire" ,pipewire)
       ("fontconfig-minimal" ,fontconfig)
       ("freetype" ,freetype)
       ("harfbuzz" ,harfbuzz)
       ("zlib" ,zlib)
       ("avahi" ,avahi)
       ("x265" ,x265)
       ("e2fsprogs" ,e2fsprogs)
       ("gmp" ,gmp)
       ("libgpg-error" ,libgpg-error)))
    ;; Asset filenames are Sunshine_<version>_<arch>.AppImage; upstream-name
    ;; is the filename prefix before the version (case-sensitive).
    (properties `((upstream-name . "Sunshine")))
    (home-page "https://app.lizardbyte.dev/Sunshine")
    (synopsis "Self-hosted game stream host for Moonlight")
    (description "Sunshine is a self-hosted game stream host for Moonlight.
It streams the desktop and games to local devices with low latency, using
hardware encoding (NVENC, AMF, Quick Sync, VA-API, VideoToolbox) where
available.  Configuration happens through a local web UI; clients pair with
a PIN.  This package provides the prebuilt AppImage release.")
    (license license:gpl3)
    (supported-systems '("x86_64-linux"))))

;;; SPDX-FileCopyrightText: 2021 Petr Hodina <phodina@protonmail.com>
;;; SPDX-FileCopyrightText: 2024 Murilo <murilo@disroot.org>
;;; SPDX-FileCopyrightText: 2025 VnPower <vnpower@loang.net>
;;; SPDX-FileCopyrightText: 2026 Giacomo Leidi <therewasa@fishinthecalculator.me>
;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Android tooling: the waydroid container runtime together with the
;;; binder stack it needs, and scrcpy.
;;;
;;; Ported from the cast channel
;;; <https://codeberg.org/vnpower/cast> (cast/packages/waydroid.scm) and
;;; the small-guix channel
;;; <https://codeberg.org/fishinthecalculator/small-guix>
;;; (modules/small-guix/packages/scrcpy.scm).

;;; Packing notes (kept out of the descriptions on purpose):
;;;
;;; - waydroid hardcodes bare "sh" and bare lxc-* command names in
;;;   tools/helpers/*.py.  Those are rewritten to store paths at unpack
;;;   time; waydroid-net.sh gets a PATH wrapper and bin/waydroid gets a
;;;   PYTHONPATH wrapper, since the gnome/dbus/python deps are propagated
;;;   but the script does not look for them on its own.
;;; - cast also ships anbox-binder (choff/anbox-modules), which is not
;;;   ported here.  Every Guix kernel -- linux-libre and nonguix's
;;;   linux, which is (corrupt-linux linux-libre-*) -- is built with
;;;   CONFIG_ANDROID_BINDER_IPC=y and CONFIG_ANDROID_BINDERFS=y, so no
;;;   out-of-tree module is needed; waydroid itself mounts binderfs and
;;;   creates the /dev/binder, /dev/vndbinder and /dev/hwbinder nodes
;;;   (tools/helpers/drivers.py).  Upstream's copy is also dead code for
;;;   these kernels: it does not compile against 7.x, which removed
;;;   zap_page_range_single and kill_litter_super.

(define-module (jeans packages android)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system meson)
  #:use-module (guix build-system python)
  #:use-module (gnu packages android)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages bison)
  #:use-module (gnu packages compiler-tools)
  #:use-module (gnu packages dns)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages gawk)
  #:use-module (gnu packages gettext)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gnome)   ;desktop-file-utils
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages libusb)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages pciutils)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages python)
  #:use-module (gnu packages python-build)
  #:use-module (gnu packages python-web)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages sdl)
  #:use-module (gnu packages video)
  #:use-module (gnu packages virtualization)
  #:use-module (gnu packages xdisorg)
  #:use-module (jeans packages python-xyz))

;;; GLib helper library shared by libgbinder and the Sailfish stack.  No
;;; configure script upstream, hence the deleted 'configure phase.
(define-public libglibutil
  (package
    (name "libglibutil")
    (version "1.0.83")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://git.sailfishos.org/mer-core/libglibutil")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0i8gdr4y6avpx0a3i0n4fcfnbrk00vwxbzx1z8z131yqw3ibim55"))))
    (build-system gnu-build-system)
    (arguments
     (list #:make-flags
           #~(list (string-append "CC=" #$(cc-for-target))
                   (string-append "DESTDIR=" #$output))
           #:phases
           #~(modify-phases %standard-phases
               (delete 'configure)
               (add-after 'unpack 'remove-usr-prefix
                 (lambda _
                   (substitute* "libglibutil.pc.in"
                     (("/usr/include")
                      (string-append #$output "/include")))
                   (substitute* "Makefile"
                     (("usr/") ""))))
               (add-after 'install 'install-dev
                 (lambda _
                   (invoke "make" "install-dev"
                           (string-append "DESTDIR=" #$output))))
               (replace 'check
                 (lambda* (#:key tests? #:allow-other-keys)
                   (when tests?
                     (chdir "test")
                     (invoke "make" (string-append "CC=" #$(cc-for-target)))
                     (chdir "..")))))))
    (native-inputs (list pkg-config))
    (inputs (list glib))
    (home-page "https://git.sailfishos.org/mer-core/libglibutil")
    (synopsis "GLib utility library")
    (description
     "libglibutil is a library of GLib utilities, providing convenience
wrappers used by the Sailfish OS middleware stack.")
    (license license:bsd-3)))

;;; GLib-style interface to the Android binder, used by waydroid through
;;; gbinder-python.
(define-public libgbinder
  (package
    (name "libgbinder")
    (version "1.1.54")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/mer-hybris/libgbinder")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "18a1jh24npzn4vmrkd32wca91p0z6i1a3j8sx0aycqyjf20c7gpj"))))
    (build-system gnu-build-system)
    (arguments
     (list #:make-flags
           #~(list (string-append "CC=" #$(cc-for-target))
                   (string-append "DESTDIR=" #$output))
           #:phases
           #~(modify-phases %standard-phases
               (delete 'configure)
               (add-after 'unpack 'fix-pkg-config-in
                 (lambda _
                   (substitute* "Makefile"
                     (("usr/") ""))
                   (substitute* "libgbinder.pc.in"
                     (("@libdir@") (string-append #$output "/lib"))
                     (("/usr/include") (string-append #$output "/include")))))
               (add-after 'install 'install-dev
                 (lambda _
                   (invoke "make" "install-dev"
                           (string-append "DESTDIR=" #$output))))
               (replace 'check
                 (lambda* (#:key tests? #:allow-other-keys)
                   (when tests?
                     (chdir "test")
                     (invoke "make" (string-append "CC=" #$(cc-for-target)))
                     (chdir "..")))))))
    (native-inputs (list bison flex pkg-config))
    (inputs (list glib libglibutil))
    (home-page "https://github.com/mer-hybris/libgbinder")
    (synopsis "GLib-style interface to binder")
    (description
     "This package provides a GLib-style interface to binder:
@itemize @bullet
@item Integration with the GLib event loop
@item Detection of 32 vs 64 bit kernel at runtime
@item Asynchronous transactions that do not block the event thread
@item Stable service manager and low-level transaction APIs.
@end itemize")
    (license license:bsd-3)))

;;; Python bindings for libgbinder.  Upstream's setup.py cythonizes
;;; gbinder.pyx unconditionally at import time, so no build flag is needed;
;;; Cython still has to be present, hence python-cython in native-inputs.
(define-public python-gbinder
  (package
    (name "python-gbinder")
    (version "1.3.1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/erfanoabdi/gbinder-python")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "080bvw3954g6q5y28wr4yxjl1r4743wkc71r7j1gi2fq7hcsyyvd"))))
    (build-system python-build-system)
    (arguments
     (list
      ;; tests/ are device-side integration tests that need a running binder
      ;; service, so they cannot run during the build.
      #:tests? #f))
    (native-inputs (list pkg-config python-cython python-setuptools))
    (inputs (list glib libgbinder libglibutil))
    (home-page "https://github.com/erfanoabdi/gbinder-python")
    (synopsis "Python bindings for libgbinder")
    (description
     "This package provides Python bindings for libgbinder, used by waydroid
to talk to the Android binder from the host side.")
    (properties `((upstream-name . "gbinder-python")))
    (license license:gpl3+)))

;;; The version of Python the propagated bindings were built against
;;; decides where their site-packages directory lives; hardcoding a minor
;;; version here silently breaks the PYTHONPATH wrapper on the next
;;; Python upgrade.
(define %waydroid-python-version
  (version-major+minor (package-version python)))

(define-public waydroid
  (package
    (name "waydroid")
    (version "1.6.3")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/waydroid/waydroid")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1kkk83ww4v1p6glnnf4s9s2rfh5vmblvszhn17j4pyqnl950v1nm"))))
    (build-system gnu-build-system)
    (arguments
     (list #:make-flags
           #~(list "USE_SYSTEMD=0"
                   ;; The host firewall is nftables-based; the net script's
                   ;; legacy iptables rules would not be seen by it, so let
                   ;; waydroid manage its own nftables tables instead.
                   "USE_NFTABLES=1"
                   (string-append "PREFIX=" #$output)
                   (string-append "SYSCONFDIR=" #$output "/etc"))
           #:phases
           #~(modify-phases %standard-phases
               (add-after 'install 'patch-dbus-service
                 (lambda* (#:key outputs #:allow-other-keys)
                   ;; Upstream's D-Bus activation file hardcodes /usr/bin,
                   ;; which does not exist on Guix.  Without this rewrite
                   ;; the container daemon cannot be activated on demand.
                   (let* ((out (assoc-ref outputs "out"))
                          (service
                           (string-append
                            out "/share/dbus-1/system-services/"
                            "id.waydro.Container.service")))
                     (substitute* service
                       (("/usr/bin/waydroid")
                        (string-append out "/bin/waydroid"))))))
               (delete 'configure)
               (delete 'check)
               (add-after 'unpack 'hardcode-tool-paths
                 (lambda _
                   (substitute* '("tools/helpers/run.py"
                                  "tools/helpers/lxc.py")
                     (("\"sh\"")
                      (string-append "\"" #$bash-minimal "/bin/sh\""))
                     (("\"lxc-info\"")
                      (string-append "\"" #$lxc "/bin/lxc-info\""))
                     (("\"lxc-start\"")
                      (string-append "\"" #$lxc "/bin/lxc-start\""))
                     (("\"lxc-stop\"")
                      (string-append "\"" #$lxc "/bin/lxc-stop\""))
                     (("\"lxc-freeze\"")
                      (string-append "\"" #$lxc "/bin/lxc-freeze\""))
                     (("\"lxc-unfreeze\"")
                      (string-append "\"" #$lxc "/bin/lxc-unfreeze\""))
                     (("\"lxc-attach\"")
                      (string-append "\"" #$lxc "/bin/lxc-attach\"")))))
               (add-after 'install 'wrap-programs
                 (lambda* (#:key outputs #:allow-other-keys)
                   (let* ((out (assoc-ref outputs "out"))
                          (search-paths
                           (list (string-append #$iptables "/bin")
                                 (string-append #$iptables "/sbin")
                                 ;; 'ip' and friends live in iproute2's /sbin,
                                 ;; not /bin; the net script calls 'ip' by
                                 ;; bare name and fails with "command not
                                 ;; found" when only /bin is on PATH.
                                 (string-append #$iproute "/bin")
                                 (string-append #$iproute "/sbin")
                                 ;; dnsmasq only has /sbin (no /bin) here.
                                 (string-append #$dnsmasq "/sbin")
                                 ;; 'nft' lives in nftables' /sbin; the net
                                 ;; script uses it to manage its own tables.
                                 (string-append #$nftables "/sbin")
                                 ;; 'getent' (for the dnsmasq user lookup) is
                                 ;; in glibc; coreutils provides kill/cat/rm.
                                 (string-append #$glibc "/bin")
                                 (string-append #$coreutils "/bin")
                                 (string-append #$lxc "/bin")
                                 (string-append #$wl-clipboard "/bin")))
                          (python-path
                           (map (lambda (package)
                                  (string-append package "/lib/python"
                                                 #$%waydroid-python-version
                                                 "/site-packages"))
                                (list #$python-dbus
                                      #$python-gbinder
                                      #$python-pygobject
                                      #$python-pyclip))))
                     (wrap-program
                         (string-append
                          out "/lib/waydroid/data/scripts/waydroid-net.sh")
                       `("PATH" prefix ,search-paths))
                     (wrap-program (string-append out "/bin/waydroid")
                       `("PYTHONPATH" prefix ,python-path))))))))
    (native-inputs (list gobject-introspection))
    ;; The wrappers created below are bash scripts, so bash must be a
    ;; host input rather than a native one: it is substituted into the
    ;; store path of the built package.
    (inputs (list bash-minimal))
    (propagated-inputs
     (list coreutils
           dnsmasq
           gawk
           gtk
           iproute
           iptables
           kmod
           lxc
           nftables
           python
           python-dbus
           python-gbinder
           python-pyclip
           python-pygobject
           util-linux
           wl-clipboard))
    (home-page "https://waydro.id")
    (synopsis "Container-based approach to boot a full Android system")
    (description
     "Waydroid uses Linux namespaces @code{(user, pid, uts, net, mount,
ipc)} to run a full Android system in a container and provide Android
applications.  The Android inside the container has direct access to needed
underlying hardware.  The Android runtime environment ships with a minimal
customized Android system image based on LineageOS.

The Guix kernels already include the Android binder driver
(@code{CONFIG_ANDROID_BINDER_IPC} and @code{CONFIG_ANDROID_BINDERFS} are
enabled), and waydroid mounts @code{binderfs} to obtain the
@file{/dev/binder} nodes it needs, so no extra kernel module is required.
Run @command{waydroid init} once to download the system and vendor images,
then start the container with @command{waydroid session start}.")
    (license license:gpl3)))

;;; The DEX server component pushed to the device at runtime.  scrcpy has
;;; two halves: a C client built from source here, and a small Android app
;;; ("scrcpy-server") shipped as Java compiled to DEX, which needs the
;;; Android SDK -- not packaged in Guix.  The official release binary is
;;; reused instead, exactly as Debian, Arch and nixpkgs do; upstream's
;;; meson build supports this through the 'prebuilt_server' option.
;;;
;;; The version is a literal and the server origin is inlined here, because
;;; guix refresh only rewrites text inside the (package ...) form.  Refresh
;;; still cannot update the server hash -- it only knows the package's own
;;; source -- so scrcpy stays out of the CI refresh whitelist, and its
;;; version, source hash and server hash are updated together by hand.
(define-public scrcpy
  (package
    (name "scrcpy")
    (version "5.0.1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/Genymobile/scrcpy")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "062fnhm5pj39cxygs276zqw780blfw6rf850r442iw587a63fsyf"))))
    (build-system meson-build-system)
    (arguments
     (list
      #:configure-flags
      #~(list (string-append
               "-Dprebuilt_server="
               #$(origin
                  (method url-fetch)
                  (uri (string-append
                        "https://github.com/Genymobile/scrcpy/releases/download/v"
                        version "/scrcpy-server-v" version))
                  (file-name (string-append "scrcpy-server-v" version))
                  (sha256
                   (base32 "0dn57gjn5dizpzbrgf31g969ka9bi0h12d6zx4gj3m8ik3vvckkn"))))
              ;; Look the server up under the store 'prefix' rather than
              ;; next to the executable.
              "-Dportable=false"
              ;; V4L2 sink (Linux only) and USB/OTG support (HID over AOA).
              "-Dv4l2=true"
              "-Dusb=true")
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'hardcode-adb
            (lambda* (#:key inputs #:allow-other-keys)
              ;; scrcpy shells out to "adb", relying on $PATH.  Point it at
              ;; the store instead so it works without adb being installed
              ;; in the user profile.  The ADB environment variable still
              ;; takes precedence, so a newer adb can be substituted at
              ;; runtime.
              (substitute* "app/src/adb/adb.c"
                (("strdup\\(\"adb\"\\)")
                 (string-append
                  "strdup(\""
                  (search-input-file inputs "/bin/adb")
                  "\")")))))
          (add-after 'unpack 'enable-tests
            (lambda _
              ;; Upstream only compiles the unit tests for buildtype=debug,
              ;; to avoid running them with assertions disabled.  Guix
              ;; builds with buildtype=debugoptimized, for which
              ;; 'b_ndebug=if-release' keeps assertions enabled, so the
              ;; tests are meaningful here.
              (substitute* "app/meson.build"
                (("get_option\\('buildtype'\\) == 'debug'")
                 "get_option('buildtype') != 'release'")))))))
    (native-inputs (list pkg-config))
    ;; 'libdecor' is not strictly used by scrcpy, but Guix's sdl3 lists it
    ;; in the 'Requires' of sdl3.pc without propagating it, so pkg-config
    ;; fails to resolve sdl3 unless it is present at configure time.
    (inputs (list adb ffmpeg libdecor libusb sdl3))
    (home-page "https://scrcpy.org")
    (synopsis "Display and control Android devices from the desktop")
    (description
     "scrcpy mirrors the screen of an Android device over USB or TCP/IP and
lets you control it with the keyboard and mouse of the computer.  It does
not require root access and installs nothing permanently on the device: a
server component is pushed to the device for the duration of the session.

Features include low-latency mirroring, audio forwarding, recording to a
file, clipboard sharing in both directions, file transfer by drag and drop,
physical keyboard and mouse simulation over @acronym{HID, Human Interface
Device}, and an @acronym{OTG, On-The-Go} mode that controls the device
without mirroring.

The @command{adb} program is invoked internally and is referenced from the
store, so it needs no separate installation.  Set the @env{ADB} environment
variable to override it.")
    (license license:asl2.0)))

;;; Packing notes (kept out of the description on purpose):
;;;
;;; - 打包的是用户 fork（ShineBreaker/waydroid-helper，开发主线，git 版本），
;;;   上游原仓库 waydroid-helper/waydroid-helper 自 2026-09 起停滞；fork 的
;;;   main 领先上游并新增了 Guix 打配脚本（waydroid-helper.scm）、CI 等内容，
;;;   本定义即以该脚本为蓝本改造。
;;; - waydroid 本体不是依赖：GUI 通过 PATH 调用 waydroid / waydroid-cli 等
;;;   命令，wrapper 的 PATH 用 prefix 语义保留会话 PATH，用户 profile 里的
;;;   waydroid 包照常可见。
;;; - Guix 无 systemd / dbus-1 的 pc 文件：传空 -Dsystemd-* / -Ddbus-* 关闭
;;;   服务文件安装（meson 侧对应 required:false 分支）。
;;; - 上游脚本的 bin-labels 查 "bash" 而 inputs 给的是 bash-minimal（label
;;;   不一致导致 bash 不进 wrapper PATH）；此处直接用 gexp 引用展开路径，
;;;   不再经过 assoc-ref 查表。
;;; - waydroid-cli 经 pkexec 以极简环境运行，只补 PATH；GUI 主程序补全套
;;;   GI_TYPELIB_PATH / PYTHONPATH / GSETTINGS_SCHEMA_DIR / XDG_DATA_DIRS。
;;; - gobject-introspection 留在 inputs（lint 会提示应为 native-input，此处
;;;   为已知误报）：GUI 运行时经 GI_TYPELIB_PATH 加载其 out 里的
;;;   GLib/GObject 等 typelib， propagated 路径同官方 gjs 包。
(define-public waydroid-helper
  (let ((commit "a3868dddff7e0674e732c04797c96c46061a7ccd")
        (revision "1"))
    (package
      (name "waydroid-helper")
      (version (git-version "0.2.9" revision commit))
      (source
       (origin
        (method git-fetch)
        (uri (git-reference
              (url "https://github.com/ShineBreaker/waydroid-helper")
              (commit commit)))
        (file-name (git-file-name name version))
        (sha256
         (base32 "0ghd2xv4rapzp8xaxz7nz4vni85sfsxrscmln5zqd2cgvgdjsvrq"))))
      (build-system meson-build-system)
      (arguments
       (list
        #:configure-flags #~(list "-Dsystemd-system-unit-dir="
                                  "-Dsystemd-user-unit-dir="
                                  "-Ddbus-service-dir="
                                  "-Ddbus-policy-dir=")
        ;; pytest 用例要 import Gtk typelib 且 meson test 会重置环境变量，
        ;; 构建容器无图形栈；单测在源码树用 guix shell + pytest 单独验证。
        #:tests? #f
        #:phases
        #~(let ((py-site
                 (string-append "/lib/python"
                                #$(version-major+minor (package-version python))
                                "/site-packages")))
            (modify-phases %standard-phases
              (add-after 'install 'wrap-program-paths
                (lambda* (#:key inputs outputs #:allow-other-keys)
                  (let* ((out (assoc-ref outputs "out"))
                         (python-path
                          (map (lambda (pkg)
                                 (string-append pkg py-site))
                               (list #$python-pygobject
                                     #$python-pycairo
                                     #$python-pywayland
                                     #$python-dbus
                                     #$python-aiofiles
                                     #$python-httpx
                                     #$python-pyyaml)))
                         (gi-path
                          (map (lambda (pkg)
                                 (string-append pkg "/lib/girepository-1.0"))
                               (list #$gtk #$libadwaita #$vte #$graphene
                                     #$gdk-pixbuf #$gobject-introspection
                                     #$pango #$harfbuzz #$cairo #$glib)))
                         (path-dirs
                          (append
                           (list (string-append out "/bin")
                                 (string-append #$bash-minimal "/bin")
                                 (string-append #$coreutils-minimal "/bin")
                                 (string-append #$grep "/bin")
                                 (string-append #$sed "/bin")
                                 (string-append #$tar "/bin")
                                 (string-append #$pciutils "/bin")
                                 (string-append #$fakeroot "/bin")))))
                    (wrap-program (string-append out "/bin/waydroid-helper")
                      `("PATH" ":" prefix ,path-dirs)
                      `("GI_TYPELIB_PATH" ":" prefix ,gi-path)
                      `("PYTHONPATH" ":" prefix ,python-path)
                      `("GSETTINGS_SCHEMA_DIR" ":" prefix
                        (,(string-append out "/share/glib-2.0/schemas")))
                      `("XDG_DATA_DIRS" ":" prefix
                        (,(string-append out "/share"))))
                    ;; 特权 CLI：pkexec 环境下路径极简，只补 PATH。
                    (wrap-program (string-append out "/bin/waydroid-cli")
                      `("PATH" ":" prefix ,path-dirs)))))))))
      (native-inputs
       `(("gettext-minimal" ,gettext-minimal)
         ("python-wrapper" ,python-wrapper)
         ("desktop-file-utils" ,desktop-file-utils)
         ("glib:bin" ,glib "bin")           ; glib-compile-schemas
         ("gtk:bin" ,gtk "bin")))            ; gtk4-update-icon-cache
      (inputs
       `(("bash-minimal" ,bash-minimal)
         ("coreutils-minimal" ,coreutils-minimal)
         ("grep" ,grep)
         ("sed" ,sed)
         ("tar" ,tar)
         ("pciutils" ,pciutils)
         ("fakeroot" ,fakeroot)
         ("gtk" ,gtk)                        ; typelib 在 out output
         ("libadwaita" ,libadwaita)
         ("vte" ,vte)
         ("graphene" ,graphene)
         ("gdk-pixbuf" ,gdk-pixbuf)
         ("gobject-introspection" ,gobject-introspection)
         ("glib" ,glib)
         ("pango" ,pango)
         ("harfbuzz" ,harfbuzz)
         ("cairo" ,cairo)
         ("python" ,python)
         ("python-pygobject" ,python-pygobject)
         ("python-pycairo" ,python-pycairo)
         ("python-pywayland" ,python-pywayland)
         ("python-dbus" ,python-dbus)
         ("python-aiofiles" ,python-aiofiles)
         ("python-httpx" ,python-httpx)
         ("python-pyyaml" ,python-pyyaml)))
      (home-page "https://github.com/ShineBreaker/waydroid-helper")
      (synopsis "Configure Waydroid, manage key mappings and install extensions")
      (description
       "Waydroid Helper is a GTK4/libadwaita GUI application for
configuring Waydroid, managing key mappings and installing extensions.  It
ships a main GUI process, a separate key-mapper overlay process, and a
privileged helper CLI (@command{waydroid-cli}) invoked through pkexec.")
      ;; 上游有 tag 线（v0.2.9 等），但用户要求打包 fork 开发主线的 git 版本；
      ;; commit 追踪由 Python updater 的 let-git-version 适配逻辑负责。
      (properties `((with-latest-git-commit . #t)))
      (license license:gpl3))))

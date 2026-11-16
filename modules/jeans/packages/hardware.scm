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
   #:use-module ((gnu packages freedesktop)
                 #:select ((fprintd . fprintd/upstream)
                           (libfprint . libfprint/upstream)))
   #:use-module (gnu packages gcc)
   #:use-module (gnu packages gnome)
   #:use-module (gnu packages gtk)
   #:use-module (gnu packages icu4c)
   #:use-module (gnu packages instrumentation)
   #:use-module (gnu packages kerberos)
   #:use-module (gnu packages linux)
   #:use-module ((gnu packages power)
                 #:select ((tuned . tuned/upstream)))
   #:use-module (gnu packages libunwind)
   #:use-module (gnu packages tls)
   #:use-module (gnu packages web)
   #:use-module (gnu packages xorg)
   #:use-module (guix build utils)
  #:use-module (jeans build-system binary)
   #:use-module (guix build-system gnu)
   #:use-module (guix build-system linux-module)
   #:use-module (guix download)
   #:use-module (guix git-download)
   #:use-module (guix gexp)
   #:use-module (guix packages)
   #:use-module (guix utils))

(define-public opentabletdriver-udev-rules
  (package
    (name "opentabletdriver-udev-rules")
    (version "0.6.8.1")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
              (url "https://github.com/OpenTabletDriver/OpenTabletDriver")
              (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256
          (base32 "01xsnms8525a2k5n27z9z9dq2yxpbq4gx75wnp9iv77lhbz5dl5m"))))
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
                           (output (get-string-all pipe))
                           (status (close-pipe pipe)))
                      (unless (eqv? 0 (status:exit-val status))
                        (error "generate-rules.sh failed" status))
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
 ;;; on RPATH alongside the static set.  That RPATH only covers dlopens
 ;;; the apphost's own libraries issue: glibc dlopen consults only the
 ;;; *caller's* RUNPATH, and bare-soname P/Invokes are issued by
 ;;; libcoreclr (whose RUNPATH is nonguix's runtime plan), so the apphost
 ;;; RPATH is invisible to them.  Those resolve via .NET's
 ;;; assembly-directory probe instead (NativeLibrary tries
 ;;; <BaseDir>/<soname> first): HidSharp dlopens libudev.so.1 for hidraw
 ;;; enumeration (without it the device list is silently empty -- "No
 ;;; tablets were detected"), artist mode dlopens libevdev.so.2 (Guix's
 ;;; libevdev also carries the libevdev_uinput_* symbols, so the one
 ;;; soname covers the virtual device too), the GUI dlopens
 ;;; libnotify.so.4, and display handling P/Invokes libX11.so.6 plus
 ;;; libXrandr.so.2 (XScreen, the X11 fallback); Wayland needs no native
 ;;; library at all (WaylandDisplay is the pure-managed WaylandNET
 ;;; client).  All these sonames are symlinked next to the bundles.  The
 ;;; display pick is env-driven (WAYLAND_DISPLAY else DISPLAY, else a
 ;;; doomed XScreen), so the daemon must be started inside the graphical
 ;;; session -- see the wait-for-display wrapper in jeans home services
 ;;; hardware.
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
    (arguments
     (list #:unpack-method 'tar
           ;; source 是 url-fetch/tarbomb（下载时已解包的目录）：目录分支只拷贝
           ;; 不 chdir；若是未解包的归档文件，散装 tarball 才会 chdir 进首个子目录。
           ;; 'bsdtar 在此不适用（它只能读归档文件）。
           #:install-plan
           #~'(("./" "share/dotnet/"))
           #:patchelf-plan
           ;; nonguix 形状 ((BIN (SPECS ...))) 展平为 ((PATH SPEC ...) ...)。
           ;; PATH 是输出内相对路径（nonguix 是构建目录相对，故多了 share/dotnet/ 前缀）。
           ;; 版本号写死面值，随 version 一起 bump（见上注释）。末两条同路径
           ;; （与现状一致：后者覆盖前者的 RPATH）。
           #~'(("share/dotnet/dotnet" "gcc:lib" "zlib")
               ("share/dotnet/host/fxr/8.0.25/libhostfxr.so" "gcc:lib")
               ("share/dotnet/shared/Microsoft.NETCore.App/8.0.25/createdump" "gcc:lib")
               ("share/dotnet/shared/Microsoft.NETCore.App/8.0.25/libclrjit.so" "gcc:lib")
               ("share/dotnet/shared/Microsoft.NETCore.App/8.0.25/libclrgc.so" "gcc:lib")
               ("share/dotnet/shared/Microsoft.NETCore.App/8.0.25/libcoreclr.so"
                "gcc:lib" "icu4c")
               (#$(string-append "share/dotnet/shared/Microsoft.NETCore.App/8.0.25/"
                                 "libcoreclrtraceptprovider.so")
                "gcc:lib" "lttng-ust")
               ("share/dotnet/shared/Microsoft.NETCore.App/8.0.25/libhostpolicy.so"
                "gcc:lib")
               ("share/dotnet/shared/Microsoft.NETCore.App/8.0.25/libmscordaccore.so"
                "gcc:lib")
               ("share/dotnet/shared/Microsoft.NETCore.App/8.0.25/libmscordbi.so"
                "gcc:lib")
               ("share/dotnet/shared/Microsoft.NETCore.App/8.0.25/libSystem.Native.so"
                "gcc:lib")
               (#$(string-append "share/dotnet/shared/Microsoft.NETCore.App/8.0.25/"
                                 "libSystem.Globalization.Native.so")
                "gcc:lib")
               (#$(string-append "share/dotnet/shared/Microsoft.NETCore.App/8.0.25/"
                                 "libSystem.IO.Compression.Native.so")
                "zlib")
               (#$(string-append "share/dotnet/shared/Microsoft.NETCore.App/8.0.25/"
                                 "libSystem.Net.Security.Native.so")
                "gcc:lib")
               (#$(string-append "share/dotnet/shared/Microsoft.NETCore.App/8.0.25/"
                                 "libSystem.Net.Security.Native.so")
                "mit-krb5")
               (#$(string-append "share/dotnet/shared/Microsoft.NETCore.App/8.0.25/"
                                 "libSystem.Security.Cryptography.Native.OpenSsl.so")
                "openssl"))))
    ;; patchelf 由 jeans-binary 按 #:patchelf? 自动注入，无需 native-inputs。
    ;; 旧 nonguix 模板里的 patchelf-writable 阶段不再需要（基座逐文件 chmod）。
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
                ;; Bare-soname dlopens from the .NET runtime (libudev for
                ;; HidSharp's hidraw enumeration, libevdev for artist
                ;; mode's uinput device, libnotify for GUI notifications,
                ;; libX11/libXrandr for the X11 fallback display): the
                ;; apphost RPATH is invisible to libcoreclr's dlopen, but
                ;; NativeLibrary probes this directory first.
                (symlink (string-append (assoc-ref inputs "eudev") "/lib/libudev.so.1")
                         (string-append libdir "/libudev.so.1"))
                (symlink (string-append (assoc-ref inputs "libevdev")
                                        "/lib/libevdev.so.2")
                         (string-append libdir "/libevdev.so.2"))
                (symlink (string-append (assoc-ref inputs "libnotify")
                                        "/lib/libnotify.so.4")
                         (string-append libdir "/libnotify.so.4"))
                (symlink (string-append (assoc-ref inputs "libx11")
                                        "/lib/libX11.so.6")
                         (string-append libdir "/libX11.so.6"))
                (symlink (string-append (assoc-ref inputs "libxrandr")
                                        "/lib/libXrandr.so.2")
                         (string-append libdir "/libXrandr.so.2"))
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
       ("eudev" ,eudev)
       ("glibc" ,glibc)
       ("gcc:lib" ,gcc "lib")
       ("libnotify" ,libnotify)
       ("libunwind" ,libunwind)
       ("libx11" ,libx11)
       ("libxrandr" ,libxrandr)
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

;;; i915-sriov-dkms 是标准 kbuild 外部模块：顶层 Makefile 通过
;;; `make -C $KDIR M=$PWD` 编出 intel_sriov_compat、i915、xe 三个模块，
;;; linux-module-build-system 的 build/install 阶段正好驱动它，无需额外阶段。
;;;
;;; 本定义不写 #:linux：operating-system 的 kernel-loadable-modules 会经
;;; gnu/services.scm 的 package-for-kernel 把该关键字重绑到实际内核，写死默认
;;; 内核反而破坏这条路径（同机 v4l2loopback-linux-module 的既有做法）。
;;;
;;; 上游只支持 6.18.x–7.3.x 内核，include/config.h 在缺少 CONFIG_HMM_MIRROR 或
;;; CONFIG_MMU_NOTIFIER 时直接 #error。本包的实际用法是加进
;;; kernel-loadable-modules 由目标内核重建，所以这里只验证依赖解析与源码哈希，
;;; 没有对 linux-libre 做真构建。
;;;
;;; build 阶段删掉 kvmgt 一行：上游 Makefile 无条件 `obj-m += kvmgt.o`，但
;;; gvt/Makefile 的对象列表挂在 `kvmgt-$(CONFIG_DRM_I915_GVT)` 上。目标内核
;;; 关掉 GVT-g 后（CONFIG_DRM_I915_GVT=n，本机 machine trim 即如此），kvmgt-y
;;; 为空，ld 去链接一个没有输入对象的复合目标，报
;;; `ld: read in flex scanner failed`，整包构建失败。kvmgt 是 GVT-g 的 KVM 侧
;;; 支持，与 SR-IOV 无关，删掉不影响直通。
(define-public i915-sriov-linux-module
  (package
    (name "i915-sriov-linux-module")
    (version "2026.11.05")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
              (url "https://github.com/strongtz/i915-sriov-dkms")
              (commit version)))
        (file-name (git-file-name name version))
        (sha256
          (base32 "0azy55v6z6ap01xb1rnhj8imbqzakm18j6lqwn86770hmy8yamsq"))))
    (build-system linux-module-build-system)
    (arguments
     (list #:tests? #f
           #:phases
           #~(modify-phases %standard-phases
               (add-after 'unpack 'drop-kvmgt
                 (lambda _
                   (substitute* "drivers/gpu/drm/i915/Makefile"
                     (("^obj-m \\+= kvmgt.o\n") "")))))))
    (home-page "https://github.com/strongtz/i915-sriov-dkms")
    (synopsis "Intel i915 and xe drivers with SR-IOV support")
    (description
      "Linux i915 and xe drivers backported from mainline and extended with
SR-IOV support, letting an Intel GPU expose virtual functions that can be
assigned to virtual machines.  Both the host and the guest need to load the
module; virtual functions are enabled on the kernel command line through
@code{intel_iommu=on} together with @code{i915.max_vfs=} or
@code{xe.max_vfs=}.  Kernels 6.18.x through 7.3.x are supported.")
    (properties '((upstream-name . "i915-sriov-dkms")))
    (license (list license:gpl2 license:expat))
    (supported-systems '("x86_64-linux"))))

;;; —— 指纹栈 ——
;;;
;;; 主线 libfprint 1.94.5 / fprintd 1.94.2 都早于 goodixmoc 驱动可用的
;;; 1.94.9（Goodix 27c6:689a 等 USB 传感器所需），而两包上游最新 release
;;; 分别是 1.94.100 与 1.94.5。以 -next 记号提供这两个最新 release，
;;; 不覆盖主线同名包：主线追上后删除本组定义即可。
;;;
;;; libfprint-next 只换 TLS 后端：goodixmoc 走 USB 传输，不需要 nss 的
;;; URU4x00 证书支持，改 openssl 可少拉一整棵嵌入运行时；同时必须覆盖
;;; configure-flags —— 主线的 -Dc_link_args 里写死了 lib/nss。
;;;
;;; fprintd-next 的 arguments 不能继承主线：1.94.5 把 systemd 依赖改成
;;; `dependency(get_option('libsystemd'))`，主线用 substitute 改
;;; `dependency('libsystemd')` 的补丁匹配不到，配置直接报
;;; "Dependency libsystemd not found"。这里改走 meson 自己的
;;; -Dlibsystemd=libelogind 选项（1.94.5 起提供），并保留把 dbus/polkit
;;; 输出目录改指 $out 的那段（Guix 的 meson 默认装到上游 owner 包）。

(define %libfprint-version "1.94.100")
(define %fprintd-version "1.94.5")

(define-public libfprint-next
  (package
    (inherit libfprint/upstream)
    (name "libfprint-next")
    (version %libfprint-version)
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
              (url "https://gitlab.freedesktop.org/libfprint/libfprint")
              (commit (string-append "v" %libfprint-version))))
        (file-name (git-file-name "libfprint" %libfprint-version))
        (sha256
          (base32 "1c5n1xl7b32hssfs6yl4ndn1dfs6aqa26igmpahpym53l19zq017"))))
    (arguments
      (list #:configure-flags
            #~(list "-Dudev_hwdb=enabled"
                    (string-append "-Dudev_hwdb_dir=" #$output
                                   "/lib/udev/hwdb.d")
                    (string-append "-Dudev_rules_dir=" #$output
                                   "/lib/udev/rules.d"))))
    (inputs
      (modify-inputs (package-inputs libfprint/upstream)
                     (replace "nss" openssl)))
    (properties '((upstream-name . "libfprint")))))

(define-public fprintd-next
  (package
    (inherit fprintd/upstream)
    (name "fprintd-next")
    (version %fprintd-version)
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
              (url "https://gitlab.freedesktop.org/libfprint/fprintd")
              (commit (string-append "v" %fprintd-version))))
        (file-name (git-file-name "fprintd" %fprintd-version))
        (sha256
          (base32 "1rf80qzx4fx5y3x04n7wb58ywga34agjd42ymlvz3kdl8kkk6qk8"))))
    (arguments
      (list #:configure-flags
            #~(list "-Dsystemd_system_unit_dir=/tmp"
                    "-Dlibsystemd=libelogind"
                    (string-append "-Ddbus_service_dir=" #$output
                                   "/share/dbus-1/system-services")
                    (string-append "-Dpam_modules_dir=" #$output
                                   "/lib/security"))
            #:phases
            #~(modify-phases %standard-phases
                (add-before 'configure 'patch-output-directories
                  (lambda* (#:key outputs #:allow-other-keys)
                    (let ((out (assoc-ref outputs "out")))
                      (substitute* "meson.build"
                        (("(dbus_interfaces_dir = ).*" _ set)
                         (string-append set "'" out
                                        "/share/dbus-1/interfaces'\n"))
                        (("(polkit_policy_directory = ).*" _ set)
                         (string-append set "'" out
                                        "/share/polkit-1/actions/'\n"))
                        (("(dbus_data_dir = ).*" _ set)
                         (string-append set "get_option('prefix')"
                                        " / get_option('datadir')\n")))))))
            #:tests? #f))
    (inputs
      (modify-inputs (package-inputs fprintd/upstream)
                     (replace "libfprint" libfprint-next)))
    (properties '((upstream-name . "fprintd")))))

;;; tuned 主线在 patch-paths 阶段把 tuned/consts.py 里所有 /etc/tuned 改写成
;;; $out/etc/tuned（覆盖 GLOBAL_CONFIG_FILE、USER_PROFILES_DIR、
;;; PPD_CONFIG_FILE 等全部运行时路径），而 tuned-service-type 的 activation
;;; 把配置写到 /etc/tuned：两条路径不搭界，activation 生成的 tuned-main.conf、
;;; profiles 与 ppd.conf 从未被读取，系统一直跑内置档位。这里在 install 后把
;;; store 内路径整体改回 /etc/tuned，让 activation 产物真正生效。
(define-public tuned
  (package
    (inherit tuned/upstream)
    (arguments
      (substitute-keyword-arguments (package-arguments tuned/upstream)
        ((#:phases phases '%standard-phases)
         #~(begin
             (use-modules (guix build utils))
             (modify-phases #$phases
               (add-after 'install 'point-tuned-at-etc
                 (lambda* (#:key outputs #:allow-other-keys)
                   (let ((consts (car (find-files
                                       (string-append (assoc-ref outputs "out")
                                                      "/lib")
                                       "^consts\\.py$"))))
                     (substitute* consts
                       (("/gnu/store/[^/]+/etc/tuned")
                        "/etc/tuned"))))))))))))

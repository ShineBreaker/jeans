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
  #:use-module (gnu packages gnome)        ; libsoup, glib-networking, gnome-keyring,
                                           ; libsecret
  #:use-module (gnu packages golang)       ; go
  #:use-module (gnu packages gtk)          ; gtk, gtk+, cairo, pango, harfbuzz,
                                           ; graphene, gdk-pixbuf, at-spi2-core
  #:use-module (gnu packages image)        ; libjpeg-turbo, libpng
  #:use-module (gnu packages linux)        ; eudev
  #:use-module (gnu packages nss)          ; nss, nss-certs
  #:use-module (gnu packages ncurses)
  #:use-module (gnu packages node)         ; node
  #:use-module (gnu packages pulseaudio)   ; pulseaudio
  #:use-module (gnu packages python)       ; python (asar 定长替换)
  #:use-module (gnu packages rust-apps)    ; ripgrep
  #:use-module (gnu packages tls)          ; openssl
  #:use-module (gnu packages version-control) ; git
  #:use-module (gnu packages vulkan)       ; vulkan-loader
  #:use-module (gnu packages web)          ; json-c
  #:use-module (gnu packages webkit)       ; webkitgtk, webkitgtk-for-gtk3
  #:use-module (gnu packages xdisorg)      ; libxkbcommon
  #:use-module (gnu packages xml)          ; expat
  #:use-module (gnu packages xorg)         ; libx11, libxcb, libxcomposite, ...
  #:use-module (guix build-system copy)    ; opencode-bin
  #:use-module (guix build-system go)      ; cindy-browser-native
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
;;; 新包请用 electron-build-system，不再各写各的。

(define (disable-electron-updater-phase application-directory)
  #~(lambda _
      ;; electron-updater treats "package-type" as permission to replace the
      ;; application with a downloaded .deb; without it getAutoUpdater() falls
      ;; back to AppImageUpdater, which stays inactive when $APPIMAGE is unset.
      ;; app-update.yml is the provider manifest — dropping it too means no
      ;; update config ships at all (applies to non-electron-build-system
      ;; packages; electron-build-system's phase does the same).
      (let ((resources (string-append #$output "/lib/" #$application-directory
                                      "/resources")))
        (for-each (lambda (file)
                    (let ((path (string-append resources "/" file)))
                      (when (file-exists? path)
                        (delete-file path))))
                  '("package-type" "app-update.yml")))))

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
    (version "0.10.4")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/Hmbown/CodeWhale/releases/download/"
             "v" version "/codewhale-linux-x64.tar.gz"))
       (sha256
        (base32 "0dxbm06ikbj7c4xfzsjnh1pb1y0vvi04r0n4ca4vwkxmfki069wv"))))
    (build-system binary-build-system)
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

;;; Pi is an MIT-licensed, Bun-compiled coding-agent CLI.  The Linux release
;;; keeps the executable and its themes, WASM asset, export templates and
;;; native X11 helper in one directory.  Bun compiled executables are
;;; self-locating, so keep that layout and the real pi filename intact.
(define-public pi-bin
  (package
    (name "pi-bin")
    (version "1.7.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/earendil-works/pi/releases/download/v"
             version "/pi-linux-x64.tar.gz"))
       (sha256
        (base32 "0jlgqqm410m2js153aar85wd3is5vi86sx6j3pjpywizx1kyvxs2"))))
    (build-system binary-build-system)
    (arguments
     (list
      #:unpack-method 'gnu-unpack
      #:install-plan #~'(("./" "libexec/pi/"))
      #:patchelf? #f
      #:wrap? #f
      #:modules '((jeans build binary)
                  (guix build utils))
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'install 'install-launcher
            (lambda* (#:key inputs #:allow-other-keys)
              (let* ((out #$output)
                     (bin (string-append out "/bin"))
                     (executable (string-append out "/libexec/pi/pi"))
                     (ld-so (string-append (assoc-ref inputs "glibc")
                                           #$(glibc-dynamic-linker)))
                     (library-path
                      (string-join
                       (map (lambda (label)
                              (string-append (assoc-ref inputs label) "/lib"))
                            '("glibc" "gcc:lib" "libxcb" "libxau"
                              "libxdmcp"))
                       ":"))
                     (wrapper (string-append bin "/pi")))
                (mkdir-p bin)
                (call-with-output-file wrapper
                  (lambda (port)
                    (format port "#!~a/bin/bash~%"
                            (assoc-ref inputs "bash-minimal"))
                    (format port "if [ -z \"$NIX_LD\" ]; then export NIX_LD=\"~a\"; fi~%"
                            ld-so)
                    (format port
                            (string-append
                             "if [ -n \"$NIX_LD_LIBRARY_PATH\" ]; then~%"
                             "  export NIX_LD_LIBRARY_PATH=\"~a:$NIX_LD_LIBRARY_PATH\"~%"
                             "else~%  export NIX_LD_LIBRARY_PATH=\"~a\"~%fi~%")
                            library-path library-path)
                    (format port
                            (string-append
                             "if [ -n \"$LD_LIBRARY_PATH\" ]; then~%"
                             "  export LD_LIBRARY_PATH=\"~a:$LD_LIBRARY_PATH\"~%"
                             "else~%  export LD_LIBRARY_PATH=\"~a\"~%fi~%")
                            library-path library-path)
                    (format port "exec ~a \"$@\"~%" executable)))
                (chmod wrapper #o755)))))))
    (inputs
     `(("bash-minimal" ,bash-minimal)
       ("gcc:lib" ,gcc "lib")
       ("glibc" ,glibc)
       ("libxcb" ,libxcb)
       ("libxau" ,libxau)
       ("libxdmcp" ,libxdmcp)))
    (properties `((upstream-name . "pi")))
    (home-page "https://pi.dev")
    (synopsis "Minimal, extensible agent harness for the terminal")
    (description
     "Pi is a minimal, extensible agent harness for the terminal.  It can be
customized with extensions, skills, prompt templates and themes, and supports
interactive, print, JSON and RPC modes.  This package provides the upstream
prebuilt Linux release.  On Guix System, enable the nix-ld service to run this
prebuilt binary.")
    (license license:expat)
    (supported-systems '("x86_64-linux"))))

;;; Cindy Chrome（my-browser 插件）的 native messaging host。
;;;
;;; 扩展在 Chrome 里调 chrome.runtime.sendNativeMessage 起这个 host：host 先
;;; 校验「调用方是不是可信浏览器」，再把连接令牌 POST 给 Cindy 本地桥，完成
;;; 自动配对。上游只认 /opt/google/chrome/chrome、/usr/lib/chromium/chromium
;;; 这类发行版路径（直接读 /proc/<ppid>/exe），Guix 的 store 路径一律判
;;; BROWSER_CALLER_UNVERIFIED，扩展就永远停在「等待配对」。
;;;
;;; 源码逐字取自上游 0.4.95（cindy-official-plugins/my-browser/native-host，
;;; Apache-2.0，只有 main.go + parent_linux.go + go.mod）；补丁见
;;; jeans/patches/cindy-browser-native-guix-browsers.patch。上游改协议时 diff
;;; 这三份文件即可，别在此处另写实现。
;;;
;;; 目录路径由 go.mod 定位：search-path 只认普通文件，对目录返回 #f；而
;;; -L modules 下 current-source-directory 也是 #f。
(define %cindy-native-host-directory
  (dirname (canonicalize-path
            (search-path %load-path
                         "jeans/packages/cindy/native-host/go.mod"))))

(define %cindy-browser-native-source
  (local-file %cindy-native-host-directory
              "cindy-browser-native-0.4.95"
              #:recursive? #t))

(define %cindy-browser-native-patch
  (local-file (canonicalize-path
               (search-path
                %load-path
                "jeans/patches/cindy-browser-native-guix-browsers.patch"))))

(define-public cindy-browser-native
  (package
    (name "cindy-browser-native")
    (version "0.4.95")
    (source %cindy-browser-native-source)
    (build-system go-build-system)
    (arguments
     (list #:import-path "cindy-browser-native"
           #:install-source? #f
           #:tests? #f
           ;; go-build-system 的 lower 不接 #:patches，只能在 unpack 后自己打。
           #:phases
           #~(modify-phases %standard-phases
               (add-after 'unpack 'patch-guix-browsers
                 (lambda* (#:key import-path #:allow-other-keys)
                   (with-directory-excursion
                       (string-append (getenv "GOPATH") "/src/" import-path)
                     (invoke "patch" "--batch" "-p1" "-i"
                             #$%cindy-browser-native-patch)))))))
    (home-page "https://github.com/makecindy/cindy-official-plugins")
    (synopsis "Native messaging host for the Cindy Chrome extension")
    (description
     "This package provides the native messaging host that the Cindy Chrome
browser extension uses to bind to the Cindy desktop application.  The
upstream host only trusts browsers installed under /opt and /usr/lib; this
build also accepts a browser packaged in the store, which is how Guix
installs Chromium and friends.")
    (license license:asl2.0)
    (supported-systems '("x86_64-linux" "aarch64-linux"))))

;;; Cindy: open-source AI agent desktop client (Electron, Apache-2.0).
;;;
;;; The upstream .deb (data.tar.zst, unlike the xz used by opencode/paseo)
;;; installs an Electron bundle under /usr/lib/cindy:
;;;   - Cindy                 the Electron main executable (GUI entry)
;;;   - chrome-sandbox        setuid sandbox helper; installed but not
;;;                           setuid-root (namespace sandbox suffices)
;;;   - resources/app.asar.unpacked/node_modules/...  native addons
;;;     (better-sqlite3, node-pty, sharp) in nested directories; sharp
;;;     carries its own $ORIGIN-relative RPATH pointing at the bundled
;;;     libvips, so patchelf must --prepend-rpath (existing RPATH kept)
;;;     rather than --set-rpath.
;;;   - resources/tools/ripgrep/rg   statically linked, shipped as-is.
;;;   - resources/tools/remote-desktop/cindy-linux-desktop-{capture,
;;;     clipboard,input}  Wayland 远程桌面 sidecar，NEEDED
;;;     libwayland-client/libturbojpeg/libpng——对应 wayland、
;;;     libjpeg-turbo、libpng 三个 input，升级时重查。
;;;
;;; @img/ 子树（sharp 的预编译 libvips 与 .node）自包含：$ORIGIN RPATH
;;; 已自足，patchelf-exclude 原样保留。libvips-cpp.so 的 .init 紧贴
;;; ELF 头（vaddr 0x25c），patchelf 扩 phdr 将其移位后不更新 DT_INIT，
;;; patch 即变砖（ld.so 调旧址段错误，0.1.103 实证）。
;;;
;;; Sidecars proxy.mjs / cc-mgr.mjs are "#!/usr/bin/env node" scripts;
;;; Electron spawns them via ELECTRON_RUN_AS_NODE, so no Node.js input.
;;; electron-updater: no resources/package-type file in this bundle, so
;;; the disable-electron-updater phase is unnecessary.
;;;
;;; Linux 分支的系统工具与浏览器探测全部写死成 /usr/bin/... 绝对路径（
;;; google-chrome、chromium、loginctl、wl-paste、python3、grim、xdotool、
;;; tar、hyprctl …），Guix System 只有 /usr/bin/env，于是浏览器自动化报
;;; 「未检测到本机浏览器」，锁屏、远程桌面凭据/输入 sidecar、本地模型
;;; 解包也一并静默降级。同一批代码还假设 POSIX 标配的 /bin/bash、/bin/zsh、
;;; /bin/ps、/bin/true（Guix 只有 /bin/sh），那些是 spawn/execFile 的目标，
;;; 落空即 ENOENT——强制退出、脚本导入、用户级工具安装、进程身份探测
;;; 全在里面。patch-guix-bin-paths 阶段（见 jeans/build/asar-guix-paths.py
;;; 的 cindy 表）注入 gxResolveBin() 把命中字面量改走
;;; /run/current-system/profile/bin → ~/.guix-home/profile/bin → $PATH；该
;;; 阶段整包重打包，必须排在 patch-bootstrap-tdz 之后。
;;; resources/ 下不在 asar 里的 pi-manager.mjs 另有固定 PATH，由
;;; patch-resource-paths 就地替换。

;;; 0.1.143 的 Linux bundle（app.asar 内成对的上游 .deb 字节一致）把
;;; withAvailabilityPolicyMutation 的 const 声明排在 bootstrap-electron-*.js
;;; 里使用它的模块之后：模块顶层构造 device-link settings 时触发
;;; "Cannot access 'withAvailabilityPolicyMutation' before initialization"，
;;; 主进程启动即死。这里等长移动声明到使用点之前（文件字节数不变，
;;; asar offset 表无需重算）；该 app 的 asar integrity fuse 已开启，
;;; header 里每个文件带 SHA256，故同步重算整文件与 4MiB 分块哈希。
;;; 上游修复后（声明已在使用点之前或锚点消失）脚本自行跳过。
(define %cindy-bootstrap-tdz-patch
  (string-append
   "import sys,json,struct,hashlib\n"
   "d=bytearray(open(sys.argv[1],'rb').read())\n"
   "hs=struct.unpack('<I',d[12:16])[0]\n"
   "h=json.loads(bytes(d[16:16+hs]))\n"
   "base=(16+hs+7)&~7\n"
   "def find(n):\n"
   "    for k,v in n.get('files',{}).items():\n"
   "        if 'files' in v:\n"
   "            r=find(v)\n"
   "            if r: return r\n"
   "        elif k.startswith('bootstrap-electron-'): return v\n"
   "    return None\n"
   "e=find(h)\n"
   "assert e is not None, 'bootstrap-electron-*.js not found'\n"
   "D='const{withAvailabilityPolicyLock,rememberAvailabilityShare,"
   "withAvailabilityPolicyMutation}=createAvailabilityPolicy("
   "disableShareAvailability);'\n"
   "U='withAvailabilityPolicyMutation}),settingsStore_desktop='\n"
   "A='const{readDeviceLinkSettings'\n"
   "off=int(e['offset']);size=int(e['size']);st=base+off\n"
   "s=bytes(d[st:st+size]).decode('utf-8','surrogateescape')\n"
   "if s.count(D)!=1 or U not in s or s.find(D)<s.find(U):\n"
   "    print('cindy: bootstrap TDZ already fixed, skipping')\n"
   "    sys.exit(0)\n"
   "ui=s.find(U);di=s.find(D);ai=s.rfind(A,0,ui)\n"
   "assert ai>0 and di>ui\n"
   "ns=s[:ai]+D+s[ai:di]+s[di+len(D):]\n"
   "assert len(ns)==len(s)\n"
   "nb=ns.encode('utf-8','surrogateescape')\n"
   "assert len(nb)==size\n"
   "it=e.get('integrity')\n"
   "if it:\n"
   "    nh=hashlib.sha256(nb).hexdigest()\n"
   "    nbl=[hashlib.sha256(nb[i:i+4194304]).hexdigest()"
   " for i in range(0,len(nb),4194304)]\n"
   "    hdr=bytearray(bytes(d[16:16+hs]))\n"
   "    assert bytes(hdr).count(it['hash'].encode())==1\n"
   "    hdr=bytearray(bytes(hdr).replace(it['hash'].encode(),nh.encode()))\n"
   "    assert len(nbl)==len(it['blocks'])\n"
   "    for o,n in zip(it['blocks'],nbl):\n"
   "        assert len(o)==64 and bytes(hdr).count(o.encode())==1\n"
   "        hdr=bytearray(bytes(hdr).replace(o.encode(),n.encode()))\n"
   "    d[16:16+hs]=hdr\n"
   "d[st:st+size]=nb\n"
   "open(sys.argv[1],'wb').write(d)\n"
   "print('cindy: moved withAvailabilityPolicyMutation declaration "
   "before use site')\n"))

;;; 预编译 Electron 应用共用：把 bundle 里写死的系统路径改走 Guix profile
;;; （详见 jeans/build/asar-guix-paths.py 与它在 SPECS 里的 per-app 锚点表）。
;;; 目前用它的是 cindy-cn-bin、qoder-cn、zcode；新包只需加一条 SPECS。
(define %asar-guix-paths-script
  (local-file (canonicalize-path
               (search-path %load-path "jeans/build/asar-guix-paths.py"))
              "asar-guix-paths.py"))

(define-public cindy-cn-bin
  (package
    (name "cindy-cn-bin")
    (version "0.1.148")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/makecindy/cindy/releases/download/"
             "v" version "/cindy-" version "-linux-x64-cn.deb"))
       (sha256
        (base32 "011y1sh52waid97s8r5v6mm2xvsml38njfb1pbdk46jvsqabz7f1"))))
    (build-system electron-build-system)
    (arguments
     (list
      #:program "cindy"
      #:app-dir "lib/cindy"
      #:application-directory "cindy"
      ;; safeStorage 凭据持久化需要会话 secrets 服务：inputs 能定位到 gdbus /
      ;; gnome-keyring-daemon / gcr-prompter（即含 glib:bin / gnome-keyring /
      ;; gcr-3 三个输入）便自动启用 build/electron.scm 的
      ;; ensure-secret-service-phase（探测在位就不动，缺服务才兜底拉
      ;; gnome-keyring；用户显式 --password-store 永远最优先）。
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
      ;; @img/：$ORIGIN RPATH 自足，patch 反而触发 DT_INIT 失步 bug（见包
      ;; 上方注释）。
      #:patchelf-exclude
      #~'("lib/cindy/resources/app.asar.unpacked/node_modules/@img/")
      #:desktop-files
      #~'(("share/applications/cindy.desktop"
           "bin/cindy"
           "share/pixmaps/cindy.png"))
      #:modules '((guix build utils))
      #:phases
      #~(modify-phases (@ (jeans build electron) %standard-phases)
          (add-after 'install 'install-native-host
            (lambda _
              ;; Cindy 把 host 复制到 ~/.local/share/Cindy/browser-native/ 再写
              ;; NativeMessagingHosts 清单；补丁后的 JS 优先读这里
              ;; （lib/cindy/native-host/），读不到才回落到插件自带的那份。
              (let* ((out #$output)
                     (dir (string-append out "/lib/cindy/native-host"))
                     (dst (string-append dir "/cindy-browser-native"))
                     (src (string-append #$(this-package-input
                                           "cindy-browser-native")
                                         "/bin/cindy-browser-native")))
                (mkdir-p dir)
                (copy-file src dst)
                (chmod dst #o755))))
          (add-after 'install 'patch-resource-paths
            (lambda _
              ;; pi-manager 用固定 PATH 起 `bash -c`。Node 是用子进程 env 里的
              ;; PATH 去 execvp 的，Guix 下 /usr/bin:/bin:/usr/local/bin 里没有
              ;; bash，spawn 直接 ENOENT，pi 会话根本起不来。
              (substitute*
                  (string-append #$output
                                 "/lib/cindy/resources/pi-manager/pi-manager.mjs")
                (("PATH: \"/usr/bin:/bin:/usr/local/bin\",")
                 "PATH: (process.env.PATH || \"\") + \":/usr/bin:/bin:/usr/local/bin\","))))
          (add-after 'install 'patch-bootstrap-tdz
            (lambda _
              (invoke "python3" "-c" #$%cindy-bootstrap-tdz-patch
                      (string-append #$output
                                     "/lib/cindy/resources/app.asar"))))
          ;; 必须在 patch-bootstrap-tdz 之后：那个脚本做定长替换并重算受影响
          ;; 成员的哈希，本阶段整包重打包（offset 与全部 integrity 重排），
          ;; 顺序反过来会把前者的成果算进旧偏移。
          (add-after 'patch-bootstrap-tdz 'patch-guix-bin-paths
            (lambda _
              (invoke "python3" #$%asar-guix-paths-script "cindy"
                      (string-append #$output
                                     "/lib/cindy/resources/app.asar"))))
          (add-after 'patchelf 'install-bin
            (lambda _
              (let* ((out #$output)
                     (bin (string-append out "/bin"))
                     (exe (string-append out "/lib/cindy/Cindy")))
                (mkdir-p bin)
                (symlink exe (string-append bin "/cindy"))))))))
    (native-inputs (list binutils python tar xz zstd))
    (inputs `(("alsa-lib" ,alsa-lib)
              ("at-spi2-core" ,at-spi2-core)
              ("bash-minimal" ,bash-minimal)
              ("cindy-browser-native" ,cindy-browser-native)
              ("nss-certs" ,nss-certs)
              ("cairo" ,cairo)
              ("cups" ,cups)
              ("dbus" ,dbus)
              ("eudev" ,eudev)
              ("expat" ,expat)
              ("fontconfig-minimal" ,fontconfig)
              ("gcc:lib" ,gcc "lib")
              ("gcr" ,gcr-3)
              ("glibc" ,glibc)
              ("glib" ,glib)
              ("glib:bin" ,glib "bin")
              ("gnome-keyring" ,gnome-keyring)
              ("gtk+" ,gtk+)
              ("json-c" ,json-c)
              ("libx11" ,libx11)
              ("libxcb" ,libxcb)
              ("libxcomposite" ,libxcomposite)
              ("libxdamage" ,libxdamage)
              ("libxext" ,libxext)
              ("libxfixes" ,libxfixes)
              ("libjpeg-turbo" ,libjpeg-turbo)
              ("libpng" ,libpng)
              ("libsecret" ,libsecret)
              ("libxkbcommon" ,libxkbcommon)
              ("libxrandr" ,libxrandr)
              ("mesa" ,mesa)
              ("nspr" ,nspr)
              ("nss" ,nss)
              ("pango" ,pango)
              ("wayland" ,wayland)))
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

;;; codex-bin packages OpenAI's Codex CLI from the prebuilt "codex-package"
;;; release: the complete local package layout that 0.171.0+ requires to
;;; provision its app-server daemon -- bin/codex plus codex-code-mode-host,
;;; codex-exec-server, codex-path/rg and codex-resources/.  The bare
;;; single-binary tarball (codex-x86_64-unknown-linux-musl.tar.gz) makes the
;;; TUI exit with "this CLI has no complete local package".  Every ELF is
;;; static-pie with no interpreter, so it is installed as-is (no patchelf,
;;; no wrapper).  Upstream tags the Rust release line as "rust-vX.Y.Z" and
;;; mixes in -alpha pre-releases, hence the tag prefix.
(define-public codex-bin
  (package
    (name "codex-bin")
    (version "0.172.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/openai/codex/releases/download/rust-v"
             version
             "/codex-package-x86_64-unknown-linux-musl.tar.gz"))
       (sha256
        (base32 "14frl4sfv0jl6rikxl403nindf1wcrzy28h5dlb64zzdcl0b1qv3"))))
    (build-system binary-build-system)
    (arguments
     (list
      #:unpack-method 'gnu-unpack
      #:install-plan
      #~'(("bin/" "bin/")
          ("codex-package.json" "codex-package.json")
          ("codex-path/" "codex-path/")
          ("codex-resources/" "codex-resources/"))
      #:patchelf? #f
      #:wrap? #f
      #:modules '((jeans build binary)
                  (guix build utils))
      #:phases
      #~(modify-phases %standard-phases
          (replace 'unpack
            ;; 上游 tarball 没有统一顶层目录，gnu unpack 会 chdir 进第一个
            ;; 子目录 bin/，把 codex-package.json 与 codex-resources/ 留在
            ;; 上一层。直接 tar 解包，保持顶层布局。
            (lambda* (#:key source #:allow-other-keys)
              (invoke "tar" "xvf" source)))
          (add-after 'install 'make-executable
            (lambda _
              ;; daemon 安装前会校验这些文件的可执行位。
              (for-each (lambda (file)
                          (chmod (string-append #$output "/" file) #o755))
                        '("bin/codex"
                          "bin/codex-code-mode-host"
                          "bin/codex-exec-server"
                          "codex-path/rg"
                          "codex-resources/bwrap")))))))
    (properties '((upstream-name . "codex")
                  (release-tag-prefix . "^rust-v")))
    (home-page "https://github.com/openai/codex")
    (synopsis "OpenAI's coding agent that runs in the terminal")
    (description
     "Codex is OpenAI's local coding agent.  It reads and edits files and runs
commands in the current workspace, driving the model from the terminal.  This
package installs the upstream prebuilt Linux binary.")
    (license license:asl2.0)
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
    (version "1.5.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/github/app/releases/download/"
             "v" version "/GitHub-Copilot-linux-x64.deb"))
       (sha256
        (base32 "1hrjinzkils99fs9b5r5l8p58n2ixhjzw35jinrdg8fy7a05ajs7"))))
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
;;; codewhale-bin).

(define-public herdr-bin
  (package
    (name "herdr-bin")
    (version "0.9.5")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/ogulcancelik/herdr/releases/download/"
             "v" version "/herdr-linux-x86_64"))
       (sha256
        (base32 "17cjb6gxh2wna8vv4bil82dz0qflfrpjcckwswc037jaifyfin8l"))))
    (build-system binary-build-system)
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
    (version "0.7.2")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/MiniMax-AI/minimax-code/releases/download/"
             "v" version "/minimax-code-" version ".tar.gz"))
       (sha256
        (base32 "1r7lf7gabj74bnzqnncas3j2h56y6n4792rgnsx6qa25d5lmn1da"))))
    (build-system binary-build-system)
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
    (version "2.4.2")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/anomalyco/opencode/releases/download/"
             "v" version "/opencode-desktop-linux-amd64.deb"))
       (sha256
        (base32 "12jxji11rzkipk0fwkzpsxayj3r21wl4dd72zxdk455182491iy9"))))
    (build-system electron-build-system)
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
      #:imported-modules '((guix build utils))
      #:phases
      #~(modify-phases (@ (jeans build electron) %standard-phases)
          (add-after 'patchelf 'install-bin
            (lambda _
              (let* ((out #$output)
                     (bin (string-append out "/bin"))
                     (exe (string-append
                           out "/lib/opencode-desktop/ai.opencode")))
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
                   (find-files icon-dst "ai\\.opencode\\.png$")))))))))
    (native-inputs (list binutils tar xz))
    (inputs `(("alsa-lib" ,alsa-lib)
              ("at-spi2-core" ,at-spi2-core)
              ("bash-minimal" ,bash-minimal)
              ("nss-certs" ,nss-certs)
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
    (license license:expat)
    (supported-systems '("x86_64-linux"))))

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
;;;
;;; Startup: the daemon compiles every built-in plugin from TypeScript on each
;;; launch, behind startPaused, and only then starts accepting WebSocket
;;; connections — the desktop window shows nothing but the logo until that is
;;; done.  Run from a store path, esbuild's boundary resolve (buildContext
;;; .resolve) enumerates /gnu/store, tens of thousands of entries, once per
;;; import: 2-30 s per plugin, ~74 s before the first paint on this bundle.
;;; The same tree outside the store compiles in 10-300 ms.  The build therefore
;;; precompiles the built-in plugins (see modules/jeans/packages/paseo):
;;; it patches app.asar so compileDirectoryPlugin() prefers
;;; <plugin>/.paseo-precompiled.json for built-in plugins (falling back to
;;; compiling when version/id do not match), re-packs the archive with
;;; recomputed offsets and per-file integrity, and fails loudly if the upstream
;;; anchor disappears.

(define %paseo-precompile-script
  (local-file (canonicalize-path
               (search-path %load-path "jeans/packages/paseo/precompile.mjs"))
              "paseo-precompile.mjs"))

(define-public paseo-bin
  (package
    (name "paseo-bin")
    (version "0.18.1")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/getpaseo/paseo/releases/download/"
             "v" version "/Paseo-" version "-amd64.deb"))
       (sha256
        (base32 "0xgdq74a2yikv2hb527x90lm85s3addspvzw9cfg5dxjgw6njadc"))))
    (build-system electron-build-system)
    (arguments
     (list
      ;; 不套 asar-guix-paths：扫过 0.17.4 的 app.asar，Linux 可达的写死路径
      ;; 只有 /usr/bin/which（外面套了 existsSync 守卫，且有库兜底）与
      ;; /bin/bash（userInfo().shell 缺失时的兜底，正常用户走 SHELL），
      ;; 其余是 macOS 的 scutil/plutil/open。为诊断文案重建一次不值得。
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
      #:imported-modules '((guix build utils))
      #:phases
      #~(modify-phases (@ (jeans build electron) %standard-phases)
          (add-after 'patchelf 'precompile-builtin-plugins
            ;; Run the bundled Electron in node mode (asar-aware fs) against the
            ;; already-patched tree, so the bundles are byte-identical to what
            ;; the daemon would compile from this very store path.
            (lambda _
              (let* ((app (string-append #$output "/lib/paseo"))
                     (home (string-append (getcwd) "/precompile-home")))
                ;; Electron-as-node looks at HOME/XDG_*; builders have no
                ;; writable home (/homeless-shelter), point them into the build
                ;; tree instead.
                (mkdir-p home)
                (setenv "HOME" home)
                (setenv "XDG_CACHE_HOME" (string-append home "/.cache"))
                (setenv "XDG_CONFIG_HOME" (string-append home "/.config"))
                (setenv "XDG_DATA_HOME" (string-append home "/.local/share"))
                ;; Only lib/paseo is needed here (bundled libffmpeg.so); the
                ;; wrapper with the full LD_LIBRARY_PATH does not exist yet.
                (setenv "LD_LIBRARY_PATH" app)
                (setenv "ELECTRON_RUN_AS_NODE" "1")
                (invoke (string-append app "/Paseo.bin")
                        #$%paseo-precompile-script app))))
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
              ("nss-certs" ,nss-certs)
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
    (properties '((upstream-name . "paseo") (release-tag-prefix . "^v")))
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
;;;    lib/thinkrail/ (an ld-linux wrapper would break that lookup).
;;;    The directory keeps the upstream name: -bin is only the Guix
;;;    package name, and nothing the app resolves may carry it.
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
    (version "0.5.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/JetBrains/thinkrail/releases/download/"
             "v" version "/stable-linux-x64-ThinkRail-" version ".tar.zst"))
       (sha256
        (base32 "16zwi28c95bb95anaqgqy2l5x4p3ib609zvjryd5hbg0qcsr4a29"))))
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
                     (libdir (string-append out "/lib/thinkrail"))
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
                     (libdir (string-append out "/lib/thinkrail"))
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
                 (string-append apps "/thinkrail.desktop")
                 #:name "ThinkRail"
                 #:comment #$(package-synopsis this-package)
                 #:exec (string-append out "/bin/thinkrail")
                 #:icon "thinkrail"
                 #:categories '("Development" "IDE")
                 #:startup-w-m-class "ThinkRail"))))
          (add-after 'install-desktop 'install-icons
            (lambda _
              (let* ((src (string-append #$output "/lib/thinkrail"
                                         "/Resources/appIcon.png"))
                     (dst (string-append #$output "/share/icons/hicolor"
                                         "/512x512/apps/thinkrail.png")))
                (mkdir-p (dirname dst))
                (copy-file src dst))))
          (add-after 'install-icons 'wrap-program
            (lambda* (#:key inputs outputs #:allow-other-keys)
              (let* ((out (assoc-ref outputs "out"))
                     (libdir (string-append out "/lib/thinkrail"))
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
    (version "4.1.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://cdn-zcode.z.ai/zcode/electron/releases/"
             version "/linux-x64/ZCode-" version "-linux-x64.deb"))
       (sha256
        (base32 "1bjj9cc1snhy9m73pkjagvcrnyyyrbcwjsvs22sfvi3sbsvq7cql"))))
    (build-system electron-build-system)
    (arguments
     (list
      #:program "zcode"
      #:app-dir "lib/zcode"
      #:application-directory "zcode"
      ;; safeStorage 凭据持久化需要会话 secrets 服务：inputs 能定位到 gdbus /
      ;; gnome-keyring-daemon / gcr-prompter（即含 glib:bin / gnome-keyring /
      ;; gcr-3 三个输入）便自动启用 build/electron.scm 的
      ;; ensure-secret-service-phase（探测在位就不动，缺服务才兜底拉
      ;; gnome-keyring；用户显式 --password-store 永远最优先）。
      #:unpack-method 'deb-xz
      #:install-plan
      #~'(("opt/ZCode" "lib/zcode"))
      ;; install-bin symlink, generated desktop entry and the hicolor
      ;; icon copy are beyond install-plan: kept as small escape-hatch
      ;; phases on top of the electron defaults.
      #:modules '((guix build utils)
                  (ice-9 ftw)
                  (ice-9 regex)
                  (srfi srfi-26))
      #:imported-modules '((guix build utils))
      #:phases
      #~(modify-phases (@ (jeans build electron) %standard-phases)
          (add-after 'install 'patch-guix-bin-paths
            ;; Linux 分支的 login-env 默认 PATH 是发行版布局（/usr/sbin:
            ;; /usr/local/bin:…），登录 shell 捕获出来等于空环境。换成
            ;; gxProfilePath()（SPECS 里 zcode 那张表）。
            (lambda _
              (invoke "python3" #$%asar-guix-paths-script "zcode"
                      (string-append #$output
                                     "/lib/zcode/resources/app.asar"))))
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
                ;; Upstream hicolor icons are already named zcode.png, which is
                ;; what Icon=zcode looks up.  Copying each file onto that
                ;; same path and then deleting every zcode.png removes them.
                (when (file-exists? icon-src)
                  (copy-recursively icon-src icon-dst)))))
          ;; zcode 在 fork 子进程时用 $b() 构造环境：打包版只返回 4 个
          ;; OTEL/telemetry 变量（不读 .env），经 pa() 加工后 fork 出去的
          ;; zcode-host 完全没有会话环境。而 runPhase 里的凭据走
          ;; @napi-rs/keyring（dbus-secret-service → C libdbus），libdbus 只认
          ;; DBUS_SESSION_BUS_ADDRESS，缺失时退回编译期已禁用的 X11
          ;; autolaunch（"Using X11 for dbus-daemon autolaunch was disabled at
          ;; compile time"），表现为所有 oauth/credential RPC 报
          ;; CREDENTIAL_SECURE_STORAGE_UNAVAILABLE。wrapper 里 export 无效
          ;; （白名单会丢掉），所以必须让 fork 处展开 process.env：把锚点参数
          ;; （<var>.hostProcessLocalEnv）原位换成等长的 process.env，an()
          ;; 本身是 `{...e, ...yL()}`，传完整环境同样成立。
          ;; 替换保持字节数相同，asar 的 offset 表无需重算；锚点用正则匹配
          ;; minified 参数名与后随的 "()" 函数名都会随每个版本变，写死字面
          ;; 锚点每次升级都断（3.18.2–4.0.0 三次实证）。
          (add-after 'install-icons 'patch-host-process-env
            (lambda _
              (invoke "python3" "-c"
                      (string-append
                       "import re,sys\n"
                       "p=sys.argv[1]\n"
                       "d=open(p,'rb').read()\n"
                       "pat=re.compile(\n"
                       "    rb'\\.\\.\\.([A-Za-z_$][\\w$]*)'\n"
                       "    rb'\\(([A-Za-z_$][\\w$]*)'\n"
                       "    rb'\\.hostProcessLocalEnv\\)'\n"
                       "    rb'(?=,\\.\\.\\.)')\n"
                       "m=list(pat.finditer(d))\n"
                       "assert len(m)==1, ('unexpected anchor count:'\n"
                       "                   ' %d' % len(m))\n"
                       "m=m[0]\n"
                       "inner=m.group(2)+b'.hostProcessLocalEnv'\n"
                       "repl=b'process.env'\n"
                       "pad=len(inner)-len(repl)\n"
                       "assert pad>=0, 'anchor too short to pad'\n"
                       "i=m.start(2)\n"
                       "d=d[:i]+repl+b' '*pad+d[i+len(inner):]\n"
                       "open(p,'wb').write(d)\n")
                      (string-append #$output
                                     "/lib/zcode/resources/app.asar")))))))
    (native-inputs (list binutils python tar xz))
    (inputs `(("alsa-lib" ,alsa-lib)
              ("at-spi2-core" ,at-spi2-core)
              ("bash-minimal" ,bash-minimal)
              ("nss-certs" ,nss-certs)
              ("cups" ,cups)
              ("dbus" ,dbus)
              ("eudev" ,eudev)
              ("expat" ,expat)
              ("fontconfig-minimal" ,fontconfig)
              ("gcc:lib" ,gcc "lib")
              ("gcr" ,gcr-3)
              ("glibc" ,glibc)
              ("glib" ,glib)
              ("glib:bin" ,glib "bin")
              ("gnome-keyring" ,gnome-keyring)
              ("gtk+" ,gtk+)
              ("libsecret" ,libsecret)
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
;;; forbidden for this category (see conventions-prebuilt.md "自定位二进制").  The
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
    (version "4.9.1")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/TriDefender/zcode-api/releases/download/"
             "v" version "/zcode-proxy-linux-x64"))
       (sha256
        (base32 "1rynhx3krzlcfqmqg23yxgylk3fg71ydmvpsv71yn309wmcwfwql"))))
    (build-system binary-build-system)
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

;;; OmO is an AI coding-agent CLI built on the pi agent core (memory
;;; system, CodeMode, Anthropic subscriptions, installable extensions).
;;; Upstream naming is split three ways: the GitHub repo is
;;; oh-my-openagent, the npm package still carries the pre-rename name
;;; oh-my-opencode, while the product, release assets and CLI all say
;;; OmO/omo -- hence package name omo-bin with upstream-name "omo"
;;; (the release asset filename prefix).
;;;
;;; Upstream builds the release asset with `bun build --compile`:
;;; readelf -S shows the self-locating `.bun` / `.bun_builtins` sections,
;;; so patchelf and ld-linux wrappers are both forbidden here
;;; (conventions-prebuilt.md "自定位二进制").  Installed unpatched; runs
;;; through the system-wide nix-ld-service-type, whose default library
;;; list already covers the only NEEDED entries (readelf -d: libc.so.6,
;;; ld-linux-x86-64.so.2, libpthread.so.0, libdl.so.2, libm.so.6 -- all
;;; glibc).  The senpi-desktop-engine sidecar ships embedded in bunfs
;;; (/$bunfs/root/omo-runtime/native/prebuilds/linux-x64/...) and every
;;; config path is homedir-relative (~/.omo), so one file in bin/ is the
;;; whole runtime.
;;;
;;; License evidence: LICENSE.md is the Sustainable Use License 1.0 (the
;;; n8n model; package.json license field "SUL-1.0") -- source-visible
;;; but nonfree, so -bin naming with nonguix nonfree.  Release evidence:
;;; tag v5.1.28 (stable, GitHub Latest), asset omo-linux-x64 (150 MB).
;;; guix refresh handles the whole update cycle despite the version-less
;;; asset filename (verified end-to-end: with the package downgraded to
;;; 5.1.27, `refresh -u` rebuilt the download URL, recomputed the hash
;;; and restored 5.1.28), so it belongs on the auto-update workflow's
;;; refresh list.

(define-public omo-bin
  (package
    (name "omo-bin")
    (version "5.1.84")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/code-yeongyu/oh-my-openagent/releases/download/"
             "v" version "/omo-linux-x64"))
       (sha256
        (base32
         "0fyk91i3m9s3aqq8hq4rb3hpd9z3kiq5wqkipv3xddps9gpdzf8l"))))
    (build-system binary-build-system)
    (arguments
     (list
      ;; bun --compile self-locating single file: install unpatched and
      ;; unwrapped, runs through the system-wide nix-ld service.
      #:unpack-method 'file
      #:install-plan
      #~'(("omo-linux-x64" "bin/omo"))
      #:patchelf? #f
      #:wrap? #f))
    (properties `((upstream-name . "omo")))
    (home-page "https://github.com/code-yeongyu/oh-my-openagent")
    (synopsis "AI coding agent CLI with memory system and extensions")
    (description
     "OmO is an AI coding agent command-line interface built on the pi
agent core: it drives multi-model coding sessions with read, bash, edit
and write tools, a built-in memory system, durable scheduled prompts, and
installable extension packages (@command{omo install}).  Configuration
lives in @file{~/.omo}; on first start it migrates a pre-existing
@file{~/.pi/agent} directory.  This package provides the prebuilt
@code{linux-x64} release and needs the @code{nix-ld} system service to
run.")
    (license (license:nonfree
              "https://github.com/code-yeongyu/oh-my-openagent/blob/main/LICENSE.md"))
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
    (version "0.65.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/trycua/cua/releases/download/"
             "cua-driver-rs-v" version
             "/cua-driver-rs-" version "-linux-x86_64-binary.tar.gz"))
       (sha256
        (base32 "188vfi7f99didz5rrsak8sasvr8pfljqwrcyc96y3q0yfp038mdq"))))
    (build-system binary-build-system)
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
;;; NEEDED at 0.1.1203 (re-check with `patchelf --print-needed` on
;;; upgrades; Go rebuilds can add or drop entries): libgtk-3, libgdk-3,
;;; libgdk_pixbuf-2.0, libgio-2.0, libgobject-2.0, libglib-2.0,
;;; libfontconfig (new in 0.1.1167 — must sit in --library-path),
;;; libX11, libwebkit2gtk-4.1, libsoup-3.0, libjavascriptcoregtk-4.1,
;;; libc.
;;;
;;; The Wails self-updater (wails:updater:* IPC) is runtime-only —
;;; there is no package-type file to remove — and upgrades are owned by
;;; the channel.  Plugins and sign-in state live under the user's XDG
;;; data dirs, which the wrapper leaves untouched (prefix semantics).
;;;
;;; Desktop integration mirrors upstream's install.sh: a menu entry
;;; claiming the x-scheme-handler/magpie MIME type (magpie://import
;;; links) plus a 256x256 icon.  The release ships neither, so the
;;; entry is generated and the icon is fetched from the very URL the
;;; installer downloads it from.
;;;
;;; magpie also keeps a copy of that entry in the user's XDG_DATA_HOME,
;;; rewritten on every start with os.Executable() as the command --
;;; which under this launcher is ld.so, so the copy cannot start
;;; anything.  It nevertheless decides what the menu runs, because
;;; launchers walk XDG_DATA_HOME before XDG_DATA_DIRS and keep the
;;; first entry they see for a given desktop file id.  The wrapper
;;; therefore re-seals that copy read-only whenever it is missing,
;;; stale or writable; see the comment there.
(define magpie-icon
  (origin
    (method url-fetch)
    (uri "https://usemagpie.ai/img/icon-256.png")
    (sha256
     (base32 "0167a1hh5mv99m35vqwzns3fs05a6308hhidqk7qynp0jrjpqhsp"))))

(define-public magpie-bin
  (package
    (name "magpie-bin")
    (version "0.1.5003")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/yetone/magpie-releases/releases/download/"
             "v" version "/magpie-linux-amd64"))
       (sha256
        (base32 "10vh7f6iaw3dm936yl46v4qs4cfjdkqrmqfcykd9v9g2273l6yw7"))))
    (build-system binary-build-system)
    (arguments
     (list
      ;; Single raw ELF, no archive; unpatched — see the comment above.
      #:unpack-method 'file
      #:install-plan
      #~'(("magpie-linux-amd64" "libexec/magpie/magpie"))
      #:patchelf? #f
      #:wrap? #f
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'install 'install-wrapper
            (lambda* (#:key inputs #:allow-other-keys)
              (let* ((out #$output)
                     (bin (string-append out "/bin"))
                     (real (string-append out "/libexec/magpie/magpie"))
                     (ld.so (string-append (assoc-ref inputs "glibc")
                                           #$(glibc-dynamic-linker)))
                     (libs (string-join
                            (map (lambda (name)
                                   (string-append
                                    (assoc-ref inputs name) "/lib"))
                                 '("fontconfig-minimal" "gdk-pixbuf"
                                   "glib" "glibc" "gtk+" "libx11"
                                   "libsoup" "wayland"
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
# magpie rewrites the user-level magpie.desktop on every start: it opens
# the file, replaces its Exec= line with os.Executable() -- ld.so under
# this launcher -- and writes it back.  That copy beats the one this
# package installs, because launchers walk XDG_DATA_HOME before
# XDG_DATA_DIRS.  Seal the file read-only (the rewrite's open then
# fails) and re-seal it whenever it went missing, writable or stale.
# The bare command name keeps the entry valid across package upgrades.
d=\"${XDG_DATA_HOME:-$HOME/.local/share}/applications\"
f=\"$d/magpie.desktop\"
want=$(cat <<'SEALED'
# Sealed by the magpie-bin Guix wrapper: left writable, magpie replaces
# this file's Exec line with os.Executable() (ld.so) on every start.
[Desktop Entry]
Type=Application
Name=magpie
Comment=Every agent's model. One place.
Exec=magpie %u
Icon=magpie
StartupWMClass=magpie
Categories=Development;Utility;
MimeType=x-scheme-handler/magpie;
Terminal=false
SEALED
)
if [ \"$(cat \"$f\" 2>/dev/null)\" != \"$want\" ] || [ -w \"$f\" ]; then
  mkdir -p \"$d\" 2>/dev/null
  chmod u+w \"$f\" 2>/dev/null
  printf '%s\\n' \"$want\" > \"$f\" 2>/dev/null
  chmod 444 \"$f\" 2>/dev/null
fi
exec ~a --argv0 ~a --library-path ~a ~a \"$@\""
                            (assoc-ref inputs "bash-minimal")
                            fontconf
                            gtk-share
                            webkit-share
                            ld.so real libs real)))
                (chmod (string-append bin "/magpie") #o555))))
          (add-after 'install 'install-desktop-entry
            (lambda _
              (let ((apps (string-append #$output "/share/applications"))
                    (icons (string-append #$output
                                          "/share/icons/hicolor/256x256/apps")))
                (mkdir-p apps)
                (mkdir-p icons)
                (copy-file #$magpie-icon (string-append icons "/magpie.png"))
                (make-desktop-entry-file
                 (string-append apps "/magpie.desktop")
                 #:name "magpie"
                 #:comment "Every agent's model. One place."
                 #:exec (string-append #$output "/bin/magpie %u")
                 #:icon "magpie"
                 #:categories '("Development" "Utility")
                 #:mime-type "x-scheme-handler/magpie"
                 #:startup-w-m-class "magpie"
                 #:terminal #f
                 #:startup-notify #f)))))))
    (inputs `(("bash-minimal" ,bash-minimal)
              ("fontconfig-minimal" ,fontconfig)
              ("gdk-pixbuf" ,gdk-pixbuf)
              ("glib" ,glib)
              ("glibc" ,glibc)
              ("gtk+" ,gtk+)
              ("libx11" ,libx11)
              ("libsoup" ,libsoup)
              ("wayland" ,wayland)
              ("webkitgtk-for-gtk3" ,webkitgtk-for-gtk3)))
    (properties '((upstream-name . "magpie")))
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

;;; WorkBuddy（中国版）：腾讯的 AI 办公智能体桌面端，闭源 Electron 应用。
;;;
;;; 版本信号。官网 Linux 一栏只写「到统信 UOS/银河麒麟应用商店下载」，官方
;;; 桌面更新通道却直接提供 Linux 构建：主信号取与产物同域的清单
;;;   https://download.codebuddy.cn/workbuddy/saas/version.json
;;; （linux-x64-deb.stable.version），备用信号取
;;;   https://copilot.tencent.com/v2/update?platform=workbuddy-linux-x64-deb
;;; 清单里的版本就是完整文件名主体（<semver>.<build>-<commit>），故 version
;;; 保留 commit 后缀：上游会用同一数字版本重切构建并换后缀，只留数字版本的
;;; 包永远等不到重钉。自动更新见 scripts/check-updates/handlers/workbuddy_cn.py。
;;;
;;; 源站。download.codebuddy.cn 是 CDN，上游会原地重传同名文件，重传窗口内
;;; 大陆与海外边缘可能给出不同字节；本包 hash 固定，故固定 COS 桶的全球加速
;;; 端点（同一对象、各处同字节），与 flatpark 的 resolve-update.sh 同款处理。
;;; 路径与文件名和 CDN 完全一致，只换主机。
;;;
;;; 布局。deb 把整棵 electron-builder 产物放在 /opt/WorkBuddy，里面另有捆绑的
;;; Node 与 CPython 运行时供智能体调用工具。主二进制 workbuddy 的 DT_RPATH 是
;;; $ORIGIN，NEEDED 里带同目录的 libffmpeg.so——#:preserve-rpath? 必须为 #t，
;;; 否则 RPATH 被换成 store 路径后 libffmpeg 解析失败，启动即挂。
;;;
;;; 数据目录。应用不读 XDG 变量：账号状态、插件、日志与它自己下载的运行时都
;;; 在 ~/.workbuddy，任务工作区在 ~/WorkBuddy，凭据回退密钥在
;;; ~/.workbuddy-key-fallback。

(define-public workbuddy-cn
  (package
    (name "workbuddy-cn")
    (version "5.11.6.44396970-0f347fd9")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://acc-1258344699.cos.accelerate.myqcloud.com/"
             "workbuddy/saas/linux-x64-deb/"
             "WorkBuddy-linux-x64-deb-" version ".deb"))
       (sha256
        (base32 "1s3d2lx9w490y7dfx958jl2s5jscrfd0prmzp0989g3pwzhybvrf"))))
    (build-system electron-build-system)
    (arguments
     (list
      #:program "workbuddy"
      ;; 安装路径用上游原名：-cn 只是本通道区分区域版本的记号，上游不认识它
      ;; （scripts/check-package-paths.py 的规则，cindy-cn-bin 同为 lib/cindy）。
      #:app-dir "lib/workbuddy"
      #:application-directory "workbuddy"
      #:unpack-method 'deb-xz
      ;; 捆绑的 .so/.node 用 $ORIGIN 定位同目录依赖（libffmpeg、pty.node 等），
      ;; RPATH 被替换即失效。
      #:preserve-rpath? #t
      #:install-plan
      #~'(("opt/WorkBuddy" "lib/workbuddy")
          ("usr/share/applications/workbuddy.desktop"
           "share/applications/workbuddy.desktop")
          ("usr/share/icons/hicolor" "share/icons/hicolor"))
      #:desktop-files
      #~'(("share/applications/workbuddy.desktop"
           "bin/workbuddy"
           "share/icons/hicolor/512x512/apps/workbuddy.png"))
      #:modules '((guix build utils))
      #:phases
      #~(modify-phases (@ (jeans build electron) %standard-phases)
          (add-after 'patchelf 'install-bin
            (lambda _
              (let ((bin (string-append #$output "/bin")))
                (mkdir-p bin)
                (symlink (string-append #$output "/lib/workbuddy/workbuddy")
                         (string-append bin "/workbuddy"))))))))
    (inputs `(("alsa-lib" ,alsa-lib)
              ("at-spi2-core" ,at-spi2-core)
              ("bash-minimal" ,bash-minimal)
              ("cups" ,cups)
              ("dbus" ,dbus)
              ("eudev" ,eudev)
              ("expat" ,expat)
              ("fontconfig-minimal" ,fontconfig)
              ("gcc:lib" ,gcc "lib")
              ("glib" ,glib)
              ("glibc" ,glibc)
              ("gtk+" ,gtk+)
              ;; 登录凭据走系统 secrets 服务（Electron safeStorage 运行时
              ;; dlopen libsecret-1.so.0，NEEDED 看不见）。
              ("libsecret" ,libsecret)
              ("libx11" ,libx11)
              ("libxcb" ,libxcb)
              ("libxcomposite" ,libxcomposite)
              ("libxdamage" ,libxdamage)
              ("libxext" ,libxext)
              ("libxfixes" ,libxfixes)
              ("libxkbcommon" ,libxkbcommon)
              ("libxrandr" ,libxrandr)
              ("mesa" ,mesa)
              ("nss" ,nss)
              ("nss-certs" ,nss-certs)))
    (home-page "https://www.workbuddy.cn/")
    (synopsis "AI agent desktop workspace from Tencent")
    (description
     "WorkBuddy is an Electron desktop application in which an AI agent plans
and carries out office work: it reads documents, edits files, drives
applications and reports progress while running.  This is the China build
distributed through Tencent's own update channel; signing in requires a
Tencent account.")
    (license (license:nonfree "https://www.workbuddy.cn/"))
    (supported-systems '("x86_64-linux"))))

;;; Qoder CN: Alibaba's agent workbench for human and AI software teams
;;; (closed-source Electron desktop client).
;;;
;;; 版本通道（2026-11-07 摸清）：上游不发 GitHub release，Linux .deb 只挂在
;;; 阿里云 OSS 上。官网和下载页给的是
;;;   .../qoder-app/releases/latest/Qoder-CN-linux-amd64.deb
;;; ——那是 OSS 里一次 CopyObject 出来的副本，每次发版被同名对象原地覆盖，
;;; 对 Guix 不可用（同一 URL 的内容会变，hash 必然漂移）。可固定的是桌面端
;;; 自更新通道的 electron-builder generic provider 清单，以及按版本归档的
;;; 资产目录：
;;;   https://static.qoder.com.cn/qoder-app/releases/latest-linux.yml
;;;   https://static.qoder.com.cn/qoder-app/releases/<version>/Qoder-CN-linux-amd64.deb
;;; 历史版本目录一直保留（0.3.0 起各版本实测仍可下载），所以 URI 指向
;;; releases/<version>/ 后，同一版本号的内容就是稳定的。版本发现交给
;;; scripts/check-updates/handlers/qoder_cn.py（读清单；同版本按清单 sha256
;;; 重钉，防上游原地重传）。
;;;
;;; 包内是 Electron 43（Chrome 150）的标准 /opt 布局：
;;;   - qoder-cn        主程序，RPATH=$ORIGIN 用于找同目录的 libffmpeg.so /
;;;                     libEGL / libGLESv2 / libvulkan / libvk_swiftshader
;;;   - chrome-sandbox  安装但非 setuid-root：Guix 下靠 user namespace
;;;                     sandbox（cindy-cn-bin 同一处理）
;;;   - resources/app.asar.unpacked/node_modules/ 原生模块：keytar 运行期
;;;                     dlopen libsecret-1.so.0（NEEDED 里看不见）、node-pty、
;;;                     sharp（自带 libvips-cpp.so，$ORIGIN RPATH 自足）、
;;;                     @napi-rs/canvas
;;;   - resources/package-type 是 electron-updater 的替换许可，由
;;;                     electron-build-system 的 disable-updater phase 删掉
;;;
;;; 登录链（2026-11-09 实证）：safeStorage/keytar dlopen libsecret-1.so.0 +
;;; 会话里的 org.freedesktop.secrets 服务，缺服务即退 basic_text 后端、
;;; isEncryptionAvailable() 报 false、应用拒绝持久化凭据（niri 下每次启动
;;; 都要重新登录）。wrapper 的 ensure-secret-service phase 在 exec 前补
;;; 服务并固定 --password-store=gnome-libsecret（cindy-cn-bin 同款）。
;;;
;;; 远程控制链（2026-11-09 实证）：utilityProcess.fork 用过滤后的 env
;;; （仅 HOME/PATH/LANG 等）重新 exec process.execPath，LD_LIBRARY_PATH
;;; 丢失；Guix 的 nss 库在 <nss>/lib/nss/，wrapper 的 LD_LIBRARY_PATH 特判
;;; 了它而 RUNPATH 没有 ⇒ 子进程 libnss3.so cannot open、退出 127。
;;; 基座 auto-lib-dirs 对 nss input 追加 /lib/nss 后自足。
;;;
;;; 闭源（.deb 的 License 字段为 unknown，随包只有 Electron/Chromium 的许可
;;; 文本），按通道惯例不加 -bin 后缀。

(define-public qoder-cn
  (package
    (name "qoder-cn")
    (version "0.5.21")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://static.qoder.com.cn/qoder-app/releases/"
             version "/Qoder-CN-linux-amd64.deb"))
       (sha256
        (base32 "18jyks9kmamszi7kgbgg0jwbgsing7mil1mmf65ci4afd487x9hj"))))
    (build-system electron-build-system)
    (arguments
     (list
      #:program "qoder-cn"
      #:app-dir "lib/qoder-cn"
      #:application-directory "qoder-cn"
      ;; safeStorage 凭据持久化需要会话 secrets 服务：inputs 能定位到 gdbus /
      ;; gnome-keyring-daemon / gcr-prompter（即含 glib:bin / gnome-keyring /
      ;; gcr-3 三个输入）便自动启用 build/electron.scm 的
      ;; ensure-secret-service-phase（探测在位就不动，缺服务才兜底拉
      ;; gnome-keyring；用户显式 --password-store 永远最优先）。
      #:unpack-method 'deb-xz
      ;; 主程序 RPATH=$ORIGIN 用来找同目录 libffmpeg.so 等；sharp 的 .node
      ;; 也靠 $ORIGIN 相对路径找自带的 libvips。prepend 而不是替换。
      #:preserve-rpath? #t
      ;; @img/ 子树（sharp 的 .node 与自带 libvips-cpp.so）自包含，patch
      ;; 反而有 DT_INIT 失步风险（cindy-cn-bin 实证），整体跳过。
      #:patchelf-exclude
      #~'("lib/qoder-cn/resources/app.asar.unpacked/node_modules/@img/")
      #:install-plan
      #~'(("opt/Qoder-CN" "lib/qoder-cn")
          ("usr/share/applications/qoder-cn.desktop"
           "share/applications/qoder-cn.desktop")
          ("usr/share/icons/hicolor" "share/icons/hicolor")
          ("usr/share/doc/qoder-cn" "share/doc/qoder-cn"))
      #:desktop-files
      #~'(("share/applications/qoder-cn.desktop"
           "bin/qoder-cn"
           "share/icons/hicolor/256x256/apps/qoder-cn.png"))
      #:modules '((guix build utils))
      #:phases
      #~(modify-phases (@ (jeans build electron) %standard-phases)
          (add-after 'install 'patch-guix-bin-paths
            ;; 重启脚本的 /bin/bash、ELECTRON_RUN_AS_NODE 包装的 /usr/bin/env、
            ;; 杀 esa-agent 的 /usr/bin/pkill，以及 which/lsof/nvidia-smi/lspci
            ;; 的绝对路径（SPECS 里 qoder-cn 那张表）。
            (lambda _
              (invoke "python3" #$%asar-guix-paths-script "qoder-cn"
                      (string-append #$output
                                     "/lib/qoder-cn/resources/app.asar"))))
          (add-after 'patchelf 'install-bin
            (lambda _
              (let* ((out #$output)
                     (bin (string-append out "/bin")))
                (mkdir-p bin)
                (symlink (string-append out "/lib/qoder-cn/qoder-cn")
                         (string-append bin "/qoder-cn"))))))))
    (native-inputs (list binutils python tar xz))
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
              ("gcr" ,gcr-3)
              ("glibc" ,glibc)
              ("glib" ,glib)
              ("glib:bin" ,glib "bin")
              ("gnome-keyring" ,gnome-keyring)
              ("gtk+" ,gtk+)
              ;; keytar 运行期 dlopen libsecret-1.so.0（NEEDED 里看不见）；
              ;; 登录凭据由系统 secrets 服务提供。
              ("libsecret" ,libsecret)
              ("libx11" ,libx11)
              ("libxcb" ,libxcb)
              ("libxcomposite" ,libxcomposite)
              ("libxdamage" ,libxdamage)
              ("libxext" ,libxext)
              ("libxfixes" ,libxfixes)
              ("libxkbcommon" ,libxkbcommon)
              ("libxrandr" ,libxrandr)
              ("mesa" ,mesa)
              ("nss" ,nss)
              ("nss-certs" ,nss-certs)
              ("pango" ,pango)))
    (home-page "https://qoder.com")
    (synopsis "Agent workbench for human and AI software teams")
    (description
     "Qoder is an AI coding workspace in which an agent plans, reads code,
edits files, runs commands and reports progress while working.  This is the
China build distributed through Qoder's own update channel; signing in
requires a Qoder account.")
    (license (license:nonfree "https://qoder.com"))
    (supported-systems '("x86_64-linux"))))

;;; CrommaCode: proprietary agent terminal / desktop (GPUI + wgpu, not
;;; Electron).  Upstream deb layout:
;;;   /opt/crommacode/cromma-bees      main program (103 MB, stripped)
;;;   /opt/crommacode/bees             swarm CLI (6 MB)
;;;   /usr/bin/crommacode              symlink to the main program
;;;   /usr/share/applications/ai.cromma.bees.desktop
;;;   /usr/share/icons/hicolor/*/apps/ai.cromma.bees.png
;;;
;;; Two layout constraints drive the install plan:
;;;
;;; 1. bees must sit next to the main binary.  cromma-bees resolves it from
;;;    the current_exe parent directory ("cromma-bees: no `bees` next to ")
;;;    and only then falls back to PATH.  wrap-program renames the real ELF
;;;    to .cromma-bees-real, which keeps current_exe inside lib/crommacode/,
;;;    so both ELFs are installed there; bin/bees is an extra symlink for
;;;    plain shells.
;;;
;;; 2. wgpu dlopen()s libEGL.so.1, libvulkan.so.1, libwayland-client.so.0
;;;    and libwayland-egl.so.1.  Only libxcb, libxkbcommon, libxkbcommon-x11,
;;;    libasound, libgcc_s and libc are NEEDED, so RPATH covers those while
;;;    the wrapper's LD_LIBRARY_PATH supplies the dlopen'd set.
;;;
;;; 3. The UI is GPUI, whose fontdb reads FONTCONFIG_FILE (and a few
;;;    homedir-relative paths) but never XDG_DATA_DIRS.  Guix has no
;;;    /etc/fonts/fonts.conf, so a launcher-started session without that
;;;    variable would panic in resolve_font; the wrapper therefore supplies
;;;    a default and keeps any value the session already set.
;;;
;;; Runtime state lives in ~/.cromma-bees (0600 credential file) and the
;;; bees hive, both homedir-relative and independent of the install prefix.

(define-public crommacode
  (package
    (name "crommacode")
    (version "1.0.4")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://dl.cromma.ai/code/artifacts/" version
             "/CrommaCode-" version "-linux-amd64.deb"))
       (sha256
        (base32 "0pqlja3xn6rh6dlnh5g9d3hfys4rj9wgps74zvhrpxxr2p2ks1i8"))))
    (build-system binary-build-system)
    (arguments
     (list
      #:unpack-method 'deb-xz
      #:app-dir "crommacode"
      ;; opt/crommacode/ contents (bees included) land in lib/crommacode/.
      ;; The deb's /usr/bin/crommacode is an absolute /opt symlink, so it is
      ;; skipped and recreated below.
      #:install-plan
      #~'(("opt/crommacode/" "lib/crommacode/")
          ("usr/share/applications/ai.cromma.bees.desktop"
           "share/applications/")
          ("usr/share/icons/hicolor/" "share/icons/hicolor/"))
      #:wrap-plan
      #~'(("lib/crommacode/cromma-bees"
           ("LD_LIBRARY_PATH" ":" prefix
            (#$(file-append libglvnd "/lib")
             #$(file-append vulkan-loader "/lib")
             #$(file-append wayland "/lib")))))
      #:desktop-files
      #~'(("share/applications/ai.cromma.bees.desktop" "bin/crommacode"))
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'wrap 'wrap-fontconfig
            (lambda _
              ;; fontdb only looks at FONTCONFIG_FILE; keep a session-supplied
              ;; value and fall back to fontconfig's own default otherwise.
              (substitute*
                  (string-append #$output "/lib/crommacode/cromma-bees")
                (("^exec -a ")
                 (string-append
                  "export FONTCONFIG_FILE=\"${FONTCONFIG_FILE:-"
                  #$(file-append fontconfig "/etc/fonts/fonts.conf")
                  "}\"\n"
                  "exec -a ")))))
          (add-after 'desktop-files 'install-bin
            (lambda _
              (let ((bin (string-append #$output "/bin")))
                (mkdir-p bin)
                (symlink (string-append #$output "/lib/crommacode/cromma-bees")
                         (string-append bin "/crommacode"))
                (symlink (string-append #$output "/lib/crommacode/bees")
                         (string-append bin "/bees"))))))))
    (inputs `(("alsa-lib" ,alsa-lib)
              ("fontconfig-minimal" ,fontconfig)
              ("gcc:lib" ,gcc "lib")
              ("glibc" ,glibc)
              ("libglvnd" ,libglvnd)
              ("libxcb" ,libxcb)
              ("libxkbcommon" ,libxkbcommon)
              ("vulkan-loader" ,vulkan-loader)
              ("wayland" ,wayland)))
    (home-page "https://cromma.ai/code")
    (synopsis "Terminal that turns coding-agent work into a watchable game")
    (description
     "CrommaCode is a desktop terminal for coding agents such as Claude Code
and Codex.  It runs an agent in a real terminal and renders the session as a
side-view game console, turning tool calls, plans and sub-agents into
watchable activity.  Its @command{bees} helper flies parallel workers, each in
its own git worktree and branch, and collects them back into the hive.
This package installs the vendor's prebuilt Linux release; an account is
required for the hosted features.")
    (license (license:nonfree "https://vibeloft.ai/terms"))
    (supported-systems '("x86_64-linux"))))

;;; DeepSeek Harness 桌面版（MIT，预编译 .deb）。
;;;
;;; 两层结构，包的布局由这两层各自的路径假设决定，不能按包名改名：
;;; usr/bin/deepseek-harness-desktop 是 Rust/Tauri 外壳（GTK3，负责设置、
;;; 依赖下载、dsh 服务生命周期与单实例），窗口与页面全部跑在自带的
;;; lib/<productName>/runtime/<arch>/ 里的 Electron 44.7（crates/electron-rs），
;;; 由外壳 spawn 并把 --port、IPC 凭据经 stdin 传进去。外壳按
;;; current_exe 的父目录推导 runtime 候选目录
;;; （crates/tauri-runtime-electron 的 bundled_roots：
;;; ../lib/<productName>/runtime、$APPDIR/usr/lib/...、/usr/lib/...），
;;; productName 是 tauri.conf.json 的 "DSH Tauri"——所以 lib/ 下的目录必须
;;; 叫 "DSH Tauri"（含空格），与包名无关；改名或改成 libexec 会让外壳找不到
;;; runtime 并直接报 "Electron runtime was not bundled"。
;;;
;;; sandbox：deb 的 postinst 只把 chrome-sandbox chmod 0755（不是 SUID）并给
;;; runtime 里每个可执行文件装 AppArmor unconfined profile（含 userns 规则），
;;; 也就是说上游走的是 user-namespace sandbox。Guix 系统没有 Ubuntu 的
;;; AppArmor userns 限制，不需要这份 profile；chrome-sandbox 原样保留、
;;; 不做 patchelf（它是 sandbox helper 自身，且不需要 SUID）。
;;;
;;; 内核名下的 arm64 预编译 .node（@tailwindcss/oxide-linux-arm64-gnu，供
;;; dsh-tauri-remote 推给 ARM 远端用）在 x86_64 上永远不会被 dlopen，给
;;; x86_64 interpreter/RPATH 只会写坏它，故排除。
;;;
;;; 自动更新语义由上游自己处理：主程序读 /etc/debian_version 判断发行版托管
;;; （is_desktop_distro_managed），Guix 下没有该文件，deb 的 package-type 也
;;; 不存在，disable-electron-updater 因此是 no-op。
;;;
;;; 选 Bundle 资产：普通版 deb 首次启动要从 dsh-tauri/deepseek-harness-pkg 的
;;; release 下载 441MB 内核 asar（GitHub API 定 tag，限流时回退 HTML 解析），
;;; 内核不在包里意味着每次重装都赌一次网络与限流状态（2026-11-17 实测本机
;;; 匿名 API 403 → 回退解析拿到不存在的 tag → 404 重试 5 次失败）。Bundle
;;; 版把内核 asar 与 pnpm 放进 resources/，manifest 的 managedRoot 指向
;;; $Resources，首次启动离线可用，也符合 Guix 对包自包含的期望。

(define-public deepseek-harness-desktop-bin
  (package
    (name "deepseek-harness-desktop-bin")
    (version "0.34.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/dsh-tauri/deepseek-harness-desktop/releases/"
             "download/v" version "/Deepseek.Harness.Desktop_Bundle_"
             ;; Bundle 的 Linux deb 资产名不带架构后缀（带 _amd64 的是非
             ;; Bundle 版）；写错会 404，而且因为 hash 正确，guix 会先试
             ;; bordeaux / ci 兜底再 Disarchive，全部 404 后才报失败。
             version ".deb"))
       (sha256
        (base32 "1icqig1sm5sp7fg76hvhznlpy3615rlv0djbjn9ha5kklrl2mpb0"))))
    (build-system electron-build-system)
    (arguments
     (list
      #:program "deepseek-harness-desktop"
      ;; 上游 productName，带空格；外壳据此找 runtime（见上方注释）。
      #:app-dir "lib/DSH Tauri"
      #:application-directory "DSH Tauri"
      ;; 外壳把 TAURI_RUNTIME_ELECTRON_ARGS 原样交给 Electron，而自身 argv
      ;; 不解析 Chromium flag，所以只 export Electron 原生 hint 变量。
      #:wayland? 'hint-env
      #:unpack-method 'deb
      #:install-plan
      #~'(("usr/bin/deepseek-harness-desktop"
           "bin/deepseek-harness-desktop")
          ("usr/lib/DSH Tauri/" "lib/DSH Tauri/")
          ("usr/share/applications/DSH Tauri.desktop"
           "share/applications/DSH Tauri.desktop")
          ("usr/share/icons/hicolor/" "share/icons/hicolor/"))
      ;; 外壳与整棵 Electron runtime 都要 patchelf；arm64 addon 与
      ;; chrome-sandbox 见包前注释。
      #:patchelf-plan
      #~'("lib/DSH Tauri" "bin/deepseek-harness-desktop")
      #:patchelf-exclude
      #~'("lib/DSH Tauri/runtime/linux-x64/chrome-sandbox"
          "lib/DSH Tauri/resources/node_modules/@tailwindcss/oxide-linux-arm64-gnu/")
      #:desktop-files
      #~'(("share/applications/DSH Tauri.desktop"
           "bin/deepseek-harness-desktop"))))
    (native-inputs (list binutils tar xz))
    (inputs `(("alsa-lib" ,alsa-lib)
              ("at-spi2-core" ,at-spi2-core)
              ("bash-minimal" ,bash-minimal)
              ("nss-certs" ,nss-certs)
              ("cups" ,cups)
              ("dbus" ,dbus)
              ("eudev" ,eudev)
              ("expat" ,expat)
              ("fontconfig-minimal" ,fontconfig)
              ("gcc:lib" ,gcc "lib")
              ("gcr" ,gcr-3)
              ("glibc" ,glibc)
              ("glib" ,glib)
              ("glib:bin" ,glib "bin")
              ("gnome-keyring" ,gnome-keyring)
              ("gtk+" ,gtk+)
              ("libx11" ,libx11)
              ("libxcb" ,libxcb)
              ("libxcomposite" ,libxcomposite)
              ("libxdamage" ,libxdamage)
              ("libxext" ,libxext)
              ("libxfixes" ,libxfixes)
              ("libxkbcommon" ,libxkbcommon)
              ("libxrandr" ,libxrandr)
              ;; 托盘：deb Depends 的 libappindicator3-1。libappindicator-sys
              ;; 依次 dlopen libayatana-appindicator3.so.1 /
              ;; libappindicator3.so.1（运行时 dlopen，NEEDED 里看不到）；
              ;; Guix 只提供后者，缺整个 input 时四个候选全失败并 panic。
              ("libappindicator" ,libappindicator)
              ("mesa" ,mesa)
              ("nss" ,nss)
              ("openssl" ,openssl)
              ("vulkan-loader" ,vulkan-loader)
              ("wayland" ,wayland)))
    (properties '((upstream-name . "deepseek-harness-desktop") (release-tag-prefix . "^v")))
    (home-page "https://github.com/dsh-tauri/deepseek-harness-desktop")
    (synopsis "Desktop application for DeepSeek Harness")
    (description
     "DeepSeek Harness Desktop is a desktop shell for the DeepSeek Harness
agent platform: it manages the @command{dsh} service, ships a first-run
plugin wizard and keeps profiles, sessions and credentials in the
@file{\\$DSH_HOME} directory shared with the command-line install.  This
package installs the vendor's prebuilt Linux release; the Harness core
distribution itself is downloaded on first launch.")
    (license license:expat)
    (supported-systems '("x86_64-linux"))))

;;; Eta Host：Eta 的常驻宿主（MIT，0xfe-project/eta）。桌面端与移动端都只是
;;; 客户端——agent loop、会话、插件与代码工作区都在宿主里跑，宿主对外提供
;;; Web UI（默认 http://127.0.0.1:8787）与客户端协议，可以装在笔记本、服务器
;;; 或容器里，多台设备连同一个宿主。
;;;
;;; 这是仓库的另一条发布线：`v*` 稳定 tag（asset eta-host-linux-x64，文件名不带
;;; 版本号，SHA256SUMS 与 eta-host.json 同发），与桌面线 `desktop-v*` 完全独立，
;;; GitHub 的 Latest 指针指的始终是这条。tag 是普通 v<version>、资产名以
;;; upstream-name 开头，本来最适合交给 guix refresh，但实测它报「would be
;;; upgraded from 0.4.0 to 0.5.0-rc.15」：该 repo 最近 30 条 release 全是
;;; pre-release（桌面线 rc 一天数发），guix github updater 过滤 pre-release 后
;;; 列表为空，于是回退成 keep everything（2026-11-28 实测）。CI 的 refresh 守卫
;;; （G2：正式版被推到 pre-release）会在写盘前拦下这条，实际更新由 Python
;;; updater 接管（config.json 的 tag_prefix "v" 走列表扫描并跳过 pre-release；
;;; /releases/latest 本身也恒指宿主稳定线）。
;;;
;;; 单文件是 `bun build --compile` 产物（readelf -S 有 .bun 段）。实测
;;; patchelf --set-interpreter/--set-rpath 之后启动即 SIGSEGV（`--version` 都过
;;; 不去），未打补丁的同一文件在 nix-ld 下正常输出
;;; {"version":"0.4.0","commit":...,"minDesktop":"0.1.0"}。故原样装进 bin/、不
;;; patch 不 wrap，运行依赖系统级 nix-ld-service-type；它只 NEED
;;; libc/ld-linux/libpthread/libdl/libm，服务默认库表已覆盖。
;;;
;;; 首次运行会在 ~/.eta/ 建库（eta.sqlite、secret.key、running-host.json、
;;; agents/、artifacts/、unpacked/ 等）；没有 systemd 的系统按上游 INSTALL.md
;;; 的「Quick trial」直接跑二进制，或交给 home shepherd 管理。
(define-public eta-host-bin
  (package
    (name "eta-host-bin")
    (version "0.5.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/0xfe-project/eta/releases/download/"
             "v" version "/eta-host-linux-x64"))
       (sha256
        (base32 "0nj5ax1znlf8kgnhr3psa1xd8pgybibki8yqiqp33xsbj5qdmasz"))))
    (build-system binary-build-system)
    (arguments
     (list
      #:unpack-method 'file
      #:install-plan #~'(("eta-host-linux-x64" "bin/eta-host"))
      ;; bun --compile 自定位单文件：不碰 ELF，走系统 nix-ld。
      #:patchelf? #f
      #:wrap? #f))
    (properties `((upstream-name . "eta-host")))
    (home-page "https://eta.0xfe.tech")
    (synopsis "Always-on host for the Eta multi-agent workspace")
    (description
     "Eta Host is the server side of Eta: it runs the agent loop, keeps
sessions and plugins, and serves the Eta Web UI on
@code{http://127.0.0.1:8787} for desktop, mobile and browser clients.  This
package installs the prebuilt @code{linux-x64} release and needs the
@code{nix-ld} system service to run.")
    (license license:expat)
    (supported-systems '("x86_64-linux"))))

;;; Eta Desktop：Eta 的原生桌面客户端。Eta 本体（MIT，0xfe-project/eta）是
;;; 多 agent 工作台——Claude Code、Codex、Antigravity、OpenCode、Pi、任意 ACP
;;; agent 与 Eta 自带 runtime 共用一间群聊，底下是 git worktree 任务板、依赖
;;; 计划、自主 Captain 和远程 worker 机器。客户端用 longbridge/nsh（Native
;;; Shell：Rust + GTK4 + WebKitGTK 6.0）打包，不是 Electron，也不是 Tauri。
;;;
;;; 同一仓库并发两条发布线（README「Install」与 release-desktop.yml 都写明）：
;;; 宿主线 `v*`（eta-host-linux-x64，稳定版，GitHub 的 Latest 指针始终指向
;;; 它）与桌面线 `desktop-v*`（一律标 pre-release——正是为了不抢 Latest）。
;;; 本包只取桌面线。带 -bin 是因为分发上游预编译产物：源码是 bun + nsh 的
;;; monorepo，构建要先有 nsh 工具链，不在 Guix 里重建。
;;;
;;; 资产有两个同内容的名字：eta-desktop-linux-x64.tar.gz 与
;;; Eta-<version>-linux-x86_64.tar.gz（解包树相同）。这里取不带版本号的那个：
;;; Python 兜底 updater 按包定义里显式的 "desktop-v" 段 + version 变量重建
;;; URL，资产名里再嵌一遍版本号只是多一处要同步的地方。guix refresh 用不了
;;; 这条线：github updater 的 URL 形状匹配只认 /download/(v)?<version>/…，
;;; 而这里的 tag 是 desktop-v<version>（同 bun-bin 的 download/bun-v 盲区），
;;; 实测报 no updater，故由 Python updater + config.json 的
;;; check_pre_release 接管（整条桌面线都是 pre-release）。
;;;
;;; 布局是 nsh 的 app 目录，不能打散：
;;;   Eta/Eta                     nsh shell 本体（Rust，链 GTK4 + WebKitGTK 6.0）
;;;   Eta/nsh/bundle.nshc         编译好的前端 bundle
;;;   Eta/nsh/{app,capabilities}.json、nsh/assets/
;;;   Eta/nsh/eta-bootstrap       宿主安装器（bun --compile 单文件，见下）
;;; shell 按自身可执行文件所在目录找 nsh/，所以整棵树原样装进
;;; lib/dev.eta.client/。这正是上游 Flatpak 的布局（/app/lib/dev.eta.client/，
;;; release-desktop.yml 里逐项断言），bin/Eta 则只是下面的启动脚本。
;;;
;;; 两个 ELF 分两种待遇：
;;; - Eta 是普通动态 ELF，走 #:patchelf-plan。0.1.0 的 NEEDED（rc.22 实测同一
;;;   集合；升级时用 `patchelf --print-needed` 重查，WebKitGTK 会增减条目）：libharfbuzz、
;;;   libfontconfig、libpango{ft2,cairo}、libgobject/glib、libcairo、
;;;   libwebkitgtk-6.0、libgtk-4、libgraphene、libsoup-3.0、libgio、
;;;   libjavascriptcoregtk-6.0，加 libgcc_s/libm/libc。
;;; - nsh/eta-bootstrap 是 bun --compile 自定位单文件：patchelf 0.18 在它上面
;;;   直接 abort（`patchelf.cc:529 shiftFile: Assertion 'splitIndex == -1'
;;;   failed`），改 ELF 布局也会破坏它按 /proc/self/exe 找尾部载荷的假设
;;;   （conventions-prebuilt.md「自定位二进制」）。故原样安装、不 patch；
;;;   它只 NEED libc/ld/pthread/dl/m，运行时走系统级
;;;   nix-ld-service-type（服务默认库表已覆盖这几个）。
;;;
;;; 宿主不靠 app 现场下载：eta-host-bin 是本包的 input，启动脚本把它的 bin/
;;; 前置进 PATH。nsh 的宿主解析顺序是
;;;   $XDG_DATA_HOME/eta/host/eta-host -> ~/.eta/desktop/host/eta-host ->
;;;   PATH 上的 eta-host -> 都没有才从 GitHub 下 398 MB（scripts/nsh-host-bootstrap.ts）。
;;; 走下载那条路还要过 minDesktop 门：桌面线在 rc 阶段整体是 pre-release，semver
;;; 排序小于 0.1.0，而每个宿主 release 的 eta-host.json 都写 minDesktop 0.1.0，
;;; 所以 rc 客户端实测直接报
;;;   "has no host release this app 0.1.0-rc.20 can run: 0.4.0 needs the app 0.1.0"。
;;; 0.1.0 正式版发布后这道门自然放行，但 PATH 命中的宿主本来就不经过它。
;;; PATH 命中的宿主不经过那道过滤（gate 只在 downloadHost 里），所以
;;; 「Run on this computer」用我们打的宿主，既不用联网下 398 MB，也不会被那条
;;; 版本门挡住。宿主本身同样是 bun --compile 产物，同样需要 nix-ld。
;;;
;;; nsh 启动时会给 `eta://` 写自己的菜单项
;;; （$XDG_DATA_HOME/applications/dev.eta.client.desktop，X-NSH-Generated=true）：
;;; Exec 取 current_exe —— 也就是 lib/dev.eta.client/Eta 这个真实二进制，而不是
;;; 本包的 bin/Eta 启动脚本；Icon 取 <exe 目录>/<app-id>.png。后者本包装好了，
;;; 前者意味着从菜单/坞启动时拿不到 wrapper 注入的 PATH，nsh 的 host-bootstrap
;;; 找不到 eta-host 就会去下载 398 MB（实测写
;;; ~/.eta/desktop/host/eta-host.<pid>.download）。所以 bin/Eta 在 exec 之前先做
;;; 一次幂等维护：把宿主链到上游「已安装宿主」的位置
;;; $XDG_DATA_HOME/eta/host/eta-host —— 那是 host-bootstrap 候选链的第一项，此
;;; 后任何启动方式（包括 nsh 自己注册的菜单项）都直接用仓库版本，不联网。目标
;;; 优先取进来时 PATH 里的 eta-host（用户 profile 里装的会随 reconfigure 更新，
;;; 软链因此跨升级不悬空），否则用本包捆绑的那份；用户自己装的宿主是真实文件，
;;; 不动。剩下的边角只有「第一次打开就绕过了启动脚本」（例如手动跑
;;; lib/dev.eta.client/Eta）：那一次仍会走下载，之后再经启动脚本即回正。
;;;
;;; nsh 自带的 in-app updater（nsh/assets/nsh-updater.json）在 install 阶段删
;;; 掉：它下载整包 tar.gz 后替换 app 目录，而 store 只读，留下只会让设置页
;;; 显示一个永远失败的更新按钮。版本由 channel 管理（同 Electron 包删
;;; electron-updater 清单的处理）。
;;;
;;; 运行时环境（缺了是"能开窗但功能静默降级"）：XDG_DATA_DIRS 必须按 prefix
;;; 语义带上 gtk/webkitgtk 的 share（GTK4 的 gschemas、WebKitGTK 的 inspector
;;; 资源），GIO_EXTRA_MODULES 要含 glib-networking 的 gio 模块（libsoup 的
;;; TLS 走 GIO 模块，NEEDED 里看不到），gdk-pixbuf 通过
;;; GUIX_GDK_PIXBUF_MODULE_FILES 补 loader cache（不要设单数
;;; GDK_PIXBUF_MODULE_FILE）。FONTCONFIG_FILE 只在会话没给值时兜底。
;;;
;;; 许可证证据：仓库根 LICENSE 为 MIT（GitHub API 亦报 MIT）。发布证据：
;;; tag 形如 desktop-v<version>（rc 阶段一律 pre-release，0.1.0 起转正），资产
;;; eta-desktop-linux-x64.tar.gz（84 MiB）。
(define-public eta-desktop-bin
  (package
    (name "eta-desktop-bin")
    (version "0.1.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/0xfe-project/eta/releases/download/"
             "desktop-v" version "/eta-desktop-linux-x64.tar.gz"))
       (sha256
        (base32 "1i7f4gi5yqkd36npxdj0zzlsywyxwbwffl24294jc82fh3m3cgvv"))))
    (build-system binary-build-system)
    (arguments
     (list
      #:unpack-method 'tar
      #:app-dir "dev.eta.client"
      #:install-plan
      ;; gnu unpack 会剥掉唯一的顶层目录（Eta/），所以这里的路径相对解包根目录。
      #~'(;; 上游布局：shell 与 nsh/ 必须相邻（shell 按自身 exe 位置找 nsh/）。
          ("Eta" "lib/dev.eta.client/Eta")
          ("nsh/" "lib/dev.eta.client/nsh/")
          ;; nsh 给 eta:// 自己注册菜单项时，图标取 <exe 目录>/<app-id>.png
          ;; （nsh-platform-linux/src/links.rs），所以图标也要放在 shell 旁边，
          ;; 否则它写出的菜单项没有 Icon=（坞/任务栏显示空白）。
          ("dev.eta.client.png" "lib/dev.eta.client/dev.eta.client.png")
          ("dev.eta.client.desktop"
           "share/applications/dev.eta.client.desktop")
          ("dev.eta.client.metainfo.xml"
           "share/metainfo/dev.eta.client.metainfo.xml")
          ("dev.eta.client.png"
           "share/icons/hicolor/256x256/apps/dev.eta.client.png"))
      ;; 只打 shell 本体；nsh/eta-bootstrap 保持原样（见包前注释）。
      #:patchelf-plan #~'("lib/dev.eta.client/Eta")
      ;; bin/Eta 是手写启动脚本，不能再让 wrap-program 把它改名成 .Eta-real。
      #:wrap? #f
      #:desktop-files
      #~'(("share/applications/dev.eta.client.desktop" "bin/Eta"))
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'install 'install-launcher
            (lambda* (#:key inputs #:allow-other-keys)
              (let* ((out #$output)
                     (app (string-append out "/lib/dev.eta.client"))
                     (sh (assoc-ref inputs "bash-minimal"))
                     (eta-host (assoc-ref inputs "eta-host-bin"))
                     (gtk (assoc-ref inputs "gtk"))
                     (webkitgtk (assoc-ref inputs "webkitgtk"))
                     (glib (assoc-ref inputs "glib"))
                     (glib-networking (assoc-ref inputs "glib-networking"))
                     (gdk-pixbuf (assoc-ref inputs "gdk-pixbuf"))
                     ;; 两串多目录的值先在宿主侧拼好，免得脚本源码行超长。
                     (pixbuf-cache
                      (string-append
                       gdk-pixbuf
                       "/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache"))
                     (typelib-path
                      (string-append glib "/lib/girepository-1.0:"
                                     gtk "/lib/girepository-1.0:"
                                     webkitgtk "/lib/girepository-1.0"))
                     (fontconfig (assoc-ref inputs "fontconfig-minimal"))
                     ;; 基础工具用绝对路径：裸会话的 PATH 可能没有 coreutils
                     ;; （实测 PATH=/usr/bin:/bin 时 mkdir 直接不存在）。
                     (coreutils (assoc-ref inputs "coreutils-minimal"))
                     (bin-mkdir (string-append coreutils "/bin/mkdir"))
                     (bin-rm (string-append coreutils "/bin/rm"))
                     (bin-ln (string-append coreutils "/bin/ln"))
                     (bin-readlink (string-append coreutils "/bin/readlink")))
                ;; nsh 的 in-app updater 换不了只读 store 里的 app 目录。
                (delete-file (string-append app "/nsh/assets/nsh-updater.json"))
                (mkdir-p (string-append out "/bin"))
                ;; 整段脚本在宿主侧拼好再落盘：单条 format 串里塞不下这些
                ;; 变量名（会被 formatting checker 判行过长），也容易把
                ;; export 写到 exec 之后去。
                (let ((launcher
                       (string-append
                        "#!" sh "/bin/sh\n"
                        "# The nsh shell finds its nsh/ directory next to its own\n"
                        "# executable, so exec the real binary by its store path\n"
                        "# instead of letting wrap-program rename it.\n"
                        "# eta-host sits ahead of PATH: nsh looks its host up on\n"
                        "# PATH before it downloads one, so choosing this computer\n"
                        "# uses the packaged host instead of fetching 398 MB.\n"
                        ;; 目标优先取“进来时 PATH 里的 eta-host”（用户 profile 里
                        ;; 装的会随 reconfigure 更新，软链因此跨升级不悬空），否则
                        ;; 用本包捆绑的那份。
                        "host=" eta-host "/bin/eta-host\n"
                        "oldifs=$IFS; IFS=:\n"
                        "for d in ${PATH:-}; do\n"
                        "  if [ -n \"$d\" ] && [ -x \"$d/eta-host\" ]; then\n"
                        "    host=\"$d/eta-host\"; break\n"
                        "  fi\n"
                        "done\n"
                        "IFS=$oldifs\n"
                        "export PATH=\"" eta-host "/bin${PATH:+:$PATH}\"\n"
                        "export FONTCONFIG_FILE=\"${FONTCONFIG_FILE:-"
                        fontconfig "/etc/fonts/fonts.conf}\"\n"
                        "export XDG_DATA_DIRS=\"" out "/share:" gtk
                        "/share:" webkitgtk
                        "/share${XDG_DATA_DIRS:+:$XDG_DATA_DIRS}\"\n"
                        "export GIO_EXTRA_MODULES=\"" glib-networking
                        "/lib/gio/modules${GIO_EXTRA_MODULES:+:"
                        "$GIO_EXTRA_MODULES}\"\n"
                        "export GUIX_GDK_PIXBUF_MODULE_FILES=\""
                        pixbuf-cache
                        "${GUIX_GDK_PIXBUF_MODULE_FILES:+:"
                        "$GUIX_GDK_PIXBUF_MODULE_FILES}\"\n"
                        "export GI_TYPELIB_PATH=\"" typelib-path
                        "${GI_TYPELIB_PATH:+:$GI_TYPELIB_PATH}\"\n"
                        ;; nsh 给 eta:// 注册的菜单项 Exec 取真实二进制，从菜单
                        ;; 启动时没有本脚本注入的 PATH（见包前注释）。把宿主放到
                        ;; host-bootstrap 候选链第一项——上游 INSTALL.md Path C 的
                        ;; “宿主装在系统上”位置——那条路也能直接用仓库版本，不会
                        ;; 去下载 398 MB。每次启动幂等刷新；用户自己装的宿主是真
                        ;; 实文件，不动它。
                        "data=\"${XDG_DATA_HOME:-$HOME/.local/share}\"\n"
                        "hostdir=\"$data/eta/host\"\n"
                        "hostlink=\"$hostdir/eta-host\"\n"
                        ;; 基础工具走 store 绝对路径，不依赖会话 PATH
                        bin-mkdir " -p \"$hostdir\" 2>/dev/null || true\n"
                        "if [ ! -e \"$hostlink\" ] || [ -L \"$hostlink\" ]; then\n"
                        "  if [ \"$(" bin-readlink
                        " \"$hostlink\" 2>/dev/null)\" != \"$host\" ]; then\n"
                        "    " bin-rm " -f \"$hostlink\" 2>/dev/null\n"
                        "    " bin-ln
                        " -s \"$host\" \"$hostlink\" 2>/dev/null || true\n"
                        "  fi\n"
                        "fi\n"
                        "exec " app "/Eta \"$@\"\n")))
                  (call-with-output-file (string-append out "/bin/Eta")
                    (lambda (port)
                      (display launcher port)))
                  (chmod (string-append out "/bin/Eta") #o755))))))))
    (inputs `(("bash-minimal" ,bash-minimal)
              ("cairo" ,cairo)
              ;; 启动脚本用它的 mkdir/rm/ln/readlink 绝对路径（裸会话 PATH 可能没有）。
              ("coreutils-minimal" ,coreutils-minimal)
              ;; 本机宿主：nsh 在 PATH 上找不到 eta-host 才会联网下载（见包前注释）。
              ("eta-host-bin" ,eta-host-bin)
              ("fontconfig-minimal" ,fontconfig)
              ("gcc:lib" ,gcc "lib")
              ("gdk-pixbuf" ,gdk-pixbuf)
              ("glib" ,glib)
              ("glib-networking" ,glib-networking)
              ("glibc" ,glibc)
              ("graphene" ,graphene)
              ("gtk" ,gtk)
              ("harfbuzz" ,harfbuzz)
              ("libsoup" ,libsoup)
              ("pango" ,pango)
              ("webkitgtk" ,webkitgtk)))
    (properties `((upstream-name . "eta-desktop")
                  (release-tag-prefix . "^desktop-v")
                  (accept-pre-releases? . #t)))
    (home-page "https://eta.0xfe.tech")
    (synopsis "Native desktop client for the Eta multi-agent workspace")
    (description
     "Eta is a multi-agent workspace: Claude Code, Codex, Antigravity,
OpenCode, Pi and any ACP agent share one group chat on top of a
@command{git worktree} task board with dependency plans, an autonomous
Captain and remote worker machines.  This package installs the prebuilt
@code{linux-x64} desktop client together with the @command{eta-host} it
runs on this computer (from @code{eta-host-bin}), so the first start does
not download a host; a host elsewhere is reached by connecting to it.
Its launcher keeps that host where the client treats a host as installed,
so starting the app from the menu does not download one either; running a
host on this computer needs the @code{nix-ld} system service.")
    (license license:expat)
    (supported-systems '("x86_64-linux"))))

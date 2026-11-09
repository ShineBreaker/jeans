;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-only

;;; Electron 预编译包的 builder 侧阶段：复用基座，只追加 Electron 专属语义。
;;;
;;; 本模块复用 (jeans build binary) 的 %standard-phases，只追加 Electron
;;; 专属 phase（顺序沿 opencode-desktop-bin 全链实证）：
;;;   install -> disable-electron-updater -> patch-elf -> install-bin
;;;     -> desktop -> icons -> wrap -> wrap-electron
;;;     -> prefer-wayland / prefer-wayland-hint -> ensure-secret-service
;;;
;;; ensure-secret-service 以 inputs 为开关：包依赖 glib:bin / gnome-keyring /
;;; gcr-3（能定位到对应文件）才注入，不设 build-system 关键字（详见 phase
;;; 注释）。
;;;
;;; 三个 phase 的 shell 负载与 (jeans packages agent) 的同名 helper
;;; （disable-electron-updater-phase / prefer-electron-wayland-phase /
;;; prefer-electron-wayland-hint-phase，见 agent.scm）逐行同形；唯一的改写是
;;; staging：agent.scm 的是 host 侧 gexp 工厂（收值、吐 #~ phase），这里是
;;; builder 侧直调 procedure（经 #:key 读值），因为 builder 内没有 gexp。
;;; agent.scm 的三处 define 暂时保留（加注释指向此处），供未迁移包兼容。
;;;
;;; 参数（由 (jeans build-system electron) 的 lower 校验后透传）：
;;;   #:disable-updater?    布尔，默认 #t。#f 时 updater phase 直接 no-op。
;;;   #:application-directory 字符串，lib/ 下的上游目录名（updater 用）。
;;;   #:wayland?            'inject-flags（默认，注入 --ozone-platform flag）
;;;                         / 'hint-env（export ELECTRON_OZONE_PLATFORM_HINT，
;;;                         argv 解析严格、拒未知 flag 的上游如 Paseo 用）
;;;                         / #f（关闭）。两个 wayland phase 按取值自门控，
;;;                         互斥触发，#f 时双双 no-op。
;;;   #:program             bin/ 下的程序名（wayland/wrap 定位 wrapper 用）。
;;;   #:app-dir             资源目录相对路径，如 "lib/opencode-desktop"
;;;                        （wrap 组装 LD_LIBRARY_PATH 用）。
;;;
;;; wrap-electron 是 wrap 默认三件套 + 证书注入（opencode-desktop-bin 实证）：
;;;   LD_LIBRARY_PATH prefix (lib/<app> mesa nss/nss)
;;;   + FONTCONFIG_FILE = fontconfig-minimal
;;;   + XDG_DATA_DIRS prefix (out/share)
;;;   + SSL_CERT_DIR = nss-certs（内置终端子进程的 TLS 信任根，见函数注释）。
;;; 基座的 wrap phase 无 #:wrap-plan 时按约定 no-op，有自定义 plan 时两者
;;; 都会跑（wrap-program 可重入，只是前缀会有重复条目）；要完全自定义 wrap
;;; 请用 #:phases 逃生舱接管，不要指望本层静默让路。
;;;
;;; 不迁清单（留在调用包自定义 phase，不进本层）：
;;;   - 自定位 / bun --compile 二进制：wrap-program 改名 .real 破坏
;;;     /proc/self/exe（neomacs-bin 实证）。
;;;   - Tauri resource_dir / sidecar 布局：按 exe_dir 基准解析
;;;    （rayburst-bin 实证），通用 install-plan 会打散。
;;;   - dotnet 内嵌 runtime 的裸 soname symlink：宿主 RPATH 对其 dlopen
;;;     不可见（opentabletdriver-bin 实证）。
;;;   - deb ABI 漂移 compat-symlink：必须建在 patch-elf 之后
;;;    （mysql-workbench 类实证），通用顺序罩不住。
;;;
;;; Builder 隔离：本模块只依赖 (guix build utils) + Guile 自带（ice-9/srfi），
;;; 禁引任何包模块（(gnu packages …) / (jeans packages …) 会污染 builder）。
;;;
;;; 对基座的假设（与 planner 冻结接口一致，基座 worker 落地时核对）：
;;;   - (jeans build binary) 导出 %standard-phases（alist），含 'install
;;;     与 'wrap 两个 phase 名（本模块的 add-after 锚点）。
;;;   - 基座 wrap 无 #:wrap-plan 时 no-op；基座没有消费 #:disable-updater? /
;;;     #:application-directory / #:wayland? 符号值的 phase（恒 dormant），
;;;     Electron 符号值只由本层两 phase 消费，不会双重注入。
;;;   - 基座 builder 经 #:allow-other-keys（或显式声明）容忍本层五个关键字
;;;     透传给 phases；各 phase 自带 #:allow-other-keys 忽略无关键。

(define-module (jeans build electron)
  #:use-module (guix build utils)
  #:use-module ((jeans build binary) #:prefix binary:)
  #:export (%standard-phases
            disable-electron-updater-phase
            prefer-electron-wayland-phase
            prefer-electron-wayland-hint-phase
            ensure-secret-service-phase
            wrap-electron-program))

(define* (disable-electron-updater-phase
          #:key outputs (application-directory #f) (disable-updater? #t)
          #:allow-other-keys)
  "删 Electron 自更新许可，有意义缺参时报错，无动作时返回 #t。"
  (when disable-updater?
    (unless (and (string? application-directory)
                 (not (string-null? application-directory)))
      (error "disable-electron-updater-phase: #:application-directory must be ~
a non-empty string when #:disable-updater? is true"
             application-directory))
    ;; electron-updater treats "package-type" as permission to replace the
    ;; application with a downloaded .deb.  Guix owns package upgrades.
    (let ((package-type
           (string-append (assoc-ref outputs "out") "/lib/"
                          application-directory
                          "/resources/package-type")))
      (when (file-exists? package-type)
        (delete-file package-type))))
  #t)

(define* (prefer-electron-wayland-phase
          #:key outputs (program #f) (wayland? 'inject-flags)
          #:allow-other-keys)
  "WAYLAND? 为 'inject-flags 时向 wrapper 注入 ozone flag，否则 no-op。"
  (when (eq? wayland? 'inject-flags)
    (unless (and (string? program) (not (string-null? program)))
      (error "prefer-electron-wayland-phase: #:program must be a non-empty ~
string when #:wayland? is 'inject-flags"
             program))
    (let ((wrapper (string-append (assoc-ref outputs "out") "/bin/" program)))
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
          "exec -a ")))))
  #t)

;; Variant for Electron apps whose own argv parser rejects Chromium's
;; --ozone-platform flags (Paseo): prefer Wayland by exporting Electron's
;; native ELECTRON_OZONE_PLATFORM_HINT instead of injecting flags.  Only
;; applied when the user has not chosen a platform themselves.
(define* (prefer-electron-wayland-hint-phase
          #:key outputs (program #f) (wayland? 'inject-flags)
          #:allow-other-keys)
  "WAYLAND? 为 'hint-env 时 export hint 变量，否则 no-op。"
  (when (eq? wayland? 'hint-env)
    (unless (and (string? program) (not (string-null? program)))
      (error "prefer-electron-wayland-hint-phase: #:program must be a ~
non-empty string when #:wayland? is 'hint-env"
             program))
    (let ((wrapper (string-append (assoc-ref outputs "out") "/bin/" program)))
      (substitute* wrapper
        (("^exec -a ")
         (string-append
          "if [ -z \"${ELECTRON_OZONE_PLATFORM_HINT:-}\" ] "
          "&& [ -n \"${WAYLAND_DISPLAY:-}\" ]; then\n"
          "  export ELECTRON_OZONE_PLATFORM_HINT=wayland\n"
          "fi\n"
          "exec -a ")))))
  #t)

;; Electron safeStorage（Linux 凭据存储）依赖 dlopen libsecret-1.so.0 +
;; 会话里的 org.freedesktop.secrets 服务；niri 等轻量 WM 会话下探测失败
;; 会退 basic_text 后端、isEncryptionAvailable() 报 false、应用拒绝持久化
;; 凭据（每次启动都要重新登录）。本 phase 在 exec 前完成三件事，全部
;; 条件化、不覆盖用户与桌面会话的既有选择：
;;   1. KDE/Plasma 直接不管：Chromium 原生 detect 会选 kwallet 直连，我们
;;      注入 --password-store=gnome-libsecret 反而把它换成 libsecret 路径；
;;   2. 其余桌面用 gdbus 探测 org.freedesktop.secrets owner（kwallet 桥 /
;;      keepassxc / gnome-keyring 等任何实现都算在位，不偏向 GNOME）；无
;;      owner 时才用包自带的 gnome-keyring-daemon 补一个 secrets 服务（兜底，
;;      不是替换），成功后再拉 gcr-prompter 供解锁弹窗；
;;   3. 仅当服务确认在位、且用户未显式传 --password-store 时，前置
;;      --password-store=gnome-libsecret（客户端是 libsecret，凭据实际
;;      落在会话选定的后端）。其余情况保持 Chromium 原生 detect。
(define* (ensure-secret-service-phase
          #:key inputs outputs (program #f)
          #:allow-other-keys)
  "能定位到 gdbus、gnome-keyring-daemon、gcr-prompter 三者时向 wrapper 注入
secrets 服务保障，否则 no-op。按 inputs 里实有的文件判定、不看 label：包依赖
这三个组件即表示需要兜底，无需另设关键字（关键字须逐层穿过 bag arguments 才
到 build 侧，而 phases 只认 builder 显式转发的键）。"
  (define (locate file)
    "在 INPUTS 里定位 FILE，找不到返回 #f（不区分是缺输入还是缺文件）。"
    (catch #t
      (lambda () (search-input-file inputs file))
      (lambda _ #f)))
  (let ((gdbus (locate "bin/gdbus"))
        (keyring (locate "bin/gnome-keyring-daemon"))
        (prompter (locate "libexec/gcr-prompter")))
    (when (and gdbus keyring prompter)
      (unless (and (string? program) (not (string-null? program)))
        (error "ensure-secret-service-phase: #:program must be a non-empty ~
string when inputs provide gdbus / gnome-keyring-daemon / gcr-prompter"
               program))
      (let ((wrapper (string-append (assoc-ref outputs "out")
                                    "/bin/" program)))
        (substitute* wrapper
          (("^exec -a ")
           (string-append
            "_had_store=0\n"
            "for _a in \"$@\"; do\n"
            "  case \"$_a\" in --password-store=*) _had_store=1 ;; esac\n"
            "done\n"
            "_secrets_ok=0\n"
            "case \"$XDG_CURRENT_DESKTOP\" in\n"
            "  *KDE*|*Plasma*) ;;\n"
            "  *)\n"
            "    _secrets_owned=$(\"" gdbus "\" call --session "
            "--dest org.freedesktop.DBus "
            "--object-path /org/freedesktop/DBus "
            "--method org.freedesktop.DBus.NameHasOwner "
            "org.freedesktop.secrets 2>/dev/null)\n"
            "    case \"$_secrets_owned\" in\n"
            "      *true*) _secrets_ok=1 ;;\n"
            "      *) \"" keyring "\" --start --components=secrets"
            " >/dev/null 2>&1 || true\n"
            "         if \"" gdbus "\" call --session "
            "--dest org.freedesktop.DBus "
            "--object-path /org/freedesktop/DBus "
            "--method org.freedesktop.DBus.NameHasOwner "
            "org.freedesktop.secrets 2>/dev/null"
            " | grep -q true; then\n"
            "           _secrets_ok=1\n"
            "           \"" prompter "\" >/dev/null 2>&1 &\n"
            "         fi ;;\n"
            "    esac\n"
            "    unset _secrets_owned ;;\n"
            "esac\n"
            "if [ \"$_had_store\" != 1 ]"
            " && [ \"$_secrets_ok\" = 1 ]; then\n"
            "  set -- --password-store=gnome-libsecret \"$@\"\n"
            "fi\n"
            "unset _secrets_ok _had_store _a\n"
            "exec -a "))))))
  #t)

(define* (wrap-electron-program
          #:key inputs outputs (program #f) (app-dir #f)
          #:allow-other-keys)
  "Electron wrap 默认三件套 + 证书环境注入，缺参时报有意义错误。"
  (unless (and (string? program) (not (string-null? program)))
    (error "wrap-electron-program: #:program must be a non-empty string"
           program))
  (unless (and (string? app-dir) (not (string-null? app-dir)))
    (error "wrap-electron-program: #:app-dir must be a non-empty string, ~
e.g. \"lib/opencode-desktop\""
           app-dir))
  (unless (assoc-ref inputs "mesa")
    (error "wrap-electron-program: 缺少 input \"mesa\"（wrap 三件套所需）" inputs))
  (unless (assoc-ref inputs "nss")
    (error "wrap-electron-program: 缺少 input \"nss\"（wrap 三件套所需）" inputs))
  (unless (assoc-ref inputs "fontconfig-minimal")
    (error "wrap-electron-program: 缺少 input \"fontconfig-minimal\"（wrap 三件套所需）" inputs))
  (unless (assoc-ref inputs "nss-certs")
    (error "wrap-electron-program: 缺少 input \"nss-certs\"（wrap 证书注入所需）" inputs))
  (let* ((out (assoc-ref outputs "out"))
         (lib (string-append out "/" app-dir))
         (mesa-lib (string-append (assoc-ref inputs "mesa") "/lib"))
         (nss-lib (string-append (assoc-ref inputs "nss") "/lib/nss"))
         (ca-dir (string-append (assoc-ref inputs "nss-certs")
                                "/etc/ssl/certs")))
    (wrap-program (string-append out "/bin/" program)
      `("LD_LIBRARY_PATH" prefix
        (,lib ,mesa-lib ,nss-lib))
      `("FONTCONFIG_FILE" =
        (,(string-append (assoc-ref inputs "fontconfig-minimal")
                         "/etc/fonts/fonts.conf")))
      `("XDG_DATA_DIRS" prefix
        (,(string-append out "/share"))))
    ;; 内置终端 spawn 的 curl/git/python/node 等子进程在 Guix 下没有编译期
    ;; 默认 CA 路径，缺 SSL_CERT_DIR 即 "证书不可信/无法连接"（zcode 内置
    ;; 终端实证：curl 000、git certificate signer not trusted、python
    ;; unable to get local issuer）。${VAR:-默认} 形式保留用户或桌面会话
    ;; 已设的值（如自签 MITM CA）。只设目录型变量：nss-certs 不产出合并
    ;; bundle，文件型变量指向不存在的文件比不设更糟。
    (substitute* (string-append out "/bin/" program)
      (("^exec -a ")
       (string-append
        "export SSL_CERT_DIR=\"${SSL_CERT_DIR:-" ca-dir "}\"\n"
        "exec -a ")))
    )
  #t)

(define %standard-phases
  (modify-phases binary:%standard-phases
    (add-after 'install 'disable-electron-updater
      disable-electron-updater-phase)
    (add-after 'wrap 'wrap-electron
      wrap-electron-program)
    (add-after 'wrap-electron 'prefer-wayland
      prefer-electron-wayland-phase)
    (add-after 'prefer-wayland 'prefer-wayland-hint
      prefer-electron-wayland-hint-phase)
    (add-after 'prefer-wayland-hint 'ensure-secret-service
      ensure-secret-service-phase)))

;;; electron.scm ends here

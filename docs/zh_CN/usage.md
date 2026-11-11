<!-- SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com> -->

<!-- SPDX-License-Identifier: GPL-3.0-only -->

# 用法指南

[**English**](../usage.md) | **中文**

本文档提供 jeans 通道的安装配置说明，以及通道内所有系统服务和 Guix Home 用户服务的完整使用指南。

---

## 目录

- [添加频道](#添加频道)
- [安装软件包](#安装软件包)
- [系统服务](#系统服务)
  - [nix-ld](#nix-ld)
  - [OpenTabletDriver](#opentabletdriver)
  - [Sunshine](#sunshine)
  - [Waydroid](#waydroid)
- [用户服务（Guix Home）](#用户服务guix-home)
  - [Neomacs](#neomacs)
  - [OpenTabletDriver 守护进程](#opentabletdriver-守护进程)
  - [Sunshine 串流服务端](#sunshine-串流服务端)
  - [nosDshell](#nosdshell)
  - [水杉输入法辅助服务](#水杉输入法辅助服务)

---

## 添加频道

在 `~/.config/guix/channels.scm` 中追加以下频道声明：

```scheme
(channel
  (name 'jeans)
  (branch "main")
  (url "https://github.com/ShineBreaker/jeans.git")
  (introduction
   (make-channel-introduction
    "35d1811c26daf2c132880fe304149b1363064a79"
    (openpgp-fingerprint
     "6271 1D5E 9CCD EC69 07CA  DBF8 8637 1322 2257 1907"))))
```

若访问 GitHub 较慢，可以使用 Codeberg 镜像：`https://codeberg.org/BrokenShine/jeans.git`，两者保持同步。

随后拉取最新频道：

```bash
guix pull
```

---

## 安装软件包

直接使用包名安装：

```bash
guix install librewolf-nongnu
```

若与其他频道重名，可使用频道前缀精确指定：

```bash
guix install jeans:librewolf-nongnu
```

完整可用软件包清单请查阅 [docs/packages.md](../packages.md)。

---

## 系统服务

### nix-ld

`nix-ld-service-type` 在系统层创建 `/lib64/ld-linux-x86-64.so.2` 动态链接器垫片软链接，并通过 `/etc/profile.d/nix-ld.sh` 配置环境变量，让面向标准 FHS 构建的预编译二进制程序无需容器或 chroot 即可在 Guix System 上直接运行。

详细原理与更多用例请参考 [nix-ld 指南](nix-ld.md)。

#### 基础配置

在 `operating-system` 的服务列表中添加：

```scheme
(use-modules (gnu services)
             (jeans services nix-ld))

(operating-system
  ;; ...
  (services
   (cons* (service nix-ld-service-type)
          %base-services)))
```

#### 配置项说明

`nix-ld-configuration` 包含以下字段：

| 字段名称    | 类型                                       | 默认值                      | 说明                                        |
| ----------- | ------------------------------------------ | --------------------------- | ------------------------------------------- |
| `package`   | `<package>`                                | `nix-ld`                    | nix-ld 核心软件包                           |
| `glibc`     | `<package>`                                | `glibc`                     | 提供目标动态链接器的 glibc 软件包           |
| `libraries` | `<package>` 或 `(<package> "output")` 列表 | `%default-nix-ld-libraries` | 注入到 `NIX_LD_LIBRARY_PATH` 中的共享库列表 |

#### 自定义扩展共享库

```scheme
(use-modules (gnu services)
             (gnu packages gl)
             (gnu packages sdl)
             (gnu packages audio)
             (jeans services nix-ld))

(service nix-ld-service-type
         (nix-ld-configuration
          (libraries
           (append %default-nix-ld-libraries
                   (list mesa sdl2 pulseaudio)))))
```

---

### OpenTabletDriver

`opentabletdriver-service-type` 配置数位板驱动的系统底层支持：

- 安装 udev 规则，授予当前登录用户访问数位板设备节点的权限。
- 自动加载 `uinput` 内核模块（用于模拟输入事件）。
- 在 `/etc/modprobe.d/99-opentabletdriver.conf` 中黑名单禁用冲突的内核模块（`wacom` 与 `hid_uclogic`）。
- 部署 `/etc/libinput/local-overrides.quirks`，避免 libinput 抢占数位板事件。
- 将 `opentabletdriver-bin` 软件包添加到系统 Profile。

#### 基础配置

```scheme
(use-modules (gnu services)
             (jeans services hardware))

(operating-system
  ;; ...
  (services
   (cons* (service opentabletdriver-service-type)
          %desktop-services)))
```

也可以使用辅助构造函数 `(opentabletdriver-service)`：

```scheme
(cons* (opentabletdriver-service)
       %desktop-services)
```

#### 配置项说明

`opentabletdriver-configuration` 包含以下字段：

| 字段名称  | 类型        | 默认值                        | 说明                                 |
| --------- | ----------- | ----------------------------- | ------------------------------------ |
| `package` | `<package>` | `opentabletdriver-udev-rules` | 包含 udev 规则的软件包               |
| `driver`  | `<package>` | `opentabletdriver-bin`        | 提供驱动可执行文件与 quirks 的软件包 |

#### 注意事项

- 系统服务仅负责底层规则与内核配置。若要在用户图形会话中启动后台驱动守护进程，需在 Guix Home 中配置 `home-opentabletdriver-service-type`。

---

### Sunshine

`sunshine-service-type` 配置 Sunshine 游戏串流服务端（配合 Moonlight 客户端使用）的系统底层要求：

- 安装 udev 规则，授予登录用户对 `/dev/uinput`、`/dev/uhid` 和虚拟手柄设备节点的读写权限。
- 自动加载 `uhid` 与 `uinput` 内核模块。
- 将 `sunshine-bin` 软件包添加到系统 Profile。
- 可选为 Sunshine 二进制可执行文件设置 `cap_sys_admin=ep` 文件权能，无需 root 权限即可通过 KMS/DRM 进行高效抓屏。

#### 基础配置

```scheme
(use-modules (gnu services)
             (gnu services avahi)
             (jeans services tools))

(operating-system
  ;; ...
  (services
   (cons* (service sunshine-service-type
                   (sunshine-configuration
                    (cap-sys-admin? #t)))
          ;; mDNS 广播服务（客户端自动发现必需）
          (service avahi-service-type)
          %desktop-services)))
```

也可以使用辅助构造函数 `(sunshine-service #:cap-sys-admin? #t)`。

#### 配置项说明

`sunshine-configuration` 包含以下字段：

| 字段名称         | 类型        | 默认值         | 说明                                             |
| ---------------- | ----------- | -------------- | ------------------------------------------------ |
| `package`        | `<package>` | `sunshine-bin` | 提供 Sunshine 主程序与 udev 规则的软件包         |
| `cap-sys-admin?` | `boolean`   | `#f`           | 是否为真实二进制赋予 `cap_sys_admin=ep` 抓屏权能 |

#### 前置要求

- **用户附加组**：串流用户必须加入 `video` 组（若系统存在 `render` 组也需加入），以获取 GPU 硬件编码权限。
- **防火墙端口**：Sunshine 默认基础端口为 47989：
  - TCP：47984、47989、47990、48010
  - UDP：47998、47999、48000、48002、48010
- **Web 管理界面**：首次使用需在本地浏览器访问 `https://localhost:47990` 完成配对和参数设置。
- **用户守护进程**：实际串流服务进程需通过 Guix Home 的 `home-sunshine-service-type` 运行在用户图形会话中。

---

### Waydroid

`waydroid-service-type` 在 Guix System 上部署基于 LXC 的 Waydroid 安卓容器运行环境：

- 全局安装 `id.waydro.Container` 对应的 D-Bus 策略与服务激活文件。
- 将 root 容器守护进程（`waydroid container start`）作为系统级 Shepherd 服务进行生命周期管理。

#### 基础配置

```scheme
(use-modules (gnu services)
             (jeans services android))

(operating-system
  ;; ...
  (services
   (cons* (service waydroid-service-type)
          %desktop-services)))
```

#### 配置项说明

`waydroid-configuration` 包含以下字段：

| 字段名称     | 类型        | 默认值     | 说明                                                                        |
| ------------ | ----------- | ---------- | --------------------------------------------------------------------------- |
| `waydroid`   | `<package>` | `waydroid` | Waydroid 软件包                                                             |
| `autostart?` | `boolean`   | `#t`       | 是否在系统开机时启动容器守护进程；设为 `#f` 时仅在通过 D-Bus 请求时按需启动 |

#### 首次初始化

首次使用前需手动下载安卓镜像：

```bash
sudo waydroid init
```

初始化完成后，在 Wayland 图形桌面中启动安卓会话：

```bash
waydroid session start
```

亦可直接从系统应用菜单中启动已安装的安卓应用。容器运行日志位于 `/var/log/waydroid-container.log`。

---

## 用户服务（Guix Home）

### Neomacs

`home-neomacs-service-type` 将 Neomacs 及其配置的 Emacs Lisp 扩展包安装到 Guix Home 环境中。

该服务构建了一个合并 Neomacs 与扩展包的内部 Profile，并通过包装器脚本自动设置 `EMACSLOADPATH` 等搜索路径，同时重写桌面应用入口与图标，确保无论在命令行还是桌面启动器中打开 Neomacs，都能无缝加载扩展。

#### 基础配置

```scheme
(use-modules (gnu home)
             (gnu services)
             (gnu packages)
             (jeans home services emacs-xyz))

(home-environment
  (services
   (list (service home-neomacs-service-type
                  (home-neomacs-configuration
                   (packages (specifications->manifest
                              '("emacs-avy"
                                "emacs-magit"))))))))
```

若无需随服务安装额外的扩展包，可直接使用默认配置 `(service home-neomacs-service-type)`。

#### 配置项说明

`home-neomacs-configuration` 包含以下字段：

| 字段名称   | 类型         | 默认值           | 说明                                                                      |
| ---------- | ------------ | ---------------- | ------------------------------------------------------------------------- |
| `neomacs`  | `<package>`  | `neomacs-bin`    | 使用的 Neomacs 软件包                                                     |
| `packages` | `<manifest>` | `(manifest '())` | 随 Neomacs 一同安装的 Emacs Lisp 扩展清单（兼容 GNU Emacs 编译的 `.elc`） |

#### 注意事项

- Neomacs 上游的 `--fg-daemon` 等守护进程模式尚未成熟稳定，因此本服务暂未注册 Shepherd 后台守护进程。

---

### OpenTabletDriver 守护进程

`home-opentabletdriver-service-type` 将数位板驱动程序安装到用户 Home Profile，并作为用户级 Shepherd 服务管理后台守护进程 `otd-daemon`。

由于 Shepherd 会在 TTY 登录时过早启动，此时图形合成器尚未就绪。该服务内置了显示等待脚本，自动检测 `$XDG_RUNTIME_DIR/wayland-*` 或 `/tmp/.X11-unix/X*`，待显示套接字生成后导出环境变量再启动 `otd-daemon`，彻底避免初始化崩溃。

#### 基础配置

```scheme
(use-modules (gnu home)
             (gnu services)
             (jeans home services hardware))

(home-environment
  (services
   (list (service home-opentabletdriver-service-type))))
```

#### 配置项说明

`home-opentabletdriver-configuration` 包含以下字段：

| 字段名称  | 类型        | 默认值                 | 说明                                                 |
| --------- | ----------- | ---------------------- | ---------------------------------------------------- |
| `package` | `<package>` | `opentabletdriver-bin` | OpenTabletDriver 软件包                              |
| `daemon?` | `boolean`   | `#t`                   | 是否作为自启动与崩溃重拉的用户 Shepherd 守护进程运行 |

#### 注意事项

- 必须与系统级服务 `opentabletdriver-service-type` 配合使用，以获得完整的 udev 权限与防冲突内核模块黑名单。

---

### Sunshine 串流服务端

`home-sunshine-service-type` 将 Sunshine 串流服务端作为用户级 Shepherd 服务运行。使用用户身份运行能够保证 Sunshine 直接连接当前用户的 Wayland 渲染套接字、GPU 节点以及本地配置目录（`~/.config/sunshine`）。

#### 基础配置

```scheme
(use-modules (gnu home)
             (gnu services)
             (jeans home services tools))

(home-environment
  (services
   (list (service home-sunshine-service-type))))
```

#### 配置项说明

`home-sunshine-configuration` 包含以下字段：

| 字段名称      | 类型        | 默认值         | 说明                       |
| ------------- | ----------- | -------------- | -------------------------- |
| `package`     | `<package>` | `sunshine-bin` | Sunshine 软件包            |
| `auto-start?` | `boolean`   | `#t`           | 是否随用户会话自动启动服务 |

#### 注意事项

- **服务依赖**：依赖 `wayland-display` 目标（由 Guix 官方 `home-wayland-service-type` 或 Rosenthal 通道的 `home-graphical-session-service-type` 提供）。
- **系统底层依赖**：必须在操作系统层面启用 `sunshine-service-type` 注入 udev 虚拟输入权限与内核模块。
- 守护进程日志默认输出至 `$XDG_STATE_HOME/shepherd/sunshine.log`（通常为 `~/.local/state/shepherd/sunshine.log` 或 `~/.local/var/log/sunshine.log`）。

---

### nosDshell

`home-nosdshell-service-type` 将基于 quickshell 的 Wayland 桌面组件 nosDshell 托管为用户 Shepherd 服务。

该服务在启动时自动继承图形会话环境变量，并等待 `dbus` 与 `wayland-display` 就绪后启动。

#### 基础配置

```scheme
(use-modules (gnu home)
             (gnu services)
             (gnu home services desktop)
             (jeans home services desktop))

(home-environment
  (services
   (list (service home-wayland-service-type)
         (service home-nosdshell-service-type))))
```

#### 配置项说明

`home-nosdshell-configuration` 包含以下字段：

| 字段名称      | 类型        | 默认值      | 说明                               |
| ------------- | ----------- | ----------- | ---------------------------------- |
| `nosdshell`   | `<package>` | `nosdshell` | nosdshell 核心软件包               |
| `auto-start?` | `boolean`   | `#t`        | 是否在图形会话就绪后自动启动 Shell |

---

### 水杉输入法辅助服务

`home-msime-service-type` 为水杉输入法（MSIME）管理运行后台 Provider 辅助守护进程：

- **在线候选词与翻译服务**（`msime-online`）：提供云端联想输入与翻译支持。
- **语音输入服务**（`msime-voice`）：提供语音识别输入后端。
- **剪贴板历史监听**（`msime-clipboard`）：可选运行的剪贴板历史收集组件。

在常见发行版中，上述组件由 systemd user socket activation 按需拉起。Guix 无 systemd 环境，本服务在用户登录后直接常驻拉起上述进程，以便 IBus 与 Fcitx5 前端引擎无缝调用相关功能。

#### 基础配置

```scheme
(use-modules (gnu home)
             (gnu services)
             (jeans home services desktop))

(home-environment
  (services
   (list (service home-msime-service-type
                  (home-msime-configuration
                   (online? #t)
                   (voice? #t)
                   (clipboard? #f))))))
```

#### 配置项说明

`home-msime-configuration` 包含以下字段：

| 字段名称                | 类型        | 默认值               | 说明                                                                                                                                     |
| ----------------------- | ----------- | -------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| `msime`                 | `<package>` | `msime-bin`          | 水杉输入法核心二进制包                                                                                                                   |
| `online?`               | `boolean`   | `#t`                 | 是否启动在线联想词与翻译服务守护进程                                                                                                     |
| `voice?`                | `boolean`   | `#t`                 | 是否启动语音输入服务守护进程                                                                                                             |
| `clipboard?`            | `boolean`   | `#f`                 | 是否启动剪贴板历史监听守护进程                                                                                                           |
| `clipboard-requirement` | 符号列表    | `'(wayland-display)` | 剪贴板监听器所依赖的 Shepherd 资源；Wayland 会话填 `'(wayland-display)`，X11 会话填 `'(x11-display)`，已在外部准备好显示变量时可填 `'()` |
| `auto-start?`           | `boolean`   | `#t`                 | 是否随用户会话自动启动所启用的 Provider                                                                                                  |

#### 注意事项

- IBus 引擎或 Fcitx5 插件等输入法前端宿主由各自框架自行加载，无需在 Shepherd 中另建服务；本服务仅负责其后台网络与辅助数据提供进程。

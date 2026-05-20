<!-- SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com> -->

<!-- SPDX-License-Identifier: GPL-3.0-only -->

               8 8888 8 8888888888            .8.          b.             8    d888888o.
               8 8888 8 8888                 .888.         888o.          8  .`8888:' `88.
               8 8888 8 8888                :88888.        Y88888o.       8  8.`8888.   Y8
               8 8888 8 8888               . `88888.       .`Y888888o.    8  `8.`8888.
               8 8888 8 888888888888      .8. `88888.      8o. `Y888888o. 8   `8.`8888.
               8 8888 8 8888             .8`8. `88888.     8`Y8o. `Y88888o8    `8.`8888.
    88.        8 8888 8 8888            .8' `8. `88888.    8   `Y8o. `Y8888     `8.`8888.
    `88.       8 888' 8 8888           .8'   `8. `88888.   8      `Y8o. `Y8 8b   `8.`8888.
      `88o.    8 88'  8 8888          .888888888. `88888.  8         `Y8o.` `8b.  ;8.`8888
        `Y888888 '    8 888888888888 .8'       `8. `88888. 8            `Yo  `Y8888P ,88P'

# jeans -- Just Enough AI-geNerated Slops.

[**English**](../README.md) \| **中文**

[**Packages**](docs/packages.md)

一个个人 [Guix Channel](https://guix.gnu.org/manual/en/html_node/Channels.html)，打包了一些前沿软件和闭源软件。

**AI 辅助生成。**

主仓库：`https://github.com/ShineBreaker/jeans.git`

镜像：`https://codeberg.org/BrokenShine/jeans.git`

---

## 目录

- [如何使用](#如何使用)
- [可用包](#可用包)
- [使用示例](#使用示例)
- [nix-ld：运行预编译二进制](#nix-ld运行预编译二进制)
- [OpenTabletDriver](#opentabletdriver)
- [开发](#开发)
- [许可证](#许可证)

---

## 如何使用

在你的 channels 配置中添加以下内容：

```scheme
                (channel
                  (name 'jeans)
                  (branch "main")
                  (url "https://github.com/ShineBreaker/jeans.git")
                  (introduction
                   (make-channel-introduction
                    "1e30ccbcaef375169d453d89d8186137bc32d9e8"
                    (openpgp-fingerprint
                     "6271 1D5E 9CCD EC69 07CA  DBF8 8637 1322 2257 1907"))))
```

如果你偏好镜像，`https://codeberg.org/BrokenShine/jeans.git` 同步相同的 `main` 分支。

然后运行 `guix pull`。

---

## 使用示例

安装包：

```bash
guix install librewolf-nongnu
```

或使用通道前缀：

```bash
guix install jeans:librewolf-nongnu
```

---

## nix-ld：运行预编译二进制

### 它是什么

[nix-ld](https://github.com/Mic92/nix-ld) 是一个最小的 ELF 动态链接器 shim（仅 62K）， 它让那些为 FHS（Filesystem Hierarchy Standard）系统编译的二进制文件——比如 Zoom、 Master PDF Editor、一些游戏客户端——能够在不遵循 FHS 的系统上直接运行。

NixOS 社区广泛使用它。jeans 通道将其移植到了 Guix System。

#### 工作原理

预编译二进制文件的 ELF header 里硬编码了对动态链接器的绝对路径引用， 例如 `/lib64/ld-linux-x86-64.so.2`。但 Guix System 没有 `/lib64/` 目录—— 动态链接器藏在 `/gnu/store/…-glibc-2.41/lib/ld-linux-x86-64.so.2`。

nix-ld 的解决方式：

1.  在 `/lib64/ld-linux-x86-64.so.2` 放一个指向 nix-ld 自身的 symlink
2.  预编译二进制启动时，内核加载 nix-ld 而非真正的 `ld-linux`
3.  nix-ld 读取环境变量 `NIX_LD`（真正的 ld-linux 路径）和 `NIX_LD_LIBRARY_PATH` （库搜索路径），然后把控制权转交给真正的动态链接器

整个过程对二进制文件完全透明。

### 快速开始

#### 1. 在操作系统配置中启用服务

在你的 `operating-system` 声明里：

```scheme
(use-modules (jeans services nix-ld))

(operating-system
  (services
   (cons* (service nix-ld-service-type)   ;; ← 添加这一行
          %base-services)))
```

重新配置系统：

```bash
sudo guix system reconfigure /path/to/your-config.scm
```

服务会自动完成以下事情：

| 动作                               | 效果                                   |
| ---------------------------------- | -------------------------------------- |
| 创建 `/lib64/ld-linux-x86-64.so.2` | symlink → nix-ld 二进制                |
| 生成 `/etc/profile.d/nix-ld.sh`    | 设置 `NIX_LD` 和 `NIX_LD_LIBRARY_PATH` |
| 将 nix-ld 加入系统 profile         | 确保 nix-ld 二进制可用                 |

#### 2. 运行预编译二进制

重新登录（让 `/etc/profile.d/nix-ld.sh` 生效），然后直接运行：

```bash
chmod +x some-fhs-binary
./some-fhs-binary
```

就这么简单。

### 自定义配置

`nix-ld-service-type` 接受一个 `nix-ld-configuration` 记录，有三个可配置字段：

| 字段        | 类型                | 默认值   | 说明                             |
| ----------- | ------------------- | -------- | -------------------------------- |
| `package`   | `<package>`         | `nix-ld` | nix-ld 包本身                    |
| `glibc`     | `<package>`         | `glibc`  | 指向真正的动态链接器的 glibc     |
| `libraries` | `list of <package>` | 见下方   | `NIX_LD_LIBRARY_PATH` 中包含的库 |

#### 默认库列表

服务默认将以下库加入 `NIX_LD_LIBRARY_PATH`：

- `glibc` — libc、libm、libpthread 等
- `(gcc "lib")` — libstdc++、libgcc_s（C++ 程序需要）
- `zlib` — 压缩库
- `bzip2` — bzip2 压缩
- `xz` — xz/lzma 压缩
- `openssl` — TLS/SSL
- `curl` — HTTP 客户端库
- `expat` — XML 解析
- `ncurses` — 终端 UI

这覆盖了绝大多数预编译二进制的依赖。如果你需要额外的库：

```scheme
(use-modules (jeans services nix-ld)
             (gnu packages gl)
             (gnu packages sdl)
             (gnu packages audio))

(service nix-ld-service-type
  (nix-ld-configuration
   (libraries
    (append
     %default-nix-ld-libraries    ;; 保留默认列表
     (list
      mesa                         ;; OpenGL
      `(,gcc "lib")                ;; libstdc++（已在默认中，此处演示语法）
      sdl2                         ;; SDL2 游戏引擎
      pulseaudio)))))              ;; 音频
```

> **注意**：`libraries` 列表中的元素可以是：
>
> - 一个 `<package>` 对象（使用其 `lib` 输出）
> - `(package "output")` 二元组（使用指定输出）

### 纯包安装（无服务）

如果你不需要 `/lib64/` symlink 和环境变量自动设置，也可以单独安装：

```bash
guix install jeans:nix-ld
```

然后手动设置环境变量：

```bash
export NIX_LD=/gnu/store/…-glibc-2.41/lib/ld-linux-x86-64.so.2
export NIX_LD_LIBRARY_PATH=/gnu/store/…-glibc-2.41/lib:\
/gnu/store/…-gcc-14.3.0-lib/lib:…
```

> 但绝大多数情况下你应该使用 **服务** 而非手动安装。

### 实际用例

#### 运行 Zoom

```bash
# Zoom 是一个典型的 FHS 预编译二进制
# 启用 nix-ld 服务后：
./zoom/zoom
```

#### 运行独立游戏

```bash
# 许多独立游戏（如 itch.io 上的）是预编译 ELF
./game-binary
```

#### 运行 IDE / 工具链

```bash
# 一些闭源 IDE 只提供预编译二进制
./some-ide/bin/run
```

### 故障排除

#### `No such file or directory` 运行二进制时

这通常意味着 `/lib64/ld-linux-x86-64.so.2` 不存在。检查服务是否启用：

```bash
ls -la /lib64/ld-linux-x86-64.so.2
```

如果不存在，重新配置系统：

```bash
sudo guix system reconfigure /path/to/your-config.scm
```

#### `error while loading shared libraries: libxxx.so`

缺少某个动态库。把它对应的 Guix 包添加到 `nix-ld-configuration` 的 `libraries` 字段。

你可以用 `ldd` 检查二进制需要哪些库：

```bash
ldd ./your-binary 2>&1 | grep "not found"
```

#### 二进制在非 x86_64 架构上不工作

nix-ld 和 `/lib64/ld-linux-x86-64.so.2` 路径是 x86_64 特定的。 aarch64 系统上的路径会是 `/lib/ld-linux-aarch64.so.1`。 当前 jeans 的 nix-ld 打包仅针对 x86_64 测试过。

#### 环境变量未设置

确保你已经重新登录，或手动 source：

```bash
source /etc/profile.d/nix-ld.sh
```

验证：

```bash
echo $NIX_LD
echo $NIX_LD_LIBRARY_PATH
```

---

## OpenTabletDriver

- 在配置中添加 `opentabletdriver-service-type`
- 通过 flatpak 安装 OpenTabletDriver
- 禁用 `hid-uclogic` 和 `wacom` 内核模块

---

## 开发

本仓库包含 `maak.scm` 用于常见任务：

```bash
# 检查包更新
maak upgrade

# 构建包
maak build librewolf-nongnu

# 导入 Rust crate 源
maak import-crate <crate-name>[@version]
```

## 许可证

本通道中的包使用各种许可证。请查看各个包定义了解详情。

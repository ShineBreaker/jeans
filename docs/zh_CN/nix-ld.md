<!-- SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com> -->

<!-- SPDX-License-Identifier: GPL-3.0-only -->

# nix-ld：运行预编译二进制文件

[**English**](../nix-ld.md) | **中文**

本文档介绍如何在 Guix System 上通过 nix-ld 服务运行面向标准 FHS（Filesystem Hierarchy Standard）环境构建的预编译二进制文件。

---

## 基本概念

[nix-ld](https://github.com/Mic92/nix-ld) 是一个体积精简（约 62 KB）的 ELF 动态链接器垫片（shim）。它使面向传统 FHS 系统构建的预编译二进制文件（例如 Zoom、各类商业软件、独立游戏等）能够直接在非 FHS 发行版上透明运行。

该方案最初在 NixOS 社区广泛使用，jeans 通道将其移植到了 Guix System。

### 工作原理

标准 Linux 发行版下的预编译 ELF 二进制文件在头部硬编码了动态链接器的绝对路径（例如 x86_64 架构下的 `/lib64/ld-linux-x86-64.so.2`）。而在 Guix System 中并不存在标准的 `/lib64/` 目录，真正的动态链接器位于 `/gnu/store/…-glibc-…/lib/ld-linux-x86-64.so.2`。

nix-ld 的解决机制如下：

1. 在系统激活阶段创建软链接 `/lib64/ld-linux-x86-64.so.2`，指向 nix-ld 二进制文件。
2. 启动预编译程序时，内核加载 nix-ld 替代原始的 `ld-linux`。
3. nix-ld 读取环境变量 `NIX_LD`（真实动态链接器路径）与 `NIX_LD_LIBRARY_PATH`（共享库搜索路径），随后将执行权转交给真正的动态链接器。

整个执行过程对运行中的二进制文件完全透明。

---

## 快速开始

### 1. 在操作系统配置中启用服务

在系统的 `operating-system` 声明中引入模块并添加服务：

```scheme
(use-modules (gnu services)
             (jeans services nix-ld))

(operating-system
  ;; ...
  (services
   (cons* (service nix-ld-service-type)
          %base-services)))
```

重新配置系统：

```bash
sudo guix system reconfigure /path/to/your-config.scm
```

该服务会自动完成以下操作：

| 操作项                             | 效果说明                                           |
| ---------------------------------- | -------------------------------------------------- |
| 创建 `/lib64/ld-linux-x86-64.so.2` | 软链接指向 nix-ld 可执行文件                       |
| 生成 `/etc/profile.d/nix-ld.sh`    | 自动配置环境变量 `NIX_LD` 与 `NIX_LD_LIBRARY_PATH` |
| 安装 nix-ld 到系统 Profile         | 确保 nix-ld 依赖程序可在全局环境中被解析           |

### 2. 运行预编译程序

重新登录当前用户会话（使 `/etc/profile.d/nix-ld.sh` 生效），赋予程序可执行权限并直接运行：

```bash
chmod +x some-fhs-binary
./some-fhs-binary
```

---

## 自定义配置

`nix-ld-service-type` 接受 `nix-ld-configuration` 记录体作为配置参数：

| 字段名称    | 类型                                       | 默认值                      | 说明                                        |
| ----------- | ------------------------------------------ | --------------------------- | ------------------------------------------- |
| `package`   | `<package>`                                | `nix-ld`                    | nix-ld 核心软件包                           |
| `glibc`     | `<package>`                                | `glibc`                     | 提供目标动态链接器的 glibc 软件包           |
| `libraries` | `<package>` 或 `(<package> "output")` 列表 | `%default-nix-ld-libraries` | 注入到 `NIX_LD_LIBRARY_PATH` 中的共享库列表 |

### 默认共享库列表

服务默认在 `NIX_LD_LIBRARY_PATH` 中包含以下常用底层库：

- `glibc`：libc、libm、libpthread 等基础 C 运行库
- `(,gcc "lib")`：libstdc++ 与 libgcc_s（C++ 程序必需）
- `zlib`：通用压缩库
- `bzip2`：bzip2 解压缩库
- `xz`：xz 与 lzma 压缩库
- `openssl`：TLS 与 SSL 加密库
- `curl`：HTTP 客户端传输库
- `expat`：XML 解析库
- `ncurses`：终端字符界面库

### 添加自定义扩展库

若目标程序依赖额外的动态库（例如图形渲染、音频或游戏接口），可以通过 `libraries` 字段追加：

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
                   (list mesa         ;; OpenGL 图形驱动库
                         sdl2         ;; SDL2 媒体框架
                         pulseaudio))))) ;; 音频输出库
```

`libraries` 列表中的元素支持两种格式：

- `<package>` 对象（默认使用其 `lib` 输出，若无 `lib` 则使用主输出）
- `(package "output")` 二元组（显式指定要使用的包输出名）

---

## 仅安装软件包（无系统服务）

若无需创建系统级 `/lib64/` 软链接和自动环境变量配置，可单独安装软件包：

```bash
guix install jeans:nix-ld
```

安装后需在当前 Shell 会话中手动配置环境变量：

```bash
export NIX_LD=/gnu/store/…-glibc-…/lib/ld-linux-x86-64.so.2
export NIX_LD_LIBRARY_PATH=/gnu/store/…-glibc-…/lib:\
/gnu/store/…-gcc-…-lib/lib:…
```

绝大多数日常场景推荐直接使用 `nix-ld-service-type` 系统服务。

---

## 典型应用场景

### 运行 Zoom

```bash
./zoom/zoom
```

### 运行独立游戏

itch.io 等平台分发的预编译 Linux 游戏：

```bash
./game-binary
```

### 运行 Steam 运行环境库

配合 `%steam-runtime-libraries` 可运行 Steam 客户端及其运行库依赖。

### 运行商业开发工具与 IDE

部分未提供源码打包的编译器、调试工具或闭源 IDE 可直接启动：

```bash
./some-ide/bin/run
```

---

## 常见问题排查

### 启动时提示 `No such file or directory`

该错误通常表示内核未能找到动态链接器 `/lib64/ld-linux-x86-64.so.2`。

检查该软链接是否存在：

```bash
ls -la /lib64/ld-linux-x86-64.so.2
```

若不存在，请检查操作系统声明中是否已添加 `nix-ld-service-type`，并重新执行系统构建：

```bash
sudo guix system reconfigure /path/to/your-config.scm
```

### 提示 `error while loading shared libraries: libxxx.so`

这表明程序运行所需的动态库未在当前库搜索路径中。

使用 `ldd` 检查缺失的具体依赖：

```bash
ldd ./your-binary 2>&1 | grep "not found"
```

在 Guix 中查找提供该库的包（例如 `guix search`），将其添加到 `nix-ld-configuration` 的 `libraries` 列表中，随后重新构建系统。

### 非 x86_64 架构支持

目前 nix-ld 与 `/lib64/ld-linux-x86-64.so.2` 路径主要针对 x86_64 平台测试。在 aarch64 架构下，对应的动态链接器路径通常为 `/lib/ld-linux-aarch64.so.1`。

### 环境变量未生效

确认是否已重新登录桌面或 TTY 会话。若需在当前 Shell 立即生效，可手动加载配置脚本：

```bash
source /etc/profile.d/nix-ld.sh
```

检验环境变量设置：

```bash
echo $NIX_LD
echo $NIX_LD_LIBRARY_PATH
```

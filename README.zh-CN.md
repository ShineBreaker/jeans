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

[**English**](./README.md) \| **中文**

[**Packages**](docs/packages.md) \| [**Usage**](docs/usage.md) \| [**nix-ld**](docs/nix-ld.md)

一个个人 [Guix Channel](https://guix.gnu.org/manual/en/html_node/Channels.html)，打包了一些前沿软件和闭源软件。

**AI 辅助生成。**

主仓库：`https://github.com/ShineBreaker/jeans.git`

镜像：`https://codeberg.org/BrokenShine/jeans.git`

---

## 目录

- [快速开始](#快速开始)
- [可用包](#可用包)
- [开发](#开发)
- [许可证](#许可证)

---

## 快速开始

- **用法指南** → [usage.md](usage.md) — 频道配置、包安装、OpenTabletDriver
- **nix-ld 指南** → [nix-ld.md](nix-ld.md) — 在 Guix System 上运行预编译二进制
- **包列表** → [packages.md](packages.md)

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

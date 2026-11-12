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

[**Packages**](docs/packages.md) \| [**Usage**](docs/zh_CN/usage.md) \| [**nix-ld**](docs/zh_CN/nix-ld.md)

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

- **用法指南** → [docs/zh_CN/usage.md](docs/zh_CN/usage.md) — 频道配置、包安装与服务使用指南
- **nix-ld 指南** → [docs/zh_CN/nix-ld.md](docs/zh_CN/nix-ld.md) — 在 Guix System 上运行预编译二进制
- **包列表** → [docs/packages.md](docs/packages.md)

---

## 开发

本仓库使用 [BLUE](https://codeberg.org/lapislazuli/blue)（`blueprint.scm`）处理常见任务：

```bash
# 检查包更新
blue upgrade

# 构建包
blue build librewolf-nongnu

# 导入 Rust crate 源
blue import-crate <crate-name>[@version]
```

## 许可证

本通道中的包使用各种许可证。请查看各个包定义了解详情。

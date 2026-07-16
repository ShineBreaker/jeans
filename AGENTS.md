# AGENTS.md — jeans Guix Channel

## 这是什么

一个个人 [Guix channel](https://guix.gnu.org/manual/en/html_node/Channels.html)，名为 **jeans**（Just Enough AI-geNerated Slops）。
用 AI 辅助打包前沿软件和闭源软件，供 GNU Guix 使用。

- 主仓库：`https://github.com/ShineBreaker/jeans.git`（`main` 分支）
- Codeberg 镜像：从 GitHub 自动同步
- 硬依赖 [nonguix](https://gitlab.com/nonguix/nonguix)（在 `.guix-channel` 中声明）。部分包从 `(nongnu ...)` 模块导入（如 `hardware.scm` 使用 `nongnu packages dotnet`）

<critical> 在进行任何操作前，请先执行 `git pull` ，以防止CI的提交未被拉取到本地</critical>

## 构建命令

任务运行器使用 [BLUE](https://codeberg.org/lapislazuli/blue)，定义在 `blueprint.scm`（已从原先的 `maak` 迁移）。所有命令在仓库根目录执行。

```bash
# 列出所有可用命令
blue help

# 构建单个包
blue build <包名>
# 等价于: guix build --load-path=./modules <包名>
# 支持多包: blue build pkg-a pkg-b

# 检查所有包的上游更新
blue upgrade
# 内部调用 scripts/check-updates/update_versions.py

# 从 crates.io 导入 Rust crate 源码
blue import-crate <crate名>[@版本]
# 使用 guix import crate，自动检测 ./Cargo.lock
# 在 rust-crates.scm 的 ssss-separator 前插入 crate-source 定义

# 根据 modules/ 里的包定义重新生成 docs/packages.md
blue gen-docs
# 内部通过 guix repl 运行 scripts/gen-docs.scm，读取每个包的 name/synopsis
# 加载失败的模块会被跳过并给出警告（例如依赖未满足时）

# 直接 guix 构建（替代方案）
guix build -L modules <包名>
```

## 仓库结构

```
modules/                          # 通道包目录（由 .guix-channel 指定）
├──jeans.scm                       # 顶层模块：通过 %public-modules 重新导出所有子模块
├──jeans/packages/                 # 按类别组织的包定义
│  ├──agent.scm                     # OpenCode/Orca/ZCode 及其他 AI agent 包；开源预编译包使用 -bin，闭源/限制性许可证包不使用 -bin
│  ├──browser.scm                   # librewolf-nongnu（trivial-build-system，omni.ja 补丁）
│  ├──desktop.scm                   # python-screeninfo, waypaper
│  ├──fonts.scm                     # font-maple-font-nf-cn, font-misans, font-nerd-symbols, font-nerd-font-iosevka
│  ├──games.scm                     # lr2oraja-endlessdream-bin, osu-lazer-bin（开源预编译包，AppImage/JAR 提取）
│  ├──hardware.scm                  # opentabletdriver-udev-rules
│  ├──nix-ld.scm                    # nix-ld（从上游镜像的 Rust 源码构建包）
│  ├──theme.scm                     # colloid-gtk-theme, vimix-gtk-themes, vimix-kvantum-themes, orchis-kde-themes, colloid-kde-themes
│  ├──tools.scm                     # winapps, jdtls-bin, motrix-next-bin, cc-switch-bin,
│  │                                # git-credential-keepassxc, amber-pm
│  └──rust-crates.scm               # Rust crate 源码 —— 由 guix import 管理，禁止手动编辑
├──jeans/services/
│  └──hardware.scm                  # Guix 服务定义（opentabletdriver-service-type）
└──jeans/patches/
   └──winapps-fix-install-paths.patch # 通过 search-patches 被包定义引用的补丁

scripts/
├──check-updates/
│  ├──update_versions.py            # 自动版本检查器（GitHub API）
│  ├──test_updated_packages.py      # 对所有本次更新的包进行构建测试
│  ├──config.json                   # 更新器的跳过/预发布配置
│  └──manifest.scm                  # guix shell 环境：python + python-requests
├──jgen-docs.scm                    # 由 `blue gen-docs` 调用，生成 docs/packages.md
blueprint.scm                     # BLUE 蓝图：任务运行器（build/upgrade/import-crate/gen-docs）
```

## 提交信息规范

前缀风格：`ADD:`、`FIX:`、`UPDATE:`、`FEATURE:`、`MIGRATE:` —— 后跟简短描述。
自动更新 CI 使用 `UPDATE: auto package update YYYY-MM-DD`。

## 仓库约定与陷阱

仓库级别的硬性约定；具体 Guix 打包细节（包定义模式、构建系统、命名规范、input label 规范、阶段修改等）见 `.agents/skills/pack-guix/SKILL.md`。

- **`nonguix` 通道是硬依赖** —— 在 `.guix-channel` 中声明，构建时必须可用。
- **不要从其他通道复制 `rust-crates.scm`**。版本不匹配会导致 `cargo build --offline` 失败。始终使用 `blue import-crate` 或 `guix import crate --lockfile`。
- **`licenses/misans.txt`** 被 `font-misans` 通过 `local-file` 以相对路径引用（`../../../licenses/misans.txt`）—— 路径相对于 `.scm` 文件，而非仓库根目录。
- **文件头**：所有 `.scm` 文件使用 `SPDX-FileCopyrightText` 和 `SPDX-License-Identifier` 头。新文件应包含 `BrokenShine <xchai404@gmail.com>` 版权。
- **`#:use-module ((guix licenses) #:prefix license:)`** 是许可证的标准导入模式 —— 总是以 `license:` 为前缀。
- **`jeans.scm`** 重新导出所有子模块 —— 添加新包文件时，将其模块加入 `jeans.scm` 的 `%public-modules`。

## 更新工作流

1. 运行 `blue upgrade` —— 脚本扫描 `modules/jeans/packages/` 中的所有 `.scm` 文件，通过正则解析 `define-public` 块，检查 GitHub releases/tags/commits API。
2. **url-fetch 包**：通过 `guix download <url>` 自动计算正确的 `base32`。
3. **git-fetch 包**：`git clone --depth=1` + `guix hash -rx <dir>` 计算 hash。部分包设置占位 hash；你必须重新构建以获取真实 hash。
4. 版本规范化：去除 GitHub 标签的 `v` 前缀（Guix 约定：不带 `v` 前缀）。
5. `scripts/check-updates/config.json` 中的配置：
   - `check_pre_release`：同时检查预发布版本的包。
   - `skip_packages`：完全跳过的包。记得用中文来撰写
   - `skip_files`：跳过的文件（如 `rust-crates.scm`）。
6. 退出码：0 = 无更新，1 = 已应用更新，2 = 出错。
7. 更新后，`test_updated_packages.py` 对所有更新包运行 `guix build`；不要通过包名后缀跳过闭源或预编译包。

## CI 流水线

`auto-update.yml` 工作流每周运行（周二、四、六 02:00 UTC）或手动触发：

1. 运行更新脚本 → 检测变更
2. 安装 Guix 并 `guix pull` 更新到最新版本
3. 构建测试所有更新的包
4. 全部通过后 GPG 签名提交 → 推送到 GitHub → 镜像到 Codeberg
5. 构建失败则阻止提交，并创建 GitHub Issue 通知

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

自动更新采用 **guix refresh 主力 + Python 脚本兜底** 的分层架构。两层都在 CI 的同一个 job 内串行执行，先 refresh 后 Python，最后合并两路的更新集合统一构建测试。

### 第 1 层：guix refresh（主力）

`guix refresh -u` 接管大部分包的上游版本检测和源码改写（version + base32）。要让 refresh 正确识别一个包，包定义需要带合适的 `properties`：

- **`upstream-name`**：几乎对所有 `-bin` 包必需。github updater 用它匹配 release 资产文件名前缀（如 `crush-bin` 的 upstream-name 是 `crush`，因为资产文件名是 `crush_*.deb` 而非 `crush-bin_*`）。
- **`release-tag-prefix`**：正则，当 repo 有多个 tag 系列时指定跟踪哪个（如 reasonix-bin 用 `"^v"`）。
- **`accept-pre-releases?`**：布尔，允许 refresh 考虑预发布版本。

refresh 覆盖：GitHub release 包（带 upstream-name）和 git-fetch 有 tag 包（generic-git updater）。`rust-crates.scm` 中是私有 `crate-source` origin，不是可供 `guix refresh -t crate` 更新的 package；依赖更新必须通过 `blue import-crate` / `guix import crate --lockfile` 重新生成。

### 第 2 层：Python 脚本（兜底）

`scripts/check-updates/update_versions.py` 处理 guix refresh 力不能及的包，分三类：

- **通用逻辑**（GitHub 源）：url-fetch 包（从 release 资产发现版本）和 git-fetch 包（tag / commit / let-绑定 git-version 追踪），其中无 tag 固定 commit 包（`winapps`/`orchis-kde-themes`/`colloid-kde-themes`）用 `let`+`git-version` 结构，脚本追踪 main 分支 commit 并更新 let 绑定的 commit + 自增 revision；`with-latest-git-commit` property 已写入但本机 Guix 尚未实现该功能。
- **特殊源处理器**（`SPECIAL_UPDATERS` 映射，按包名分发，版本信号不在 GitHub 上）：
  - `zcode`：z.ai CDN 无目录列表，从官网 `zcode.z.ai/cn` 的 JS 内嵌版本列表（`releases/X.Y.Z`）取最新
  - `amber-pm`：gitee 仓库无 tag，用 gitee API `/branches/master` 追踪 master 最新 commit（通用逻辑只认 GitHub）
  - `jdtls-bin`：GitHub tags 发现版本 + 抓 `download.eclipse.org/jdtls/milestones/<v>/` 目录页提取归档时间戳（`-YYYYMMDDHHMM` 不在 version 里，通过 `extra_replacements` 一并改写）
  - `font-misans`：zip 无版本号，以 `Last-Modified` 为更新信号，基线存 `font-misans-state.json`（227MB zip 不能每次下载算 hash；`ETag/Last-Modified` 变了才下载）
- **stale 监控**：`config.json` 的 `stale_watch` 中的包无法自动更新（继承上游 / 有意冻结），超 `stale_days`（默认 14）天无手动更新则在 CI 发提醒 issue；周期记忆存 `stale-state.json`。

Python 脚本也用 `config.json` 的 `tag_prefix`/`check_pre_release` 作为兜底规则。三个状态文件（`report.json`、`font-misans-state.json`、`stale-state.json`）中只有后两个入库，且每次提交时随包改动一起更新。

### 合并与构建测试

- `refresh-changed-packages.sh` 从 git diff 提取 refresh 改动的包名 → `refresh-updates.json`
- `test_updated_packages.py` 合并 Python 的 `report.json`（`status == "updated"`）和 `refresh-updates.json`，对并集逐个 `guix build`
- 不要通过包名后缀跳过闭源或预编译包

### 版本号约定

- 版本格式完全遵从 Guix 上游规定。`generic-git` updater 会把日期 tag（如 `2025-07-31`）规范化为 `2025.07.31`，这是预期行为。
- 无 tag 包用 `(git-version base revision commit)` 生成版本号（如 `0-0.7f6b6ab`），格式为 `base-revision.commit前7位`。
- GitHub 标签的 `v` 前缀会被去除（Guix 约定：不带 `v` 前缀）。

### 退出码（Python updater）

0 = 无更新，1 = 已应用更新，2 = 出错。

## CI 流水线

`auto-update.yml` 工作流每周运行（周二、四、六 02:00 UTC）或手动触发：

1. 安装 Guix + `guix pull` + checkout nonguix（提前、无条件，供 refresh 使用）
2. **guix refresh**（主力）：改写 GitHub release 包 + git-fetch 包；记录改动的包到 `refresh-updates.json`
3. **Python updater**（兜底）：通用逻辑 + 特殊源处理器（zcode/amber-pm/jdtls-bin/font-misans），写 `report.json`
4. 检测变更（含未跟踪的 state 文件）→ 合并两路更新集合 → 构建测试所有更新的包
5. 全部通过后 GPG 签名提交（含 state 文件）→ 推送到 GitHub → 镜像到 Codeberg
6. 构建失败则阻止提交，并创建 GitHub Issue 通知
7. **stale 监控**：无法自动更新的包（`stale_watch`）超 14 天无手动更新，发提醒 issue

关键环境变量：`GUIX_GITHUB_TOKEN`（映射自 `GITHUB_TOKEN`）是 guix refresh 读 GitHub API 的专属变量名，必须单独设置。

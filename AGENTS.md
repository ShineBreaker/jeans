# AGENTS.md — jeans Guix Channel

## 这是什么

一个个人 [Guix channel](https://guix.gnu.org/manual/en/html_node/Channels.html)，名为 **jeans**（Just Enough AI-geNerated Slops）。
用 AI 辅助打包前沿软件和闭源软件，供 GNU Guix 使用。

- 主仓库：`https://github.com/ShineBreaker/jeans.git`（`main` 分支）
- Codeberg 镜像：从 GitHub 自动同步
- 硬依赖 [nonguix](https://gitlab.com/nonguix/nonguix)（在 `.guix-channel` 中声明）。部分包从 `(nongnu ...)` 模块导入（如 `hardware.scm` 使用 `nongnu packages dotnet`）

## 构建命令

```bash
# 构建单个包
maak build <包名>
# 等价于: guix build --load-path=./modules <包名>
# 支持多包: maak build pkg-a pkg-b

# 检查所有包的上游更新
maak upgrade
# 内部调用 scripts/check-updates/update_versions.py

# 直接 guix 构建（替代方案）
guix build -L modules <包名>

# 从 crates.io 导入 Rust crate 源码
maak import-crate <crate名>[@版本]
# 使用 guix import crate，自动检测 ./Cargo.lock
# 在 rust-crates.scm 的 ssss-separator 前插入 crate-source 定义
```

## 仓库结构

```
modules/                          # 通道包目录（由 .guix-channel 指定）
  jeans.scm                       # 顶层模块：通过 %public-modules 重新导出所有子模块
  jeans/packages/                 # 按类别组织的包定义
    browser.scm                   # librewolf-nongnu（trivial-build-system，omni.ja 补丁）
    desktop.scm                   # python-screeninfo, waypaper, zen-browser-bin, opencode-desktop-bin
    fonts.scm                     # font-maple-font-nf-cn, font-misans, font-nerd-symbols, font-nerd-font-iosevka
    games.scm                     # lr2oraja-endlessdream-bin, osu-lazer-bin（-bin 后缀，AppImage 提取）
    hardware.scm                  # opentabletdriver-udev-rules
    nix-ld.scm                    # nix-ld（从上游镜像的 Rust 源码构建包）
    theme.scm                     # colloid-gtk-theme, vimix-gtk-themes, vimix-kvantum-themes, orchis-kde-themes, colloid-kde-themes
    tools.scm                     # crush-bin, winapps, jdtls-bin, motrix-next-bin, cc-switch-bin,
                                  # git-credential-keepassxc, opencode-bin, oh-my-pi-bin, amber-pm
    rust-crates.scm               # Rust crate 源码 —— 由 guix import 管理，禁止手动编辑
  jeans/services/
    hardware.scm                  # Guix 服务定义（opentabletdriver-service-type）
  jeans/patches/
    WinApps.patch                 # 通过 local-file 被包定义引用的补丁
scripts/check-updates/
  update_versions.py              # 自动版本检查器（GitHub API）
  test_updated_packages.py        # 对更新的非二进制包进行构建测试
  config.json                     # 更新器的跳过/预发布配置
  manifest.scm                    # guix shell 环境：python + python-requests
maak.scm                          # 构建任务运行器（maak 工具）
```

## 提交信息规范

前缀风格：`ADD:`、`FIX:`、`UPDATE:`、`FEATURE:`、`MIGRATE:` —— 后跟简短描述。
自动更新 CI 使用 `UPDATE: auto package update YYYY-MM-DD`。

## 包定义模式

### Rust 打包（双文件模式）

Rust 包使用双文件模式：

1. **`rust-crates.scm`** —— `crate-source` 定义 + `define-cargo-inputs` 映射。**由 `guix import crate --lockfile` 管理，禁止手动编辑。** 更新脚本完全跳过此文件。
2. **包文件**（如 `desktop.scm`、`tools.scm`）—— `package` 定义，通过 `(cargo-inputs '<name> #:module '(jeans packages rust-crates))` 引用依赖。

关键 Rust 包参数：

- 应用 crate 总是指定 `#:rust rust-1.88`（或当前版本）和 `#:install-source? #f`。
- crate 根为 workspace 根时使用 `#:cargo-install-paths ''(".")`。
- Rust 包可能需要自定义 `unpack` 阶段来改写 `Cargo.toml` 条目（去除 `git =`、`rev =` 行，替换为 `version = "*"` 以支持 vendored 依赖）。

### 预编译二进制包（`-bin` 后缀）

二进制包有三种常见形态，处理方式不同：

- **AppImage 包**：用 `7z x` 提取，然后对所有 ELF 二进制和 `.so` 文件执行 `patchelf`。使用 `copy-build-system` 配合 `#:install-plan`。
- **tar.gz/deb 等归档包**：`gnu-build-system`，删除 `configure`/`build` 阶段，自定义 `install`。
- **裸 ELF 可执行文件**（如 oh-my-pi-bin）：`gnu-build-system`，`replace 'unpack` 阶段用 `copy-file` 直接复制原始二进制。安装到 `lib/<pkg>/`，然后从 `bin/` 创建 ld-linux wrapper。

所有预编译二进制包的通用规则：

- `patchelf` 用于设置 ELF 解释器（`ld-linux`）和 RPATH（指向 Guix store 路径）。
- 设置 `#:tests? #f`（无源码 → 无测试）。
- 设置 `#:validate-runpath? #f`（预编译二进制无法通过 Guix 的 runpath 校验）。
- 设置 `#:strip-binaries? #f`（预编译二进制不支持 Guix 的 strip，会导致损坏）。
- 二进制安装到 `lib/<pkg>/`，然后从 `bin/` 创建符号链接，使 patchelf 能找到同目录的 `.so` 文件。
- 二进制包（`-bin`）被排除在 CI 构建测试之外 —— 只有源码包会被测试构建。

**⚠️ 裸 ELF 的陷阱**：即使 `readelf -d` 显示 NEEDED 为空，运行时仍可能通过 `dlopen` 加载 native addon（如 oh-my-pi 的 `pi_natives.linux-x64-modern.node`）。这些 addon 可能依赖 `libgcc_s.so.1`，因此 inputs 中需要包含 `(,gcc "lib")`。

### `trivial-build-system` 包装模式

`librewolf-nongnu` 使用一种特殊模式：

- `source #f` + `trivial-build-system` 配合 `#:builder` —— 操作继承包的 store 输出。
- `(inherit librewolf)` 包装上游 Guix 包。
- `dereference!` 辅助函数在补丁前将符号链接替换为实际副本（Guix store 路径是只读的符号链接）。
- `chmod` 舞蹈：`#o644` → 补丁 → `#o444`（先写权限，修改，再恢复只读）。
- 通过嵌入式 Python 脚本进行 `omni.ja` 补丁 —— 解压、修改 JS 模块、重新打包。

### Git-Fetch 固定提交包

- 滚动提交包的版本格式：`0-unstable-YYYY-MM-DD`。
- 更新脚本对 git-fetch 包使用占位 hash（`000...000`）；你必须重新构建以获取正确的 hash。
- 固定提交包：`(let ((commit "...") (revision "0")) ...)` 配合 `(git-version ...)`。

### 通用构建阶段模式

- **`wrap-program`**：总是包装以设置 `PATH`、`LD_LIBRARY_PATH`、`GI_TYPELIB_PATH`、`XDG_DATA_DIRS` 等。
- **`substitute*`**：用于补丁 `.desktop` 文件、配置文件和源码文件。
- **`(,gcc "lib")`**：选择包的子输出的语法。
- **私有辅助包**：仅在同一文件内使用的包用 `define`（而非 `define-public`）。

### 字体包

- 标准字体归档使用 `font-build-system`。
- 单文件字体下载使用 `copy-build-system`。
- 本地许可证文件使用 `(local-file "../../../licenses/<file>")`，路径相对于 `.scm` 文件而非仓库根目录。

### 服务定义

模式：`define-record-type*` → 带扩展的 `service-type` → 便捷包装函数。

服务扩展：

- `udev-service-type` 用于 udev 规则
- `kernel-module-loader-service-type` 用于内核模块

## 更新工作流

1. 运行 `maak upgrade` —— 脚本扫描 `modules/jeans/packages/` 中的所有 `.scm` 文件，通过正则解析 `define-public` 块，检查 GitHub releases/tags/commits API。
2. **url-fetch 包**：通过 `guix download <url>` 自动计算正确的 `base32`。
3. **git-fetch 包**：`git clone --depth=1` + `guix hash -rx <dir>` 计算 hash。部分包设置占位 hash；你必须重新构建以获取真实 hash。
4. 版本规范化：去除 GitHub 标签的 `v` 前缀（Guix 约定：不带 `v` 前缀）。
5. `scripts/check-updates/config.json` 中的配置：
   - `check_pre_release`：同时检查预发布版本的包。
   - `skip_packages`：完全跳过的包。
   - `skip_files`：跳过的文件（如 `rust-crates.scm`）。
6. 退出码：0 = 无更新，1 = 已应用更新，2 = 出错。
7. 更新后，`test_updated_packages.py` 对更新的非二进制包运行 `guix build`。

## CI 流水线

`auto-update.yml` 工作流每周运行（周一 02:00 UTC）或手动触发：

1. 在 Ubuntu runner 上安装 Guix
2. 运行更新脚本 → 检测变更
3. 使用工作流密钥进行 GPG 签名提交
4. 构建测试更新的非二进制包
5. 推送到 GitHub → 镜像到 Codeberg
6. 为构建失败创建 GitHub Issues（带去重）

## 已知陷阱

- **不要从其他通道复制 `rust-crates.scm`**。版本不匹配会导致 `cargo build --offline` 失败。始终使用 `guix import crate --lockfile`。
- **`licenses/misans.txt`** 被 `font-misans` 通过 `local-file` 以相对路径引用（`../../../licenses/misans.txt`）—— 路径相对于 `.scm` 文件，而非仓库根目录。
- **`nonguix` 通道是硬依赖** —— 在 `.guix-channel` 中声明，构建时必须可用。
- **文件头**：所有 `.scm` 文件使用 `SPDX-FileCopyrightText` 和 `SPDX-License-Identifier` 头。新文件应包含 `BrokenShine <xchai404@gmail.com>` 版权。
- **`#:use-module ((guix licenses) #:prefix license:)`** 是许可证的标准导入模式 —— 总是以 `license:` 为前缀。
- **`jeans.scm`** 重新导出所有子模块 —— 添加新包文件时，将其模块加入 `jeans.scm` 的 `%public-modules`。

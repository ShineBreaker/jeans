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
scripts/
  check-updates/
    update_versions.py            # 自动版本检查器（GitHub API）
    test_updated_packages.py      # 对更新的非二进制包进行构建测试
    config.json                   # 更新器的跳过/预发布配置
    manifest.scm                  # guix shell 环境：python + python-requests
  gen-docs.scm                    # 由 `blue gen-docs` 调用，生成 docs/packages.md
blueprint.scm                     # BLUE 蓝图：任务运行器（build/upgrade/import-crate/gen-docs）
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

**⚠️ 裸 ELF 的陷阱**：即使 `readelf -d` 显示 NEEDED 为空，运行时仍可能通过 `dlopen` 加载 native addon（如 oh-my-pi 的 `pi_natives.linux-x64-modern.node`）。这些 addon 可能依赖 `libgcc_s.so.1`，因此 inputs 中需要包含 gcc 的 `lib` 子输出（写法见下方「input label 规范」）。

**⚠️ input label 规范（必须遵守以通过 `guix lint`）**：

`guix lint` 的 `check-input-labels` 检查要求 input 的 label（标签）与包的**实际 `name` 字段**完全一致——带子输出时还要附加 `:output`。本通道因此统一采用**旧式 quasiquote alist** 写法，而非现代的 `(list ...)`：

```scheme
;; ✅ 正确：quasiquote alist，label 与 package name 一致
(inputs `(("bash-minimal" ,bash-minimal)
          ("glibc" ,glibc)
          ("gcc:lib" ,gcc "lib")))           ; ← 带 output 的 input，label 必须是 name:output

;; ❌ 错误：现代 (list ...) 形式无法为带 output 的 input 生成满足 lint 的 label
(inputs (list bash-minimal glibc `(,gcc "lib")))   ; 会触发 "label 'gcc' does not match 'gcc:lib'"
```

关键规则：

- **带子输出的 input**（如 `gcc "lib"`）：label 必须是 `"name:output"`（即 `"gcc:lib"`），来自 `(,pkg "lib")` 在现代形式下只会生成裸 `"gcc"`，永远过不了 lint。
- **label 必须用包的实际 `name`，而非变量名**：见下方「变量名 ≠ 包名」陷阱。
- **build-side 查询要同步**：`(assoc-ref inputs "gcc:lib")`、`(this-package-input "gcc:lib")` 必须与 label 一致；否则返回 `#f` 导致构建期 `wrong-type-arg` 错误。
- 上游 Guix 的官方惯例也是 quasiquote alist（见 `gnu/packages/elf.scm` 的 `` `(("gcc:lib" ,gcc "lib")) ``）。

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
- **选择包的子输出**（如 gcc 的 lib）：用 quasiquote alist 形式 `("gcc:lib" ,gcc "lib")`（label 必须是 `name:output`，详见上方「input label 规范」）。**禁止**在现代 `(list ...)` 里写 `(,gcc "lib")`——会触发 lint 警告且无法清除。
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

1. 运行 `blue upgrade` —— 脚本扫描 `modules/jeans/packages/` 中的所有 `.scm` 文件，通过正则解析 `define-public` 块，检查 GitHub releases/tags/commits API。
2. **url-fetch 包**：通过 `guix download <url>` 自动计算正确的 `base32`。
3. **git-fetch 包**：`git clone --depth=1` + `guix hash -rx <dir>` 计算 hash。部分包设置占位 hash；你必须重新构建以获取真实 hash。
4. 版本规范化：去除 GitHub 标签的 `v` 前缀（Guix 约定：不带 `v` 前缀）。
5. `scripts/check-updates/config.json` 中的配置：
   - `check_pre_release`：同时检查预发布版本的包。
   - `skip_packages`：完全跳过的包。记得用中文来撰写
   - `skip_files`：跳过的文件（如 `rust-crates.scm`）。
6. 退出码：0 = 无更新，1 = 已应用更新，2 = 出错。
7. 更新后，`test_updated_packages.py` 对更新的非二进制包运行 `guix build`。

## CI 流水线

`auto-update.yml` 工作流每周运行（周二、四、六 02:00 UTC）或手动触发：

1. 运行更新脚本 → 检测变更
2. 安装 Guix 并 `guix pull` 更新到最新版本
3. 构建测试所有更新的包
4. 全部通过后 GPG 签名提交 → 推送到 GitHub → 镜像到 Codeberg
5. 构建失败则阻止提交，并创建 GitHub Issue 通知

## 已知陷阱

- **不要从其他通道复制 `rust-crates.scm`**。版本不匹配会导致 `cargo build --offline` 失败。始终使用 `guix import crate --lockfile`。
- **`licenses/misans.txt`** 被 `font-misans` 通过 `local-file` 以相对路径引用（`../../../licenses/misans.txt`）—— 路径相对于 `.scm` 文件，而非仓库根目录。
- **`nonguix` 通道是硬依赖** —— 在 `.guix-channel` 中声明，构建时必须可用。
- **文件头**：所有 `.scm` 文件使用 `SPDX-FileCopyrightText` 和 `SPDX-License-Identifier` 头。新文件应包含 `BrokenShine <xchai404@gmail.com>` 版权。
- **`#:use-module ((guix licenses) #:prefix license:)`** 是许可证的标准导入模式 —— 总是以 `license:` 为前缀。
- **`jeans.scm`** 重新导出所有子模块 —— 添加新包文件时，将其模块加入 `jeans.scm` 的 `%public-modules`。
- **变量名 ≠ 包名（input label 陷阱）**：写 input 的 label 时必须用包的**实际 `name` 字段**，而非 import 进来的变量名。已知不符的包：
  - `fontconfig`（变量名）→ `name` 是 `"fontconfig-minimal"`
  - `openjdk17`（变量名）→ `name` 是 `"openjdk"`
  - 拿不准时先 `guix show <var>` 看 `name:` 字段，或 `(package-name <var>)` 在 repl 里查。quasiquote alist 里 label 写错会同时触发 lint 警告**并**让 build-side 的 `(assoc-ref inputs ...)` / `(this-package-input ...)` 返回 `#f`。
- **`#$<symbol>` gexp 引用必须是已导出的绑定**：在 gexp（`#$`）里引用包时，符号必须真实存在于 import 的模块里。例如 `(gnu packages gcc)` 导出的是 `gcc`，不导出 `gcc:lib`——写 `#$gcc:lib` 会成为未绑定符号，但因 gexp 是惰性求值，**只在构建时才爆**（模块加载期不报错），是危险的潜伏 bug。正确写法：`#$(this-package-input "gcc:lib")`（按 label 查）或 `#$(gcc "lib")`（显式 output）。

---

## Guix 打包参考

以下为通用的 Guix 打包知识，补充 jeans 特定约定之上。

### 包结构基础

每个 Guix 包遵循此结构：

```scheme
(define-public package-name
  (package
    (name "package-name")
    (version "1.0.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://example.com/package-" version ".tar.gz"))
       (sha256
        (base32 "hash-here"))))
    (build-system gnu-build-system)  ; 或 cargo-build-system 等
    (arguments
     `(#:tests? #t
       #:configure-flags '("--enable-feature")))
    (native-inputs (list pkg-config))
    (inputs (list openssl zlib))
    (propagated-inputs (list python))
    (home-page "https://example.com")
    (synopsis "Short one-line description")
    (description "Longer multi-line description of the package.")
    (license license:expat)))
```

#### 必填字段

- **name**: 包名（字符串）
- **version**: 版本（字符串）
- **source**: 源码获取方式（origin 块）
- **build-system**: 构建系统
- **synopsis**: 单行描述（<80 字符）
- **description**: 详细描述
- **license**: 许可证（来自 `(guix licenses)`）
- **home-page**: 项目 URL

#### 源码获取方式

**URL 下载:**

```scheme
(source
 (origin
   (method url-fetch)
   (uri (string-append "https://example.com/" version ".tar.gz"))
   (sha256 (base32 "hash"))))
```

**Git 获取:**

```scheme
(source
 (origin
   (method git-fetch)
   (uri (git-reference
         (url "https://github.com/user/repo")
         (commit (string-append "v" version))))
   (file-name (git-file-name name version))
   (sha256 (base32 "hash"))))
```

**Crate URI（Rust）:**

```scheme
(source
 (origin
   (method url-fetch)
   (uri (crate-uri "package-name" version))
   (file-name (string-append name "-" version ".tar.gz"))
   (sha256 (base32 "hash"))))
```

#### 获取源码 Hash

```bash
# URL
guix hash https://example.com/package-1.0.0.tar.gz

# 解压后的目录
guix hash -rx /path/to/source

# Git 仓库
guix hash -rx $(guix build --source package-name)
```

### 构建系统

#### cargo-build-system（Rust）

```scheme
(build-system cargo-build-system)
(arguments
 `(#:install-source? #f          ; 不安装源码
   #:cargo-test-flags             ; 可选的测试标记
   '("--release" "--"
     "--skip=failing_test")))
(inputs (cargo-inputs 'package-name #:module '(jeans packages rust-crates)))
```

**要点:**

- 使用 `cargo-inputs` 并指定 `#:module '(jeans packages rust-crates)` 从 jeans 通道解析依赖
- 依赖定义在 `rust-crates.scm` 文件中

#### gnu-build-system

用于 autotools 项目（./configure && make && make install）：

```scheme
(build-system gnu-build-system)
(arguments
 `(#:configure-flags
   '("--enable-shared"
     "--with-feature")
   #:make-flags
   '("CC=gcc")
   #:tests? #t
   #:phases
   (modify-phases %standard-phases
     (add-after 'unpack 'patch-source
       (lambda _
         (substitute* "src/main.c"
           (("/usr/bin") (which "bin"))))))))
```

**标准阶段:**

1. `unpack` - 解压源码
2. `patch-source-shebangs` - 修复脚本解释器
3. `configure` - 运行 ./configure
4. `build` - 运行 make
5. `check` - 运行 make check
6. `install` - 运行 make install
7. `patch-shebangs` - 修复已安装脚本

#### python-build-system / pyproject-build-system

```scheme
;; Legacy
(build-system python-build-system)
(arguments
 `(#:tests? #f
   #:python ,python-3))

;; Modern
(build-system pyproject-build-system)
(native-inputs (list python-setuptools python-wheel))
```

#### cmake-build-system

```scheme
(build-system cmake-build-system)
(arguments
 `(#:tests? #f
   #:configure-flags
   '("-DUSE_SYSTEM_LIBS=ON"
     "-DBUILD_TESTS=OFF")))
```

### 输入类型与依赖

#### native-inputs

**构建时**需要的工具（运行时不需要）：

- pkg-config
- 编译器（gcc, rust, clang）
- 构建工具（cmake, autoconf）
- 测试框架

```scheme
(native-inputs (list pkg-config cmake python-pytest))
```

#### inputs

运行时依赖：

- 库（openssl, zlib）
- 程序调用的可执行文件
- 共享库

```scheme
(inputs (list openssl curl libffi))
```

#### propagated-inputs

必须对使用此包的用户可见的依赖：

- 你的模块导入的 Python 模块
- 你的头文件需要的头文件
- 你的库链接的库

```scheme
(propagated-inputs (list python-requests python-numpy))
```

#### cargo-inputs

Rust 包使用 jeans 通道的依赖：

```scheme
(inputs (cargo-inputs 'package-name #:module '(jeans packages rust-crates)))
```

### 阶段与修改

#### 标准阶段操作

```scheme
(arguments
 `(#:phases
   (modify-phases %standard-phases
     ;; 删除阶段
     (delete 'configure)

     ;; 替换阶段
     (replace 'install
       (lambda* (#:key outputs #:allow-other-keys)
         (let ((out (assoc-ref outputs "out")))
           (install-file "binary" (string-append out "/bin")))))

     ;; 在已有阶段之前添加
     (add-before 'build 'set-environment
       (lambda _
         (setenv "CC" "gcc")))

     ;; 在已有阶段之后添加
     (add-after 'unpack 'patch-source
       (lambda _
         (substitute* "setup.py"
           (("/usr") (assoc-ref %outputs "out"))))))))
```

#### 常见阶段修改

**修补 Shebangs:**

```scheme
(add-after 'unpack 'patch-shebangs
  (lambda _
    (substitute* "script.sh"
      (("/bin/bash") (which "bash"))
      (("/usr/bin/env") (which "env")))))
```

**跳过测试:**

```scheme
(arguments
 `(#:tests? #f))  ; 禁用所有测试

;; 或跳过特定测试:
(arguments
 `(#:cargo-test-flags
   '("--release" "--"
     "--skip=test_network"
     "--skip=test_timing")))
```

**自定义安装:**

```scheme
(add-after 'build 'install
  (lambda* (#:key outputs #:allow-other-keys)
    (let* ((out (assoc-ref outputs "out"))
           (bin (string-append out "/bin"))
           (lib (string-append out "/lib")))
      (mkdir-p bin)
      (copy-file "target/release/binary"
                 (string-append bin "/binary"))
      (chmod (string-append bin "/binary") #o755))))
```

### 常见工作流

#### 打包 Rust 应用

```bash
# 1. 准备环境
guix shell rust rust:cargo cargo-audit cargo-license

# 2. 生成 lockfile 并检查依赖
cd /path/to/source
cargo generate-lockfile
cargo audit          # 检查安全问题
cargo license        # 验证许可证

# 3. 导入包模板
guix import crate package-name > modules/jeans/packages/target.scm

# 4. 导入依赖（-f = --lockfile, -i = 插入到文件）
guix import -i modules/jeans/packages/rust-crates.scm \
      crate -f /path/to/Cargo.lock package-name

# 5. 编辑包定义
# - 设置正确的版本
# - 添加 home-page、synopsis、description
# - 按需配置 arguments

# 6. 构建
guix build -L modules package-name

# 7. 测试
guix shell -L modules package-name -- package-name --version
```

#### 打包 Python 应用

```bash
# 1. 从 PyPI 导入
guix import pypi package-name > modules/jeans/packages/python-target.scm

# 2. 编辑并构建
guix build -L modules python-package-name
```

#### 去除捆绑依赖

当包捆绑了库时：

```scheme
(source
 (origin
   ...
   (snippet
    #~(begin
        (use-modules (guix build utils))
        ;; 删除捆绑的库
        (delete-file-recursively "vendor/libffi")
        (delete-file-recursively "vendor/openssl")
        ;; 修补以使用系统库
        (substitute* "build.rs"
          (("vendor/") ""))))))
```

### 最佳实践

#### 安全与许可证

```bash
cargo audit              # Rust 安全漏洞
cargo license            # 验证可接受的许可证
```

在包定义中：

```scheme
;; 明确指定许可证
(license license:expat)  ; MIT
(license license:asl2.0) ; Apache 2.0
(license (list license:expat license:asl2.0))  ; 双重许可
```

#### 跨平台编译

```scheme
#:phases
#~(modify-phases %standard-phases
    #$@(if (%current-target-system)
           ;; 跨编译
           #~((add-before 'build 'set-cross-env
                (lambda _
                  (setenv "TARGET" #$(%current-target-system)))))
           ;; 原生编译
           #~()))
```

#### 文件命名与组织

包文件按类别组织，使用 kebab-case：

- **按领域**：`browser.scm`、`desktop.scm`、`fonts.scm`、`games.scm`、`tools.scm`
- **按语言**（绑定/库）：`python-xyz.scm`
- **特殊文件**：`rust-crates.scm`（自动管理）

遵循 jeans 现有文件约定。优先将包添加到已有类别文件中；仅在没有已有类别匹配时才创建新文件。

#### 模块组织

**包文件头:**

```scheme
;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-only

(define-module (jeans packages category)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system cargo)
  #:use-module (gnu packages rust))
```

**导入组织:**

1. License 模块（带 prefix）
2. Guix 核心模块
3. 构建系统模块
4. 包模块（按字母顺序）

#### 测试与验证

**所有新包和修改过的包必须通过以下完整验证流程：**

```bash
# 1. 构建包
guix build -L modules package-name

# 2. Lint 检查（必须！）
#    检查 synopsis/description 格式、许可证一致性、home-page 可达性等
guix lint -L modules package-name

# 3. 在隔离环境中试用
guix shell -L modules package-name -- package-name --help

# 4. 验证依赖
guix graph package-name | dot -Tpng > graph.png
```

**Lint 是强制性步骤**，不是可选的。每个包在首次打包或修改后都必须通过 `guix lint` 检查，修复所有报告的问题后再提交。

### 快速参考

#### 常用命令

```bash
# 导入包模板
guix import crate PACKAGE > modules/jeans/packages/file.scm
guix import pypi PACKAGE > modules/jeans/packages/file.scm

# 构建包
guix build -L modules PACKAGE

# 本地安装
guix package -L modules -i PACKAGE

# 带包进入 shell
guix shell -L modules PACKAGE

# Lint 检查（打包后必须运行）
guix lint -L modules PACKAGE

# 显示包信息
guix show PACKAGE

# 检查依赖
guix graph PACKAGE

# 获取源码 hash
guix hash FILE
guix hash -rx DIRECTORY
```

#### jeans 文件位置

- **包定义**: `modules/jeans/packages/*.scm`
- **Rust crates**: `modules/jeans/packages/rust-crates.scm`
- **服务定义**: `modules/jeans/services/*.scm`
- **补丁**: `modules/jeans/patches/`
- **许可证文件**: `licenses/`

#### 获取帮助

```bash
# 手册
info guix

# 包文档
guix show PACKAGE

# 在线资源
# - Guix 手册: https://guix.gnu.org/manual/
# - Guix Cookbook: https://guix.gnu.org/cookbook/
# - 邮件列表: help-guix@gnu.org
```

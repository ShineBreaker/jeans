# jeans 通道打包约定

jeans 仓库的特定约定，补充通用 Guix 知识（见 `guix-reference.md`）。所有新包与修改包都应符合这些规则。

## 命名规范（按许可证/源码状态，而非构建系统）

判断 `-bin` 后缀的依据是上游**源码可见性 + 许可证**，不是本地 build-system 或文件格式。

| 软件状态                                 | 本通道直接分发           | 命名                                 |
| ---------------------------------------- | ------------------------ | ------------------------------------ |
| MIT/GPL/Apache/MPL 等开源软件            | 预编译产物，未从源码构建 | 加 `-bin`（`opencode-bin` 等）       |
| 同一软件已有源码包                       | 预编译变体               | 用 `-bin` 区分                       |
| 闭源软件                                 | 只有预编译产物           | 不加 `-bin`（`zcode` 等）            |
| 源码可见但 FSL 或其他非自由/限制性许可证 | 预编译产物               | 加 `-bin`，使用 nonguix 的 `nonfree` |
| 从源码构建                               | 源码包                   | 不因构建结果含二进制而添加 `-bin`    |

示例：`opencode-bin`、`orca-ide-bin`、`zen-browser-bin`、`osu-lazer-bin`（开源预编译）；`zcode`、`github-copilot`（闭源）。

## 自动更新 properties（决定包能否被 guix refresh 接管）

`guix refresh` 是 CI 自动更新的主力。要让 refresh 正确识别并更新一个包，包定义需要带合适的 `properties` 字段。**新建包时必须根据以下规则设置 properties**，否则包将无法被自动更新，或被误判为"无 updater"。

### upstream-name（GitHub release 包几乎必需）

github updater 用 release 资产 URL 的文件名前缀匹配包。`package-upstream-name`（无此 property 时回退到 package name）必须出现在文件名中。

对 `-bin` 包，Guix 包名（如 `crush-bin`）通常**不等于**上游 repo 名（`crush`），而 release 资产文件名（如 `crush_0.85.0_amd64.deb`）用的是 repo 名。不加 `upstream-name` 会导致 `guix refresh` 报 "no updater"（静默失败，不报具体原因）。

**规则**：upstream-name 的值 = release 资产文件名里 version 之前的前缀。判断方法：看 `releases/download/{tag}/` 后面的文件名，去掉 version 部分，剩下的就是 upstream-name。

```scheme
;; crush-bin 的资产是 crush_{version}_amd64.deb → upstream-name = "crush"
(properties `((upstream-name . "crush")))

;; 不需要 upstream-name 的情况：资产文件名恰好以 Guix 包全名开头
;; 如 mypackage-1.0.tar.gz 且 Guix 包名就是 mypackage → 不加
```

多个 property 用 alist 合并：
```scheme
(properties `((upstream-name . "reasonix") (release-tag-prefix . "^v")))
```

### release-tag-prefix（多 tag 系列时必需）

当同一个 GitHub repo 有多个 release tag 系列（如 `v1.0`/`v2.0` 和 `desktop-v1.0`/`desktop-v2.0`），用正则指定跟踪哪个系列。值是**正则表达式**：

```scheme
(properties `((release-tag-prefix . "^v")))           ; 只匹配 v 开头的 tag
(properties `((release-tag-prefix . "^desktop-v")))   ; 只匹配 desktop-v 开头
(properties `((release-tag-prefix . "^rust-v")))      ; 只匹配 rust-v 开头
```

### accept-pre-releases?（跟踪预发布版本）

允许 guix refresh 考虑预发布版本（alpha/beta/rc）。**注意 property 名带问号**：

```scheme
(properties `((accept-pre-releases? . #t)))
```

### with-latest-git-commit（无 tag 仓库追踪 commit）

见下方「Git-Fetch 固定提交包 → 上游无 tag」章节。仅用于上游不打 tag 的 git-fetch 包，配合 `let`+`git-version` 结构。

### properties 写在哪里

`(properties ...)` 是 package 的一个字段，放在 `(license ...)` 之前（作为倒数第二个字段）。用 quasiquote（反引号）+ alist：

```scheme
(package
  ...
  (properties `((upstream-name . "foo") (release-tag-prefix . "^v")))
  (license license:expat))
```

### 验证 properties 是否生效

加完 properties 后，用 dry-run 验证 guix refresh 能否识别（带 `GUIX_GITHUB_TOKEN` 避免匿名限流）：

```bash
GUIX_GITHUB_TOKEN="$(gh auth token)" guix refresh -L modules -L /tmp/nonguix <package-name>
# "已是最新" 或 "would be upgraded" = 识别成功
# "no updater" = properties 配置有误，检查 upstream-name 是否匹配文件名前缀
```

### Python updater 兜底（guix refresh 力不能及的包）

少数包 guix refresh 无法处理，仍由 `update_versions.py` + `config.json` 兜底：
- **非 GitHub 源**：CDN（zcode）、gitee（amber-pm）、无 version URL（font-misans）
- **npm scoped tag**：kimi-code-bin（`@scope/name@version` 模式）
- **refresh URL 重建失败的边缘 case**：reasonix-desktop-bin（`desktop-v` 前缀 + 文件名不标准）
- 这些包的 tag_prefix / pre-release 规则保留在 `config.json`，不写入 properties。

## Rust 打包（双文件模式）

Rust 包使用双文件结构：

1. **`modules/jeans/packages/rust-crates.scm`** —— `crate-source` 定义 + `define-cargo-inputs` 映射。**由 `guix import crate --lockfile` 或 `blue import-crate` 管理，禁止手动编辑。** 这些定义是私有 origin，不是 package，不能交给 `guix refresh -t crate`；Python updater 和 CI refresh 都跳过此文件。
2. **包文件**（如 `desktop.scm`、`tools.scm`）—— `package` 定义，通过 `(cargo-inputs '<name> #:module '(jeans packages rust-crates))` 引用依赖。

关键参数：

- 应用 crate 总是指定 `#:rust rust-1.88`（或当前版本）和 `#:install-source? #f`。
- crate 根为 workspace 根时使用 `#:cargo-install-paths ''(".")`。
- Rust 包可能需要自定义 `unpack` 阶段来改写 `Cargo.toml` 条目（去除 `git =`、`rev =` 行，替换为 `version = "*"` 以支持 vendored 依赖）。

```scheme
(build-system cargo-build-system)
(arguments
 `(#:install-source? #f
   #:cargo-test-flags '("--release" "--"
     "--skip=failing_test")))
(inputs (cargo-inputs '<name> #:module '(jeans packages rust-crates)))
```

### 更新现有 cargo 包的依赖（升级 crate 版本）

cargo 包升级时，`guix refresh` 只能改写包文件里的 `version`/`hash`，**不会**碰 `rust-crates.scm`。新版本的传递依赖必须重新 import 并合并。完整流程（记录于 git-credential-keepassxc 0.14.2→0.14.3 的升级事故）：

1. **先查 MSRV，否则白干。** 新版 `Cargo.lock` 里某个依赖的 `rust-version` 可能高于 Guix 已打包的 rust（`guix show rust | grep version`）。例：sysinfo 0.39.1 要求 rustc 1.95，而 Guix 当时最新只有 1.93。**这种升级必须整体跳过**——合并脚本能重写定义，但变不出更新的 rustc。查 MSRV：下载新 crate 源码，`grep -r rust-version Cargo.lock` 或看构建报错 `requires Rust 1.X`。

2. **导入新依赖集：**
   ```bash
   WORK="$(mktemp -d /tmp/<pkg>-XXXXXX)"
   guix download "$(crate-uri '<pkg>' '<new-ver>')" -o "$WORK/src.tar.gz"
   tar xf "$WORK/src.tar.gz" -C "$WORK"
   guix import crate --lockfile "$WORK/<pkg>-<new-ver>/Cargo.lock" \
     > "$WORK/import.scm"
   ```
   `import.scm` 是扁平的 `(define rust-... (crate-source ...))` 列表，**它的全部 define 就是新的 input 列表**（已用 0.14.2 的 266 个 input 全部能在现有 define 中找到验证过）。

3. **用 `scripts/check-updates/merge_crate_inputs.py` 合并**（不要手写脚本，历史事故都来自这里）：
   ```bash
   python3 scripts/check-updates/merge_crate_inputs.py \
     <pkg> modules/jeans/packages/rust-crates.scm "$WORK/import.scm" --dry-run
   # dry-run 报告 OK 后去掉 --dry-run 正式执行
   ```
   脚本做三件事：在 `ssss-separator` 前插入缺失的 crate-source 定义；用括号深度匹配替换 `<pkg>` 的 input 列表；断言每个 input 变量都有定义。

   **这个脚本修正了旧脚本的两个致命 bug**：
   - 正则 `rust-[a-z0-9.+-]+` 必须含 `-`（crate 名如 `objc2-open-directory`）和 `+`（版本如 `1.0.3+wasi-0.2.9`）。旧的 `rust-[\w.+]+` 在连字符处截断，静默漏掉一半定义 → 文件被清空。
   - input 列表的 `(list ...)` 必须保留**内层**右括号（`scm[list_close-1:]`，不是 `scm[list_close:]`），否则 `(key => (list ...))` 项的外层括号丢失 → 整个 `define-cargo-inputs` 块语法错误。

4. **验证只信 guix，不信 wrapper 退出码。** `blue build`/shell 的 `$?` 反映的是 wrapper 是否成功调用 guix，**不是**构建是否成功。必须读 guix 输出里的字样：
   ```bash
   guix build -L modules <pkg> --dry-run    # 先确认模块能加载（语法/括号）
   blue build <pkg>                          # 再真实构建，grep 输出里的 "失败"/"error"
   ```
   guile 能 `use-modules` 加载不代表语法正确（可能命中 `.go` cache）；`guix build --dry-run` 报 `unexpected end of input` 才是真相。

## 预编译二进制包

预编译包有三种常见形态，处理方式不同。

### AppImage 包

用 `7z x` 提取，对所有 ELF 二进制和 `.so` 文件执行 `patchelf`。使用 `copy-build-system` 配合 `#:install-plan`：

```scheme
(build-system copy-build-system)
(arguments
 (list
  #:tests? #f
  #:validate-runpath? #f
  #:strip-binaries? #f
  #:install-plan
  #~'(("bin/%upstream-program%" "bin/"))))
(native-inputs (list patchelf))
```

### tar.gz / .deb 等归档包

`gnu-build-system`，删除 `configure`/`build` 阶段，自定义 `install`。

### 裸 ELF 可执行文件

`gnu-build-system`，`replace 'unpack` 阶段用 `copy-file` 直接复制原始二进制。安装到 `lib/<pkg>/`，然后从 `bin/` 创建 ld-linux wrapper。**裸 ELF 的陷阱**：即使 `readelf -d` 显示 NEEDED 为空，运行时仍可能通过 `dlopen` 加载 native addon（如 oh-my-pi 的 `pi_natives.linux-x64-modern.node`）。这些 addon 可能依赖 `libgcc_s.so.1`，因此 inputs 中需要包含 gcc 的 `lib` 子输出。

完整模板见 `references/package-template.scm`。

### 所有预编译包的通用规则

- `patchelf` 用于设置 ELF 解释器（`ld-linux`）和 RPATH（指向 Guix store 路径）。
- 设置 `#:tests? #f`（无源码 → 无测试）。
- 设置 `#:validate-runpath? #f`（预编译二进制无法通过 Guix 的 runpath 校验）。
- 设置 `#:strip-binaries? #f`（预编译二进制不支持 Guix 的 strip，会导致损坏）。
- 二进制安装到 `lib/<pkg>/`，然后从 `bin/` 创建符号链接，使 patchelf 能找到同目录的 `.so` 文件。
- 自动更新 CI（guix refresh 主力 + Python 兜底）会对本次更新的所有包运行构建测试；预编译包同样需要验证解包、patchelf 和 wrapper 阶段。

## input label 规范（必须遵守以通过 `guix lint`）

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

- **带子输出的 input**（如 `gcc "lib"`）：label 必须是 `"name:output"`（即 `"gcc:lib"`）。`(,pkg "lib")` 在现代形式下只会生成裸 `"gcc"`，永远过不了 lint。
- **label 必须用包的实际 `name`，而非变量名**：见下方「变量名 ≠ 包名」陷阱。
- **build-side 查询要同步**：`(assoc-ref inputs "gcc:lib")`、`(this-package-input "gcc:lib")` 必须与 label 一致；否则返回 `#f` 导致构建期 `wrong-type-arg` 错误。
- 上游 Guix 的官方惯例也是 quasiquote alist（见 `gnu/packages/elf.scm` 的 `` `(("gcc:lib" ,gcc "lib")) ``）。
- `references/package-template.scm` 使用 `quasiquote` + `unquote` 形式以兼容 lint。

## `trivial-build-system` 包装模式

`librewolf-nongnu` 使用一种特殊模式，仅在确实需要复用上游 Guix 包输出时才使用：

- `source #f` + `trivial-build-system` 配合 `#:builder` —— 操作继承包的 store 输出。
- `(inherit librewolf)` 包装上游 Guix 包。
- `dereference!` 辅助函数在补丁前将符号链接替换为实际副本（Guix store 路径是只读的符号链接）。
- `chmod` 舞蹈：`#o644` → 补丁 → `#o444`（先写权限，修改，再恢复只读）。
- 通过嵌入式 Python 脚本进行 `omni.ja` 补丁 —— 解压、修改 JS 模块、重新打包。

## Git-Fetch 固定提交包

git-fetch 包按上游是否打 tag 分两种写法，直接影响能否被 `guix refresh` 自动更新。

### 上游有 tag：`(commit version)` 或 `(commit (string-append "v" version))`

generic-git updater 能直接处理。version 字段是字面字符串，commit 表达式引用 version 变量：

```scheme
(define-public colloid-gtk-theme
  (package
    (name "colloid-gtk-theme")
    (version "2025-07-31")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/vinceliuice/Colloid-gtk-theme")
             (commit version)))          ; tag 名 == version 字符串
       (file-name (git-file-name name version))
       (sha256 (base32 "hash"))))         ; tag 包的 hash；更新时需重算
    ...))
```

若 tag 带 `v` 前缀：`(commit (string-append "v" version))`。

### 上游无 tag（追踪 main HEAD）：`let` + `git-version` + `with-latest-git-commit`

上游不打 tag 时，用 `let` 绑定 commit/revision，version 由 `(git-version base revision commit)` 求值生成（格式 `base-revision.commit前7位`，如 `0-0.7f6b6ab`）。**必须**加 `with-latest-git-commit` property：

```scheme
(define-public winapps
  (let ((commit "7f6b6abf575e3f93614aeeacb75b609372e7f1a6")
        (revision "0"))                  ; 首次为 "0"，每次追踪到新 commit 自增
    (package
      (name "winapps")
      (version (git-version "0" revision commit))   ; → "0-0.7f6b6ab"
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/winapps-org/winapps")
               (commit commit)))         ; 引用 let 的 commit 符号，不是字面量
         (file-name (git-file-name name version))
         (sha256 (base32 "hash"))))
      ...
      (properties `((with-latest-git-commit . #t)))  ; 触发 latest-git-commit updater
      (license ...))))
```

**注意**：`with-latest-git-commit` 在 Guix ≤ 9e068cc0（截至 2026-07）**尚未实现**（bug#53144 设计但未合入）。property 写入待上游支持后自动生效；在此之前，这些包的 commit 追踪由 `update_versions.py` 的 let-git-version 适配逻辑负责（解析 let 绑定的 commit，追踪 main HEAD，自增 revision，重算 hash）。`revision` 初值统一用 `"0"`。

### 更新时重算 hash

git-fetch 包更新版本/commit 后，必须重新构建以获取正确的 base32。占位 hash（`000...000`）只用于占位，不能提交。

## 通用构建阶段模式

- **`wrap-program`**：总是包装以设置 `PATH`、`LD_LIBRARY_PATH`、`GI_TYPELIB_PATH`、`XDG_DATA_DIRS` 等。
- **`substitute*`**：用于补丁 `.desktop` 文件、配置文件和源码文件。
- **选择包的子输出**（如 gcc 的 lib）：用 quasiquote alist 形式 `("gcc:lib" ,gcc "lib")`（label 必须是 `name:output`，详见上方「input label 规范」）。**禁止**在现代 `(list ...)` 里写 `(,gcc "lib")`——会触发 lint 警告且无法清除。
- **私有辅助包**：仅在同一文件内使用的包用 `define`（而非 `define-public`）。

## 字体包

- 标准字体归档使用 `font-build-system`。
- 单文件字体下载使用 `copy-build-system`。
- 本地许可证文件使用 `(local-file "../../../licenses/<file>")`，路径相对于 `.scm` 文件而非仓库根目录。

## 服务定义

模式：`define-record-type*` → 带扩展的 `service-type` → 便捷包装函数。

服务扩展：

- `udev-service-type` 用于 udev 规则
- `kernel-module-loader-service-type` 用于内核模块

## 输入 label 的具体陷阱

### 变量名 ≠ 包名（input label 陷阱）

写 input 的 label 时必须用包的**实际 `name` 字段**，而非 import 进来的变量名。已知不符的包：

- `fontconfig`（变量名）→ `name` 是 `"fontconfig-minimal"`
- `openjdk17`（变量名）→ `name` 是 `"openjdk"`

拿不准时先 `guix show <var>` 看 `name:` 字段，或 `(package-name <var>)` 在 repl 里查。quasiquote alist 里 label 写错会同时触发 lint 警告**并**让 build-side 的 `(assoc-ref inputs ...)` / `(this-package-input ...)` 返回 `#f`。

### `#$<symbol>` gexp 引用必须是已导出的绑定

在 gexp（`#$`）里引用包时，符号必须真实存在于 import 的模块里。例如 `(gnu packages gcc)` 导出的是 `gcc`，不导出 `gcc:lib`——写 `#$gcc:lib` 会成为未绑定符号，但因 gexp 是惰性求值，**只在构建时才爆**（模块加载期不报错），是危险的潜伏 bug。

正确写法：

- `#$(this-package-input "gcc:lib")` —— 按 label 查
- `#$(gcc "lib")` —— 显式 output

### XDG_DATA_DIRS / gdk-pixbuf 陷阱

在手写 wrapper 脚本（`with-output-to-file`）里设置 `XDG_DATA_DIRS` 时，**必须**用追加语法 `"${XDG_DATA_DIRS:+:$XDG_DATA_DIRS}"`，保留系统原有的 `~/.guix-home/profile/share`、`/run/current-system/profile/share` 等路径。如果用 `export XDG_DATA_DIRS=...`（精确替换）覆盖掉系统路径，gdk-pixbuf 会找不到 loaders cache 和 mime 数据 → GTK 加载 PNG 图标时崩溃（`Gtk:ERROR ... Unrecognized image file format (gdk-pixbuf-error-quark, 3)` SIGABRT）。这个 bug 极其隐蔽：构建正常、`guix lint` 通过、纯 gdk-pixbuf 程序（不调 `gtk_init`）正常，只有完整 GTK 应用才崩。

同样适用于 `GDK_PIXBUF_MODULE_FILE`：Guix 的 gdk-pixbuf 用补丁加了 `GUIX_GDK_PIXBUF_MODULE_FILES`（复数），上游的 `GDK_PIXBUF_MODULE_FILE`（单数）在 Guix 环境下指向的 store cache 通常只有部分 loader（无 PNG/JPEG，因为它们是内建的），设置它反而有害——应让 gdk-pixbuf 从 profile 继承。

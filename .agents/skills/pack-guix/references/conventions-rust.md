# jeans 通道打包约定 — Rust 打包

<!-- 2026-11-12 由 references/jeans-conventions.md 按主题拆分；内容为整段原样搬迁 -->

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

### Cargo git 依赖（尤其是 workspace 型）

`guix import crate --lockfile` 支持解析 Cargo.lock 里的 git 依赖：为每个 git crate 生成 git-fetch origin（变量/版本带 commit 后缀，如 `rust-steel-core-0.8.3.118fb9f`，hash 为整个仓库 checkout 的 NAR），若上游 commit 是一个**单 crate 仓库**则 vendor 机制直接可用（上游 rust-crates.scm 的 `rust-ecies-ed25519-ng-0.5.3.554ca29` 即此形态）。importer 对 workspace 会在 define 上方注释 `TODO REVIEW: Define standalone package if this is a workspace`——这是给维护者的信号，不是能直接构建的产物。

**workspace 型 git 依赖不能直接 vendor**：`crate-src?` 对目录走 `cargo-package?`（要求 Cargo.toml 含 `[package]` 段），virtual workspace（只有 `[workspace]`）被拒；且 cargo-build-system 生成的 `.cargo/config` 只有 `[source.crates-io] replace-with` 规则，`cargo build --offline` 遇到 `git =` 依赖声明无法 checkout（报 `can't checkout from '...': you are in the offline mode`）。解决方案（helix-steel 实例，`editor.scm:272`）：把 git checkout 作为普通 input 传入（label 需加 `-checkout` 后缀，guix 给 git-fetch origin 的 label 规则），patch 阶段把**所有** `git = "...<url>"` 声明改写为 `path = "<checkout>/<crate目录>"`——path 依赖离线可解析，且 checkout 内部各 crate 的相互 path 依赖保持自洽，只需改写入口声明。注意入口声明可能不止根 Cargo.toml 一处（helix-steel 分支里 `steel-doc` 直接写在 `helix-term/Cargo.toml`，不走 `workspace = true`），改写前 `grep -rn "git = " --include=Cargo.toml` 全量排查。

配置块（`define-cargo-inputs` 的条目）里同 commit 的多个 git 变体可只保留一个（其余是同一 checkout 的重复 input）；define 保留不动以便将来 import 重跑 diff 最小。

**追踪特性分支**：let-git-version 包默认追踪 GitHub 默认分支；上游实际开发在特性分支时，在 properties 加 `(git-branch . "<分支名>")`（updater 的 `get_latest_commit` 支持），否则 CI 拿到的会是默认分支（主线）的 commit，构建必然失败（helix-steel 实例：默认分支是上游主线 master）。

### 新建 cargo 包：merge 脚本会创建新键

`merge_crate_inputs.py` 原先只能替换**已存在**的 `<pkg>` input 列表，新包会报
`ERROR: input list for <pkg> not found`。脚本已扩展「新包分支」：键不存在时，
从 `define-cargo-inputs` 块里第一个条目推导缩进网格（key 21 列、`(list` 47 列、
item 48 列），在块尾插入新的 `(pkg => (list ...))` 条目（ai-usagebar 560 inputs、
satty 211 inputs 实证）。流程不变：`guix import crate --lockfile <Cargo.lock> >
import.scm` → `merge_crate_inputs.py <pkg> rust-crates.scm import.scm --dry-run`
→ 去 dry-run 正式执行。import.scm 的 define 数 = Cargo.lock crate 数减去
**从源码构建的 path 成员/根包**（satty：213 − 根 satty − path 成员 satty_cli = 211；
herdr：297 − 根 − ghostty-vt − path-patch portable-pty = 294）。

### workspace 安装跳过陷阱（has-executable-target? 取 packages[0]）

cargo-build-system 的 install 阶段用 `has-executable-target?` 判断要不要跑
`cargo install`，它读 `cargo metadata --no-deps` 的 **`packages[0]`** 的 targets。
**workspace 里 packages[0] 可能是 lib 成员而非根 bin 包**——satty 的 packages[0]
是 `satty_cli`（纯 lib，无 bin），于是判定「无二进制目标」，install 阶段 0.0s
跳过、不装 bin，后续自定义 wrap 阶段对不存在的 `bin/satty` 调 wrap-program 报
`system-error "link" … No such file or directory`（satty 0.22.0 实证）。

修复：显式 `#:cargo-install-paths ''(".")` 强制 `cargo install --path .` 装根包
（该参数非空时 install 阶段绕过 has-executable-target? 判断）。**凡 workspace
根包含 bin 的 cargo 包都应加这一行**，不要依赖自动探测。单 crate 包（ai-usagebar）
packages[0] 即自身，不受影响。

### 系统库混入 cargo inputs；sqlite 要用 sqlite-next

系统库与 crate 依赖混装：把系统包 `cons`/`append` 进 `inputs`，crate 依赖仍走
`(cargo-inputs '<pkg> #:module '(jeans packages rust-crates))`（helix-steel
`editor.scm:718`、ai-usagebar、satty 实证）：

```scheme
(inputs (cons sqlite-next (cargo-inputs 'ai-usagebar #:module '(jeans packages rust-crates))))
;; 多个系统库：
(inputs (append (list gtk libadwaita pango gdk-pixbuf glib cairo graphene fontconfig libepoxy libglvnd)
                (cargo-inputs 'satty #:module '(jeans packages rust-crates))))
```

**rusqlite 非 bundled 时链接系统 `-lsqlite3`，且 Guix 的 `sqlite` 变量太旧**：
`sqlite` 钉在 3.39.3，而 rusqlite 0.39（libsqlite3-sys 0.39.1）引用
`sqlite3_set_clientdata`（SQLite **3.44+** 才引入）→ 链接报 `undefined reference
to sqlite3_set_clientdata`。改用同模块 `(gnu packages sqlite)` 导出的
**`sqlite-next`**（3.53.4，上游注释「Newer version required for e.g. fossil」）。
凡 rusqlite/libsqlite3-sys 非 bundled 的包一律用 sqlite-next（ai-usagebar 实证）。

GTK4/relm4 源码包的 -sys crate 经 pkg-config 探测系统库，输入集参照 satty：
`pkg-config`（native）+ gtk/libadwaita/pango/gdk-pixbuf/glib/cairo/graphene/
fontconfig/libepoxy；OpenGL 由 glow/femtovg 运行时 dlopen，加 libglvnd 提供
libGL/libEGL dispatch 即可不依赖系统 GL。build.rs 若用 `ci-release` feature 把
completions/man 写进源码根，install 后自定义 phase 按上游 Makefile 布局安装。

**cargo-build-system 强制一批 -sys crate 链接系统库（不是 bundled C）**：
`configure` 阶段（上游 `guix/build/cargo-build-system.scm:280-285`）无条件 setenv
`GETTEXT_SYSTEM=1`、`LIBGIT2_SYS_USE_PKG_CONFIG=1`、`LIBSQLITE3_SYS_USE_PKG_CONFIG=1`、
`LIBSSH2_SYS_USE_PKG_CONFIG=1`、`RUSTONIG_SYSTEM_LIBONIG=1`、`SODIUM_USE_PKG_CONFIG=1`、
`ZSTD_SYS_USE_PKG_CONFIG=1`。凡依赖树里出现对应的 -sys crate（gettext-sys /
libgit2-sys / libsqlite3-sys / libssh2-sys / **onig_sys** / libsodium-sys /
zstd-sys），就**必须**把系统库加进 inputs、`pkg-config` 加进 native-inputs，否则
build.rs 报 `The pkg-config command could not be found` / `Unable to find X in
pkg-config` 而整个 build 阶段失败。这是上游刻意的范式（Guix 的 `rust-onig-sys`
还用 snippet `delete-file-recursively "oniguruma"` 删掉 bundled 副本），不要靠
unset 环境变量退回 bundled C 绕过。

- **onig_sys → oniguruma**（`(gnu packages regex)`）。fresh-editor 0.5.8 实证：
  首构在 onig_sys 处失败（`RUSTONIG_SYSTEM_LIBONIG is set ... pkg-config could
  not be found`），修复 = `(native-inputs (list pkg-config))` +
  `(inputs (cons oniguruma (cargo-inputs 'fresh-editor ...)))`，与上游 bat 完全
  一致（`gnu/packages/rust-apps.scm:554-555`：`(native-inputs (list pkg-config))`
  / `(inputs (cons* libgit2-1.9 oniguruma zlib (cargo-inputs 'bat)))`）。
- **审计方法**：`grep -E '^name = "(onig_sys|libsqlite3-sys|zstd-sys|libgit2-sys|libsodium-sys|gettext-sys|libssh2-sys|openssl-sys)"' Cargo.lock`，
  命中哪个就补哪个系统库。fresh 的 TUI 闭包只命中 onig_sys（sqlite 见上段）。
- **反例（不要盲目加 pkg-config）**：`lzma-sys`、`ring`、`bzip2-sys`、`libz-sys`
  不在强制列表里，它们用 standard-packages 提供的 cc 编译 bundled C/asm，无需
  pkg-config 或系统库。先查列表再决定，别给每个含 C 的 crate 都塞 pkg-config。

### cargo 包 dlopen 的系统库要手动补 RUNPATH（只加 input 不够）

cargo-build-system 产物的 RUNPATH 由 **rustc 链接时按实际链接的 native 库**嵌入，
只覆盖 NEEDED 里的库所在目录；**运行时 dlopen 的库不在 NEEDED，其 /lib 不会自动
上 RUNPATH**。把库加进 inputs 只让它进闭包，dlopen 仍找不到（fresh-editor 实证：
加了 gpm input 后 `patchelf --print-rpath` 仍只有 xz/oniguruma/gcc/glibc，无 gpm）。
对比 binary-build-system 的 `#:patchelf-plan` 是把**全部 inputs 的 /lib** 塞进
RPATH，所以 -bin 包没有这个问题——源码包要自己补。

- **修复**：install 后加 phase，用 patchelf 把 `<lib>/lib` 追加到现有 RUNPATH
  （上游 idiom 见 `gnu/packages/maths.scm:3363` fix-rpath）：

  ```scheme
  (add-after 'install 'add-gpm-runpath
    (lambda* (#:key inputs outputs #:allow-other-keys)
      (use-modules (ice-9 popen) (ice-9 rdelim))   ; 必须！见下条
      (let* ((out (assoc-ref outputs "out"))
             (gpm (assoc-ref inputs "gpm"))
             (bin (string-append out "/bin/fresh"))
             (pipe (open-pipe* OPEN_READ "patchelf" "--print-rpath" bin))
             (rpath (read-line pipe)))
        (close-pipe pipe)
        (invoke "patchelf" "--set-rpath"
                (string-append rpath ":" gpm "/lib") bin))))
  ;; native-inputs 加 patchelf（(gnu packages elf) 导出）
  ```

- **`open-pipe*`/`read-line` 在 build phase 里默认 unbound**：构建环境只加载
  `(guix build utils)` 等，不含 `(ice-9 popen)`/`(ice-9 rdelim)`。phase lambda
  里必须显式 `(use-modules (ice-9 popen) (ice-9 rdelim))`，否则报
  `unbound-variable ... (open-pipe*)` 整个 phase 失败（fresh-editor 首构实证；
  上游 maths.scm 的 gexp 同样显式 import 这两个模块）。`invoke` 来自
  guix build utils，无需 import。

- **不要用 gremlin `set-file-runpath` 追加**：它假设字符串表无 padding，只能
  缩短/等长，加长必抛 `&runpath-too-long-error`（`guix/build/gremlin.scm:446`）。
  patchelf 能重写 ELF 扩段，才是加 RUNPATH 的正解。
- **不要图省事用 wrap-program 设 LD_LIBRARY_PATH**：若程序用
  `std::env::current_exe()` 重新拉起自身（fresh 的 daemon `server/daemon/unix.rs:78`、
  集成终端 `app/terminal.rs:141`），wrapper 会让 current_exe 解析到 `.real`，
  子进程绕过 wrapper 环境 → dlopen 又失败。这类程序必须走 patchelf RUNPATH，
  与 -bin 包保持一致（fresh-editor 实证）。
- 验证：`patchelf --print-rpath` 命中该 lib；store 产物只读，手动复现要先
  `cp` 到临时目录并 `chmod u+w` 再 patchelf（直接 patchelf store 文件报
  `open: Permission denied`）。


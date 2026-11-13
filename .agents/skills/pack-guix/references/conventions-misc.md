# jeans 通道打包约定 — 其他（trivial/git-fetch/构建阶段/字体/服务/运行时验证）

<!-- 2026-11-12 由 references/jeans-conventions.md 按主题拆分；内容为整段原样搬迁 -->

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

## 括号失衡的两类症状（定位方向相反）

改完 `.scm` 后加载报错时，先按症状选定位方向，不要肉眼重排全文：

- **`missing field initializers`（缺字段初始化器）**：某个 package 提前闭合——通常是字段块里少了开括号/多了闭括号，解析器认为 package 到此结束，后面的字段成了裸表达式。此时全文括号净差往往恰好为 0（一开一闭成对错位），净差扫描查不出来。
- **`unexpected end of input`（输入意外结束）**：整体未闭合——某处少了闭括号，解析器读到 EOF 还在等。净差扫描对这类有效。

两类都优先用 `guix build -L modules <pkg> --dry-run` 的报错定位；guile 能 `use-modules` 加载不代表语法正确（可能命中 `.go` cache），dry-run 报错才是真相。

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


## 运行时验证的环境限制（TUI / headless）

- TUI 入口在无控制终端的环境下启动，报 `os error 6`（无 TTY）是**预期行为**，不代表包损坏。headless 会话只做静态验证（ELF interpreter/RPATH、wrapper `bash -n`、文件布局、desktop Exec），并在交接报告里标注"TUI 未真实复现"。
- CLI 入口不受此限，必须真实运行（`--version` / `--help`）。
- 验证脚本注意：Guix 没有 `/bin/bash`，shebang 写 `#!/bin/bash` 的脚本会秒退——在 `guix shell` 里显式用 bash 调起，或先 patch shebang；工具重写文件会重置执行位，跑之前 `chmod +x`。
- 在 tmux 里做 TUI 验证时只 kill 自己创建的会话（`tmux kill-session -t <自己的>`），不要 `kill-server`。

### 外来 Emacs 变体需要自带 Guix autoloads 集成

GNU Emacs 的 site-start.el/guix-emacs.el（包 autoloads 链 + TREE_SITTER_GRAMMAR_PATH 接线）由 emacs 包自带，且住在 emacs 包**自身 profile**里，不出现在 EMACSLOADPATH 根目录——因此没有编译期 Guix site-lisp 的外来 Emacs 实现（如 neomacs-bin）会缺失整条链：所有 `*-autoloads.el` 不加载，用户配置引用 autoloads 期符号（如 `telega-prefix-map`）启动即崩。修法（见 emacs-xyz.scm 的 neomacs-bin）：这类实现的"运行时 lisp 目录"恒在其默认 load-path 上（neomacs 是 `share/neomacs/lisp`），且它像 GNU Emacs 一样在 early-init 前从 load-path 加载 site-run-file——把复刻 Guix 官方版的 `site-start.el` + vendor 的 `guix-emacs.el` 装进该目录即可；GNU Emacs 不受影响（该目录不会进入其 load-path）。顺带可在 site-start 里用 `unless-boundp` defvar 修上游漏定义的变量（eln 那类），上游修复后守卫自动 no-op。

配套两个 Guix 通用坑（同次实测）：

- `local-file` 的相对路径在此 channel 环境按 **CWD** 解析（编译期源目录信息丢失），channel 内文件用 `(local-file (search-path %load-path "jeans/..."))` 定位（misans 模式，见 fonts.scm）。
- `install-file` 保留 store item 的完整 basename（**含哈希前缀**）；目标文件名必须精确时（如 site-run-file 按名字原样查找）改用 `copy-file` 显式指定目标名。


### 1.4 copy-build-system 的 install-license-files 陷阱

`copy-build-system` 继承自 `gnu-build-system` 的 `install-license-files` 阶段，
该阶段用 `%license-file-regexp` 搜索 license 文件。AppImage 等二进制包通常没有
标准的 license 文件，导致 `match-error: no matching pattern`。

**修复：** 在 `#:phases` 中加 `(delete 'install-license-files)`。

```scheme
#:phases
#~(modify-phases %standard-phases
    (delete 'install-license-files)   ;; AppImage 包无标准 license 文件
    ...)
```

此问题在 git-fetch 沙箱修复前被掩盖——checkout 失败比 license 阶段更早触发。

### 1.5 版本升级时 patch 兼容性

`emacs-ghostel` 的 `%ghostel-patches` 中有一项 `ghostel.el.patch` 仅修改 docstring
示例（`/bin/bash` → `bash`），功能性修复已在 `substitute*` 阶段单独完成。
当 upstream 0.38.0 变更了该行上下文后，patch 无法应用。

**通用规则：** 每当 auto-update 脚本升级了某包的版本，其**所有 patch**
都可能因 upstream 变更而失效。诊断时优先检查 build log 中的 `Hunk #N FAILED`。
若 patch 只是 cosmetic（docstring 修正、注释调整），直接移除比重新生成更稳妥。

**幽灵陷阱（2026-07-30 补充）：** 当升级涉及**内联 vendored 依赖**（如 ghostel 通过 `./deps/ghostty/` 内联 ghostty 源码构建 libghostty-vt），vendored 依赖本身的 `build.zig` / `build.zig.zon` 可能也随上游 commit 更新，导致 zig 版本要求、API 调用签名全部变化。这类失败的特征不是 `Hunk #N FAILED`，而是 zig 编译错误（`error: no field named 'linkLibC'` / `error: member function expected 3 argument(s), found 2`）。此时**不是 patch 兼容性**问题，而是整个内联依赖与新的 zig 版本不兼容。

### 1.6 url-fetch origin 在 build phase 中是 tarball，不是目录

**关键陷阱（本会话发现）：** 当辅助 origin（private source 定义，如
`%ghostel-ghostty-source`）从 `git-fetch` 转为 `url-fetch` 后，其 `#$origin` gexp
展开为**文件路径（tarball）**，而非目录。Guix 对 url-fetch（即使带 patches 的）
会在 store 中存储 repack 后的 `.tar.xz` 压缩包。

如果 build phase 中对这类 origin 使用 `copy-recursively`，会将 tarball 文件直接
复制到目标位置，而非解压提取——导致后续工具（如 zig、make）找不到预期的文件。

**错误症状：**

```
error: unable to load package manifest '...deps/ghostty/build.zig.zon': NotDir
```

**正确做法：** 用 `mkdir-p` + `tar xf --strip-components=1` 替代 `copy-recursively`：

```scheme
;; ❌ 错误：url-fetch origin = tarball 文件，copy-recursively 只复制文件
(copy-recursively #$%ghostel-ghostty-source
                  (string-append deps "/ghostty")
                  #:log (%make-void-port "w"))

;; ✅ 正确：先创建目录，再解压 tarball（--strip-components=1 剥离顶层目录）
(let ((ghostty-dir (string-append deps "/ghostty")))
  (mkdir-p ghostty-dir)
  (invoke "tar" "xf" #$%ghostel-ghostty-source
          "-C" ghostty-dir "--strip-components=1"))
```

**适用范围：** 所有在 build phase 中通过 `#$origin` 引用辅助源的场景。
主包 source 不受此影响——`gnu-build-system` 的 `unpack` 阶段自动处理提取。

**检测方法：** 区别 `git-fetch` 和 `url-fetch` 的 store 输出类型：

- `git-fetch` → 目录（checkout） → `copy-recursively` 正确
- `url-fetch` → 文件（tarball） → 必须 `tar xf` 解压

- `update_versions.py` 的 `apply_pending_updates()` 只修改 `version` 和
  `base32`,**不会**改动 `method` 字段。因此将 `method git-fetch` 改为
  `method url-fetch` 后,auto-update 脚本会保留 url-fetch 并正确走 url-fetch
  更新路径(`construct_download_url_from_uri` + `get_base32_from_guix_download`)。


## 2. Adding/upgrading a package

Standard flow lives in `AGENTS.md` (see `blue build`, `blue upgrade`, `blue import-crate`). Recurring pitfalls:

- **`rust-crates.scm` is auto-managed.** Never edit by hand. `guix import crate -f ./Cargo.lock <pkg>` rewrites it whole (the package name is required, and `-f/--lockfile` must be attached with `=` for the long form). Manual edits cause `cargo build --offline` failures later.
- **`-bin` suffix packages use one of three templates** depending on artifact shape (AppImage / archive / bare ELF). Pattern details + the "bare ELF still links libgcc_s via dlopen'd .node addon" trap are in AGENTS.md "预编译二进制包" — re-read that section before touching a -bin package.
- **Rust packages with `option_env!()` compile-time config** (e.g. nix-ld's `DEFAULT_NIX_LD`) bake NixOS paths into the binary if the env var isn't set at build time, causing runtime `Posix(2)`/ENOENT panics. Diagnosis recipe + fix pattern + cargo-build-system input-label mechanics (`"glibc"` vs `"libc"` dual-label gotcha) + two-step verification when guix build is network-blocked: `references/rust-packaging-patterns.md`.
- **Electron 预编译 `.deb`（data.tar.zst 形态）四个坑**：
  (a) 新上游 deb 的 data 压缩是 zstd 不是 xz——native-inputs 加 `zstd`，unpack 用 `tar xf data.tar.zst`；
  (b) Guix 的 patchelf 0.18 **没有 `--prepend-rpath`**，且 native addon（sharp 等 `.node`）自带指向 bundle 内依赖的 `$ORIGIN` 相对 RPATH，直接 `--set-rpath` 会毁掉它——先 `patchelf --print-rpath` 读旧值，拼 `ours:old` 再 `--set-rpath`；
  (c) deb 内混有跨平台预编译产物（node-pty `prebuilds/darwin-*` 是 Mach-O），patchelf 前按 ELF magic（`\x7fELF`，`call-with-input-file` + `get-bytevector-n`）过滤，否则 patchelf 报 `not an ELF executable` 中断构建；
  (d) 构建 rpath 列表用 `(append (list lib) (map ...) (list ...))`——`(cons* lib (map ...))` 会把 map 结果嵌成单个元素，构建期 `string-append` 报 wrong-type。
- **版本 bump 引入新 hard NEEDED 库 → RPATH 没跟上，构建绿但运行时"打不开"**：上游新版 .deb 可能在 readelf NEEDED 里新增硬条目（neomacs 0.0.19 起链上 `libdbus-1.so.3`，来自 GStreamer 的 GLib 事件循环）。`guix build` 只验证构建阶段能跑完，不验证二进制启动时能否解析全部 NEEDED；`-bin` 包普遍还设了 `#:validate-runpath? #f`，连仅有的 runpath 自查也关了——缺口一路漏到用户手上。症状固定为 `<profile>/bin/<exe>: error while loading shared libraries: libX.so.N: cannot open shared object file`。
  诊断三步：① `readelf -d <store>/bin/<exe> | grep NEEDED` 列出全部硬依赖；② `guix shell patchelf -- patchelf --print-rpath <exe>` 读现有 RPATH 逐条比对，找出未覆盖项；③ 对上一个版本的 store item 做同一比对，diff 出来的就是本次新增——那正是要补的 input。
  修复三处：`inputs` 按字母序加 `("dbus" ,dbus)`、RPATH 列表插 `(string-append (assoc-ref inputs "dbus") "/lib")`、文件头的 readelf NEEDED 注释同步。缺第三处会让下次诊断重新读一遍二进制。
  验证必须 exec **新 store 产物本身**（`<new-store>/bin/<exe> --version`，每个入口都试），或用临时 profile 走一遍软链层：`guix build -L modules --manifest=<(echo '(specifications->manifest (list "<pkg>"))')`。`ldd` 和用户当前 profile 都不算数——它们反映的是修复前的状态。修完还要提醒用户 `blue home` 部署，store 里构建成功 ≠ 用户机器上生效。


## 5. Adding a new package file — don't forget `%public-modules`

When you create a new modules/jeans/packages/<file>.scm, you may also need to
register it in `modules/jeans.scm` so that `(jeans)` re-exports it:

```scheme
(define %public-modules
  '(...
    (jeans packages <file>)
    ...))
```

**Symptom of omission:** `(jeans)` users can't see the new packages. `guix lint
-L modules modules/jeans/packages/<file>.scm` prints `未知软件包`, even though
`guix repl -L modules` can resolve the symbols correctly — lint runs each file
in isolation, so its result is misleading when the only problem is missing
re-export. The real test is the REPL:

```bash
guix repl -L modules -e '(use-modules (jeans packages <file>))
(format #t "~a~%" (module-variable (resolve-module (quote (jeans packages <file>)))
         (quote <symbol>)))'
```

If that exits 0 and prints a variable, the package is loadable and the
re-export is the only missing piece. **After fixing the re-export, regenerate
`docs/packages.md` with `blue gen-docs` and include it in the same commit.**

### 5.1 `guix lint` "未知软件包" （实为 re-export 缺失的间接表现）

`guix lint -c <module-file>` 在沙箱内逐文件求值。若 `%public-modules` 漏了
该文件，lint 会报 `未知软件包`，但：

- `guix repl -L modules` 加载 `(jeans)` 后可直接 `(module-variable
(resolve-module '(jeans packages <file>)) '<pkg>)` —— 能 resolve 说明定义
  本身正确，只是顶层 re-export 链断了。
- 核实顺序：先 `rg <pkg-name> modules/jeans/packages/<file>.scm` 确认
  `define-public` 存在，再查 `modules/jeans.scm` 的 `%public-modules` 里有
  没有该模块条目。

**不要**为了"修 lint"去动 package 定义本身；应该补 `%public-modules`。

### 5.2 `search-path %load-path` 的相对路径 warning

`modules/jeans/patches/emacs-ghostel-*.patch` 等文件通过
`(search-path %load-path "jeans/patches/<name>")` 引用时，`guix repl -L
modules` 会输出：

```
正在将"modules/jeans/patches/..."解析为相对于当前目录
```

这是 `search-path` 在 REPL 非标准 cwd 下的已知 carry-over warning；不影响
解析结果。`guix lint -L modules` 在同一上下文中也会转发这 6 条。属于
upstream posix 路径检查行为，**不是包定义错误**，可以在审阅时忽略。


## 4.4 Merged from `guix/jeans-channel-ops` (2026-08) — CI 补充要点
- cron 实际 05:12-05:29 UTC 触发（非 02:00），06:00 前勿判调度失效；运行号按 workflow 分开计数；`gh` 绝对路径 `~/.local/state/nix/profile/bin/gh`，403 回退 `x-access-token` Bearer。
- CI 签名速查：`exit 8+502 Bad Gateway`→重试 Install Guix；`exit 128+403 codeberg`→FORGEJO_TOKEN/IP；`report.json 无文件+<30s`→死于 Install Guix 前；详表见原 ci-failure-signatures。
- `guix refresh` 列表含 1 个 unknown package 即整批 exit 1 零更新；字母版本号（如 1.21b vs 1.21.10b）需核 `gh api .../releases`；`/releases/latest 404` 仅意味全为 prerelease。
- 回填验证：`NONGUIX_DIR` 扫 `~/.cache/guix/checkouts` + `GUIX_EXTRA_LOAD_PATH` + `guix build -L modules -L $NONGUIX_DIR`；-bin 包验 store 内 bin/.desktop/ELF 内容。
## Appendix — packaging pitfalls (agenote 202608, merged)
- neomacs: wrap-program → .neomacs-real 无限循环; 用 libexec + exec -a 手写 wrapper (20260818-201651). home-neomacs-service-type 的 wrapper 只是个 guile program：设好 search paths 后 exec profile/bin/<argv[0] basename>，RPATH 在 ELF 自己身上——所以 RPATH 类修复只需重打 neomacs-bin，再由用户跑 blue home 部署（wrapper 与 profile 会跟着重建），不要动 home 服务定义。
- bun --compile: patchelf/ld-linux wrapper 破坏 .bun section / /proc/self/exe; 用 nix-ld + NIX_LD_LIBRARY_PATH (20260818-201643).
- ffmpeg: Guix 无 7.x 需私有 helper pin 7.1.5 (20260818-201800); waywallen Qt6 需 libglvnd + 4 Quick 模块已知缺失; wine64 11.0 stub/regedit/wineserver 缺陷链见 agenote 20260818-201633.


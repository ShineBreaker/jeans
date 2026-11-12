# jeans 通道打包约定 — 2026-11-12 全通道审查实证（issue #74–#95）

<!-- 2026-11-12 由 references/jeans-conventions.md 按主题拆分；内容为整段原样搬迁 -->

## 2026-11-12 全通道审查实证（issue #74–#95）

对全部公开包做了一轮对照审查，以下教训均有实证，按主题归纳。

### `source`/`origin` 不是 thunk：架构分支在模块加载期就定死

`origin` 的 `uri`/`sha256` 字段在**模块加载时**求值——`(match (or (%current-system) (%current-target-system)) ...)` 写在 origin 里，之后 `guix build --system=aarch64-linux` 仍使用当初加载时选中的那份 tarball 与 hash。`supported-systems` 同时声明多架构不会让它变成条件源，只会误导（gh 实证：x86_64 上为 aarch64 构建会拿 amd64 包，补全阶段还执行那份二进制）。正解：URL 与 hash 钉到单一上游资产，`supported-systems` 收窄到它真实支持的架构。

连带规则：**上游只发 amd64 资产的预编译包必须写 `(supported-systems '("x86_64-linux"))`**。默认支持列表会让 aarch64 装机者原样装上 amd64 二进制（opencode-desktop-bin、lem-next-bin、gh 三处实证）。

### RPATH / wrapper / desktop 文件

- **RPATH 只放库目录**。`gtk+/share` 之类数据目录进 RPATH 毫无意义（zen-browser-bin 实证）；share 树交给 wrapper 的 `XDG_DATA_DIRS`。
- **改写 `.desktop` 的 `Exec=` 时保留字段代码**（`%F`/`%U`/`%f`）。把 `Exec=run-lem %F` 替换成绝对路径时 `%F` 会一起被吃掉，文件管理器打开文件传不进路径（lem-next-bin 实证）。源码包与 -bin 包对照检查一次，别只改一边。
- **`close-pipe` 必须查退出码**：`open-input-pipe` 跑的生成器失败时，stdout 里的半截内容照样被装成产物（opentabletdriver-udev-rules 的 `generate-rules.sh` 缺 jq 时 set -eu 退出 1，构建照样"成功"装了截断的规则）。`(close-pipe p)` 的返回值过 `(status:exit-val ...)` 判定，非零即 `error`。

### modify-phases / inputs / source 三处语义陷阱

- **同名 `(replace 'x)` 只保留最后一个**：`modify-phases` 对同一阶段的多次 replace，前面的静默丢弃——不是警告不是错误，是永远不会执行的死代码（wuffs 实证：两段 `(replace 'check)` 中第一段编译已被 `delete-vendored-snapshot` 删掉的文件还跑 `wuffs test`，真执行反而炸）。清理旧阶段替换时全文件搜一遍同名 key。
- **builder 把 input 复制进自己 outputs 的包用 `inputs` 不用 `propagated-inputs`**：同一批文件随 propagated input 进 profile 一次、又随自身 output 进一次，`guix package` 拒收碰撞（wuffs 实证）。propagated 只用于"运行期必须可见、且不复制进自身"的依赖。
- **生成器/聚合包 `(source #f)` 是合法且正确的**：builder 只用 inputs 时，为它下载一个从不解包的归档只会带来无谓的 hash churn（dear-bindings-imgui 实证：origin 拉 upstream zip 而 builder 只对 imgui.h 跑生成器，zip 一变构建就死于无用 hash）。HASH 形参保留则调用点不用改。

### `inherit` 上游的包在上游升版后至少要真构建一次

`inherit` 让包自动跟上游版本走，但 **builder 对上游产物布局的假设不会自动跟**。librewolf-nongnu 实证：Firefox ~159 把 `BrowserGlue.sys.mjs` 从 `browser/omni.ja` 的 `modules/` 挪进根 `omni.ja` 的 `moz-src/browser/components/`（Mozilla 还在 moz-src 迁移中，`modules/AppConstants.sys.mjs` 这类 toolkit 文件仍在旧路径）——模块加载、lint、license 全过，只有真构建才在 patch 阶段炸出 FileNotFoundError。对上游 bundle（omni.ja、asar、resources.pak）做文件级 patch 的脚本，目标路径写成**存在性检查的候选列表**（先 moz-src 路径，回退旧 modules 路径），都找不到就显式 `sys.exit`，别让 `read_text()` 的裸 FileNotFoundError 当错误报告。

### 其他零碎实证

- **公开包与上游同名**会报 `ambiguous package specification`（font-nerd-symbols 实证：上游同版本源码包已在，本通道的 zipbomb 预编译版是纯重复，直接删）。上游已提供同名包时，要么改名区分、要么不打包。
- `(guix build-system python)` 再导出的 `pypi-uri` 已废弃（加载即警告）；用 `(guix build-system pyproject)` 里的同名绑定，原模块 `#:hide` 掉（python-xyz.scm 实证）。
- **`guix lint` 不带 `--checkers` 会跑联网 checker**（home-page、archival 等）且可能长挂；批量审查一律传显式离线 checker 列表（pack-guix SKILL.md 那份），网络型 finding 单独重试。
- **`guix repl` 探包别忘 `(guix licenses)`**：`license-name`/`service-type-name` 等不在 `(guix packages)` 的导出里；私有包 `specification->package` 查不到要用 `@@` 或模块变量。

### `-bin` 包换源时先查 glibc 版本底线

候选预编译二进制的可用性由 `GLIBC_*` 符号版本决定，与版本号无关：`ld.so --list <elf>` 或 `readelf -V` 看 `Version needs`。2026-11-12 实证（ghostty-bin 选源）：pkgforge AppImage、Arch、COPR 构建都需 `GLIBC_2.43`，通道 glibc 只有 2.41——patchelf 能修 RPATH 但修不了符号版本，这类包构建会过、`--version` 一跑就炸。conda-forge 面向老 glibc（ghostty 只需 2.34）常是唯一 ABI 兼容的现成渠道；代价是文件名带 `h<hash>_<build>` 后缀无法由版本推导 URI，updater 接管不了（在 origin 注释里写明）。另：pkgforge 的新式 uruntime AppImage 内嵌的是 **DwarFS**（不是 squashfs），`7z`/`unsquashfs` 都解不开；要解用 `dwarfsextract -i <img> -o <已存在目录>`，`--image-offset` 默认 auto 自动定位镜像。

### 预编译包大版本升级时核对 ELF/资源文件名

`-bin` 包的 install/wrap/patchelf 阶段硬编码了上游产物里的文件名（主 ELF、图标名、desktop 文件名）。上游大版本可以静默改名：opencode-desktop 1.19→2.x 把主 ELF 从 `ai.opencode.desktop` 改成 `ai.opencode`、图标从 `ai.opencode.desktop.png` 改成 `ai.opencode.png`——`wrap-electron` 报 `canonicalize-path: No such file or directory`。升大版本前 `ar x <deb>` / 解包归档核对文件名清单，把 `#:program`、symlink 目标、`find-files` 正则一起改；desktop 文件的 `Exec=` 行是最权威的上游命名来源。

### 审查 issue 的补丁消费法（meta）

审查类 issue 正文里的 ```` ```diff ```` 围栏，其内部可能出现 ` ``` ` 行（文档补丁改的正是 markdown 代码块）：提取时按"下一行恰为 ```"切分，不能用"下一个 ``` 出现位置"（非贪婪正则会把补丁截断在第一处内嵌围栏，issue #76 实证）。issue 里的 hunk 行数声明也可能与实际不符（渲染吃掉尾部上下文行）：逐 patch `git apply --check` 再应用；计数差一行时按目标文件实际行数修正 `@@ -a,b +c,d @@` 头（issue #75、#94 实证）。

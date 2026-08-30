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
# "no updater" = properties 配置有误（检查 upstream-name 是否匹配文件名前缀），
#               或命中 github updater 静默盲区（见下方「Python updater 兜底」的盲区清单）
```

### Python updater 兜底（guix refresh 力不能及的包）

少数包 guix refresh 无法处理，仍由 `update_versions.py` + `config.json` 兜底：

- **非 GitHub 源**：CDN（zcode）、gitee（amber-pm）、无 version URL（font-misans）
- **npm scoped tag**：kimi-code-bin（`@scope/name@version` 模式）
- **refresh URL 重建失败的边缘 case**：reasonix-desktop-bin（`desktop-v` 前缀 + 文件名不标准）
- 这些包的 tag_prefix / pre-release 规则保留在 `config.json`，不写入 properties。

github updater 还有几个静默盲区（不报错、就是不识别），命中任一条就直接走 Python 兜底，不要在 properties 上浪费时间：

- **非数字开头的 tag 系列**：`nightly-20260831` 这类 tag 不被当作版本（lem-next-bin，由 SPECIAL_UPDATERS 的 nightly 处理器接管，正则锁定 `nightly-YYYYMMDD-HHMM` 日期 tag）。
- **资产前缀大小写不匹配**：上游 tag/资产用大写 `V0.3.7`（inso-bin），refresh 的资产名匹配区分大小写。
- **只发 prerelease 的 repo**：`/releases/latest` 恒 404（inso-bin），必须进 `check_pre_release` 列表才有版本可查；即使 guix refresh 侧能识别， prerelease-only 的上游也常需要 Python 侧配合。

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

预编译包的常见形态各不相同，按小节对号入座；先用 `patchelf --print-interpreter` 探测 linkage，再选处理路线。

### AppImage 包

**默认用 `7z x` 静态解压，永远不要执行 AppImage 自身的 `--appimage-extract`。** 原因：自解压需要执行构建树里的 AppImage runtime，而 jeans 的自动更新 CI（GitHub runner）不允许执行构建树中的任何可执行文件——AppImage 自解压、autotools `./configure` 乃至 chmod 755 的 shell 脚本全部 `execvp: Permission denied` （issue #32）。`7z` 只解析容器格式（ELF runtime + squashfs 段），全程只运行 store 里的程序，本地与 CI 行为一致。`p7zip` 加入 `native-inputs`。

`7z x` 把内容直接解到构建目录顶层（`usr/`、`*.desktop`、图标等），**没有** `squashfs-root/` 前缀——那是自解压模式才有的产物。`#:install-plan` 按顶层路径写：

```scheme
(native-inputs (list p7zip patchelf))
#:install-plan
#~'(("usr/" "lib/<pkg>/"))
```

**install-plan 陷阱**：AppImage 根部的 `.desktop` 和图标文件几乎都是指向 `usr/share/...` 的**相对符号链接**，按链接路径安装会得到悬空链接（waywallen-bin 实证）。需要这些文件时引用 `usr/` 内的真实文件，而非根部链接。

解压后对所有 ELF 二进制和 `.so` 执行 `patchelf`（遍历全部，不只主入口）。

参照包：

- `modules/jeans/packages/games.scm` 的 `osu-lazer-bin` —— 最简参照，7z 解包 + patchelf + wrap-program，该模式已被自动更新 CI 构建验证多次。
- `modules/jeans/packages/desktop.scm` 的 `waywallen-bin` —— 复杂参照，Qt6 bundle 保留 AppRun 布局、QT_PLUGIN_PATH 补插件、插件发现桥接。

### tar.gz / .deb 等归档包

`gnu-build-system`，删除 `configure`/`build` 阶段，自定义 `install`。解包前先 `tar tzf` / `unzip -l` 列出顶层布局——多数归档有 `<name>-<version>/` 顶层目录，但有的直接散装在根部（ai-usagebar-bin 的 tar.gz、inso-bin 的 zip），install-plan 按实际布局写。

### 裸 ELF 可执行文件

`gnu-build-system`，`replace 'unpack` 阶段用 `copy-file` 直接复制原始二进制。安装到 `lib/<pkg>/`，然后从 `bin/` 创建 ld-linux wrapper。**裸 ELF 的陷阱**：即使 `readelf -d` 显示 NEEDED 为空，运行时仍可能通过 `dlopen` 加载 native addon（如 oh-my-pi 的 `pi_natives.linux-x64-modern.node`）。这些 addon 可能依赖 `libgcc_s.so.1`，因此 inputs 中需要包含 gcc 的 `lib` 子输出。

完整模板见 `references/package-template.scm`。

### 自定位二进制：patchelf 和 wrapper 都不可用

判断标准：二进制在运行时用 `/proc/self/exe` 或自身文件名定位资源、甚至解包自己。任何改变 ELF 布局或文件名的处理都会破坏这条假设：

- **bun --compile 产物**：`patchelf` 写 interpreter/RPATH 会平移 ELF 内的 `.bun` 段，自解包随之损坏；Guix ld-linux wrapper 则让 `/proc/self/exe` 指向 wrapper 自身，触发循环解包（打包探索记录，仓库暂无此类包实例；nix-ld 侧基础设施已就位）。可行方案：**原样安装、不 patch**，依赖系统级 nix-ld 提供带回退搜索路径的 `/lib/ld-linux`（`jeans/services/nix-ld.scm` 的 `nix-ld-service-type`），运行库通过 `NIX_LD_LIBRARY_PATH` 提供。
- **wrap-program 会把真实二进制改名为 `.<name>-real`**：neomacs 在该命名下死循环。解法：真实 ELF 以本名安装到 `libexec/<pkg>/`，`bin/` 下手写 thin shell wrapper 启动它；exe 同目录数据（`neomacs.pdump`）和上游按 exe 路径探测的 `../share/<name>` 随之回正，仍不够时用上游提供的环境变量（如 `NEOMACS_RUNTIME_ROOT`）显式指路。完整分析见 `emacs-xyz.scm` 的 `neomacs-bin` 包前注释。
- **反例（能容忍 `.real` 命名）**：Tauri 的 resource/sidecar 解析以真实 exe 路径为基准，`wrap-program` 不影响（motrix-next-bin，见下方 Tauri 小节）。动手前先读上游定位自身资源的代码，不要按包类型猜。

### dlopen / CFFI 写死的动态加载

`readelf -d` 的 NEEDED 列表只是静态真相，两类运行时加载会让"NEEDED 为空 = 无依赖"的判断失效：

- **裸 soname dlopen**：加载探测列表的第一项常是不带路径的裸 soname（fresh-editor-bin 的控制台鼠标支持 dlopen `libgpm.so.2`，`editor.scm` 包前注释）。RUNPATH 即可满足：把提供该库的包加进 inputs 并纳入 library path，不需要 symlink。
- **写死上游发行版的 soname**：CFFI/FFI 的候选列表按打包者的发行版写死（lem-next 的 CFFI 写死 Ubuntu 的 `libncursesw.so.6.3`、neomacs 的 `libtinfo.so.6` 同理，而 Guix 的 ncurses 只提供 `libncursesw.so.6`）。解法：安装阶段在二进制同目录 `symlink` 一个别名指向 Guix 的实际库文件（`editor.scm` 的 `lem-next-bin`、`emacs-xyz.scm` 的 `neomacs-bin` 均有实例），并把该目录放进 RUNPATH。
- 断言"Guix 下无法加载"之前，先读上游的加载源码找探测顺序——多数 FFI 按列表依次尝试，前面失败会落到可满足的后续项。

### 所有预编译包的通用规则

- `patchelf` 用于设置 ELF 解释器（`ld-linux`）和 RPATH（指向 Guix store 路径）。
- 先探测 linkage 再动手：`patchelf --print-interpreter` 非零退出（找不到 `.interp` 段）说明是静态二进制（static-pie），直接复制安装即可，不做任何 interpreter/RPATH 处理。`agent.scm` 的 crush 在构建时探测、只在 dynamic 时 `--set-interpreter`；CodeWhale 已知 fully static，直接安装、连 patchelf 都不进 native-inputs。
- 设置 `#:tests? #f`（无源码 → 无测试）。
- 设置 `#:validate-runpath? #f`（预编译二进制无法通过 Guix 的 runpath 校验）。
- 设置 `#:strip-binaries? #f`（预编译二进制不支持 Guix 的 strip，会导致损坏）。
- 二进制安装到 `lib/<pkg>/`，然后从 `bin/` 创建符号链接，使 patchelf 能找到同目录的 `.so` 文件。
- 自动更新 CI（guix refresh 主力 + Python 兜底）会对本次更新的所有包运行构建测试；预编译包同样需要验证解包、patchelf 和 wrapper 阶段。

### Qt 预编译 bundle 缺插件

自包含 Qt bundle（AppImage 等）常缺个别 Qt 插件。典型案例：waywallen 的 AppImage 不含 `iconengines/libqsvgicon.so`，所有主题 SVG 图标渲染为空白。补法：把 Guix 对应 qt 包的插件目录（如 `qtsvg` 的 `lib/qt6/plugins`）**追加**到 wrapper 的 `QT_PLUGIN_PATH`（bundle 自带目录在前）。前提：wrapper 的 `LD_LIBRARY_PATH` 让 bundle 的 Qt 库排在 Guix Qt 之前，插件于是链接回 bundle 的 Qt，避免两套 Qt ABI 混用。

### 预编译包需要的 ffmpeg 版本 Guix 没有

Guix 只有 ffmpeg 8.x/6.x/5.x/4.x，没有 7.x。预编译包链接 7.x sonames（libavformat.so.61、libavcodec.so.61、libavutil.so.59、libswscale.so.8、libswresample.so.5）时，在同一包文件内写**私有 helper**（`define` 而非 `define-public`）：`(inherit ffmpeg)` 改 name/version/source，只保留 shared 输出，inputs 收缩到实际需要的（如仅 zlib）。**保留继承来的自定义 `configure` phase**——ffmpeg 用手写的 configure，不接受 gnu-build-system 默认 phase 注入的 `CONFIG_SHELL`/`--build=` 参数，替换掉就构建失败。参照 `desktop.scm` 的 `ffmpeg-7`（open-wallpaper-engine-bin 的依赖）。

### 插件宿主不读 XDG_DATA_DIRS

插件型宿主（daemon/编辑器）常只扫私有目录（如 `<exec>/../share/<name>` 和 `$XDG_DATA_HOME/<name>`），不读 `XDG_DATA_DIRS`——而 Guix profile 恰恰通过 `XDG_DATA_DIRS` 暴露 `share/` 树。桥接法：在 wrapper 里遍历 `XDG_DATA_DIRS`（shell 循环需临时 `IFS=:`），把含 `<name>/plugins/` 的目录去重后转成上游的插件 CLI 参数（如 `--plugin <dir>`）。使用前确认：flag 是否可重复、上游期望前缀目录还是插件目录本身。桥接后，插件包与宿主装进同一 profile 即可互相发现，无需用户手动 symlink。

### Electron 包的 Wayland/Ozone 参数

仓库有两个现成的 phase helper（`agent.scm`），新 Electron 包直接复用，不要各写各的：

- `prefer-electron-wayland-phase`：默认方案。`WAYLAND_DISPLAY` 存在且用户未自选平台时，向 wrapper 注入 `--ozone-platform=wayland --enable-features=UseOzonePlatform,WaylandWindowDecorations`。
- `prefer-electron-wayland-hint-phase`：**argv 解析严格的上游**（自己的 parser 对未知 flag 直接退出，Paseo 实证）不能用注入方案，改为 export Electron 原生的 `ELECTRON_OZONE_PLATFORM_HINT=wayland`。注入后启动即报未知 flag 的包换这个。

生效条件（读 case 逻辑）：hint-phase 只在用户未设置 `ELECTRON_OZONE_PLATFORM_HINT` 时 export；wayland-phase 在未设置（默认 auto）或显式设为 wayland 时注入，设为其他值（如 x11）则不注入。两者都不覆盖用户指向其他平台的选择。

### Tauri 应用（prebuilt .deb）

Tauri 预编译包的两个解析规则（motrix-next-bin 实证）：

- **resource_dir()** = `exe_dir/../lib/<identifier>/`：资源树（配置、数据库、bootstrap 数据）必须装到 `lib/<identifier>/`，缺任一数据文件会在启动时崩溃。
- **shell-plugin sidecar 按 `exe_dir` + basename 解析**（不在 resource dir）：替换 sidecar（如用独立 Guix 包替换 bundled 引擎）时，新二进制必须放在主 ELF 同目录。注意 `wrap-program` 会把真实二进制改名为 `.<name>-real`，`/proc/self/exe` 随之指向它——sidecar 与 resource 解析都以这个真实路径为基准。

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

## 运行时验证的环境限制（TUI / headless）

- TUI 入口在无控制终端的环境下启动，报 `os error 6`（无 TTY）是**预期行为**，不代表包损坏。headless 会话只做静态验证（ELF interpreter/RPATH、wrapper `bash -n`、文件布局、desktop Exec），并在交接报告里标注"TUI 未真实复现"。
- CLI 入口不受此限，必须真实运行（`--version` / `--help`）。
- 验证脚本注意：Guix 没有 `/bin/bash`，shebang 写 `#!/bin/bash` 的脚本会秒退——在 `guix shell` 里显式用 bash 调起，或先 patch shebang；工具重写文件会重置执行位，跑之前 `chmod +x`。
- 在 tmux 里做 TUI 验证时只 kill 自己创建的会话（`tmux kill-session -t <自己的>`），不要 `kill-server`。

# jeans 通道打包约定 — 命名与 input label

<!-- 2026-11-12 由 references/jeans-conventions.md 按主题拆分；内容为整段原样搬迁 -->

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

### 包名是本通道的记号，不渗入安装路径

包名上的通道记号目前有三种：`-bin` 表示「本通道分发的是预编译产物」，`-next` 表示「追上游 master 的版本线」（`lem-next-bin` 的上游只叫 Lem；`aria2-next-bin` 的 `-next` 却是上游 repo 名，不是我们的记号——判断依据是 `upstream-name`），`-se` 表示「跟踪我们自己的 fork 而非上游发布线」（判定见下文专节）。记号属于 Guix 包名命名空间，上游软件不知道、也不该知道它。**凡是上游会读取、探测、写回或显示给用户的路径与标识，一律用上游原名**；包名只用于 Guix 侧的标识（`name` 字段、`define-public` 符号、Scheme 变量名），不进入任何上游可读的字符串。

判断标准一句话：**这个字符串会被上游程序读到吗？** 会 → 上游名。只有 Guix/profile 自己读才可能是包名（目前仅 `share/doc/`）。

| 位置 | 正确 | 错误 |
| --- | --- | --- |
| 主程序 | `$out/bin/thinkrail` | `$out/bin/thinkrail-bin` |
| bundle / 私有库根 | `$out/lib/thinkrail`、`$out/libexec/magpie/magpie` | `$out/lib/thinkrail-bin`、`$out/libexec/magpie-bin/magpie` |
| 应用资源 | `share/neomacs`、`share/inso` | `share/neomacs-bin` |
| 桌面入口 | `share/applications/thinkrail.desktop`、`dev.zed.Zed.desktop` | `share/applications/thinkrail-bin.desktop` |
| 图标 | `share/icons/hicolor/<size>/apps/thinkrail.png`、`#:icon "thinkrail"` | `thinkrail-bin.png` |
| man / 补全 | `share/man/man8/opentabletdriver.8.gz`、`completions/crush`、`site-functions/_crush` | `_crush-bin` |
| wrapper 的 argv[0] | `exec -a inso` | `exec -a inso-bin` |
| 版本线记号 | `lem-next-bin` 装 `libexec/lem/`（上游叫 Lem） | `libexec/lem-next/` |
| 用户数据 / 配置目录 | 程序自己用 `~/.config/<app>`，保持原样 | substitute 成 `~/.config/<app>-bin` |

**唯一例外**：`share/doc/<package-name>/` 是 Guix 自己的文档元数据命名空间（与 `gnu/packages` 的 `share/doc/emacs-29.4` 同构），用包名。它不是给程序读的。

**机制上的坑在 build-system 默认值**，不在手写字符串。`binary-build-system` 的默认 install-plan 是 `lib/<package-name>/`，而 `#:package-name` 由 build-system 自动取 `(package-name this-package)`——漏传 `#:install-plan` 与 `#:app-dir` 的 `-bin` 包会**自动**装进 `lib/foo-bin/`，不需要任何人写错字。所以 `-bin` 包用 `binary-build-system` 时必须显式给 `#:install-plan` 或 `#:app-dir`。`electron-build-system` 强制 `#:app-dir`，同样写上游名（`lib/opencode-desktop`，不是 `lib/opencode-desktop-bin`）。`blue check-paths` 已覆盖这两条。

为什么必须这样：上游定位资源的方式全是「按自己的名字找」——`/proc/self/exe` 同目录、`share/<appname>`、argv[0] basename 分支、`.desktop` 的 desktop-id 与 `StartupWMClass`。目录名一换，构建期完全正常（文件都在），运行期静默失效：资源找不到、配置写进新目录（旧配置丢失）、启动器出现重复项或图标不匹配。这类故障不报错，只表现为「功能有点怪」。另外，包改名（上游改名，或某天去掉 `-bin`）会连带改掉用户数据目录，等于强制用户丢配置。

审查：

```bash
blue check-paths                              # 静态扫描，违规时退出码 1
find /gnu/store/<hash>-<pkg> -name '*-bin*'   # 安装后，应只命中 share/doc/
```

**实证**：thinkrail-bin 曾把 Electrobun bundle 装到 `lib/thinkrail-bin/`、桌面文件写成 `thinkrail-bin.desktop`；magpie-bin 曾装到 `libexec/magpie-bin/magpie`；lem-next-bin 曾装到 `libexec/lem-next/`。三者构建与运行都正常（wrapper 都传绝对路径），但违反本规则，2026-11-07 全仓审计时修正。

`blue check-paths` 的通道记号后缀集合写在 `scripts/check-package-paths.py` 的 `CHANNEL_SUFFIXES`；新增记号（`-nightly` 之类）时要同步，否则检查看不到。

### `-se`：跟踪我们自己的 fork

源码指向 `ShineBreaker/<repo>`、且该 repo 是**上游软件的 fork**（不是我们原创的项目），包名加 `-se`。它回答一个问题：装进 profile 之后，这个包和上游原版是不是同一条线。

| 情形 | 处置 | 实例 |
| --- | --- | --- |
| fork 上游软件，源码指向我们的仓库 | 加 `-se` | `distrobox-se`（上游 89luca89/distrobox）、`waydroid-helper-se`（上游 waydroid-helper/waydroid-helper） |
| 我们原创的项目 | 不加，用原名 | `nosdshell`、`nosd-blur`、`nosd-helpers`、`nosd-theme`、`agenote` |
| 原创项目内部的 fork 组件 | 不加，跟随项目命名 | `quickshell-nosd`（隶属 nosdshell 项目） |
| 追上游 master 或 release tag | 不加，那是版本线的事 | `lem-next`（追 master） |
| 追第三方分支或别人的 fork | 不加，用描述性名字 | `helix-steel`（mattwparas/helix 的 steel-event-system 分支） |

判定依据是 origin 里 `git-reference` 的 url，不是注释怎么说——注释会过期，url 不会。`-se` 与 `-bin` 正交：`-se` 说明版本线来自哪里，`-bin` 说明分发形态，两者可以同时出现。

`-se` 自身的路径纪律与 `-bin` / `-next` 完全相同：`$out` 下的 `bin/` 程序名、`lib/`、`libexec/`、`share/` 目录、`.desktop` 文件名与 `Icon=`、man / 补全文件名、wrapper 的 `exec -a`、程序自己的配置目录，一律用上游原名；`-se` 只出现在 `name` 字段、`define-public` 符号与 `share/doc/`。


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


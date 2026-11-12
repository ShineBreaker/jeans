# CODING_STANDARDS.md — 改 `.scm` 时必守的仓库规则

本文件是仓库级 Scheme 写法的单一真相源。**新建或修改 `modules/` 下任何 `.scm`（包定义、服务定义、home 服务、build-system）之前读一遍**；只读任务（查包在哪、某个包怎么打的）或只改 Python / CI / 文档时不必读。

下面每一条都是**硬护栏**：违反了要么构建直接失败，要么静默产出错误结果，而错误信息里看不出真实原因。

打包的完整过程（取源、算 hash、lint、运行时验证、refresh dry-run）不在这里，见 `.agents/skills/pack-guix/SKILL.md`。凡是 skill 已拥有的含义——`-bin` 命名决策、input label 规范、properties 写法与盲区、解包与 wrapper 的具体模式——本文只给指针。

## 文件头

每个 `.scm` 以 SPDX 头开头，新文件用仓库版权：

```scheme
;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-only
```

复制或移植上游代码（Guix 自身、其他 channel、上游 PR）时，SPDX 头列全版权持有者，每人一行；`SPDX-License-Identifier` 照抄上游的值，不要收窄成 `-only`。来源（PR 链接、原模块名）写在 SPDX 块下方的注释里。

## `description` 只描述软件本身

`description` 写软件是什么。打包过程、wrapper 机制、安装布局写成包定义前的 `;;;` 注释，不进 `description`。

留在 `description` 里的只有两类：**面向用户的使用须知**（运行时数据目录、首次启动的初始化步骤）和**一句** prebuilt 来源声明。

可泛化到其他包的打包经验凝练进 `.agents/skills/pack-guix/references/conventions-*.md`（按主题分文件），不要在包定义和本文各留一份。

## 包名是记号，不渗入路径

`-bin`（预编译）、`-next`（追 master 版本线）、`-se`（跟踪我们自己的 fork）等通道记号属于 Guix 包名命名空间。`$out` 下的 `bin/` 程序名、`lib/`、`libexec/`、`share/` 目录名，`.desktop` 文件名与 `Icon=`，man / 补全文件名，wrapper 的 `exec -a` 参数，以及程序会读写的用户配置目录，一律用上游原名。唯一例外是 Guix 自用的 `share/doc/<package-name>/`。

判断标准：这个字符串会被上游程序读到吗？会 → 上游名。清单与实证见 `.agents/skills/pack-guix/references/conventions-naming.md`「包名是本通道的记号，不渗入安装路径」；`blue check-paths` 做静态检查。

## 许可证导入

统一 `#:use-module ((guix licenses) #:prefix license:)`，许可证一律写 `license:expat`、`license:agpl3+` 这样的前缀形式。

## 预编译包用仓库自有 build-system

发布预编译产物的包选对应的一个，选错一类：

- 单二进制 / `.deb` / tarball / AppImage / 裸 ELF：`(jeans build-system binary)`。
- Electron 应用：`(jeans build-system electron)`，必填 `#:program`、`#:app-dir`、`#:application-directory`。

共同要求：

- `#:unpack-method` 必须显式声明——没有扩展名探测，漏了就靠猜（未知值在 `build-system/binary.scm:80` 直接报错）。
- 从旧的 `(build-system gnu-build-system)` 迁移时，`properties`、`version`、`uri`、`sha256`、`inputs` 一律不动；`native-inputs` 里删掉 `patchelf`（新系统自动注入）。
- 永不迁移的特例：自定位 / `bun --compile` 产物、Tauri resource、需要发行版 ABI 的 `.deb`、依赖上游私有 helper 的构建。这些在包定义前用 `;;;` 注释写明原因，并以注释为锚点，不参与批量迁移。

逐参数真相源是 `modules/jeans/build/`（lower 阶段）与 `modules/jeans/build-system/`（host 侧参数校验），两者文件头注释已写明各自职责。

## 模块导出门禁

新建 `modules/jeans/**/<name>.scm` 后，把它加进 `modules/jeans.scm` 的 `%public-modules`（`define` 的第一个参数是模块符号，如 `(jeans packages databases)`）。漏了这步，包不会被 `guix package -L modules -A` 和 `blue gen-docs` 看见。

## 只能由工具改写的文件

- `modules/jeans/packages/rust-crates.scm` —— 只由 `blue import-crate` / `guix import crate --lockfile` 写入。手工编辑、或从其他 channel 复制同文件，都会让 `cargo build --offline` 因版本不匹配失败。`scripts/check-updates/config.json` 的 `skip_files` 也把它列为不检查不更新。
- `docs/packages.md` —— 由 `blue gen-docs` 从包定义生成，不手改。

## channel 内文件引用

`local-file` 在本 channel 按 **CWD** 解析相对路径（编译期源目录信息丢失），所以 channel 自带的资源文件用 `(local-file (search-path %load-path "jeans/licenses/misans.txt"))` 定位（`font-misans` 模式）。

`install-file` 会保留 store item 含哈希的完整 basename；目标文件名必须精确时改用 `copy-file`。

## 通道

`nonguix` 是 `.guix-channel` 里声明的硬依赖。`(nongnu ...)` 模块找不到时修 channel（`guix pull`），不要改包定义绕过。FSL 等限制性许可证走 nonguix `nonfree` 的判定见 `conventions-naming.md`「命名规范」。

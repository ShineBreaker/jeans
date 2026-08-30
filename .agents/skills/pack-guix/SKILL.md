---
name: pack-guix
description: "Use when creating, updating, or reviewing a GNU Guix package in this channel, especially precompiled binaries, .deb/AppImage/tarball extraction, ELF/FHS compatibility, package naming, hashes, wrappers, lint, or build verification."
---

# Pack-Guix

把上游软件变成可审查、可复现、可验证的 Guix package。这个 skill 的目标是稳定的过程，不是只生成一段能加载的 Scheme。

完成标准：包名和许可证有上游证据；源码 hash 已验证；模块能加载；构建和 lint 已执行；运行时验证与包类型匹配；自动更新 properties（upstream-name 等）已设置且 guix refresh dry-run 确认 updater 识别；channel 文档和模块导出已同步；没有未解释的 lint finding。网络失败要明确记录，不能用“代码看起来没问题”代替验证。

## Runbook

### 0. Preflight

1. 读取仓库根目录的 AGENTS.md 和目标分类文件，先理解本地约定。
2. 读 jeans-conventions.md 的「自动更新 properties」章节——新包必须根据上游情况设置 `upstream-name`/`release-tag-prefix` 等属性，否则无法被 guix refresh 自动更新。
3. 按仓库要求先执行 git pull，再执行 git status --short；保留用户已有修改。
4. 创建唯一临时目录，并把下载、解压、clone 和 hash 中间物都放进去：

```bash
PKG_NAME="package"
WORK_DIR="$(mktemp -d "/tmp/pack-guix-$PKG_NAME-XXXXXX")"
trap 'rm -rf "$WORK_DIR"' EXIT
```

4. 搜索已有定义、同名包、旧包名和 jeans.scm 导出列表，选择现有分类；只有没有合适归属时才新建文件。

完成标准：知道要修改的模块、包名候选、上游仓库、release 资产和验证命令；没有把临时文件写进仓库或共享固定目录。

### 1. Naming and license decision

先看上游 LICENSE、源码仓库和 release 资产，再决定命名。不要用“有 ELF”“用了 .deb”或 Guix build system 代替许可证判断。

| 软件状态                                 | 本通道直接分发           | 命名                             |
| ---------------------------------------- | ------------------------ | -------------------------------- |
| MIT/GPL/Apache/MPL 等开源软件            | 预编译产物，未从源码构建 | 加 -bin                          |
| 同一软件已有源码包                       | 预编译变体               | 用 -bin 区分                     |
| 闭源软件                                 | 只有预编译产物           | 不加 -bin                        |
| 源码可见但 FSL 或其他非自由/限制性许可证 | 预编译产物               | 加 -bin，使用 nonguix 的 nonfree |
| 从源码构建                               | 源码包                   | 不因构建结果含二进制而添加 -bin  |

记录证据：许可证文件 URL、源码仓库 URL、使用的 release 资产 URL。-bin 是软件许可状态和本次打包来源的结论，不是文件格式的别名。

完成标准：define-public 名称、name 字段、docs 名称、自动更新 properties 和测试命令全部一致；许可证与上游证据一致；已确认 release 资产文件名前缀（决定 upstream-name 的值）。

### 2. Acquire and inspect the source

根据来源选择唯一分支：

- Git tag/commit：使用 git-fetch、git-reference、git-file-name；固定 commit 并用 checkout 内容算 hash。
- 稳定源码归档：使用 url-fetch；下载后立即用 file 检查类型。
- GitHub 自动生成的源码 tarball：优先改用 git-fetch，避免同一 tag 的归档内容漂移。
- .deb：ar x 后解压 data.tar.*，检查 opt/、usr/bin、desktop 文件和资源路径。
- AppImage：永远用 `7z x` 静态解压（`p7zip` 进 native-inputs），不要执行
  AppImage 自身的 `--appimage-extract`——那需要执行构建树内的二进制，CI 上
  一律 Permission denied。解压产物在顶层（无 `squashfs-root/` 前缀）；产物
  结构、install-plan 符号链接陷阱与参照包见 jeans-conventions.md「AppImage
  包」。解压后检查所有 ELF 和 .so；不要把 AppImage 自带更新器带进 Guix runtime。

预编译产物至少执行：

```bash
file "$BINARY"
readelf -l "$BINARY" | rg 'interpreter' || true
patchelf --print-needed "$BINARY" || true
find "$EXTRACT_DIR" -type f \( -name '*.so*' -o -name '*.node' \) -print
```

同时搜索运行时动态加载线索：dlopen、.node、native、sidecar、Electron resources、Tauri externalBin。readelf 没有 NEEDED 不等于运行时没有依赖。

完成标准：已列出入口文件、资源/sidecar 位置、ELF interpreter、NEEDED 库、动态 addon 和用户可写数据目录。

### 3. Compute and verify hashes

不要手写或猜 hash。使用 Guix 工具：

```bash
# url-fetch：直接对最终下载文件/URL 计算 Guix base32 hash
guix download "$URL"

# git-fetch：对固定 checkout 的递归内容计算 hash
guix hash -rx "$WORK_DIR/src"
```

如果上游同版本资产发生 hash mismatch，先确认 URL、版本和实际内容，再重新计算；不要为了通过构建盲目替换 hash。保留 placeholder hash 的 git 包必须在提交前完成一次真实构建。

完成标准：origin 的 hash 来自当前 URL 或固定 checkout；无 placeholder、旧版本 hash 或未经解释的 mismatch。

### 4. Write the package definition

先读按需参考：

- references/package-template.scm：最小的源码、归档 binary、raw ELF/wrapper 结构。
- references/test-template.sh：单次验证脚本。
- references/watch-test-template.sh：需要持续迭代时才使用。

遵循仓库现有风格：模块导入按类别组织；私有 helper 用 define；新模块必须加入 modules/jeans.scm 的 %public-modules。

预编译包默认使用：

```scheme
#:tests? #f
#:validate-runpath? #f
#:strip-binaries? #f
```

inputs 使用实际包名作为 label；带子输出必须使用 quasiquote alist：

```scheme
(inputs (quasiquote
         (("bash-minimal" unquote bash-minimal)
          ("glibc" unquote glibc)
          ("gcc:lib" unquote gcc "lib"))))
```

fontconfig 变量的实际包名是 fontconfig-minimal，openjdk17 变量的实际包名是 openjdk。build phase 的 assoc-ref、this-package-input 和 gexp 引用必须使用同一个 label；不要写不存在的 gexp 变量 gcc:lib。

选择运行策略：

- 能安全修改 ELF：patchelf --set-interpreter + RPATH，遍历所有实际 ELF，不只 patch 主入口。
- 不能修改或需要保持自定位：安装到 libexec/<pkg>，用 Guix ld-linux wrapper，并传 --argv0 和 --library-path。
- wrapper 中所有路径类环境变量使用 prefix/追加语义。手写 GTK wrapper 的 XDG_DATA_DIRS 必须保留原值；不要设置有害的单数 GDK_PIXBUF_MODULE_FILE。
- shell wrapper 使用 store 中的 bash-minimal，不写宿主 /bin/sh 或 /usr/bin/env。
- Electron 包删除会触发 electron-updater 的 resources/package-type；Wayland 会话可在 wrapper 中注入 Ozone 参数，并提供 ELECTRON_OZONE_PLATFORM_HINT=x11 回退。

完成标准：构建阶段不依赖网络更新、不写入 store 外的源码目录；wrapper、desktop 文件、资源和可写数据路径都指向正确位置；所有输入 label 可由 guix show 证明。

### 5. Load, build, and lint

先做低成本检查，再做实际构建：

```bash
guix package -L modules -A >/dev/null
guix build -L modules <package-name> --dry-run
guix build -L modules <package-name>

guix lint -L modules \
  --checkers=name,tests-true,description,inputs-should-be-native,\
inputs-should-not-be-input,inputs-should-be-minimal,input-labels,\
wrapper-inputs,license,optional-tests,misplaced-flags,\
profile-collisions,patch-file-names,patch-headers,formatting,\
synopsis,gnu-description <package-name>
```

网络型 source、home-page、github-url checker 如果被远端 HTTP/镜像故障中断，记录具体错误并单独重试；不能把网络错误写成包已通过全部 lint。

完成标准：实际构建退出码为 0；lint 没有 package finding；所有 warning 都有解释或修复；git diff --check 通过。

### 6. Runtime verification

根据包类型选择真实命令：

- CLI：guix shell -L modules <package> -- <command> --version 或 --help。
- GUI：在真实图形会话中启动；至少检查 wrapper bash -n、ELF interpreter/RPATH、desktop Exec 和资源路径。
- Electron：分别记录 Wayland/X11 会话、WAYLAND_DISPLAY、缩放变量和 wrapper 实际参数；用 ELECTRON_OZONE_PLATFORM_HINT=x11 做对照实验。
- GTK/Tauri：检查 XDG_DATA_DIRS、GI_TYPELIB_PATH、GUIX_GDK_PIXBUF_MODULE_FILES 和 tray/native addon；不要只以“进程启动未立即退出”判定成功。

如果无法访问图形会话，完成 CLI/静态验证即可，但要明确写出“GUI 未复现”，不要宣称已经证明用户报告的根因。

完成标准：每个已宣称支持的入口都有对应证据；无法运行的测试标记为环境限制，而不是成功。

### 7. Integrate and hand off

1. 新包文件加入 modules/jeans.scm；不要手动编辑 rust-crates.scm。
2. 根据包类型设置自动更新 properties（见 jeans-conventions.md「自动更新 properties」）：
   - **GitHub release 的 `-bin` 包**：几乎必需 `(upstream-name . "<repo-name>")`，否则 guix refresh 报 "no updater"。
   - **多 tag 系列 repo**：加 `(release-tag-prefix . "^<prefix>")`。
   - **跟踪预发布**：加 `(accept-pre-releases? . #t)`。
   - **上游无 tag 的 git-fetch 包**：用 `let`+`git-version` 结构 + `(with-latest-git-commit . #t)`。
   - 仅 guix refresh 力不能及的包（非 GitHub 源、npm scoped tag 等）才在 config.json 配 tag_prefix。
3. 用 dry-run 验证 guix refresh 能识别新包：`GUIX_GITHUB_TOKEN="$(gh auth token)" guix refresh -L modules -L /tmp/nonguix <package>`，确认输出"已是最新"或"would be upgraded"而非"no updater"。
4. 运行 blue gen-docs 更新 docs/packages.md，确认旧名、别名和 docs 没有漂移。
5. 检查 git status --short、git diff --check 和所有测试输出。
6. 汇报修改、验证、网络限制和未完成项；除非用户明确要求，不执行 git commit。

完成标准：代码、文档、自动更新 properties 和模块导出彼此一致；guix refresh dry-run 确认 updater 识别；工作区没有运行中的构建进程；交接报告能区分“通过”“未测试”和“网络阻塞”。

## Hard guards

- 不把开源预编译包和闭源包统一命名；先看许可证。
- 不用固定 /tmp 路径；每次运行使用唯一 WORK_DIR。
- 不用手工 SHA256 转换替代 guix download/guix hash -rx。
- 不用现代 list + output 的表达式表示带 output 的 input；使用 quasiquote alist。
- 不覆盖系统 XDG_DATA_DIRS，不指向包内不完整的 gdk-pixbuf loader cache。
- 不把网络故障、GUI 不可用或只完成 dry-run 写成构建/运行时成功。
- 不提交缺少 `upstream-name` 的 GitHub release `-bin` 包；否则 guix refresh 会报 "no updater" 且包永远收不到自动更新。交付前必须用 `guix refresh` dry-run 确认 updater 识别。

## Channel references

- 仓库约定：../../../AGENTS.md
- jeans 通道特定约定（命名、-bin 决策、自动更新 properties、input label、git-fetch 无 tag 结构、裸 ELF、trivial-build-system、XDG_DATA_DIRS 等）：references/jeans-conventions.md
- 通用 Guix 打包参考（包结构、构建系统、输入类型、阶段修改、最佳实践）：references/guix-reference.md
- Guix package templates：references/package-template.scm
- Single-run test：references/test-template.sh
- Watch test：references/watch-test-template.sh

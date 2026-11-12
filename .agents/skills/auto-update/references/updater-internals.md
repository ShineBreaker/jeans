# updater 内部导航

薄入口 `scripts/check-updates/update_versions.py` 只剩 `main()`（分支骨架）+ 3 个嵌套闭包；其余实现按域拆进 `scripts/check-updates/common/`（13 模块）与 `scripts/check-updates/handlers/`（注册表 + 7 处理器），回归测试在 `scripts/check-updates/tests/`。本文件只做**导航事实**：入口顺序、分发表、版本号与哈希算法、以及"失效信号 → 处置"。语义重复的部分不复述——properties 规则见 `../../pack-guix/references/jeans-conventions.md`，`config.json` 各键语义见它自己的 `notes`，CI 步骤见工作流注释。

下文引用一律用 `模块:符号` 定位，不要信死行号。

## 入口与产物

`update_versions.py:main` 的顺序有意义：

1. 载入 `config.json` 的 `check_pre_release` / `skip_packages` / `skip_files` / `tag_prefix`（`common/config.py:load_config`，路径锚点 `common/paths.py`）。
2. 扫 `modules/jeans/packages/` 下所有 `.scm`（`common/scm.py:find_scm_files` / `parse_package_definitions`），先对 `skip_files` / `skip_packages` 置 `skipped`。
3. `SPECIAL_UPDATERS` 命中的包走专用处理器（`handlers/__init__.py:SPECIAL_UPDATERS`），其余走通用逻辑（url-fetch / git-fetch / `let`+`git-version`）。
4. git-fetch 的两条 release/tag 发现分支（共享变量分支、`is_version_ref` 分支）不再内联实现，统一调 `common/discover.py:discover_release_update`：共享变量分支 `resolve_peel=True`，成功后调 `common/changes.py:build_shared_source_change`；`is_version_ref` 分支 `resolve_peel=False`，成功后调 `common/changes.py:update_package_in_file`。去重状态（`handled_shared` / `shared_results`）与 `finish_shared` 闭包仍保留在入口；`add_retries` 记账键名不变。
5. 写 `report.json`，带上 `total` / `updated` / `failed` / `skipped` / `uptodate` 计数（落盘 `common/changes.py:apply_pending_updates`）。
6. **`common/state.py:check_stale_packages` 最后跑**——它靠本轮 git diff 判定"有没有手工更新"，所以必须等 diff 落定。提前调用会让 stale 判定基于陈旧 diff。
7. `failed_packages > 0` 时开 CI issue（`common/issues.py:create_ci_issue`，正文 `common/issues.py:_build_issue_body`）。
8. 返回码：`has_errors → 2`，`has_updates → 1`，否则 `0`。

`report.json` 里 `packages[].status` 取值：`updated` / `uptodate` / `skipped` / `failed`。闸门只取 `status == "updated"`。

`--only <pkg>` 重跑单包会**覆盖** report.json——报告只含本轮处理的包（2026-11-12 实证：全量跑后 --only 补跑失败包，report 只剩那一包）。需要完整构建测试集时以 `refresh-changed-packages.sh` 从 git diff 重建 refresh-updates.json 为准，它不看 report。

`report.json` **不入库**（单次运行产物）；`font-misans-state.json` 与 `stale-state.json` 是跨轮基线，**必须随包改动一起入库**。

## `SPECIAL_UPDATERS` 分发表（`handlers/__init__.py:SPECIAL_UPDATERS`）

7 个处理器。版本信号不在 GitHub release 上，或 refresh 的 URL 重建对不上：

| 包名 | 函数 | 版本信号源 | 额外改写 |
| --- | --- | --- | --- |
| `zcode` | `handlers/zcode.py:update_zcode` | 官网 `zcode.z.ai/cn` 的 JS 内嵌 `releases/X.Y.Z` 取最新稳定版 | 在 `check_pre_release` 列表里时额外扫 CDN 灰度先行版（`handlers/zcode.py:_zcode_scan_cdn_prerelease`，递增探测 `<v>/linux-x64/latest.yml`，因为官网不展示、先发部分平台） |
| `amber-pm` | `handlers/amber_pm.py:update_amber_pm` | gitee API `/branches/master` 的 commit —— gitee 无 tag，通用逻辑只认 GitHub | `git-version` 重建 |
| `jdtls-bin` | `handlers/jdtls_bin.py:update_jdtls_bin` | GitHub tags 拿版本 + `download.eclipse.org/jdtls/milestones/<v>/` 目录页的归档时间戳 | `-YYYYMMDDHHMM` 不在 version 里，需一并改写 |
| `font-misans` | `handlers/font_misans.py:update_font_misans` | zip 无版本号，用 `ETag` / `Last-Modified` 对 `font-misans-state.json` 比对，变了才下载 | 227MB，不能每次算哈希 |
| `lem-next-bin` | `handlers/lem_next_bin.py:update_lem_next_bin` | nightly 日期 tag（`nightly-YYYYMMDD-HHMM`） | — |
| `mysql-workbench-community-bin` | `handlers/mysql_workbench_bin.py:update_mysql_workbench_bin` | GitHub + release 资产名匹配 | — |
| `prettier-bin` | `handlers/prettier_bin.py:update_prettier_bin` | GitHub + release 资产名匹配 | — |

文档只列前 4 个就会漂移——新增处理器时以这张表为准同步更新，或干脆以本文件为导航、读 `handlers/__init__.py:SPECIAL_UPDATERS` 的字典本身。

## 出网与重试

所有 `requests` 调用集中在 `common/http.py`（公网 URL 校验 + `github_api_get` / `head` / `get` / `post`）；旧 `_http.py` 只剩兼容垫片（`from common.http import *`，下轮删除）。瞬时错误重试走 `common/retry.py:with_retry`（`RetryableError` + 记账 `LAST_RETRIES`）。GitHub token 获取与 release/tag/commit 查询在 `common/github.py`（`get_github_token` / `get_latest_github_release` / `get_latest_github_tag` / `get_latest_commit` / `get_tag_commit_sha`）。

## 版本号与 tag 规范化

- `common/versions.py:package_tag_prefix` —— 先读包定义的 `release-tag-prefix` property（剥掉 `^` 锚点），没有再查 `config.json` 的 `tag_prefix`。**包的 property 优先于配置**，两者不一致时 property 胜出。
- `common/versions.py:normalize_tag_to_version` —— 有 prefix 就剥 prefix；没有则依次尝试 npm scoped tag（`@scope/name@1.2.3` 取最后一个 `@` 之后）、最后只去前导 `v`。
- `common/versions.py:format_commit_version` —— 保留原版本号前缀只替换日期段：`0-unstable-2026-03-01` + `2026-03-16` → `0-unstable-2026-03-16`；无匹配前缀时直接返回新日期。

**无 tag 固定 commit 包**用 `let` + `git-version` 结构（见 `jeans-conventions.md`「上游无 tag」），脚本更新 let 绑定的 commit 并自增 revision，版本号形如 `base-revision.commit前7位`（`common/changes.py:build_let_git_version_change`）。

## `compare_versions` 的语义

`common/versions.py:compare_versions`：两边都能解析成点分数字元组（`\d+(\.\d+)*`）时按**数值比较**，只在新版本严格更大时更新；解析不了（日期版、带字母尾缀、带 `-suffix`）退化为字符串不等。

数值比较是 2026-11-12 加的降级保护：此前是纯粹「不等即更新」，GitHub `/releases/latest` 指针滞后于已发布新 tag 时会把 guix refresh 刚写的版本静默降回去（pnpm v12.20.0 已发布、latest 仍指 v12.18.0，兜底层把 12.20.0 降回 12.18.0；opencode-desktop-bin 2.2.7 被降回 1.19.5 同案）。refresh 层与兜底层对「最新」的定义不完全一致（release 列表扫描 vs `/releases/latest`），指针分歧窗口内比较方向必须可靠。

残留盲区：字母尾缀版本（`1.22b`、`0.4.0-alpha.12`）仍走字符串不等——zen-browser-bin 被 refresh 反复降级是 `version>` 排序问题（`1.22b > 1.22.3b`），与本层无关；若兜底层也见到尾缀型版本倒退，按同一思路加后缀段比较。

## 哈希

NAR 序列化 + Guix base32 编码是纯 Python（`common/hashing.py:compute_nar_base32`，等价于 `guix hash -rx`）；url-fetch 包走 `common/hashing.py:get_base32_from_guix_download` 下载算 hash；git 源走 `common/hashing.py:get_base32_for_git`（clone + NAR）。**不手写、不为了通过构建替换哈希**——同版本资产 hash mismatch 时先确认 URL、版本和实际内容。

## 手工更新判定

`common/state.py:AUTO_COMMIT_MARKERS` 两个前缀：`feat(packages): auto package update`（Conventional Commits，2026-08-19 起）与历史遗留的 `UPDATE: auto package update`。`git log --since` 回溯窗口内新旧并存，判别时要同时排除两者，否则 2026-08-19 之前的自动提交会被误判成手工更新。

## 回归测试

- `tests/test_tag_prefix.py`：`release-tag-prefix` property 优先 + tag 剥离 + 下载 URL 重建（直引 `common/versions.py` 与 `common/scm.py`）。
- `tests/test_shared_source.py`：共享变量源解析正例/4 负例 + 落盘原子性 + `get_tag_commit_sha` peel 语义（直引 `common/scm.py` / `common/changes.py` / `common/github.py`，mock 面打在 `common.github.subprocess` 上）。
- `tests/test_updated_packages.py`：构建测试逻辑不动，常量取自 `common/paths.py`。

## 失效信号 → 处置

| 信号 | 根因 | 处置 |
| --- | --- | --- |
| refresh 报 `no updater`，退出码却是 0 | `-L` 用了相对路径，定位不到包定义，静默跳过 | 换绝对路径重跑（2026-09-27 前的 CI 全程如此） |
| 版本被改小、反复降级 | `guix refresh` 的 `version>` 排序把字母后缀段排在数字段之后 | 把该包移出 refresh 白名单，交兜底层或人工 |
| pre-release 被降级回 stable | refresh 只认 stable release，而 `check_pre_release` 里的包上游只发 pre-release | 留在兜底层，并加进 `config.json` 的 `check_pre_release` |
| monorepo 组件 tag 被读成别的组件版本 | GitHub updater 优先级高于 generic-git，且忽略 `release-tag-prefix` | 移出 refresh 白名单；`release-tag-prefix` property 保留但不生效（agenote / emacs-agenote 2026-10-03 实证） |
| `upstream-name` 写了仍 `no updater` | 它必须等于 release 资产文件名的前缀，不是仓库名加 `-bin` | 核对 `curl -s https://api.github.com/repos/<repo>/releases/latest` 里的资产文件名 |
| 构建测试失败 | 闭源 / 预编译包 / ABI 漂移需要额外适配 | 不要按包名后缀跳过它们；看 issue 里的失败包逐个处理 |
| updater 整个 sweep 崩在 `AttributeError`/`Traceback` | version 非字面量包（`(package-version imgui)`）让 `compare_versions` 对 None 调 `lstrip` | `discover_release_update` 已有早退 guard（2026-11-12）；同类包直接进 `skip_packages` 更省 API 调用 |
| 崩出的 traceback 以 exit 1 退出、CI 当「有更新」继续 | 未捕获异常恰好命中「1=有更新」的退出码约定 | 已修根因；排查 CI 行为怪异时先怀疑「包级异常伪装成正常信号」 |
| refresh 宣布 `updating` 但 `git diff` 无改动 | 版本字面量在模板函数调用点（`osu-lazer-appimage-package`），`package-field-location` 指到模板内 `(version version)` 而非调用点的字面量 | 手写回写版本+hash（资产已入 store，`guix download` 直接出 hash）；g0v0-bin 2026-11-12 实证 |
| refresh 写的版本被兜底层降回去 | `/releases/latest` 指针滞后于新 tag + 旧 compare 不等即更新 | `compare_versions` 数值比较已修（2026-11-12）；再见到写小先查 latest 与 releases 列表是否分歧 |
| 版本钉包（变量名带版本后缀，`imgui-docking-1.92.5`）被「更新」 | 解析器按变量名识别包，不知道它是钉版兼容包 | 进 `skip_packages` 并在 notes 写清原因；新增钉版包时同步 |
| 同 repo 的伴生包版本错位（wuffs 主包 source #f 没被 updater 碰、编译器/库已升） | `source #f` 的包无 URI 可提取，恒报 skipped | 版本号手动对齐伴生包；这类包靠上游 tag 同源保证一致 |
| wrap/patchelf 阶段 `canonicalize-path: No such file or directory` | 上游大版本改了主 ELF 或图标文件名（opencode 1.19→2.x：`ai.opencode.desktop`→`ai.opencode`、图标 `ai.opencode.desktop.png`→`ai.opencode.png`） | `ar x <deb>` 或解包新归档核对实际文件名，同步 `#:program`、install phase 路径与 `find-files` 正则（2026-11-12 实证） |
| git-fetch 源 Software Heritage 查无此 revision、报 `release-release-...` 双前缀 | 包用 `(commit (string-append "release-" version))` 拼 tag，而 updater 把含前缀的完整 tag 写进了 `version` | version 归一化为裸后缀（`20261109-150625-5fad1bd`），hash 不动（updater 算的就是该 tag）；iterm2-color-schemes 2026-11-12 实证 |
| 一批同语言生态包集体构建失败、错误是编译器 API 不兼容（zig `build.zig` exit 2） | 上游新 commit 已迁到比通道内工具链更新的语言 API（zig-* 新 commit 要 >0.16，Guix 最高 zig-0.16） | 整链回退包括下游应用自身的 commit bump（ghostty 随 zig-aro/zig-gobject-ghostty 一起回）；等工具链到位再让 updater 重试 |
| 构建报告出现「未知软件包」但该包在 diff 里确实变了 | `define-private`/hidden 包无法按名字解析（wuffs-compiler、go-* inputs、zig-gobject-ghostty） | 不算真失败——构建其消费方（wuffs、lzsync、ghostty）即覆盖验证，或在报告里忽略 |

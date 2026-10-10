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

## `compare_versions` 不是语义比较

`common/versions.py:compare_versions` 只做**字符串不等**比较（docstring 原话："简单的字符串比较（对于语义化版本，可以改进）"）。它回答的是"变了没有"，不回答"哪个更新"。

由此推出的实际后果：**兜底层不会发现版本倒退，也不会发现版本号变小**。Guix `version>` 对字母后缀段的排序（`1.22b > 1.22.3b`）只影响 `guix refresh` 那一层——zen-browser-bin 被 refresh 反复降级就是这个原因，也正是它被排除在 refresh 白名单外的原因。

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

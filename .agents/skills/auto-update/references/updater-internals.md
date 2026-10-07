# updater 内部导航

`update_versions.py` 有 2000 行，只读它拼不出全貌。本文件只做**导航事实**：入口顺序、分发表、版本号与哈希算法、以及"失效信号 → 处置"。语义重复的部分不复述——properties 规则见 `../../pack-guix/references/jeans-conventions.md`，`config.json` 各键语义见它自己的 `notes`，CI 步骤见工作流注释。

行号对应 `scripts/check-updates/update_versions.py`，改动后按符号名重新定位，不要信死行号。

## 入口与产物

`main():1576` 的顺序有意义：

1. 载入 `config.json` 的 `check_pre_release` / `skip_packages` / `skip_files` / `tag_prefix`。
2. 扫 `modules/jeans/packages/` 下所有 `.scm`，先对 `skip_files` / `skip_packages` 置 `skipped`。
3. `SPECIAL_UPDATERS` 命中的包走专用处理器（`:1684`），其余走通用逻辑（url-fetch / git-fetch / `let`+`git-version`）。
4. 写 `report.json`，带上 `total` / `updated` / `failed` / `skipped` / `uptodate` 计数。
5. **`check_stale_packages(scm_files, config)` 最后跑**（`:2176`）——它靠本轮 git diff 判定"有没有手工更新"，所以必须等 diff 落定。提前调用会让 stale 判定基于陈旧 diff。
6. `failed_packages > 0` 时开 CI issue。
7. 返回码：`has_errors → 2`，`has_updates → 1`，否则 `0`。

`report.json` 里 `packages[].status` 取值：`updated` / `uptodate` / `skipped` / `failed`。闸门只取 `status == "updated"`。

`report.json` **不入库**（单次运行产物）；`font-misans-state.json` 与 `stale-state.json` 是跨轮基线，**必须随包改动一起入库**。

## `SPECIAL_UPDATERS` 分发表（`:888`）

7 个处理器。版本信号不在 GitHub release 上，或 refresh 的 URL 重建对不上：

| 包名 | 函数 | 版本信号源 | 额外改写 |
| --- | --- | --- | --- |
| `zcode` | `:548` | 官网 `zcode.z.ai/cn` 的 JS 内嵌 `releases/X.Y.Z` 取最新稳定版 | 在 `check_pre_release` 列表里时额外扫 CDN 灰度先行版（`_zcode_scan_cdn_prerelease:515`，递增探测 `<v>/linux-x64/latest.yml`，因为官网不展示、先发部分平台） |
| `amber-pm` | `:597` | gitee API `/branches/master` 的 commit —— gitee 无 tag，通用逻辑只认 GitHub | `git-version` 重建 |
| `jdtls-bin` | `:636` | GitHub tags 拿版本 + `download.eclipse.org/jdtls/milestones/<v>/` 目录页的归档时间戳 | `-YYYYMMDDHHMM` 不在 version 里，需一并改写 |
| `font-misans` | `:690` | zip 无版本号，用 `ETag` / `Last-Modified` 对 `font-misans-state.json` 比对，变了才下载 | 227MB，不能每次算哈希 |
| `lem-next-bin` | `:749` | nightly 日期 tag（`nightly-YYYYMMDD-HHMM`） | — |
| `mysql-workbench-community-bin` | `:796` | GitHub + release 资产名匹配 | — |
| `prettier-bin` | `:849` | GitHub + release 资产名匹配 | — |

文档只列前 4 个就会漂移——新增处理器时以这张表为准同步更新，或干脆以本文件为导航、读 `:888` 的字典本身。

## 版本号与 tag 规范化

- `package_tag_prefix:403` —— 先读包定义的 `release-tag-prefix` property（剥掉 `^` 锚点），没有再查 `config.json` 的 `tag_prefix`。**包的 property 优先于配置**，两者不一致时 property 胜出。
- `normalize_tag_to_version:381` —— 有 prefix 就剥 prefix；没有则依次尝试 npm scoped tag（`@scope/name@1.2.3` 取最后一个 `@` 之后）、最后只去前导 `v`。
- `format_commit_version:287` —— 保留原版本号前缀只替换日期段：`0-unstable-2026-03-01` + `2026-03-16` → `0-unstable-2026-03-16`；无匹配前缀时直接返回新日期。

**无 tag 固定 commit 包**用 `let` + `git-version` 结构（见 `jeans-conventions.md`「上游无 tag」），脚本更新 let 绑定的 commit 并自增 revision，版本号形如 `base-revision.commit前7位`。

## `compare_versions` 不是语义比较

`compare_versions:1121` 只做**字符串不等**比较（docstring 原话："简单的字符串比较（对于语义化版本，可以改进）"）。它回答的是"变了没有"，不回答"哪个更新"。

由此推出的实际后果：**兜底层不会发现版本倒退，也不会发现版本号变小**。Guix `version>` 对字母后缀段的排序（`1.22b > 1.22.3b`）只影响 `guix refresh` 那一层——zen-browser-bin 被 refresh 反复降级就是这个原因，也正是它被排除在 refresh 白名单外的原因。

## 哈希

`compute_nar_base32:117` 经 `guix download` 拿 base32；git 源走 `get_base32_for_git:1192`。**不手写、不为了通过构建替换哈希**——同版本资产 hash mismatch 时先确认 URL、版本和实际内容。

## 手工更新判定

`AUTO_COMMIT_MARKERS:901` 两个前缀：`feat(packages): auto package update`（Conventional Commits，2026-08-19 起）与历史遗留的 `UPDATE: auto package update`。`git log --since` 回溯窗口内新旧并存，判别时要同时排除两者，否则 2026-08-19 之前的自动提交会被误判成手工更新。

## 失效信号 → 处置

| 信号 | 根因 | 处置 |
| --- | --- | --- |
| refresh 报 `no updater`，退出码却是 0 | `-L` 用了相对路径，定位不到包定义，静默跳过 | 换绝对路径重跑（2026-09-27 前的 CI 全程如此） |
| 版本被改小、反复降级 | `guix refresh` 的 `version>` 排序把字母后缀段排在数字段之后 | 把该包移出 refresh 白名单，交兜底层或人工 |
| pre-release 被降级回 stable | refresh 只认 stable release，而 `check_pre_release` 里的包上游只发 pre-release | 留在兜底层，并加进 `config.json` 的 `check_pre_release` |
| monorepo 组件 tag 被读成别的组件版本 | GitHub updater 优先级高于 generic-git，且忽略 `release-tag-prefix` | 移出 refresh 白名单；`release-tag-prefix` property 保留但不生效（agenote / emacs-agenote 2026-10-03 实测） |
| `upstream-name` 写了仍 `no updater` | 它必须等于 release 资产文件名的前缀，不是仓库名加 `-bin` | 核对 `curl -s https://api.github.com/repos/<repo>/releases/latest` 里的资产文件名 |
| 构建测试失败 | 闭源 / 预编译包 / ABI 漂移需要额外适配 | 不要按包名后缀跳过它们；看 issue 里的失败包逐个处理 |
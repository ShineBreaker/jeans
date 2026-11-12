### 1.8 `blue upgrade` 撞 GitHub API rate limit(本次 2026-07-16 实测)

未配 `GITHUB_TOKEN` 时,cron 跑 `blue upgrade` 经常会全 0 检出,看起来"啥也没干"。

**根因(直接读源码确认):**

- `scripts/check-updates/update_versions.py:286` `get_latest_github_release` 在 `requests.get(...)` 后调用 `response.raise_for_status()`,把 HTTP 4xx/5xx 转化为 `requests.exceptions.HTTPError`
- 同文件 `is_retryable_http_error`(~line 120)**只**判 5xx(`500 <= status <= 599`),403 **不重试**
- 撞到 403 时:走 `except HTTPError` 分支,`is_retryable_http_error(e)=False` → 直接 `raise` → 被外层 `except requests.exceptions.RequestException` 捕获 → 返回 None
- 结果:41 个包的 release/tags/commits endpoint **全部** 撞 60/h 未鉴权上限 → 全部返回 None → `0 更新、0 保持、0 跳过`

**诊断 prompt 关键字:**

```
⚠️  无法获取GitHub release: 403 Client Error: rate limit exceeded for url:
https://api.github.com/repos/<owner>/<repo>/releases?per_page=30
```

如果 `blue upgrade` 输出里 100% 包都带这个,而且报告是 `已更新: 0 / 保持最新: 0 / 已跳过: <少量非 GitHub 包>`,**别去查 update_versions.py 逻辑**,是 rate limit。

**修复方向(任选,不强制实施):**

1. **`GITHUB_TOKEN` 注入**:交互 shell 已由 `~/.config/fish/conf.d/10-github-token.fish` 注入 `GITHUB_TOKEN`/`GH_TOKEN`（事实源 `gh` CLI），直接读环境变量即可。cron/shepherd 等非交互环境没有该注入时，由用户在任务定义里显式传入——**不要在脚本里解析凭据文件**（hosts.yml/credentials 不进脚本与日志），也不要把 token 写到 /tmp。`update_versions.py:301` 已经支持 `Authorization: token <...>` header,无需改脚本。
   ```bash
   # 验证已有 token 可用（期望 200）
   curl -s -o /dev/null -w "%{http_code}" -H "Authorization: Bearer $GITHUB_TOKEN" https://api.github.com/rate_limit
   # guix refresh 读 GitHub API 用的是专属变量名 GUIX_GITHUB_TOKEN（不是 GITHUB_TOKEN），两个都要 export
   ```
2. **Retry-After 处理**:把 `is_retryable_http_error` 扩展到 403 且 `Retry-After` header 存在的情形,按 header 等待后重试。
3. **fail-fast 早退**:无 token 时第一个 403 就 `sys.exit("no GITHUB_TOKEN; aborting to avoid burning quota")`,别跑完 41 个空请求。

**不要做:**

- ❌ 自己改 cron 直接给所有 `update_versions.py` 调用挂代理——治标不治本
- ❌ 把这个错误当成"正常无更新"假装成功——这会延迟下游 issue 报警

### 1.10 emacs-ghostel 版本升级的连锁依赖陷阱（2026-07-30 实测）

`emacs-ghostel` 的版本升级经常牵动整条依赖链：

1. **zig 版本升级**：ghostel 0.46.0 起 `required_zig` 从 `0.15.2` 升到 `0.16.0`（`build.zig` 里的 `comptime` 检查）。`native-inputs` 里的 `zig-0.15` 必须同步改为 `zig-0.16`。

2. **vendored ghostty 依赖也要求 zig 0.16**：ghostel 通过 `./deps/ghostty/` 目录内联 ghostty 源码构建 libghostty-vt。ghostty commit `ab0b9da`（ghostel 0.46.0 的 `build.zig.zon` 引用）的 `build.zig.zon` 声明 `minimum_zig_version = "0.16.0"`，且其依赖（libxev / vaxis / z2d / zig-objc / zig-js / uucode / zig-wayland / zf / gobject）全部是 zig-0.16 兼容版本。

3. **zig-0.16 API 破坏性变更**：即使 `native-inputs` 改为 `zig-0.16`，ghostty 的 build scripts 仍可能因 zig-0.16 API 变更而失败（如 `linkLibC` 字段移除、`environ_map` 字段移除、`b.modules.put` 签名从 2 变 3 参数等）。

**诊断特征**：

```
build.zig:11:9: error: ghostel requires exactly Zig 0.16.0, found 0.15.2
```

→ 先改 `native-inputs` 里的 `zig-0.15` → `zig-0.16`。

```
deps/ghostty/pkg/zlib/build.zig:15:8: error: no field or member function named 'linkLibC' in 'Build.Step.Compile'
deps/ghostty/src/build/zig.zig:13:9: error: Your Zig version v0.16.0 does not meet the required build version of v0.15.2
```

→ 说明 vendored ghostty 的 build scripts 与 zig-0.16 不兼容。此时**不要继续调试**，revert 版本升级并报告。

**修复方向（按优先级）**：

1. ✅ **等 ghostty 1.4.0 正式发布后再升级 ghostel**：ghostty 的 zig-0.16 迁移（issue #12228）在 2026-04 完成，但 ghostel 内联的 ghostty commit 可能尚未包含所有修复。等 ghostty 1.4.0 发布后，ghostel 下一版本大概率会引用兼容的 ghostty commit。

2. ❌ **手动 patch ghostty build scripts**：工作量巨大（libxev / vaxis / z2d 等十几个依赖全部需要同步），且每次 ghostel 升级都要重新 patch。不可持续。

3. ⚠️ **降级 zig 到 0.15**：ghostel 0.46.0 的 `build.zig` 有 `comptime` 检查，强制要求 zig-0.16，无法降级。

**2026-10-31 新一轮（zig 0.17，issue #66）**：ghostel 0.60.0 把 `required_zig` 提到 `0.17.0`，并已改用 `std.Io.Threaded` / `std.lang.Optimize` 等 0.17 API——不只是 comptime 检查，0.16 下连编译都不可能。Guix 最高只有 `zig-0.16.0`（zig 官方最新稳定是 0.15.2，0.16 已是开发快照），所以 **0.60.0 在当前 Guix 上无解**。处置：0.59.0 保持不动，`emacs-ghostel` 同时从 CI 的 `REFRESH_PACKAGES` 和 `config.json` 的 `skip_packages` 移除/冻结（只改一处会被另一层重新拉起来），解除条件 = Guix 打包 zig-0.17 **且** 重新核对 `build.zig.zon` 里 vendored ghostty 的 pin 与 uucode pin。0.59.0 在 zig-0.16 下实测可构建（`guix build -L modules emacs-ghostel` 退出 0）。

**Cron 行为**：遇到此类连锁依赖失败，**立即 revert**，不要尝试在 cron 里修复。将失败原因写入报告，留给用户决定是否手动介入。

### 1.8.1 `blue upgrade` 慢 / 卡死的根因 + 旁路（2026-07-18 实测）

`blue upgrade` 走的是 `blueprint.scm:128` 的：

```scheme
(run-shell
 (string-append "guix shell --manifest=" manifest
                " -- python3 " update-script))
```

也就是说每次 `blue upgrade` 都重新跑一次 `guix shell --manifest=scripts/check-updates/manifest.scm`，manifest 内容是 `python-wrapper` + `python-requests`。**这步会触达 guix substitute 服务器拉 cached 闭包**（实测 5 min 还卡在 substitute 阶段），多数情况下 cron 跑还没下完就已经 timeout。

**旁路**：绕开 `guix shell`，直接用 PATH 上的 `python3` 调脚本（**不要再假设它自带 `requests`**——2026-11-01 实测 `~/.guix-home/profile/bin/python3` 3.12.12 已无 requests；`guix shell` 在 DSH workspace-write 会话里会因 profile symlink 只读而失败）。用 `guix build` 取 store 路径再拼 `PYTHONPATH`：

```bash
cd ~/Projects/Config/jeans
# requests 及其运行时依赖的 store 路径
PY=$(guix build python-requests python-urllib3 python-certifi \
       python-idna python-charset-normalizer 2>/dev/null \
     | sed 's|$|/lib/python3.12/site-packages|' | paste -sd:)
PYTHONPATH="$PY" GITHUB_TOKEN="$(gh auth token)" \
  python3 -u scripts/check-updates/update_versions.py 2>&1 | tee /tmp/upgrade.log
```

`--only <包名>` 只跑单个包（CI 的 Recover 步骤用它重放），排查单包失败时用它，别为验证一个包跑全量 89 个包。

实测对比：

| 方式                        | 41 包耗时  | 备注                          |
| --------------------------- | ---------- | ----------------------------- |
| `blue upgrade`              | 9+ min 超时 | 卡在 `guix shell` substitute 阶段 |
| `python3 update_versions.py` | ~7 min     | 直接跑，无 substitute 开销     |

注意 `python3 -u` 关 buffering，否则 `update_versions.py` 的 print 缓存会把 cron log 留在终端为空。

**完整后台跑模式**（cron 必备）：

```bash
python3 -u scripts/check-updates/update_versions.py > /tmp/upgrade.log 2>&1 &
# 或用 hermes terminal(background=true) + notify_on_complete=true
```

轮询 `process(action="poll", timeout=N)` 或 `process(action="wait", timeout=N)`，不要让前台的 `terminal` 阻塞超过 5min——脚本本身能跑 7+ 分钟。

**`NEW_BASE32` 占位符**：`update_versions.py:25` 有个常量：

```python
NEW_BASE32 = "0000000000000000000000000000000000000000000000000000"
```

这是脚本**写入新 hash 前的占位**（后续会被真实 hash 替换）。扫描仓库时**唯一真占位**是这条；不要把它和"以 0 开头的 base32 字母表首位字符"混淆——52 字符里第一个字符是 0 是完全合法的（base32 字母表第一位是 0）。**真正占位是整串 52 个 0**，grep 必须用 `0{52}` 而不是 `^0`。

**写盘延迟（2026-08-01 实测）**：`update_versions.py` 先收集全部变更（内存），全部包检查完才统一批量写盘（`apply_pending_updates`）。脚本运行中途 `git status` / `git diff` 始终为空是**正常中间态**，不要误判"没生效"去重跑；等脚本退出后再看 diff。report.json 会记录每个包的 old/new/status，是核对更新集合的唯一权威来源。

### 1.8.2 大资产下载失败：`无法计算 hash` 的手动修复路径（2026-08-01 实测）

脚本对 GitHub release 资产调 `guix download` 计算 base32。**大体积资产（>100MiB，如 oh-my-pi 的 `omp-linux-x64` 175MiB）下载慢且易超时**，报 `❌ 无法计算 hash` 后该包停在旧版本（report.json `status: failed`），但版本信息已在日志里出现（`✅ 发现新版本`）。

手动补完路径（无需改脚本）：

```bash
# 1. 用 guix download 手动算 hash（进度条刷屏，用 tail 截取）
guix download "https://github.com/<org>/<repo>/releases/download/<tag>/<asset>" 2>&1 | tail -3
# 输出形如：/gnu/store/<h>-<asset> + <base32>

# 2. patch 对应 .scm：version + base32 两处（参考 AGENTS.md 版本号约定，v 前缀去除）
```

实测 175MiB 资产 guix download 约 4 分钟；脚本侧超时或 CI 网络波动时走此路径，hash 与脚本算的一致（store 路径即验证）。CI 若反复在同一大资产失败，可建议用户给脚本的 guix download 超时加大或改用 `curl -L --retry`。

### 1.8.3 `guix refresh` 本地 dry-run（2026-08-01 实测）

CI 的 refresh 层本地复现用（不带 `-u` 即只报告不改写）：

```bash
export GUIX_GITHUB_TOKEN=$GITHUB_TOKEN   # refresh 的专属变量名，必须与 GITHUB_TOKEN 分开设
guix refresh -L modules -L <nonguix-dir> <pkg1> <pkg2> ...   # 输出 "would be upgraded from X to Y"
```

注意点：
- **TLS 网络错误会中断整批**：某个包（如 emacs-msgu）撞 gnutls handshake 错误时 refresh 直接 abort，已检查包的结果丢失。**分批跑**（每批 5-10 个包）或对报错包单独重试，不要一次塞 30 个。
- 包列表按 CI workflow 显式列出（refresh 不管 zcode/font-misans/kimi-code-bin/jdtls-bin/librewolf-nongnu/reasonix-desktop-bin，这些留给 Python updater）。
- `generic-git` updater 会把日期 tag 规范化为 `2025.07.31` 格式，属预期行为。

### 1.9 `blue gen-docs` drift detection(本次 2026-07-16 实测)

加包后忘了跑 `blue gen-docs`,`docs/packages.md` 会跟模块顺序漂移:
- 同一包可能同时出现在"AI agents 段"和"utilities 段"(gen-docs 按 `scripts/gen-docs.scm` 的 `%package-modules` 顺序扫描,如果新包**加了同名到 `tools.scm`,但实际定义在 `agent.scm`**,docs 就会基于 `define-public` 位置去归类)
- 表现: `git status -s` 长期有 `M docs/packages.md` 一行差(±1 行)未提交

**cron 自动修复会话必备一步:**

```bash
# 1. blue upgrade 后,跑一次 gen-docs 看有无漂移
blue gen-docs
git status --short   # 期望:clean

# 2. 若有漂移(典型 1 行 ±,新包从 utilities 段搬到 AI agents 段)
#    审视 diff:确保只是位置漂移,不是内容漂移
git diff docs/packages.md | head -30
# 应该只看到 ±1 行同名包位置迁移

# 3. commit(必须带前缀 docs:)
git add docs/packages.md
git commit -m "docs(packages.md): regen via 'blue gen-docs' to include <新包名>"
# 不 push,留给用户
```

**反模式:**

- ❌ 跳过 `blue gen-docs` 认为不影响构建——这是"自动修复 cron"的本职工作之一,不是 nice-to-have
- ❌ 手写 patch 修 docs 漂移——`blue gen-docs` 是 deterministic 的,直接重生成更稳
- ❌ `M doc` 长期留在 working tree——会让后续 CI bot 推 commit 时撞非空 working tree

**`blue` 不可用时直接调用（load-path 是生死线）**：`blue` 自身可能在 `guix pull` 后报 `load-thunk-from-memory: incompatible bytecode version`（BLUE 的字节码与当前 guix 不匹配，需重编译 BLUE 才能修好 wrapper 本身）。**任何 `blue <task>` 都可能中招**（build / upgrade / gen-docs 一视同仁），旁路就是 §5 速查表里那条等价的 `guix ... -L modules` 命令。旁路直接跑底层命令时，**必须带 `--load-path=./modules`**：

```bash
guix repl --load-path=./modules scripts/gen-docs.scm > docs/packages.md
```

漏掉 `--load-path` 时脚本会从 guix pull 的陈旧 channel 快照解析 `(jeans packages ...)`，生成基于旧包集合的 docs——`git diff` 表现为几十行与本次改动无关的包增删漂移。生成后核对 diff 只含预期行（加包时就是新包那一行）；出现大面积漂移 = load-path 没带对，丢弃输出重跑，不要逐行审。


## 6. Where to look when stuck

| Symptom                                                                   | First read                                                                                                                                                                                                                               |
| ------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Build fails in CI but passes locally                                      | `references/auto-update-ci-failures.md` + §1.1 本文件。注意：`1fc7d60` 和 `13f9147` 的 workflow 级修复**均已证明无效**（前者 env 不穿透沙箱，后者 AppArmor 拦截路径）。唯一可靠修复为 `3727139`：将受影响的 git-fetch 包转为 url-fetch。 |
| `cargo build --offline` fails after upgrade                               | `rust-crates.scm` likely stale; re-run `blue import-crate`                                                                                                                                   |
| `guix lint` complains about synopsis/description                          | AGENTS.md "Guix 打包参考" → "测试与验证"                                                                                                                                                                                                 |
| AppImage binary segfaults at runtime                                      | AGENTS.md "裸 ELF 的陷阱" — check for dlopen'd native addons needing `(,gcc "lib")`                                                                                                                                                      |
| 改 `jeans-issue-fixer` cron job 的 prompt                                 | `references/cron-issue-fixer-prompt-template.md`（完整 prompt 模板 + 分支决策 + retry guard 设计 + 调试路径）                                                                                       |
| CI 显示 "包仍然失败" 但之前修过 git-fetch                                 | §1.3：**检查 build-report.json artifact**，失败原因可能已改变（patch 不兼容 / license 阶段等）                                                                                                                                           |
| `install-license-files` match-error（copy-build-system）                  | §1.4：AppImage/二进制包需 `(delete 'install-license-files)`                                                                                                                                                                             |
| `Hunk #N FAILED` in patch application                                     | §1.5：版本升级后 patch 与 upstream 不兼容；cosmetic patch 直接移除                                                                                                                                                                       |
| `NotDir` or `unable to load package manifest` in zig/build phase          | §1.6：url-fetch origin 是 tarball 文件，不能用 copy-recursively；改用 tar xf                                                                                                                                                             |
| `ghostel requires exactly Zig 0.16.0, found 0.15.2`                       | §1.10：ghostel 0.46.0+ 要求 zig-0.16，连带 vendored ghostty 也要求 zig-0.16；先改 native-inputs 再评估 ghostty build scripts 兼容性                                                                                                     |
| ghostel 升级后 zig build 报 `linkLibC` / `environ_map` / `modules.put` 参数错 | `references/ghostel-ghostty-zig-version-chain.md`：vendored ghostty build scripts 与 zig-0.16 API 不兼容；不要 patch，revert 版本等 ghostty 1.4.0 发布后再跟进                                                                         |
| 添加 langpack / 翻译资源 / 主题资源到现有 Guix 包（如 LibreOffice zh-CN） | `references/langpack-resource-merge-pattern.md` —— fundamentalrc 写死相对 argv[0] 路径，profile union 不进 `lib/<app>/`，必须 `inherit + copy-recursively + union-build`                                                                 |
| 新建包文件后 `guix lint` 报 `未知软件包`                                  | §5 / §5.1：先确定 `define-public` 存在，然后检查 `%public-modules` 是否注册了该模块；lint 在文件级沙箱里报的"未知"往往是 re-export 链断了，不是包本身有错。                                                                              |
| `search-path %load-path` 在 REPL/lint 里频刷"解析为相对于当前目录"        | §5.2：已知 carry-over warning；不影响解析结果，审阅时忽略。                                                                                                                                                                                                                                                                                                                                                                              |
| `wrapper-inputs` lint:`wrap-program` 但 inputs 缺 `bash-minimal`           | §3.1 / `references/lint-recipes.md` §Recipe 1:quasiquote alist 字母位插一行。                                                                                                                                                                                                                                                                                                                                                            |
| lint `description` 末尾应有点号(trailing parenthetical 触发的)           | §3.3 / `references/lint-recipes.md` §Recipe 2:补 `.` 或追加一句 English sentence 收尾。                                                                                                                                                                                                                                                                                                                                                    |
| byte-level paren delta ≠ 真实 s-exp 不平衡                                    | §3.2 / `references/lint-recipes.md` §Recipe 5:URL/字符串/正则里 `(`,`)` 多算;以 `guix repl -L modules` + `(use-modules (jeans))` + `guix build -L modules -e ...` + `guix lint` 三件套为准。                                                                                                                                                                                                                                                                                                                   |
| `blue upgrade` 全 0/41 检出,100% 包都报 `403 rate limit exceeded`           | §1.8:无 `GITHUB_TOKEN` 时撞 60/h 上限。修法:`export GITHUB_TOKEN=$(gh auth token)` 给 cron;或 `is_retryable_http_error` 扩到 403+`Retry-After`;或无 token 时 fail-fast。不要反复"诊断逻辑 bug"。                                                                                                                                                                                                                                                                                                         |
| `M docs/packages.md` 长期漂移(典型 ±1 行,新包同名段重复出现)             | §1.9:`blue gen-docs` 是 deterministic,直接重生成 + 审视 diff + commit,不要手改。
| `blue <task>`（build / gen-docs / upgrade 任一）报 `load-thunk-from-memory: incompatible bytecode version`，或重生成后 docs 出现大面积无关漂移 | §1.9：BLUE 字节码与当前 guix 不匹配时整个 runner 不可用，旁路跑 §5 速查表里的等价 `guix ... -L modules` 命令；漏 load-path 会从陈旧 channel 快照解析包集合，diff 大面积漂移即中招，丢弃重跑。 |                                                                                                                                                                                                                                                                                                                                                          |
| cron 自动修复会话里"不知道能做什么/不能做什么"                            | §3.5:docs 可改 + commit + 单文件;包定义/`rust-crates.scm`/workflow 文件全部不碰;`git push` 永远留给用户。                                                                                                                                                                                                                                                                                                                                  |
| `blue upgrade` 9+ min 超时但 `python3 update_versions.py` 7 min 跑完         | §1.8.1:`guix shell --manifest` 重新拉 substitute 是瓶颈;旁路直接调脚本即可（前提 PATH 有 `python3 + requests`）                                                                                                                                                                                                                                                                                                                              |
| 扫仓库 base32 找"占位 hash" 时把"以 0 开头"全当占位                         | §1.8.1:base32 字母表首位是 0;真正占位是 `0{52}` 整串;`update_versions.py:25` 有 `NEW_BASE32` 常量定义占位值                                                                                                                                                                                                                                                                                                                                  |
| cron session 里 `git reset --hard` / `git commit --allow-empty` 撞 §4.2 陷阱  | §4.2:reset --hard 会丢掉 staged 改动;reflog 不显式存空 commit;丢失改动要 `git fsck --unreachable` 捞。改用 `git switch -c debug/test-gpg` 临时分支测试                                                                                                                                                                                                                                                                                            |
| GPG 签 commit 在 cron 里 fail(`cannot open '/dev/tty'` / "损坏的密码")      | §4.3:本机 passphrase 非空 + 无 loopback pinentry + 无专用 secret key;workaround 全有副作用。fallback 到"留 patch 不 commit + 用户手动 rebase 重签"
| 系统调起 skill 时拽错了(例如把 Guix-configs 仓的 skill 拽到 jeans 任务里) | 优先读 jeans 工作目录里的 `AGENTS.md`(本仓库用的任务是 `blue` 不是 `blue home`)。本 skill 是 jeans 的专属 class 级 skill;Guix-configs 仓的 `guix-config-maintenance` 等 skill 专治那个仓库，跟 jeans 不互通。 |
| cron 跑 `git pull` 超时(60s) | 本机网络拉 GitHub 较慢,pull 可能卡在 channel tarball unpack。cron 里 `git pull` 用 `timeout 30` 包一下,超时就跳过——下一次 cron 会续上。 |
| GitHub API rate limit 403 查不到 CI 状态 | 本机 gh CLI 已可用（绝对路径 `/home/brokenshine/.local/state/nix/profile/bin/gh`，2026-08-06 实测正常）：`gh api` / `gh run view <id> --log-failed` / `gh issue list` 优先用；仍 403 时用 `git log --oneline origin/main` 看最新 commit 是否已落本地,再 `git show <sha> --stat` 看改了什么,间接判断 CI 是否跑通。 |
| AGENTS.md 描述里有 `source/channel.lock`，但仓库只有 `.guix-channel`          | `references/lint-recipes.md` §Recipe 4：blueprint 走 `.guix-channel` + `-L modules`；不要为对齐文档建假的 `source/`。                                                                                                                                                                                                                                                                                                                       |
| `modules/jeans.scm` 补完 re-export 后要同步的事                           | `blue gen-docs` 重新生成 `docs/packages.md`，并在同一 commit 中提交。                                                                                                                                                                                                                                                                                                                                                                      |
| Rust 包运行时 panic `Posix(2)` / ENOENT（如 nix-ld `src/main.rs:187`）     | `references/rust-packaging-patterns.md` §1：`option_env!()` 编译时常量未设，baked 了 NixOS 默认路径。诊断：`strings` 二进制查 baked 值；修复：build phase `setenv` + `native-inputs (list glibc)`。input label 是 `"glibc"` 不是 `"libc"`。 |
| runner 沙箱拒绝 exec 构建树内新文件（AppImage 自解压 / `./configure` execvp 127/EACCES） | 三种已验证修法按场景选：① AppImage → 用 store 的 7z 静态解包（waywallen-bin 72ccb4f）；② 手写 configure 脚本 → `(which "sh") "./configure"` 由解释器当数据读入，配套 `(add-before 'configure 'disable-exec-sanity-check)` 把 configure 自身的 chmod+x/exec sanity check 短路成 `if false`，再加 `--enable-cross-compile --arch=... --target-os=linux` 让探针跳过运行时执行（ffmpeg-7 实战验证）；③ 纯数据文件不受影响。daemon TMPDIR 迁移到 /var/tmp 对此无效（runner 的 /tmp 本身不 noexec）。 |
| `.scm` 里给 `substitute*` 写含 `$` 的正则，多层字符串转义反复踩坑 | Scheme 字符串吃一层 `\`、regex 引擎再吃一层，肉眼极难数对；直接改用 `.` 通配符匹配 `$`/`\`（如 `"if ! .TMPSH >> .logfile"`），零转义且唯一命中。先用同引擎预检：`guix repl` 里 `string-match` 测试模式，别等构建跑到 phase 才发现静默未匹配（`substitute*` 未命中是静默通过的！后续 phase 报错才暴露）。 |
| 私有 `define`（无 `-bin` 后缀依赖包 / 内部包）不能 `blue build <名字>` | `blue build` 只认 export 的公开名。验证其效果直接构建下游公开包（依赖会把它拉进构建图）；不要用 `guix build -e '(@ ...)'` 硬引用——`@` 在带 gexp 参数的包上可能解析到不同加载路径，误导诊断。 |
| `guix build -L modules` 报 `未绑定变量` / `未知软件包`，但同模块 `guix repl -L modules` 能加载 | §3.2：模块有语法错误，`package: missing field initializers` = 多一个 `)` 提前闭合 `package` 表单；不是包名写错，也不是 re-export 缺失。 |


# CI 失败判定与 issue 处理（jeans auto-update 流水线）

jeans (`~/Projects/Config/jeans`, `main` branch, mirror at codeberg) is a personal [Guix channel](https://guix.gnu.org/manual/en/html_node/Channels.html) that packages bleeding-edge and proprietary software for Guix. It depends on `nonguix` for some imports (`.guix-channel`).

**Repository layout reality (as of 2026-07-11):** the repo root contains only `.guix-channel` (the channel manifest declaring `(name jeans) (directory "modules") (dependencies … nonguix)`) — there is **no** `source/` directory or `source/channel.lock` file. `AGENTS.md` (auto-injected project context) sometimes references `source/channel.lock` as if it existed; treat that as a doc drift — the authoritative layout is `blueprint.scm` + `.guix-channel` + `-L modules`. Auto-fix scripts should never create a `source/` directory to match AGENTS.md; if it ever becomes real, it would be a conscious layout change, not a missing-file stub.

This skill covers routine maintenance of that repo. Project conventions (commit message prefixes, file layout, linting, etc.) live in `AGENTS.md` and are auto-injected as project context — do not duplicate them here. This skill captures **workflow patterns and known failure modes** that AGENTS.md does not.


## 1. The auto-update pipeline (most common failure source)

`.github/workflows/auto-update.yml` runs weekly (Tue/Thu/Sat 02:00 UTC):

```
checkout → update_versions.py → detect changes →
  (if changes) install guix + git clone nonguix → test_updated_packages.py →
  gpg sign + commit + push to github → mirror to codeberg
```

- `scripts/check-updates/update_versions.py` queries GitHub API, bumps `version` + recomputes `base32` for url-fetch packages, or `git clone --depth=1` to compute nar-base32 for git-fetch packages. Updates are written in-memory first, then flushed to disk in `apply_pending_updates()`.
- `scripts/check-updates/test_updated_packages.py` reads `report.json`, runs `guix build -L modules <pkg>` for every entry with `status=updated`, creates a GitHub issue titled `❌ Updated package build failures — <sha1[:8]>` on any failure, exits 1 to block the commit step.

### 1.0 CI 失败类型判定（先判定再动手，2026-08-01 实战确立）

**不是所有 CI failure 都要修包。** 先判定失败类型：

- **基础设施失败（无需修复）**：run 创建后几十秒内即 completed+failure，卡在 `Install Guix` / `Checkout` / `Set up job` / `Prepare /etc/gitconfig` 等**早期步骤**，`Build test updated packages` 从未开始，且**无新 issue** 生成。典型观测：`Install Guix` step 5 秒内 failure（如 2026-07-30 run 30535193381、2026-08-01 run 30685995735 均为 4-5 秒卡死 Install Guix）。→ **直接 `gh workflow run auto-update.yml --repo ShineBreaker/jeans --ref main` 重跑，不修任何包。**
- **真实构建失败（需要修复）**：CI 跑到 `Build test updated packages` 步骤后失败，`test_updated_packages.py` 创建 `❌ Updated package build failures — <sha>` issue。**只有看到这种 issue 才修包。**
- **测试/脚本同步失败（需要修代码，不是重跑，2026-08-06 实例确立）**：run 创建后 ~10-20 秒内 failure——时间上与基础设施失败几乎一样短，**但失败步骤是一个测试步骤**（如 `Test updater release tag prefixes`），不是 Install Guix / Checkout。日志特征是 Python Traceback / `KeyError` / 断言失败，**无构建 issue**。典型根因：某次提交删除了包（`define-public`），但回归测试用例 / config 注释 / CI 包列表仍引用该包名 → 测试与仓库不同步。实例：commit `293affd`（2026-08-02）删除 `open-interpreter-bin` 等 6 个包，`test_tag_prefix.py` 的用例仍引用它 → `KeyError: 'open-interpreter-bin'`。修法：删掉/更新过时引用，**本地先复跑同款测试命令**（`python3 scripts/check-updates/test_tag_prefix.py`）验证通过，再交用户 commit/push。

判定命令（gh 用绝对路径，注意 `~/.nix-profile` 已废弃、新路径是 `~/.local/state/nix/profile/bin/gh`）：

```bash
GH=/home/brokenshine/.local/state/nix/profile/bin/gh
$GH api 'repos/ShineBreaker/jeans/actions/runs?per_page=5' \
  --jq '.workflow_runs[] | select(.name=="Auto Update Packages") | {id, status, conclusion, event, created_at, updated_at}'
$GH issue list --repo ShineBreaker/jeans --state open --json number,title,labels,createdAt
```

- run 的 `conclusion: failure` + `updated_at - created_at < 60s` → 基础设施失败
- `updated_at - created_at > 几分钟` + 有 `❌` issue → 构建失败，进修复流程
- **判断失败类型必须看失败步骤名，不能只看 run 时长**：基础设施失败和测试/脚本同步失败都可能几十秒内完成（2026-08-06 run 31067714158 约 13 秒挂在 `Test updater release tag prefixes`）。先 `gh run view <run_id> --jobs` 定位 failed step，再 `gh run view <run_id> --log-failed` 抓真实错误行（grep `Traceback|KeyError|error`）。

### 1.0.1 重跑 action 的时机陷阱（2026-08-06 实测踩坑）

**本地修复未 commit/push 时，`gh workflow run` 重跑 CI 用的是远端 main 分支代码——修复不生效，重跑必败**（本次实测：修复 test_tag_prefix.py 后立即重跑，20 秒内又以同样 KeyError 失败，日志里还是旧代码）。正确顺序：

1. 本地修复 → **本地复跑 CI 同款命令验证**（如 `python3 scripts/check-updates/test_tag_prefix.py`，测试脚本本身无 guix 依赖，直接可跑）
2. 用 ad-hoc 验证脚本做针对性验证（临时文件放 /tmp、前缀 `hermes-verify-`，跑完删除；可加"反向验证"断言——如确认旧用例对当前代码确实失败，证明修复针对真实失败模式而非掩盖问题）
3. 重跑留给用户 commit/push 之后，或报告里说明"需提交后 CI 才生效"

### 1.0.2 删除包后的引用清理清单（2026-08-06 确立）

删除一个 `define-public` 包时（或接手他人已删包的失败时），同步检查三处残留引用：

- `scripts/check-updates/test_tag_prefix.py` 等**回归测试用例**——引用已删包 → CI 测试步骤硬失败（无容错），本次即此
- `scripts/check-updates/config.json` 的注释/配置（`tag_prefix`、`notes` 等）——不影响功能但保持描述准确
- `.github/workflows/auto-update.yml` 的 `guix refresh` 包列表——**不能由 agent 改**（workflow 边界），但残留只警告不阻塞（refresh 步骤 `set +e`，注释明示"个别包失败不阻塞整体"）；报告给用户手动清理
- 更新 `docs/packages.md`（`blue gen-docs`）

### 1.1 Known CI failure mode: sandbox git-fetch can never finish (issue #20 / #21)

**Status (2026-06-25):** 经三轮尝试后确认有效修复。

- commit `1fc7d60`（`GIT_CONFIG_NOSYSTEM`）：❌ env 不穿透 daemon 沙箱
- commit `13f9147`（`rm -f /etc/gitconfig` 在 daemon 前）：❌ AppArmor 仍拦截
- commit `3727139`（**git-fetch → url-fetch**）：✅ 本次确认有效，彻底绕过 git 对 /etc/gitconfig 的依赖

**根因链条（最终确认）：**

1. GitHub Actions `ubuntu-latest` 的 AppArmor 在构建沙箱内拦截对 `/etc/gitconfig` 的任何访问（即使文件不存在也返回 EACCES）
2. `guix-daemon` 创建构建沙箱时只传递白名单环境变量（`http_proxy`、`NIX_*` 等），`GIT_CONFIG_NOSYSTEM` 不在其中
3. Guix 上游的 `guix/build/git.scm` 未在 git-fetch 构建器内设置该变量（NixOS #63774 同类修复未移植）
4. 因此 git-fetch 包的 checkout 阶段必然失败：`git init` → EACCES → exit 128

如果遇到匹配此模式的症状，**先查 `git log --oneline .github/workflows/auto-update.yml` 看是否有更新的修复，再继续诊断。**

Symptoms in the build log:

```
building /gnu/store/<h>-<pkg>-<ver>-checkout.drv...
warning: unable to access '/etc/gitconfig': Permission denied
fatal: unknown error occurred while reading the configuration files
git-fetch: '.../git-minimal-2.52.0/bin/git init --initial-branch=main' failed with exit code 128
Trying content-addressed mirror at bordeaux.guix.gnu.org... 404 Not Found
SWH: revision "v<X>" originating from https://github.com/<org>/<repo> could not be found
```

Root cause: guix sandbox cannot read `/etc/gitconfig`, so `git init` fails. The `GIT_CONFIG_NOSYSTEM` env var set on the CI workflow step does **not propagate** into the sandbox because `guix-daemon` only passes a whitelist of environment variables (`http_proxy`, `NIX_*`, etc.) to build environments. After `git init` fails, guix falls back to:

1. bordeaux/ci.guix.gnu.org nar mirror — nar not yet published → 404
2. Software Heritage — `v<tag>` revisions often not indexed for newly-tagged releases → 404

The result: **every** git-fetch package whose version was bumped in the same run fails to build, including **transitive dependents** that pull in the broken git-fetch package via `native-inputs`. Example: `osu-lazer-bin` was reported as failed in issue #20 because its `native-inputs` includes `opentabletdriver-udev-rules` (which is itself git-fetch).

**Diagnostic checklist when this issue recurs:**

1. `curl -s https://api.github.com/repos/<org>/<repo>/tags` — verify the tag still exists upstream. If yes, it's not an upstream regression.
2. `curl -sL -o /dev/null -w "%{http_code}\n" https://archive.softwareheritage.org/api/1/revision/origin/https://github.com/<org>/<repo>/tag/v<X>/` — check SWH. 404 here is normal for fresh tags; SWH re-indexing takes hours to days.
3. Confirm the failure pattern is "git init failed" not "checkout failed" — the former is CI sandbox; the latter is real upstream change.

**Known mitigations（按有效性从高到低）：**

1. ✅ **将受影响的 git-fetch 包转为 url-fetch**（主修复，commit `3727139`）：
   改为 `https://github.com/<org>/<repo>/archive/refs/tags/v<ver>.tar.gz`。
   使用 `guix download <url>` 计算 base32。注意 GitHub archive tarball 目录
   结构为 `<repo>-<ver>`（无 `v` 前缀），但文件相对路径与 git clone 一致。
   转换后 `update_versions.py` 能正常通过 url-fetch 路径更新版本和 hash。
   辅助 origin（固定 commit 的私有 source 定义）也可转为 url-fetch：
   `https://github.com/<org>/<repo>/archive/<full-commit-hash>.tar.gz`。

2. ❌ `rm -f /etc/gitconfig` 在 daemon 启动前（commit `13f9147`，已证明无效）：
   AppArmor 对路径的拦截不仅限于已存在的文件——即使文件已被删除，沙箱内
   对该路径的访问仍被 AppArmor 拒绝。**不要再次尝试此方法。**

3. ❌ `GIT_CONFIG_NOSYSTEM: "1"` 在 workflow step env（commit `1fc7d60`，已证明无效）：
   `guix-daemon` 只将白名单环境变量传入构建沙箱，`GIT_CONFIG_NOSYSTEM` 不在其中。
   保留在 workflow 中仅作为将来 Guix 上游修复后的预备，当前无实际效果。

### 1.2 Issue-handling protocol

When asked to "fix the new issue" in jeans:

1. `curl -s https://api.github.com/repos/ShineBreaker/jeans/issues?state=open` — list open issues. CI-bot auto-issues follow the `❌ Updated package build failures — <8hex>` title pattern; manually-created issues look different.
2. For each failure, identify whether the failing package itself changed, or whether it was pulled in transitively. Cross-reference `(native-inputs (list ...))` and `(inputs (list ...))` of every failing package.
3. **Do not trust `report.json` / `build-report.json` on disk alone** — they may be stale or from a previous run. Always re-read the issue body for the canonical failure log.
4. CI bot issues are blocked-commit notifications; the commit they refer to (`Base commit: <sha>` in the body) has typically already landed if the step ordering failed open. Verify with `git log --oneline <sha>`.

### 1.3 Masked failures（git-fetch 修复后暴露的预存 bug）

**教训（2026-06-25）：** git-fetch 的沙箱错误发生在 checkout 阶段（构建的最早期）。
一个 git-fetch 包失败时，后续阶段（unpack、patch、build、install）的 bug 被**完全掩盖**，
因为在到达这些阶段之前构建就已中止。

当 git-fetch → url-fetch 转换消除了 checkout 错误后，原先被掩盖的错误会**立即暴露**。
对每个"修复后仍然失败"的包，必须**重新读取完整的 build log**（而非依赖 issue title 或
过去的经验），因为失败原因已经变了。

**本会话碰到的两个实例：**

| 包              | 掩盖前（git-fetch 时代）        | 暴露后（url-fetch 时代）                                         |
| --------------- | ------------------------------- | ---------------------------------------------------------------- |
| `osu-lazer-bin` | checkout: git init EACCES → 128 | `install-license-files`: match-error（AppImage 无 license 文件） |
| `emacs-ghostel` | checkout: git init EACCES → 128 | `patch`: `Hunk #1 FAILED`（upstream 变更导致补丁不兼容）         |

**诊断范式：** 当 CI 报"同一个包仍然失败"时，**不要假设是同一个原因**。
必须获取 `build-report.json` artifact（API: `/actions/artifacts/<id>/zip`），
逐包检查 `output` 字段的**最后 30 行**。checkout 失败的特征是 `git-fetch: ... git init`
和 `EACCES`；其他错误则是新问题。


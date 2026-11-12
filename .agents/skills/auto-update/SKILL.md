---
name: auto-update
description: "Use when checking a channel package's latest upstream version, a release was missed (package never moves / CI produced no commit), deciding how a package stays current (refresh 白名单、properties、skip/stale_watch/config.json), triaging CI failures or cron issues, or touching scripts/check-updates/ 与 .github/workflows/auto-update.yml。Not for writing package definitions — that's pack-guix."
---

# Auto-Update

回答两个问题：**这个包现在该是哪个版本？** **改完怎么验证它下一次会被自动更新？** 结论带证据（dry-run 输出、`report.json`、真实构建退出码），不用"看起来没问题"代替验证。

完成标准：给出目标版本及其发现依据（release 资产 / tag / commit / 特殊源信号）；哈希来自 `guix download` 或 `guix hash -rx`；改过的包真实构建退出码 0；包已确认落在 refresh 白名单或兜底层；state 文件与提交状态说清；确实无法自动更新的包说明了原因落点。

## 两层

**refresh 主力**：GitHub release 包（靠 `upstream-name` 匹配资产文件名前缀）与 git-fetch 有 tag 包，由 `guix refresh` 改写 version + base32。properties 怎么写见 `../pack-guix/references/conventions-refresh.md`——不在此复述。

**Python 兜底**：非 GitHub 源（zcode 的 z.ai CDN、amber-pm 的 gitee、font-misans 的 ETag）、refresh 报 `no updater` 的边缘 case（reasonix-studio-bin、cua-driver-bin）、以及 stale 监控。逐包处理器与通用逻辑见 `references/updater-internals.md`；`config.json` 每个键的语义写在它自己的 `notes` 字段里。

## 白名单

CI 的 refresh 步骤在 `.github/workflows/auto-update.yml` 里**逐个列出包名**——那是白名单，不是全模块扫描。所以：

- 新包要自动更新：设好 properties，再把包名加进那份列表，然后跑下面的 dry-run 验证。
- 包改名：同一次改动里更新那份列表，否则新名静默收不到更新，且不报错。
- 刻意留在兜底层或排除在 refresh 之外的：`librewolf-nongnu`（inherit 上游）、`git-credential-keepassxc`（有意冻结，理由在 `config.json` 的 `stale_watch`）、zen-browser-bin、ellsp-bin / emacs-ellsp、agenote / emacs-agenote（各自理由写在工作流里那段注释）。

## 本地跑 refresh

`-L` 必须是**绝对路径**。相对 load path 下 `guix refresh` 定位不到包定义，静默零改写还退出 0——2026-09-27 前的 CI 一直处在这个状态，dry-run 从不暴露它（2026-09-27 CI 实证）：

```bash
GUIX_GITHUB_TOKEN="$(gh auth token)" guix refresh -L "$PWD/modules" -L /tmp/nonguix <package>
# "已是最新" / "would be upgraded" → 白名单与 properties 都生效
# "no updater"                → 先查 upstream-name 是否等于资产文件名前缀，
#                                再查 conventions-refresh.md 的静默盲区清单
```

`GUIX_GITHUB_TOKEN` 是 guix refresh 读 GitHub API 的专属变量名，不是 `GITHUB_TOKEN`。

## 兜底脚本

```bash
blue upgrade   # = guix shell --manifest=scripts/check-updates/manifest.scm \
              #     -- python3 scripts/check-updates/update_versions.py
```

退出码：0 = 无更新，1 = 已应用更新，2 = 出错。

`report.json` 是单次运行结果，**不入库**；`font-misans-state.json` 与 `stale-state.json` 是跨轮基线，**随包改动一起入库**——不入库则 CI 每轮都从零开始。

## 清单类上游（CDN 直发，无 release）

中国区客户端常把 Linux 构建放在自家 CDN，产物名带不可推导的后缀（`WorkBuddy-linux-x64-deb-5.6.2.40046327-c7b525f3.deb`）。`guix refresh` 对这类源恒报「未能确定可用版本」，只能由 `SPECIAL_UPDATERS` 接（`workbuddy-cn` 是参照实现）。四条判断：

- **信号源优先同域**：与产物同域的静态清单（如 `.../saas/version.json` 的平台分节）比另一域名的更新接口更可靠——CDN 通才能下载，信号与产物同生共死。接口作备份，只在主信号解析失败时兜底。
- **版本号取完整文件名主体**：清单里的版本往往就是 `<semver>.<build>-<commit>`。保留 commit 后缀，URI 才能由 `version` 完整重建（无需 `extra_replacements`）；只留数字版本的包，在上游用同一数字版本重切构建时会永远等不到重钉。
- **同版本也要重钉**：上游会原地重传同名文件，version 不变而字节变了。用清单里的 sha256 与包内 base32 对比，不同就重钉 hash（`update_package_in_file` 对同版本是幂等的）。版本变低一律不钉，防 CDN 边缘回吐旧清单降级。
- **固定源站对象，不固定 CDN 边缘**：CDN 在重传窗口内可能给不同地区不同字节，固定 sha256 的包在一半地区必然 hash mismatch。改钉存储桶的全球加速端点（同一对象、各处同字节），hash 仍从实际下载现算，并用清单 sha256 交叉校验——对不上说明正在重传，宁可这轮失败也不要钉下只在一地成立的 hash。

## 闸门

`scripts/check-updates/tests/test_updated_packages.py` 合并 `report.json`（`status == "updated"`）与 `refresh-updates.json`，对并集逐个 `guix build`。闭源与预编译包同样过这道闸门，不按包名后缀跳过。构建失败时不提交更新，CI 会开 issue 记录失败包。

`guix build` 成功后还有第二道：ELF NEEDED 解析检查。预编译包的依赖清单随上游构建漂移——magpie-bin 0.1.1167 上游新增了 `libfontconfig.so.1` 直接依赖，hash 正确、构建通过，但启动即被加载器拒绝。闸门对产物里每个带 `PT_INTERP` 的 ELF 跑 `ld.so --list`：patchelf 过的二进制用自身 interpreter + RUNPATH 解析；ld-linux wrapper 包从脚本提取 store ld.so 与 `--library-path` 目录；`LD_LIBRARY_PATH` 型 env wrapper（electron/Tauri）的导出目录并入候选。直接 NEEDED 缺失（stderr `error while loading shared libraries`）与传递缺失（stdout `=> not found`）均判构建失败；无可用 ld.so 的自定位/nix-ld 包记 `skipped` 放行并在报告中留痕。此检查只覆盖静态 NEEDED——dlopen/FFI 依赖仍需真实运行验证，见 pack-guix 的 runtime verification。

## 冻结与解冻（skip_packages / stale_watch / REFRESH_PACKAGES 三处联动）

有意冻结的包同时落在三处：`skip_packages`（兜底脚本跳过）、`stale_watch`（超 stale_days 无人工更新则 CI 开提醒 issue）、被排除在 workflow 的 `REFRESH_PACKAGES` 外（行内注释写明原因）。`stale_watch` 的 `notes` 要记：障碍是什么、解除条件、解除路径。

解冻时四处一起动（git-credential-keepassxc 2026-11-12 实证）：

1. **先确认障碍已解除**。MSRV 型障碍查 Cargo.lock 里锁定版本的 `rust_version`：`curl https://index.crates.io/<name>/<name> | grep '"vers":"<锁定版本>"'` 比 crates.io API 的 max_stable_version 可靠（API 的 rust_version 字段常为 null）。
2. **升版本 + 重钉 hash**；cargo 包还要 `guix import crate --lockfile=<新锁文件> <pkg>` → `merge_crate_inputs.py` 重做 rust-crates.scm 输入（**绝不手改**），再真构建验证。
3. `config.json`：从 `skip_packages` 与 `stale_watch` 移除；`notes` 改写成解冻事实（日期+解除依据），别留旧障碍描述误导后人。
4. `auto-update.yml`：包名加回 `REFRESH_PACKAGES`，注释更新为"已解冻"而非静默删除——下次有人搜包名能看到完整历史。
5. `stale-state.json`：删掉该包条目；仍在 `stale_watch` 的包若刚人工核对过，顺手 bump `last_checked` 避免当期重开提醒 issue。

解冻后跑一次 `guix refresh -L "$PWD/modules" <pkg>` 确认「已是最新」= 白名单与 properties 接管成功，才收工。

## Hard guards

- 动版本号前先 `git pull`：CI 与本地会同时改同一个包定义。
- 哈希用 `guix download` / `guix hash -rx` 计算，不手写、不为了通过构建替换哈希。
- `modules/jeans/packages/rust-crates.scm` 由 `blue import-crate` 管理，refresh 与兜底脚本都跳过它。
- 是否自动更新看**源与 properties**，不看包名后缀。
- `stale_watch` 里的包超期未手工更新，CI 开提醒 issue 是预期行为，不是错误。

## Channel references

- 打包侧 conventions（命名、properties、input label、git-fetch 无 tag 结构）：`../pack-guix/SKILL.md` 与 `../pack-guix/references/conventions-*.md`（按主题拆分）
- updater 内部（SPECIAL_UPDATERS 分发、通用逻辑、版本号与哈希算法）：`references/updater-internals.md`
- CI 失败判定 / issue 协议 / masked failures：`references/ci-failure-triage.md`、`references/auto-update-ci-failures.md`
- 运维陷阱（rate limit、`blue upgrade` 旁路、手动 hash、refresh dry-run、症状索引）：`references/updater-operations.md`
- cron 运维（边界、working-tree 陷阱、GPG 死结、fixer prompt 模板）：`references/cron-operations.md`、`references/cron-issue-fixer-prompt-template.md`
- git-fetch 沙箱修复全程：`references/git-fetch-sandbox-fix-journey.md`；ghostel↔ghostty zig 连锁：`references/ghostel-ghostty-zig-version-chain.md`
- CI 步骤与其中的环境陷阱（`/etc/gitconfig`、userns sysctl、Guix 安装快照、GPG、Codeberg 镜像）：`.github/workflows/auto-update.yml` 各 step 的注释本身就是真相源
- 配置键语义：`scripts/check-updates/config.json` 的 `notes`
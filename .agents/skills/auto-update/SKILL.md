---
name: auto-update
description: "Use when checking whether a package in this channel has a newer upstream version, when a release was missed (a package never moves, or a CI run produced no commit), when deciding how a new or renamed package stays current (guix refresh 白名单、upstream-name 等 properties、config.json 的 skip/tag_prefix/check_pre_release/stale_watch), or when touching scripts/check-updates/、.github/workflows/auto-update.yml、font-misans-state.json / stale-state.json。架构两层：guix refresh 主力，Python 脚本兜底 refresh 的盲区。"
---

# Auto-Update

回答两个问题：**这个包现在该是哪个版本？** **改完怎么验证它下一次会被自动更新？** 结论带证据（dry-run 输出、`report.json`、真实构建退出码），不用"看起来没问题"代替验证。

完成标准：给出目标版本及其发现依据（release 资产 / tag / commit / 特殊源信号）；哈希来自 `guix download` 或 `guix hash -rx`；改过的包真实构建退出码 0；包已确认落在 refresh 白名单或兜底层；state 文件与提交状态说清；确实无法自动更新的包说明了原因落点。

## 两层

**refresh 主力**：GitHub release 包（靠 `upstream-name` 匹配资产文件名前缀）与 git-fetch 有 tag 包，由 `guix refresh` 改写 version + base32。properties 怎么写见 `../pack-guix/references/jeans-conventions.md`「自动更新 properties」——不在此复述。

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
#                                再查 jeans-conventions.md 的静默盲区清单
```

`GUIX_GITHUB_TOKEN` 是 guix refresh 读 GitHub API 的专属变量名，不是 `GITHUB_TOKEN`。

## 兜底脚本

```bash
blue upgrade   # = guix shell --manifest=scripts/check-updates/manifest.scm \
              #     -- python3 scripts/check-updates/update_versions.py
```

退出码：0 = 无更新，1 = 已应用更新，2 = 出错。

`report.json` 是单次运行结果，**不入库**；`font-misans-state.json` 与 `stale-state.json` 是跨轮基线，**随包改动一起入库**——不入库则 CI 每轮都从零开始。

## 闸门

`scripts/check-updates/test_updated_packages.py` 合并 `report.json`（`status == "updated"`）与 `refresh-updates.json`，对并集逐个 `guix build`。闭源与预编译包同样过这道闸门，不按包名后缀跳过。构建失败时不提交更新，CI 会开 issue 记录失败包。

## Hard guards

- 动版本号前先 `git pull`：CI 与本地会同时改同一个包定义。
- 哈希用 `guix download` / `guix hash -rx` 计算，不手写、不为了通过构建替换哈希。
- `modules/jeans/packages/rust-crates.scm` 由 `blue import-crate` 管理，refresh 与兜底脚本都跳过它。
- 是否自动更新看**源与 properties**，不看包名后缀。
- `stale_watch` 里的包超期未手工更新，CI 开提醒 issue 是预期行为，不是错误。

## Channel references

- 打包侧 conventions（命名、properties、input label、git-fetch 无 tag 结构）：`../pack-guix/SKILL.md` 与 `../pack-guix/references/jeans-conventions.md`
- updater 内部（SPECIAL_UPDATERS 分发、通用逻辑、版本号与哈希算法）：`references/updater-internals.md`
- CI 步骤与其中的环境陷阱（`/etc/gitconfig`、userns sysctl、Guix 安装快照、GPG、Codeberg 镜像）：`.github/workflows/auto-update.yml` 各 step 的注释本身就是真相源
- 配置键语义：`scripts/check-updates/config.json` 的 `notes`
# AGENTS.md — jeans Guix Channel

个人 [Guix channel](https://github.com/ShineBreaker/jeans)（Just Enough AI-geNerated Slops），用 AI 辅助打包前沿软件和闭源软件。包定义在 `modules/`（由 `.guix-channel` 声明），硬依赖 [nonguix](https://gitlab.com/nonguix/nonguix)——构建时必须可用。

<critical>开始任何操作前先 `git pull`，再 `git status --short`。自动更新 CI 每周二/四/六 02:00 UTC 抢先提交包更新，不同步就是在过期的包定义上改东西。pull 后保留工作区已有的修改。</critical>

## 按分支读，不要预先全读

- **写或改任何 `.scm`**（包定义、服务定义、build-system）→ `CODING_STANDARDS.md`：文件头、`description` 边界、许可证导入、build-system 选型、模块导出门禁、只能由工具改写的文件。
- **新增、修改或评审一个包定义**，或动取源、解包、wrapper、lint、运行时验证 → `.agents/skills/pack-guix/SKILL.md` 走它的 runbook；通道特有的坑查 `references/jeans-conventions.md`。命名（`-bin` 决策）、input label 规范、properties 写法都在那里，本文不重复。
- **版本、hash、自动更新、CI**——"这个包为什么不动""它现在该是哪个版本""updater 报错"、或要改 `scripts/check-updates/` 与 `.github/workflows/auto-update.yml` → `.agents/skills/auto-update/SKILL.md`。

## 命令

任务运行器是 [BLUE](https://codeberg.org/lapislazuli/blue)，定义在 `blueprint.scm`；`blue help` 列出命令，`blue help <命令>` 看单条细节。以下均在仓库根目录执行。

| 命令                                 | 作用                                                               |
| ------------------------------------ | ------------------------------------------------------------------ |
| `blue build <包名>...`               | 构建一个或多个包，等价于 `guix build --load-path=./modules <包名>` |
| `blue upgrade`                       | 跑兜底 updater（Python 一层，不含主力 `guix refresh`）             |
| `blue import-crate <crate名>[@版本]` | 从 crates.io 导入 Rust crate 源码，写入 `rust-crates.scm`          |
| `blue gen-docs`                      | 由包定义重生成 `docs/packages.md`                                  |
| `blue check-paths`                   | 静态检查包名（`-bin` 等记号）是否渗入安装路径                      |

包定义新增、改名、改 `synopsis` 或 `description` 后跑一次 `blue gen-docs`，让文档与代码不漂移。

## 提交

`<type>(<scope>): <简短描述>`（Conventional Commits），scope 取值与 BREAKING CHANGE 细则见 `~/.config/git/gitmessage`。自动更新 CI 自己发 `feat(packages): auto package update YYYY-MM-DD`，`git log` 里见到这条是 CI 的改动，不是你写的。

## 签名与认证

走完整 Guix channel 认证：`.guix-authorizations` 授权主 key 与 `jeans-workflow-bot`，公钥在 `keyring` 分支；`guix pull` 和 `.git/hooks/pre-push` 都跑 `guix git authenticate`。

- introduction commit 钉在 `35d1811c26daf2c132880fe304149b1363064a79`，本仓库 `.git/config` 与 `Guix-configs/source/channel.scm` 必须一起改。**不要**退回 `1e30ccb`：其后的 `9115919`、`7791bbe` 是 GitHub 生成的 merge commit（`%G?=E`，签名只带 issuer key-id），guix 缺 key 时抛 `bytevector-u16-ref: Wrong type argument ... (expecting bytevector): 13071995811931693460`。
- GitHub 仓库只开 **Rebase merging**。squash 或 merge commit 会让 GitHub 重签，重新制造 `E` 提交。
- 新 clone 首次启用（写入 `.git/config` 并安装 pre-push 钩子）：

  ```bash
  guix git authenticate 35d1811c26daf2c132880fe304149b1363064a79 62711D5E9CCDEC6907CADBF88637132222571907 --keyring=keyring
  ```

- 提交身份：`git config user.email` 必须是签名 key 的某个 uid email，否则 GitHub 判 `bad_email`（Unverified）。当前 key 同时有 `102544159+ShineBreaker@users.noreply.github.com` 和 `xchai404@gmail.com` 两个 uid。

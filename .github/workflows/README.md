# Jeans CI 与镜像说明

仓库现在采用单一路线：

- `GitHub` 是主源仓库和 CI 入口
- `Codeberg` 只作为镜像仓库

因此，自动更新、失败报告、以及主分支写入都发生在 GitHub；Codeberg 只接收同步后的结果。

## 工作流概览

### `.github/workflows/auto-update.yml`

这个 workflow 每周运行一次，也支持手动触发。它会：

- 检查 GitHub 上游版本
- 计算新的 hash
- 运行 `scripts/check-updates/update_versions.py`
- 发现变更后直接 commit 并 push 回 GitHub 的当前分支
- 在更新脚本出现失败包时，自动创建 GitHub Issue
- 如果本次运行产生了新 commit，会顺手把同一提交镜像到 Codeberg

### `.github/workflows/mirror-codeberg.yml`

这个 workflow 在 `main` 分支有新 push 时运行，也支持手动触发。它会：

- 以 GitHub 当前 `main` 为准
- 强制推送到 Codeberg 的 `main`

这个 workflow 负责同步普通开发提交、PR 合并后的提交，以及手动 push 的提交。

说明：

- GitHub Actions 用 `${{ secrets.GITHUB_TOKEN }}` 回推 GitHub 时，不会再触发新的 `push` workflow。
- 因此 `auto-update.yml` 在它自己写回 GitHub 后，会额外做一次 Codeberg 镜像，避免自动更新提交漏同步。

## 需要的 GitHub 配置

在 GitHub 仓库设置中添加以下配置：

| 名称 | 类型 | 用途 |
| --- | --- | --- |
| `FORGEJO_TOKEN` | Secret | 从 GitHub Actions 推送到 Codeberg 镜像仓库 |
| `FORGEJO_USERNAME` | Variable | HTTPS 推送到 Codeberg 时使用的用户名 |
| `WORKFLOW_GPG_PRIVATE_KEY` | Secret | 供自动更新 workflow 导入的 ASCII-armored GPG 私钥；建议专门为 CI 单独创建 |
| `WORKFLOW_GPG_PASSPHRASE` | Secret | 如果 workflow 私钥有口令则填写；无口令可留空 |
| `WORKFLOW_GPG_FINGERPRINT` | Variable | workflow 私钥的 fingerprint；CI 会校验导入的私钥是否就是这把 key |
| `WORKFLOW_GIT_NAME` | Variable | 自动更新提交使用的 Git committer name |
| `WORKFLOW_GIT_EMAIL` | Variable | 自动更新提交使用的 Git committer email |

说明：

- `${{ secrets.GITHUB_TOKEN }}` 是 GitHub 内置 token，不需要你额外创建。
- `auto-update.yml` 已经声明了 `contents: write` 和 `issues: write` 权限，用于回推更新和创建 GitHub Issue。
- 当前 workflow 默认把 Codeberg 目标仓库写死为 `BrokenShine/jeans`。
- `WORKFLOW_GPG_PRIVATE_KEY` 对应的公钥必须已经存在于 `keyring` 分支，并且其 fingerprint 已写入 `.guix-authorizations`。

## 推荐的签名模型

推荐把签名职责拆开：

- 你自己日常开发继续使用个人 GPG key
- GitHub Actions 自动更新使用单独的 workflow GPG key

这样做的好处：

- CI 泄漏风险和个人 key 隔离
- 后续如果需要轮换 CI key，只改 `keyring`、`.guix-authorizations` 和 GitHub secrets
- 一眼就能区分“人工提交”和“自动更新提交”

建议的落地顺序：

1. 生成一把新的 workflow 专用 OpenPGP key。
2. 把它的公钥提交到 `keyring` 分支。
3. 把它的 fingerprint 加进 `.guix-authorizations`。
4. 等这两部分都已经进入受信历史后，再把私钥放进 GitHub secret `WORKFLOW_GPG_PRIVATE_KEY`。
5. 在 GitHub variables 里配置 `WORKFLOW_GPG_FINGERPRINT`、`WORKFLOW_GIT_NAME`、`WORKFLOW_GIT_EMAIL`。
6. 手动运行一次 `Auto Update Packages` 验证自动签名是否生效。

## 推荐工作流

1. 所有代码修改、PR、Issue、自动更新都在 GitHub 上完成。
2. GitHub 的 `main` 是唯一真源。
3. Codeberg 只接受来自 GitHub Actions 的镜像同步，不再作为手动合并入口。

## Guix Channel 鉴权注意事项

Guix channel authentication 不认 “GitHub Verified” 这个概念，它只认：

- 提交是否带 OpenPGP 签名
- 签名公钥是否已经出现在 `keyring` 分支
- 对应 fingerprint 是否已经被 `.guix-authorizations` 授权

这意味着以下提交方式会破坏已认证 channel 的提交链：

- GitHub UI 的 `Merge pull request`
- GitHub UI 的 `Squash and merge`
- GitHub UI 的 `Rebase and merge`
- 未导入授权私钥的 GitHub Actions 自动提交

原因是这些提交通常会由 GitHub 自己或其他未授权 key 重新生成提交对象；即使 GitHub 页面显示 `Verified`，Guix 也不会信任它。

推荐做法：

1. PR 在 GitHub 上审查即可。
2. 真正写入 `main` 时，在本地获取 PR 内容。
3. 使用你已经授权的 GPG key 执行 `git cherry-pick -S`、`git merge -S` 或重新提交。
4. 再由本地 push 到 GitHub。

`auto-update.yml` 现在已经支持通过 `WORKFLOW_GPG_PRIVATE_KEY` 在 CI 中签名自动更新提交，但普通 PR 合并仍然不要依赖 GitHub UI 自动生成 merge commit。

## 更新脚本约定

`update_versions.py` 的退出码如下：

- `0`：没有更新且没有错误
- `1`：有更新
- `2`：有错误

`auto-update.yml` 已经兼容这个约定，不会把“有更新”误判成失败。

### 跳过文件配置

某些 `.scm` 文件可以加入跳过列表，不进行检查。编辑 `scripts/check-updates/config.json`：

```json
{
  "skip_files": ["rust-crates.scm"],
  "check_pre_release": false,
  "skip_packages": [],
  "notes": {
    "skip_files": "这些文件不会被检查或更新。rust-crates.scm 由 guix import crate 管理，禁止手动编辑。",
    "check_pre_release": "是否检查预发布版本（alpha/beta/rc）"
  }
}
```

## 验证方式

### 验证自动更新

1. 打开 GitHub 仓库页面
2. 进入 `Actions`
3. 手动运行 `Auto Update Packages`
4. 检查 GitHub `main` 是否产生新的更新 commit
5. 检查 Codeberg `main` 是否同步到相同提交

### 验证镜像同步

1. 在 GitHub `main` 合并一个普通 PR
2. 等待 `Mirror GitHub to Codeberg` 运行
3. 检查 Codeberg 仓库是否到达同一提交

## 故障排除

### GitHub API 速率限制

如果看到 `403 API rate limit exceeded`：

1. 确保 workflow 正在使用 `${{ secrets.GITHUB_TOKEN }}`
2. 或者在 `config.json` 中临时增加 `skip_packages`

### 推送到 Codeberg 失败

如果镜像同步失败，优先检查：

1. `FORGEJO_TOKEN` 是否有效且有 `repo` 权限
2. `FORGEJO_USERNAME` 是否和 token 对应的账户一致
3. Codeberg 目标仓库是否允许该账户推送

### Guix 安装慢或不稳定

如果 GitHub runner 上安装 Guix 过慢：

1. 尽量保持 `manifest.scm` 精简
2. 先手动重跑一次 workflow，确认是否为瞬时网络故障

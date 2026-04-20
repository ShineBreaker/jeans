# Jeans CI 自动更新配置教程

本文档说明如何为 jeans Guix Channel 配置自动更新 CI。仓库现在同时提供两条路径：

- `.forgejo/workflows/auto-update.yml`
  适合已经拿到 Codeberg Actions 配额，或者你自己接了 Forgejo Runner 的情况。
- `.github/workflows/auto-update.yml`
  适合把仓库镜像到 GitHub，用 GitHub Actions 跑更新，再把结果作为 PR 提交回 Codeberg。

如果你当前没法使用 Codeberg 托管 Actions，优先用第二种。

## 两种工作流的区别

### Forgejo / Codeberg 工作流

`.forgejo/workflows/auto-update.yml` 实现以下功能：

- **定时执行**：每周一 UTC 02:00 自动运行
- **手动触发**：支持通过 Codeberg UI 手动运行
- **版本检查**：调用 GitHub API 检查所有包的最新版本
- **Hash 计算**：由更新脚本 `update_versions.py` 内部处理（含 git-fetch 场景）
- **失败报告**：`update_versions.py` 在 CI 模式下会自动尝试创建 Codeberg Issue
- **自动提交**：有更新时自动 commit + push 到 `main`
- **产物上传**：上传 `report.json` 作为构建产物

### GitHub Actions 工作流

`.github/workflows/auto-update.yml` 实现以下功能：

- **定时执行**：每周一 UTC 02:00 自动运行
- **手动触发**：支持通过 GitHub UI 手动运行
- **版本检查与 Hash 计算**：复用同一个 `update_versions.py`
- **失败报告**：继续由脚本调用 Codeberg Issue API
- **自动建 PR**：有更新时通过 Forgejo AGit 推送到 Codeberg，自动创建一个指向 `main` 的 PR
- **产物上传**：上传 `report.json` 到 GitHub Actions 产物

这个 GitHub 方案不会直接改 Codeberg 的 `main`，而是把变更提交成 PR，方便你手动审查和合并。

## 推荐方案：GitHub Actions 驱动，Codeberg 合并

### 1. 在 GitHub 创建镜像仓库

把 `https://codeberg.org/BrokenShine/jeans.git` 镜像到 GitHub。工作流会在 GitHub 上执行，但真正的合并入口仍然是 Codeberg。

### 2. 添加 GitHub Secret 和 Variable

在 GitHub 仓库设置中添加以下配置：

| 名称               | 类型     | 用途                                                        | 获取方式                                                                    |
| ------------------ | -------- | ----------------------------------------------------------- | --------------------------------------------------------------------------- |
| `FORGEJO_TOKEN`    | Secret   | 调用 Codeberg API 创建 Issue，并通过 HTTPS push 到 Codeberg | Codeberg → Settings → Applications → Create New Token，至少需要 `repo` 范围 |
| `FORGEJO_USERNAME` | Variable | 作为 Git HTTPS push 时的用户名                              | 你的 Codeberg 用户名，或用于推送的 bot 用户名                               |

说明：

- GitHub 的 `${{ secrets.GITHUB_TOKEN }}` 为内置 token，工作流会直接使用它访问 GitHub API，不需要额外创建同名 secret。
- 当前 workflow 里已经把 Codeberg 目标仓库写死为 `BrokenShine/jeans`，所以即使 GitHub 镜像仓库名称不同，也不会推错地方。

### 3. 推送 GitHub 工作流文件

提交以下文件到仓库：

```bash
git add .github/workflows/auto-update.yml .forgejo/workflows/README.md
git commit -m "ADD: GitHub auto-update workflow"
git push
```

如果你的 GitHub 仓库是从 Codeberg 手动镜像过去的，记得把这些改动同步到 GitHub 镜像。

### 4. 手动触发测试

1. 打开 GitHub 仓库页面
2. 进入 **Actions**
3. 选择 **Auto Update Packages**
4. 点击 **Run workflow**

### 5. 到 Codeberg 检查 PR

如果检测到包更新，workflow 会：

1. 在 GitHub runner 上提交变更
2. 通过 `git push ... HEAD:refs/for/main/...` 把变更送到 Codeberg
3. 在 Codeberg 上自动创建一个指向 `main` 的 PR

默认 topic 使用当天的 UTC 日期，例如 `auto-update-2026-04-20`。同一天重跑会更新同一个 PR，下一天会创建新的 PR。

## Forgejo / Codeberg 工作流配置

如果你后面拿到了 Codeberg Actions 配额，或者自己挂了 runner，可以继续使用 `.forgejo/workflows/auto-update.yml`。

### 1. 添加 Forgejo Secrets

在 Codeberg 仓库设置中添加以下加密 Secrets：

| Secret 名称     | 用途                                                     | 获取方式                                                                |
| --------------- | -------------------------------------------------------- | ----------------------------------------------------------------------- |
| `GITHUB_TOKEN`  | GitHub API 认证，应对速率限制                            | GitHub Settings → Developer settings → Personal access tokens           |
| `FORGEJO_TOKEN` | Forgejo API 认证，供脚本创建 Issue 和 workflow push 代码 | Codeberg → Settings → Applications → Create New Token，需要 `repo` 范围 |

### 2. 确认 Runner 可用性

工作流使用 `runs-on: codeberg-small`。确保你的 Codeberg 实例：

- 启用了 Forgejo Actions
- 有可用的 `codeberg-small` runner

如需修改 runner 标签，编辑 `.forgejo/workflows/auto-update.yml` 的 `runs-on` 字段：

```yaml
runs-on: codeberg-small # 可选: codeberg-tiny, codeberg-small, codeberg-medium
```

### 3. 调整定时执行时间（可选）

默认每周一 UTC 02:00 执行。如需修改，编辑 `on.schedule.cron`：

```yaml
cron: "0 2 * * 1" # 分 时 日 月 星期
```

常用示例：

- 每周一 10:00 北京时间：`"0 2 * * 1"`
- 每天凌晨：`"0 0 * * *"`
- 每两周：`"0 0 * * 0/2"`

## 更新脚本相关约定

### 退出码

`update_versions.py` 约定如下：

- `0`：没有更新且没有错误
- `1`：有更新
- `2`：有错误

两个 workflow 都已经兼容这个约定，不会把“有更新”误判成失败。

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

## 验证结果

- **GitHub 工作流成功时**：Codeberg 上会出现新的 PR，`modules/` 中的版本变更包含在 PR 里
- **Forgejo 工作流成功时**：会直接看到新的 commit 推到 `main`
- **有更新但部分失败时**：`update_versions.py` 会在 CI 模式下根据失败计数决定是否创建 Issue
- **无更新时**：不会创建 PR、commit 或 Issue

构建结束后，可以下载 `report.json` 查看详细更新报告。

## 故障排除

### GitHub API 速率限制

如果看到 `403 API rate limit exceeded`：

1. 确保 workflow 已经向脚本传入 GitHub token
2. 或者在 `config.json` 中临时增加 `skip_packages`

### Guix 安装超时

如果安装 Guix 过慢：

1. 尽量保持 `manifest.scm` 精简
2. GitHub runner 一般比 `codeberg-small` 更稳定
3. Codeberg runner 不够时，优先使用 GitHub 方案

### 推送到 Codeberg 失败

如果 GitHub workflow 无法把 PR 推回 Codeberg，优先检查：

1. `FORGEJO_TOKEN` 是否有效且有 `repo` 权限
2. `FORGEJO_USERNAME` 是否和 token 对应的账户一致
3. Codeberg 仓库是否仍允许该 token 对应账户推送

### 不希望自动建 PR

如果你只想让 GitHub 跑检查，不自动向 Codeberg 发 PR，可以注释掉 `.github/workflows/auto-update.yml` 中的 `Push AGit pull request to Codeberg` 步骤，改为手动处理变更。

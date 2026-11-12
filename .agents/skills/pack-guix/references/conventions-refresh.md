# jeans 通道打包约定 — 自动更新 properties

<!-- 2026-11-12 由 references/jeans-conventions.md 按主题拆分；内容为整段原样搬迁 -->

## 自动更新 properties（决定包能否被 guix refresh 接管）

`guix refresh` 是 CI 自动更新的主力。要让 refresh 正确识别并更新一个包，包定义需要带合适的 `properties` 字段。**新建包时必须根据以下规则设置 properties**，否则包将无法被自动更新，或被误判为"无 updater"。

### upstream-name（GitHub release 包几乎必需）

github updater 用 release 资产 URL 的文件名前缀匹配包。`package-upstream-name`（无此 property 时回退到 package name）必须出现在文件名中。

对 `-bin` 包，Guix 包名（如 `crush-bin`）通常**不等于**上游 repo 名（`crush`），而 release 资产文件名（如 `crush_0.85.0_amd64.deb`）用的是 repo 名。不加 `upstream-name` 会导致 `guix refresh` 报 "no updater"（静默失败，不报具体原因）。

**规则**：upstream-name 的值 = release 资产文件名里 version 之前的前缀。判断方法：看 `releases/download/{tag}/` 后面的文件名，去掉 version 部分，剩下的就是 upstream-name。

```scheme
;; crush-bin 的资产是 crush_{version}_amd64.deb → upstream-name = "crush"
(properties `((upstream-name . "crush")))

;; 不需要 upstream-name 的情况：资产文件名恰好以 Guix 包全名开头
;; 如 mypackage-1.0.tar.gz 且 Guix 包名就是 mypackage → 不加
```

资产文件名**不含版本号**（`omo-linux-x64`）不必然让 refresh 失效：tag 是
plain `v<ver>` 且资产名以 upstream-name 开头时，refresh 会原样保留资产名、
只替换 tag 段，整条升级链（版本发现 → URL 重建 → hash 重算）实测可用
（omo-bin 5.1.27→5.1.28 降级实验，2026-10-10）。与
reasonix-studio-bin（refresh 无法重建）的关键差异在 tag 形状：后者是
`studio-v*` 产品前缀系列，不是"无版本号资产"本身。

多个 property 用 alist 合并：

```scheme
(properties `((upstream-name . "reasonix") (release-tag-prefix . "^v")))
```

### release-tag-prefix（多 tag 系列时必需）

当同一个 GitHub repo 有多个 release tag 系列（如 `v1.0`/`v2.0` 和 `desktop-v1.0`/`desktop-v2.0`），用正则指定跟踪哪个系列。值是**正则表达式**：

```scheme
(properties `((release-tag-prefix . "^v")))           ; 只匹配 v 开头的 tag
(properties `((release-tag-prefix . "^desktop-v")))   ; 只匹配 desktop-v 开头
(properties `((release-tag-prefix . "^rust-v")))      ; 只匹配 rust-v 开头
```

### accept-pre-releases?（跟踪预发布版本）

允许 guix refresh 考虑预发布版本（alpha/beta/rc）。**注意 property 名带问号**：

```scheme
(properties `((accept-pre-releases? . #t)))
```

### with-latest-git-commit（无 tag 仓库追踪 commit）

见下方「Git-Fetch 固定提交包 → 上游无 tag」章节。仅用于上游不打 tag 的 git-fetch 包，配合 `let`+`git-version` 结构。

### properties 写在哪里

`(properties ...)` 是 package 的一个字段，放在 `(license ...)` 之前（作为倒数第二个字段）。用 quasiquote（反引号）+ alist：

```scheme
(package
  ...
  (properties `((upstream-name . "foo") (release-tag-prefix . "^v")))
  (license license:expat))
```

### 验证 properties 是否生效

加完 properties 后，用 dry-run 验证 guix refresh 能否识别（带 `GUIX_GITHUB_TOKEN` 避免匿名限流）：

```bash
GUIX_GITHUB_TOKEN="$(gh auth token)" guix refresh -L modules -L /tmp/nonguix <package-name>
# "已是最新" 或 "would be upgraded" = 识别成功
# "no updater" = properties 配置有误（检查 upstream-name 是否匹配文件名前缀），
#               或命中 github updater 静默盲区（见下方「Python updater 兜底」的盲区清单）
```

### Python updater 兜底（guix refresh 力不能及的包）

少数包 guix refresh 无法处理，仍由 `update_versions.py` + `config.json` 兜底：

- **非 GitHub 源**：CDN（zcode）、gitee（amber-pm）、无 version URL（font-misans）
- **npm scoped tag**：kimi-code-bin（`@scope/name@version` 模式）
- **refresh URL 重建失败的边缘 case**：reasonix-studio-bin（`studio-v` 前缀 + 资产文件名无版本号）
- 这些包的 tag_prefix / pre-release 规则保留在 `config.json`，不写入 properties。

github updater 还有几个静默盲区（不报错、就是不识别），命中任一条就直接走 Python 兜底，不要在 properties 上浪费时间：

- **非数字开头的 tag 系列**：`nightly-20260831` 这类 tag 不被当作版本（lem-next-bin，由 SPECIAL_UPDATERS 的 nightly 处理器接管，正则锁定 `nightly-YYYYMMDD-HHMM` 日期 tag）。
- **资产前缀大小写不匹配**：上游 tag/资产用大写 `V0.3.7`（inso-bin），refresh 的资产名匹配区分大小写。
- **只发 prerelease 的 repo**：`/releases/latest` 恒 404（inso-bin），必须进 `check_pre_release` 列表才有版本可查；即使 guix refresh 侧能识别， prerelease-only 的上游也常需要 Python 侧配合。
- **tag 带产品前缀 + 资产名带平台后缀**：`updated-url` 对 `/releases/download/` 只认 `v<ver>/<name>-<ver><ext>`、`<ver>/<repo>-<ver><ext>` 等固定形状；cua 的 `cua-driver-rs-v0.23.2/cua-driver-rs-0.23.2-linux-x86_64-binary.tar.gz`（monorepo 多产品）所有形状都不匹配，设了 `upstream-name` 也报 no updater（cua-driver-bin，2026-09-02）。
- **monorepo 把 stable 刻意标成 prerelease**：cua 上游用 GitHub 的 prerelease 标签防止仓库级 Latest 指针被单个产品抢走，plain SemVer 稳定版（`cua-driver-rs-v0.23.2`）全是 prerelease——除了 `tag_prefix` 过滤 nightly 系列，还必须进 `check_pre_release` 放行（cua-driver-bin，2026-09-02）。

### 上游改名（包名跟随上游时）

上游把项目整体改名（repo、release 资产名、二进制名、desktop/图标全变）时，Guix 包名跟随新名，且以下位置必须一起改——漏一处是「静默不再更新」而不是报错：

1. 包定义：`define-public` / `name` / URL（新 repo）/ 资产文件名 / `upstream-name` property。
2. `.github/workflows/auto-update.yml` 里 `guix refresh -u` 的显式包列表：refresh 按**包名**取包（该列表是白名单，不是全模块），旧名报「找不到包」被日志淹没，新名完全收不到自动更新。
3. `docs/packages.md`（`blue gen-docs` 重新生成）与 AGENTS.md 的包清单。
4. 同文件内其他包注释对该包的交叉引用（`aria2-next-bin` 的注释曾描述它为 motrix 供引擎）。

实证：motrix-next → rayburst（4.0.0，2026-09-24，issue #44）——guix refresh 与 Python updater 两层都在用已不存在的 `MotrixNext_<v>_amd64.deb` 重建 URL，404 即报「无法计算 hash」；改名后两包（rayburst-bin / aria2-next-bin）均通过 refresh dry-run 确认识别。


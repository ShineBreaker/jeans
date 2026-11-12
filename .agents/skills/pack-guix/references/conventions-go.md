# jeans 通道打包约定 — Go 打包

<!-- 2026-11-12 由 references/jeans-conventions.md 按主题拆分；内容为整段原样搬迁 -->

## Go 打包（每个依赖一个完整包，禁止 vendor 捷径）

go-build-system 是传统 **GOPATH 模式**（`GO111MODULE=off`），**没有 vendor 目录
支持**：不能把上游 vendor/ 塞进去了事，必须把**每一个 Go 依赖都打成完整的独立
包**，再作为 inputs 传入（上游 golang-xyz.scm 即此范式）。用户明确要求对照上游
最佳实践，distrobox-se 已按此重构（2026-11-12）。

依赖包集中在 `modules/jeans/packages/golang.scm`（已加 %public-modules），镜像
上游 golang-xyz.scm 的组织。需要与官方包不同的版本时，写**版本变体**，严格 follow
上游先例（`go-github-com-zitadel-oidc-v3-3.45` golang-web.scm:24282、
`go-github-com-cyphar-filepath-securejoin-0.4.1`）：

- `define-public` + `hidden-package` + `inherit` 官方包；
- **变量名**带点分版本后缀（如 `go-github-com-urfave-cli-v3-3.14`），但 **`name`
  字段保持原 import-path 名**（`go-github-com-urfave-cli-v3`）——GOPATH 模式忽略
  版本，同 import-path 的多个变体可在 store 共存；
- 注释说明为何需要这个变体（go.mod 钉的版本与官方包不一致）；
- source 用 git-fetch 钉 tag，hash 用 `guix hash -rx` 实算；`#:import-path` 与
  `#:tests?` 按需。

```scheme
(define-public go-github-com-urfave-cli-v3-3.14
  (hidden-package
   (package
     (inherit go-github-com-urfave-cli-v3)
     (name "go-github-com-urfave-cli-v3")      ; name 保持原名
     (version "3.14.0")
     (source (origin (method git-fetch)
               (uri (git-reference (url "https://github.com/urfave/cli")
                     (commit (string-append "v" version))))
               (file-name (git-file-name name version))
               (sha256 (base32 "0vk3…"))))
     (arguments (list #:import-path "github.com/urfave/cli/v3" #:tests? #f))
     (propagated-inputs '()))))
```

应用包（containers.scm 的 distrobox-se）inputs 直接列这些完整依赖包 + 官方包
（go-golang-org-x-term 等版本与 go.mod 一致时直接用官方包）。**不要**用私有
`define` 凑依赖、不要在 name 字段加版本后缀、不要用「API 兼容」近似版本替代
go.mod 钉的精确版本——这三点是 distrobox-se 旧形式被用户判为不规范的根因。
依赖的测试套件可继承运行（ini.v1 变体继承 testify native-inputs，8.3s 全 PASS）。

### 用 go-build-system 打包应用（lzsync 实证，2026-11-12）

依赖包都就位后，应用包直接用 go-build-system：unpack 按 `#:import-path` 把源码
放到 `$GOPATH/src/<import-path>`，`go install` 装进 GOBIN（= out/bin），inputs
里 name 以 `go-` 开头的包由 `setup-go-environment` union 进 GOPATH。lzsync
（games.scm）从 gnu-build-system + 内联模块 zip 改过来后实跑通过，六个坑：

- **`#:import-path` 用 module 名，不是 VCS 路径**。lzsync 的 go.mod 是
  `module lzsync`、内部 import 写 `lzsync/internal/...`，import-path 必须是
  `lzsync`（源码落 src/lzsync）；写 github.com/user/repo 会找不到包。
- **`#:go` 默认是 `(gnu packages golang)` 的 `go`（当前 1.26）**，native-inputs
  放 go-1.27 不会自动接管（PATH 里默认 go 在前）。需要新版语法/标准库（如
  encoding/json v2）时显式 `#:go go-1.27`。
- **`#:build-flags` / `#:test-flags` 的值必须是 gexp**（`#~(list "-ldflags" ...)`）。
  普通 list 会被 builder 当代码求值，报 `Wrong type to apply: "-ldflags"`。
  go-build-system 的 build 阶段先给 `-ldflags=-s -w`，build-flags 再传一次
  `-ldflags` 会覆盖它。
- **input 源码在 GOPATH 里是符号链接，Go 拒绝 embed 符号链接文件**
  （`cannot embed irregular file`）。被依赖包有 //go:embed 资源时（mygo 的
  bridge.js / *.json / *.glsl），build 前从
  `(assoc-ref inputs "<pkg>")/src/<import-path>` copy-recursively 覆盖 union
  出来的目录（先 delete-file-recursively）；或给 `#:embed-files` 正则让
  fix-embed-files 阶段实体化。
- **`#:skip-build? #t` 不跳过 check**。只提供源码的依赖包（mygo，与官方
  x-sys 同法）还要 `#:tests? #f`，否则 check 阶段跑 `go test` 撞未打包的子包
  依赖。
- **应用包的 install 阶段要自己 replace**（go-build-system 默认只装源码）：
  GOBIN 里的二进制已在 out/bin，install 里装库/图标/desktop 并 wrap-program，
  `#:install-source? #f` 关源码安装。

依赖闭包用 `go list -deps .` 实测，不要照抄 go.mod 的 indirect：lzsync 的
go.mod 列了 x/net、go-isatty、go-strftime，但 Linux 编译闭包不包含它们（只在
非 Linux 构建标签与 modernc 跨平台文件里出现），按闭包建包即可。

### `substitute-keyword-arguments` 的模式变量不要用 `_`

在 `(package ...)` 字段里嵌套展开时，`((#:test-flags _) ...)` 会报
`bad use of '_' syntactic keyword`（同样的宏在顶层最小复现却通过）。改用普通
变量名即可：

```scheme
(arguments
 (substitute-keyword-arguments (package-arguments go-modernc-org-sqlite)
   ((#:test-flags old)
    #~(list "-short" "-skip" "TestInterruptBeforeFirstStep"))))
```

sqlite 1.61.0 的该用例用 testing/synctest，asynctimerchan!=0 时 panic；保留
其余测试、只 skip 这一条。版本变体要复检上游包的测试设置是否仍适用。


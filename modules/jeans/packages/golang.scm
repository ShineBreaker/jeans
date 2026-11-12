;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-only

;;; Go 依赖包。对照上游 gnu/packages/golang-xyz.scm 的范式：每个 Go 依赖都
;;; 是一个完整的 package，消费者把它们作为 inputs 引用，而不是 vendoring 或
;;; 私有内联定义。同 import-path 的不同版本用版本变体表达——变量名带点分
;;; 版本后缀、name 字段保持原名、hidden-package 包裹（先例：
;;; go-github-com-zitadel-oidc-v3-3.45、go-github-com-cyphar-filepath-securejoin-0.4.1、
;;; go-gitlab-com-gitlab-org-api-client-go-0.116）。GOPATH 模式下版本号不参与
;;; 依赖匹配，故同名 import-path 的多个版本可在 store 并存、互不干扰。
;;;
;;; 消费者：
;;; - distrobox-se（containers.scm）：urfave/cli v3、ini.v1
;;; - lzsync（games.scm）：humanize、purego、x/sys、x/text、modernc.org
;;;   {libc,memory,sqlite} 与 go-github-com-egoist-mygo

(define-module (jeans packages golang)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix build-system go)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (gnu packages golang-build)
  #:use-module (gnu packages golang-maths)
  #:use-module (gnu packages golang-xyz))

;; distrobox-se 的 go.mod 钉 v3.14.0；官方 go-github-com-urfave-cli-v3 停在
;; 3.4.1 且被 gnu/packages 多个模块引用，不能整体升级，故立版本变体。
;; v3.14.0 的 go.mod 仅测试依赖 testify，无运行时传播依赖。
(define-public go-github-com-urfave-cli-v3-3.14
  (hidden-package
   (package
     (inherit go-github-com-urfave-cli-v3)
     (name "go-github-com-urfave-cli-v3")
     (version "3.14.0")
     (source
      (origin
        (method git-fetch)
        (uri (git-reference
              (url "https://github.com/urfave/cli")
              (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256
         (base32 "0vk3jykzs0hl33k7ww9ny9q13a86k4b9ffzvma75x1pv1fmcircv"))
        (modules '((guix build utils)))
        (snippet
         #~(begin
             ;; docs/ 有自己的 go.mod 并 import cli-altsrc，官方定义同样删除。
             (delete-file-recursively "docs")))))
     (arguments
      (list
       #:import-path "github.com/urfave/cli/v3"
       #:tests? #f))
     (propagated-inputs '()))))

;; distrobox-se 的 go.mod 钉 v1.67.3；官方 go-gopkg-in-ini-v1 是 1.67.0，
;; 差一个 patch 级。立变体精确对齐 go.mod，而非依赖「GOPATH 模式 API 兼容」
;; 的近似。继承官方包保留其 #:import-path 与测试设置。
(define-public go-gopkg-in-ini-v1-1.67.3
  (hidden-package
   (package
     (inherit go-gopkg-in-ini-v1)
     (name "go-gopkg-in-ini-v1")
     (version "1.67.3")
     (source
      (origin
        (method git-fetch)
        (uri (git-reference
              (url "https://github.com/go-ini/ini")
              (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256
         (base32 "1mcyd42a3plmj9fliscsshiyy7xpwizsjgysprc2bi3mkp65v0p4")))))))

;;; LZSync 的依赖链。lzsync 的 go.mod 钉的版本多数高于 Guix 官方：
;;; humanize 1.1.0（官方 1.0.1）、purego 0.11.1（0.9.0）、x/sys 0.49.0
;;; （0.47.0）、x/text 0.43.0（0.41.0）、memory 1.12.1（1.11.0）、libc
;;; 1.79.0（1.66.3）、sqlite 1.61.0（1.45.0）。逐一对齐 go.mod 立变体，
;;; 变体的 propagated-inputs 指向同批变体，避免 GOPATH 里同一 import-path
;;; 出现两个版本。
;;;
;;; go.mod 里另有 x/net、go-isatty、go-strftime 三个 indirect 依赖，它们
;;; 只在 mygo 的非 Linux 构建标签与 modernc 的跨平台文件里出现，不在 lzsync
;;; 的 Linux 编译闭包内（go list -deps 实测），因此不建变体、不进 inputs。

(define-public go-github-com-dustin-go-humanize-1.1
  (hidden-package
   (package
     (inherit go-github-com-dustin-go-humanize)
     (name "go-github-com-dustin-go-humanize")
     (version "1.1.0")
     (source
      (origin
        (method git-fetch)
        (uri (git-reference
              (url "https://github.com/dustin/go-humanize")
              (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256
         (base32 "0i0ak7j0rcbjpfwhx24lyn5a1q2cscjhd4wl0z17x07d0m4c3bj1")))))))

(define-public go-github-com-ebitengine-purego-0.11
  (hidden-package
   (package
     (inherit go-github-com-ebitengine-purego)
     (name "go-github-com-ebitengine-purego")
     (version "0.11.1")
     (source
      (origin
        (method git-fetch)
        (uri (git-reference
              (url "https://github.com/ebitengine/purego")
              (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256
         (base32 "1r7ivlgwn7ikifzxbp62vzdjccvh19iyill3mzqw4dgc9b0hvg15")))))))

(define-public go-golang-org-x-sys-0.49
  (hidden-package
   (package
     (inherit go-golang-org-x-sys)
     (name "go-golang-org-x-sys")
     (version "0.49.0")
     (source
      (origin
        (method git-fetch)
        (uri (git-reference
              (url "https://go.googlesource.com/sys")
              (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256
         (base32 "1g5fb3mhhhx5cyh6rwz586zq7d22prmfkc3m0cj2yqgsyiypz2jl")))))))

(define-public go-golang-org-x-text-0.43
  (hidden-package
   (package
     (inherit go-golang-org-x-text)
     (name "go-golang-org-x-text")
     (version "0.43.0")
     (source
      (origin
        (method git-fetch)
        (uri (git-reference
              (url "https://go.googlesource.com/text")
              (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256
         (base32 "0kx87mkhqvz59d63l5mh5wcjy3xkkmgbrm6prppy96kmyxn0lxnv")))))))

(define-public go-modernc-org-memory-1.12
  (hidden-package
   (package
     (inherit go-modernc-org-memory)
     (name "go-modernc-org-memory")
     (version "1.12.1")
     (source
      (origin
        (method git-fetch)
        (uri (git-reference
              (url "https://gitlab.com/cznic/memory")
              (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256
         (base32 "063i1x9xi99lcfxff4f29n08asz2w4d6y0x9xfc5zf1ry3vidyb3"))))
     (propagated-inputs
      (list go-golang-org-x-sys-0.49
            go-modernc-org-mathutil)))))

(define-public go-modernc-org-libc-1.79
  (hidden-package
   (package
     (inherit go-modernc-org-libc)
     (name "go-modernc-org-libc")
     (version "1.79.0")
     (source
      (origin
        (method git-fetch)
        (uri (git-reference
              (url "https://gitlab.com/cznic/libc")
              (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256
         (base32 "0w616yqgl2i57ii5nmw0ni30w8cahs0wwiiy20v96w8zsa2rlysx"))))
     (propagated-inputs
      (list go-github-com-dustin-go-humanize-1.1
            go-github-com-google-uuid
            go-github-com-ncruces-go-strftime
            go-github-com-remyoudompheng-bigfft
            go-golang-org-x-exp
            go-golang-org-x-sys-0.49
            go-modernc-org-mathutil
            go-modernc-org-memory-1.12)))))

(define-public go-modernc-org-sqlite-1.61
  (hidden-package
   (package
     (inherit go-modernc-org-sqlite)
     (name "go-modernc-org-sqlite")
     (version "1.61.0")
     (source
      (origin
        (method git-fetch)
        (uri (git-reference
              (url "https://gitlab.com/cznic/sqlite")
              (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256
         (base32 "007lx7jgcsxzzav0zy13s3j51d4r65jxm46z3j0810vq81l2706a"))))
     ;; 官方定义对 1.45.0 只加 "-short"；1.61.0 的 TestInterruptBeforeFirstStep
     ;; 用 testing/synctest，在 asynctimerchan!=0 的构建环境直接 panic。
     (arguments
      (substitute-keyword-arguments (package-arguments go-modernc-org-sqlite)
        ((#:test-flags old)
         #~(list "-short" "-skip" "TestInterruptBeforeFirstStep"))))
     (propagated-inputs
      (list go-github-com-dustin-go-humanize-1.1
            go-github-com-google-uuid
            go-github-com-ncruces-go-strftime
            go-github-com-remyoudompheng-bigfft
            go-golang-org-x-sys-0.49
            go-modernc-org-libc-1.79
            go-modernc-org-memory-1.12)))))

;;; mygo 是 LZSync 的 Go 后端框架（webview + 前端运行环境）。取 git checkout
;;; 而非 module zip：lzsync 还要用它的 packages/runtime/src 作为前端依赖，
;;; module zip 会剪枝非 .go 文件。
;;;
;;; #:skip-build? 与官方的 go-golang-org-x-sys 同法——这是只提供源码、由消费
;;; 者按需编译的依赖包，不单独构建。propagated-inputs 只列 lzsync 编译路径
;;; （Linux 闭包）上的依赖：顶层包只 import purego 与 x/text；audio/*、ui、
;;; internal/text 等子包用到 typesetting / go-mp3 / oggvorbis / x/image，
;;; 本通道尚未打包这些模块，当前消费者也不需要。
(define-public go-github-com-egoist-mygo
  (package
    (name "go-github-com-egoist-mygo")
    (version "0.6.3")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/egoist/mygo")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0zqy063s6pwagyd20bi7l0rf6mwgz5r7c0gp6wm1kvc4v6v8mlhs"))))
    (build-system go-build-system)
    (arguments
     (list #:import-path "github.com/egoist/mygo"
           #:skip-build? #t
           ;; 测试集覆盖 audio/ui/markdown 等未打包子包，靠 network 与
           ;; typesetting/x-image 等模块；本包只提供源码供消费者编译。
           #:tests? #f))
    (propagated-inputs
     (list go-github-com-ebitengine-purego-0.11
           go-golang-org-x-text-0.43))
    (home-page "https://github.com/egoist/mygo")
    (synopsis "Go framework for desktop applications with a webview frontend")
    (description "mygo builds desktop applications from a Go backend and a web
frontend.  It embeds the system webview, exposes the backend to the frontend
runtime, and provides dialogs, menus, clipboard, window state and file system
APIs.")
    (license license:expat)))

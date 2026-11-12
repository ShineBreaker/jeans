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

(define-module (jeans packages golang)
  #:use-module (guix build-system go)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix packages)
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
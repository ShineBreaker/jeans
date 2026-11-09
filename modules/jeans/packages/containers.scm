;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-only

;;; 容器生态工具。目前只有 distrobox 的用户 fork。

;;; Packing notes (kept out of the descriptions on purpose):
;;;
;;; - 上游 distrobox 自 2.0.0-rc 起从 shell 脚本整体重写为 Go（cmd/ +
;;;   internal/ + pkg/），Guix 官方的 distrobox 还停在 1.8.2.4 的 shell 版
;;;   （copy-build-system 跑 ./install）。源码结构、build-system、inputs
;;;   全不相同，inherit 上游包定义没有意义，只能从零打包。
;;; - 跟踪 ShineBreaker/distrobox，相对上游 main (a48297c) 领先 6 个
;;;   commit，都是 Guix 场景定制：enter 时丢弃指向宿主-only store 路径的
;;;   环境变量、create 的 --home-src、enter 的 --env-blacklist、export
;;;   注册 URL scheme handler、host-exec 转发显示环境变量给 GUI 启动器、
;;;   helper 脚本绑定源避开内容寻址 store 路径。
;;; - go.mod 要求 urfave/cli v3.14.0，Guix 官方 golang-xyz 停在 3.4.1，且
;;;   该符号被 gnu/packages 多个模块引用，不能整体升级，故按相同
;;;   import-path 另立一个带版本后缀的包。
;;; - go-build-system 跑在 GO111MODULE=off 的 GOPATH 模式下：按 store 项名
;;;   的 go- 前缀识别 Go 依赖、按 #:import-path 决定解包位置，版本号不参与
;;;   匹配，所以并存的同名 import-path 版本互不干扰。
;;; - x/term 0.45.0、x/sys 0.47.0 与 fork 的 go.mod 完全一致；ini.v1 官方是
;;;   1.67.0（fork 要 1.67.3，差一个 patch 级，GOPATH 模式下 API 兼容），
;;;   直接用官方包。testify 与 go.yaml.in/yaml/v3 只被测试代码引用，本包
;;;   关测试，两者都不需要。
;;; - main 包在 cmd/distrobox 子目录，用 #:unpack-path 把源码放到模块根、
;;;   #:import-path 指向 cmd/distrobox（参照 go-github-com-davecgh-go-spew）。
;;; - distrobox-init / -export / -host-exec 三个脚本已被 go:embed 进二进制，
;;;   Makefile 仍单独安装它们是为了让容器内直接调用；它们在容器里跑，容器
;;;   与宿主不共享 /gnu/store，shebang 必须回到裸 #!/bin/sh。
;;; - -se 后缀是本通道的记号，标识「跟踪我们自己的 fork 而非上游发布线」，
;;;   与 waydroid-helper-se 同一口径；$out 下的程序名、man、completions、
;;;   图标一律用上游原名（distrobox、distrobox-init、terminal-distrobox-icon）。

(define-module (jeans packages containers)
  #:use-module (guix build-system go)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix packages)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages golang-build)
  #:use-module (gnu packages golang-xyz)
  #:use-module (gnu packages containers))

;;; urfave/cli v3.14.0，distrobox 的 go.mod 要求此版本。理由见文件头说明。
;;; 私有定义：它是 distrobox-se 的实现细节，不属于通道对外提供的包。
(define go-github-com-urfave-cli-v3-314
  (package
    (inherit go-github-com-urfave-cli-v3)
    (name "go-github-com-urfave-cli-v3-314")
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
      #:tests? #f))))

(define-public distrobox-se
  (let ((commit "3dc3b9ef7eafa8bb93235223134b94deefb1866d")
        (revision "0"))
    (package
      (name "distrobox-se")
      (version (git-version "2.0.0" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/ShineBreaker/distrobox")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "05wqs12chrh0pzfgzpd0fcpzdv0axd79gh5h1jxxmly2knngwiwq"))))
      (build-system go-build-system)
      (arguments
       (list
        #:unpack-path "github.com/89luca89/distrobox"
        #:import-path "github.com/89luca89/distrobox/cmd/distrobox"
        #:install-source? #f
        ;; 测试要 testify，且 e2e 需要真起容器，构建环境两者皆无。
        #:tests? #f
        #:build-flags
        #~(list (string-append
                 "-ldflags=-X "
                 "github.com/89luca89/distrobox/pkg/version.Version="
                 #$version))
        #:phases
        #~(modify-phases %standard-phases
            (add-before 'build 'materialize-go-dependency-symlinks
              (lambda _
                ;; go-build-system 的 union 把 Go 依赖以符号链接树形式放进
                ;; $GOPATH/src，而 go:embed 不跟随符号链接：urfave/cli v3 的
                ;; completion.go 嵌入 autocomplete/ 目录，符号链接形态下报
                ;; "contains no embeddable files"。#:embed-files 只覆盖被
                ;; 构建包自身的 embed 文件，依赖侧只能在这里物化。做法与
                ;; go-build-system 的 fix-embed-files 相同，只是不限定文件名。
                (for-each
                 (lambda (file)
                   (when (eq? (stat:type (lstat file)) 'symlink)
                     (let ((target (readlink file)))
                       (delete-file file)
                       (copy-recursively target file))))
                 (find-files (string-append (getenv "GOPATH") "/src")))))
            (add-before 'build 'restore-container-script-shebangs
              (lambda* (#:key unpack-path #:allow-other-keys)
                ;; patch-source-shebangs 把这三个容器侧脚本的 shebang 指到了
                ;; store 里的 bash，而它们在容器内执行、容器不共享 /gnu/store：
                ;; 既污染 go:embed 嵌进二进制的副本，也让装到 $out/bin 的副本
                ;; 不可用。构建前在源码树里还原，两处一起修正。
                (with-directory-excursion
                    (string-append (getenv "GOPATH") "/src/" unpack-path
                                   "/internal/inside-distrobox/assets")
                  (for-each
                   (lambda (script)
                     (chmod script #o755)
                     (substitute* script (("#!.*/bin/sh") "#!/bin/sh\n")))
                   '("distrobox-init" "distrobox-export"
                     "distrobox-host-exec")))))
            (add-after 'install 'install-support-files
              (lambda* (#:key outputs unpack-path #:allow-other-keys)
                ;; build 阶段不切目录，这里显式回到源码根再找辅助文件。
                (let ((out (assoc-ref outputs "out")))
                  (with-directory-excursion
                      (string-append (getenv "GOPATH") "/src/" unpack-path)
                    ;; build 阶段已把二进制装进 $out/bin，这里补安装辅助文件。
                    (for-each
                     (lambda (script)
                       (install-file
                        (string-append "internal/inside-distrobox/assets/" script)
                        (string-append out "/bin")))
                     '("distrobox-init" "distrobox-export" "distrobox-host-exec"))
                    ;; shell 时代的 distrobox-<子命令> 入口，Makefile 的
                    ;; V1_SUBCOMMANDS 同款（ls 与 list 是兼容性别名）。
                    (for-each
                     (lambda (sub)
                       (symlink "distrobox"
                                (string-append out "/bin/distrobox-" sub)))
                     '("assemble" "create" "enter" "ephemeral"
                       "generate-entry" "ls" "list" "rm" "stop" "upgrade"))
                    (for-each
                     (lambda (man)
                       (install-file man (string-append out "/share/man/man1")))
                     (find-files "man/man1" "\\.1$"))
                    (mkdir-p (string-append out
                                            "/share/bash-completion/completions"))
                    (install-file "completions/bash/distrobox"
                                  (string-append out
                                                 "/share/bash-completion/completions"))
                    (mkdir-p (string-append out "/share/zsh/site-functions"))
                    (install-file "completions/zsh/_distrobox"
                                  (string-append out
                                                 "/share/zsh/site-functions"))
                    (install-file "icons/terminal-distrobox-icon.svg"
                                  (string-append out
                                                 "/share/icons/hicolor/scalable/apps"))
                    (for-each
                     (lambda (png)
                       ;; 形如 icons/hicolor/128x128/apps/…，第三级目录名
                       ;; 本身就是 "128x128"，直接用作目标子目录。
                       (let* ((size (basename (dirname (dirname png))))
                              (dir (string-append out "/share/icons/hicolor/"
                                                  size "/apps")))
                         (mkdir-p dir)
                         (copy-file png (string-append dir "/" (basename png)))))
                     (find-files "icons/hicolor" "\\.png$"))
                    #t))))
            (add-after 'patch-shebangs 'unpatch-shebangs
              (lambda* (#:key outputs #:allow-other-keys)
                ;; patch-shebangs 跑在 install 之后，会把这三个容器侧脚本的
                ;; shebang 指到 store 里的 bash；它们在容器内执行、容器不共享
                ;; /gnu/store，必须改回裸 /bin/sh。
                (let ((out (assoc-ref outputs "out")))
                  (for-each
                   (lambda (script)
                     (substitute* (string-append out "/bin/" script)
                       (("#!.*/bin/sh") "#!/bin/sh\n")))
                   '("distrobox-init" "distrobox-export"
                     "distrobox-host-exec")))))
            (add-after 'unpatch-shebangs 'wrap-distrobox
              (lambda* (#:key inputs outputs #:allow-other-keys)
                (wrap-program (string-append (assoc-ref outputs "out")
                                             "/bin/distrobox")
                  `("PATH" ":" prefix
                    ,(list (string-append (assoc-ref inputs "podman")
                                          "/bin")))))))))
      (inputs
       (list bash-minimal               ; wrap-program 生成 wrapper 用
             go-github-com-urfave-cli-v3-314
             go-golang-org-x-term
             go-gopkg-in-ini-v1
             podman))
      (home-page "https://github.com/ShineBreaker/distrobox")
      (synopsis "Create and start containers highly integrated with the hosts")
      (description
       "Distrobox is a fancy wrapper around Podman or Docker to create and
start containers highly integrated with the hosts.")
      ;; fork 不打 tag，按 let + git-version 结构交给自动更新追踪 commit。
      (properties `((with-latest-git-commit . #t)))
      (license license:gpl3))))

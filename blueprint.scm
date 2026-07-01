;;; blueprint.scm --- BLUE 任务运行器（替代 maak.scm）
;;;
;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-only
;;;
;;; Commentary:
;;;
;;; 这是 jeans 通道的 BLUE 蓝图文件（blueprint）。
;;;
;;; BLUE（Build Language User Extensible）是一个用 Guile Scheme 编写的通用
;;; 构建系统。本文件把原先 maak.scm 里的任务（task）迁移成 BLUE 的命令
;;; （command），并新增了一个自动生成 docs/packages.md 的命令。
;;;
;;; 使用方法（在仓库根目录执行）：
;;;
;;;   blue --list            列出所有可用命令
;;;   blue help <命令>       查看某条命令的详细帮助
;;;   blue build <包名> ...  用 guix 构建包
;;;   blue upgrade           检查所有包的上游更新
;;;   blue import-crate <crate>[@版本]
;;;                          从 crates.io 导入 Rust crate 源码
;;;   blue gen-docs          根据 modules/ 里的包定义重新生成 docs/packages.md
;;;
;;; BLUE 的心智模型：
;;;   - 一份蓝图由若干 (blueprint ...) 表达式描述，包含 commands、
;;;     buildables、configuration、testables 等字段。
;;;   - 每条命令用 (define-command (name arguments) ((属性 ...)) body ...)
;;;     定义。其中 (invoke "名字") 决定了命令行里输入的名字。
;;;   - 本仓库的命令大多是「跑一条 shell 命令」式的任务，所以用
;;;     (blue subprocess) 的 popen 来执行子进程（相当于 maak 里的 `$`）。
;;;
;;; 详见 BLUE 官方文档：https://codeberg.org/lapislazuli/blue

;; ─── 模块导入 ────────────────────────────────────────────────────────────
;;;
;; blueprint 文件运行在一个只导入了 (guile) 的用户模块里，所以需要显式
;; 把要用到的 BLUE 模块拉进来。
(use-modules
 (blue subprocess)        ; popen / fork-and-wait：执行子进程
 (blue types blueprint)   ; blueprint 表达式
 (blue types command)     ; define-command 宏
 (ice-9 format)           ; format 格式化输出
 (srfi srfi-1)            ; list 工具：fold 等

 ;; BLUE 的日志工具：progress 打印进度，warning!/hint! 打印分级提示。
 ;; 这里用 #:prefix log: 给它们加上前缀，避免和 Guile 内建冲突。
 ((blue utils logging) #:prefix log:))

;; ─── 项目级路径常量 ──────────────────────────────────────────────────────
;;;
;; 把所有路径集中放在这里，方便以后改动。注意它们都是相对仓库根目录的
;; 相对路径，blueprint 默认就在仓库根目录运行。

;; 检查更新的 Python 脚本所在的 manifest（guix shell 环境描述）
(define manifest "./scripts/check-updates/manifest.scm")
;; 自动检查上游版本的 Python 脚本
(define update-script "./scripts/check-updates/update_versions.py")
;; 包定义所在目录
(define packages-dir "./modules/jeans/packages/")
;; rust-crates.scm 路径（import-crate 要往里插入）
(define rust-crates "./modules/jeans/packages/rust-crates.scm")
;; 要生成的包清单文档
(define packages-doc "./docs/packages.md")
;; gen-docs 实际调用的辅助 Scheme 脚本
(define gen-docs-script "./scripts/gen-docs.scm")


;; ─── 辅助函数 ────────────────────────────────────────────────────────────

;;; 把字符串列表拼成一条命令交给 shell 执行，并返回退出码。
;;; 之所以走 "sh -c" 是因为很多任务需要管道、重定向等 shell 特性
;;; （比如 import-crate 用了 awk 管道）。popen 的第二个参数是参数列表。
(define (run-shell command-string)
  "通过 `sh -c' 执行 COMMAND-STRING，返回子进程退出状态。"
  (popen "sh" (list "-c" command-string)))


;; ════════════════════════════════════════════════════════════════════════
;; 命令 1：build —— 用 guix 构建包
;; ════════════════════════════════════════════════════════════════════════
;;
;; 与 maak 不同，BLUE 会把命令行里命令名之后的位置参数原样传进
;; `arguments'（一个字符串列表），所以我们不用再自己去解析
;; (command-line)，直接用 arguments 即可。

(define-command (build-command arguments)
  ;; 属性块：(invoke ...) 是命令名；synopsis/help 是帮助文本。
  ;; load-configuration-policy 设为 'no：本命令不需要 BLUE 的配置系统。
  ((invoke "build")
   (category 'jeans)
   (load-configuration-policy 'no)
   (synopsis "用 guix 构建包")
   (help "[PACKAGE] ...
用 guix build 构建一个或多个 jeans 包。

用法:
    blue build my-package
    blue build pkg-a pkg-b
等价于: guix build --load-path=./modules <PACKAGE> ..."))
  (if (null? arguments)
      (begin
        (log:warning! "未提供包名。用法: blue build <package> ...")
        #f)
      (let ((cmd (string-append "guix build --load-path=./modules "
                                (string-join arguments " "))))
        (log:progress "构建中: ~a" cmd)
        (zero? (run-shell cmd)))))


;; ════════════════════════════════════════════════════════════════════════
;; 命令 2：upgrade —— 检查所有包的上游更新
;; ════════════════════════════════════════════════════════════════════════

(define-command (upgrade-command arguments)
  ((invoke "upgrade")
   (category 'jeans)
   (load-configuration-policy 'no)
   (synopsis "检查所有包的上游更新")
   (help "扫描 modules/jeans/packages/ 下所有包，通过 GitHub API 检查
是否有新版本，并自动更新版本号与 hash。

需要在 scripts/check-updates/manifest.scm 描述的环境里运行；
本命令会用 guix shell 自动准备好该环境。"))
  (log:progress "正在检查包更新…")
  (zero?
   (run-shell
    (string-append "guix shell --manifest=" manifest
                   " -- python3 " update-script))))


;; ════════════════════════════════════════════════════════════════════════
;; 命令 3：import-crate —— 从 crates.io 导入 Rust crate 源码
;; ════════════════════════════════════════════════════════════════════════
;;
;; 这个命令把一个 crate 的 crate-source 定义插入到 rust-crates.scm 的
;; ssss-separator 分隔行之前。流程：
;;   1. 用 guix import crate 生成定义，写到临时文件；
;;   2. 用 awk 把临时文件内容插到分隔行前面；
;;   3. 替换原文件，删除临时文件。

(define-command (import-crate-command arguments)
  ((invoke "import-crate")
   (category 'jeans)
   (load-configuration-policy 'no)
   (synopsis "从 crates.io 导入 Rust crate 源码到 rust-crates.scm")
   (help "CRATE[@VERSION]
把一个 Rust crate 的 crate-source 定义插入 rust-crates.scm 的
ssss-separator 分隔行之前。

用法:
    blue import-crate nix-ld
    blue import-crate embedded-io@0.6.1

会自动检测当前目录下的 ./Cargo.lock 作为 lockfile。"))
  (let ((spec (and (pair? arguments) (car arguments))))
    (cond
     ((not spec)
      (log:warning! "未提供 crate 名。用法: blue import-crate <name>[@version]")
      #f)
     (else
      (let* (;; 若存在 ./Cargo.lock，则把 --lockfile 参数带上。
             (lockfile-arg
              (if (file-exists? "./Cargo.lock")
                  " --lockfile=./Cargo.lock"
                  ""))
             ;; 临时文件：先把 guix import 的输出写到这里
             (tmp-file "/tmp/blue-crate-import.scm")
             ;; 第 1 步：生成定义
             (gen-cmd
              (string-append "guix import crate" lockfile-arg
                             " " spec " > " tmp-file))
             ;; 第 2 步：用 awk 把临时文件插到分隔行前
             ;;   /ssss-separator/ 匹配到分隔行时：先 cat 临时文件，
             ;;   再 print 当前行，然后 next 跳到下一行。
             (insert-cmd
              (string-append
               "awk '/ssss-separator/{system(\"cat " tmp-file
               "\");print;next}1' " rust-crates
               " > " rust-crates ".tmp"))
             ;; 第 3 步：用临时文件覆盖原文件
             (replace-cmd (string-append "mv " rust-crates ".tmp " rust-crates))
             ;; 第 4 步：清理临时文件
             (cleanup-cmd (string-append "rm -f " tmp-file)))
        ;; ↑ 注意上面只闭合到「绑定列表」为止；下面的代码才是 let* 的执行体
        (log:progress "导入 crate: ~a" spec)
        (log:hint! "  1) 生成定义…")
        (run-shell gen-cmd)
        (log:hint! "  2) 插入到 rust-crates.scm …")
        (run-shell insert-cmd)
        (log:hint! "  3) 替换原文件…")
        (run-shell replace-cmd)
        (log:hint! "  4) 清理临时文件…")
        (run-shell cleanup-cmd)
        (log:progress "完成。")
        #t)))))


;; ════════════════════════════════════════════════════════════════════════
;; 命令 4：gen-docs —— 重新生成 docs/packages.md（新增功能）
;; ════════════════════════════════════════════════════════════════════════
;;
;; 为什么需要单独一条命令？
;;   以前 docs/packages.md 是手工维护的，加包 / 改描述后很容易忘记同步，
;;   导致文档和实际包定义脱节。这条命令通过「直接加载 Guix 包模块、读出
;;   每个包的 name 和 synopsis」来生成清单，保证文档始终与代码一致。
;;
;; 为什么不直接在 blueprint 里做内省？
;;   blueprint 运行在 BLUE 提供的用户模块里，只导入了 (guile)，无法直接
;;   resolve guix / jeans 的包模块（会缺 gcrypt 等依赖）。所以这里通过
;;   `guix repl` 运行一个独立的辅助脚本 scripts/gen-docs.scm，让它在拥有
;;   完整 Guix 环境的 REPL 里做内省、把 Markdown 写到 stdout，本命令再
;;   把 stdout 重定向到 docs/packages.md。
;;
;; 该辅助脚本不存在时，命令会给出清晰提示，而不是直接报错。

(define-command (gen-docs-command arguments)
  ((invoke "gen-docs")
   (category 'jeans)
   (load-configuration-policy 'no)
   (synopsis "根据 modules/ 里的包定义重新生成 docs/packages.md")
   (help "扫描 modules/jeans/packages/ 下所有包模块，读取每个包的
name 和 synopsis，重新生成 docs/packages.md。

加载失败的模块（例如依赖未满足）会被跳过并给出警告。
rust-crates.scm 只含 crate-source 定义，不是包，故不在扫描之列。"))
  (cond
   ((not (file-exists? gen-docs-script))
    (log:warning! "找不到辅助脚本 ~a" gen-docs-script)
    (log:hint! "请先创建该脚本（见仓库说明）。")
    #f)
   (else
    (log:progress "正在重新生成 ~a …" packages-doc)
    (let ((cmd (string-append "guix repl " gen-docs-script
                              " > " packages-doc)))
      (if (zero? (run-shell cmd))
          (begin
            (log:progress "已生成 ~a" packages-doc)
            #t)
          (begin
            (log:warning! "生成失败，请检查上面的 guix repl 输出。")
            #f))))))


;; ════════════════════════════════════════════════════════════════════════
;; 组装蓝图：把上面定义的命令注册进去
;; ════════════════════════════════════════════════════════════════════════

(blueprint
 (commands
  (list
   build-command
   upgrade-command
   import-crate-command
   gen-docs-command)))

;;; gen-docs.scm --- 重新生成 docs/packages.md 的辅助脚本
;;;
;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-only
;;;
;;; Commentary:
;;;
;;; 本脚本由 blueprint.scm 的 `gen-docs` 命令通过 `guix repl` 调用。
;;; 它把 stdout 当成输出文件，直接打印 Markdown 内容；blueprint 命令
;;; 再用 shell 重定向 `> docs/packages.md` 把它写盘。
;;;
;;; 为什么是独立脚本？
;;;   blueprint.scm 运行在 BLUE 的用户模块里（只有 (guile)），无法直接
;;;   加载 Guix 包模块。`guix repl` 则提供了一个完整的 Guix 环境，可以
;;;   resolve jeans / gnu 的包模块并对它们做内省。
;;;
;;; 用法（一般无需手动执行，用 `blue gen-docs` 即可）：
;;;
;;;   guix repl scripts/gen-docs.scm > docs/packages.md

(use-modules
 (gnu)                       ; 让 (gnu) 的所有包可用，满足 jeans 模块的依赖
 (guix)                      ; package?、package-name、package-synopsis
 (srfi srfi-1)               ; filter-map、sort
 (ice-9 exceptions)          ; with-exception-handler
 (ice-9 format))             ; format

;; ─── 要扫描的包模块 ──────────────────────────────────────────────────────
;;;
;; 按字母顺序列出。注意：
;;   - rust-crates.scm 只含 crate-source / cargo-inputs 定义，不是包，跳过。
;;   - 新增类别文件后，把它的模块加到这里即可。
(define %package-modules
  '((jeans packages agent)
    (jeans packages browser)
    (jeans packages desktop)
    (jeans packages emacs-xyz)
    (jeans packages fonts)
    (jeans packages games)
    (jeans packages hardware)
    (jeans packages nix-ld)
    (jeans packages theme)
    (jeans packages tools)))

;; ─── 输出文档的固定头部 ─────────────────────────────────────────────────
;;;
;; SPDX 版权头 + 标题。每次重新生成都会原样写出。
(define %header
  "\
<!-- SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com> -->

<!-- SPDX-License-Identifier: GPL-3.0-only -->

# jeans 通道可用包清单

本文件由 `blue gen-docs` 根据 `modules/jeans/packages/` 下的包定义自动生成。
请勿手动编辑——所有改动都会在下一次生成时被覆盖。

")

;; ─── 把异常渲染成单行文字（用于警告信息） ───────────────────────────────
;;;
;; 直接用 (exception-message exn) 有时会拿到带 ~S 这类格式占位符的原始
;; 模板（而不是格式化后的文字）。这里用 with-output-to-string + Guile
;; 自带的 print-exception 渲染，再压成一行，得到对用户更友好的提示。
(define (exception->one-line exn)
  (call-with-output-string
   (lambda (port)
     (print-exception port #f (exception-kind exn) (exception-args exn)))))

;; ─── 从单个模块里提取包列表 ─────────────────────────────────────────────
;;;
;; 返回 (symbol . package) 对的列表，按 package-name 升序排列。
;; 模块加载失败时返回 '() 并向 stderr 打印警告（例如 agent.scm 在迁移
;; 过程中依赖未满足时会被跳过，不会让整个生成中断）。
(define (packages-in-module module-name)
  (with-exception-handler
   (lambda (exn)
     (format (current-error-port)
             "警告: 跳过模块 ~a（加载失败: ~a)\n"
             module-name
             (string-trim-right (exception->one-line exn) #\newline))
     '())
   (lambda ()
     (let ((mod (resolve-interface module-name)))
       (sort
        (filter-map
         (lambda (binding)
           ;; binding = (symbol . variable)；interface 里的都是 public 绑定。
           (let* ((sym (car binding))
                  (val (and (module-bound? mod sym)
                            (module-ref mod sym))))
             (and (package? val)
                  (cons sym val))))
         (module-map (lambda (s v) (cons s v)) mod))
        (lambda (a b)
          (string<? (package-name (cdr a))
                    (package-name (cdr b)))))))
   #:unwind? #t))

;; ─── 把单个模块的包渲染成一段 Markdown 表格 ────────────────────────────
(define (render-module module-name port)
  (let ((pkgs (packages-in-module module-name)))
    (unless (null? pkgs)
      ;; 模块名作为三级标题，例如 ### (jeans packages tools)
      (format port "### ~a\n\n" module-name)
      (format port "| Package | Description |\n")
      (format port "| --- | --- |\n")
      (for-each
       (lambda (binding)
         (let ((pkg (cdr binding)))
           (format port "| `~a` | ~a |\n"
                   (package-name pkg)
                   (package-synopsis pkg))))
       pkgs)
      (format port "\n"))))

;; ─── 主流程 ─────────────────────────────────────────────────────────────
;;;
;; 先写头部，再逐个模块写表格。表格之间用空行分隔。
(display %header)
(for-each (lambda (m) (render-module m (current-output-port)))
          %package-modules)

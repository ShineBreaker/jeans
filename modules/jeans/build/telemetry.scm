;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-only

;;; build 侧：把遥测关闭开关注入预编译包的 wrapper。
;;;
;;; 为什么在 wrapper 上做：预编译包不能重编译，而这些上游只读一次进程环境；
;;; wrapper 是唯一「随包移动、且在用户直接调用 bin/ 程序时也生效」的注入点。
;;; 变量表与 shell 片段在 (jeans telemetry)，host 侧 home 服务共用同一张表。
;;;
;;; 注入形态（见 telemetry-off-shell-snippet）：
;;;
;;;   export DO_NOT_TRACK="${DO_NOT_TRACK:-1}"
;;;
;;; `${VAR:-default}' 而不是硬赋值：用户 export DO_NOT_TRACK=0 / OTEL_SDK_DISABLED=false
;;; 即覆盖默认值，包的语义只是「默认关」。
;;;
;;; 只在 bin/ 下以 "#!" 开头的普通文件上动手；符号链接、ELF、非脚本一律跳过。
;;; 插入点是最后一个顶层 `exec' 行之前——本通道 binary/electron build-system
;;; 生成的 wrapper 都以 `exec ... "$@"' 收尾（wrap-program 的 exec -a 同款），
;;; 找不到 exec 行时退化为追加到文件末尾。
;;;
;;; #:telemetry-opt-out? #f 可整包关掉。phase 自带 #:telemetry-variables 键，
;;; 但基座不把它从包定义透传下来（build 侧多一个键就多一处 plumbing）；
;;; 要追加厂商私有键的包，自己用 (jeans telemetry) 的 telemetry-off-shell-snippet
;;; 拼 wrapper（agent.scm 的 thinkrail/github-copilot 即此做法）。

(define-module (jeans build telemetry)
  #:use-module (guix build utils)
  #:use-module (ice-9 binary-ports)
  #:use-module (ice-9 ftw)
  #:use-module (ice-9 match)
  #:use-module (ice-9 rdelim)
  #:use-module (rnrs bytevectors)
  #:use-module (srfi srfi-1)
  #:use-module (jeans telemetry)
  #:export (telemetry-opt-out-phase
            auto-update-opt-out-phase))

(define (read-shebang file)
  "读 FILE 头 128 字节里的第一行（shebang）；不是 \"#!\" 开头时返回 #f。
按字节读并截断，避免把 ELF/大二进制整块读进内存。"
  (let* ((port (open-file file "rb"))
         (bv (get-bytevector-n port 128)))
    (close-port port)
    (and bv
         (>= (bytevector-length bv) 2)
         (= (bytevector-u8-ref bv 0) (char->integer #\#))
         (= (bytevector-u8-ref bv 1) (char->integer #\!))
         (let* ((len (bytevector-length bv))
                (end (or (list-index (lambda (i)
                                       (= (bytevector-u8-ref bv i) 10))
                                     (iota len))
                         len)))
           ;; shebang 恒为 ASCII：逐字节转 char，避开 utf8->string 的签名差异。
           (list->string
            (map (lambda (i) (integer->char (bytevector-u8-ref bv i)))
                 (iota end)))))))

(define (script-file? file)
  "FILE 是否为 shell 脚本（shebang 指向 sh/bash）。
只动 shell wrapper：wrap-program 生成的 wrapper 恒为 bash，而 bin/ 下上游自带
的 python/node/perl 脚本一旦被塞进 export 行就会坏。"
  (let ((line (read-shebang file)))
    (and line
         (if (or (string-contains line "bash")
                 (string-suffix? "/sh" line))
             #t
             #f))))

(define (exec-line? line)
  "LINE 是否顶层 exec 调用（`exec '、`exec\t' 或整行 `exec'）。"
  (and (string-prefix? "exec" line)
       (or (= (string-length line) 4)
           (char-whitespace? (string-ref line 4)))))

(define (last-exec-index lines)
  "最后一个 exec 行的下标；没有则 #f。"
  (let loop ((rest lines) (index 0) (found #f))
    (cond ((null? rest) found)
          ((exec-line? (car rest)) (loop (cdr rest) (1+ index) index))
          (else (loop (cdr rest) (1+ index) found)))))

(define (read-lines file)
  (call-with-input-file file
    (lambda (port)
      (let loop ((line (read-line port)) (acc '()))
        (if (eof-object? line)
            (reverse acc)
            (loop (read-line port) (cons line acc)))))))

(define (write-lines file lines)
  (make-file-writable file)
  (call-with-output-file file
    (lambda (port)
      (for-each (lambda (line)
                  (display line port)
                  (newline port))
                lines))))

(define (idempotency-marker variables)
  "第一条变量的 export 形态；文件里已有它就说明这张表注入过。"
  (let ((name (caar variables)))
    (format #f "~a=\"${~a:-" name name)))

(define* (inject-opt-out file #:key (variables %telemetry-off-variables))
  "把 VARIABLES 的 export 块插进 script FILE；已注入过时返回 #f（幂等）。"
  (let ((lines (read-lines file)))
    (if (any (lambda (line)
               (string-contains line (idempotency-marker variables)))
             lines)
        #f
        (let* ((anchor (or (last-exec-index lines) (length lines)))
               (block (remove string-null?
                              (string-split
                               (telemetry-off-shell-snippet
                                #:variables variables)
                               #\newline))))
          (write-lines file (append (take lines anchor)
                                    block
                                    (drop lines anchor)))
          #t))))

(define (to-abs out path)
  "PATH 是输出内相对路径时拼成绝对路径，绝对路径原样返回。"
  (if (string-prefix? "/" path)
      path
      (string-append out "/" path)))

(define (resolve-symlink file)
  "跟随 FILE 的符号链接链（相对目标按链所在目录解析），超过 10 层或链断时
返回最后到达的路径。"
  (let loop ((file file) (depth 0))
    (let ((st (false-if-exception (lstat file))))
      (cond ((not st) file)
            ((not (eq? 'symlink (stat:type st))) file)
            ((> depth 10) file)
            (else
             (let ((target (readlink file)))
               (loop (if (string-prefix? "/" target)
                         target
                         (string-append (dirname file) "/" target))
                     (1+ depth))))))))

(define (directory-entries dir)
  "DIR 下的顶层条目名；DIR 不存在时返回 '()。"
  (if (file-exists? dir)
      (scandir dir (lambda (entry)
                     (not (member entry '("." "..")))))
      '()))

(define (wrap-plan-targets out plan)
  "把 #:wrap-plan 里每个 PROG 解成输出内绝对路径；PLAN 非列表时返回 '()。"
  (if (list? plan)
      (filter-map (match-lambda
                    ((? string? prog) (to-abs out prog))
                    ((prog . _) (to-abs out prog))
                    (_ #f))
                  plan)
      '()))

(define* (inject-opt-out-phase
          #:key outputs wrap-plan variables label
          (enabled #t)
          #:allow-other-keys)
  "把 VARIABLES 注入输出里每个 shell wrapper；LABEL 只用于日志。

只看 bin/ 与 #:wrap-plan 的目标：整目录扫 lib/、share/ 会把 node_modules
与上游自带脚本一并改写，代价远大于收益。"
  (when enabled
    (let* ((out (assoc-ref outputs "out"))
           (candidates
            (delete-duplicates
             (append
              (map (lambda (base) (string-append out "/bin/" base))
                   (directory-entries (string-append out "/bin")))
              (wrap-plan-targets out wrap-plan))
             string=?)))
      (for-each
       (lambda (candidate)
         (let ((file (resolve-symlink candidate)))
           ;; 符号链接可能指向别的 store item（共享 launcher）：只在输出内部
           ;; 动手，跨包改写会被 store 的只读权限挡住，也不该改。
           (when (and (string-prefix? (string-append out "/") file)
                      (file-exists? file)
                      (eq? 'regular (stat:type (stat file)))
                      (script-file? file)
                      (inject-opt-out file #:variables variables))
             (format #t "~a: opt-out injected into ~a~%"
                     label
                     (substring file (1+ (string-length out)))))))
       candidates)))
  #t)

(define* (telemetry-opt-out-phase
          #:key outputs wrap-plan
          (telemetry-opt-out? #t)
          (telemetry-variables %telemetry-off-variables)
          #:allow-other-keys)
  "给 wrapper 注入默认关闭遥测的 export 块（变量表见 (jeans telemetry)）。"
  (inject-opt-out-phase #:label "telemetry"
                        #:enabled telemetry-opt-out?
                        #:variables telemetry-variables
                        #:outputs outputs
                        #:wrap-plan wrap-plan))

(define* (auto-update-opt-out-phase
          #:key outputs wrap-plan
          (auto-update-opt-out? #t)
          (update-variables %update-optout-variables)
          #:allow-other-keys)
  "给 wrapper 注入默认关闭应用内自更新的 export 块。

store 只读，自更新必然失败，还会先联网检查一遍；升级由 Guix 拥有。"
  (inject-opt-out-phase #:label "auto-update"
                        #:enabled auto-update-opt-out?
                        #:variables update-variables
                        #:outputs outputs
                        #:wrap-plan wrap-plan))

;;; telemetry.scm ends here

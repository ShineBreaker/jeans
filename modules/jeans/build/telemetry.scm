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
  #:use-module (ice-9 match)
  #:use-module (ice-9 rdelim)
  #:use-module (srfi srfi-1)
  #:use-module (jeans telemetry)
  #:export (telemetry-opt-out-phase))

(define (script-file? file)
  "FILE 是否以 \"#!\" 开头的脚本（按字节读，不碰 ELF 的解码问题）。"
  (let* ((port (open-file file "rb"))
         (first (get-u8 port))
         (second (get-u8 port)))
    (close-port port)
    (and first second
         (= first (char->integer #\#))
         (= second (char->integer #\!)))))

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

(define* (inject-telemetry-opt-out file #:key (variables %telemetry-off-variables))
  "把遥测关闭 export 块插进 script FILE；已有同名块时返回 #f（幂等）。"
  (let ((lines (read-lines file)))
    (if (any (lambda (line)
               (string-contains line "DO_NOT_TRACK=\"${DO_NOT_TRACK:-"))
             lines)
        #f
        (let* ((anchor (or (last-exec-index lines) (length lines)))
               (block (remove string-null?
                              (string-split
                               (telemetry-off-shell-snippet #:variables variables)
                               #\newline))))
          (write-lines file (append (take lines anchor)
                                    block
                                    (drop lines anchor)))
          #t))))

(define* (telemetry-opt-out-phase
          #:key outputs
          (telemetry-opt-out? #t)
          (telemetry-variables %telemetry-off-variables)
          #:allow-other-keys)
  "给 $out/bin 下每个 shell wrapper 注入默认关闭遥测的环境变量。"
  (when telemetry-opt-out?
    (let* ((out (assoc-ref outputs "out"))
           (bin (string-append out "/bin")))
      (when (file-exists? bin)
        (for-each (lambda (file)
                    (when (and (script-file? file)
                               (inject-telemetry-opt-out
                                file #:variables telemetry-variables))
                      (format #t "telemetry: opt-out injected into ~a~%"
                              (basename file))))
                  (find-files bin
                              (lambda (_file stat)
                                (eq? 'regular (stat:type stat))))))))
  #t)

;;; telemetry.scm ends here

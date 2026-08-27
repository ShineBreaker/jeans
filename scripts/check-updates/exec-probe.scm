;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-only
;;;
;;; Diagnostic package: run inside a Guix build sandbox, dump the
;;; sandbox mount table (per-mount exec/noexec flags are visible in
;;; mountinfo) and try to execute a script from the build tree — the
;;; exact operation that fails with EACCES on GitHub runners
;;; (issue #32, `In execvp of ./configure: Permission denied').
;;;
;;; Usage: guix build -f scripts/check-updates/exec-probe.scm

(define-module (exec-probe)
  #:use-module (gnu packages bash)
  #:use-module (guix gexp)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix modules)
  #:use-module (guix packages)
  #:use-module (guix build-system trivial))

(package
  (name "exec-probe")
  (version "0")
  (source #f)
  (build-system trivial-build-system)
  (arguments
   (list #:builder
         (with-imported-modules (source-module-closure
                                 '((guix build utils)))
           #~(begin
               (use-modules (guix build utils) (ice-9 rdelim))
               (format #t "=== probe: cwd = ~a ===~%" (getcwd))
               (format #t "=== probe: /proc/self/mountinfo ===~%")
               ;; /proc may be inaccessible in restricted sandboxes; treat
               ;; failure as a diagnostic data point, not a probe abort.
               (catch #t
                 (lambda ()
                   (call-with-input-file "/proc/self/mountinfo"
                     (lambda (port)
                       (display (read-string port)))))
                 (lambda args
                   (format #t "=== probe: cannot read mountinfo: ~a ===~%"
                           args)))
               (call-with-output-file "probe.sh"
                 (lambda (port)
                   (format port "#!~a/bin/sh\necho SANDBOX-EXEC-OK\n" #$bash)))
               (chmod "probe.sh" #o755)
               (invoke "./probe.sh")
               (mkdir-p (assoc-ref %outputs "out"))))))
  (home-page "about:blank")
  (synopsis "Build sandbox exec probe")
  (description "Diagnostic throw-away package.")
  (license license:public-domain))

;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-only

;;; jeans-electron-build-system：Electron 预编译包的薄层 host 侧。
;;;
;;; 本层不自建 bag，只做三件事，然后经基座 lower 成 bag 后做 bag 手术追加 Electron 参数
;;; （bag inherit，不经过基座具名校验；基座对五键 dormant 透传）：
;;;   1. 固化 Electron 默认值：#:unpack-method 默认 'deb（可覆写），
;;;      #:disable-updater? 默认 #t，#:wayland? 默认 'inject-flags。
;;;   2. 校验必填参数，失败报有意义错误（不把缺参漏到 builder 才炸）：
;;;      #:program（bin/ 下程序名）、#:app-dir（如 "lib/opencode-desktop"），
;;;      以及 #:disable-updater? 为真时的 #:application-directory。
;;;   3. 自动把 (jeans build electron) + (jeans build binary) 前置进 #:modules
;;;     与 #:imported-modules（builder 侧 %load-path 只含 #:imported-modules
;;;     所列模块，不前置则 builder 内 use-modules 找不到本层；形态抄 copy.scm
;;;     的 modules 透传）。
;;;
;;; phases 默认值即 '(@ (jeans build electron) %standard-phases)（copy.scm 同
;;; 款写法，由基座 builder 按标准语义 sexp->gexp）。调用包自带 #:phases 时按逃
;;; 生舱语义原样透传，本层的 updater/wayland/wrap-electron 不会自动追加——
;;; 此时请从 (jeans build electron) 引用上述 phase 手动组装，并自行保证 inputs
;;; 含 mesa / nss / fontconfig-minimal（wrap 三件套所需）。
;;;
;;; 默认 phases 实测顺序：install → disable-electron-updater → patchelf → wrap
;;; → wrap-electron → prefer-wayland → prefer-wayland-hint → desktop-files。
;;;
;;; 与基座的分工：Electron 专属五个关键字（#:disable-updater?
;;; #:application-directory #:wayland? #:program #:app-dir）的值随 builder
;;; 参数透传，由 builder 侧 phases 经 #:key 消费；基座侧按约定对其 dormant
;;; （不校验不剥离，无 wrap-plan 时 wrap no-op，无 updater/wayland 符号值消费者）。
;;; 基座 builder 须经 #:allow-other-keys（或显式声明）容忍这五个关键字。

(define-module (jeans build-system electron)
  #:use-module (guix build-system)
  #:use-module ((jeans build-system binary) #:prefix binary:)
  #:use-module (srfi srfi-1)
  #:export (jeans-electron-build-system
            lower
            %electron-build-modules))

(define %electron-build-modules
  '((jeans build electron)
    (jeans build binary)))

(define (plist-ref key lst)
  "取关键字列表 LST 中 KEY 的值，缺席返回 #f。"
  (let ((tail (memq key lst)))
    (and tail (pair? (cdr tail)) (cadr tail))))

(define (plist-drop keys lst)
  "删关键字列表 LST 中 KEYS 诸键及其值。"
  (cond ((null? lst) '())
        ((and (pair? lst) (memq (car lst) keys))
         (plist-drop keys (if (pair? (cdr lst)) (cddr lst) '())))
        ((pair? lst)
         (cons (car lst)
               (plist-drop keys
                           (if (pair? (cdr lst)) (cdr lst) '()))))
        (else lst)))

(define (check-non-empty-string value name example)
  (unless (and (string? value) (not (string-null? value)))
    (error (string-append "jeans-electron-build-system: " name " must be a ~
non-empty string, e.g. " example)
           value)))

(define (validate-electron-arguments program app-dir application-directory
                                     disable-updater? wayland? inputs
                                     custom-phases?)
  (check-non-empty-string program "#:program" "\"opencode-desktop\"")
  (check-non-empty-string app-dir "#:app-dir" "\"lib/opencode-desktop\"")
  (unless (boolean? disable-updater?)
    (error "jeans-electron-build-system: #:disable-updater? must be a boolean"
           disable-updater?))
  (if disable-updater?
      (check-non-empty-string application-directory "#:application-directory"
                              "\"opencode-desktop\"")
      (unless (or (not application-directory)
                  (string? application-directory))
        (error "jeans-electron-build-system: #:application-directory must be ~
a string or #f"
               application-directory)))
  (unless (or (not wayland?) (memq wayland? '(inject-flags hint-env)))
    (error "jeans-electron-build-system: #:wayland? must be 'inject-flags, ~
'hint-env or #f"
           wayland?))
  ;; wrap 三件套读这三个 label；默认 phases 才跑 trio，自定义 phases 不查。
  (unless custom-phases?
    (for-each (lambda (label)
                (unless (assoc-ref inputs label)
                  (error (string-append "jeans-electron-build-system: missing ~
input \"" label "\" (required by the default electron wrap trio); add ~
(\"mesa\" ,mesa) (\"nss\" ,nss) (\"fontconfig-minimal\" ,fontconfig) to inputs")
                         inputs)))
              '("mesa" "nss" "fontconfig-minimal"))))

(define* (lower name
                #:key source inputs native-inputs outputs system target
                (unpack-method 'deb)
                (disable-updater? #t)
                (application-directory #f)
                (wayland? 'inject-flags)
                (program #f)
                (app-dir #f)
                #:allow-other-keys
                #:rest arguments)
  "校验 Electron 参数、填默认值，经基座 lower 成 bag 后 bag inherit 追加 Electron 参数
（不经过基座具名校验；#:modules/#:imported-modules 同步前置）。"
  (let* ((user-phases (plist-ref #:phases arguments))
         (user-modules (plist-ref #:modules arguments))
         (user-imported (plist-ref #:imported-modules arguments))
         ;; Guile 的 #:rest 保留全部实参（含已被 #:key 具名的），此处把本层
         ;; 已显式转发的键剥离，只剩基座私有的透传键（如 #:tests?），原样交基座 lower。
         (rest (plist-drop '(#:source #:inputs #:native-inputs #:outputs
                              #:system #:target #:unpack-method
                              #:disable-updater? #:application-directory
                              #:wayland? #:program #:app-dir
                              #:phases #:modules #:imported-modules)
                             arguments)))
    (validate-electron-arguments program app-dir application-directory
                                 disable-updater? wayland? inputs user-phases)
    (let ((base (apply binary:lower name
                       #:source source
                       #:inputs inputs
                       #:native-inputs native-inputs
                       #:outputs outputs
                       #:system system
                       #:target target
                       #:unpack-method unpack-method
                       rest)))
      ;; bag 手术：Electron 五键 + phases/modules/imported-modules 追加进 bag arguments，
      ;; 由基座 builder 经 gexp 透传给 build-side phases（基座 dormant，不校验）。
      (bag (inherit base)
           (arguments (append (bag-arguments base)
                              (list #:program program
                                    #:app-dir app-dir
                                    #:wayland? wayland?
                                    #:disable-updater? disable-updater?
                                    #:application-directory application-directory
                                    #:phases (or user-phases
                                                 '(@ (jeans build electron)
                                                     %standard-phases))
                                    #:modules (delete-duplicates
                                                 (append %electron-build-modules
                                                         (or user-modules '()))
                                                 equal?)
                                    #:imported-modules
                                    (delete-duplicates
                                     (append %electron-build-modules
                                             (or user-imported '())
                                             binary:%jeans-binary-build-system-modules)
                                     equal?))))))))

(define jeans-electron-build-system
  (build-system
    (name 'jeans-electron)
    (description "Electron prebuilt binary build system, thin layer over jeans-binary")
    (lower lower)))

;;; electron.scm ends here

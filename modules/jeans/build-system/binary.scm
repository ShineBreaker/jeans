;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-only

;;; jeans-binary-build-system（host-side，基座；electron 层在其上扩展）。
;;;
;;; copy.scm 的 lower→bag 形态：校验参数后 lower 成 bag，builder 经 gexp 调用
;;; build-side (jeans build binary) 的 binary-build，并在 builder 内把该模块前置进
;;; 构建环境的 #:modules（用户自己的 #:modules 追加在其后）。
;;;
;;; 参数（完整语义见 (jeans build binary) 的模块注释）：
;;;
;;; - #:unpack-method（默认 'gnu-unpack）：显式声明，无探测。未知符号直接报错。
;;; - #:install-plan：默认 #f → build-side 按 lib/<dir>/ 落盘（<dir> 优先取 #:app-dir）。
;;; - #:app-dir（默认 #f）：build-side 取资源根做 lib-dir（RPATH 首项），原值同时透传
;;;   给 phases（electron 层 wrap 读 "lib/<app>" 形式）；缺省 #f 时行为不变。
;;; - #:patchelf?（默认 #t）：#f 则不打任何 ELF（静态 / 自定位二进制用）。
;;; - #:patchelf-plan：((PATH [SPEC ...]) ...)，见 build-side。
;;; - #:preserve-rpath?（默认 #f）。
;;; - #:wrap?（默认 #t）/#:wrap-plan：直通 wrap-program。
;;; - #:desktop-files：(DESKTOP [EXEC [ICON]]) 列表，简单版重写。
;;; - #:wayland?/#:disable-updater?/#:program/#:application-directory：
;;;   Electron 专属键，基座 dormant 透传（不校验不剥离，随 builder 参数直达 phases；
;;;   基座自身无消费者，无 wrap-plan 时 wrap no-op）。
;;; - #:phases/#:modules/#:imported-modules：标准逃生舱。
;;;
;;; 三关默认全关：#:tests? #f、#:validate-runpath? #f、#:strip-binaries? #f。
;;;
;;; #:patchelf? #t 时自动把 patchelf 注入 native-inputs（已有同 label 则不重复，
;;; 故包定义里无需手写 patchelf；'bsdtar/'appimage-7z 所需的 libarchive/p7zip
;;; 仍需包自己声明）。

(define-module (jeans build-system binary)
  #:use-module (guix store)
  #:use-module (guix utils)
  #:use-module (guix gexp)
  #:use-module (guix monads)
  #:use-module (guix search-paths)
  #:use-module (guix build-system)
  #:use-module (guix build-system gnu)
  #:use-module (guix packages)
  #:use-module (srfi srfi-1)
  #:export (%jeans-binary-build-system-modules
            lower
            jeans-binary-build
            jeans-binary-build-system))

(define %unpack-methods
  ;; 与 (jeans build binary) 的 unpack 对齐；两处各一份，改时一起改。
  '(gnu-unpack tar zip deb deb-xz deb-zst bsdtar appimage-7z file none))

(define %jeans-binary-build-system-modules
  ;; Build-side 模块：(jeans build binary) 打头；ice-9/srfi 系由
  ;; guix 模块的传递闭包自动带入容器（显式列出会触发 Guix 的
  ;; "importing modules from the host" 警告），此处只列 guix 模块。
  `((jeans build binary)
    ,@%default-gnu-imported-modules))

(define (default-patchelf)
  "Return the default patchelf package."
  ;; Do not use `@' to avoid introducing circular dependencies.
  (let ((module (resolve-interface '(gnu packages elf))))
    (module-ref module 'patchelf)))

(define (has-input-label? inputs label)
  "INPUTS（alist 或 package 列表）中是否有 LABEL（防重复注入）。"
  (any (lambda (entry)
         (and (pair? entry)
              (equal? (car entry) label)))
       inputs))

(define* (lower name
                #:key source inputs native-inputs outputs system target
                (unpack-method 'gnu-unpack)
                (patchelf? #t)
                #:allow-other-keys
                #:rest arguments)
  "校验参数后返回 NAME 的 bag（不支持交叉编译）。Electron 专属键经 rest 透传，不校验。"
  (unless (memq unpack-method %unpack-methods)
    (error "jeans-binary-build-system: 未知的 #:unpack-method" unpack-method))
  (define private-keywords
    '(#:target #:inputs #:native-inputs))

  (and (not target)                               ;XXX: no cross-compilation
       (bag
         (name name)
         (system system)
         (host-inputs `(,@(if source
                              `(("source" ,source))
                              '())
                        ,@inputs
                        ;; Keep the standard inputs of 'gnu-build-system'.
                        ,@(standard-packages)))
         (build-inputs (if (and patchelf?
                                (not (has-input-label? native-inputs "patchelf")))
                           `(("patchelf" ,(default-patchelf))
                             ,@native-inputs)
                           native-inputs))
         (outputs outputs)
         (build jeans-binary-build)
         (arguments (strip-keyword-arguments private-keywords arguments)))))

(define* (jeans-binary-build name inputs
                             #:key
                             guile source
                             (outputs '("out"))
                             (unpack-method 'gnu-unpack)
                             (install-plan #f)
                             (patchelf? #t)
                             (patchelf-plan ''())
                             (preserve-rpath? #f)
                             (wrap? #t)
                             (wrap-plan ''())
                             (desktop-files ''())
                             ;; Electron 专属键：基座 dormant 透传给 phases，自身不消费。
                             (wayland? #f)
                             (disable-updater? #f)
                             (program #f)
                             (app-dir #f)
                             (application-directory #f)
                             (search-paths '())
                             (tests? #f)
                             (validate-runpath? #f)
                             (strip-binaries? #f)
                             (phases '(@ (jeans build binary)
                                         %standard-phases))
                             (system (%current-system))
                             (substitutable? #t)
                             (imported-modules %jeans-binary-build-system-modules)
                             (modules '((guix build utils)))
                             #:allow-other-keys
                             #:rest rest)
  "用 INSTALL-PLAN 等参数构建预编译二进制包（见模块注释）。Electron 专属键透传给 phases。"
  (unless (memq unpack-method %unpack-methods)
    (error "jeans-binary-build-system: 未知的 #:unpack-method" unpack-method))
  (define builder
    (with-imported-modules imported-modules
      #~(begin
          ;; (jeans build binary) 恒前置，用户 #:modules 追加其后。
          (use-modules (jeans build binary) #$@modules)

          #$(with-build-variables inputs outputs
              #~(binary-build #:package-name #$name
                              #:source #+source
                              #:system #$system
                              #:outputs %outputs
                              #:inputs %build-inputs
                              ;; 符号必须 quote，否则 gexp 会当成变量引用。
                              #:unpack-method '#$unpack-method
                              ;; plan 类参数与 copy-build-system 同约定：传 #~'(...)（可内嵌
                              ;; #$output 等引用）；(list ...) 里写裸 '(...) 会在求值时丢掉
                              ;; quote 而无法使用，切记。
                              #:install-plan #$(if (pair? install-plan)
                                                   (sexp->gexp install-plan)
                                                   install-plan)
                              #:patchelf? #$patchelf?
                              #:patchelf-plan #$(if (pair? patchelf-plan)
                                                    (sexp->gexp patchelf-plan)
                                                    patchelf-plan)
                              #:preserve-rpath? #$preserve-rpath?
                              #:wrap? #$wrap?
                              #:wrap-plan #$(if (pair? wrap-plan)
                                                (sexp->gexp wrap-plan)
                                                wrap-plan)
                              #:desktop-files #$(if (pair? desktop-files)
                                                    (sexp->gexp desktop-files)
                                                    desktop-files)
                              ;; Electron 专属键透传给 build-side，由 electron phases 经 #:key 消费；
                              ;; 基座自身无消费者。wayland? 是符号值，必须 quote。
                              #:wayland? '#$wayland?
                              #:disable-updater? #$disable-updater?
                              #:program #$program
                              #:app-dir #$app-dir
                              #:application-directory #$application-directory
                              #:search-paths '#$(sexp->gexp
                                                 (map search-path-specification->sexp
                                                      search-paths))
                              #:phases #$(if (pair? phases)
                                             (sexp->gexp phases)
                                             phases)
                              #:tests? #$tests?
                              #:validate-runpath? #$validate-runpath?
                              #:strip-binaries? #$strip-binaries?)))))

  (mlet %store-monad ((guile (package->derivation (or guile (default-guile))
                                                  system #:graft? #f)))
    (gexp->derivation name builder
                      #:system system
                      #:target #f
                      #:substitutable? substitutable?
                      #:graft? #f
                      #:guile-for-build guile)))

(define jeans-binary-build-system
  (build-system
    (name 'jeans-binary)
    (description "The standard jeans prebuilt-binary build system")
    (lower lower)))

;;; binary.scm ends here

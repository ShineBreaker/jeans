;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;;
;;; SPDX-License-Identifier: MIT

(define-module (jeans packages category)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix gexp)
  #:use-module (guix build-system copy)
  #:use-module (guix build-system gnu)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages base)
  #:use-module (gnu packages elf)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages pkg-config))

(define-public %name%
  (package
    (name "%name%")
    (version "%version%")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "%repo-url%")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256 (base32 "%guix-base32-hash%"))))
    (build-system gnu-build-system)
    (native-inputs (list pkg-config))
    (inputs
     (quasiquote
      (("dependency-name" unquote dependency-variable))))
    (home-page "%home-page%")
    (synopsis "%short-description")
    (description "%Long description with complete sentences.")
    (license license:gpl3+)))

(define-public %name%-bin
  (package
    (name "%name%-bin")
    (version "%version%")
    (source
     (origin
       (method url-fetch)
       (uri "%binary-url%")
       (sha256 (base32 "%guix-base32-hash%"))))
    (build-system copy-build-system)
    (arguments
     (list
      #:tests? #f
      #:validate-runpath? #f
      #:strip-binaries? #f
      #:install-plan
      #~'(("bin/%upstream-program%" "bin/"))))
    (native-inputs (list patchelf))
    (inputs
     (quasiquote
      (("bash-minimal" unquote bash-minimal)
       ("glibc" unquote glibc)
       ("gcc:lib" unquote gcc "lib"))))
    (home-page "%home-page%")
    (synopsis "%short-description")
    (description "%Long description with complete sentences.")
    ;; upstream-name 几乎对所有 -bin 包必需：github updater 用它匹配 release
    ;; 资产文件名前缀。值 = 文件名里 version 之前的部分。详见 jeans-conventions.md。
    ;; 多个 property 用 alist 合并：`((upstream-name . "foo") (release-tag-prefix . "^v"))
    (properties `((upstream-name . "%upstream-repo-name%")))
    (license license:expat)
    (supported-systems '("x86_64-linux"))))

;;; For raw ELF files that need Guix's loader, use gnu-build-system,
;;; delete configure/build, copy the source in unpack, then create a wrapper
;;; with --argv0 and --library-path. Do not use trivial-build-system by default.

;;; Minimal raw-ELF phase shape:
;;;
;;; (replace 'unpack
;;;   (lambda _
;;;     (copy-file #$source "program")
;;;     (chmod "program" #o755)))
;;; (replace 'install
;;;   (lambda* (#:key inputs #:allow-other-keys)
;;;     (let* ((out #$output)
;;;            (bin (string-append out "/bin"))
;;;            (libexec (string-append out "/libexec/%name%"))
;;;            (ld-so (string-append (assoc-ref inputs "glibc")
;;;                                  #$(glibc-dynamic-linker)))
;;;            (library-path
;;;             (string-join
;;;              (list (string-append (assoc-ref inputs "glibc") "/lib")
;;;                    (string-append (assoc-ref inputs "gcc:lib") "/lib"))
;;;              ":")))
;;;       (mkdir-p bin)
;;;       (mkdir-p libexec)
;;;       (install-file "program" libexec)
;;;       ;; Use a store bash path and preserve the binary's argv0 contract.
;;;       ...)))

;;; Git-fetch package tracking latest commit (上游无 tag):
;;; 用 let 绑定 commit/revision，version 由 (git-version ...) 求值。
;;; 必须加 (properties `((with-latest-git-commit . #t)))。
;;; 注意：该 property 在 Guix <= 9e068cc0 尚未实现，commit 追踪暂由
;;; update_versions.py 的 let-git-version 适配逻辑负责。
;;;
;;; (define-public %name%
;;;   (let ((commit "%40-hex-hash%")
;;;         (revision "0"))
;;;     (package
;;;       (name "%name%")
;;;       (version (git-version "0" revision commit))   ; → "0-0.<commit前7位>"
;;;       (source
;;;        (origin
;;;          (method git-fetch)
;;;          (uri (git-reference
;;;                (url "%repo-url%")
;;;                (commit commit)))            ; 引用 let 绑定的符号
;;;          (file-name (git-file-name name version))
;;;          (sha256 (base32 "%guix-base32-hash%"))))
;;;       ...
;;;       (properties `((with-latest-git-commit . #t)))
;;;       (license ...))))

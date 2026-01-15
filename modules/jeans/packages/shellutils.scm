(define-module (jeans packages shellutils)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix gexp)
  #:use-module (guix utils)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system cargo)
  #:use-module (guix build-system copy)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system go)
  #:use-module ((guix build-system python) #:select (pypi-uri))
  #:use-module (guix build-system pyproject)
  #:use-module (gnu packages)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bison)
  #:use-module (gnu packages check)
  #:use-module (gnu packages cmake)
  #:use-module (gnu packages flex)
  #:use-module (gnu packages golang-build)
  #:use-module (gnu packages golang-check)
  #:use-module (gnu packages golang-xyz)
  #:use-module (gnu packages libunistring)
  #:use-module (gnu packages ncurses)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages pcre)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages python)
  #:use-module (gnu packages python-build)
  #:use-module (gnu packages python-check)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages readline)
  #:use-module (gnu packages ruby)
  #:use-module (gnu packages ruby-check)
  #:use-module (gnu packages ruby-xyz)
  #:use-module (gnu packages shells)
  #:use-module (gnu packages textutils)
  #:use-module (gnu packages tmux)
  #:use-module (gnu packages version-control)
  #:use-module (gnu packages vim))


(define-public starship-latest
  (let ((commit "cc493347dcb1d129df29e87f978443262c3b1730")   ; ← 改成最新
        (revision "0"))
    (package
      (inherit (specification->package "starship"))   ; 或直接写 (@@ (gnu packages rust-apps) starship)
      (name "starship-latest")
      (version (git-version "1.24.2" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
                (url "https://github.com/starship/starship")
                (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32
           "1n10ayllgsds9nsmn8v3c6xb0g70ijpwllgb82rmi2glvmjc9pgq"))))
      ;; 以下字段通常保持原样，除非真的构建失败再改
      (build-system cargo-build-system)
      ;; ... 保留原有的 arguments、inputs、native-inputs 等
      ;; 如果要覆盖某部分，可以在这里写 (arguments #~(...)) 来覆盖
      )))

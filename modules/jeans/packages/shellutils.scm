(define-module (my-packages starship)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system cargo)
  #:use-module (gnu packages)
  #:use-module (gnu packages version-control)   ; git-minimal
  #:use-module (gnu packages cmake)             ; 如果需要
  #:use-module ((gnu packages crates-io) #:prefix crate:)
  #:use-module (guix utils)
  #:use-module (guix gexp))

(define-public starship-git
  (let ((commit "cc493347dcb1d129df29e87f978443262c3b1730")   ; ← 改成最新
        (revision "0"))
    (package
      (inherit (specification->package "starship"))   ; 或直接写 (@@ (gnu packages rust-apps) starship)
      (name "starship-git")
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
           "1yvppkbz0s6ms1hcahla93995bajg2rvxyfzg7baqssz5n12gvnb"))))
      ;; 以下字段通常保持原样，除非真的构建失败再改
      (build-system cargo-build-system)
      ;; ... 保留原有的 arguments、inputs、native-inputs 等
      ;; 如果要覆盖某部分，可以在这里写 (arguments #~(...)) 来覆盖
      )))

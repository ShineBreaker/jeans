;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2025 brokenshine <xchai404@gmail.com>

(define-module (jeans packages java)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix build-system copy)
  #:use-module ((guix licenses)
                #:prefix license:)
  #:use-module (gnu packages)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages elf)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages java)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages xorg)
  #:use-module ((guix build utils)
                #:select (find-files)))

(define* (make-zulu-package zulu-name zulu-version jdk-version hash)
  "Create a Zulu JDK package for the given versions.
ZULU-VERSION: The Azul Zulu version (e.g., \"21.0.5\")
JDK-VERSION: The JDK version (e.g., \"21\")
HASH: The sha256 hash of the tarball"
  (package
    (name zulu-name)
    (version zulu-version)
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://cdn.azul.com/zulu/bin/zulu" zulu-version
                           "-ca-jdk" jdk-version "-linux_x64.tar.gz"))
       (sha256
        (base32 hash))
       (modules '((guix build utils)))
       (snippet '(begin
                   (for-each delete-file
                             (find-files "." "\\.dll$"))
                   (for-each delete-file
                             (find-files "." "\\.exe$")) #t))))
    (supported-systems '("x86_64-linux"))
    (build-system copy-build-system)
    (arguments
     `(#:install-plan '(("." "lib/jvm/zulu"))
       #:validate-runpath? #f))
    (native-inputs (list bash-minimal))
    (inputs (list alsa-lib
                  fontconfig
                  freetype
                  gcc
                  libx11
                  libxext
                  libxi
                  libxrender
                  libxtst
                  libxxf86vm
                  patchelf
                  zlib))
    (home-page "https://www.azul.com/products/zulu/")
    (synopsis "Azul Zulu - OpenJDK distribution")
    (description
     "Azul Zulu is a build of OpenJDK that is tested and
certified for enterprise use.  It includes the Java Runtime Environment
(JRE) and Java Development Kit (JDK) tools and is available under the
GPLv2 with Classpath Exception.")
    (license license:gpl2)))

(define-public zulu25-bin
  (make-zulu-package "zulu25-bin" "25.30.17" "25.0.1"
                     "0giir03cxazpxg6wgqfc9hj0vw9rhqnq8p806xzd5bpzpmi3w6s7"))

(define-public zulu21-bin
  (make-zulu-package "zulu21-bin" "21.46.19" "21.0.9"
                     "1f4kbkvxa199qf3g2p96z7qbs03a0sakais9qbqhzb172jri1s37"))

(define-public zulu8-bin
  (make-zulu-package "zulu8-bin" "8.90.0.19" "8.0.472"
                     "1pg2f1xr2jrdi7wbi6kwqhkhd64lngg0ryqi6iaw56l2ffkkz7kg"))

;; Alias for default Zulu (currently 21)
(define-public zulu-bin
  zulu21-bin)

zulu8-bin

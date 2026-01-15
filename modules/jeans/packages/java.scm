;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2025 brokenshine <xchai404@gmail.com>

(define-module (jeans packages java)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix build-system copy)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages java)
  #:use-module (gnu packages xorg)
  #:use-module (gnu packages elf)
  #:use-module ((guix build utils)
                #:select (find-files)))

(define* (make-zulu-package zulu-version jdk-version hash)
  "Create a Zulu JDK package for the given versions.
ZULU-VERSION: The Azul Zulu version (e.g., \"21.0.5\")
JDK-VERSION: The JDK version (e.g., \"21\")
HASH: The sha256 hash of the tarball"
  (package
    (name "zulu")
    (version zulu-version)
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://cdn.azul.com/zulu/bin/zulu"
                           zulu-version
                           "-ca-jdk"
                           jdk-version
                           "-linux_x64.tar.gz"))
       (sha256
        (base32 hash))
       (modules '((guix build utils)))
       (snippet
        '(begin
           (for-each delete-file
                     (find-files "." "\\.dll$"))
           (for-each delete-file
                     (find-files "." "\\.exe$"))
           #t))))
    (supported-systems '("x86_64-linux"))
    (build-system copy-build-system)
    (arguments
     `(#:install-plan '(("." "lib/jvm/zulu"))
       #:validate-runpath? #f))
    (native-inputs
     (list bash-minimal))
    (inputs
     (list patchelf))
    (home-page
     "https://www.azul.com/products/zulu/")
    (synopsis
     "Azul Zulu - OpenJDK distribution")
    (description
     "Azul Zulu is a build of OpenJDK that is tested and
certified for enterprise use.  It includes the Java Runtime Environment
(JRE) and Java Development Kit (JDK) tools and is available under the
GPLv2 with Classpath Exception.")
    (license
     license:gpl2)))

;; Zulu JDK 25 (Latest)
(define-public zulu25
  (make-zulu-package "25.30.17" "25.0.1" "0giir03cxazpxg6wgqfc9hj0vw9rhqnq8p806xzd5bpzpmi3w6s7"))

;; Zulu JDK 21 (LTS)
(define-public zulu21
  (make-zulu-package "21.0.5" "21" "1v92nzdqx07c35x945awzir4yk0fk22vky6fpp8mq9js930sxsz0"))

;; Alias for default Zulu (currently 21)
(define-public zulu zulu21)

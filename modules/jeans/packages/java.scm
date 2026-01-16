;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2025 brokenshine <xchai404@gmail.com>

(define-module (jeans packages java)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix build-system copy)
  #:use-module (guix build-system trivial)
  #:use-module ((guix licenses)
                #:prefix license:)
  #:use-module (gnu packages)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages cups)
  #:use-module (gnu packages elf)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages java)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages wget)
  #:use-module (gnu packages web)
  #:use-module (gnu packages xorg)
  #:use-module ((guix build utils)
                #:select (find-files)))

(define* (make-zulu-package zulu-name zulu-version jdk-version hash)
  "Create a Zulu JDK package for given versions.
ZULU-VERSION: The Azul Zulu version (e.g., \"21.0.5\")
JDK-VERSION: The JDK version (e.g., \"21\")
HASH: The sha256 hash of tarball"
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
    (build-system trivial-build-system)
    (arguments
     (list
      #:modules '((guix build utils))
      #:builder
      #~(begin
          (use-modules (guix build utils))

          (let* ((source (assoc-ref %build-inputs "source"))
                 (tar (string-append (assoc-ref %build-inputs "tar")
                                     "/bin/tar"))
                 (zstd (string-append (assoc-ref %build-inputs "zstd")
                                      "/bin/zstd"))
                 (wget (string-append (assoc-ref %build-inputs "wget")
                                      "/bin/wget"))
                 (unzip (string-append (assoc-ref %build-inputs "unzip")
                                       "/bin/unzip"))
                 (out (assoc-ref %outputs "out"))
                 (jdk-dir (string-append out "/lib/jvm/zulu"))
                 (bin-dir (string-append jdk-dir "/bin"))
                 (lib-dir (string-append jdk-dir "/lib"))
                 (include-dir (string-append jdk-dir "/include"))
                 (security-dir (string-append lib-dir "/security"))
                 (patchelf (string-append (assoc-ref %build-inputs "patchelf")
                                          "/bin/patchelf"))
                 (bash (assoc-ref %build-inputs "bash")))
            
            ;; Unpack and install
            (mkdir-p jdk-dir)
            (invoke tar
                    "--use-compress-program"
                    zstd
                    "-xf"
                    source
                    "-C"
                    jdk-dir
                    "--strip-components=1")

            ;; Download and install JCE policies (optional, skip if download fails)
            (let ((jce-url
                   "https://web.archive.org/web/20211126120343/http://cdn.azul.com/zcek/bin/ZuluJCEPolicies.zip")
                  (jce-zip "/tmp/zulu-jce-policies.zip"))
              (when (zero? (system* wget "-q" "-O" jce-zip jce-url))
                (mkdir-p "/tmp/zulu-jce")
                (system* unzip "-q" jce-zip "-d" "/tmp/zulu-jce")
                (for-each (lambda (file)
                            (copy-file file
                                       (string-append security-dir "/" file)))
                          (find-files "/tmp/zulu-jce/ZuluJCEPolicies"
                                      "\\.jar$"))))

            ;; Create JNI header symlink (optional, skip if directory doesn't exist)
            (let ((linux-include (string-append include-dir "/linux")))
              (when (and (directory-exists? linux-include)
                         (file-exists? (string-append linux-include
                                                      "/jni_md.h")))
                (for-each (lambda (file)
                            (let ((target (string-append linux-include "/"
                                                         file))
                                  (link (string-append include-dir "/" file)))
                              (when (and (file-exists? target)
                                         (not (file-exists? link)))
                                (symlink target link))))
                          (find-files linux-include ".*"))))

            ;; Patch ELF files to set correct rpath for JDK internal libraries only
            (let* ((rpath (string-append jdk-dir "/lib:"
                                          jdk-dir "/lib/server:"
                                          jdk-dir "/lib/jli")))
              (for-each (lambda (so-file)
                          (invoke patchelf "--set-rpath" rpath so-file))
                        (find-files (string-append jdk-dir "/lib") "\\.so$"))

              (for-each (lambda (bin-file)
                          (when (not (string=? (basename bin-file)
                                               "jspawnhelper"))
                            (invoke patchelf "--set-rpath" rpath bin-file)))
                        (find-files (string-append jdk-dir "/bin") ".*")))

            ;; Create symlinks for binaries in out/bin
            (mkdir-p (string-append out "/bin"))
            (for-each (lambda (bin-file)
                        (let* ((bin-name (basename bin-file))
                               (wrapper-path (string-append out "/bin/"
                                                            bin-name)))
                          ;; Skip wrapping jspawnhelper as it's executed by JVM
                          (when (not (string=? bin-name "jspawnhelper"))
                            (symlink bin-file wrapper-path))))
                      (find-files bin-dir ".*"))

            ;; Create setup-hook for JAVA_HOME
            (let ((hook-file (string-append out "/etc/profile.d/zulu.sh")))
              (mkdir-p (dirname hook-file))
              (call-with-output-file hook-file
                (lambda (port)
                  (display (string-append "export JAVA_HOME=\"" jdk-dir "\"\n")
                           port))))

            ;; Create symlink for standard location
            (let ((std-jdk-dir (string-append out "/lib/jvm/java")))
              (symlink jdk-dir std-jdk-dir))))))
    (native-inputs (list bash
                         patchelf
                         tar
                         unzip
                         wget
                         zstd))
    (inputs (list alsa-lib
                  fontconfig
                  freetype
                  gcc
                  glibc
                  libx11
                  libxext
                  libxi
                  libxrender
                  libxtst
                  libxxf86vm
                  zlib
                  cups
                  cairo
                  glib
                  gtk+))
    (propagated-inputs (list alsa-lib
                             fontconfig
                             freetype
                             gcc
                             libx11
                             libxext
                             libxi
                             libxrender
                             libxtst
                             libxxf86vm
                             zlib
                             cups
                             cairo
                             glib
                             gtk+))
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

(define-public zulu-bin
  zulu21-bin)

zulu25-bin

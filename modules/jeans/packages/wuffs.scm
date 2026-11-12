;;; SPDX-FileCopyrightText: 2026 Raven Hallsby <raven@hallsby.com>
;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-or-later
;;;
;;; Ported from GNU Guix PR 4087 <https://codeberg.org/guix/guix/pulls/4087>.

;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2026 Raven Hallsby <raven@hallsby.com>
;;;
;;; This file is part of GNU Guix.
;;;
;;; GNU Guix is free software; you can redistribute it and/or modify it
;;; under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 3 of the License, or (at
;;; your option) any later version.
;;;
;;; GNU Guix is distributed in the hope that it will be useful, but
;;; WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with GNU Guix.  If not, see <http://www.gnu.org/licenses/>.

(define-module (jeans packages wuffs)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix git-download)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system go)
  #:use-module (guix build-system trivial)
  #:use-module (guix utils)
  #:use-module (gnu packages)
  #:use-module (gnu packages base)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages digest)
  #:use-module (gnu packages golang-build)
  #:use-module (gnu packages image)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages tls))

;;; Commentary:
;;;
;;; Google's Wrangling Untrusted File Formats Safely (WUFFS) library is a
;;; domain-specific programming language for describing binary formats.
;;;
;;; <https://github.com/google/wuffs>
;;;
;;; The WUFFS project includes the language and its compiler, the WUFFS standard
;;; library, and a pre-translated (pre-compiled) release of the WUFFS standard
;;; library meant for immediate downstream consumption.
;;;
;;; The WUFFS language is intended to make describing and working with binary
;;; file formats safer, particularly around memory safety.  The language is
;;; used to build tools that operate on this binary data, usually as encoders
;;; and decoders (or serializers/deserializers) easy.  The WUFFS compiler
;;; consumes a WUFFS specification and produces C code that you can build and
;;; link with your project.
;;;
;;; From the terminology of WUFFS' BUILD.md, Guix does build options 2, 3, and
;;; 4.  Guix does not provide the pre-compiled release of the WUFFS standard
;;; library (build option 1), opting to instead build the library itself (4).
;;;
;;; 1. The Wuffs library (e.g. image decoders) in C/C++ form.
;;; 2. Its example programs (e.g. jsonptr).
;;; 3. The Wuffs toolchain (e.g. Wuffs-to-C compiler/proof-checker).
;;; 4. The Wuffs library in Wuffs form (converting it to C/C++ code).
;;; 5. Everything.

;;; FIXME: Remove duplicated package definition stuff, version, source, etc.

(define-public wuffs-compiler
  (hidden-package
   (package
     (name "wuffs-compiler")
     (version "0.4.0-alpha.12")
     (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/google/wuffs")
               (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256
         (base32 "03ssk72n6xbgai1l6chlip8fns46f28zhz822whk3z629a03iq8j"))))
     (build-system go-build-system)
     (arguments
      (list
       #:unpack-path "github.com/google/wuffs"
       #:import-path "github.com/google/wuffs/cmd/..."
       #:install-source? #f
       #:phases
       #~(modify-phases %standard-phases
           (add-after 'install 'remove-unneeded-bins
             (lambda* (#:key outputs #:allow-other-keys)
               (let ((bin (string-append (assoc-ref outputs "out") "/bin")))
                 (delete-file (string-append bin "/dumbindent"))))))))
     ;; go-golang-org-x-image is only imported while compiling the wuffs
     ;; commands.  Propagating it would drag a Go library into every profile
     ;; that installs wuffs.
     (native-inputs (list go-golang-org-x-image
                          lz4
                          pkg-config
                          zlib
                          `(,zstd "lib")))
     (home-page "https://github.com/google/wuffs")
     (synopsis "DSL for writing tools that handle binary file formats")
     (description
      "WUFFS (Wrangling Untrusted File Formats Safely) is a memory-safe programming
language (and a standard library written in that language) for Wrangling
Untrusted File Formats Safely.  Wrangling includes parsing, decoding and
encoding.  Example file formats include images, audio, video, fonts and
compressed archives.")
     (license (list license:asl2.0 license:expat)))))

(define-public wuffs-stdlib
  (hidden-package
   (package
     (name "wuffs-stdlib")
     (version "0.4.0-alpha.12")
     (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/google/wuffs")
               (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256
         (base32 "03ssk72n6xbgai1l6chlip8fns46f28zhz822whk3z629a03iq8j"))))
     (build-system gnu-build-system)
     (arguments
      (list
       #:phases
       #~(modify-phases %standard-phases
           (add-after 'unpack 'delete-vendored-snapshot
             (lambda _
               (delete-file "release/c/wuffs-unsupported-snapshot.c")))
           (delete 'configure)
           (replace 'build
             (lambda _
               (let ((cmd '("wuffs" "gen" "std/...")))
                 (format #t "running: ~s~%" cmd)
                 (apply invoke cmd))))
           ;; A previous (replace 'check) compiled release/c/wuffs-unsupported-snapshot.c
           ;; and ran `wuffs test`.  modify-phases keeps only the last replacement of a
           ;; phase, so that body never ran; it also could not run, because
           ;; delete-vendored-snapshot removes that file before check.  The png
           ;; driver below is the check that actually executes.  The include in
           ;; test/c/std/png.c is "../../../release/c/wuffs-unsupported-snapshot.c";
           ;; substituting the basename yields release/c/wuffs-v0.4.c, which
           ;; `wuffs gen` writes.
           (replace 'check
             (lambda* (#:key tests? #:allow-other-keys)
               (when tests?
                 ;; Exercise the packaged release instead of the development
                 ;; snapshot normally used by the test suite.
                 (substitute* "test/c/std/png.c"
                   (("wuffs-unsupported-snapshot\\.c")
                    "wuffs-v0.4.c"))
                 (invoke #$(cc-for-target)
                         "-std=c99"
                         "-Wall"
                         "-Werror"
                         "test/c/std/png.c"
                         "-o"
                         "png-test")
                 (invoke "./png-test"))))
           (replace 'install
             (lambda* (#:key outputs #:allow-other-keys)
               (let* ((out (assoc-ref outputs "out"))
                      (include (string-append out "/include"))
                      (docs (string-append out "/share/doc/wuffs")))
                 (mkdir-p docs)
                 (copy-recursively "release/c/README.md"
                                   (string-append docs "/RELEASES.md"))
                 (delete-file "release/c/README.md")
                 (mkdir-p include)
                 (copy-recursively "release/c" include)
                 ))))))
     (native-inputs
      (list giflib
            libdeflate
            libjpeg-turbo
            libpng
            libwebp
            openssl
            wuffs-compiler
            xxhash
            zlib))
     (home-page "https://github.com/google/wuffs")
     (synopsis "DSL for writing tools that handle binary file formats")
     (description
      "WUFFS (Wrangling Untrusted File Formats Safely) is a memory-safe programming
language (and a standard library written in that language) for Wrangling
Untrusted File Formats Safely.  Wrangling includes parsing, decoding and
encoding.  Example file formats include images, audio, video, fonts and
compressed archives.")
     (license (list license:asl2.0 license:expat)))))

(define-public wuffs
  (package
    (name "wuffs")
    (version "0.4.0-alpha.12")
    (source #f)
    (outputs '("out"                    ;C library and docs
               "bin"))                  ;wuffs compiler
    (build-system trivial-build-system)
    (arguments
     (list
      #:modules '((guix build utils))
      #:builder
      #~(begin
          (use-modules (guix build utils))
          (copy-recursively (assoc-ref %build-inputs "wuffs-compiler")
                            (assoc-ref %outputs "bin"))
          (copy-recursively (assoc-ref %build-inputs "wuffs-stdlib")
                            (assoc-ref %outputs "out")))))
    ;; Inputs, not propagated-inputs.  The builder copies the compiler and
    ;; the generated C library into this package's outputs.  Propagating the
    ;; same two packages installs those files a second time and `guix package`
    ;; refuses the profile collision.  The compiler is the "bin" output
    ;; (`guix install wuffs:bin`); the default output is the C library.
    (inputs (list wuffs-compiler wuffs-stdlib))
    (home-page "https://github.com/google/wuffs")
    (synopsis "DSL for writing tools that handle binary file formats")
    (description
     "WUFFS (Wrangling Untrusted File Formats Safely) is a memory-safe programming
language (and a standard library written in that language) for Wrangling
Untrusted File Formats Safely.  Wrangling includes parsing, decoding and
encoding.  Example file formats include images, audio, video, fonts and
compressed archives.")
    (license (list license:asl2.0 license:expat))))
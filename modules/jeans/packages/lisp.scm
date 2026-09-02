;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-only

;;; Common Lisp libraries and native helper libraries needed to build
;;; lem-next (the main-branch form of the Lem editor).  The pinned
;;; commits of webview / tree-sitter-cl / jsonrpc mirror Lem's qlfile.lock
;;; at the commit pinned by lem-next: update them together with lem-next.

(define-module (jeans packages lisp)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix utils)
  #:use-module (guix build-system asdf)
  #:use-module (guix build-system copy)
  #:use-module (guix build-system gnu)
  #:use-module (gnu packages cmake)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages lisp-xyz)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages tree-sitter)
  #:use-module (gnu packages webkit))

;;; Zero-dependency UUID library, a hard dependency of Lem's mcp-server
;;; extension.
(define-public sbcl-frugal-uuid
  (let ((commit "b25fcddef4c653f072b76993ba7d48d8c063fe61"))
    (package
      (name "sbcl-frugal-uuid")
      (version (git-version "0" "0" commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/ak-coram/cl-frugal-uuid")
               (commit commit)))
         (file-name (git-file-name "frugal-uuid" version))
         (sha256
          (base32 "1pj0cg2bcf9bx1xfmzcps0b2a9j4lvi1h5nn0y6sz93mhkkqza16"))))
      (build-system asdf-build-system/sbcl)
      ;; The test system needs fiveam, which is not packaged here.
      (arguments (list #:tests? #f))
      (synopsis "Common Lisp UUID library with zero dependencies")
      (description
       "Frugal-uuid is a UUID library for Common Lisp implementing
RFC 9562 (formerly RFC 4122) UUIDs with no external dependencies.
Non-frugal companions (strong randomness, thread safety, name-based
UUIDs) are available as separate optional systems.")
      (home-page "https://github.com/ak-coram/cl-frugal-uuid")
      (license license:expat))))

;;; Tree-sitter FFI bindings for Lem.  The upstream repository vendors
;;; prebuilt libts-wrapper.so binaries under static/; we delete them and
;;; compile the single-file C wrapper ourselves.  The C wrapper handles
;;; by-value struct returns that CFFI cannot express directly.
;;; Both dlopen'd libraries are rewritten to absolute store paths, so
;;; no LD_LIBRARY_PATH tricks are needed at runtime.
(define-public sbcl-tree-sitter-cl
  (package
    (name "sbcl-tree-sitter-cl")
    (version "0.1.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/lem-project/tree-sitter-cl")
             (commit "bfc3471b165856a20c3379f538a00ec256785a44")))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1gdiy00v3ng00n7xnzs93wxj8z8x6qlf9a099bhay1faiaq51k32"))
       (snippet
        #~(begin
            (use-modules (guix build utils))
            ;; Delete vendored prebuilt shared objects.
            (delete-file-recursively "static")))))
    (build-system asdf-build-system/sbcl)
    (arguments
     (list
      #:tests? #f
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'install-and-link-native-libs
            (lambda* (#:key inputs outputs #:allow-other-keys)
              (let* ((out (assoc-ref outputs "out"))
                     (ts-lib (search-input-file inputs "/lib/libtree-sitter.so.0"))
                     (wrapper-lib (string-append out "/lib/libts-wrapper.so")))
                (substitute* "src/ffi.lisp"
                  (("\"libtree-sitter\\.so\\.0\" \"libtree-sitter\\.so\"")
                   (string-append "\"" ts-lib "\""))
                  (("\"libts-wrapper\\.so\"")
                   (string-append "\"" wrapper-lib "\"")))
                (mkdir-p (dirname wrapper-lib))
                (invoke #$(cc-for-target)
                        "-shared" "-fPIC"
                        "c-wrapper/ts-wrapper.c"
                        "-o" wrapper-lib
                        "-ltree-sitter")))))))
    (inputs
     `(("sbcl-alexandria" ,sbcl-alexandria)
       ("sbcl-babel" ,sbcl-babel)
       ("sbcl-cffi" ,sbcl-cffi)
       ("sbcl-trivial-garbage" ,sbcl-trivial-garbage)
       ("tree-sitter" ,tree-sitter)))
    (synopsis "Common Lisp bindings for tree-sitter")
    (description
       "Tree-sitter-cl provides FFI bindings to tree-sitter, an
incremental parsing library.  It supports parsing, AST traversal and
pattern queries.")
    (home-page "https://github.com/lem-project/tree-sitter-cl")
    (license license:expat)))

;;; Private helper package: installs the upstream webview/webview C++
;;; sources so the C shim build below can consume them offline via
;;; CMake's FETCHCONTENT_SOURCE_DIR_WEBVIEW override.
(define webview-upstream-src
  (package
    (name "webview-upstream-src")
    (version "0.12.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/webview/webview")
             (commit "3ab4b5d722438fc8a13e6ca830c5e2372d19a01d")))
       (file-name (git-file-name "webview-core" version))
       (sha256
        (base32 "0xfbcwsgjxsqb1whp18crajhqvm5di7dawrn4n6m08lzbmvahsm6"))))
    (build-system copy-build-system)
    (arguments
     (list #:install-plan #~'(("." "share/webview-upstream-src"))))
    (synopsis "Sources of the webview C++ library")
    (description
       "This package only installs the source tree of webview, a tiny
cross-platform webview library, for offline consumption by the webview
C shim build.")
    (home-page "https://github.com/webview/webview")
    (license license:expat)))

;;; The webview C shim: lem-project/webview's c/ directory is a thin C
;;; wrapper around webview/webview's C++ core, exposing webview_create
;;; and friends for CFFI.  The CL binding hardcodes the soname
;;; libwebview.so.0.12.0, so both the plain and versioned names are
;;; installed.  The upstream repository vendors prebuilt libraries
;;; under lib/, which are deleted here and rebuilt from source.
(define-public webview
  (package
    (name "webview")
    (version "0.12.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/lem-project/webview")
             (commit "607daff93e9e716a76c5dbd08c48b5233c96b9a3")))
       (file-name (git-file-name name version))
       (sha256
        (base32 "18fgbvpgd587993m8lwdd80djsrc7pb2c5d1bq88znmmnz6rp5bx"))
       (snippet
        #~(begin
            (use-modules (guix build utils))
            ;; Delete vendored prebuilt shared objects.
            (delete-file-recursively "lib")))))
    (build-system gnu-build-system)
    (arguments
     (list
      #:tests? #f
      #:phases
      #~(modify-phases %standard-phases
          (delete 'configure)
          (replace 'build
            (lambda* (#:key inputs #:allow-other-keys)
              ;; FETCHCONTENT_SOURCE_DIR_WEBVIEW feeds the pre-fetched
              ;; upstream sources to CMake so nothing is downloaded.
              (invoke "cmake" "-B" "build" "-S" "c"
                      "-DCMAKE_BUILD_TYPE=Release"
                      "-DWEBVIEW_WEBKITGTK_API=4.1"
                      (string-append
                       "-DFETCHCONTENT_SOURCE_DIR_WEBVIEW="
                       (assoc-ref inputs "webview-upstream-src")
                       "/share/webview-upstream-src"))
              (invoke "cmake" "--build" "build")))
          (replace 'install
            (lambda* (#:key outputs #:allow-other-keys)
              (let* ((lib (string-append (assoc-ref outputs "out") "/lib"))
                     ;; The "example" target is an empty shell (main.c is
                     ;; a bare #include); the real library with exported
                     ;; C API symbols is the upstream core_shared build.
                     (built "build/lib/libwebview.so"))
                (mkdir-p lib)
                (copy-file built (string-append lib "/libwebview.so"))
                ;; The CL binding dlopens the versioned soname.
                (symlink "libwebview.so"
                         (string-append lib "/libwebview.so.0.12.0"))))))))
    (native-inputs (list cmake-minimal pkg-config))
    (inputs
     `(("gtk+" ,gtk+)
       ("webkitgtk-for-gtk3" ,webkitgtk-for-gtk3)
       ("webview-upstream-src" ,webview-upstream-src)))
    (synopsis "Tiny cross-platform webview library (C shim for Lem)")
    (description
       "Webview is a tiny cross-platform library to build modern
cross-platform GUI applications around a single shared webview,
reusing a native WebView engine.  This package builds the C shim from
Lem's fork, which exposes the webview C++ core through a plain C API
for use with CFFI.")
    (home-page "https://github.com/webview/webview")
    (license license:expat)))

;;; CL bindings for the webview C shim.  The vendored prebuilt
;;; libwebview binaries under lib/ are deleted; the dlopen name is
;;; rewritten to the absolute path of the shim library built above.
(define-public sbcl-webview
  (package
    (name "sbcl-webview")
    (version "0.12.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/lem-project/webview")
             (commit "607daff93e9e716a76c5dbd08c48b5233c96b9a3")))
       (file-name (git-file-name name version))
       (sha256
        (base32 "18fgbvpgd587993m8lwdd80djsrc7pb2c5d1bq88znmmnz6rp5bx"))
       (snippet
        #~(begin
            (use-modules (guix build utils))
            (delete-file-recursively "lib")))))
    (build-system asdf-build-system/sbcl)
    (arguments
     (list
      #:tests? #f
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'patch-libwebview-path
            (lambda* (#:key inputs #:allow-other-keys)
              (substitute* "webview.lisp"
                (("\"libwebview\\.so\\.0\\.12\\.0\"")
                 (string-append
                  "\"" (search-input-file inputs "/lib/libwebview.so")
                  "\""))))))))
    (inputs
     `(("sbcl-cffi" ,sbcl-cffi)
       ("sbcl-float-features" ,sbcl-float-features)
       ("webview" ,webview)))
    (synopsis "Common Lisp bindings for the webview library")
    (description
       "This package provides CFFI bindings for webview, a tiny
cross-platform webview library, as used by Lem's webview frontend.")
    (home-page "https://github.com/lem-project/webview")
    (license license:expat)))

;;; micros pinned to the commit Lem's qlfile.lock tracks: lem-living-canvas
;;; uses CALL-GRAPH-ANALYZE-PACKAGE from the micros-call-graph contrib,
;;; which only exists since commit 08c3134.
(define-public sbcl-micros-lem
  (package
    (inherit sbcl-micros)
    (name "sbcl-micros-lem")
    (version "0.0.0-3.08c3134")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/lem-project/micros")
             (commit "08c313476bf436d72bcd5cd8f4e494d9f9323d08")))
       (file-name (git-file-name "micros" version))
       (sha256
        (base32 "0mas5wib4vdncj6g8qqk7fv42ccsaff707b5g43g4mirc3wdppg7"))))
    ;; The system defined in micros.asd is named "micros", not
    ;; "micros-lem".
    (arguments (list #:asd-systems ''("micros")))))

;;; jsonrpc pinned to the commit Lem's qlfile.lock tracks: Lem's server
;;; frontend passes the :silent initarg to the websocket transport,
;;; which only exists since commit 42fa96e.  All transport subsystems
;;; are built explicitly; jsonrpc.asd uses package-inferred systems, so
;;; e.g. jsonrpc/transport/stdio maps to transport/stdio.lisp.
(define-public sbcl-jsonrpc-lem
  (package
    (inherit sbcl-jsonrpc)
    (name "sbcl-jsonrpc-lem")
    (version "0.3.2-3.42fa96e")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/cxxxr/jsonrpc")
             (commit "42fa96ec34f6b6be77a6f12f7c4e84f375eff019")))
       (file-name (git-file-name "jsonrpc" version))
       (sha256
        (base32 "0na41pfvich9ck4q36k9n5z4mrr5k93z55mrq2npw7ggf2hsjvdl"))))
    (arguments
     (list
      #:asd-systems ''("jsonrpc"
                       "jsonrpc/transport/stdio"
                       "jsonrpc/transport/tcp"
                       "jsonrpc/transport/websocket"
                       "jsonrpc/transport/local-domain-socket")))))

;;; SPDX-FileCopyrightText: 2026 Raven Hallsby <raven@hallsby.com>
;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Zig libraries required by Ghostty, ported from GNU Guix PR 4087
;;; <https://codeberg.org/guix/guix/pulls/4087>.  That PR adds these to
;;; gnu/packages/zig-xyz.scm together with the zig-build-system changes the
;;; channel carries in (jeans build-system zig); both halves are needed for
;;; ghostty to build.
;;;
;;; Definitions are kept textually close to the PR.  Two deliberate deltas:
;;;
;;; - `#:zig zig-0.16' resolves to Guix's own zig-0.16 variable.  (Note that
;;;   plain `zig' is zig-0.13 in Guix, so the versioned variable is required.)
;;; - zig-zigimg and zig-translate-c shadow the packages of the same name in
;;;   (gnu packages zig-xyz): the PR pins commits newer than what Guix ships,
;;;   and Ghostty needs those exact revisions.

(define-module (jeans packages zig)
  #:use-module (guix build-system copy)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (jeans build-system zig)
  #:use-module (gnu packages)                    ; search-patches
  #:use-module ((gnu packages zig) #:select (zig-0.16))
  #:use-module ((gnu packages zig-xyz)
                #:hide (zig-zigimg zig-translate-c))
  #:use-module ((guix licenses) #:prefix license:))

(define-public zig-xml
  ;; There have been some pretty big updates since 0.2.0 was tagged.
  (let ((commit "4beab29d68ab308af4bd12a4fc4187c24fdad0d6")
        (revision "1"))
  (package
    (name "zig-xml")
    (version (git-version "0.2.0" revision commit))
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
              (url "https://github.com/ianprime0509/zig-xml")
              (commit commit)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1jcbp3cqx904n3wmnzlxr9nw6g38v31n5941c07l7qjzd52n0fb2"))))
    (build-system zig-build-system)
    (arguments
     (list
      #:zig zig-0.16))
    (home-page "https://ianjohnson.dev/zig-xml/")
    (synopsis "XML parser for Zig")
    (description
     "zig-xml is an XML library for Zig and parser written in Zig.")
    (license license:bsd-0))))

(define-public zig-aro
  ;; This commit is tip of the 0.16.x branch.  Guix does not have Zig 0.17
  ;; packaged yet.
  ;; No tags either.
  (let ((commit "f97cdfc3779aec4b242299e2fc9a1c828c3547c6")
        (revision "0"))
  (package
    (name "zig-aro")
    (version (git-version "0.0.1" revision commit))
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
              ;; A fork of vexu/arocc required for zig-translate-c and therefore
              ;; Ghostty.
              ;; vexu/arocc's last commit that used Zig 0.16 is
              ;; 5f5a050569a95ecc40a426f0c3666ae7ef987ede
              ;; TODO: Investigate compatibility between fork and upstream?
              (url "https://github.com/vancluever/arocc")
              (commit commit)))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "1yxzhbwdyazzg6xk75ql21ifk340cafqlyrdfy5r916a9s14vwqv"))
       (patches (search-patches
                  "jeans/patches/zig-aro-use-correct-test-runner.patch"))))
    (build-system zig-build-system)
    (arguments
     (list
      #:zig zig-0.16
      ;; Upstream CI uses this flag on its builds.
      #:zig-build-flags
      #~(list (string-append "-Doptimize=" "ReleaseSafe"))
      ;; TODO: Should zig-aro have its source installed for zig-translate-c?
      #:install-source? #t
      #:phases
      #~(modify-phases %standard-phases
          ;; Do not install the test binaries into output.  The PR hooks this
          ;; before a phase named `install', which zig-build-system deletes;
          ;; install-source is the phase that actually copies the tree.
          (add-before 'install-source 'remove-tests
            (lambda _
              (when (file-exists? "test-out")
                (delete-file-recursively "test-out")))))))
    (home-page "https://github.com/vancluever/arocc")
    (synopsis "C compiler with fast compilation and low memory usage")
    (description
     "@code{arocc} is a C compiler with the goal of providing fast compilation
and low memory usage with good diagnostics.  The project supports standard C and
all common extensions.")
    (license (list license:expat
                   license:unicode)))))

(define-public zig-uucode
  (let ((commit "9d55524551411b493cca41ca06363625d90aff1e")
        (revision "0"))
    (package
      (name "zig-uucode")
      (version (git-version "0.2.0" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
                (url "https://github.com/jacobsandlund/uucode")
                (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32
           "1z32b8yqvhggi7rkp5926491dghzjy9zad8kfx0ww9b58zzyk5i9"))))
      (build-system zig-build-system)
      (arguments
       (list
        #:zig zig-0.16
        #:install-source? #t))
      (home-page "https://github.com/jacobsandlund/uucode")
      (synopsis "Fast unicode library written in Zig")
      (description
       "A fast and flexible unicode library written in Zig that is fully
configurable at build time.")
      (license (list license:expat
                     (license:non-copyleft "file:///licenses/LICENSE_Bjoern_Hoehrmann")
                     license:unicode)))))

(define-public zig-zigimg
  ;; No tagged release.
  (let ((commit "d695acd97c02e57bb151e8f659d1280f5cd6ca70")
        (revision "1"))
    (package
      (name "zig-zigimg")
      (version (git-version "0.1.0" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/zigimg/zigimg")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "08dvw349m8swfpk3pai67axik1mhhbylyxhlqn4sfksx156h11nh"))))
      (build-system zig-build-system)
      (arguments
       (list
        #:zig zig-0.16
        #:phases
        #~(modify-phases %standard-phases
            (add-before 'check 'copy-test-suite-fixtures
              (lambda* (#:key inputs #:allow-other-keys)
                (let ((tests-name (string-append #$name "-" #$version "-test-suite")))
                  ;; By default, this path is put into a buffer that is
                  ;; zigimg.io.DEFAULT_BUFFER_SIZE=4096 bytes large, so the
                  ;; path rewrite into the store should not overrun the buffer.
                  (substitute* "tests/helpers.zig"
                    (("../test-suite/fixtures/")
                     (string-append (assoc-ref inputs tests-name)
                                    "/fixtures/")))))))))
      (native-inputs
       (list
        (origin
          (method git-fetch)
          (uri (git-reference
                 (url "https://github.com/zigimg/test-suite")
                 (commit "072fcaa45201a6c48d65a741881b8f3eab77412e")))
          (file-name (string-append name "-" version "-test-suite"))
          (sha256
           (base32 "102ls7a7awydv0zk4m9q95cbsz6a05ylg246hilmiy24m4kd3bw3")))))
      (home-page "https://github.com/zigimg/zigimg")
      (synopsis "Zig image library")
      (description
       "@code{zigimg} is a Zig library for reading and writing different image
formats.")
      (license license:expat))))

;; FIXME: Perhaps this should just be named libxev?  It is meant to be
;; consumable by C projects too.
(define-public zig-libxev
  ;; No tags.
  (let ((commit "a82a04eabb46b0611c72d6d0e32db2d9dcf2e745")
        (revision "0"))
    (package
      (name "zig-libxev")
      (version (git-version "0.0.1" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
                (url "https://github.com/mitchellh/libxev")
                (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32
           "1bksdjgvwd9ls7vgg6imhxghhyz9x06igpwv3r0xl7h8kylni9hi"))))
      (build-system zig-build-system)
      (arguments
       (list
        #:zig zig-0.16))
      (home-page "https://github.com/mitchellh/libxev")
      (synopsis "Cross-platform, high-performance event loop library")
      (description
       "libxev is a cross-platform, high-performance event loop that provides
abstractions for non-blocking IO, timers, events, and more and works on Linux
(io_uring or epoll), macOS (kqueue), and Wasm + WASI.")
      (license license:expat))))

;; FIXME: Perhaps this should just be named libvaxis?  It is meant to be
;; consumable by C projects too.
(define-public zig-libvaxis
  ;; Untagged, but marked in build.zig.zon.
  (let ((commit "173a890d1394946b5d7623c66cd34bcd36d8eeb8")
        (revision "0"))
    (package
      (name "zig-libvaxis")
      (version (git-version "0.6.0" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
                (url "https://github.com/rockorager/libvaxis")
                (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32
           "053hlnrbkj7dl060lwmmvkhrqpbl1680lyj4j7psyq3l5j22b45p"))))
      (build-system zig-build-system)
      (arguments
       (list
        #:zig zig-0.16
        #:phases
        #~(modify-phases %standard-phases
            (add-before 'unpack-dependencies 'prepare-build.zig.zon
              (lambda _
                (substitute* "build.zig.zon"
                  (("\\.uucode") ".@\"zig-uucode\"")
                  (("\\.zigimg") ".@\"zig-zigimg\""))))
            (add-after 'unpack-dependencies 'revert-build.zig.zon
              (lambda _
                (substitute* "build.zig.zon"
                  (("\\.@\"zig-uucode\"") ".uucode")
                  (("\\.@\"zig-zigimg\"") ".zigimg")))))))
      (native-inputs
       (list zig-uucode
             zig-zigimg))
      (home-page "https://rockorager.github.io/libvaxis/")
      (synopsis "Modern TUI library written in Zig")
      (description
       "Libvaxis provides both a low level API suitable for making applications
of any sort as well as a higher level framework.  The low level API is suitable
for making applications of any type, providing your own event loop, and gives
you full control over each cell on the screen.

The high level API, called @code{vxfw} (Vaxis framework), provides a
Flutter-like style of API.

Libvaxis does not use terminfo.  Support for vt features is detected through
terminal queries.")
      (license license:expat))))

(define-public zig-gobject
  ;; No tagged releases.
  (let ((commit "4ff7b4d030465b50796b90af72fec41eb9b3b5c6")
        (revision "0"))
  (package
    (name "zig-gobject")
    (version (git-version "0.3.2" revision commit))
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
              (url "https://github.com/jcollie/zig-gobject")
              (commit commit)))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "1frw5slj23wngv6iwi1dw4ii99fpr7skkrk71jrbs1gnii4mypgp"))))
    (build-system zig-build-system)
    (arguments
     (list
      #:zig zig-0.16
      #:phases
      #~(modify-phases %standard-phases
          (add-before 'unpack-dependencies 'prepare-build.zig.zon
            (lambda _
              (substitute* "build.zig.zon"
                (("\\.xml") ".@\"zig-xml\""))))
          (add-after 'unpack-dependencies 'revert-build.zig.zon
            (lambda _
              (substitute* "build.zig.zon"
                (("\\.@\"zig-xml\"") ".xml")))))))
    (native-inputs (list zig-xml))
    (home-page "https://ianjohnson.dev/zig-gobject/")
    (synopsis "GObject bindings for Zig using GObject introspection")
    (description
     "Bindings for GObject-based libraries (such as GTK) generated using GObject
introspection data.")
    (license license:bsd-0))))

;; (define-public zig-gobject-ghostty
;;   (package
;;     (name "zig-gobject-ghostty")
;;     (version "0.10.0-2026-07-28-36-1")
;;     (source
;;      (origin
;;        (method git-fetch)
;;        (uri (git-reference
;;               (url "https://github.com/ghostty-org/zig-gobject")
;;               (commit version)))
;;        (file-name (string-append name "-" version))
;;        (sha256
;;         (base32
;;          "04fgpir1vac126bavdjzk84wpjcdrd8n6jvba2jkkks80cih8py6"))))
;;     (build-system zig-build-system)
;;     (arguments
;;      (list
;;       #:zig zig-0.16
;;       #:phases
;;       #~(modify-phases %standard-phases
;;           (add-before 'unpack-dependencies 'prepare-build.zig.zon
;;             (lambda _
;;               (substitute* "build.zig.zon"
;;                 (("\\.gobject_codegen") ".@\"zig-gobject\""))))
;;           (add-after 'unpack-dependencies 'revert-build.zig.zon
;;             (lambda _
;;               (substitute* "build.zig.zon"
;;                 (("\\.@\"zig-gobject\"") ".gobject_codegen"))))
;;           ;; XXX: Custom build phase because -Dtarget is not supported by this
;;           ;; package's build.zig.zon.  Disables parallel building.  This package
;;           ;; also has no possible optimizations.
;;           (replace 'build
;;             (lambda* (#:key
;;                       zig-build-flags
;;                       zig-build-target
;;                       #:allow-other-keys)
;;               (setenv "DESTDIR" "out")
;;               (let* ((call `("zig" "build"
;;                              "--prefix"             ""            ;; Don't add /usr
;;                              "--prefix-lib-dir"     "lib"
;;                              "--prefix-exe-dir"     "bin"
;;                              "--prefix-include-dir" "include"
;;                              "--verbose"
;;                              ,@zig-build-flags)))
;;                 (format #t "running: ~s~%" call)
;;                 (apply invoke call)))))))
;;     (native-inputs
;;      (list ;; gdk
;;            ;; glib
;;            zig-gobject
;;            zig-xml))
;;     (home-page "https://github.com/ghostty-org/zig-gobject")
;;     (synopsis "GObject bindings for Zig using GObject introspection for Ghostty")
;;     (description
;;      "Bindings for GObject-based libraries (such as GTK) generated using GObject
;; introspection data, specifically for ghostty.")
;;     (license license:expat)))

;; FIXME: Replace this fetched version with one we clone, provide our own
;; sources, and produce our own Zig files from all of our own sources.

(define-public zig-translate-c
  ;; This commit is tip of the 0.16.x branch.  Guix does not have Zig 0.17
  ;; packaged yet.
  (let ((commit "4e879eb8aba615de112eabd1231ea6e01920cead")
        (revision "0"))
    (package
      (name "zig-translate-c")
      ;; 1.0.0 is the most recent release, but is unrelated to the commit we
      ;; want.
      (version (git-version "1.0.0" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
                (url "https://codeberg.org/vancluever/translate-c")
                (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32
           "0vq2nmmbilyzzpjfacilyk6rcf4hzyb84hd1qmsyvy59q9dzpi7y"))))
      (build-system zig-build-system)
      (arguments
       (list
        #:zig zig-0.16
        #:install-source? #t
        #:phases
        #~(modify-phases %standard-phases
            (add-before 'unpack-dependencies 'prepare-build.zig.zon
              (lambda _
                (substitute* "build.zig.zon"
                  (("\\.aro") ".@\"zig-aro\""))))
            (add-after 'unpack-dependencies 'revert-build.zig.zon
              (lambda _
                (substitute* "build.zig.zon"
                  (("\\.@\"zig-aro\"") ".aro"))))
            )))
      (native-inputs (list zig-aro))
      (home-page "https://codeberg.org/vancluever/translate-c")
      (synopsis "Translate C code into Zig code")
      (description
       "Translate C code into Zig code.  Intended to replace @code{@@cImport}
and @code{zig translate-c}.")
      (license license:expat))))

(define-public zig-zf
  ;; Untagged, but marked in build.zig.zon.
  (let ((commit "c35c421f84895193246db06c40683c1a30e616ef")
        (revision "0"))
  (package
    (name "zig-zf")
    (version (git-version "0.11.0" revision commit))
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
              (url "https://github.com/natecraddock/zf")
              (commit commit)))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "1819400i4zvx6y9i1dczq9b5x4rhxcjzqp86y17kiwla19dsnyrc"))))
    (build-system zig-build-system)
    (arguments
     (list
      #:zig zig-0.16
      #:zig-build-flags
      #~(list "-Dwith_tui=false")
      #:zig-test-flags
      #~(list "-Dwith_tui=false")
      #:phases
      #~(modify-phases %standard-phases
          (add-before 'unpack-dependencies 'prepare-build.zig.zon
            (lambda _
              (substitute* "build.zig.zon"
                (("\\.vaxis") ".@\"zig-libvaxis\""))))
          (add-after 'unpack-dependencies 'revert-build.zig.zon
            (lambda _
              (substitute* "build.zig.zon"
                (("\\.@\"zig-libvaxis\"") ".vaxis")))))))
    (native-inputs
     ;; FIXME: WE SHOULD NOT NEED TO SPECIFY zig-uucode & zig-zigimg for
     ;; zig-zf.  Those should propagate somehow! zig-zf only depends on
     ;; zig-libvaxis.
     (list zig-libvaxis
           zig-uucode
           zig-zigimg))
    (home-page "https://github.com/natecraddock/zf")
    (synopsis "Command-line fuzzy finder and file path filter")
    (description
     "zf is a general-purpose fuzzy finder that particularly excels at filtering
file paths.")
    (license license:expat))))

(define-public zig-z2d
  (package
    (name "zig-z2d")
    (version "0.12.1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
              (url "https://github.com/vancluever/z2d")
              (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "17b4lqrcan97a0s5qz8pkch0g51rk66zcd06xma3r8zl34wzafhn"))))
    (build-system zig-build-system)
    (arguments
     (list
      ;; Min version is technically 0.14, but let's put as many things up at
      ;; 0.16 as possible.
      #:zig zig-0.16))
    (home-page "https://z2d.vancluevertech.com/docs/")
    (synopsis "Pure Zig 2D graphics library")
    (description
     "z2d is a 2D graphics library that rasterizes shapes composed of
vector primitives: lines and cubic Beziers, e.g., things you would need if you
were rendering something like an SVG file, or rendering shapes directly for UI
elements.")
    (license (list license:bsd-0
                   license:bsd-3
                   license:expat
                   ;; z2d is MPL2.0, other pieces are other licenses.
                   license:mpl2.0
                   license:silofl1.1
                   license:w3c))))

;; FIXME: Replace this fetched version with one we clone, provide our own
;; sources, and produce our own Zig files from all of our own sources.
(define-public zig-gobject-ghostty
  (hidden-package
   (package
     (name "zig-gobject-ghostty")
     (version "0.10.0-2026-07-28-36-1")
     (source
      (origin
        (method url-fetch)
        (uri (string-append
              "https://github.com/ghostty-org/zig-gobject/releases/download/"
              version
              "/ghostty-gobject-" version ".tar.gz"))
        (sha256
         (base32
          "15h1nz6iz9184gb9zm89kwd9m78w3wxgxqs0qz36m93jhrp8hwnm"))))
     (build-system copy-build-system)
     (arguments
      (list
       #:install-plan
       #~`(("." ,(string-append "/src/zig/" #$name "-" #$version)))))
     (home-page "https://ghostty.org/")
     (synopsis "Ghostty-specific GObject bindings in Zig")
     (description
      "Ghostty-specific GObject bindings in Zig")
     (license license:expat))))

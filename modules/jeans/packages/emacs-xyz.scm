;;; SPDX-FileCopyrightText: 2026 Andrew Tropin <andrew@trop.in>
;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (jeans packages emacs-xyz)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix gexp)
  #:use-module (guix build-system copy)
  #:use-module (guix build-system emacs)
  #:use-module (guix build-system gnu)
  #:use-module (gnu packages)
  #:use-module (gnu packages backup)         ; libarchive (bsdtar for .zst deb)
  #:use-module (gnu packages base)           ; glibc
  #:use-module (gnu packages bash)
  #:use-module (gnu packages bootstrap)      ; glibc-dynamic-linker
  #:use-module (gnu packages elf)            ; patchelf
  #:use-module (gnu packages fontutils)      ; fontconfig
  #:use-module (gnu packages freedesktop)    ; wayland (libwayland-*)
  #:use-module (gnu packages gcc)            ; gcc "lib"
  #:use-module (gnu packages gl)             ; mesa (libEGL/libGL/libgbm)
  #:use-module (gnu packages glib)           ; glib
  #:use-module (gnu packages gstreamer)      ; gstreamer, gst-plugins-base
  #:use-module (gnu packages ncurses)        ; ncurses (libtinfo)
  #:use-module (gnu packages compression)    ; zlib
  #:use-module (gnu packages vulkan)         ; vulkan-loader (wgpu ash backend)
  #:use-module (gnu packages xdisorg)        ; libxkbcommon
  #:use-module (gnu packages xorg)           ; libx11, libxcb, libxi, libxcursor
  #:use-module (gnu packages zig)
  #:use-module (gnu packages emacs)
  #:use-module (gnu packages emacs-xyz)
  #:use-module (gnu packages emacs-build)
  #:use-module (jeans packages tools)          ; agenote (propagated by emacs-agenote)
  #:use-module ((guix licenses) #:prefix license:))

;; Ghostel vendors ghostty and uucode as build-time git sources.  Earlier
;; revisions inlined these origins inside a (let*) wrapping the package
;; body, which confuses scripts/check-updates/update_versions.py: its
;; r"\\(uri\s+(.+?)\)\s+\\(sha256" regex picks up the inner ghostty
;; origin as if it were the package source.  Hoisting the supporting
;; origins to module top level keeps the emacs-ghostel package definition
;; block free of nested (origin ...) forms.
(define %ghostel-patches
  (map canonicalize-path
       (search-patches "jeans/patches/emacs-ghostel-build.zig.patch")))

(define %ghostel-ghostty-patches
  (map canonicalize-path
       (search-patches
        "jeans/patches/emacs-ghostel-ghostty-build.zig.zon.patch"
        "jeans/patches/emacs-ghostel-ghostty-exe.zig.patch"
        "jeans/patches/emacs-ghostel-ghostty-bench.zig.patch"
        "jeans/patches/emacs-ghostel-ghostty-framedata.zig.patch"
        "jeans/patches/emacs-ghostel-ghostty-resources.zig.patch")))

(define %ghostel-ghostty-source
  (let ((commit "ab0b9da9e88fcb4b0533a1854e84628f663930af"))
    (origin
      (method url-fetch)
      (uri (string-append
             "https://github.com/ghostty-org/ghostty"
             "/archive/" commit ".tar.gz"))
      (sha256
       (base32 "02ymjk7qw8c9bbc5fn96xfc9kyvibysclky0m90vqq40x5kzl7v5"))
      (patches %ghostel-ghostty-patches))))

;; uucode is pinned to commit 2826a37a (not the v0.2.0 tag) because that is
;; the exact revision ghostty's build.zig.zon vendors for ghostel 0.46.0; its
;; build.zig was rewritten for the zig 0.16 API, while the v0.2.0 tag still
;; targets zig 0.15 and fails to compile under zig-0.16.
(define %ghostel-uucode-source
  (origin
    (method url-fetch)
    (uri (string-append
          "https://github.com/jacobsandlund/uucode/archive/"
          "2826a37a4562284fdacd8fa029d49509cc9bffcd.tar.gz"))
    (sha256
     (base32 "17mwjh2ha4yb9cdgxixz3a23kimqwnrvnd9bqllcfyhymdzzqxky"))))

(define-public emacs-ghostel
  (package
    (name "emacs-ghostel")
    (version "0.48.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/dakra/ghostel")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0wagk9rzsyp910ch3nx57546fpzb8m27il7xvwf31nqzihpir4ms"))
       (patches %ghostel-patches)))
      (build-system emacs-build-system)
      (arguments
       (list
        #:lisp-directory "lisp"
        #:tests? #f
        ;; 'redirect-ghostty-dependency' rewrites build.zig.zon in Scheme
        ;; using read-string (ice-9 rdelim) and regexp-substitute/global
        ;; (ice-9 regex).  emacs-build-system's default #:modules only
        ;; imports them privately, so the free variables are unbound in the
        ;; builder's (guile-user).  Add the modules explicitly.
        #:modules '((guix build emacs-build-system)
                    (guix build utils)
                    (ice-9 rdelim)
                    (ice-9 regex))
        #:phases
        #~(modify-phases %standard-phases
            (delete 'patch-el-files)
            ;; The Zig-built native module links against system libraries
            ;; and zig cache paths that don't satisfy Guix's RUNPATH
            ;; validator.  Disable the check rather than patch the build.
            (delete 'validate-runpath)
            (add-after 'unpack 'redirect-ghostty-dependency
              (lambda _
                ;; emacs-build-system 'unpack chdirs into 'lisp-directory,
                ;; so the source root is one level up.  Rewrite the
                ;; .ghostty dependency in build.zig.zon to point at the
                ;; ./deps/ghostty directory we populate below, so the build
                ;; never touches the network.  We do this in scheme by
                ;; rewriting the file rather than using a patch file
                ;; because the ghostty URL/hash inside the dependency
                ;; block changes between ghostel releases (e.g. 0.39.0 ->
                ;; 0.41.0) and a context-sensitive patch would need to be
                ;; regenerated for every bump.  substitute* is line-based
                ;; so it cannot collapse the four-line .url/.hash block
                ;; into the single-line .path form on its own.
                (let* ((source-root (dirname (getcwd)))
                       (zon (string-append source-root "/build.zig.zon"))
                       (original (with-input-from-file zon
                                   (lambda () (read-string)))))
                  ;; Replace the entire .ghostty dependency block (canonical
                  ;; multi-line .url/.hash form) with a single .path entry
                  ;; that points at the ./deps/ghostty directory populated in
                  ;; the next phase.  The block looks like:
                  ;;   .ghostty = .{
                  ;;       .url = "...tar.gz",
                  ;;       .hash = "...",
                  ;;   },
                  ;; so anchor on ".ghostty = .{" and consume up to and
                  ;; including the matching "}," (the first one after the
                  ;; opening brace, since ghostty has no nested braces here).
                  (let* ((pattern
                          "        \\.ghostty = \\.\\{[^}]+\\},")
                         (rewritten
                          (regexp-substitute/global #f pattern original
                            'pre
                            "        .ghostty = .{ .path = \"./deps/ghostty\" },"
                            'post)))
                    (call-with-output-file zon
                      (lambda (port) (display rewritten port)))))))
            (add-after 'redirect-ghostty-dependency 'unpack-zig-dependencies
              (lambda _
                (let* ((source-root (dirname (getcwd)))
                       (deps (string-append source-root "/deps")))
                  (setenv "GUIX_GHOSTEL_SOURCE_ROOT" source-root)
                  (mkdir-p deps)
                  ;; url-fetch origins are stored as tarballs; extract them
                  ;; rather than copy-recursively (which would copy the file as-is).
                  (let ((ghostty-dir (string-append deps "/ghostty")))
                    (mkdir-p ghostty-dir)
                    (invoke "tar" "xf" #$%ghostel-ghostty-source
                            "-C" ghostty-dir "--strip-components=1"))
                  (let ((uucode-dir (string-append deps "/uucode")))
                    (mkdir-p uucode-dir)
                    (invoke "tar" "xf" #$%ghostel-uucode-source
                            "-C" uucode-dir "--strip-components=1"))
                  (for-each make-file-writable
                            (find-files deps #:directories? #t)))))
            (add-after 'unpack-zig-dependencies 'patch-guix-specific-shell-paths
              (lambda _
                ;; Keep local /bin/sh references patched to the store, but
                ;; do not leak store paths into remote TRAMP and Docker hosts.
                (substitute* "ghostel.el"
                  (("\\(\"docker\" \"[^\"]*/bin/sh\"\\)")
                   "(\"docker\" \"/bin/sh\")")
                  (("\\(list \"([^\"]*/bin/sh)\" \"-c\"" _ shell)
                   (string-append
                    "(list (if remote-p \"/bin/sh\" \""
                    shell "\") \"-c\"")))))
            (add-after 'unpack-zig-dependencies 'build-native-module
              (lambda* (#:key outputs inputs #:allow-other-keys)
                ;; zig build must run from the source root where build.zig
                ;; lives; phases other than 'unpack see cwd under the
                ;; lisp directory or the ELPA install directory, so read
                ;; the source root that 'unpack-zig-dependencies stashed.
                (let* ((out (assoc-ref outputs "out"))
                       (root (getenv "GUIX_GHOSTEL_SOURCE_ROOT")))
                  (with-directory-excursion root
                    (mkdir-p "zig-cache/global")
                    (mkdir-p "zig-cache/local")
                    (setenv "HOME" root)
                    (setenv "EMACS_INCLUDE_DIR"
                            (string-append (assoc-ref inputs "emacs")
                                           "/include"))
                    (setenv "ZIG_GLOBAL_CACHE_DIR"
                            (string-append root "/zig-cache/global"))
                    (setenv "ZIG_LOCAL_CACHE_DIR"
                            (string-append root "/zig-cache/local"))
                    (invoke "zig" "build" "install"
                            "--prefix" out
                            "-Doptimize=ReleaseFast"
                            "-Dcpu=baseline")))))
            (add-after 'install 'install-resources
              (lambda* (#:key outputs #:allow-other-keys)
                (let* ((out (assoc-ref outputs "out"))
                       (root (getenv "GUIX_GHOSTEL_SOURCE_ROOT"))
                       (elpa-dir (elpa-directory out)))
                  (copy-recursively (string-append root "/etc")
                                    (string-append elpa-dir "/etc"))
                  ;; Since 0.42.0 ghostel's build.zig installs the native
                  ;; module via addInstallFile(lib.getEmittedBin(),
                  ;; moduleOutputName(target_os)) — i.e. directly to
                  ;; $out/ghostel-module.so (no 'lib/' prefix, no 'lib' soname
                  ;; prefix).  The version sidecar is likewise written by
                  ;; build.zig to $out/ghostel-module.version.  ghostel--load-
                  ;; module (ghostel-module-install.el) looks both up with
                  ;; (expand-file-name "ghostel-module" module-file-suffix)
                  ;; inside the ELPA directory, so relocate them there.  The
                  ;; pre-0.42 layout ($out/lib/libghostel-module.so produced by
                  ;; installArtifact) no longer exists.
                  (copy-file (string-append out "/ghostel-module.so")
                             (string-append elpa-dir "/ghostel-module.so"))
                  (copy-file (string-append out "/ghostel-module.version")
                             (string-append elpa-dir
                                            "/ghostel-module.version"))))))))
      (native-inputs (list zig-0.16))
      (home-page "https://github.com/dakra/ghostel")
      (synopsis "Terminal emulator powered by libghostty")
      (description
       "Ghostel is an Emacs terminal emulator powered by @code{libghostty-vt},
the VT engine from Ghostty.  It uses a native Zig dynamic module for terminal
state and rendering, while Emacs Lisp manages buffers, processes, keymaps,
shell integration, and user commands.")
      (license (list license:gpl3+
                     license:expat
                     license:asl2.0
                     license:unicode))))
;; Emacs plugins previously lived in tools.scm; migrated here so all
;;; emacs-* packages share one definition file.

(define-public emacs-msgu
  (package
    (name "emacs-msgu")
    (version "0.1.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/jcs-elpa/msgu")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "15brivkix3q0q32q8c3byzy7rl1x6zlgwkvz6ydx2dpyfpb1wyr6"))))
    (build-system emacs-build-system)
    (arguments
     (list #:tests? #f))
    (home-page "https://github.com/jcs-elpa/msgu")
    (synopsis "Utility functions for message output in Emacs")
    (description
     "msgu provides utility functions to help with outputting messages in Emacs.
It includes macros for silencing messages, preserving colored output in the
*Messages* buffer, and helper functions for sleep/sit-for with defaults.")
    (license license:gpl3+)))

(define-public emacs-ellsp
  (package
    (name "emacs-ellsp")
    (version "0.2.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/elisp-lsp/Ellsp")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "11jhr241rv0b4v6lw4532nps3c3izq62c0hf8h78d5ijwhyknlr6"))))
    (build-system emacs-build-system)
    (arguments
     (list #:tests? #f))
    (propagated-inputs
     (list emacs-lsp-mode
           emacs-company
           emacs-dash
           emacs-s
           emacs-msgu
           emacs-log4e))
    (home-page "https://github.com/elisp-lsp/Ellsp")
    (synopsis "Elisp Language Server Protocol server (Emacs backend)")
    (description
     "Ellsp is a Language Server Protocol (LSP) server for Emacs Lisp.
This package provides the Emacs Lisp backend that implements completion,
hover, signature help, and code actions for Elisp files via the LSP protocol.
It requires lsp-mode, company, and several utility libraries to function.")
    (properties `((accept-pre-releases? . #t)))
    (license license:gpl3+)))

(define-public ellsp-bin
  (package
    (name "ellsp-bin")
    (version "0.2.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/elisp-lsp/Ellsp/releases/download/"
             version "/ellsp_linux-x64.tar.gz"))
       (sha256
        (base32 "15ra839lvab22dm135swygn2v4l1ib4li52p0f7mh6y9yc5nbhaj"))))
    (build-system copy-build-system)
    (arguments
     (list
      #:validate-runpath? #f
      #:strip-binaries? #f
      #:tests? #f
      #:install-plan
      #~'(("ellsp" "libexec/ellsp/"))
      #:phases
      #~(modify-phases %standard-phases
          (delete 'install-license-files)
          (add-after 'install 'make-binary-executable
            (lambda _
              (chmod (string-append #$output "/libexec/ellsp/ellsp") #o555)))
          (add-after 'make-binary-executable 'create-wrapper
            (lambda* (#:key inputs #:allow-other-keys)
              (let ((bin (string-append #$output "/bin"))
                    (libexec (string-append #$output "/libexec/ellsp/ellsp"))
                    (emacs-bin (search-input-file inputs "bin/emacs")))
                (mkdir-p bin)
                (call-with-output-file (string-append bin "/ellsp")
                  (lambda (port)
                    (format port
                            "#!~a/bin/sh\nexport ELLSP_EMACS=~a\nexec ~a \"$@\"\n"
                            #$(this-package-input "bash-minimal")
                            emacs-bin
                            libexec)))
                (chmod (string-append bin "/ellsp") #o755)))))))
    (inputs (list bash-minimal))
    (propagated-inputs
     (list emacs emacs-ellsp))
    (home-page "https://github.com/elisp-lsp/Ellsp")
    (synopsis "Elisp Language Server Protocol server")
    (description
     "Ellsp is a Language Server Protocol (LSP) server for Emacs Lisp.
It consists of a Node.js proxy that communicates with LSP clients via
stdin/stdout, and an Emacs Lisp backend that provides completion, hover,
signature help, and code actions for Elisp files.  This package provides
the prebuilt proxy binary.")
    (properties `((upstream-name . "ellsp") (accept-pre-releases? . #t)))
    (license license:gpl3+)
    (supported-systems '("x86_64-linux"))))

;;; Eask: CLI tool for building, testing and managing Emacs packages.
;;;
;;; The upstream release is a statically linked ELF binary built with
;;; @yao-pkg/pkg (Node.js runtime embedded).  It internally locates Emacs
;;; via the EMACS or ELLSP_EMACS environment variable, or the system PATH.
;;;
;;; The binary ships with a bundled lisp/ directory used at runtime to
;;; locate Emacs Lisp scripts.  We install the binary to libexec/ and
;;; create a bin/ wrapper that sets EMACS to Guix's emacs.

(define-public eask-bin
  (package
    (name "eask-bin")
    (version "0.12.9")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/emacs-eask/cli/releases/download/"
             version "/eask_" version "_linux-x64.tar.gz"))
       (sha256
        (base32 "0nkdmiii8biyyfjzz9pg7w2l4jwb2dkkh7inaxa807af0in38rk3"))))
    (build-system gnu-build-system)
    (arguments
     (list
      #:validate-runpath? #f
      #:strip-binaries? #f
      #:tests? #f
      #:modules '((guix build gnu-build-system)
                  (guix build utils))
      #:phases
      #~(modify-phases %standard-phases
          (delete 'configure)
          (delete 'build)
          (add-after 'unpack 'back-to-root
            (lambda _
              ;; gnu-build-system unpack chdirs into first subdir (lisp/);
              ;; go back so we can access both eask binary and lisp/.
              (chdir "..")))
          (replace 'install
            (lambda* (#:key inputs #:allow-other-keys)
              (let* ((out #$output)
                     (bin (string-append out "/bin"))
                     (libexec (string-append out "/libexec/eask"))
                     (emacs-bin (search-input-file inputs "bin/emacs")))
                (mkdir-p libexec)
                (install-file "eask" libexec)
                (chmod (string-append libexec "/eask") #o555)
                (copy-recursively "lisp" (string-append libexec "/lisp"))
                (mkdir-p bin)
                (call-with-output-file (string-append bin "/eask")
                  (lambda (port)
                    (format port
                            "#!~a/bin/sh\nexport EMACS=~a\nexec ~a \"$@\"\n"
                            #$(this-package-input "bash-minimal")
                            emacs-bin
                            (string-append libexec "/eask"))))
                (chmod (string-append bin "/eask") #o755)))))))
    (inputs (list bash-minimal emacs))
    (propagated-inputs '())
    (properties `((upstream-name . "eask")))
    (home-page "https://github.com/emacs-eask/cli")
    (synopsis "CLI tool for building, testing and managing Emacs packages")
    (description
     "Eask is a CLI tool that helps you build, test, and manage Emacs packages.
It provides a consistent build environment regardless of your Emacs
configuration, supporting batch operations, linting, testing, and packaging
of Emacs Lisp projects.  This package provides the prebuilt binary release.")
    (license license:gpl3+)
    (supported-systems '("x86_64-linux"))))

;;; Neomacs (NEO Emacs) is a from-scratch reimplementation of an
;;; Emacs-like, programmable text editor in Rust.  Instead of the Emacs
;;; C engine, it runs Emacs Lisp on top of a Neovim-derived virtual
;;; machine (neovm).  The GUI is rendered with wgpu and the layout comes
;;; from a dedicated engine; it can also embed terminals (alacritty)
;;; and play media via GStreamer.
;;;
;;; This package wraps the official prebuilt Linux .deb, which ships a
;;; set of x86_64 ELF binaries plus a pre-dumped runtime image
;;; (neomacs.pdump) and the full Lisp/Etc data tree
;;; (usr/share/neomacs/{lisp,etc,leim}).
;;;
;;; Upstream's self-locator logic is FHS-specific, so we must respect it:
;;;
;;;   * The .pdump for an executable lives NEXT TO the executable, named
;;;     "<exe-name>.pdump" (see neovm-core load.rs:
;;;     runtime_image_path_for_executable => exe.parent().join(exe+".pdump")).
;;;   * The Lisp/Etc runtime root is resolved as
;;;     exe.parent().parent().join("share/neomacs") (load.rs:
;;;     runtime_project_root), i.e. <prefix>/share/neomacs where <prefix>
;;;     is two levels up from the binary.
;;;
;;; Consequence: an ld-linux wrapper CANNOT be used, because it makes
;;; /proc/self/exe point at the wrapper script and breaks the
;;; self-locator.  We therefore patchelf every ELF in place (set
;;; interpreter + RPATH) and lay them out as:
;;;
;;;   out/bin/neomacs            (patchelf'd)
;;;   out/bin/neomacs.pdump      (sibling pdump, see above)
;;;   out/bin/neomacsclient ...
;;;   out/share/neomacs/         (<prefix>=out, two levels: bin/../ = out)
;;;
;;; The deb's data.tar is zstd-compressed, hence libarchive's bsdtar.
;;;
;;; Runtime ELF dependencies (readelf -d neomacs): libtinfo.so.6,
;;; libgst{video,app}-1.0.so.0, libgstreamer-1.0.so.0,
;;; libgobject-2.0.so.0, libglib-2.0.so.0, libfontconfig.so.1,
;;; libz.so.1, libgcc_s.so.1, libm/libc.so.6.  The Deb control only
;;; declares libfontconfig1 + libglib2.0-0 but the binary is linked
;;; against many more, so we add the full set.

(define-public neomacs-bin
  (package
    (name "neomacs-bin")
    (version "0.0.14")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/eval-exec/neomacs/releases/download/"
             "v" version "/neomacs_" version "_amd64.deb"))
       (sha256
        (base32 "0yf6mpqcwr293amq81xrcy7c8xzqplql35ljqhl1cw8gqiksy8zw"))))
    (build-system gnu-build-system)
    (arguments
     (list
      #:tests? #f
      #:validate-runpath? #f
      #:strip-binaries? #f
      #:modules '((guix build gnu-build-system)
                  (guix build utils))
      #:phases
      #~(modify-phases %standard-phases
          (delete 'configure)
          (delete 'build)
          (replace 'unpack
            (lambda _
              ;; .deb = ar archive: debian-binary, control.tar.zst,
              ;; data.tar.zst.  bsdtar handles both the ar wrapper and
              ;; the zstd payload in one go.
              (invoke "bsdtar" "xf" #$source)
              (invoke "bsdtar" "xf" "data.tar.zst")))
          (replace 'install
            (lambda* (#:key inputs #:allow-other-keys)
              (let* ((out #$output)
                     (bin (string-append out "/bin"))
                     (lib (string-append out "/lib"))
                     (share (string-append out "/share/neomacs"))
                     (ldso (string-append (assoc-ref inputs "glibc")
                                          #$(glibc-dynamic-linker)))
                     (patchelf-bin
                      (string-append (assoc-ref inputs "patchelf")
                                     "/bin/patchelf"))
                     ;; NOTE: assoc-ref (not this-package-input) is used for
                     ;; every input on purpose: for multi-output inputs such
                     ;; as ("gcc:lib" ,gcc "lib"), assoc-ref returns the store
                     ;; path of the *bound output* (the lib output), whereas
                     ;; #$(this-package-input ...) yields the package record and
                     ;; the gexp then dereferences its DEFAULT output (the gcc
                     ;; main output, which lacks libgcc_s.so.1).  This is the
                     ;; "gexp default-output" footgun documented in AGENTS.md.
                     (gcc-lib (string-append (assoc-ref inputs "gcc:lib") "/lib"))
                     (ncurses-lib (string-append (assoc-ref inputs "ncurses") "/lib"))
                     ;; RPATH over every runtime library input + our own lib/
                     ;; (which carries the libtinfo.so.6 compatibility symlink,
                     ;; see below).
                     ;;
                     ;; IMPORTANT: this includes the GUI windowing/GPU stack
                     ;; (wayland, mesa, vulkan-loader, libxkbcommon, the X11
                     ;; libs).  winit/wgpu do NOT list these in readelf NEEDED
                     ;; -- they are dlopen'd at runtime (libwayland-client.so,
                     ;; libxkbcommon.so on Wayland; libX11.so/libxcb.so on X11;
                     ;; libEGL.so/libvulkan.so for the wgpu backend).  Putting
                     ;; them on RUNPATH lets dlopen find them, since the dynamic
                     ;; loader searches RUNPATH for dlopen too.
                     (rpath (string-join
                             (list lib
                                   (string-append (assoc-ref inputs "glibc") "/lib")
                                   gcc-lib
                                   ncurses-lib
                                   (string-append
                                    (assoc-ref inputs "gstreamer") "/lib")
                                   (string-append
                                    (assoc-ref inputs "gst-plugins-base") "/lib")
                                   (string-append (assoc-ref inputs "glib") "/lib")
                                   (string-append
                                    (assoc-ref inputs "fontconfig-minimal") "/lib")
                                   (string-append (assoc-ref inputs "zlib") "/lib")
                                   ;; GUI windowing/GPU stack (dlopen'd, see above).
                                   (string-append
                                    (assoc-ref inputs "wayland") "/lib")
                                   (string-append
                                    (assoc-ref inputs "libxkbcommon") "/lib")
                                   (string-append (assoc-ref inputs "mesa") "/lib")
                                   (string-append
                                    (assoc-ref inputs "vulkan-loader") "/lib")
                                   (string-append (assoc-ref inputs "libx11") "/lib")
                                   (string-append (assoc-ref inputs "libxcb") "/lib")
                                   (string-append (assoc-ref inputs "libxi") "/lib")
                                   (string-append
                                    (assoc-ref inputs "libxcursor") "/lib"))
                             ":")))
                ;; libtinfo.so.6 compatibility symlink.
                ;;
                ;; The neomacs ELF links against libtinfo.so.6, but Guix's
                ;; ncurses is built with --enable-widec and WITHOUT
                ;; --with-termlib, so the terminfo subset lives inside
                ;; libncursesw.so.6 and there is no standalone libtinfo.so.6
                ;; in the store (cf. haskell.scm's GHC bootstrap, which uses
                ;; the same workaround).  libtinfo is an ABI-compatible subset
                ;; of libncursesw, so we ship a symlink in the package's own
                ;; lib/ directory and put it on RUNPATH.
                (mkdir-p lib)
                (symlink (string-append ncurses-lib "/libncursesw.so.6")
                         (string-append lib "/libtinfo.so.6"))
                ;; Binaries + sibling pdump.
                (mkdir-p bin)
                (for-each
                 (lambda (f)
                   (install-file (string-append "usr/bin/" f) bin))
                 '("neomacs" "neomacsclient" "neomacs-temacs"
                   "bootstrap-neomacs" "mock-display"))
                ;; neomacs.pdump is NOT executable; copy as data.
                (copy-file "usr/bin/neomacs.pdump"
                           (string-append bin "/neomacs.pdump"))
                ;; Runtime data tree (lisp, etc, leim).
                (mkdir-p share)
                (copy-recursively "usr/share/neomacs/." share)
                ;; Patch every ELF: interpreter + RPATH.
                (for-each
                 (lambda (elf)
                   (invoke patchelf-bin "--set-interpreter" ldso elf)
                   (invoke patchelf-bin "--set-rpath" rpath elf))
                 (find-files bin (lambda (name stat)
                                   (and (eq? 'regular (stat:type stat))
                                        (executable-file? name)
                                        (string-prefix? (string-append bin "/")
                                                        name))))))))
          (add-after 'install 'install-desktop-entry
            (lambda* (#:key outputs #:allow-other-keys)
              (let* ((out (assoc-ref outputs "out"))
                     (apps (string-append out "/share/applications")))
                (mkdir-p apps)
                (copy-file "usr/share/applications/neomacs.desktop"
                           (string-append apps "/neomacs.desktop"))
                ;; Point Exec at the absolute store path; keep Icon as-is.
                (substitute* (string-append apps "/neomacs.desktop")
                  (("Exec=neomacs")
                   (string-append "Exec=" out "/bin/neomacs"))))))
          (add-after 'install-desktop-entry 'install-icons
            (lambda* (#:key outputs #:allow-other-keys)
              (let* ((out (assoc-ref outputs "out"))
                     (icon-dst (string-append
                                out "/share/icons/hicolor/128x128/apps")))
                (mkdir-p icon-dst)
                (copy-file "usr/share/icons/hicolor/128x128/apps/neomacs.png"
                           (string-append icon-dst "/neomacs.png"))))))))
    (native-inputs (list libarchive patchelf))
    (inputs `(("glibc" ,glibc)
              ("gcc:lib" ,gcc "lib")
              ("ncurses" ,ncurses)
              ("gstreamer" ,gstreamer)
              ("gst-plugins-base" ,gst-plugins-base)
              ("glib" ,glib)
              ("fontconfig-minimal" ,fontconfig)
              ("zlib" ,zlib)
              ;; GUI windowing/GPU stack — not in readelf NEEDED; loaded via
              ;; dlopen by winit/wgpu at runtime, so they must be on RUNPATH.
              ("wayland" ,wayland)
              ("libxkbcommon" ,libxkbcommon)
              ("mesa" ,mesa)
              ("vulkan-loader" ,vulkan-loader)
              ("libx11" ,libx11)
              ("libxcb" ,libxcb)
              ("libxi" ,libxi)
              ("libxcursor" ,libxcursor)))
    (properties `((upstream-name . "neomacs")))
    (home-page "https://github.com/eval-exec/neomacs")
    (synopsis "Extensible text editor built on Emacs Lisp and the Neovim VM")
    (description
     "Neomacs (NEO Emacs) is an extensible, programmable text editor written
in Rust.  Instead of the GNU Emacs C engine it runs Emacs Lisp on top of a
Neovim-derived virtual machine (neovm), and renders its GUI with wgpu and a
dedicated layout engine.  It can edit and evaluate Emacs Lisp, embed
terminals, and play media through GStreamer.  This package wraps the
official prebuilt Linux x86_64 release.")
    (license license:gpl3+)
    (supported-systems '("x86_64-linux"))))

;;; agenote-el is the Emacs integration for the agenote "跨 Agent 经验平台"
;;; (cross-Agent experience platform) knowledge-base CLI.  It ships five
;;; root-level .el files (agenote, agenote-knowledge, agenote-health,
;;; agenote-dashboard, agenote-keybinds) with no third-party Elisp
;;; dependencies (only cl-lib/json/org, all built in).
;;;
;;; Upstream does not publish releases or tags, so this package follows the
;;; main-branch HEAD with the let + git-version structure and the
;;; with-latest-git-commit property.  The agenote CLI is the hard runtime
;;; dependency (agenote.el resolves it on every call via
;; (executable-find "agenote") so a long-lived daemon picks up a new agenote
;;; after a Guix profile switch); it is propagated so the CLI lands on the
;;; profile PATH.  Re-resolution is not defeated: propagate only guarantees
;;; presence on PATH, the lookup itself stays dynamic.

(define-public emacs-agenote
  (let ((commit "ec127222dd3831dd2f11aa3fd71a853a515c0ba3")
        (revision "0"))
    (package
      (name "emacs-agenote")
      (version (git-version "0" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/ShineBreaker/agenote-el")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "10bhsaxw9x1rpcyd56wp7k2qv9hsm9l63fmr917b17x4wp9jr50l"))))
      (build-system emacs-build-system)
      (arguments
       (list #:tests? #f))
      (propagated-inputs (list agenote))
      (home-page "https://github.com/ShineBreaker/agenote-el")
      (synopsis "Emacs integration for the agenote knowledge-base CLI")
      (description
       "Agenote-el integrates the @command{agenote} cross-Agent experience
platform CLI with Emacs.  It provides interactive commands for knowledge-card
capture, search (by text and tag), inbox management, curation, a health panel,
and stateless dashboard data functions, plus a bare keymap
(@code{agenote-command-map}) that hosts can bind to a prefix of their choice.
All file-system operations are delegated to the @command{agenote} CLI through
the @code{agenote-call} adapter layer, so no logic drifts between the Emacs
frontend and the CLI.  The @command{agenote} CLI is propagated so it lands on
the profile PATH; @code{agenote-call} still re-resolves it on every call.")
      (properties `((with-latest-git-commit . #t)))
      (license license:expat))))

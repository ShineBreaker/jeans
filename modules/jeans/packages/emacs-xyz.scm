;;; SPDX-FileCopyrightText: 2026 Andrew Tropin <andrew@trop.in>
;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (jeans packages emacs-xyz)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix gexp)
  #:use-module (guix build-system copy)
  #:use-module (guix build-system emacs)
  #:use-module (guix build-system gnu)
  #:use-module (gnu packages zig)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages emacs)
  #:use-module (gnu packages emacs-xyz)
  #:use-module (gnu packages emacs-build)
  #:use-module ((guix licenses) #:prefix license:))

;; Ghostel vendors ghostty and uucode as build-time git sources.  Earlier
;; revisions inlined these origins inside a (let*) wrapping the package
;; body, which confuses scripts/check-updates/update_versions.py: its
;; r"\\(uri\s+(.+?)\)\s+\\(sha256" regex picks up the inner ghostty
;; origin as if it were the package source.  Hoisting the supporting
;; origins to module top level keeps the emacs-ghostel package definition
;; block free of nested (origin ...) forms.
(define %ghostel-local-patch
  (lambda (name)
    (local-file
     (search-path %load-path
                  (string-append "jeans/patches/" name)))))

(define %ghostel-patches
  (list (%ghostel-local-patch "emacs-ghostel-build.zig.patch")))

(define %ghostel-ghostty-patches
  (list (%ghostel-local-patch "emacs-ghostel-ghostty-build.zig.zon.patch")
        (%ghostel-local-patch "emacs-ghostel-ghostty-exe.zig.patch")
        (%ghostel-local-patch "emacs-ghostel-ghostty-bench.zig.patch")
        (%ghostel-local-patch "emacs-ghostel-ghostty-framedata.zig.patch")
        (%ghostel-local-patch "emacs-ghostel-ghostty-resources.zig.patch")))

(define %ghostel-ghostty-source
  (let ((commit "6246c288ae1087c8d67f75432a59da004b30bf25"))
    (origin
      (method url-fetch)
      (uri (string-append
             "https://github.com/ghostty-org/ghostty"
             "/archive/" commit ".tar.gz"))
      (sha256
       (base32 "0zf82ziicl5ciyhgbj691vmgdgcwdnqsjbgj2czwmdjgvfc01cyz"))
      (patches %ghostel-ghostty-patches))))

(define %ghostel-uucode-source
  (origin
    (method url-fetch)
    (uri "https://github.com/jacobsandlund/uucode/archive/refs/tags/v0.2.0.tar.gz")
    (sha256
     (base32 "15az8qzp0rg5qj8ma0dam9j8jbf4wwb7wxsiq3iymmlb9w7yxayh"))))

(define-public emacs-ghostel
  (package
    (name "emacs-ghostel")
    (version "0.39.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
              "https://github.com/dakra/ghostel"
              "/archive/refs/tags/v" version ".tar.gz"))
       (sha256
        (base32 "1q98jvcdzybdmkdzdqg9hv09kigbyifxhcaf5w3jnsa8cnlhpw7a"))
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
                  ;; Ghostel's build.zig produces two install targets the
                  ;; Elisp loader depends on:
                  ;;   1. installArtifact        -> $out/lib/libghostel-module.so
                  ;;      (Zig forces the 'lib' prefix on shared libs)
                  ;;   2. addInstallFile(.., "../ghostel-module.so")
                  ;;      addInstallFile(.., "../ghostel-module.version")
                  ;;      -> $out/ghostel-module.so / .version
                  ;;      (canonical, prefix-less names that ghostel.el looks up)
                  ;; zig 0.15 resolves the "../" destination by escaping
                  ;; $prefix, which is unreliable inside the Guix build
                  ;; sandbox — only target 1 actually lands.  So we lift the
                  ;; .so from $out/lib and rename it to the canonical
                  ;; 'ghostel-module.so' (no 'lib' prefix) that
                  ;; ghostel--load-module (ghostel-module-install.el) looks
                  ;; up via (expand-file-name "ghostel-module"
                  ;; module-file-suffix).  Without the rename ghostel can't
                  ;; find its module and falls back to the "native module not
                  ;; found" download prompt.
                  ;;
                  ;; The version sidecar is written by build.zig next to the
                  ;; canonical .so; we reproduce it here from #$version
                  ;; (kept in sync with src/version.zig upstream) so the
                  ;; loader skips the live version probe and the
                  ;; 'stale module' upgrade path.
                  (copy-file (string-append out "/lib/libghostel-module.so")
                             (string-append elpa-dir "/ghostel-module.so"))
                  (call-with-output-file
                      (string-append elpa-dir "/ghostel-module.version")
                    (lambda (port)
                      (display (string-append #$version "\n") port)))))))))
      (native-inputs (list zig-0.15))
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
        (base32 "1zyjq0k2ccp3aji7x1hv1dbnziwhznm8ylbw1wfrcgzwiz1nvlm0"))))
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
        (base32 "13plraz5z1cyxd4n29b9y9dxmm0la97zaa37k115mrh98jvawzkp"))))
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
                            "#!/bin/sh\nexport ELLSP_EMACS=~a\nexec ~a \"$@\"\n"
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
                            "#!/bin/sh\nexport EMACS=~a\nexec ~a \"$@\"\n"
                            emacs-bin
                            (string-append libexec "/eask"))))
                (chmod (string-append bin "/eask") #o755)))))))
    (inputs (list bash-minimal emacs))
    (propagated-inputs '())
    (home-page "https://github.com/emacs-eask/cli")
    (synopsis "CLI tool for building, testing and managing Emacs packages")
    (description
     "Eask is a CLI tool that helps you build, test, and manage Emacs packages.
It provides a consistent build environment regardless of your Emacs
configuration, supporting batch operations, linting, testing, and packaging
of Emacs Lisp projects.  This package provides the prebuilt binary release.")
    (license license:gpl3+)
    (supported-systems '("x86_64-linux"))))

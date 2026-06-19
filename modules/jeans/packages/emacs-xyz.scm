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

(define-public emacs-ghostel
  (let* ((version "0.35.4")
         (ghostty-version "1.3.2-dev")
         (ghostty-commit "6246c288ae1087c8d67f75432a59da004b30bf25")
         (uucode-version "0.2.0")
         (patch (lambda (name)
                  (local-file
                   (search-path %load-path
                                (string-append "jeans/patches/" name)))))
         (ghostel-patches
          (list (patch "emacs-ghostel-build.zig.zon.patch")
                (patch "emacs-ghostel-build.zig.patch")
                (patch "emacs-ghostel-ghostel.el.patch")))
         (ghostty-patches
          (list (patch "emacs-ghostel-ghostty-build.zig.zon.patch")
                (patch "emacs-ghostel-ghostty-exe.zig.patch")
                (patch "emacs-ghostel-ghostty-bench.zig.patch")
                (patch "emacs-ghostel-ghostty-framedata.zig.patch")
                (patch "emacs-ghostel-ghostty-resources.zig.patch")))
         (ghostty-source
          (origin
            (method git-fetch)
            (uri (git-reference
                  (url "https://github.com/ghostty-org/ghostty")
                  (commit ghostty-commit)))
            (file-name (git-file-name "ghostty" ghostty-commit))
            (sha256
             (base32
              "02a7s2qbsipic2wm42bij6q90ia79f686iiyada24ync6zb6xyjf"))
            (patches ghostty-patches)))
         (uucode-source
          (origin
            (method git-fetch)
            (uri (git-reference
                  (url "https://github.com/jacobsandlund/uucode")
                  (commit (string-append "v" uucode-version))))
            (file-name (git-file-name "uucode" uucode-version))
            (sha256
             (base32
              "1a3lrmbpc4ifdj1z6ra2b3xnfwh784q2bx835pz58hwpc2pf3flc")))))
    (package
      (name "emacs-ghostel")
      (version version)
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/dakra/ghostel")
               (commit (string-append "v" version))))
         (file-name (git-file-name name version))
         (sha256
          (base32
           "10zrcnzymrn8vyjq548fsvskwlqv7fd8r8dp3f66ir2cnmvlq0b4"))
         (patches ghostel-patches)))
      (build-system emacs-build-system)
      (arguments
       (list
        #:lisp-directory "lisp"
        #:tests? #f
        #:phases
        #~(modify-phases %standard-phases
            (delete 'patch-el-files)
            ;; The Zig-built native module links against system libraries
            ;; and zig cache paths that don't satisfy Guix's RUNPATH
            ;; validator.  Disable the check rather than patch the build.
            (delete 'validate-runpath)
            (add-after 'unpack 'unpack-zig-dependencies
              (lambda _
                ;; emacs-build-system 'unpack chdirs into 'lisp-directory,
                ;; so the source root is one level up.  Stash it for the
                ;; later phases to find.
                (let* ((source-root (dirname (getcwd)))
                       (deps (string-append source-root "/deps")))
                  (setenv "GUIX_GHOSTEL_SOURCE_ROOT" source-root)
                  (mkdir-p deps)
                  (copy-recursively #$ghostty-source
                                    (string-append deps "/ghostty")
                                    #:log (%make-void-port "w"))
                  (copy-recursively #$uucode-source
                                    (string-append deps "/uucode")
                                    #:log (%make-void-port "w"))
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
                  ;; Ghostel's build.zig uses 'addInstallFile(..., "../ghostel-module.so")'
                  ;; to put the native module next to $out, which zig 0.15
                  ;; resolves by escaping the prefix.  In the Guix sandbox
                  ;; only the default 'installArtifact' copy under $out/lib
                  ;; is reliable, so we lift the .so into the Emacs package
                  ;; directory from there.
                  (install-file (string-append out "/lib/libghostel-module.so")
                                elpa-dir)))))))
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
                     license:unicode)))))
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

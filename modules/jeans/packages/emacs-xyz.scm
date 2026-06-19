;;; SPDX-FileCopyrightText: 2026 Andrew Tropin <andrew@trop.in>
;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (jeans packages emacs-xyz)
  #:use-module (gnu packages zig)
  #:use-module (guix build-system emacs)
  #:use-module (guix git-download)
  #:use-module (guix gexp)
  #:use-module (guix packages)
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

;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (jeans packages terminals)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system go)
  #:use-module (guix build-system pyproject)
  #:use-module (guix build-system trivial)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (gnu packages)
  #:use-module (gnu packages assembly)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages elf)  ; patchelf
  #:use-module (gnu packages digest)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages linux)  ; alsa-lib
  #:use-module (gnu packages vulkan)  ; vulkan-loader
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages ghostscript)
  #:use-module (gnu packages gl)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages golang)
  #:use-module (gnu packages golang-build)
  #:use-module (gnu packages golang-compression)
  #:use-module (gnu packages golang-crypto)
  #:use-module (gnu packages golang-maths)
  #:use-module (gnu packages golang-xyz)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages image)
  #:use-module (gnu packages imagemagick)
  #:use-module (gnu packages libcanberra)
  #:use-module (gnu packages ncurses)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages python)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages rsync)
  #:use-module (gnu packages shells)
  #:use-module (gnu packages sphinx)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages xorg)
  #:use-module (jeans packages fonts)
  #:use-module (srfi srfi-26))

(define go-github-com-kovidgoyal-go-shm
  (package
    (name "go-github-com-kovidgoyal-go-shm")
    (version "1.0.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://github.com/kovidgoyal/go-shm/archive/refs/tags/v"
                           version ".tar.gz"))
       (sha256
        (base32 "0myargxqcwnihzw6h7npi2nvx3fzy2cpzkzvrjsv57fxfhvjdbjs"))))
    (build-system go-build-system)
    (arguments '(#:import-path "github.com/kovidgoyal/go-shm"))
    (propagated-inputs (list go-golang-org-x-sys))
    (home-page "https://github.com/kovidgoyal/go-shm")
    (synopsis "POSIX shared memory for Go")
    (description "Tools to create and manage shared memory (POSIX shared
memory) across all Unix variants.  Pure Go, no external dependencies.
Implements Go versions of @code{shm_open()} and @code{shm_unlink()} that
interoperate with the libc versions.")
    (license license:bsd-3)))

(define go-github-com-kovidgoyal-go-parallel
  (package
    (name "go-github-com-kovidgoyal-go-parallel")
    (version "1.1.1")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://github.com/kovidgoyal/go-parallel/archive/refs/tags/v"
                           version ".tar.gz"))
       (sha256
        (base32 "0g4ndf8gff415g8vzjin7bz2jk6pbapxc9bv3kfj8avqvi1z1921"))))
    (build-system go-build-system)
    (arguments '(#:import-path "github.com/kovidgoyal/go-parallel"
                 #:tests? #f))
    (home-page "https://github.com/kovidgoyal/go-parallel")
    (synopsis "Utility functions for running code in parallel in Go")
    (description "Utility functions to make running code in parallel easier
and safer.  Panics in goroutines are turned into regular errors, instead of
crashing the program.")
    (license license:bsd-3)))

(define go-github-com-hako-durafmt
  (package
    (name "go-github-com-hako-durafmt")
    (version "5c1018a4e16b")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://github.com/hako/durafmt/archive/"
                           version ".tar.gz"))
       (sha256
        (base32 "1rqd216434xdrcmbxqk3a21khc5rq0krw4pcpfawplhwazqkvg9f"))))
    (build-system go-build-system)
    (arguments '(#:import-path "github.com/hako/durafmt"))
    (home-page "https://github.com/hako/durafmt")
    (synopsis "Better time duration formatting in Go")
    (description "Durafmt is a tiny Go library that formats
@code{time.Duration} strings (and types) into a human-readable format.")
    (license license:expat)))

(define go-github-com-nwaples-rardecode-v2-2.2.2
  (package
    (name "go-github-com-nwaples-rardecode-v2")
    (version "2.2.2")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://github.com/nwaples/rardecode/archive/refs/tags/v"
                           version ".tar.gz"))
       (sha256
        (base32 "10jh31w8rd5dgw83zp3wqjzaiplrzjms4w4w71l4hiyyqgnjplp0"))))
    (build-system go-build-system)
    (arguments '(#:import-path "github.com/nwaples/rardecode/v2"))
    (home-page "https://github.com/nwaples/rardecode")
    (synopsis "RAR archive decoder for Go")
    (description "Package rardecode implements a RAR archive decoder.")
    (license license:bsd-3)))

(define go-github-com-kovidgoyal-imaging-1.8.20
  (package
    (name "go-github-com-kovidgoyal-imaging")
    (version "1.8.20")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://github.com/kovidgoyal/imaging/archive/refs/tags/v"
                           version ".tar.gz"))
       (sha256
        (base32 "0caipj526hqzq5lcy830xyfac3qq1f8g7dgvy5d3dh8cqvrbrkdx"))))
    (build-system trivial-build-system)
    (arguments
     (list
      #:modules '((guix build utils))
      #:builder
      #~(begin
          (use-modules (guix build utils))
          (let ((out (string-append #$output "/src/github.com/kovidgoyal/imaging"))
                (tar (string-append #$(this-package-native-input "tar") "/bin/tar"))
                (gzip (string-append #$(this-package-native-input "gzip") "/bin/gzip")))
            (setenv "PATH" (string-append (dirname tar) ":" (dirname gzip)))
            (mkdir-p out)
            (invoke tar "xzf" #$source "-C" out "--strip-components=1")))))
    (native-inputs (list tar gzip))
    (home-page "https://github.com/kovidgoyal/imaging")
    (synopsis "Simple image processing package for Go")
    (description "Package imaging provides basic image processing functions
(resize, rotate, crop, brightness/contrast adjustments, etc.).  All the
image processing functions provided by the package accept any image type
that implements @code{image.Image} interface as an input, and return a new
image of @code{*image.NRGBA} type (32bit RGBA colors, non-premultiplied
alpha).")
    (license license:expat)))

(define-public kitty-full
  (package
    (name "kitty-full")
    (version "0.46.2")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/kovidgoyal/kitty")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0yh8b3bjbgghfb6166zr3dvsi3jb4c9dc1dk7kxah89pp11c3s67"))
       (modules '((guix build utils)))
       (snippet
        #~(begin
            (substitute* "docs/conf.py"
              (("(from kitty.constants import str_version)" imp)
               (string-append "sys.path.append(\"..\")\n" imp)))
            (substitute* "docs/Makefile"
              (("^SPHINXBUILD[[:space:]]+= (python3.*)$")
               "SPHINXBUILD = sphinx-build\n"))))))
    (build-system pyproject-build-system)
    (outputs '("out" "terminfo" "shell-integration"))
    (arguments
     (list
      #:tests? #t
      #:phases
      #~(modify-phases %standard-phases
          (delete 'build)
          (delete 'check)

          (add-after 'unpack 'setup-fonts
            (lambda* (#:key inputs #:allow-other-keys)
              (let* ((font-dir (search-input-directory inputs "/share/fonts"))
                     (fonts (string-append font-dir "/truetype")))
                (mkdir-p "fonts")
                (when (directory-exists? fonts)
                  (copy-recursively fonts "fonts")))))

          (add-after 'setup-fonts 'generate-headers
            (lambda _
              (invoke "python3" "-c"
                      "import sys; sys.path.insert(0, '.'); \
from setup import build_ref_map, build_cli_parser_specs, build_uniforms_header; \
build_ref_map(False); build_cli_parser_specs(False); build_uniforms_header(False)")))

          (add-after 'generate-headers 'build-kitty
            (lambda* (#:key inputs #:allow-other-keys)
              (setenv "HOME" (getcwd))
              (setenv "GOTOOLCHAIN" "local")
              (setenv "GOPROXY" "off")
              (setenv "GOSUMDB" "off")
              (substitute* "setup.py"
                (("required_go_version = subprocess\\.check_output.*\\.decode\\(\\)\\.strip\\(\\)")
                 "required_go_version = '1.0.0'"))
              (for-each make-file-writable (find-files "kitty"))
              (apply invoke "python3" "setup.py" "linux-package"
                     "--update-check-interval=0"
                     "--shell-integration=enabled no-rc"
                     "--skip-building-kitten"
                     "--skip-code-generation"
                     (map (lambda (pair)
                            (string-append "--" (car pair) "="
                                           (search-input-file inputs (cdr pair))))
                          '(("egl-library" . "/lib/libEGL.so.1")
                            ("startup-notification-library" . "/lib/libstartup-notification-1.so")
                            ("canberra-library" . "/lib/libcanberra.so")
                            ("fontconfig-library" . "/lib/libfontconfig.so"))))))

          (add-after 'build-kitty 'build-kitten
            (lambda* (#:key inputs #:allow-other-keys)
              (let* ((go-path (string-append (getcwd) "/gopath"))
                     (src-dir (string-append go-path "/src")))
                ;; Set up Go environment
                (setenv "GOPATH" go-path)
                (setenv "GO111MODULE" "off")
                (setenv "GOTOOLCHAIN" "local")
                (setenv "GOPROXY" "off")
                (setenv "GOSUMDB" "off")
                (setenv "GOCACHE" (string-append (getcwd) "/go-cache"))
                (mkdir-p src-dir)
                (mkdir-p (getenv "GOCACHE"))

                ;; Symlink kitty source into GOPATH
                (mkdir-p (string-append src-dir "/github.com/kovidgoyal"))
                (symlink (getcwd)
                         (string-append src-dir "/github.com/kovidgoyal/kitty"))

                ;; Copy Go dependency sources into GOPATH
                (for-each
                 (lambda (input)
                   (let ((go-src (string-append (cdr input) "/src")))
                     (when (directory-exists? go-src)
                       (copy-recursively go-src src-dir #:keep-mtime? #t)
                       ;; Make files writable for subsequent copies
                       (for-each (lambda (f)
                                   (unless (symbolic-link? f)
                                     (make-file-writable f)))
                                 (find-files src-dir #:directories? #t)))))
                 inputs)

                ;; Re-copy our imaging package to override any older version
                ;; propagated by other Go dependencies
                (let ((imaging-src (string-append
                                    (assoc-ref inputs "go-github-com-kovidgoyal-imaging")
                                    "/src/github.com/kovidgoyal/imaging"))
                      (imaging-dst (string-append src-dir "/github.com/kovidgoyal/imaging")))
                  (when (directory-exists? imaging-src)
                    (when (directory-exists? imaging-dst)
                      (for-each (lambda (f)
                                  (unless (symbolic-link? f)
                                    (make-file-writable f)))
                                (find-files imaging-dst #:directories? #t))
                      (delete-file-recursively imaging-dst))
                    (mkdir-p imaging-dst)
                    (copy-recursively imaging-src imaging-dst #:keep-mtime? #t)))

                ;; Generate Go code using the built kitty binary
                (setenv "ASAN_OPTIONS" "detect_leaks=0")
                (invoke (string-append (getcwd) "/linux-package/bin/kitty")
                        "+launch"
                        (string-append (getcwd) "/gen/go_code.py"))

                ;; Build kitten binary (compute output path BEFORE changing directory)
                (let ((kitten-output (string-append (getcwd) "/linux-package/bin/kitten")))
                  (with-directory-excursion
                   "gopath/src/github.com/kovidgoyal/kitty/tools"
                   (invoke "go" "build" "-trimpath"
                           "-o" kitten-output
                           "./cmd"))))))

          (add-after 'build-kitten 'patch-test-runner
            (lambda _
              (substitute* "kitty_tests/main.py"
                (("go_proc: 'Optional\\[GoProc\\]' = run_go\\(go_pkgs, args\\.name\\)")
                 "go_proc: 'Optional[GoProc]' = None  # Guix: Skip Go tests"))
              (substitute* "kitty/constants.py"
                (("def kitty_exe\\(\\) -> str:" all)
                 (string-append all "\n    return '"
                                (getcwd) "/linux-package/bin/kitty'  # Guix\n    "))
                (("def kitten_exe\\(\\) -> str:" all)
                 (string-append all "\n    return '"
                                (getcwd) "/linux-package/bin/kitten'  # Guix\n    ")))))

          (add-after 'patch-test-runner 'run-tests
            (lambda* (#:key tests? #:allow-other-keys)
              (when tests?
                (setenv "HOME" (getcwd))
                (setenv "KITTY_NO_UPDATE_CHECK" "1")
                (mkdir-p "test-home")
                (setenv "XDG_CONFIG_HOME" (string-append (getcwd) "/test-home"))
                (setenv "TMPDIR" (string-append (getcwd) "/test-tmp"))
                (mkdir-p (getenv "TMPDIR"))
                (for-each (lambda (f)
                            (let ((path (string-append "kitty_tests/" f ".py")))
                              (when (file-exists? path) (delete-file path))))
                          '("check_build" "glfw" "graphics" "multicell"
                            "tui" "shell_integration" "ssh" "options"
                            "atexit" "shm" "file_transmission" "completion"))
                (invoke "python3" "test.py"))))

          (add-before 'install 'cleanup
            (lambda _
              (for-each delete-file-recursively
                        (find-files "linux-package/" "__pycache__"
                                    #:directories? #t))))

          (replace 'install
            (lambda _
              (let ((out #$output)
                    (terminfo #$output:terminfo)
                    (shell-int #$output:shell-integration))
                (copy-recursively "linux-package/bin"
                                  (string-append out "/bin"))
                (copy-recursively "linux-package/share"
                                  (string-append out "/share"))
                (copy-recursively "linux-package/lib"
                                  (string-append out "/lib"))
                (mkdir-p (string-append terminfo "/share"))
                (rename-file (string-append out "/share/terminfo")
                             (string-append terminfo "/share/terminfo"))
                (mkdir-p (string-append out "/nix-support"))
                (call-with-output-file
                    (string-append out "/nix-support/propagated-user-env-packages")
                  (lambda (p) (display terminfo p) (newline p)))
                (copy-recursively "shell-integration" shell-int)))))))

    (native-inputs
     (list bash dbus fish font-nerd-symbols go-1.24 imagemagick
           ncurses pkg-config python-pillow python-sphinx
           python-sphinx-inline-tabs zsh))
    (inputs
     (list cairo fontconfig harfbuzz lcms libcanberra libpng librsync libx11
           libxcursor libxext libxi libxinerama libxkbcommon libxrandr mesa
           ncurses openssl python simde startup-notification wayland
           wayland-protocols xxhash zlib
           ;; Go dependencies for kitten
           go-github-com-alecthomas-chroma-v2
           go-github-com-altree-bigfloat
           go-github-com-bmatcuk-doublestar-v4
           go-github-com-dlclark-regexp2
           go-github-com-ebitengine-purego
           go-github-com-google-go-cmp
           go-github-com-google-uuid
           go-github-com-hako-durafmt
           go-github-com-klauspost-compress
           go-github-com-klauspost-cpuid-v2
           go-github-com-kovidgoyal-dbus
           go-github-com-kovidgoyal-exiffix
           go-github-com-kovidgoyal-go-parallel
           go-github-com-kovidgoyal-go-shm
           go-github-com-kovidgoyal-imaging-1.8.20
           go-github-com-nwaples-rardecode-v2-2.2.2
           go-github-com-rwcarlsen-goexif
           go-github-com-seancfoley-bintree
           go-github-com-seancfoley-ipaddress-go
           go-github-com-shirou-gopsutil-v4
           go-github-com-tklauser-go-sysconf
           go-github-com-tklauser-numcpus
           go-github-com-ulikunitz-xz
           go-github-com-zeebo-xxh3
           go-golang-org-x-exp
           go-golang-org-x-image
           go-golang-org-x-sys
           go-golang-org-x-text
           go-howett-net-plist))
    (home-page "https://sw.kovidgoyal.net/kitty/")
    (synopsis "Fast, feature-rich, GPU-based terminal emulator. (with kitten utilities)")
    (description "Kitty is a fast, GPU-based terminal emulator with all kitten
command-line utilities included.  It provides GPU-accelerated rendering, support
for modern terminal features including images and ligatures, a tiling layout system,
multiple windows and tabs, extensive keyboard customization, and Unicode support.
This package includes both the @code{kitty} terminal emulator and the @code{kitten}
command-line utilities.")
    (license license:gpl3+)))

    ;;; Warp Terminal: prebuilt binary terminal emulator (Rust/GPU-accelerated).
    ;;;
    ;;; The upstream .deb ships one large ELF PIE binary:
    ;;;   - warp   (dynamically linked to zlib, xz, alsa-lib, glibc, gcc:lib)
    ;;;
    ;;; Runtime dependencies loaded via dlopen:
    ;;;   fontconfig, libEGL (libglvnd), libxkbcommon, vulkan-loader,
    ;;;   wayland-client, libX11, libXcursor, libXi, libxcb
    ;;;
    ;;; Because this is a prebuilt binary compiled on Ubuntu, we must:
    ;;;   1. Use patchelf to set the ELF interpreter to Guix's ld-linux.
    ;;;   2. Use patchelf to set RPATH so the binary finds all shared libs in the store.
    ;;;   3. Add libfontconfig.so.1 as an explicit needed library (nix does this too).

    (define-public warp-terminal-bin
      (package
        (name "warp-terminal-bin")
        (version "0.2026.05.06.15.42.stable")
        (source
         (origin
           (method url-fetch)
           (uri (string-append
                 "https://releases.warp.dev/stable/"
                 "v" version "_03/"
                 "warp-terminal_" version ".03_amd64.deb"))
           (sha256
            (base32 "1sf6j49k7pr0zbilq20cb0p0zb1hicb0zd23xm8y0j8ypsy3wls8"))))
        (build-system gnu-build-system)
        (arguments
         (list
          #:tests? #f
          #:validate-runpath? #f
          #:modules '((guix build gnu-build-system)
                      (guix build utils))
          #:phases
          #~(modify-phases %standard-phases
              (delete 'configure)
              (delete 'build)
              (replace 'unpack
                (lambda _
                  (let ((debdir (string-append "warp-terminal-" #$version)))
                    (mkdir debdir)
                    (with-directory-excursion debdir
                      (invoke "ar" "x" #$source)
                      (invoke "tar" "xJf" "data.tar.xz"))
                    (chdir debdir))))
              (replace 'install
                (lambda _
                  (let* ((out #$output)
                         (bin (string-append out "/bin"))
                         (lib-dir (string-append out "/lib/warpdotdev/warp-terminal"))
                         (share (string-append out "/share"))
                         (rpath
                          (string-join
                           (list (string-append #$glibc "/lib")
                                 (string-append #$gcc:lib "/lib")
                                 (string-append #$zlib "/lib")
                                 (string-append #$xz "/lib")
                                 (string-append #$alsa-lib "/lib")
                                 (string-append #$fontconfig "/lib")
                                 (string-append #$libglvnd "/lib")
                                 (string-append #$libxkbcommon "/lib")
                                 (string-append #$vulkan-loader "/lib")
                                 (string-append #$wayland "/lib")
                                 (string-append #$libx11 "/lib")
                                 (string-append #$libxcb "/lib")
                                 (string-append #$libxcursor "/lib")
                                 (string-append #$libxi "/lib"))
                           ":")))
                    (mkdir-p lib-dir)
                    (copy-recursively "opt/warpdotdev/warp-terminal" lib-dir)

                    (invoke #$(file-append patchelf "/bin/patchelf")
                            "--set-interpreter"
                            #$(file-append glibc "/lib/ld-linux-x86-64.so.2")
                            (string-append lib-dir "/warp"))
                    (invoke #$(file-append patchelf "/bin/patchelf")
                            "--set-rpath" rpath
                            (string-append lib-dir "/warp"))
                    (invoke #$(file-append patchelf "/bin/patchelf")
                            "--add-needed" "libfontconfig.so.1"
                            (string-append lib-dir "/warp"))

                    (mkdir-p bin)
                    (call-with-output-file (string-append bin "/warp-terminal")
                      (lambda (port)
                        (format port "#!~a/bin/sh
    exec ~a/warp \"$@\"~%"
                                #$bash-minimal
                                lib-dir)))
                    (chmod (string-append bin "/warp-terminal") #o755)

                    (wrap-program (string-append bin "/warp-terminal")
                      `("PATH" ":" prefix
                        ,(list (string-append #$bash-minimal "/bin")
                               (string-append #$coreutils "/bin")))
                      `("LD_LIBRARY_PATH" ":" prefix
                        ,(list (string-append #$libglvnd "/lib")
                               (string-append #$vulkan-loader "/lib")
                               (string-append #$wayland "/lib")
                               (string-append #$libxkbcommon "/lib")
                               (string-append #$libx11 "/lib")
                               (string-append #$libxcb "/lib")
                               (string-append #$libxcursor "/lib")
                               (string-append #$libxi "/lib")
                               (string-append #$fontconfig "/lib")))
                      `("XDG_DATA_DIRS" ":" prefix
                        ,(list share
                               (string-append #$glib "/share"))))

                    (mkdir-p (string-append share "/applications"))
                    (copy-file "usr/share/applications/dev.warp.Warp.desktop"
                               (string-append share "/applications/dev.warp.Warp.desktop"))
                    (substitute* (string-append share "/applications/dev.warp.Warp.desktop")
                      (("Exec=warp-terminal")
                       (string-append "Exec=" bin "/warp-terminal")))

                    (for-each
                     (lambda (size-dir)
                       (let ((icon-src
                              (string-append "usr/share/icons/hicolor/"
                                             size-dir "/apps/dev.warp.Warp.png"))
                             (icon-dst-dir
                              (string-append share "/icons/hicolor/"
                                             size-dir "/apps")))
                         (when (file-exists? icon-src)
                           (mkdir-p icon-dst-dir)
                           (copy-file icon-src
                                      (string-append icon-dst-dir
                                                     "/dev.warp.Warp.png")))))
                     '("16x16" "32x32" "64x64" "128x128" "256x256" "512x512"))))))))
        (native-inputs (list patchelf binutils))
        (inputs
         (list bash-minimal
               glibc
               `(,gcc "lib")
               zlib
               xz
               alsa-lib
               fontconfig
               libglvnd
               libxkbcommon
               vulkan-loader
               wayland
               libx11
               libxcb
               libxcursor
               libxi
               coreutils
               glib))
        (home-page "https://www.warp.dev")
        (synopsis "Rust-based terminal with AI and modern developer experience")
        (description "Warp is a modern, GPU-accelerated terminal emulator built with
    Rust.  It features AI-assisted command suggestions, modern text editing
    capabilities, collaborative workflows, and a GPU-accelerated rendering engine.
    This package provides the prebuilt binary release.")
        (license (list license:agpl3+ license:expat))))

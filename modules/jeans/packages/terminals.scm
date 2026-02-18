;;; SPDX-FileCopyrightText: 2026 IliaLuetin
;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-only

(define-module (jeans packages terminals)
  #:use-module (jeans packages fonts)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix build-system cargo)
  #:use-module (guix build-system cmake)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system glib-or-gtk)
  #:use-module (guix build-system go)
  #:use-module (guix build-system meson)
  #:use-module (guix build-system pyproject)
  #:use-module (guix build-system python)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (gnu packages)
  #:use-module (gnu packages assembly)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages check)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages crypto)
  #:use-module (gnu packages curl)
  #:use-module (gnu packages dlang)
  #:use-module (gnu packages digest)
  #:use-module (gnu packages docbook)
  #:use-module (gnu packages fonts)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages fribidi)
  #:use-module (gnu packages gettext)
  #:use-module (gnu packages ghostscript)
  #:use-module (gnu packages gl)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages golang)
  #:use-module (gnu packages golang-build)
  #:use-module (gnu packages golang-check)
  #:use-module (gnu packages golang-crypto)
  #:use-module (gnu packages golang-maths)
  #:use-module (gnu packages golang-xyz)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages imagemagick)
  #:use-module (gnu packages image)
  #:use-module (gnu packages libcanberra)
  #:use-module (gnu packages libevent)
  #:use-module (gnu packages libunwind)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages man)
  #:use-module (gnu packages ncurses)
  #:use-module (gnu packages pcre)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages perl-check)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages popt)
  #:use-module (gnu packages protobuf)
  #:use-module (gnu packages python)
  #:use-module (gnu packages python-build)
  #:use-module (gnu packages python-check)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages rsync)
  #:use-module (gnu packages serialization)
  #:use-module (gnu packages sphinx)
  #:use-module (gnu packages shells)
  #:use-module (gnu packages ssh)
  #:use-module (gnu packages textutils)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages xml)
  #:use-module (gnu packages xorg)
  #:use-module (srfi srfi-26))

(define-public kitty-latest
  (package
    (name "kitty-latest")
    (version "0.45.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/kovidgoyal/kitty")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1nx6ib6phjxma32zwwzax7shr3npzdgp3kijrzflj5vwnyc1cx6x"))
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
      #:tests? #t  ; Run only Python tests for kitty
      #:phases
      #~(modify-phases %standard-phases
          (delete 'build)
          (delete 'check)

          (add-after 'unpack 'setup-fonts
            (lambda* (#:key inputs #:allow-other-keys)
              (let ((fonts (string-append
                           (assoc-ref inputs "font-nerd-symbols")
                           "/share/fonts/truetype")))
                (mkdir-p "fonts")
                (copy-recursively fonts "fonts"))))

          (add-after 'setup-fonts 'setup-environment
            (lambda _
              ;; Tell kitty we don't need Go for this build
              (setenv "KITTY_BUILDING_FOR_GUIX" "1")
              ;; We need to set Go environment even though we skip kitten
              (setenv "HOME" (getcwd))
              (setenv "GOTOOLCHAIN" "local")
              (setenv "GOPROXY" "off")
              (setenv "GOSUMDB" "off")))

          (add-after 'setup-environment 'generate-headers
            (lambda _
              (invoke "python3" "-c"
                      "import sys; sys.path.insert(0, '.'); \
from setup import build_ref_map, build_cli_parser_specs, build_uniforms_header; \
build_ref_map(False); build_cli_parser_specs(False); build_uniforms_header(False)")))

          (add-after 'generate-headers 'patch-go-check
            (lambda _
              ;; Kitty's setup.py checks for Go even when --skip-building-kitten is used
              ;; We bypass this check since we build kitten separately
              (substitute* "setup.py"
                ;; Patch the Go version extraction to return a dummy version
                (("required_go_version = subprocess\\.check_output.*\\.decode\\(\\)\\.strip\\(\\)")
                 "required_go_version = '1.0.0'"))))

          (add-after 'patch-go-check 'build-kitty
            (lambda* (#:key inputs #:allow-other-keys)
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

          (add-after 'build-kitty 'patch-test-runner
            (lambda _
              ;; Remove Go test execution from test runner so we only run Python tests
              (substitute* "kitty_tests/main.py"
                ;; Comment out the line that runs Go tests
                (("go_proc: 'Optional\\[GoProc\\]' = run_go\\(go_pkgs, args\\.name\\)")
                 "go_proc: 'Optional[GoProc]' = None  # Guix: Skip Go tests in kitty package"))
              ;; Patch kitty_exe() and kitten_exe() to return build paths
              (substitute* "kitty/constants.py"
                ;; Make kitty_exe() return the built binary path
                (("def kitty_exe\\(\\) -> str:" all)
                 (string-append all "\n    return '"
                                (getcwd) "/linux-package/bin/kitty'  # Guix: Return build path\n    "))
                ;; Make kitten_exe() return a dummy path (kitten not built in kitty package)
                (("def kitten_exe\\(\\) -> str:" all)
                 (string-append all "\n    return '/dev/null'  # Guix: kitten not available in kitty build\n    ")))))

          (add-after 'patch-test-runner 'run-python-tests
            (lambda* (#:key tests? #:allow-other-keys)
              (when tests?
                (setenv "HOME" (getcwd))
                (setenv "KITTY_NO_UPDATE_CHECK" "1")
                (mkdir-p "test-home")
                (setenv "XDG_CONFIG_HOME" (string-append (getcwd) "/test-home"))
                (setenv "TMPDIR" (string-append (getcwd) "/test-tmp"))
                (mkdir-p (getenv "TMPDIR"))
                ;; Remove tests requiring display server, dbus access or kitten binary
                (for-each (lambda (f)
                            (let ((path (string-append "kitty_tests/" f ".py")))
                              (when (file-exists? path) (delete-file path))))
                          '("check_build" "glfw" "graphics" "multicell"
                            "tui" "shell_integration" "ssh" "options"
                            "atexit" "shm" "file_transmission" "completion"))
                ;; Finaly run Python tests only
                (invoke "python3" "test.py"))))

          (add-before 'install 'cleanup
            (lambda _
              (for-each delete-file-recursively
                        (find-files "linux-package/" "__pycache__" #:directories? #t))))

          (replace 'install
            (lambda _
              (let ((out #$output)
                    (terminfo #$output:terminfo)
                    (shell-int #$output:shell-integration))
                (copy-recursively "linux-package/bin" (string-append out "/bin"))
                (copy-recursively "linux-package/share" (string-append out "/share"))
                (copy-recursively "linux-package/lib" (string-append out "/lib"))
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
           wayland-protocols xxhash zlib))
    (home-page "https://sw.kovidgoyal.net/kitty/")
    (synopsis "Fast, feature-rich, GPU-based terminal emulator")
    (description "Kitty is a fast, GPU-based terminal emulator.  It provides
GPU-accelerated rendering, support for modern terminal features including images
and ligatures, a tiling layout system, multiple windows and tabs, extensive
keyboard customization, and Unicode support.  The kitten command-line utilities
are provided by the separate @code{kitten} package.")
    (license license:gpl3+)))

(define-public kitten-latest
  (package
    (name "kitten-latest")
    (version "0.45.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/kovidgoyal/kitty")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1nx6ib6phjxma32zwwzax7shr3npzdgp3kijrzflj5vwnyc1cx6x"))))
    (build-system go-build-system)
    (arguments
     (list
      #:tests? #t
      #:import-path "github.com/kovidgoyal/kitty/tools/cmd"
      #:unpack-path "github.com/kovidgoyal/kitty"
      #:embed-files #~(list ".*\\.xml" ".*\\.json" ".*\\.txt" ".*\\.css" ".*\\.html")
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'prepare-build
            (lambda* (#:key inputs #:allow-other-keys)
              (setenv "HOME" (getcwd))
              (setenv "GOTOOLCHAIN" "local")
              (setenv "GOPROXY" "off")
              (setenv "GOSUMDB" "off")
              ;; Point to the kitty binary from the kitty package
              (setenv "KITTY_PATH_TO_KITTY_EXE"
                      (search-input-file inputs "/bin/kitty"))))

          (add-before 'build 'generate-code
            (lambda* (#:key inputs #:allow-other-keys)
              (with-directory-excursion "src/github.com/kovidgoyal/kitty"
                ;; Generate C headers
                (invoke "python3" "-c"
                        "import sys; sys.path.insert(0, '.'); \
from setup import build_ref_map, build_cli_parser_specs, build_uniforms_header; \
build_ref_map(False); build_cli_parser_specs(False); build_uniforms_header(False)")
                ;; Use the kitty binary from inputs to generate Go code
                (setenv "ASAN_OPTIONS" "detect_leaks=0")
                (invoke (search-input-file inputs "/bin/kitty") "+launch"
                        (string-append (getcwd) "/gen/go_code.py")))))

          (replace 'check
            (lambda* (#:key tests? #:allow-other-keys)
              (when tests?
                (setenv "HOME" (getcwd))
                (mkdir-p "test-tmp")
                (setenv "TMPDIR" (string-append (getcwd) "/test-tmp"))
                ;; Run Go tests using the full import path
                ;; This way Go can find all dependencies in $GOPATH/src/
                (invoke "go" "test" "-v"
                        "github.com/kovidgoyal/kitty/tools/..."
                        "-skip" "TestKittyRunning|TestDisplay|TestSSH")))))))
    (native-inputs (list python python-pillow kitty-latest))  ; kitty needed for Go code gen
    (inputs
     (list go-github-com-alecthomas-chroma-v2
           go-github-com-altree-bigfloat
           go-github-com-bmatcuk-doublestar-v4
           go-github-com-dlclark-regexp2
           go-github-com-google-go-cmp
           go-github-com-google-uuid
           go-github-com-kovidgoyal-dbus
           go-github-com-kovidgoyal-exiffix
           go-github-com-kovidgoyal-imaging
           go-github-com-rwcarlsen-goexif
           go-github-com-seancfoley-bintree
           go-github-com-seancfoley-ipaddress-go
           go-github-com-shirou-gopsutil-v3
           go-github-com-zeebo-xxh3
           go-golang-org-x-exp
           go-golang-org-x-image
           go-golang-org-x-sys
           go-golang-org-x-text
           go-howett-net-plist))
    (home-page "https://sw.kovidgoyal.net/kitty/")
    (synopsis "Command-line utilities for Kitty terminal")
    (description "Kitten provides command-line utilities for the Kitty terminal
emulator, including image viewing, diff viewing, SSH integration, clipboard
management, and other terminal enhancements written in Go.  This package depends
on the @code{kitty} package and runs Go tests for the kitten utilities.")
    (license license:gpl3+)))

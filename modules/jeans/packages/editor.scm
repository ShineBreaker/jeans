;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-only

(define-module (jeans packages editor)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix utils)
  #:use-module (guix build-system asdf)
  #:use-module (guix build-system cargo)
  #:use-module (guix build-system copy)
  #:use-module (guix build-system gnu)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages bootstrap)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages elf)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages gl)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages lisp-check)
  #:use-module (gnu packages lisp-xyz)
  #:use-module (gnu packages ncurses)
  #:use-module (gnu packages node)
  #:use-module (gnu packages node-xyz)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages regex)
  #:use-module (gnu packages rust)
  #:use-module (gnu packages terminals)
  #:use-module (gnu packages text-editors)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages tree-sitter)
  #:use-module (gnu packages vulkan)
  #:use-module (gnu packages webkit)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages xorg)
  #:use-module (gnu packages)
  #:use-module (jeans build-system binary)
  #:use-module (jeans packages lisp))

;;; lem-next-bin tracks Lem's rolling nightly release (built from master).
;;; Upstream stopped publishing dated nightlies in 2025-08; the only
;;; rolling artifact is the nightly-latest release, whose title carries
;;; the build stamp ("Nightly Build - YYYYMMDD-HHMM") used as version.
;;; Upstream master has dropped the SDL2 frontend; the GUI is now the
;;; webview frontend (GTK3 + WebKitGTK 4.1 API) with an ncurses TUI
;;; fallback.  The nightly AppImage bundles a full Ubuntu 22.04 library
;;; set but omits the WebKit helper processes (WebKitWebProcess etc.),
;;; which are ABI-coupled to the exact WebKit build.  Rather than mixing
;;; bundled 4.1 libraries with an incompatible helper, we ship only Lem's
;;; own artifacts (lem.real — an SBCL runtime+core image —, libwebview,
;;; libasyncprocess.so, terminal.so) and resolve everything else against
;;; Guix's webkitgtk-for-gtk3, whose libraries and helpers are built from
;;; the same source.  The entry point runs lem.real via the Guix
;;; ld-linux wrapper (no ELF patching); the ncurses TUI still works in a
;;; plain terminal.
(define-public lem-next-bin
  (package
    (name "lem-next-bin")
    (version "20261128-0641")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/lem-project/lem/releases/download/"
             "nightly-latest/Lem-x86_64.AppImage"))
       (sha256
        (base32 "0xb4jslwslk9fjsllgdfmr6nj4c9cy2d887fg6r2bsw1j7r1sjxk"))))
    (build-system binary-build-system)
    (arguments
     (list
      #:unpack-method 'appimage-7z
      #:install-plan
      #~'(("usr/libexec/lem.real" "libexec/lem/")
          ("usr/lib/libwebview.so.0.12.0" "libexec/lem/")
          ("usr/lib/libasyncprocess.so" "libexec/lem/")
          ("usr/lib/terminal.so" "libexec/lem/")
          ("usr/share/icons/hicolor/256x256/apps/lem.png"
           "share/icons/hicolor/256x256/apps/"))
      #:patchelf? #f
      #:wrap? #f
      #:phases
      #~(modify-phases %standard-phases
          ;; 7z 静态解包由 #:unpack-method 'appimage-7z 承担，不再需要
          ;; 自定义 extract-appimage phase。
          (add-after 'install 'install-desktop-entry
            (lambda _
              (let ((apps (string-append #$output "/share/applications")))
                (mkdir-p apps)
                (copy-file "usr/share/applications/lem.desktop"
                           (string-append apps "/lem.desktop"))
                ;; Upstream's entry launches the AppImage-internal run-lem
                ;; shim; point straight at our wrapper instead.
                (substitute* (string-append apps "/lem.desktop")
                  (("Exec=run-lem %F")
                   (string-append "Exec=" #$output "/bin/lem %F"))))))
          ;; The SBCL core baked into lem.real dlopens exact Ubuntu
          ;; 22.04 sonames; alias them to Guix's libraries.
          (add-after 'install 'fix-so
            (lambda _
              (symlink #$(file-append ncurses "/lib/libncursesw.so.6")
                       (string-append #$output
                                      "/libexec/lem/libncursesw.so.6.3"))
              ;; tree-sitter's C ABI is backward compatible across 0.2x.
              (symlink #$(file-append tree-sitter "/lib/libtree-sitter.so.0.25")
                       (string-append #$output
                                      "/libexec/lem/libtree-sitter.so.0.27"))))
          (add-after 'install-desktop-entry 'wrap-lem
            (lambda* (#:key inputs #:allow-other-keys)
              (let* ((out #$output)
                     (libexec (string-append out "/libexec/lem"))
                     (ld.so (string-append (assoc-ref inputs "glibc")
                                           #$(glibc-dynamic-linker)))
                     (lib-path
                      (string-join
                       (cons libexec
                             (map (lambda (input)
                                    (string-append (cdr input) "/lib"))
                                  inputs))
                       ":"))
                     (glib-lib (string-append (assoc-ref inputs "glib") "/lib"))
                     (gtk-lib (assoc-ref inputs "gtk+"))
                     (gtk-share (string-append gtk-lib "/share"))
                     (webkitgtk (assoc-ref inputs "webkitgtk-for-gtk3"))
                     (schemas
                      (assoc-ref inputs "gsettings-desktop-schemas")))
                (mkdir-p (string-append out "/bin"))
                (with-output-to-file (string-append out "/bin/lem")
                  (lambda ()
                    (display
                     (string-append
                      "#!" #$(this-package-input "bash-minimal") "/bin/sh\n"
                      "export FONTCONFIG_FILE="
                      #$(file-append (this-package-input "fontconfig-minimal")
                                     "/etc/fonts/fonts.conf") "\n"
                      ;; Append (never replace) the system XDG_DATA_DIRS so
                      ;; profile-provided mime/icon data stays visible.
                      "export XDG_DATA_DIRS=" out "/share:" gtk-share ":"
                      webkitgtk "/share:" schemas "/share"
                      "\"${XDG_DATA_DIRS:+:$XDG_DATA_DIRS}\"\n"
                      "export GI_TYPELIB_PATH=" glib-lib "/girepository-1.0:"
                      gtk-lib "/lib/girepository-1.0:"
                      webkitgtk "/lib/girepository-1.0\n"
                      "export GIO_EXTRA_MODULES=" glib-lib "/gio/modules"
                      "\"${GIO_EXTRA_MODULES:+:$GIO_EXTRA_MODULES}\"\n"
                      ;; webkitgtk-for-gtk3 ships its own matching helpers.
                      "export WEBKIT_EXEC_PATH=" webkitgtk
                      "/libexec/webkit2gtk-4.1\n"
                      "exec " ld.so " --argv0 " libexec "/lem.real"
                      " --library-path " lib-path " " libexec
                      "/lem.real \"$@\"\n"))))
                (chmod (string-append out "/bin/lem") #o555)))))))
    (native-inputs (list p7zip))
    (inputs
     `(("bash-minimal" ,bash-minimal)
       ("fontconfig-minimal" ,fontconfig)
       ("gcc:lib" ,gcc "lib")
       ("glib" ,glib)
       ("glibc" ,glibc)
       ("gsettings-desktop-schemas" ,gsettings-desktop-schemas)
       ("gtk+" ,gtk+)
       ("ncurses" ,ncurses)
       ("openssl" ,openssl)
       ("tree-sitter" ,tree-sitter)
       ("webkitgtk-for-gtk3" ,webkitgtk-for-gtk3)))
    (home-page "https://lem-project.github.io/")
    (synopsis "Integrated IDE/editor for Common Lisp (nightly prebuild)")
    (description
     "Lem is a Common Lisp editor/IDE with high expansibility.  This
package provides a prebuilt nightly build of Lem's master branch, using
the webview (GTK/WebKitGTK) frontend with an ncurses fallback.")
    (properties
     `((upstream-name . "lem")))
    (license license:expat)
    (supported-systems '("x86_64-linux"))))

;;; lem-next builds Lem from source, tracking the main branch (webview
;;; form).  It is based on the upstream Guix "lem" package definition
;;; (gnu/packages/text-editors.scm, version 2.3.0), adapted for the
;;; ncurses/webview/server frontends of Lem's main branch following the
;;; upstream flake.nix build recipe; native library wiring follows the
;;; upstream Guix conventions (absolute store paths substituted into the
;;; FFI definitions, terminal.so compiled into $out/lib).
;;;
;;; Differences from the upstream 2.3.0 definition:
;;;   - tracks the pinned main-branch commit instead of the v2.3.0 tag;
;;;   - (pushnew :nix-build *features*) is injected into lem.asd to skip
;;;     lem-extension-manager, whose main.lisp calls QL-DIST at load time
;;;     and is unusable without Quicklisp (same trick as flake.nix);
;;;   - the program bundles lem-ncurses, lem-webview and lem-server
;;;     instead of lem-ncurses and lem-sdl2 (SDL2 frontend is dropped
;;;     upstream); the webview frontend's dist assets are read into the
;;;     image at load time (main.lisp's *dist* toplevel), so no extra
;;;     data files need installing;
;;;   - inputs add the main-branch dependencies (webview C shim + CL
;;;     bindings, tree-sitter, frugal-uuid, hunchentoot, jsonrpc pinned
;;;     to Lem's qlfile.lock commit, deploy for defsystem-depends-on,
;;;     cl-mustache, command-line-arguments, float-features) and drop
;;;     the SDL2 stack.
;;;
;;; The pinned commits of webview / tree-sitter-cl / jsonrpc in
;;; (jeans packages lisp) mirror Lem's qlfile.lock at this commit:
;;; update them together with this package.
;;;
;;; Runtime notes: tree-sitter grammar libraries are optional; install
;;; e.g. tree-sitter-json and point LD_LIBRARY_PATH at its lib/ to
;;; enable syntax highlighting for that language.
(define-public lem-next
  (let ((commit "18e91fe804e2860548804bf2931ec37854b0cf03")
        (revision "21"))
    (package
      (inherit lem)
      (name "lem-next")
      (version (git-version "2.3.0" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/lem-project/lem/")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "14jm46xk8jkjxfifnhs5mdzxfp7qv7bg0z3lxj8bgwfryf50fxq8"))
         (patches
          (map canonicalize-path
               (search-patches
                "jeans/patches/lem-next-cl-ppcre-single-alternation.patch")))
         (snippet
          #~(begin
              (use-modules (guix build utils))
              ;; Quicklisp/Roswell-based install helpers.
              (delete-file-recursively "roswell")))))
      (home-page "https://lem-project.github.io/")
      (arguments
       (list
        ;; The system defined in lem.asd is named "lem", not "lem-next".
        #:asd-systems ''("lem")
        #:phases
        #~(modify-phases %standard-phases
            (add-after 'unpack 'patch-shared-object-files
              (lambda* (#:key inputs outputs #:allow-other-keys)
                (let* ((libvterm-lib (assoc-ref inputs "libvterm"))
                       (lib-dir (string-append libvterm-lib "/lib"))
                       (shared-lib-dir (string-append (assoc-ref outputs "out")
                                                      "/lib"))
                       (shared-lib (string-append shared-lib-dir "/terminal.so")))
                  (substitute* "extensions/terminal/ffi.lisp"
                    (("terminal\\.so")
                     shared-lib)))))
            (add-after 'unpack 'disable-extension-manager
              (lambda _
                ;; lem/core hard-depends on lem-extension-manager unless
                ;; the :nix-build feature is present; its main.lisp calls
                ;; QL-DIST at load time, unavailable without Quicklisp.
                (substitute* "lem.asd"
                  (("^(#[+]ros[.]installing.*)$" _ line)
                   (string-append
                    "(pushnew :nix-build *features*)\n" line)))))
            (add-after 'create-asdf-configuration 'build-program
              (lambda* (#:key outputs #:allow-other-keys)
                (build-program (string-append (assoc-ref outputs "out")
                                              "/bin/lem")
                               outputs
                               #:dependencies '("lem-ncurses" "lem-webview"
                                                "lem-server")
                               #:entry-program '((lem:main)
                                                 0))))
            (add-after 'build 'build-terminal-library
              (lambda* (#:key inputs outputs #:allow-other-keys)
                (let* ((libvterm-lib (assoc-ref inputs "libvterm"))
                       (lib-dir (string-append libvterm-lib "/lib"))
                       (shared-lib-dir (string-append (assoc-ref outputs "out")
                                                      "/lib"))
                       (shared-lib (string-append shared-lib-dir "/terminal.so")))
                  (mkdir-p shared-lib-dir)
                  (invoke #$(cc-for-target)
                          "extensions/terminal/terminal.c"
                          "-L"
                          lib-dir
                          "-lvterm"
                          "-Wl,-Bdynamic"
                          "-o"
                          shared-lib
                          "-shared"
                          "-fPIC"
                          "-lutil"))))
            ;; The desktop entry and icon come from the upstream
            ;; resources/ directory — the same files the AppImage
            ;; release packs.  Exec must be absolute in Guix.
            (add-after 'build-terminal-library 'install-desktop-entry
              (lambda* (#:key outputs #:allow-other-keys)
                (let* ((out (assoc-ref outputs "out"))
                       (apps (string-append out "/share/applications"))
                       (icons (string-append out
                                             "/share/icons/hicolor/256x256/apps")))
                  (mkdir-p apps)
                  (mkdir-p icons)
                  (copy-file "resources/lem.desktop"
                             (string-append apps "/lem.desktop"))
                  (substitute* (string-append apps "/lem.desktop")
                    (("Exec=lem %F")
                     (string-append "Exec=" out "/bin/lem %F")))
                  (copy-file "resources/lem.png"
                             (string-append icons "/lem.png"))))))))
      (native-inputs (list sbcl-cl-ansi-text sbcl-rove
                           sbcl-trivial-package-local-nicknames))
      (inputs
       (modify-inputs (package-inputs lem)
         (delete "sbcl-sdl2" "sbcl-sdl2-ttf" "sbcl-sdl2-image"
                 "sbcl-trivial-main-thread" "sbcl-jsonrpc"
                 "sbcl-micros")
         (append libvterm
                 sbcl-3bmd
                 sbcl-alexandria
                 sbcl-async-process
                 sbcl-babel
                 sbcl-bordeaux-threads
                 sbcl-cffi
                 sbcl-cl-change-case
                 sbcl-cl-charms
                 sbcl-cl-enchant
                 sbcl-cl-iconv
                 sbcl-cl-mustache
                 sbcl-cl-package-locks
                 sbcl-cl-ppcre
                 sbcl-cl-setlocale
                 sbcl-cl-str
                 sbcl-cl-template
                 sbcl-closer-mop
                 sbcl-command-line-arguments
                 sbcl-deploy
                 sbcl-dexador
                 sbcl-esrap
                 sbcl-float-features
                 sbcl-frugal-uuid
                 sbcl-hunchentoot
                 sbcl-inquisitor
                 sbcl-iterate
                 sbcl-jsonrpc-lem
                 sbcl-lem-mailbox
                 sbcl-lisp-preprocessor
                 sbcl-log4cl
                 sbcl-micros-lem
                 sbcl-parse-number
                 sbcl-quri
                 sbcl-slime-swank
                 sbcl-split-sequence
                 sbcl-tree-sitter-cl
                 sbcl-trivia
                 sbcl-trivial-gray-streams
                 sbcl-trivial-open-browser
                 sbcl-trivial-types
                 sbcl-trivial-utf-8
                 sbcl-trivial-ws
                 sbcl-usocket
                 sbcl-webview
                 sbcl-yason))))))

;;; The upstream .deb ships one ELF binary plus desktop entry, hicolor icons
;;; and a man page:
;;;   - fresh          (Rust TUI editor; NEEDED is only glibc basics + libgcc_s)
;;;
;;; Console-mouse support dlopen's libgpm by the bare soname "libgpm.so.2"
;;; (first entry of upstream's LIBGPM_PATHS probe list), so putting gpm on
;;; RUNPATH makes it resolvable; connecting to an actual gpm daemon is a
;;; user-environment concern.
(define-public fresh-editor-bin
  (package
    (name "fresh-editor-bin")
    (version "0.5.9")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/sinelaw/fresh/releases/download/"
             "v" version "/fresh-editor_" version "-1_amd64.deb"))
       (sha256
        (base32 "1zkydpjbm523bpz1yvlc716cbkln43d1cg93wfyfyfx89cs6g0sb"))))
    (build-system binary-build-system)
    (arguments
     (list
      ;; data.tar 是 xz 压缩，'deb 只认 data.tar.gz，此处必须用 'deb-xz。
      #:unpack-method 'deb-xz
      #:install-plan
      #~'(("usr/bin/fresh" "bin/fresh")
          ("usr/share/applications/fresh.desktop"
           "share/applications/fresh.desktop")
          ("usr/share/icons/" "share/icons/")
          ("usr/share/man/man1/fresh.1.gz" "share/man/man1/"))
      ;; RPATH 取全部 inputs 的 /lib（glibc、gcc:lib、gpm），与原手写值一致。
      #:patchelf-plan
      #~'(("bin/fresh"))
      #:desktop-files
      #~'(("share/applications/fresh.desktop"))))
    (native-inputs (list binutils))
    (inputs
     `(("glibc" ,glibc)
       ("gcc:lib" ,gcc "lib")
       ("gpm" ,gpm)))
    (home-page "https://sinelaw.github.io/fresh/")
    (synopsis "Terminal-based text editor with LSP support")
    (description "Fresh is a modern terminal text editor that requires zero
configuration.  It brings VS Code-style UX to the terminal: familiar
keybindings, full mouse support, multi-cursor editing, split panes, a command
palette with fuzzy finding, tree-sitter syntax highlighting, integrated
terminal, file explorer, and Language Server Protocol integration for code
intelligence.  It handles multi-gigabyte files with low memory overhead and
supports sandboxed TypeScript plugins.  This package provides the prebuilt
binary release.")
    (properties `((upstream-name . "fresh-editor")))
    ;; Cargo.toml at v0.5.8 says "GPL-3.0-or-later" (workspace license,
    ;; crates/fresh-editor inherits it).  The .deb's own metadata says GPL-2;
    ;; that metadata does not match the source the binary is built from.
    (license license:gpl3+)
    (supported-systems '("x86_64-linux"))))

;;; fresh-editor (source build): same upstream as fresh-editor-bin.  The
;;; workspace default-members are the TUI (bin "fresh" lives in
;;; crates/fresh-editor); fresh-gui is excluded, so the GTK/wgpu/clang
;;; crates present in the lockfile are vendored but never compiled.  The
;;; default rquickjs backend bundles quickjs-ng with pre-generated Linux
;;; bindings (no clang/bindgen on Linux).  Guix's cargo-build-system sets
;;; RUSTONIG_SYSTEM_LIBONIG=1 and strips the bundled oniguruma, so onig_sys
;;; links the system oniguruma through pkg-config (same wiring as bat);
;;; lzma-sys and ring compile their bundled C with the cc that
;;; cargo-build-system pulls in via standard-packages, so no extra native
;;; toolchain beyond pkg-config is needed.  fresh-input-parser dlopen's
;;; "libgpm.so.2" for bare-console mouse; rustc only embeds RUNPATH for
;;; actually-linked libs, so a post-install patchelf phase appends gpm/lib
;;; (idiom from gnu maths.scm fix-rpath).  Wrapping is deliberately avoided:
;;; fresh re-launches itself via current_exe() for the daemon and integrated
;;; terminal, and a wrapper would make those subprocesses bypass the wrapper
;;; environment.  #:features "web" is additive over the defaults and
;;; matches the upstream .deb, which builds the browser UI too.  The workspace
;;; install-skip trap (has-executable-target? reads packages[0], a lib member
;;; here) is avoided with an explicit #:cargo-install-paths.  License is
;;; GPL-3.0-or-later per the workspace Cargo.toml and the LICENSE file.
;;; fresh-editor-bin uses the same license; the .deb metadata's GPL-2 claim
;;; does not match that file.
(define-public fresh-editor
  (package
    (name "fresh-editor")
    (version "0.5.9")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/sinelaw/fresh")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0zd0jay7lpsyr49f276vzlqnwj7nv1n1vkwnkdmybi4nr4bj4zgv"))))
    (build-system cargo-build-system)
    (arguments
     (list
      #:install-source? #f
      #:tests? #f
      #:features ''("web")
      #:cargo-install-paths ''("crates/fresh-editor")
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'install 'install-assets
            (lambda* (#:key outputs #:allow-other-keys)
              (let* ((out (assoc-ref outputs "out"))
                     (apps (string-append out "/share/applications"))
                     (man1 (string-append out "/share/man/man1"))
                     (icons (string-append out "/share/icons/hicolor")))
                (mkdir-p apps)
                (copy-file "crates/fresh-editor/resources/fresh.desktop"
                           (string-append apps "/fresh.desktop"))
                (mkdir-p man1)
                (copy-file "crates/fresh-editor/resources/fresh.1"
                           (string-append man1 "/fresh.1"))
                (for-each
                 (lambda (size)
                   (let ((dir (string-append icons "/" size "/apps")))
                     (mkdir-p dir)
                     (copy-file
                      (string-append
                       "docs/icons/linux/hicolor/" size "/apps/fresh.png")
                      (string-append dir "/fresh.png"))))
                 '("16x16" "22x22" "24x24" "32x32" "48x48"
                   "64x64" "128x128" "256x256" "512x512")))))
          (add-after 'install-assets 'add-gpm-runpath
            (lambda* (#:key inputs outputs #:allow-other-keys)
              (use-modules (ice-9 popen) (ice-9 rdelim))
              (let* ((out (assoc-ref outputs "out"))
                     (gpm (assoc-ref inputs "gpm"))
                     (fresh (string-append out "/bin/fresh"))
                     (pipe (open-pipe* OPEN_READ "patchelf"
                                       "--print-rpath" fresh))
                     (rpath (read-line pipe)))
                (close-pipe pipe)
                (invoke "patchelf" "--set-rpath"
                        (string-append rpath ":" gpm "/lib")
                        fresh)))))))
    (native-inputs (list pkg-config patchelf))
    (inputs
     (cons* oniguruma gpm
            (cargo-inputs 'fresh-editor #:module '(jeans packages rust-crates))))
    (home-page "https://sinelaw.github.io/fresh/")
    (synopsis "Terminal-based text editor with LSP support")
    (description "Fresh is a modern terminal text editor that requires zero
configuration.  It brings VS Code-style UX to the terminal: familiar
keybindings, full mouse support, multi-cursor editing, split panes, a command
palette with fuzzy finding, tree-sitter syntax highlighting, integrated
terminal, file explorer, and Language Server Protocol integration for code
intelligence.  It handles multi-gigabyte files with low memory overhead and
supports sandboxed TypeScript plugins.  This package builds Fresh from
source.")
    (properties '((upstream-name . "fresh-editor")))
    (license license:gpl3+)
    (supported-systems '("x86_64-linux"))))

;;; package-version-server is the language server Zed ships for hover
;;; information on dependencies in package.json.  Plain Rust binary whose
;;; only native dependency is OpenSSL, so it is built from source.
(define-public package-version-server
  (package
    (name "package-version-server")
    (version "0.0.10")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/zed-industries/package-version-server")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0i9xcmppvbp536d2d1z5g9x74na7dn21k0sna8cv0xw9d2lyivnp"))))
    (build-system cargo-build-system)
    (arguments
     (list
      #:rust rust
      #:install-source? #f
      #:tests? #f))
    (native-inputs (list pkg-config))
    (inputs
     (cons* openssl
            (cargo-inputs 'package-version-server
                          #:module '(jeans packages rust-crates))))
    (home-page "https://github.com/zed-industries/package-version-server")
    (synopsis "Language server for package.json dependency hover information")
    (description
     "This package provides Zed's language server that reads the dependency
sections of a @file{package.json} and reports the latest published version of
each package on hover.")
    (license license:expat)))

;;; typescript-language-server is published on npm as a dependency-free
;;; bundle (lib/cli.mjs plus its own modules), so the tarball is the whole
;;; program.  Its shebang is "#!/usr/bin/env node", which cannot resolve on
;;; Guix; the launcher below runs it through node with an absolute path
;;; instead of wrapping the script.
(define-public typescript-language-server
  (package
    (name "typescript-language-server")
    (version "6.1.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://registry.npmjs.org/typescript-language-server/-/"
             "typescript-language-server-" version ".tgz"))
       (sha256
        (base32 "1c372yjjximbnlr2m9k84xnqjmi4c28x178nszjzdsaciyaz6cky"))))
    (build-system binary-build-system)
    (arguments
     (list
      #:unpack-method 'gnu-unpack
      #:install-plan
      #~'(("./" "lib/node_modules/typescript-language-server/"))
      #:patchelf? #f
      #:wrap? #f
      #:modules '((jeans build binary)
                  (guix build utils))
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'install 'install-launcher
            (lambda _
              (let ((bin (string-append
                          #$output "/bin/typescript-language-server"))
                    (cli (string-append
                          #$output
                          "/lib/node_modules/typescript-language-server"
                          "/lib/cli.mjs")))
                (mkdir-p (dirname bin))
                (call-with-output-file bin
                  (lambda (port)
                    (format port
                            (string-append
                             "#!~a~%export NODE_PATH=~a"
                             "${NODE_PATH:+:$NODE_PATH}"
                             "~%exec ~a ~a \"$@\"~%")
                            #$(file-append bash-minimal "/bin/bash")
                            #$(file-append
                               (this-package-input "node-typescript")
                               "/lib/node_modules")
                            #$(file-append node "/bin/node")
                            cli)))
                (chmod bin #o755)))))))
    ;; tsserver 是运行时依赖：缺 node-typescript 时 initialize 会报
    ;; "Could not find a valid TypeScript installation"，故经 NODE_PATH 提供。
    (inputs (list node node-typescript bash-minimal))
    (properties '((upstream-name . "typescript-language-server")))
    (home-page "https://github.com/typescript-language-server/typescript-language-server")
    (synopsis "Language Server Protocol implementation for TypeScript")
    (description
     "TypeScript Language Server wraps @code{tsserver} behind the Language
Server Protocol, giving editors completion, diagnostics, go-to-definition and
other code intelligence for TypeScript and JavaScript files.")
    (license license:asl2.0)))

;;; zed-bin packages the upstream Zed editor's prebuilt Linux release
;;; (zed-industries/zed): Zed's GPL-3.0-or-later binaries exactly as
;;; upstream ships them, under upstream's own names.  Only the
;;; x86_64-linux tarball is packaged; upstream also publishes -pre tags
;;; which are not tracked.
;;;
;;; Layout: bin/zed is Zed's combined CLI+GUI launcher (NEEDED is only
;;; glibc/gcc; it execs the editor below); libexec/zed-editor is the
;;; GUI/remote-server payload carrying the heavy ELF deps (X11,
;;; xkbcommon, glib, alsa).  The CLI locates the editor through its
;;; built-in bundle detection, which searches ../libexec/zed-editor
;;; (plus ../lib/zed/zed-editor and ./zed) relative to /proc/self/exe —
;;; so the two must keep upstream's bin/ + libexec/ sibling shape:
;;; lib/zed/bin/zed next to lib/zed/libexec/zed-editor.
;;; The tarball also bundles a private lib/ (libxcb, libxkbcommon-x11,
;;; libX11-xcb, ...) for generic Linux; it is deliberately NOT
;;; installed — every NEEDED soname resolves from Guix system libraries
;;; via interpreter + RPATH (verified with ld.so --list on the store
;;; output), so the bundled copies would only shadow them.
;;; ZED_UPDATE_EXPLANATION points the built-in auto-updater at Guix
;;; instead.
;;;
;;; Source history: this package originally tracked
;;; x6nux/zed-globalization (an AI-translated zh-CN repack of the same
;;; upstream binaries).  That repository was deleted outright on
;;; 2026-10-30 (the account has no public repos left; the 1.26.2
;;; tarball 404s on GitHub, bordeaux/ci.guix.gnu.org,
;;; tarballs.nixos.org, Software Heritage, web.archive.org and
;;; Disarchive), so the source was switched to zed-industries/zed —
;;; the binaries the fork had repackaged.  panther's zed package
;;; (franzos/panther, px/packages/editors.scm) uses the same upstream
;;; source but keeps the bundled lib/ and prefers it through the
;;; wrapper's LD_LIBRARY_PATH; this package resolves everything from
;;; system libraries instead.
(define-public zed-bin
  (package
    (name "zed-bin")
    (version "1.30.2")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/zed-industries/zed/releases/download/v"
             version "/zed-linux-x86_64.tar.gz"))
       (sha256
        (base32 "1px2ril7vgfi9v6rh3xiq9m8x0kfgbfvkafzahr14hskvh46l3i1"))))
    (build-system binary-build-system)
    (arguments
     (list
      ;; tarball 顶层是 zed.app/，strip 后得 bin/{zed,libexec,share}；
      ;; 基座 unpack 由下方自定义 phase 接管，此处 'none 仅满足显式声明要求。
      #:unpack-method 'none
      #:install-plan
      #~'(("bin/zed" "lib/zed/bin/zed")
          ("libexec/zed-editor" "lib/zed/libexec/zed-editor"))
      ;; RPATH 自动取 lib-dir（lib/zed）+ 全部 inputs 的 /lib。
      ;; CLI 的 NEEDED 只有 glibc/gcc；GUI 的直接 NEEDED（libxcb、
      ;; libxkbcommon[-x11]、glib 全家、libasound、libX11-xcb）都在
      ;; inputs 里，传递依赖经各系统库自己的 RUNPATH 解析。
      #:patchelf-plan
      #~'(("lib/zed/bin/zed")
          ("lib/zed/libexec/zed-editor"))
      #:wrap-plan
      #~'(("lib/zed/bin/zed"
           ("ZED_UPDATE_EXPLANATION" =
            ("Updates are handled by the Guix package manager."))
           ("XKB_CONFIG_ROOT" ":" prefix
            (#$(file-append xkeyboard-config "/share/X11/xkb")))))
      #:modules '((guix build utils) (ice-9 regex))
      #:phases
      #~(modify-phases %standard-phases
          (replace 'unpack
            (lambda _
              ;; tarball top level is ./zed.app
              (invoke "tar" "--strip-components=1" "-xzf" #$source)))
          (add-after 'install 'install-links
            (lambda _
              (let* ((out #$output)
                     (libdir (string-append out "/lib/zed")))
                ;; bin/ and libexec/ stay siblings under lib/zed/ so
                ;; the CLI's built-in bundle detection
                ;; (../libexec/zed-editor relative to /proc/self/exe)
                ;; keeps resolving.
                (mkdir-p (string-append out "/bin"))
                (symlink (string-append libdir "/bin/zed")
                         (string-append out "/bin/zed")))))
          (add-after 'install 'install-desktop-and-icons
            (lambda _
              (let ((share (string-append #$output "/share")))
                (mkdir-p (string-append share "/applications"))
                (copy-file "share/applications/dev.zed.Zed.desktop"
                           (string-append share "/applications/dev.zed.Zed.desktop"))
                (substitute* (string-append share "/applications/dev.zed.Zed.desktop")
                  ;; 主入口与 [Desktop Action NewWorkspace] 的 Exec 都换成
                  ;; 绝对路径；TryExec=zed 删掉（未装进 profile 时别隐藏入口）。
                  (("Exec=zed ") (string-append "Exec=" #$output "/bin/zed "))
                  (("TryExec=zed\n") "")
                  ;; Icon=zed 保持原名：icons 即按 zed.png 装在 hicolor 下。
                  )
                ;; Install the icons under upstream's "zed" name so icon
                ;; themes and icon packs can resolve the desktop entry.
                (copy-recursively "share/icons"
                                  (string-append share "/icons"))))))))
    (inputs
     `(("bash-minimal" ,bash-minimal)
       ("glibc" ,glibc)
       ("gcc:lib" ,gcc "lib")
       ("glib" ,glib)
       ("libx11" ,libx11)
       ("libxcb" ,libxcb)
       ("libxkbcommon" ,libxkbcommon)
       ("mesa" ,mesa)
       ("libdrm" ,libdrm)
       ("vulkan-loader" ,vulkan-loader)
       ("wayland" ,wayland)
       ("alsa-lib" ,alsa-lib)
       ("fontconfig-minimal" ,fontconfig)
       ("freetype" ,freetype)
       ("zlib" ,zlib)
       ("libxcursor" ,libxcursor)
       ("libxi" ,libxi)
       ("xkeyboard-config" ,xkeyboard-config)))
    (home-page "https://github.com/zed-industries/zed")
    (synopsis "High-performance multiplayer code editor")
    (description "Zed is a high-performance, multiplayer code editor from
the creators of Atom and Tree-sitter.  It features a fast GPU-accelerated
UI, built-in collaboration tools, and AI-powered code assistance.  This
package provides the prebuilt binary release.")
    (properties `((upstream-name . "zed")))
    (license license:gpl3+)
    (supported-systems '("x86_64-linux"))))

;;; wu-bin packages the upstream Wu editor's prebuilt Linux release
;;; (dstrml/wu, a Zed fork): GPL-3.0-or-later binaries with Apache-2.0
;;; components exactly as upstream ships them.  Only the x86_64-linux
;;; tarball is packaged; upstream also publishes an aarch64 tarball.
;;;
;;; Layout mirrors zed.app: bin/wu is the combined CLI+GUI launcher
;;; (NEEDED is only glibc/gcc); libexec/wu-editor is the GUI payload
;;; (NEEDED: libasound, libxcb, libxkbcommon[-x11]).  The launcher's
;;; built-in bundle detection searches ../libexec/wu-editor (and
;;; ../lib/wu/wu-editor) relative to /proc/self/exe, so bin/ and
;;; libexec/ must stay siblings under lib/wu/: lib/wu/bin/wu next to
;;; lib/wu/libexec/wu-editor.
;;; The tarball also bundles a private lib/ (libxcb, libxcb-xkb,
;;; libxkbcommon[-x11], libXau, ...); it is deliberately NOT installed —
;;; Guix's libxcb and libxkbcommon provide the same sonames, and
;;; interpreter + RPATH resolve them (verified with ld.so --list on the
;;; store output).
;;; GPUI dlopens libEGL/libwayland/libvulkan at runtime (none of them
;;; are NEEDED): mesa, wayland and vulkan-loader are inputs so they land
;;; on the RPATH; wgpu falls back to the GL backend when Vulkan is
;;; unavailable.  The binary also references libonnxruntime.so.1.28.3,
;;; which upstream does not ship in the tarball either.
;;; The wrapper sets ZED_UPDATE_EXPLANATION (the fork kept zed's
;;; variable name) so the built-in auto-updater points at Guix.
;;; licenses.md is upstream's third-party notice (themes, fonts, Rust
;;; crates); the MIT/Apache-2.0 components it covers require shipping
;;; it with the binaries, so the standard install-license-files phase
;;; picks it up into share/doc/.  The in-app licence viewer embeds its
;;; own copy.
(define-public wu-bin
  (package
    (name "wu-bin")
    (version "1.5.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/dstrml/wu/releases/download/v"
             version "/wu-linux-x86_64.tar.gz"))
       (sha256
        (base32 "05wd410104mjr08m96b1rgnkqk51vgzc985jl6ns6b27f8bgc9i4"))))
    (build-system binary-build-system)
    (arguments
     (list
      ;; tarball 顶层是 wu.app/，strip 后得 bin/、libexec/、share/；
      ;; 基座 unpack 由下方自定义 phase 接管，此处 'none 仅满足显式声明要求。
      #:unpack-method 'none
      #:install-plan
      #~'(("bin/wu" "lib/wu/bin/wu")
          ("libexec/wu-editor" "lib/wu/libexec/wu-editor"))
      ;; RPATH 自动取 lib-dir（lib/wu）+ 全部 inputs 的 /lib。
      #:patchelf-plan
      #~'(("lib/wu/bin/wu")
          ("lib/wu/libexec/wu-editor"))
      #:wrap-plan
      #~'(("lib/wu/bin/wu"
           ("ZED_UPDATE_EXPLANATION" =
            ("Updates are handled by the Guix package manager."))
           ("XKB_CONFIG_ROOT" ":" prefix
            (#$(file-append xkeyboard-config "/share/X11/xkb")))))
      #:modules '((guix build utils) (ice-9 regex))
      #:phases
      #~(modify-phases %standard-phases
          (replace 'unpack
            (lambda _
              ;; tarball top level is ./wu.app
              (invoke "tar" "--strip-components=1" "-xzf" #$source)))
          (add-after 'install 'install-links
            (lambda _
              (let ((libdir (string-append #$output "/lib/wu")))
                ;; bin/ and libexec/ stay siblings under lib/wu/ so the
                ;; launcher's bundle detection
                ;; (../libexec/wu-editor relative to /proc/self/exe)
                ;; keeps resolving.
                (mkdir-p (string-append #$output "/bin"))
                (symlink (string-append libdir "/bin/wu")
                         (string-append #$output "/bin/wu")))))
          (add-after 'install 'install-desktop-and-icons
            (lambda _
              (let ((share (string-append #$output "/share")))
                (mkdir-p (string-append share "/applications"))
                (copy-file "share/applications/me.farshed.Wu.desktop"
                           (string-append share "/applications/me.farshed.Wu.desktop"))
                (substitute* (string-append share "/applications/me.farshed.Wu.desktop")
                  ;; 主入口与 [Desktop Action NewWorkspace] 的 Exec 都换成
                  ;; 绝对路径；TryExec=wu 删掉（未装进 profile 时别隐藏入口）。
                  (("Exec=wu ") (string-append "Exec=" #$output "/bin/wu "))
                  (("TryExec=wu\n") ""))
                (copy-recursively "share/icons"
                                  (string-append share "/icons"))))))))
    (inputs
     `(("bash-minimal" ,bash-minimal)
       ("glibc" ,glibc)
       ("gcc:lib" ,gcc "lib")
       ("alsa-lib" ,alsa-lib)
       ("libxcb" ,libxcb)
       ("libxkbcommon" ,libxkbcommon)
       ("wayland" ,wayland)
       ("mesa" ,mesa)
       ("vulkan-loader" ,vulkan-loader)
       ("xkeyboard-config" ,xkeyboard-config)))
    (home-page "https://github.com/dstrml/wu")
    (synopsis "Fast native code editor with built-in coding agents")
    (description "Wu is a fast, native code editor written in Rust with
coding agents built in.  It is a fork of Zed and provides a GPU-accelerated
UI, built-in support for Claude Code, Codex and OpenCode, and requires no
account or telemetry.  This package provides the prebuilt binary release.")
    (properties `((upstream-name . "wu")))
    (license license:gpl3+)
    (supported-systems '("x86_64-linux"))))

;;; helix-steel tracks mattwparas' steel-event-system branch of Helix: an
;;; experimental build that embeds the Steel Scheme interpreter as a
;;; scripting/event engine.  The branch has no release tags, so the version
;;; is the workspace baseline plus the tracked branch commit (handled by
;;; update_versions.py's let-bound git-version logic).
;;;
;;; Steel enters as git dependencies pinned to a single upstream commit (see
;;; the rust-steel-* origins in rust-crates.scm).  cargo-build-system only
;;; vendors crates.io sources, and cargo --offline cannot check out git
;;; sources, so the steel checkout - a virtual Cargo workspace, rejected by
;;; the vendor phase like any workspace - is passed through as a plain input
;;; and the branch's Cargo.toml is patched to point the steel-core git
;;; dependency at the checkout's crates/steel-core; steel's crates resolve
;;; their mutual path dependencies inside the checkout, so a single path
;;; rewrite is enough.  The branch's built-in Steel configuration scripts
;;; are compiled in via include_str!, and the inherited install phases
;;; (binary + runtime + desktop entry, HELIX_RUNTIME wrapper) work unchanged.
(define-public helix-steel
  (let ((commit "8c381ba3783046fe75c5fef7df6966711c1ff860")
        (revision "8"))
    (package
      (inherit helix)
      (name "helix-steel")
      (version (git-version "25.7.1" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/mattwparas/helix")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "0rgl07q81dgz0g9lywfjwn9mhz68q9p1z2jpk37cv78625dib5in"))))
      (arguments
       (substitute-keyword-arguments (package-arguments helix)
         ((#:phases phases)
          #~(modify-phases #$phases
              (add-after 'unpack 'patch-steel-git-dependency
                (lambda* (#:key inputs #:allow-other-keys)
                  ;; The branch declares steel-core in the workspace deps
                  ;; and steel-doc directly in helix-term; both git
                  ;; declarations must become path dependencies.
                  (let* ((steel (assoc-ref inputs
                                           "rust-steel-core-0.8.3.118fb9f-checkout"))
                         (steel-url "https://github.com/mattwparas/steel.git")
                         (root-dep
                          (string-append
                           "steel-core = \\{ git = \"" steel-url "\""))
                         (term-dep
                          (string-append
                           "steel-doc = \\{ git = \"" steel-url "\"")))
                    (substitute* "Cargo.toml"
                      ((root-dep)
                       (string-append
                        "steel-core = { path = \"" steel "/crates/steel-core\"")))
                    (substitute* "helix-term/Cargo.toml"
                      ((term-dep)
                       (string-append
                        "steel-doc = { path = \"" steel "/crates/steel-doc\""))))))))))
      (inputs
       (cons bash-minimal
             (cargo-inputs 'helix-steel
                           #:module '(jeans packages rust-crates))))
      (synopsis "Post-modern modal text editor with an embedded Steel Scheme runtime")
      (description
       "A Kakoune / Neovim inspired modal text editor with the Steel Scheme
interpreter embedded as its scripting and event engine.")
      (properties
       `((with-latest-git-commit . #t)
         (git-branch . "steel-event-system"))))))

;;; OpenIDEA: IntelliJ IDEA 风格的 IDE（Rust 内核 + Tauri v2/WebKitGTK
;;; 前端），Apache-2.0。  上游 .deb 的 payload 只有一个 243 MB 的 Tauri
;;; ELF 加 .desktop 与 hicolor 图标；前端资源内嵌在二进制里，没有
;;; usr/lib 资源树，因此不涉及 Tauri 的 resource_dir 布局。
;;
;;; NEEDED 里的 libwebkit2gtk-4.1 / libjavascriptcoregtk-4.1 由 Guix 的
;;; webkitgtk-for-gtk3 提供（与 Debian 的 libwebkit2gtk-4.1-0 同一
;;; ABI），其余是 GTK3 全家。  二进制只用 /proc/self/exe 推算
;;; resource_dir（无资源可读），patchelf 只改 interpreter/RPATH，
;;; wrap-program 改文件名同样不影响它。
;;
;;; wrapper 补 Guix 下 GTK/WebKit 缺的运行时环境：
;;;   - XDG_DATA_DIRS 加 gtk+ 的 GSettings schema（org.gtk.Settings）；
;;;   - GIO_EXTRA_MODULES 加 glib-networking 的 TLS 后端——libsoup 经
;;;     GIO 模块加载 TLS，不设则 HTTPS 请求失败；
;;;   - FONTCONFIG_FILE 指向 fontconfig（包名 fontconfig-minimal）的
;;;     配置，与其它 GTK 包一致；
;;; gdk-pixbuf 的 loader 走 Guix 补丁识别的 GUIX_GDK_PIXBUF_MODULE_FILES
;;;（由 profile hook 提供），这里不指向单个包的残缺 cache。
(define-public openidea-bin
  (package
    (name "openidea-bin")
    (version "0.1.55")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/l0ng-ai/openidea/releases/download/v"
             version "/OpenIDEA_" version "_amd64.deb"))
       (sha256
        (base32 "07imfm6sjm96a7mbz0zgpc758jnc3kxnajxp2gn9cacyb45v9w4b"))))
    (build-system binary-build-system)
    (arguments
     (list
      #:unpack-method 'deb
      #:install-plan
      #~'(("usr/bin/openidea" "bin/openidea")
          ("usr/share/applications/OpenIDEA.desktop"
           "share/applications/OpenIDEA.desktop")
          ("usr/share/icons/" "share/icons/"))
      ;; RPATH = inputs 与 standard-packages 的 /lib；已用 ld.so --list
      ;;（env -i，不带 wrapper 环境）确认 NEEDED 全解析。
      #:patchelf-plan
      #~'(("bin/openidea"))
      #:wrap-plan
      #~'(("bin/openidea"
           ("XDG_DATA_DIRS" ":" prefix
            (#$(file-append gtk+ "/share")))
           ("GIO_EXTRA_MODULES" ":" prefix
            (#$(file-append glib-networking "/lib/gio/modules")))
           ("FONTCONFIG_FILE" =
            (#$(file-append fontconfig "/etc/fonts/fonts.conf")))))
      #:desktop-files
      #~'(("share/applications/OpenIDEA.desktop"))))
    (native-inputs (list binutils))
    (inputs
     `(("bash-minimal" ,bash-minimal)
       ("cairo" ,cairo)
       ("dbus" ,dbus)
       ("fontconfig-minimal" ,fontconfig)
       ("gcc:lib" ,gcc "lib")
       ("gdk-pixbuf" ,gdk-pixbuf)
       ("glib" ,glib)
       ("glib-networking" ,glib-networking)
       ("glibc" ,glibc)
       ("gtk+" ,gtk+)
       ("libsoup" ,libsoup)
       ("wayland" ,wayland)
       ("webkitgtk-for-gtk3" ,webkitgtk-for-gtk3)))
    (properties '((upstream-name . "OpenIDEA")))
    (home-page "https://github.com/l0ng-ai/openidea")
    (synopsis "IntelliJ IDEA-inspired integrated development environment")
    (description
     "OpenIDEA is an integrated development environment modelled on
IntelliJ IDEA.  It combines editing with code insight, navigation,
refactoring, debugging, VCS integration, a terminal, database tools and
an HTTP client, with keybindings and tool windows familiar to IntelliJ
users, for JVM and other language projects.  This package installs the
vendor's prebuilt Linux release.")
    (license license:asl2.0)
    (supported-systems '("x86_64-linux"))))

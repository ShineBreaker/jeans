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
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages lisp-check)
  #:use-module (gnu packages lisp-xyz)
  #:use-module (gnu packages ncurses)
  #:use-module (gnu packages terminals)
  #:use-module (gnu packages text-editors)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages tree-sitter)
  #:use-module (gnu packages webkit)
  #:use-module (gnu packages)
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
    (version "20260531-0400")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/lem-project/lem/releases/download/"
             "nightly-latest/Lem-x86_64.AppImage"))
       (sha256
        (base32 "1k37fr76w0sknss90nj8hgr3c7b4nbnrk03dlbdlfdnc9iib6rqs"))))
    (build-system copy-build-system)
    (arguments
     (list
      #:tests? #f
      #:validate-runpath? #f
      #:strip-binaries? #f
      #:install-plan
      #~'(("usr/libexec/lem.real" "libexec/lem-next/")
          ("usr/lib/libwebview.so.0.12.0" "libexec/lem-next/")
          ("usr/lib/libasyncprocess.so" "libexec/lem-next/")
          ("usr/lib/terminal.so" "libexec/lem-next/")
          ("usr/share/icons/hicolor/256x256/apps/lem.png"
           "share/icons/hicolor/256x256/apps/"))
      #:phases
      #~(modify-phases %standard-phases
          (delete 'install-license-files)
          (add-after 'unpack 'extract-appimage
            (lambda _
              (invoke "7z" "x" (car (find-files "." "\\.AppImage$")))))
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
                   (string-append "Exec=" #$output "/bin/lem"))))))
          ;; The SBCL core baked into lem.real dlopens exact Ubuntu
          ;; 22.04 sonames; alias them to Guix's libraries.
          (add-after 'install 'fix-so
            (lambda _
              (symlink #$(file-append ncurses "/lib/libncursesw.so.6")
                       (string-append #$output
                                      "/libexec/lem-next/libncursesw.so.6.3"))
              ;; tree-sitter's C ABI is backward compatible across 0.2x.
              (symlink #$(file-append tree-sitter "/lib/libtree-sitter.so.0.25")
                       (string-append #$output
                                      "/libexec/lem-next/libtree-sitter.so.0.27"))))
          (add-after 'install-desktop-entry 'wrap-lem
            (lambda* (#:key inputs #:allow-other-keys)
              (let* ((out #$output)
                     (libexec (string-append out "/libexec/lem-next"))
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
    (home-page "http://lem-project.github.io/")
    (synopsis "Integrated IDE/editor for Common Lisp (nightly prebuild)")
    (description
     "Lem is a Common Lisp editor/IDE with high expansibility.  This
package provides a prebuilt nightly build of Lem's master branch, using
the webview (GTK/WebKitGTK) frontend with an ncurses fallback.")
    (properties
     `((upstream-name . "lem")))
    (license license:expat)))

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
  (let ((commit "68e85e08e05b183f5dba78a8a84cb97fc19fb681")
        (revision "0"))
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
          (base32 "0rhrmkcdx2x9lg77m226y52kxfgm45jafqzmrshhvj4qhffs2rk4"))
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
                          "-lutil")))))))
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
                 sbcl-cl-iconv
                 sbcl-cl-mustache
                 sbcl-cl-package-locks
                 sbcl-cl-ppcre
                 sbcl-cl-setlocale
                 sbcl-cl-str
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
    (version "0.4.10")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/sinelaw/fresh/releases/download/"
             "v" version "/fresh-editor_" version "-1_amd64.deb"))
       (sha256
        (base32 "0fcidrgfqc7plfr56iq1iy1habbfw4j3cjrbgs1b5bn06vk1bqgy"))))
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
              (let ((debdir (string-append "fresh-editor-" #$version)))
                (mkdir debdir)
                (with-directory-excursion debdir
                  (invoke "ar" "x" #$source)
                  (invoke "tar" "xf" "data.tar.xz"))
                (chdir debdir))))
          (replace 'install
            (lambda* (#:key inputs #:allow-other-keys)
              (let* ((out #$output)
                     (bin (string-append out "/bin"))
                     (share (string-append out "/share"))
                     (patchelf-bin
                      (string-append (assoc-ref inputs "patchelf")
                                     "/bin/patchelf"))
                     (ldso (string-append (assoc-ref inputs "glibc")
                                          "/lib/ld-linux-x86-64.so.2"))
                     (rpath
                      (string-join
                       (list (string-append (assoc-ref inputs "glibc") "/lib")
                             (string-append (assoc-ref inputs "gcc:lib")
                                            "/lib")
                             (string-append (assoc-ref inputs "gpm") "/lib"))
                       ":")))
                ;; Patch ELF interpreter and RPATH, then install.
                (invoke patchelf-bin "--set-interpreter" ldso "usr/bin/fresh")
                (invoke patchelf-bin "--set-rpath" rpath "usr/bin/fresh")
                (install-file "usr/bin/fresh" bin)
                ;; Install desktop entry with an absolute Exec path.
                (mkdir-p (string-append share "/applications"))
                (copy-file "usr/share/applications/fresh.desktop"
                           (string-append share "/applications/fresh.desktop"))
                (substitute* (string-append share "/applications/fresh.desktop")
                  (("Exec=fresh")
                   (string-append "Exec=" bin "/fresh")))

                ;; Install all hicolor icon sizes and the man page.
                (copy-recursively "usr/share/icons"
                                  (string-append share "/icons"))
                (install-file "usr/share/man/man1/fresh.1.gz"
                              (string-append share "/man/man1"))))))))
    (native-inputs (list patchelf binutils))
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
    (license license:gpl2)
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
  (let ((commit "ba5b022c1000a0ce28d4ce1d09acdd062a83a020")
        (revision "1"))
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
          (base32 "1a4p37kclcrqwaxbq00kbr5w9zwc2yhvnr95pxxkmz4c3f1xb7mw"))))
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

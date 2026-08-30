;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-only

(define-module (jeans packages editor)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix utils)
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
  #:use-module (gnu packages ncurses)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages webkit))

;;; lem-next-bin tracks Lem's rolling nightly release (built from master).
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
    (version "20250810-0811")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/lem-project/lem/releases/download/nightly-"
             version "/Lem-x86_64-nightly.AppImage"))
       (sha256
        (base32 "0gc8f9lqj92wzpbmj3cf30i75k2indjhla57b820fajfm0vqwd5a"))))
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
                           (string-append apps "/lem-next.desktop"))
                ;; Upstream's entry launches the AppImage-internal run-lem
                ;; shim; point straight at our wrapper instead.
                (substitute* (string-append apps "/lem-next.desktop")
                  (("Exec=run-lem %F")
                   (string-append "Exec=" #$output "/bin/lem-next"))))))
          ;; The SBCL core baked into lem.real dlopens the exact Ubuntu
          ;; 22.04 soname; alias it to Guix's ncurses.
          (add-after 'install 'fix-so
            (lambda _
              (symlink #$(file-append ncurses "/lib/libncursesw.so.6")
                       (string-append #$output
                                      "/libexec/lem-next/libncursesw.so.6.3"))))
          (add-after 'install-desktop-entry 'wrap-lem-next
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
                (with-output-to-file (string-append out "/bin/lem-next")
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
                (chmod (string-append out "/bin/lem-next") #o555)))))))
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
       ("webkitgtk-for-gtk3" ,webkitgtk-for-gtk3)))
    (home-page "http://lem-project.github.io/")
    (synopsis "Integrated IDE/editor for Common Lisp (nightly prebuild)")
    (description
     "Lem is a Common Lisp editor/IDE with high expansibility.  This
package provides a prebuilt nightly build of Lem's master branch, using
the webview (GTK/WebKitGTK) frontend with an ncurses fallback.")
    (properties
     `((upstream-name . "lem")
       (release-tag-prefix . "^nightly-")
       (accept-pre-releases? . #t)))
    (license license:expat)))

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

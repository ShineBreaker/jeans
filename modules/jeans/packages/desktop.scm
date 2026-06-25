;;; SPDX-FileCopyrightText: 2024, 2025 Murilo <murilo@disroot.org>
;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-only

(define-module (jeans packages desktop)
  #:use-module (gnu packages)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages bootstrap)
  #:use-module (gnu packages check)
  #:use-module (gnu packages commencement)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages backup)
  #:use-module (gnu packages elf)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages gl)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages gnuzilla)
  #:use-module (gnu packages gstreamer)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages icu4c)
  #:use-module (gnu packages image)
  #:use-module (gnu packages instrumentation)
  #:use-module (gnu packages libevent)
  #:use-module (gnu packages libffi)
  #:use-module (gnu packages linphone)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages llvm)
  #:use-module (gnu packages networking)
  #:use-module (gnu packages nss)
  #:use-module (gnu packages pciutils)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages pulseaudio)
  #:use-module (gnu packages python)
  #:use-module (gnu packages python-build)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages video)
  #:use-module (gnu packages vulkan)
  #:use-module (gnu packages web)
  #:use-module (gnu packages webkit)
  #:use-module (gnu packages cups)
  #:use-module (gnu packages xml)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages wm)
  #:use-module (gnu packages xorg)
  #:use-module (guix build utils)
  #:use-module (jeans packages rust-crates)
  #:use-module (guix build-system cargo)
  #:use-module (guix build-system copy)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system python)
  #:use-module (guix build-system trivial)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module ((guix licenses)
                #:prefix license:))

(define-public python-screeninfo
  (package
    (name "python-screeninfo")
    (version "0.8.1")
    (source
     (origin
       (method url-fetch)
       (uri ((@ (guix build-system pyproject) pypi-uri) "screeninfo" version))
       (sha256
        (base32 "1l9frlckb9zbwx5kngxv5byi353jyfmpskcy38m40d3yrimhg0wr"))))
    (build-system python-build-system)
    (native-inputs (list python-setuptools))
    (arguments (list #:tests? #f))
    (home-page "https://github.com/rr-/screeninfo")
    (synopsis "Fetch location and size of physical screens")
    (description
     "Screeninfo is a Python package to fetch the location and size of
physical screens in multi-monitor setups.")
    (license license:expat)))

(define-public waypaper
  (package
    (name "waypaper")
    (version "2.8")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/anufrievroman/waypaper/archive/refs/tags/"
             version ".tar.gz"))
       (sha256
        (base32 "0jb8884ibylk9n8dzcm7zm9pxgz6v42gyhynpba704asv4gvx6kd"))))
    (build-system python-build-system)
    (arguments
     (list
      #:tests? #f
      #:phases
      #~(modify-phases %standard-phases
          (delete 'sanity-check)
          (add-after 'install 'wrap-gi-typelib
            (lambda* (#:key inputs outputs #:allow-other-keys)
              (let ((out (assoc-ref outputs "out"))
                    (gi-path (getenv "GI_TYPELIB_PATH")))
                (wrap-program (string-append out "/bin/waypaper")
                  `("GI_TYPELIB_PATH" ":" prefix
                    (,gi-path)))))))))
    (native-inputs (list python-setuptools-scm pkg-config
                         gobject-introspection))
    (propagated-inputs (list gtk+
                             python-pygobject
                             python-platformdirs
                             python-pillow
                             python-imageio
                             python-imageio-ffmpeg
                             python-screeninfo
                             socat))
    (home-page "https://github.com/anufrievroman/waypaper")
    (synopsis "GUI wallpaper manager for Wayland and Xorg Linux systems")
    (description
     "Waypaper is a simple GUI wallpaper manager for Linux, supporting both Wayland
and Xorg.")
    (license license:gpl3)))

(define-public opencode-desktop-bin
  (package
    (name "opencode-desktop-bin")
    (version "1.17.11")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/anomalyco/opencode/releases/download/"
             "v" version "/opencode-desktop-linux-amd64.deb"))
       (sha256
        (base32 "024189d75i4zrk31wmzgva10wl1ghdirhnw4hxvpn04a4sl6ydz3"))))
    (build-system gnu-build-system)
    (arguments
     (list
      #:tests? #f
      #:validate-runpath? #f
      #:strip-binaries? #f
      #:modules '((guix build gnu-build-system)
                  (guix build utils)
                  (ice-9 ftw)
                  (ice-9 regex)
                  (srfi srfi-26))
      #:phases
      #~(modify-phases %standard-phases
          (delete 'configure)
          (delete 'build)
          (replace 'unpack
            (lambda _
              (invoke "ar" "x" #$source)
              (invoke "tar" "xf" "data.tar.xz")))
          (replace 'install
            (lambda _
              (let ((out #$output))
                (copy-recursively "opt/OpenCode"
                                  (string-append out "/lib/opencode-desktop"))
                #t)))
          (add-after 'install 'patch-elf
            (lambda* (#:key inputs #:allow-other-keys)
              (let* ((ld.so (string-append #$(this-package-input "glibc")
                                           #$(glibc-dynamic-linker)))
                     (rpath (string-join
                             (cons* (string-append #$output "/lib/opencode-desktop")
                                    (map (lambda (input)
                                           (string-append (cdr input) "/lib"))
                                         inputs))
                             ":")))
                (define (patch-elf file)
                  (format #t "Patching ~a ..." file)
                  (unless (string-contains file ".so")
                    (invoke "patchelf" "--set-interpreter" ld.so file))
                  (invoke "patchelf" "--set-rpath" rpath file)
                  (display " done\n"))
                (for-each patch-elf
                          (append (find-files (string-append #$output
                                                             "/lib/opencode-desktop")
                                              ".*\\.so(\\.[0-9]+)?$")
                                  (map (lambda (binary)
                                         (string-append #$output
                                                        "/lib/opencode-desktop/"
                                                        binary))
                                       '("ai.opencode.desktop"
                                         "chrome_crashpad_handler"
                                         "chrome-sandbox")))))))
          (add-after 'patch-elf 'install-bin
            (lambda _
              (let* ((out #$output)
                     (bin (string-append out "/bin"))
                     (exe (string-append out "/lib/opencode-desktop/ai.opencode.desktop")))
                (mkdir-p bin)
                (symlink exe (string-append bin "/opencode-desktop")))))
          (add-after 'install-bin 'install-desktop
            (lambda _
              (let* ((out #$output)
                     (apps (string-append out "/share/applications")))
                (mkdir-p apps)
                (make-desktop-entry-file
                 (string-append apps "/opencode-desktop.desktop")
                 #:name "OpenCode"
                 #:type "Application"
                 #:comment #$(package-synopsis this-package)
                 #:exec (string-append #$output "/bin/opencode-desktop %U")
                 #:icon "opencode-desktop"
                 #:categories '("Development")
                 #:mime-type '("x-scheme-handler/opencode")
                 #:startup-w-m-class "OpenCode"))))
          (add-after 'install-desktop 'install-icons
            (lambda _
              (let* ((out #$output)
                     (icon-src "usr/share/icons/hicolor")
                     (icon-dst (string-append out "/share/icons/hicolor")))
                (when (file-exists? icon-src)
                  (copy-recursively icon-src icon-dst)
                  (for-each
                   (lambda (old)
                     (let ((new (string-append
                                 (string-append out "/share/icons/hicolor/"
                                                (match:substring
                                                 (string-match "/([0-9]+x[0-9]+)/apps/"
                                                               old) 1)
                                                "/apps/opencode-desktop.png"))))
                       (when (file-exists? old)
                         (copy-file old new))))
                   (find-files icon-dst "ai\\.opencode\\.desktop\\.png$"))))))
          (add-after 'install-icons 'wrap-program
            (lambda* (#:key inputs outputs #:allow-other-keys)
              (let* ((out (assoc-ref outputs "out"))
                     (lib (string-append out "/lib/opencode-desktop"))
                     (mesa-lib (string-append (assoc-ref inputs "mesa") "/lib"))
                     (nss-lib (string-append (assoc-ref inputs "nss") "/lib/nss")))
                (wrap-program (string-append out "/bin/opencode-desktop")
                  `("LD_LIBRARY_PATH" prefix
                    (,lib ,mesa-lib ,nss-lib))
                  `("FONTCONFIG_FILE" =
                    (,(string-append #$(this-package-input "fontconfig-minimal")
                                     "/etc/fonts/fonts.conf")))
                  `("XDG_DATA_DIRS" prefix
                    (,(string-append out "/share"))))))))))
    (native-inputs (list binutils patchelf tar xz))
    (inputs (list alsa-lib
                  at-spi2-core
                  cups
                  dbus
                  eudev
                  expat
                  fontconfig
                  `(,gcc "lib")
                  glibc
                  glib
                  gtk+
                  libx11
                  libxcb
                  libxcomposite
                  libxdamage
                  libxext
                  libxfixes
                  libxkbcommon
                  libxrandr
                  mesa
                  nss))
    (home-page "https://opencode.ai")
    (synopsis "AI coding agent desktop application")
    (description
     "OpenCode is a terminal-based AI coding agent with a desktop GUI built
with Electron.  It supports multiple LLM providers and offers an interactive
coding experience with context awareness.")
    (license license:expat)))

(define-public reasonix-desktop-bin
  (package
    (name "reasonix-desktop-bin")
    (version "1.12.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/esengine/DeepSeek-Reasonix/releases/download/"
             "desktop-v" version "/Reasonix-linux-amd64.deb"))
       (sha256
        (base32 "1px35mn2msqjyhj175hhj4gmmn9z3p9p3z13rk62bnih8nxg38y2"))))
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
              (invoke "bsdtar" "xf" #$source)
              (invoke "tar" "xzf" "data.tar.gz")))
          (replace 'install
            (lambda* (#:key inputs #:allow-other-keys)
              (let* ((out #$output)
                     (libexec (string-append out "/libexec/reasonix-desktop"))
                     (bin (string-append out "/bin"))
                     (ld.so (string-append (assoc-ref inputs "glibc")
                                           #$(glibc-dynamic-linker)))
                     (lib-path (string-join
                                (map (lambda (input)
                                       (string-append (cdr input) "/lib"))
                                     inputs)
                                ":"))
                     (glib-lib (string-append (assoc-ref inputs "glib") "/lib"))
                     (gtk-lib (string-append (assoc-ref inputs "gtk+") "/lib"))
                     (gtk-share (string-append (assoc-ref inputs "gtk+") "/share"))
                     (webkitgtk-lib (string-append (assoc-ref inputs "webkitgtk-for-gtk3")
                                                   "/lib"))
                     (webkitgtk-share (string-append (assoc-ref inputs "webkitgtk-for-gtk3")
                                                     "/share"))
                     (gdk-pixbuf (assoc-ref inputs "gdk-pixbuf")))
                (mkdir-p libexec)
                (copy-file "usr/bin/reasonix-desktop"
                           (string-append libexec "/reasonix-desktop"))
                (chmod (string-append libexec "/reasonix-desktop") #o755)
                (mkdir-p bin)
                (with-output-to-file (string-append bin "/reasonix-desktop")
                  (lambda ()
                    (display
                     (string-append
                      "#!" #$(this-package-input "bash-minimal") "/bin/sh\n"
                      "export FONTCONFIG_FILE=" #$(this-package-input "fontconfig-minimal") "/etc/fonts/fonts.conf\n"
                      "export XDG_DATA_DIRS=" out "/share:" gtk-share ":" webkitgtk-share "\n"
                      "export GI_TYPELIB_PATH=" glib-lib "/girepository-1.0:"
                      gtk-lib "/girepository-1.0:"
                      webkitgtk-lib "/girepository-1.0:"
                      gdk-pixbuf "/lib/girepository-1.0\n"
                      "export GIO_EXTRA_MODULES=" glib-lib "/gio/modules\n"
                      "export GDK_PIXBUF_MODULE_FILE=" gdk-pixbuf "/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache\n"
                      "exec " ld.so " --argv0 " libexec "/reasonix-desktop"
                      " --library-path " lib-path " " libexec "/reasonix-desktop \"$@\"\n"))))
                (chmod (string-append bin "/reasonix-desktop") #o755))))
          (add-after 'install 'install-desktop-entry
            (lambda _
              (let* ((out #$output)
                     (apps (string-append out "/share/applications"))
                     (pixmaps (string-append out "/share/pixmaps")))
                (mkdir-p apps)
                (mkdir-p pixmaps)
                (copy-file "usr/share/applications/reasonix.desktop"
                           (string-append apps "/reasonix-desktop.desktop"))
                (substitute* (string-append apps "/reasonix-desktop.desktop")
                  (("Exec=reasonix-desktop")
                   (string-append "Exec=" out "/bin/reasonix-desktop")))
                (copy-file "usr/share/pixmaps/reasonix-desktop.png"
                           (string-append pixmaps "/reasonix-desktop.png"))))))))
    (native-inputs (list libarchive tar gzip))
    (inputs (list `(,gcc "lib")
                  bash-minimal
                  fontconfig
                  glibc
                  glib
                  gtk+
                  gdk-pixbuf
                  libsoup
                  mesa
                  webkitgtk-for-gtk3))
    (home-page "https://github.com/esengine/DeepSeek-Reasonix")
    (synopsis "DeepSeek-native AI coding agent with desktop GUI")
    (description
     "Reasonix is a DeepSeek-native AI coding agent for your terminal,
tuned around DeepSeek's prefix cache so token costs stay low across long sessions.
This is the desktop version with a graphical interface built with Wails
(Go + WebKitGTK).  It provides a config- and plugin-driven harness with
support for multiple LLM providers.")
    (license license:expat)
    (supported-systems '("x86_64-linux"))))

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
       (uri (pypi-uri "screeninfo" version))
       (sha256
        (base32 "1l9frlckb9zbwx5kngxv5byi353jyfmpskcy38m40d3yrimhg0wr"))))
    (build-system python-build-system)
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

(define-public niri-latest
  (let ((commit "a85b922919815c32a3ae34e0838830fe522d6a1c")
        (revision "0")
        (base-version "26.04"))
    (package/inherit niri
      (name "niri-latest")
      (version (git-version base-version revision commit))
      (source (origin
                (method git-fetch)
                (uri (git-reference
                      (url "https://github.com/niri-wm/niri")
                      (commit commit)))
                (file-name (git-file-name name version))
                (sha256 (base32
                          "1hzxv1i7w4s00l6qwkcwj6bgfzl3xdn712zvwr3jrgkbxb9b68rg"))))
      (inputs
       (append (map cadr
                    (filter (lambda (input)
                              (not (string-prefix? "rust-"
                                                   (car input))))
                            (package-inputs niri)))
               (cargo-inputs 'niri
                             #:module '(jeans packages rust-crates))))
       (arguments
       (substitute-keyword-arguments (package-arguments niri)
         ((#:phases phases)
          #~(modify-phases #$phases
              (add-after 'configure 'fix-smithay-vendor
                (lambda _
                  ;; cargo-build-system rewrites git dependencies and may join
                  ;; version/rev onto a single line, producing invalid TOML.
                  (substitute* "Cargo.toml"
                    (("version = \"\\*\"[[:space:]]*rev = \"[0-9a-f]+\"")
                     "version = \"*\""))
                  ;; smithay-drm-extras is a workspace member inside the smithay
                  ;; git repo.  The guix-vendor directory for it contains the
                  ;; whole smithay repo, whose root Cargo.toml declares name
                  ;; "smithay" — cargo cannot find smithay-drm-extras there by
                  ;; version.  Rewrite the root Cargo.toml so cargo finds
                  ;; smithay-drm-extras correctly with a proper lib path.
                  (let* ((drm-vendor "guix-vendor/rust-smithay-drm-extras-0.1.0.ff5fa7d-checkout")
                         (toml (string-append drm-vendor "/Cargo.toml")))
                    (chmod toml #o644)
                    (call-with-output-file toml
                      (lambda (p)
                        (display "[package]\n" p)
                        (display "name = \"smithay-drm-extras\"\n" p)
                        (display "version = \"0.1.0\"\n" p)
                        (display "edition = \"2024\"\n" p)
                        (display "\n" p)
                        (display "[lib]\n" p)
                        (display "path = \"smithay-drm-extras/src/lib.rs\"\n" p)
                        (display "\n" p)
                        (display "[dependencies]\n" p)
                        (display "drm = { version = \"0.14.0\" }\n" p)))
                    (chmod toml #o444)))))))))))


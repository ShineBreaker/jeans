;;; SPDX-FileCopyrightText: 2024, 2025 Murilo <murilo@disroot.org>
;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-only

(define-module (jeans packages desktop)
  #:use-module (gnu packages)
  #:use-module (gnu packages bash)        ; bash-minimal
  #:use-module (gnu packages glib)        ; gobject-introspection, python-pygobject
  #:use-module (gnu packages gtk)         ; gtk+
  #:use-module (gnu packages networking)  ; socat
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages python-build) ; python-setuptools-scm
  #:use-module (gnu packages python-xyz)  ; python-screeninfo, python-platformdirs, python-pillow, ...
  #:use-module (guix build-system python)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix packages)
  #:use-module ((guix licenses)
                #:prefix license:))

(define-public waypaper
  (package
    (name "waypaper")
    (version "2.8")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/anufrievroman/waypaper")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0xd37qr6m2icjl0w0saq3318nw4g7i7zna5m1yr6ym3zp2byjdh5"))))
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
    (inputs `(("bash-minimal" ,bash-minimal)))
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

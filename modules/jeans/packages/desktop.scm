(define-module (jeans packages desktop)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system python)
  #:use-module (guix build-system copy)
  #:use-module (guix gexp)
  #:use-module (gnu packages)
  #:use-module (gnu packages check)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages image)
  #:use-module (gnu packages networking)
  #:use-module (gnu packages video)
  #:use-module (gnu packages python)
  #:use-module (gnu packages python-build)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages xorg)
  #:use-module (gnu packages pkg-config))

(define-public waypaper-fix
  (package
    (name "waypaper-fix")
    (version "2.7")
    (source (origin
              (method url-fetch)
              (uri (string-append
                    "https://github.com/anufrievroman/waypaper/archive/refs/tags/"
                    version ".tar.gz"))
              (sha256
               (base32
                "18yxsic5pfxf3cxn5l5cmi72566qq5v74baa7fnc9g2kgm9m3czm"))))
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
                  `("GI_TYPELIB_PATH" ":" prefix (,gi-path)))))))))
    (native-inputs
     (list python-setuptools-scm
           pkg-config
           gobject-introspection))
    (propagated-inputs
     (list gtk+
           python-pygobject
           python-platformdirs
           python-pillow
           python-imageio
           python-imageio-ffmpeg
           socat))
    (home-page "https://github.com/anufrievroman/waypaper")
    (synopsis "GUI wallpaper manager for Wayland and Xorg Linux systems")
    (description
     "Waypaper is a simple GUI wallpaper manager for Linux, supporting both Wayland
and Xorg.")
    (license license:gpl3)))

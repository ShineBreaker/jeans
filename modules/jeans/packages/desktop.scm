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
  #:use-module (gnu packages video)
  #:use-module (gnu packages python)
  #:use-module (gnu packages python-build)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages xorg))

(define-public waypaper
  (package
    (name "waypaper")
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
          (delete 'sanity-check))))
    (propagated-inputs
     (list python-pygobject
           python-platformdirs
           python-pillow
           python-imageio
           python-imageio-ffmpeg
           gtk+))
    (native-inputs
     (list python-setuptools-scm))
    (home-page "https://github.com/anufrievroman/waypaper")
    (synopsis "GUI wallpaper manager for Wayland and Xorg Linux systems")
    (description
     "Waypaper is a simple GUI wallpaper manager for Linux, supporting both Wayland
and Xorg.  It provides a graphical interface to manage and set wallpapers with
support for various wallpaper backends including swaybg, swww, hyprpaper, and feh.

Note: python-screeninfo is not currently available in Guix, but is an optional
dependency for multi-monitor support.")
    (license license:gpl3)))

waypaper

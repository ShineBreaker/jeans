(define-module (jeans packages fonts)
  #:use-module (ice-9 regex)
  #:use-module (guix utils)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module ((nonguix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix build-system font)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system meson)
  #:use-module (guix build-system trivial)
  #:use-module (guix build-system copy)
  #:use-module (gnu packages)
  #:use-module (gnu packages c)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages gd)
  #:use-module (gnu packages gettext)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages python)
  #:use-module (gnu packages python-compression)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages sdl)
  #:use-module (gnu packages xorg))

(define-public font-maple-font-nf-cn
  (package
    (name "font-maple-font-nf-cn")
    (version "7.9")
    (source (origin
              (method url-fetch)
              (uri (string-append
                    "https://github.com/subframe7536/maple-font/releases/download/v"
                    version "/MapleMono-NF-CN-unhinted.zip"))
              (sha256
               (base32
                "1b3wbgd9gngwv61ybinwxkpmyam2b7fdxxmfzvgiah6g68lm525b"))))
    (build-system font-build-system)
    (home-page "https://font.subf.dev/")
    (synopsis "Maple Mono is an open source monospace font focused on smoothing your coding flow.")
    (description
     "Maple Mono: Open source monospace font with round corner, ligatures and Nerd-Font icons for IDE and terminal, fine-grained customization options.")
    (license license:silofl1.1)
    (properties '((upstream-name . "MapleMono-NF-CN-unhinted")))))

(define-public font-misans
  (package
    (name "font-misans")
    (version "2.0")
    (source
     (origin
       (method url-fetch)
       (uri "https://hyperos.mi.com/font-download/MiSans.zip")
       (sha256
        (base32
         "1nc1gfdmc112axbws98y8k2s3g09arpg7vgq5mhj4n834z41zamn"))))
    (build-system font-build-system)

    (native-inputs
     (list
      (list "font-license"
            (local-file "../../../licenses/misans.txt"))))

    (arguments
     (list
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'add-license
            (lambda* (#:key inputs #:allow-other-keys)
              (copy-file (assoc-ref inputs "font-license")
                         "LICENSE"))))))

    (home-page "https://hyperos.mi.com/font/")
    (synopsis "MiSans is a font family for Xiaomi HyperOS.")
    (description
     "MiSans is a font family for Xiaomi HyperOS, introduced in 2021 with MIUI 13.
A precursor, Mi Lanting, was launched with MIUI 8 in 2016. MiSans Global debuted in 2023.")
    (license (license:nonfree "file://LICENSE"))))


font-misans

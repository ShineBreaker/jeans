(define-module (jeans packages theme)
  #:use-module (guix build-system trivial)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system copy)
  #:use-module (guix build-system meson)
  #:use-module (guix build-system python)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module ((guix licenses)
                #:prefix license:)
  #:use-module (gnu packages)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages build-tools)
  #:use-module (gnu packages check)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages gettext)
  #:use-module (gnu packages gl)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages gstreamer)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages qt)
  #:use-module (gnu packages web))

(define-public vimix-gtk-themes
  (package
    (name "vimix-gtk-themes")
    (version "2025-06-20")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/vinceliuice/Vimix-gtk-themes")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0xgqgha21d198dc1cq4ysdylwn4db5w70mbixr7830sswszvl6dr"))
       (modules '((guix build utils)
                  (ice-9 regex)
                  (srfi srfi-26)))
       (snippet '(begin
                   (for-each (lambda (f)
                               (let* ((r (make-regexp "\\.scss"))
                                      (f* (regexp-substitute #f
                                                             (regexp-exec r f)
                                                             'pre ".css")))
                                 (if (file-exists? f*)
                                     (delete-file f*))))
                             (find-files "." ".*\\.scss")) #t))))
    (build-system gnu-build-system)
    (arguments
     `(#:configure-flags (list "--dest"
                               (string-append (assoc-ref %outputs "out")
                                              "/share/themes") "--theme" "all")
       #:tests? #f ;no tests
       #:phases (modify-phases %standard-phases
                  (delete 'bootstrap)
                  (delete 'configure)
                  (replace 'build
                    (lambda _
                      (invoke "./parse-sass.sh")))
                  (replace 'install
                    (lambda* (#:key configure-flags #:allow-other-keys)
                      (mkdir-p (cadr (or (member "--dest" configure-flags)
                                         (member "-d" configure-flags))))
                      (apply invoke "./install.sh" configure-flags) #t)))))
    (inputs (list gtk-engines))
    (native-inputs (list ;("coreutils" ,coreutils)
                         gtk+ sassc))
    (home-page "https://github.com/vinceliuice/Vimix-gtk-themes")
    (synopsis
     "Vimix is a flat Material Design theme for GTK 3, GTK 2 and Gnome-Shell etc.")
    (description
     "Vimix is a flat Material Design theme for GTK 3,
      GTK 2 and Gnome-Shell which supports GTK 3 and GTK 2 based desktop
      environments like Gnome, Unity, Budgie, Pantheon, XFCE, Mate, etc.")
    (license (list ;According to COPYING.
                   license:gpl3
                   ;Some style sheets.
                   license:lgpl2.1
                   ; Some icons
                   license:cc-by-sa4.0))))

(define-public vimix-kvantum-themes
  (package
    (name "vimix-kvantum-themes")
    (version "2021-09-05")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/vinceliuice/Vimix-kde")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "03gs4hxnwkvyxg6wmhlilvc3srdq7vhvsyhrmz5d36ad3n4ar8pm"))))
    (build-system copy-build-system)
    (arguments
     `(#:install-plan '(("Kvantum" "share/Kvantum"))
       #:phases (modify-phases %standard-phases
                  (delete 'build))))
    (inputs (list kvantum))
    (home-page "https://github.com/vinceliuice/Vimix-gtk-themes")
    (synopsis "Build from Vimix kde.")
    (description
     "Vimix kde is a flat Design theme for KDE Plasma desktop.
      This package provides only the Kvantum themes, as full
      KDE support is not available in Guix.")
    (license (list license:gpl3 license:lgpl2.1 license:cc-by-sa4.0))))

(define-public orchis-kvantum-themes
  (package
    (name "orchis-kvantum-themes")
    (version "2025-10-18")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/vinceliuice/Orchis-kde")
             (commit "b2a96919eee40264e79db402b915f926436100ad")))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "0jn0n8187nn1d1j2w3qj32nd3zvr2v2d2qzv8lvxhdfpp5b41vcq")))) ; ← 这里需要替换成正确的 hash
    (build-system copy-build-system)
    (arguments
     `(#:install-plan '(("Kvantum" "share/Kvantum"))
       #:phases (modify-phases %standard-phases
                  (delete 'build))))
    (inputs (list kvantum))
    (home-page "https://github.com/vinceliuice/Orchis-kde")
    (synopsis "Orchis Kvantum themes for KDE Plasma")
    (description
     "Orchis is a Material Design theme for KDE Plasma desktop.
      This package provides only the Kvantum themes, as full
      KDE support is not available in Guix.")
    (license (list license:gpl3 license:lgpl2.1 license:cc-by-sa4.0))))

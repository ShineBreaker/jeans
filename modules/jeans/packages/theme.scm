;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-only

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

;; (base32 "0000000000000000000000000000000000000000000000000000")
; for test.

(define-public colloid-gtk-theme
  (package
    (name "colloid-gtk-theme")
    (version "2025-07-31")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/vinceliuice/Colloid-gtk-theme")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256

        (base32 "1hv8wrylnwmq1mgz5bv012np4rsr4537smihv2plx4j0w1wxp5fj"))
       (modules '((guix build utils)))
       (snippet
        '(for-each (lambda (file)
                     (let ((css (string-append (substring file 0 (- (string-length file) 5)) ".css")))
                       (when (file-exists? css)
                         (delete-file css))))
                   (find-files "." "\\.scss$")))))
    (build-system gnu-build-system)
    (arguments
     `(#:configure-flags (list "--dest"
                               (string-append (assoc-ref %outputs "out")
                                              "/share/themes") "--theme" "all")
       #:tests? #f ;no tests
       #:phases (modify-phases %standard-phases
                  (delete 'bootstrap)
                  (delete 'configure)
                  (delete 'build)
                  (replace 'install
                    (lambda* (#:key configure-flags #:allow-other-keys)
                      (mkdir-p (cadr (or (member "--dest" configure-flags)
                                         (member "-d" configure-flags))))
                      (apply invoke "./install.sh" configure-flags))))))
    (inputs (list gtk-engines))
    (native-inputs (list ;("coreutils" ,coreutils)
                         gtk+ sassc))
    (home-page "https://github.com/vinceliuice/Colloid-gtk-theme")
    (synopsis
     "Colloid gtk theme for linux.")
    (description
     "Colloid gtk theme for linux.")
    (license (list ;According to COPYING.
                   license:gpl3
                   ;Some style sheets.
                   license:lgpl2.1
                   ; Some icons
                   license:cc-by-sa4.0))))

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

(define-public orchis-kde-themes
  (package
    (name "orchis-kde-themes")
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
         "0jn0n8187nn1d1j2w3qj32nd3zvr2v2d2qzv8lvxhdfpp5b41vcq"))))
    (build-system copy-build-system)
    (arguments
     `(#:install-plan '(
       ("aurorae" "share/aurorae/themes")
       ("color-schemes" "share/color-schemes")
       ("Kvantum" "share/Kvantum")
       ("plasma/desktoptheme" "share/plasma/desktoptheme")
       ("plasma/look-and-feel" "share/plasma/look-and-feel")
       ("wallpapers" "share/wallpapers"))
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

(define-public colloid-kde-themes
  (package
    (name "colloid-kde-themes")
    (version "2025-07-06")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/vinceliuice/Colloid-kde")
             (commit "b768904d10ba9fcb95abfb59538eab100b1fed1e")))
       (file-name (git-file-name name version))
       (sha256
         (base32 "0c4nhc9nh8mb17iyi5vzqd4r3365sqggzxwyhyiqvlqgfcgblrh9"))))
    (build-system copy-build-system)
    (arguments
     `(#:install-plan '(
       ("aurorae" "share/aurorae/themes")
       ("color-schemes" "share/color-schemes")
       ("Kvantum" "share/Kvantum")
       ("plasma/desktoptheme" "share/plasma/desktoptheme")
       ("plasma/look-and-feel" "share/plasma/look-and-feel")
       ("wallpapers" "share/wallpapers"))
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

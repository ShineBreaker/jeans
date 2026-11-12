;;; SPDX-FileCopyrightText: 2026 Raven Hallsby <raven@hallsby.com>
;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Terminal emulators and the helper packages they need, ported from GNU Guix
;;; PR 4087 <https://codeberg.org/guix/guix/pulls/4087>.
;;;
;;; ghostty needs inputs that are neither packages nor Zig modules (upstream
;;; tarballs of freetype/harfbuzz/zlib, font directories, theme directories).
;;; Those are passed through the channel's zig-build-system via
;;; `#:zig-extra-inputs', which is why the packages that exist only to feed that
;;; list (imgui bindings, a fontconfig snapshot, the nerd font, libxml2 2.11,
;;; iTerm2 color schemes, pixels) live here next to ghostty itself.
;;;
;;; Deliberate deltas from the PR, all noted inline:
;;; - fontconfig-for-ghostty referred to a bare `arguments' variable.
;;; - font-nerd-font-symbols-only had an empty description and a truncated
;;;   synopsis, which this channel's conventions do not allow.
;;; - zig-build-system comes from (jeans build-system zig), not Guix proper.

(define-module (jeans packages terminals)
  #:use-module (guix build-system copy)
  #:use-module (guix build-system font)
  #:use-module (guix build-system trivial)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix packages)
  #:use-module (guix platform)
  #:use-module (guix utils)
  #:use-module (jeans build-system binary)
  #:use-module (jeans build-system zig)
  #:use-module (jeans packages wuffs)
  #:use-module (jeans packages zig)
  #:use-module (gnu packages)                  ; search-patches
  #:use-module (gnu packages backup)           ; libarchive (bsdtar)
  #:use-module (gnu packages compression)      ; bzip2, zlib
  #:use-module (gnu packages cpp)              ; google-highway
  #:use-module (gnu packages fonts)            ; font-jetbrains-mono
  #:use-module (gnu packages fontutils)        ; fontconfig, freetype
  #:use-module (gnu packages freedesktop)      ; wayland, wayland-protocols
  #:use-module (gnu packages gettext)          ; gettext-minimal
  #:use-module (gnu packages glib)             ; glib, gobject-introspection
  #:use-module (gnu packages gnome)            ; blueprint-compiler, gtk
  #:use-module (gnu packages gtk)              ; gdk-pixbuf, gtk4-layer-shell, harfbuzz
  #:use-module ((gnu packages image)
                #:select (libpng))          ; upstream also has a `wuffs'
  #:use-module (gnu packages kde-frameworks)   ; plasma-wayland-protocols
  #:use-module (gnu packages ncurses)          ; ncurses
  #:use-module (gnu packages pkg-config)       ; pkg-config
  #:use-module (gnu packages python)           ; python
  #:use-module (gnu packages python-xyz)       ; python-ply
  #:use-module (gnu packages regex)            ; oniguruma
  #:use-module (gnu packages toolkits)         ; imgui
  #:use-module (gnu packages vulkan)           ; glslang, spirv-cross
  #:use-module (gnu packages xorg)             ; libx11
  #:use-module ((gnu packages xml)
                #:select (libxml2) #:hide (libxml2-2.11))
  #:use-module ((gnu packages zig) #:select (zig-0.16))
  #:use-module ((gnu packages zig-xyz) #:select (zig-wayland))
  #:use-module ((guix licenses) #:prefix license:))

(define-public iterm2-color-schemes
  (package
    (name "iterm2-color-schemes")
    (version "20261109-150625-5fad1bd")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
              (url "https://github.com/mbadolato/iTerm2-Color-Schemes")
              (commit (string-append "release-" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1x137f1rc871by0d8n1k3xgin046xq3iykfz69ayf6hgvf0f8dj7"))))
    (build-system copy-build-system)
    (arguments
     (list
      #:install-plan
      #~'(("." "."))))
    (home-page "https://terminalthemes.com/")
    (synopsis "Color schemes for many TUI and GUI applications")
    (description
     "A set of color schemes for iTerm (aka iTerm2).  It also includes ports to
Terminal, Konsole, PuTTY, Xresources, XRDB, Remmina, Termite, XFCE, Tilda,
FreeBSD VT, Terminator, Kitty, Ghostty, MobaXterm, LXTerminal, Microsoft's
Windows Terminal, Visual Studio, Alacritty, Vim, and more.")
    (license license:expat)))

(define pixels
  ;; No tagged releases.
  (let ((commit "d843c2714d32e15b48b8d7eeb480295af537f877")
        (revision "0"))
    (hidden-package
     (package
       (name "pixels")
       (version (git-version "0.0.1" revision commit))
       (source
        (origin
          (method git-fetch)
          (uri (git-reference
                 (url "https://github.com/make-github-pseudonymous-again/pixels")
                 (commit "d843c2714d32e15b48b8d7eeb480295af537f877")))
          (file-name (string-append name "-pixels"))
          (sha256
           (base32
            "0hb0sjkn9dfk90y14ak66x7j0wh47l749aw077rggn5798xhcxli"))))
       (build-system copy-build-system)
       (arguments
        (list
         #:install-plan
         #~'(("." "."))))
       (home-page "https://github.com/make-github-pseudonymous-again/pixels")
       (synopsis "1x1 black & white raster images")
       (description "1x1 black & white raster images")
       (license license:cc0)))))

;; TODO: This should be reworked slightly.  imgui always released its normal
;; version and a "-docking" version as well.  They are mostly the same sources,
;; so we should be able to reuse any package definition for imgui's main
;; releases.
(define-public imgui-docking
  (package
    (inherit imgui)
    (name "imgui-docking")
    (version (package-version imgui))
    (source
     (origin
       (inherit (package-source imgui))
       (uri (git-reference
              (url "https://github.com/ocornut/imgui")
              (commit (string-append "v" version "-docking"))))
       (file-name (git-file-name "imgui-docking" version))
       ;; Parent hash is for v1.92.9b, not v1.92.9b-docking.  This is the
       ;; fixed-output hash Guix recorded for that tag after the inherited
       ;; font-deletion snippet.
       (sha256
        (base32 "1wpa8r1cd1d92y9a4rizp0clncr4ivigjk919kvhwp9f2qpxcj9y"))))
    (home-page "https://github.com/ocornut/imgui/wiki/docking")
    (synopsis "Immediate-mode C++ GUI library with docking with minimal dependencies")
    (description "@code{dear imgui} (also know as ImGui) is a graphical user
interface library for C++.  It creates optimized vertex buffers that you can
render anytime in your 3D-pipeline-enabled application.  It's fast, portable,
renderer-agnostic, and self-contained, without external dependencies.  This
variant includes support for docking ImGui's windows together.

ImGui is aimed at content creation, visualization, and debugging tools as
opposed to average end-user interfaces.  Hence it favors simplicity and
productivity but lacks certain features often found in higher-level libraries.
It is particularly suited to integration in game engine tooling, real-time 3D
applications, full-screen applications, and embedded platforms without
standard operating system features.")))

(define-public imgui-docking-1.92.5
  (hidden-package
   (package
     (inherit imgui-docking)
     (name "imgui-docking")
     (version "1.92.5")
     (source (origin
               (inherit (package-source imgui))
               (method git-fetch)
               (uri (git-reference
                      (url "https://github.com/ocornut/imgui")
                      (commit (string-append "v" version "-docking"))))
               (file-name (git-file-name name version))
               (sha256
                (base32
                 "1x2wh8hzsybv4r1aqjmc31yqx10nagap9saz92gb1q1vxzpm6dgy")))))))

(define dear-bindings
  (hidden-package
   (package
     (name "dear-bindings")
     (version "0.17")
     (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/dearimgui/dear_bindings")
               (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256
         (base32
          "1qdqrv9bpwfayz21ffxbsmmfv8cprziv6ki0p4w1aw6qsyswxv17"))))
     (build-system copy-build-system)
     (arguments
      (list
       #:install-plan
       #~'(("dear_bindings.py" "share/dear-bindings/")
           ("src" "share/dear-bindings/src"))
       #:phases
       #~(modify-phases %standard-phases
           ;; Install an entry-point that Guix will understand.
           (add-after 'install 'install-entry
             (lambda* (#:key inputs #:allow-other-keys)
               (let ((share (string-append #$output "/share/dear-bindings"))
                     (bin   (string-append #$output "/bin/dear-bindings")))
                 (mkdir-p (dirname bin))
                 (call-with-output-file bin
                   (lambda (port)
                     (format port "#!~a~%exec ~a ~a/dear_bindings.py \"$@\"~%"
                             (search-input-file inputs "/bin/sh")
                             (search-input-file inputs "/bin/python3")
                             share)))
                 (chmod bin #o755)
                 ;; Make Python inputs visible.
                 (wrap-program bin
                   `("GUIX_PYTHONPATH" ":" prefix
                     (,(getenv "GUIX_PYTHONPATH"))))))))))
     (inputs (list python python-ply))
     (home-page "https://github.com/dearimgui/dear_bindings")
     (synopsis "Pretty C header generator for Dear ImGui")
     (description
      "Dear Bindings is tool to generate a nice looking C API for Dear ImGui, and
metadata so other languages can easily generate their own bindings on top.  The
intention with Dear Bindings is to try and @b{produce a C header file which is
as close as reasonably possible to what a human would generate}, and thus
special attention has been given to @b{preserving formatting, comments and the
like} such that (maybe!) a user won't even necessarily realise that they are
working with a wrapper.")
     (license license:expat))))

;; FIXME: dear-bindings is a package.  There should also be a function that
;; takes a dear-bindings version and an imgui version and produces the
;; bindings.  The builder below already does that from imgui.h.
(define (dear-bindings-imgui dear-bindings imgui hash)
  "Create a dear-bindings-imgui <package>.

DEAR-BINDINGS is the dear_bindings <package> to use.  IMGUI is the imgui
<package> whose headers are parsed.  HASH is unused and kept so existing
call sites stay valid."
  (let ((dear-bindings-version (package-version dear-bindings)))
    ;; Keep HASH reachable so a stale call site is still a real argument.
    hash
  (package
    ;; dear-bindings-imgui or dear-bindings-imgui-docking
    ;; FIXME: dear-bindings-imgui package-name will conflict after multiple
    ;; calls!
    (name (string-append (package-name dear-bindings)
                         "-"
                         (package-name imgui)))
    ;; The version of the dear-bindings output is typically determined by
    ;; combining the dear-bindings version and the imgui version.  But we have
    ;; no good way of expressing that, so we will use the dear-bindings version
    ;; instead.
    (version dear-bindings-version)
    ;; The builder generates headers from the imgui input.  The release zip
    ;; named by HASH is not unpacked; fetching it only fails the build when
    ;; that unused archive changes.  HASH stays in the signature so callers
    ;; do not have to change.
    (source #f)
    (build-system trivial-build-system)
    (arguments
     (list
      #:modules '((guix build utils))
      ;; The builder is a Guix-ified version of BuildAllBindings.sh
      #:builder
      #~(begin
          (use-modules (guix build utils))

          (define (run-cmd . cmd-args)
            (format #t "running ~s~%" cmd-args)
            (apply invoke cmd-args))

          (let* ((inputs %build-inputs)
                 (imgui.h (search-input-file inputs "include/imgui/imgui.h"))
                 (out %output))
            (mkdir-p out)
            ;; The main header
            (run-cmd (search-input-file inputs "bin/dear-bindings")
                     "-o" (string-append out "/dcimgui")
                     imgui.h)
            (run-cmd (search-input-file inputs "bin/dear-bindings")
                     "-o" (string-append out "/dcimgui_internal")
                     "--include" imgui.h
                     (search-input-file inputs "include/imgui/imgui_internal.h"))))))
    ;; NOTE: The dear-bindings and imgui here should be the packages provided as
    ;; inputs to this function, NOT the globally-defined packages.
    (native-inputs (list dear-bindings imgui))
    (home-page "https://github.com/dearimgui/dear_bindings")
    (synopsis "Pretty C header generator for Dear ImGui")
    (description
     "Dear Bindings is tool to generate a nice looking C API for Dear ImGui, and
metadata so other languages can easily generate their own bindings on top.  The
intention with Dear Bindings is to try and @b{produce a C header file which is
as close as reasonably possible to what a human would generate}, and thus
special attention has been given to @b{preserving formatting, comments and the
like} such that (maybe!) a user won't even necessarily realise that they are
working with a wrapper.")
    (license license:expat))))

(define-public dear-bindings-imgui-docking
  (dear-bindings-imgui dear-bindings imgui-docking-1.92.5
                       "1gjm6kn16m9443hk63ci6ls6zvx4yicgcrmqnip9i78fhqphzf8i"))

(define-public fontconfig-for-ghostty
  (hidden-package
   (package
     (inherit fontconfig)
     (name "fontconfig-for-ghostty")
     (version "2.18.3")
     (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://gitlab.freedesktop.org/fontconfig/fontconfig")
               (commit version)))
        (file-name (git-file-name name version))
        (sha256
         (base32 "12vpmhznknf6d467c4h16ljggfqi07gfl1riq1y84416a224d83b"))
        (patches (search-patches
                  "jeans/patches/fontconfig-2.18.3-cache-ignore-mtime.patch"))))
     (arguments
      ;; The PR writes a bare `arguments' here, which is unbound in a
      ;; (package (inherit ...)) body; refer to the inherited field instead.
      (substitute-keyword-arguments (package-arguments fontconfig)
        ((#:phases phases)
         #~(modify-phases #$phases
             (delete 'skip-problematic-tests)
             (add-after 'unpack 'skip-network-tests
               (lambda _
                 (substitute* "test/Makefile.am"
                   ;; The crbug1004254 test attempts to fetch fonts from the
                   ;; network.
                   (("check_PROGRAMS += test-crbug1004254") ""))))
             (add-before 'check 'fix-epoch-for-tests
               (lambda _
                 ;; SOURCE_DATE_EPOCH doesn't make sense when ignoring mtime
                 (unsetenv "SOURCE_DATE_EPOCH"))))))))))

(define-public font-nerd-font-symbols-only
  (package
    (name "font-nerd-font-symbols-only")
    (version "3.5.1")
    (source
     (origin
       ;; Use url-fetch instead of git-fetch since Git repo is enormous
       (method url-fetch)
       (uri (string-append "https://github.com/ryanoasis/nerd-fonts/releases/download/v"
                           version "/NerdFontsSymbolsOnly.zip"))
       (sha256
        (base32 "1g3k4hzfjih96cjq0z6aisdpvxncc81mnd5jrkhnavsgaf13djpx"))))
    (build-system font-build-system)
    (home-page "https://www.nerdfonts.com")
    (synopsis "Nerd Fonts symbols-only icon font")
    (description
     "This font provides only the Nerd Fonts glyph set: a large collection of
icons and symbols (Powerline, Font Awesome, Material Design Icons, Octicons and
others) packaged as a single font for terminal and editor use.")
    (license
     (list license:expat
           license:silofl1.1
           license:cc-by4.0
           license:cc-by-sa4.0
           license:asl2.0
           (license:non-copyleft "https://github.com/ryanoasis/nerd-fonts/blob/master/license-audit.md")))))


(define-public libxml2-2.11
  (hidden-package
   (package
     (inherit libxml2)
     (version "2.11.9")
     (source
      (origin
        (inherit (package-source libxml2))
        (uri (string-append "mirror://gnome/sources/libxml2/"
                            (version-major+minor version)"/libxml2-"
                            version ".tar.xz"))
        (sha256
         (base32
          "17w0a622466k2hi5nln276la6rzfr9xaip3lqj71hmyvxyhmf0bq"))
        ;; The following files have the same inode (are hard links) in the
        ;; tarball.
        ;; 1. test/relaxng/ambig_name-class.xml
        ;; 1. test/relaxng/ambig_name-class2.rng
        ;; 2. test/relaxng/ambig_name-class.rng
        ;; 2. test/relaxng/tutorA.rng
        ;;
        ;; Remove them, so consumers of the tarball do not need to worry about
        ;; hard links.  This has been fixed since 2.13.0.
        (snippet
         '(begin
            (use-modules (guix build utils))
            (for-each (lambda (f) (delete-file f))
                      '("test/relaxng/ambig_name-class.xml"
                        "test/relaxng/ambig_name-class2.rng"
                        "test/relaxng/ambig_name-class.rng"
                        "test/relaxng/tutorA.rng"))
            #t)))))))

(define-public ghostty
  ;; Newer commit to get Ghostty's minimum_zig_version up to Zig 0.16
  (let* ((commit "75166e9eb0f6812b492b875bda0b49000843fe9f")
         (revision "0")
         (version (git-version "1.3.1" revision commit))
         ;; These are shared between build & test invocations to zig to tests
         ;; run on the same ghostty program the user selected and reuse the
         ;; build cache inside the environment.
         (zig-flags #~(list ;; "-Drelease=fast"
                       ;; Also set optimize flag in addition to the --release
                       ;; flag, as recommended by Ghostty.
                       "-Doptimize=ReleaseFast"
                     #$(string-append "-Dversion-string=" version)
                     #$(string-append "-Dlib-version-string=" version)
                     "-Dcpu=baseline" ; What Nixpkgs does too.
                     "-Dsimd=true" ; Allow Ghostty to use SIMD insn.
                     "-Di18n=true" ; Enabled by default on Unix & glibc
                     ;; Make ghostty PIE.  Manually enabled because we do not
                     ;; use Zig's --system flag.
                     "-Dpie=true"
                     ;; We do not need .html & .md versions of the docs, man
                     ;; versions are already generated & installed to share/man.
                     "-Demit-docs=false"
                     ;; "-Demit-lib-vt=true" ;; For libghostty-vt-only builds.
                     ;; "-Dvt-features=+all"
                     "-Demit-terminfo=true"
                     "-Demit-termcap=true"
                     ;; "-Demit-themes=false" ;; Provided by iterm2-color-schemes
                     ;; "-Dapp-runtime=none/gtk"
                     ;; "-Dgtk-wayland=true"
                     ;; "-Dgtk-x11=true" ;; Will require libx11
                     ;; "-Dfont-backend=freetype/fontconfig_freetype"
                     ;; "-Dgtk-adwaita="
                     ;; "-Drenderer=opengl"
                     ;; "-Dtest-filter='(\"\")" ;; If we need to skip tests
                     ;; TODO: Do these apply to tests too?
                     ;; "-Ddynamic-linker=\"target-system-linker\"" ;;
                     ;; "-Dpatch-interp=\"target-system-linker\"" ;; Used on Nix. Needed for Guix?
                     ;; "-Dpatch-rpath=\"target-system-linker\"" ;; Used on Nix. Needed for Guix?
                     )))
  (package
    (name "ghostty")
    (version version)
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
              (url "https://github.com/ghostty-org/ghostty")
              (commit commit)))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "1x783iipai1w34ig4009ds8vwhpqii5sdkpxzhdbd0w3qilmhq4c"))
       ;; (modules '((guix build utils)))
       ;; (snippet
       ;;  '(begin
       ;;     (use-modules (guix build utils))
       ;;     ;; Remove vendored fonts
       ;;     (delete-file-recursively "vendor/nerd-fonts")))
       (patches
        (search-patches
         "jeans/patches/ghostty-fix-tests-from-tmp.patch"))))
    (build-system zig-build-system)
    (arguments
     (list
      #:modules '((guix build zig-utils) ; for zig-target
                  (guix build utils)
                  (jeans build zig-build-system))
      #:zig zig-0.16
      ;; "fast" instead of "safe" because running ghostty compiled "safe" mode
      ;; is "too slow"
      ;; <https://github.com/ghostty-org/ghostty/blob/main/PACKAGING.md#build-options>
      #:zig-release-type "fast"
      #:install-source? #f
      #:zig-build-flags zig-flags
      #:zig-test-flags
      #~(append
         (list
          (string-append "-Dtarget="
                         (zig-target #$(platform-target
                                        (lookup-platform-by-target-or-system
                                         (or (%current-target-system)
                                             (%current-system)))))))
         #$zig-flags)
      #:zig-extra-inputs
      #~(list ;; FIXME: These should refer to the inputs of the package, and NOT
              ;; use bare gexps.  If we do it this way, we have 2 possible sources of
              ;; packages, this gexp and the inputs lists.
              `("dear-bindings-imgui-docking" . ,#$dear-bindings-imgui-docking)
              `("font-nerd-font-symbols-only" . ,(string-append
                                                  #$font-nerd-font-symbols-only
                                                  "/share/fonts/truetype"))
              `("fontconfig" . ,#$(package-source fontconfig-for-ghostty))
              `("freetype" . ,#$(package-source freetype))
              `("glslang" . ,#$(package-source glslang))
              `("harfbuzz" . ,#$(package-source harfbuzz))
              `("highway" . ,#$(package-source google-highway))
              `("imgui" . ,#$(package-source imgui-docking-1.92.5))
              `("iterm2-color-schemes" . ,(string-append
                                           #$iterm2-color-schemes "/ghostty"))
              `("jetbrains_mono". ,#$font-jetbrains-mono)
              `("libpng" . ,#$(package-source libpng))
              `("libxml2" . ,#$(package-source libxml2-2.11))
              `("oniguruma" . ,#$(package-source (@ (gnu packages regex) oniguruma)))
              `("pixels" . ,#$pixels)
              `("plasma_wayland_protocols" . ,#$(package-source plasma-wayland-protocols))
              `("spirv_cross" . ,#$(package-source spirv-cross))
              `("wayland" . ,#$(package-source wayland))
              `("wayland_protocols" . ,#$(package-source wayland-protocols))
              `("wuffs" . ,#$wuffs)
              `("zlib" . ,#$(package-source zlib))
              )
      #:phases
      #~(modify-phases %standard-phases
          ;; Delete the example/ subdirectory.  They have examples of using
          ;; libghostty for terminal projects.  The examples are not needed to
          ;; build ghostty and slows down Guix's build.zig.zon rewrites.
          (add-after 'unpack 'remove-example
            (lambda _
              (delete-file-recursively "example")))
          ;; Zig's translate-c C->Zig translator requires a way to resolve
          ;; #include <...> correctly, so it must learn about -I flags somehow.
          ;; By default, this is done with pkg-config.  Because pkg-config is
          ;; particular about capitalization, we need to fix this for libx11.
          (add-after 'unpack 'fix-x11-pkg-config-name
            (lambda _
              (substitute* "src/build/SharedDeps.zig"
                (("\\.link_system_libs = &\\.\\{\"X11\"\\}")
                 ".link_system_libs = &.{\"x11\"}"))))
          ;; Because of the way Guix passes package names directly to Zig during
          ;; the unpack-dependencies phase, we must correct the build.zig.zon's
          ;; to use the name Guix provides the package as, then revert the
          ;; chnage in a later phase.  For example, the uucode library's package
          ;; is named zig-uucode in Guix, which propagates everywhere.
          (add-before 'unpack-dependencies 'prepare-build.zig.zon
            (lambda _
              (substitute* "build.zig.zon"
                (("\\.gobject") ".@\"zig-gobject-ghostty\"")
                (("\\.iterm2_themes") ".@\"iterm2-color-schemes\"")
                (("\\.nerd_fonts_symbols_only") ".@\"font-nerd-font-symbols-only\"")
                (("\\.libxev") ".@\"zig-libxev\"")
                (("\\.uucode") ".@\"zig-uucode\"")
                (("\\.vaxis") ".@\"zig-libvaxis\"")
                (("\\.zig_wayland") ".@\"zig-wayland\"")
                (("\\.zf") ".@\"zig-zf\"")
                (("\\.z2d") ".@\"zig-z2d\"")
                )
              (substitute* "pkg/dcimgui/build.zig.zon"
                (("\\.bindings") ".@\"dear-bindings-imgui-docking\""))
              (substitute* "pkg/gtk4-layer-shell/build.zig.zon"
                (("\\.gtk4_layer_shell ") ".@\"gtk4-layer-shell\" "))
              (substitute* "pkg/translate-c/build.zig.zon"
                (("\\.translate_c ") ".@\"zig-translate-c\" "))
              ;; Guix does not put wuffs's C-facing library in $out/release/c,
              ;; so teach Zig where we put the C code.
              (substitute* "pkg/wuffs/build.zig"
                (("release/c(/)?") "include/"))
              ))
          (add-after 'unpack-dependencies 'revert-build.zig.zon
            (lambda _
              (substitute* "build.zig.zon"
                (("\\.@\"zig-gobject-ghostty\"") ".gobject")
                (("\\.@\"iterm2-color-schemes\"") ".iterm2_themes")
                (("\\.@\"font-nerd-font-symbols-only\"") ".nerd_fonts_symbols_only")
                (("\\.@\"zig-libxev\"") ".libxev")
                (("\\.@\"zig-uucode\"") ".uucode")
                (("\\.@\"zig-libvaxis\"") ".vaxis")
                (("\\.@\"zig-wayland\"") ".zig_wayland")
                (("\\.@\"zig-zf\"") ".zf")
                (("\\.@\"zig-z2d\"") ".z2d")
                )
              (substitute* "pkg/dcimgui/build.zig.zon"
                (("\\.@\"dear-bindings-imgui-docking\"") ".bindings"))
              (substitute* "pkg/gtk4-layer-shell/build.zig.zon"
                (("\\.@\"gtk4-layer-shell\" ") ".gtk4_layer_shell "))
              (substitute* "pkg/translate-c/build.zig.zon"
                (("\\.@\"zig-translate-c\" ") ".translate_c "))
              ))
          ;; arocc (and therefore Zig's translate-c) do NOT use the
          ;; *C*_INCLUDE_PATH environment variables.  Any inputs must be
          ;; completely and explicitly specified.  pkg-config will only look
          ;; for packages that are NOT in the C_INCLUDE_PATH and ARE in
          ;; PKG_CONFIG_PATH. Since x11 shows up in both, pkg-config defers to
          ;; C_INCLUDE_PATH and does not produce any output for some reason.
          (add-before 'build+install 'pkg-config-allow-system-cflags
            (lambda _
              (setenv "PKG_CONFIG_ALLOW_SYSTEM_CFLAGS" "1")))
          (add-before 'build+install 'fix-gtk-blueprint
            (lambda _
              ;; GTK 4 & Adwaita provide a different symbol to provide a
              ;; shortcut label. This file already imports the Adw namespace,
              ;; so there is nothing special we need to do.
              ;;
              ;; The "error" we get:
              ;; hint: This widget will be removed in GTK 5
              (substitute* "src/apprt/gtk/ui/1.5/command-palette.blp"
                (("Gtk\\.ShortcutLabel") "Adw.ShortcutLabel"))))
          ;; Teach Zig about where Guix places fonts.
          (add-before 'build+install 'fix-font-paths
            (lambda _
              (substitute* "src/build/SharedDeps.zig"
                (("fonts/ttf") "share/fonts/truetype")
                (("fonts/variable") "share/fonts/truetype"))))
          ;; Tests use fontconfig, which looks for a writable cache directory
          ;; in $XDG_CACHE_HOME/fontconfig.
          (add-before 'check 'set-cache-paths
            (lambda _
              (setenv "XDG_CACHE_HOME" "/tmp/.cache")))
          ;; Many tests have hard-coded paths in them.  Guix does not
          ;; install the source of ghostty into the outputs, so we can safely
          ;; patch out all instances of /bin/sh, /bin/bash, /bin/cp, etc. with
          ;; paths into the store.
          (add-before 'check 'fix-test-bins-paths
            (lambda* (#:key inputs #:allow-other-keys)
              (substitute* (list "src/Command.zig")
                (("/bin/sh") (search-input-file inputs "bin/sh"))
                (("/bin/bash") (search-input-file inputs "bin/bash")))))
          )
      ))
    (native-inputs
     (list blueprint-compiler
           dear-bindings-imgui-docking
           ;; Generate locale information
           gettext-minimal
           (package-source google-highway)
           (package-source imgui-docking-1.92.5)
           (package-source libpng)
           ;; Ghostty wants libxml 2.11.5 while commit
           ;; cdc5cfed0b16ef4e0d75f08aead39870e553b47e in libxml2 removed the
           ;; legacy symbols ghostty depends on.
           (package-source libxml2-2.11)
           libx11
           ncurses
           ;; (gnu packages terminals) imports the textutils module, which leads
           ;; to Guile attempting to use oniguruma from textutils instead of
           ;; regex.
           (package-source (@ (gnu packages regex) oniguruma))
           pixels
           pkg-config
           (package-source spirv-cross)
           ;; Right now, wuffs is weird because the wuffs package ONLY installs
           ;; wuffs-v0.x.c to its #$out.
           wuffs
           ;; Aro is used by zig-translate-c.  We must also specify aro as an
           ;; input here too so that build.zig.zon rewrites kick in.
           zig-aro
           zig-gobject-ghostty
           zig-libxev
           zig-libvaxis
           zig-translate-c
           zig-uucode
           zig-wayland
           zig-zf
           zig-zigimg
           zig-z2d
           (package-source zlib)))
    (inputs
     (list bzip2
           (package-source fontconfig-for-ghostty)
           font-jetbrains-mono
           font-nerd-font-symbols-only
           (package-source freetype)
           glib ;; Can be native-input?
           `(,glib "bin")               ;for glib-compile-resources
           gobject-introspection
           (package-source glslang)
           gtk
           (package-source harfbuzz)
           iterm2-color-schemes
           gtk4-layer-shell
           libadwaita
           libx11
           (package-source plasma-wayland-protocols)
           (package-source wayland)
           (package-source wayland-protocols)))
    (home-page "https://ghostty.org/")
    (synopsis "Fast, native, feature-rich terminal emulator pushing modern features")
    (description
     "Ghostty is a terminal emulator that differentiates itself by being fast,
feature-rich, and native.  While there are many excellent terminal emulators
available, they all force you to choose between speed, features, or native UIs.
Ghostty provides all three.")
    (license license:expat))))

;;; ghostty-bin
;;;
;;; Ghostty publishes no Linux binaries (its releases only carry macOS and wasm
;;; assets), so the reference build has to come from one of the distributions
;;; the upstream documentation points at.  conda-forge is the one that works
;;; here: Arch's build needs GLIBC_2.43 while Guix ships 2.41, whereas the
;;; conda-forge build only needs GLIBC_2.34.  It is also self-contained —
;;; terminfo, shell-integration and themes all live in the same package — and
;;; its RPATH is the relative $ORIGIN/../lib, which patchelf can replace
;;; wholesale with store paths.
;;;
;;; The 1.3.1 build is used so this can be compared against the source package
;;; above at the same version; its --version string is "1.3.1-conda".

(define-public ghostty-bin
  (package
    (name "ghostty-bin")
    (version "1.3.1")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://conda.anaconda.org/conda-forge/linux-64/"
             "ghostty-1.3.1-h41fa4c7_4.conda"))
       (sha256
        (base32 "1gsvqzp969r10sp3429d3q2axwyvr69fr3dlhv1pyfhy1kmls8x6"))))
    (build-system binary-build-system)
    (arguments
     (list
      ;; .conda 是 zip，内含 pkg-*.tar.zst，基座没有对应 unpack-method。
      #:unpack-method 'none
      #:install-plan
      #~'(("bin/ghostty" "bin/ghostty")
          ("lib" "lib")
          ("share" "share")
          ("include" "include"))
      #:patchelf-plan
      #~'("bin/ghostty" "lib")
      #:wrap-plan
      ;; 用 (list ...) 构造而不是 #~'(...)：quote 里的 #$ 不会被 gexp 展开。
      #~(list
         (list "bin/ghostty"
               (list "GHOSTTY_RESOURCES_DIR" "=" '=
                     (list (string-append #$output "/share/ghostty")))
               (list "TERMINFO_DIRS" ":" 'prefix
                     (list (string-append #$output "/share/terminfo")))
               ;; Do not set GDK_PIXBUF_MODULE_FILE.  It replaces Guix's
               ;; aggregated loader cache, so loaders outside gdk-pixbuf's
               ;; own cache (for example SVG) disappear.
               (list "GIO_EXTRA_MODULES" ":" 'prefix
                     (list #$(file-append glib "/lib/gio/modules")))
               (list "GSETTINGS_SCHEMA_DIR" ":" 'prefix
                     (list #$(file-append gtk "/share/glib-2.0/schemas")
                           #$(file-append libadwaita "/share/glib-2.0/schemas")))
               ;; GDK/GTK 的主题与图标；XDG_DATA_DIRS 必须保留原值（prefix 语义）。
               (list "XDG_DATA_DIRS" ":" 'prefix
                     (list #$(file-append gtk "/share")
                           #$(file-append libadwaita "/share")
                           #$(file-append adwaita-icon-theme "/share")))))
      #:phases
      #~(modify-phases %standard-phases
          (replace 'unpack
            (lambda* (#:key source #:allow-other-keys)
              (invoke "bsdtar" "-xf" source)
              (let ((pkg (car (find-files "." "^pkg-.*\\.tar\\.zst$"))))
                (invoke "bsdtar" "-xf" pkg)))))))
    (native-inputs (list libarchive))
    (inputs
     (list fontconfig
           freetype
           glib
           gtk
           gtk4-layer-shell
           harfbuzz
           libadwaita
           libx11
           oniguruma
           wayland
           zlib))
    (home-page "https://ghostty.org/")
    (synopsis "Fast, native, feature-rich terminal emulator")
    (description
     "Ghostty is a terminal emulator that differentiates itself by being fast,
feature-rich, and native.  This package is a prebuilt binary taken from
conda-forge, one of the distribution channels the Ghostty project points at
for Linux; upstream itself publishes no Linux binaries.")
    (license license:expat)))

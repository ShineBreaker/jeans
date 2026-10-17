;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-only

(define-module (jeans packages games)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module ((nonguix licenses) #:prefix license:)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages bootstrap)
  #:use-module (gnu packages commencement)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages elf)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages gl)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages java)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages gnuzilla)
  #:use-module (gnu packages gstreamer)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages icu4c)
  #:use-module (gnu packages image)
  #:use-module (gnu packages imagemagick)
  #:use-module (gnu packages instrumentation)
  #:use-module (gnu packages libevent)
  #:use-module (gnu packages libffi)
  #:use-module (gnu packages linphone)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages nss)
  #:use-module (gnu packages pciutils)
  #:use-module (gnu packages pulseaudio)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages video)
  #:use-module (gnu packages vulkan)
  #:use-module (gnu packages web)
  #:use-module (gnu packages webkit)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages xorg)
  #:use-module (guix build utils)
  #:use-module (guix build-system cargo)
  #:use-module (guix build-system copy)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system trivial)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (jeans build-system binary)
  #:use-module (jeans packages hardware))



;; OpenJFX 17 SDK (binary) — required by beatoraja for the JavaFX launcher.
;; JavaFX was removed from the JDK as of Java 11,
;; so it must be provided separately.
;; The pre-built native libraries (.so) depend on GTK3, GL, X11, etc.
;; We skip validate-runpath because patchelf-ing every JavaFX .so is impractical
;; and the library resolution happens at JVM level via --module-path.
(define openjfx17-sdk
  (package
    (name "openjfx17-sdk")
    (version "17.0.13")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://download2.gluonhq.com/openjfx/" version
             "/openjfx-" version "_linux-x64_bin-sdk.zip"))
       (sha256
        (base32 "16d1w8haw5mimrji7vpqg50g9hdn721jg68y10kil7c36ckyyc6h"))))
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
              (invoke "unzip" #$source)))
          (replace 'install
            (lambda _
              (let ((out #$output)
                    (sdk-dir (string-append "javafx-sdk-" #$version)))
                (copy-recursively (string-append sdk-dir "/lib")
                                  (string-append out "/lib"))))))))
    (native-inputs (list unzip))
    (inputs `(("gtk+" ,gtk+)
              ("gdk-pixbuf" ,gdk-pixbuf)
              ("glib" ,glib)
              ("pango" ,pango)
              ("cairo" ,cairo)
              ("freetype" ,freetype)
              ("fontconfig-minimal" ,fontconfig)
              ("libx11" ,libx11)
              ("libxrandr" ,libxrandr)
              ("libxrender" ,libxrender)
              ("libxtst" ,libxtst)
              ("libxxf86vm" ,libxxf86vm)
              ("mesa" ,mesa)
              ("libffi" ,libffi)
              ("alsa-lib" ,alsa-lib)
              ("gcc:lib" ,gcc "lib")))
    (home-page "https://openjfx.io/")
    (synopsis "OpenJFX 17 SDK (binary, Linux x86_64)")
    (description "This package provides the Gluon OpenJFX 17 SDK
for Linux x86_64, containing the JavaFX runtime libraries
(JARs and native .so files).")
    (license (license:non-copyleft "file://legal/javafx.base/LICENSE"))))

(define-public lr2oraja-endlessdream-bin
  (package
    (name "lr2oraja-endlessdream-bin")
    (version "0.4.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/seraxis/lr2oraja-endlessdream/"
             "releases/download/v" version
             "/lr2oraja-0.8.8-endlessdream-linux-" version ".jar"))
       (sha256
        (base32 "13njyxgav869i4i0xrkk1iqgplvmp09dbx5ywz2m1hz1aniwq8sn"))))
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
          (delete 'unpack)
          (replace 'install
            (lambda _
              (let* ((out #$output)
                     (share (string-append out "/share/lr2oraja-endlessdream"))
                     (bin (string-append out "/bin"))
                     (jfx-lib (string-append #$openjfx17-sdk "/lib")))
                ;; Install only the fork JAR.
                (mkdir-p share)
                (copy-file #$source (string-append share "/beatoraja.jar"))
                (mkdir-p bin)
                (let ((wrapper (string-append bin "/lr2oraja-endlessdream")))
                  (call-with-output-file wrapper
                    (lambda (port)
                      (format port "#!~a/bin/bash~%" #$bash-minimal)
                      (format port
                              (string-append
                               "DATA_DIR=\"${XDG_DATA_HOME:-$HOME/.local/"
                               "share}/lr2oraja-endlessdream\"~%"))
                      ;; Ensure essential writable directories exist.
                      (format port
                              (string-append
                               "mkdir -p \"$DATA_DIR/table\" "
                               "\"$DATA_DIR/skin/default\" || exit 1~%"))
                      ;; The ImGui mod menu loads VL-Gothic-Regular.ttf from
                      ;; skin/default/.  Symlink it from font/ when the user
                      ;; has extracted the base distribution but hasn't placed
                      ;; the font manually.
                      (format port
                              (string-append
                               "if [ -f \"$DATA_DIR/font/"
                               "VL-Gothic-Regular.ttf\" ] && "
                               "[ ! -e \"$DATA_DIR/skin/default/"
                               "VL-Gothic-Regular.ttf\" ]; then~%"))
                      (format port
                              (string-append
                               "  ln -sf \"$DATA_DIR/font/"
                               "VL-Gothic-Regular.ttf\" "
                               "\"$DATA_DIR/skin/default/"
                               "VL-Gothic-Regular.ttf\"~%"))
                      (format port "fi~%")
                      (format port "cd \"$DATA_DIR\" || exit 1~%")
                      (format port "exec ~a/bin/java \
-Xms1g -Xmx4g \
-Dsun.java2d.opengl=true \
-Dawt.useSystemAAFontSettings=on \
-Dswing.aatext=true \
--module-path ~a \
--add-modules javafx.controls,javafx.fxml,javafx.web \
-jar ~a/share/lr2oraja-endlessdream/beatoraja.jar \"$@\"~%"
                              #$openjdk17 jfx-lib out)))
                  (chmod wrapper #o755))
                ;; Desktop entry for application menu.
                (let ((apps (string-append out "/share/applications")))
                  (mkdir-p apps)
                  (call-with-output-file
                      (string-append apps "/lr2oraja-endlessdream.desktop")
                    (lambda (port)
                       (format port
                        "[Desktop Entry]~@
                         Name=LR2oraja Endless Dream~@
                         Comment=Community fork of beatoraja with QoL patches~@
                         Exec=~a/bin/lr2oraja-endlessdream~@
                         Terminal=false~@
                         Type=Application~@
                         Categories=Game;ArcadeGame;~%"
                        out)))))))
          (add-after 'install 'wrap-beatoraja
            (lambda _
              (let ((wrapper
                      (string-append #$output "/bin/lr2oraja-endlessdream"))
                    (jfx-lib
                      (string-append #$openjfx17-sdk "/lib"))
                    (lib-dirs
                      (list (string-append #$gtk+ "/lib")
                            (string-append #$gdk-pixbuf "/lib")
                            (string-append #$glib "/lib")
                            (string-append #$pango "/lib")
                            (string-append #$cairo "/lib")
                            (string-append #$freetype "/lib")
                            (string-append #$fontconfig "/lib")
                            (string-append #$libx11 "/lib")
                            (string-append #$libxrandr "/lib")
                            (string-append #$libxrender "/lib")
                            (string-append #$libxtst "/lib")
                            (string-append #$libxxf86vm "/lib")
                            (string-append #$mesa "/lib")
                            (string-append #$libffi "/lib")
                            (string-append #$alsa-lib "/lib")
                            (string-append #$(this-package-input "gcc:lib") "/lib"))))
                (wrap-program wrapper
                  `("LD_LIBRARY_PATH" ":" prefix
                    ,(cons jfx-lib lib-dirs))
                  `("XDG_DATA_DIRS" ":" prefix
                    (,(string-append #$output "/share")
                     ,(string-append #$gdk-pixbuf "/share")
                     ,(string-append #$gtk+ "/share"))))))))))
    (inputs `(("openjdk" ,openjdk17)
              ("openjfx17-sdk" ,openjfx17-sdk)
              ("bash-minimal" ,bash-minimal)
              ("gtk+" ,gtk+)
              ("gdk-pixbuf" ,gdk-pixbuf)
              ("glib" ,glib)
              ("pango" ,pango)
              ("cairo" ,cairo)
              ("freetype" ,freetype)
              ("fontconfig-minimal" ,fontconfig)
              ("libx11" ,libx11)
              ("libxrandr" ,libxrandr)
              ("libxrender" ,libxrender)
              ("libxtst" ,libxtst)
              ("libxxf86vm" ,libxxf86vm)
              ("mesa" ,mesa)
              ("libffi" ,libffi)
              ("alsa-lib" ,alsa-lib)
              ("gcc:lib" ,gcc "lib")))
    (properties `((upstream-name . "lr2oraja")))
    (home-page "https://github.com/seraxis/lr2oraja-endlessdream")
    (synopsis "Community fork of beatoraja BMS rhythm game with QoL improvements")
    (description "LR2oraja Endless Dream is a community fork and drop-in
replacement for beatoraja, a cross-platform BMS rhythm game based on
Java and libGDX.  It integrates quality of life patches including an
in-game song downloader, osu file support, built-in mod menu, improved
graphics backends, and faster table processing.

Users must extract the official beatoraja 0.8.8 distribution into
@file{~/.local/share/lr2oraja-endlessdream/} so that the game can find
fonts, IR jars, and other assets at runtime.  The game requires OpenGL
3.1+ and Java 17.")
    (license license:gpl3+)))

;; osu!lazer 及其 fork 的 AppImage 通用打包模板。上游布局同构：usr/bin 的
;; .NET apphost + dll + 自带 native 库（含 UpdateNix 更新器、dlopen 探测
;; Ubuntu 旧 soname 的 .NET/HidSharp），usr/share 的 hicolor 图标与根部
;; desktop。fork 之间只有仓库/资产/入口名/元数据不同，共同处理：
;; - fix-so 补 liblttng-ust.so.0 / libudev.so.0（Guix 只提供 .so.1）；
;; - wrapper 设 OSU_EXTERNAL_UPDATE_PROVIDER 禁用应用内自我更新（store
;;   只读必然失败）；
;; - 上游 hicolor 图标与 Icon= 硬编码 osu，重命名为应用名（BINARY 去掉
;;   尾部 !）：多个 lazer 系包同装一个 profile 时不再互相覆盖图标；
;;   图标为 .ico 时（g0v0）先转最大帧 png——hicolor 查找不认 .ico；
;; - 安装 opentabletdriver 的 udev 规则（数位板权限）。
;; upstream-name 取应用名，须与 release 资产文件名的版本前缀一致，否则
;; guix refresh 报 no updater。
(define* (osu-lazer-appimage-package name version hash
                                     #:key repo tag-prefix asset
                                     binary desktop
                                     home-page synopsis description
                                     (license license:expat))
  (let ((app (string-trim-right binary #\!)))
    (package
      (name name)
      (version version)
      (source
       (origin
        (method url-fetch)
        (uri (string-append repo "/releases/download/"
                            tag-prefix version "/" asset))
        (sha256 (base32 hash))))
      (build-system binary-build-system)
      (supported-systems '("x86_64-linux"))
      (arguments
       (list
        #:unpack-method 'appimage-7z
        #:install-plan
        ;; 计划值须以 #~(list ...) 在构建期求值：宿主侧裸列表经 gexp
        ;; 序列化会变成 builder 里的待求值代码（"Wrong type to apply"）。
        #~(list (list "usr/share/" "share/")
                (list "usr/bin/" #$(string-append "lib/" app "/"))
                (list #$desktop "share/applications/"))
        ;; 资源根是 lib/<app>（derivation 名去版本得 <name>，对不上），
        ;; 必须显式指定，否则 RPATH 缺第一项。
        #:app-dir app
        ;; RPATH 自动取 lib-dir + 全部 inputs 的 /lib。
        #:patchelf-plan
        #~(list #$(string-append "lib/" app))
        ;; Exec 显式指到 bin/<binary>；Icon 改写为应用名（配合重命名）。
        ;; DESKTOP 条目是输出内路径，EXEC/ICON 分别为输出内路径与图标名。
        #:desktop-files
        #~(list (list (string-append "share/applications/" #$desktop)
                      #$(string-append "bin/" binary)
                      #$app))
        #:modules '((guix build utils))
        #:phases
        #~(modify-phases %standard-phases
            ;; g0v0 类 fork 的图标是 .ico（位图混进 scalable/），hicolor
            ;; 查找只认 png/svg 后缀；取最大帧转 png（ico 帧按尺寸升序
            ;; 排列，负索引即末帧）。与 rebrand-icon 同锚 'unpack，后写
            ;; 先执行：万一哪个 fork 的 .ico 叫 osu.ico，展开出的
            ;; osu.png 仍会被 rebrand-icon 重命名为应用名。
            (add-after 'unpack 'rebrand-icon
              (lambda _
                (for-each
                 (lambda (png)
                   (rename-file png
                                (string-append (dirname png) "/"
                                               #$app ".png")))
                 (find-files "usr/share/icons" "^osu\\.png$"))))
            (add-after 'unpack 'convert-ico-icon
              (lambda _
                (for-each
                 (lambda (ico)
                   (let ((dir "usr/share/icons/hicolor/256x256/apps"))
                     (mkdir-p dir)
                     (invoke "convert"
                             (string-append ico "[-1]")
                             (string-append dir "/"
                                            (basename ico ".ico") ".png"))
                     (delete-file ico)))
                 (find-files "usr/share/icons" "\\.ico$"))))
            ;; 7z 解包由基座承担；删掉不需安装的更新器。
            (add-after 'unpack 'remove-unused-files
              (lambda _
                (when (file-exists? "usr/bin/UpdateNix")
                  (delete-file "usr/bin/UpdateNix"))))
            (add-after 'patchelf 'wrap-program
              (lambda _
                (let* ((bin (string-append #$output "/lib/" #$app "/"
                                           #$binary))
                       (wrapper (string-append #$output "/bin/" #$binary)))
                  (mkdir-p (dirname wrapper))
                  (symlink bin wrapper)
                  (wrap-program wrapper
                    `("OSU_EXTERNAL_UPDATE_PROVIDER" = ("1"))
                    `("LD_LIBRARY_PATH" prefix
                      (,(string-append #$output "/lib/" #$app)))))))
            (add-after 'wrap-program 'fix-so
              (lambda _
                (symlink #$(file-append lttng-ust
                                        "/lib/liblttng-ust.so")
                         (string-append #$output "/lib/" #$app
                                        "/liblttng-ust.so.0"))
                (symlink #$(file-append eudev "/lib/libudev.so.1")
                         (string-append #$output "/lib/" #$app
                                        "/libudev.so.0"))))
            (add-after 'wrap-program 'make-files-executable
              (lambda _
                (let ((lib-dir (string-append #$output "/lib/" #$app)))
                  (map (lambda (file) (chmod file #o555))
                       (cons* (string-append lib-dir "/" #$binary)
                              (append (find-files lib-dir ".*\\.dll")
                                      (find-files lib-dir ".*\\.so.*")))))))
            (add-after 'install 'install-udev-rules
              (lambda _
                (let* ((relative-rules.d "/lib/udev/rules.d")
                       (rules-package
                        #$(this-package-native-input
                           "opentabletdriver-udev-rules"))
                       (otd-rules (string-append rules-package
                                                 relative-rules.d
                                                 "/70-opentabletdriver.rules"))
                       (rules.d (string-append #$output relative-rules.d)))
                  (install-file otd-rules rules.d)))))))
      (native-inputs (list p7zip imagemagick opentabletdriver-udev-rules))
      (inputs
       `(("bash-minimal" ,bash-minimal)
         ("alsa-lib" ,alsa-lib)
         ("dbus" ,dbus)
         ("elfutils" ,elfutils)
         ("eudev" ,eudev)
         ("gcc:lib" ,gcc "lib")
         ("glib" ,glib)
         ("glibc" ,glibc)
         ("icu4c" ,icu4c)
         ("libdrm" ,libdrm)
         ("libxcb" ,libxcb)
         ("libxext" ,libxext)
         ("libxkbcommon" ,libxkbcommon)
         ("lttng-ust" ,lttng-ust)
         ("mesa" ,mesa)
         ("openssl" ,openssl)
         ("vulkan-loader" ,vulkan-loader)
         ("wayland" ,wayland)
         ("zlib" ,zlib)))
      (properties `((upstream-name . ,app)))
      (home-page home-page)
      (synopsis synopsis)
      (description description)
      (license license))))

;; osu!lazer 本体。release tag 无 v 前缀，资产名 osu.AppImage。
(define-public osu-lazer-bin
  (osu-lazer-appimage-package
   "osu-lazer-bin" "2026.1005.0-lazer"
   "0bns13jzhfbn80hypqbcpmvw2a0m9g0y4h6axsdk7a3kagk0hh98"
   #:repo "https://github.com/ppy/osu"
   #:tag-prefix ""
   #:asset "osu.AppImage"
   #:binary "osu!"
   #:desktop "osu!.desktop"
   #:home-page "https://osu.ppy.sh/"
   #:synopsis "rhythm is just a *click* away!"
   #:description "A free-to-win rhythm game.  This is the future and final
iteration of the osu! game client, which marks the beginning of an open era.
It is currently known by and released under the codename lazer, as in sharper
than cutting-edge."))

;; g0v0! —— osu!lazer 社区 fork（GooGuTeam）。
(define-public g0v0-bin
  (osu-lazer-appimage-package
   "g0v0-bin" "2026.1012.0-g0v0"
   "1i4c49bpyabqvfqdlg4r7aph19qxlri7i2wqfgcna79y8i777hr3"
   #:repo "https://github.com/GooGuTeam/g0v0"
   #:tag-prefix "v"
   #:asset "g0v0.AppImage"
   #:binary "g0v0!"
   #:desktop "g0v0.desktop"
   #:home-page "https://lazer.g0v0.top/"
   #:synopsis "Free and open rhythm game based on the osu!lazer codebase"
   #:description "A free and open rhythm game built as a community fork of
osu!lazer, the open-source iteration of the osu! game client.  It plays
osu! beatmaps with the lazer gameplay ruleset.

This package distributes the upstream AppImage build."))

;; inso ships no LICENSE file in its source repository, so by default
;; copyright it is nonfree.  Distributed only as a prebuilt Linux archive.
(define-public inso-bin
  (package
    (name "inso-bin")
    (version "0.3.8")
    (source
     (origin
      (method url-fetch)
      (uri (string-append
            ;; Tag prefix MUST stay lowercase "v": the github updater's URL
            ;; rewrite templates only match /(v)?<version>/ release paths,
            ;; so a capital-V tag ("V0.3.7", used once upstream in 0.3.7)
            ;; breaks guix refresh with "no updater".  0.3.8 is back to
            ;; lowercase; if upstream flips again the build gate will 404
            ;; and file an issue rather than silently stalling.
            "https://github.com/isakvik/inso/releases/download/v" version
            "/inso-" version "-linux-x64.zip"))
      (sha256
       (base32 "0111vlq268x0p6xxz3x2n387wyxbwz752fk2rh6z5kyrmai4nk8d"))))
    (build-system copy-build-system)
    (arguments
     (list
      #:tests? #f
      #:validate-runpath? #f
      #:strip-binaries? #f
      #:install-plan
      ;; Place the binary and bundled runtime libraries side-by-side under
      ;; lib/inso so the binary's $ORIGIN rpath can locate them.  Read-only
      ;; assets go under share/inso for the launch wrapper to expose.
      #~'(("inso" "lib/inso/")
          ("libbass.so" "lib/inso/")
          ("libbass_fx.so" "lib/inso/")
          ("libbassmix.so" "lib/inso/")
          ("libSDL3.so" "lib/inso/")
          ("libSDL3.so.0" "lib/inso/")
          ("data/" "share/inso/data/")
          ("shaders/" "share/inso/shaders/")
          ("skins/" "share/inso/skins/")
          ("songs/" "share/inso/songs/")
          ("docs/" "share/inso/docs/"))
      #:modules '((guix build utils)
                  (guix build copy-build-system)
                  (ice-9 format))
      #:phases
      #~(modify-phases %standard-phases
          (delete 'install-license-files)
          ;; The default unpack chdirs into a subdirectory named after one of
          ;; the archive's top-level entries; replace it so the flat tree
          ;; stays at the build root and the install-plan resolves.
          (replace 'unpack
            (lambda _
              (invoke "unzip" #$source)))
          (add-after 'install 'patch-elf
            (lambda* (#:key inputs #:allow-other-keys)
              (let* ((ld.so (string-append (assoc-ref inputs "glibc")
                                           #$(glibc-dynamic-linker)))
                     (lib-dir (string-append #$output "/lib/inso"))
                     ;; Only the directories that actually provide the
                     ;; NEEDED/dlopened libraries: bundled .so (lib-dir),
                     ;; glibc, gcc libstdc++/libgcc_s, mesa's GL/EGL, and
                     ;; alsa-lib — libbass.so dlopen()s libasound.so.2
                     ;; (not a NEEDED entry) and BASS_Init fails with
                     ;; BASS_ERROR_UNKNOWN (23) when it can't be found.
                     ;; Build-side `inputs' preserves the sub-output path
                     ;; for "gcc:lib", unlike the host-side gexp which
                     ;; would resolve to gcc's default output.
                     (rpath
                      (string-join
                       (cons lib-dir
                              (map (lambda (label)
                                     (string-append
                                      (assoc-ref inputs label) "/lib"))
                                   '("glibc" "gcc:lib" "mesa" "alsa-lib")))
                       ":")))
                (define (patch-elf file)
                  (format #t "Patching ~a ..." file)
                  (unless (string-contains file ".so")
                    (invoke "patchelf" "--set-interpreter" ld.so file))
                  (invoke "patchelf" "--set-rpath" rpath file)
                  (display " done\n"))
                (for-each patch-elf
                          (cons (string-append lib-dir "/inso")
                                (find-files lib-dir ".*\\.so.*"))))))
          (add-after 'patch-elf 'make-executable
            (lambda _
              (for-each (lambda (f) (chmod f #o555))
                        (find-files (string-append #$output "/lib/inso")
                                    ".*\\.so.*"))
              (chmod (string-append #$output "/lib/inso/inso") #o555)))
          (add-after 'patch-elf 'build-wrapper
            (lambda _
              ;; inso resolves its read-only assets (shaders/, data/,
              ;; skins/_default/) and its writable state (songs/, custom
              ;; skins) relative to its working directory.  Run it from a
              ;; per-user data directory and seed it with symlinks back to
              ;; the store assets on first launch.
              (let* ((bin (string-append #$output "/bin"))
                     (wrapper (string-append bin "/inso"))
                     (data-root (string-append #$output "/share/inso")))
                (mkdir-p bin)
                (call-with-output-file wrapper
                  (lambda (port)
                    (format port "#!~a/bin/bash~%" #$bash-minimal)
                    (format port "set -e~%")
                    (format port "DATA_DIR=\"${INSO_DATA_DIR:-")
                    (format port "${XDG_DATA_HOME:-$HOME/.local/share}/inso}\"~%")
                    (format port "STORE=\"~a\"~%" data-root)
                    (format port "mkdir -p \"$DATA_DIR\"~%")
                    ;; Expose read-only store assets by symlinking them into
                    ;; the per-user data dir when absent (-n leaves an
                    ;; existing real directory untouched).
                    (format port "for sub in shaders data docs; do~%")
                    (format port
                            "  [ -e \"$DATA_DIR/$sub\" ] || ")
                    (format port "ln -sn \"$STORE/$sub\" \"$DATA_DIR/$sub\"~%")
                    (format port "done~%")
                    ;; Seed the default skin (read-only) and the songs dir.
                    (format port "mkdir -p \"$DATA_DIR/skins\"~%")
                    (format port "[ -e \"$DATA_DIR/skins/_default\" ] || ")
                    (format port
                            "ln -sn \"$STORE/skins/_default\" ")
                    (format port "\"$DATA_DIR/skins/_default\"~%")
                    (format port "mkdir -p \"$DATA_DIR/songs\"~%")
                    (format port "cd \"$DATA_DIR\"~%")
                    (format port "exec -a inso ~a/lib/inso/inso \"$@\"~%"
                            #$output)))
                (chmod wrapper #o755))))
          (add-after 'build-wrapper 'wrap-program
            (lambda* (#:key inputs #:allow-other-keys)
              ;; RPATH already covers the bundled .so, glibc, gcc:lib,
              ;; mesa and alsa-lib, but add LD_LIBRARY_PATH for the
              ;; dlopen-loaded GL/EGL and ALSA libraries as a belt-and-
              ;; suspenders fallback.  Use build-side `inputs' so "gcc:lib"
              ;; resolves to the lib sub-output path.
              (let ((wrapper (string-append #$output "/bin/inso")))
                (wrap-program wrapper
                  `("LD_LIBRARY_PATH" ":" prefix
                    (,(string-append #$output "/lib/inso")
                     ,@(map (lambda (label)
                              (string-append
                               (assoc-ref inputs label) "/lib"))
                            '("gcc:lib" "mesa" "alsa-lib"))))))))
          (add-after 'wrap-program 'install-desktop-entry
            (lambda _
              (let ((apps (string-append #$output "/share/applications")))
                (mkdir-p apps)
                (call-with-output-file
                    (string-append apps "/inso.desktop")
                  (lambda (port)
                    (format port "[Desktop Entry]~%")
                    (format port "Name=inso~%")
                    (format port "Comment=osu! clone with Lua and GLSL shader support~%")
                    (format port "Exec=~a/bin/inso~%" #$output)
                    (format port "Icon=inso~%")
                    (format port "Terminal=false~%")
                    (format port "Type=Application~%")
                    (format port "Categories=Game;ArcadeGame;~%")))))))))
    (native-inputs (list unzip patchelf))
    (inputs
     `(("bash-minimal" ,bash-minimal)
       ("glibc" ,glibc)
       ("gcc:lib" ,gcc "lib")
       ("mesa" ,mesa)
       ("alsa-lib" ,alsa-lib)))
    ;; Release assets are named "inso-<version>-linux-x64.zip"; upstream-name
    ;; is the filename prefix before the version.  accept-pre-releases? so
    ;; guix refresh considers pre-release tags (v0.3.5 is marked pre-release).
    ;; Tag prefix is lowercase "v" again since 0.3.8, so the github updater's
    ;; URL rewrite handles this package; the "v" tag_prefix in
    ;; check-updates/config.json keeps the Python fallback in sync.
    (properties `((upstream-name . "inso")
                  (accept-pre-releases? . #t)))
    (home-page "https://github.com/isakvik/inso")
    (synopsis "Performant osu! clone with Lua and GLSL shader support")
    (description "inso is a performant osu! clone written in Odin, featuring
Lua scripting and GLSL shader support for beatmaps.  It integrates with
existing osu! beatmap collections and was originally built for the YEAST3
sightreading tournament.

On first launch it prepares a per-user data directory
(@file{~/.local/share/inso} or @env{INSO_DATA_DIR}) with the bundled default
skin, shaders and fonts; drop osu! beatmaps into @file{songs/} there to play
them.")
    (license (license:nonfree "https://github.com/isakvik/inso"))
    (supported-systems '("x86_64-linux"))))

;; deltalazer —— osu!lazer 社区 fork（可变 CS/AR/OD、HP gimmick）。应用内
;; 更新换成了 Velopack，但 deltalazer.dll 保留 OSU_EXTERNAL_UPDATE_PROVIDER
;; 开关（wrapper 已设）。用户数据在 ~/.local/share/deltalazer。
(define-public deltalazer-bin
  (osu-lazer-appimage-package
   "deltalazer-bin" "3.0"
   "1ivnmv06n61lhrshm6ajx7i1nkvzy3fmqbva396y7rybicz7q9y2"
   #:repo "https://github.com/deltalazer/delta"
   #:tag-prefix "v"
   #:asset "deltalazer-linux-x64.AppImage"
   #:binary "deltalazer"
   #:desktop "deltalazer.desktop"
   #:home-page "https://github.com/deltalazer/delta"
   #:synopsis "Unofficial osu!lazer client with variable CS/AR/OD and HP gimmicks"
   #:description "deltalazer is an unofficial fork of osu!lazer, the
open-source rhythm game, adding gameplay gimmicks such as variable
circle size (CS), approach rate (AR), overall difficulty (OD) and HP
drain.  It reads the same beatmap and skin formats as osu!

Its per-user data (beatmaps, skins, realm database) lives in
@file{~/.local/share/deltalazer}."))

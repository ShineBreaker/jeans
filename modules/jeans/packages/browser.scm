;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-only

(define-module (jeans packages browser)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build copy-build-system)
  #:use-module (guix build-system copy)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system trivial)
  #:use-module (guix gexp)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages python)
  #:use-module (gnu packages java)
  #:use-module (gnu packages librewolf)
  #:use-module (gnu packages python)
  #:use-module (gnu packages rdesktop)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bootstrap)
  #:use-module (gnu packages commencement)
  #:use-module (gnu packages elf)
  #:use-module (gnu packages gl)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages icu4c)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages pciutils)
  #:use-module (gnu packages pulseaudio)
  #:use-module (gnu packages video)
  #:use-module (gnu packages xorg)
  #:use-module (gnu system shadow)
  #:use-module (guix gexp)
  #:use-module (guix utils))

;; Patch scripts for librewolf-nongnu (extracted to patches/)
;; NOTE: Using search-path + local-file because relative local-file paths
;; fail when modules are loaded via `guix build -L modules` (current-source-directory
;; returns #f in that context). search-path resolves the absolute path at module
;; load time via %load-path, which includes the `-L` directories.
(define librewolf-patch-omni-script
  (local-file (canonicalize-path
               (search-path %load-path "jeans/patches/librewolf-patch-omni.py"))))

(define librewolf-patch-browser-omni-script
  (local-file (canonicalize-path
               (search-path %load-path "jeans/patches/librewolf-patch-browser-omni.py"))))

;;; 保留 LibreWolf 本体，仅修补其对 Mozilla 官方附加组件与语言包服务的限制。
(define-public librewolf-nongnu
  (package
   (inherit librewolf)
   (name "librewolf-nongnu")
   (source #f)
   (build-system trivial-build-system)
   (arguments
    (list
     #:modules '((guix build utils))
     #:builder
     #~(begin
         (use-modules (guix build utils))

         (define lw #$librewolf)
         (define out #$output)

         ;; 辅助函数：将符号链接替换为实际文件副本
         (define (dereference! path)
           (when (and (file-exists? path) (symbolic-link? path))
             (let* ((target (readlink path))
                    (resolved (if (string-prefix? "/" target)
                                  target
                                  (string-append (dirname path) "/" target)))
                    (tmp (string-append path ".tmp")))
               (copy-file resolved tmp)
               (delete-file path)
               (rename-file tmp path))))

         ;; 1. 复制整个 LibreWolf 到输出（保留原权限和符号链接）
         (copy-recursively lw out)

         ;; 2. 恢复 Mozilla 官方附加组件与语言包服务 URL
         (let ((cfg-file (string-append out "/lib/librewolf/librewolf.cfg")))
           (dereference! cfg-file)
           (chmod cfg-file #o644)
           (substitute* cfg-file
                        (((string-append
                           "defaultPref\\(\"extensions\\.getAddons\\."
                           "search\\.browseURL\", .*"))
                         (string-append
                          "defaultPref(\"extensions.getAddons.search.browseURL\", "
                          "\"https://addons.mozilla.org/%LOCALE%/firefox/search?"
                          "q=%TERMS%&platform=%OS%&appver=%VERSION%\");\n"))
                        (((string-append
                           "defaultPref\\(\"extensions\\.getAddons\\.get\\."
                           "url\", .*"))
                         (string-append
                          "defaultPref(\"extensions.getAddons.get.url\", "
                          "\"https://services.addons.mozilla.org/api/v4/"
                          "addons/search/?guid=%IDS%&lang=%LOCALE%\");\n"))
                        (((string-append
                           "defaultPref\\(\"extensions\\.getAddons\\.link\\."
                           "url\", .*"))
                         (string-append
                          "defaultPref(\"extensions.getAddons.link.url\", "
                          "\"https://addons.mozilla.org/%LOCALE%/firefox/\");\n"))
                        (((string-append
                           "defaultPref\\(\"extensions\\.getAddons\\."
                           "discovery\\.api_url\", .*"))
                         (string-append
                          "defaultPref(\"extensions.getAddons.discovery."
                          "api_url\", \"https://services.addons.mozilla.org/"
                          "api/v4/discovery/?lang=%LOCALE%&"
                          "edition=%DISTRIBUTION%\");\n"))
                        (((string-append
                           "defaultPref\\(\"extensions\\.getAddons\\."
                           "langpacks\\.url\", .*"))
                         (string-append
                          "defaultPref(\"extensions.getAddons.langpacks.url\", "
                          "\"https://services.addons.mozilla.org/api/v4/addons/"
                          "language-tools/?app=firefox&type=language&"
                          "appversion=%VERSION%\");\n"))
                        (((string-append
                           "defaultPref\\(\"lightweightThemes\\.getMoreURL\", "
                           ".*"))
                         (string-append
                          "defaultPref(\"lightweightThemes.getMoreURL\", "
                          "\"https://addons.mozilla.org/%LOCALE%/firefox/"
                          "themes\");\n")))
           (chmod cfg-file #o444))

         ;; 2.1 修正 app cslication.ini 中带发行版后缀的版本号，
         ;;     否则 Mozilla 语言包的 strict_max_version 不会匹配 149.0-1 这种值。
         (let ((app-file (string-append out "/lib/librewolf/application.ini")))
           (dereference! app-file)
           (chmod app-file #o644)
           (substitute* app-file
                        (("Version=([0-9]+\\.[0-9]+)-[0-9]+" all version)
                         (string-append "Version=" version)))
           (chmod app-file #o444))

         ;; 2.2 修补 omni.ja：修正 AppConstants 版本号 + 绕过 langpack 兼容性检查
         ;;     - AppConstants 中的 MOZ_APP_VERSION 带有 Guix 发行版后缀 (如 149.0-1)，
         ;;       Mozilla 语言包的 strict_max_version 无法匹配，需要去除。
         ;;     - isUsableAddon() 对 locale 类型扩展也会做版本兼容性检查，
         ;;       即使版本号正确，仍可能因其他原因失败。直接跳过 locale 类型的检查。
         (let ((omni-file (string-append out "/lib/librewolf/omni.ja")))
           (dereference! omni-file)
           (chmod omni-file #o644)
          (invoke #$(file-append python "/bin/python3")
                  #$librewolf-patch-omni-script
                  omni-file)
           (chmod omni-file #o444))

         ;; 2.3 修补 browser/omni.ja：移除启动时无条件卸载所有语言包的逻辑
         (let ((browser-omni-file (string-append out "/lib/librewolf/browser/omni.ja")))
           (dereference! browser-omni-file)
           (chmod browser-omni-file #o644)
          (invoke #$(file-append python "/bin/python3")
                  #$librewolf-patch-browser-omni-script
                  browser-omni-file)
           (chmod browser-omni-file #o444))

         ;; 3. Patch policies.json: 允许安装语言包，并显示语言切换 UI
         (let ((policies-file
                (string-append
                 out "/lib/librewolf/distribution/policies.json")))
           (dereference! policies-file)
           (chmod policies-file #o644)
           (substitute* policies-file
                        (((string-append
                           "\"allowed_types\": \\[\"dictionary\", "
                           "\"extension\", \"sitepermission\", \"theme\"\\]"))
                         (string-append
                          "\"allowed_types\": [\"dictionary\", \"extension\", "
                          "\"locale\", \"sitepermission\", \"theme\"]")))
           (substitute* policies-file
                        (((string-append
                           "\"blocked_install_message\": \"LibreWolf does not "
                           "allow installing Language Packs\\.\""))
                         (string-append
                          "\"blocked_install_message\": \"LibreWolf allows "
                          "installing language packs from Mozilla Add-ons.\"")))
           (substitute* policies-file
                        (("\"SkipTermsOfUse\": true,")
                         (string-append "\"Preferences\": {\n"
                                        "            \"extensions.ui.locale.hidden\": {\n"
                                        "                \"Value\": false,\n"
                                        "                \"Status\": \"user\"\n"
                                        "            },\n"
                                        "            \"intl.locale.requested\": {\n"
                                        "                \"Value\": \"zh-CN,en-US\",\n"
                                        "                \"Status\": \"user\"\n"
                                        "            }\n"
                                        "        },\n"
                                        "        \"SkipTermsOfUse\": true,")))
           (chmod policies-file #o444))

         ;; 4. 修正 wrapper 脚本中硬编码的旧 store 路径
         ;;    bin/librewolf 是指向 lib/.../librewolf 的符号链接，两者都需要修正
         (for-each
          (lambda (file)
            (let ((path (string-append out "/" file)))
              (when (file-exists? path)
                (dereference! path)
                (chmod path #o644)
                (substitute* path ((lw) out))
                (chmod path #o555))))
          '("bin/librewolf"
            "lib/librewolf/librewolf"
            "share/applications/librewolf.desktop")))))
   (inputs
    (list librewolf))
   (native-inputs (list python))
   (home-page "https://librewolf.net/")
       (synopsis "LibreWolf with Mozilla language pack support restored")
       (description
        "LibreWolf is designed to increase protection against tracking and
fingerprinting while including additional security improvements.  This package
restores access to Mozilla's official add-on and language pack services and
keeps the language selection interface enabled.")
       (license license:mpl2.0)))

(define-public zen-browser-bin
  (package
    (name "zen-browser-bin")
    (version "1.21.8b")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/zen-browser/desktop/releases/download/"
             version "/zen.linux-x86_64.tar.xz"))
       (sha256
        (base32 "1x4nycx7kkyqfjm901ikpsmmcimgyx0kjbjawl0fgny9wibnd8q5"))))
    (build-system copy-build-system)
    (arguments
     (list
      #:tests? #f
      #:install-plan
      #~'(("." "lib/zen"))
      #:validate-runpath? #f
      #:strip-binaries? #f
      #:modules `((ice-9 regex)
                  (ice-9 string-fun)
                  (ice-9 ftw)
                  (srfi srfi-1)
                  (srfi srfi-26)
                  (rnrs bytevectors)
                  (rnrs io ports)
                  (guix elf)
                  (guix build gremlin)
                  ,@%copy-build-system-modules
                  ,@%default-gnu-imported-modules)
      #:phases
      #~(modify-phases (@@ (guix build copy-build-system) %standard-phases)
          (add-after 'install 'wrap-program
            (lambda* (#:key inputs outputs #:allow-other-keys)
              (define (runpath-of lib)
                (call-with-input-file lib
                  (compose elf-dynamic-info-runpath elf-dynamic-info parse-elf
                           get-bytevector-all)))
              (define (runpaths-of-input label)
                (let* ((dir (string-append (assoc-ref inputs label) "/lib"))
                       (libs (find-files dir "\\.so$")))
                  (append-map runpath-of libs)))
              (let* ((out (assoc-ref outputs "out"))
                     (lib (string-append out "/lib"))
                     ;; ;; TODO: make me a loop again
                     (mesa-lib (string-append (assoc-ref inputs "mesa") "/lib"))
                     ;; For the integration of native notifications
                     (libnotify-lib (string-append (assoc-ref inputs
                                                              "libnotify")
                                                   "/lib"))
                     ;; For hardware video acceleration via VA-API
                     (libva-lib (string-append (assoc-ref inputs "libva")
                                               "/lib"))
                     ;; Needed for video acceleration (via libdrm which mesa
                     ;; and libva depend on).
                     (pciaccess-lib (string-append (assoc-ref inputs
                                                              "libpciaccess")
                                                   "/lib"))
                     ;; VA-API is run in the RDD (Remote Data Decoder) sandbox
                     ;; and must be explicitly given access to files it needs.
                     ;; Rather than adding the whole store (as Nix had
                     ;; upstream do, see
                     ;; <https://github.com/NixOS/nixpkgs/pull/165964> and
                     ;; linked upstream patches), we can just follow the
                     ;; runpaths of the needed libraries to add everything to
                     ;; LD_LIBRARY_PATH.  These will then be accessible in the
                     ;; RDD sandbox.
                     ;; TODO: Properly handle the runpath of libraries needed
                     ;; (for RDD) recursively, so the explicit libpciaccess
                     ;; can be removed.
                     (rdd-whitelist (map (cut string-append <> "/")
                                         (delete-duplicates (append-map
                                                             runpaths-of-input
                                                             '("mesa" "ffmpeg")))))
                     (pulseaudio-lib (string-append (assoc-ref inputs
                                                               "pulseaudio")
                                                    "/lib"))
                     ;; For sharing on Wayland
                     (pipewire-lib (string-append (assoc-ref inputs "pipewire")
                                                  "/lib"))
                     ;; For U2F and WebAuthn
                     (eudev-lib (string-append (assoc-ref inputs "eudev")
                                               "/lib"))
                     (gtk-share (string-append (assoc-ref inputs "gtk+")
                                               "/share")))
                (wrap-program (car (find-files lib "^zen$"))
                  `("LD_LIBRARY_PATH" prefix
                    (,mesa-lib ,libnotify-lib
                     ,libva-lib
                     ,pciaccess-lib
                     ,pulseaudio-lib
                     ,eudev-lib
                     ,@rdd-whitelist
                     ,pipewire-lib))
                  `("XDG_DATA_DIRS" prefix
                    (,gtk-share))
                  `("MOZ_LEGACY_PROFILES" =
                    ("1"))
                  `("MOZ_ALLOW_DOWNGRADE" =
                    ("1"))))))
          (add-after 'install 'patch-elf
            (lambda* (#:key inputs #:allow-other-keys)
              (let ((ld.so (string-append #$(this-package-input "glibc")
                                          #$(glibc-dynamic-linker)))
                    (rpath (string-join (cons* (string-append #$output
                                                              "/lib/zen")
                                               (string-append #$output
                                                "/lib/zen/gmp-clearkey/0.1")
                                               (string-append #$(this-package-input
                                                                 "gtk+")
                                                              "/share")
                                               (map (lambda (input)
                                                      (string-append (cdr
                                                                      input)
                                                                     "/lib"))
                                                    inputs)) ":")))
                ;; Got this proc from hako's Rosenthal, thanks
                (define (patch-elf file)
                  (format #t "Patching ~a ..." file)
                  (unless (string-contains file ".so")
                    (invoke "patchelf" "--set-interpreter" ld.so file))
                  (invoke "patchelf" "--set-rpath" rpath file)
                  (display " done\n"))
                (for-each (lambda (binary)
                            (patch-elf binary))
                          (append (map (lambda (binary)
                                         (string-append #$output "/lib/zen/"
                                                        binary))
                                       '("glxtest" "updater" "vaapitest"
                                         "vulkantest" "zen" "zen-bin"
                                         "pingsender"))
                                  (find-files (string-append #$output
                                                             "/lib/zen")
                                              ".*\\.so.*"))))))
          (add-after 'patch-elf 'install-bin
            (lambda _
              (let* ((zen (string-append #$output "/lib/zen/zen"))
                     (bin-zen (string-append #$output "/bin/zen")))
                (mkdir (string-append #$output "/bin"))
                (symlink zen bin-zen))))
          (add-after 'install-bin 'install-desktop
            (lambda _
              (let* ((share-applications (string-append #$output
                                                        "/share/applications"))
                     (desktop (string-append share-applications "/zen.desktop")))
                (mkdir-p share-applications)
                (make-desktop-entry-file desktop
                                         #:name "Zen Browser"
                                         #:icon "zen"
                                         #:type "Application"
                                         #:comment #$(package-synopsis
                                                      this-package)
                                         #:exec (string-append #$output
                                                               "/bin/zen %u")
                                         #:keywords '("Internet" "WWW"
                                                      "Browser" "Web"
                                                      "Explorer")
                                         #:categories '("Network" "Browser")
                                         ;; Upstream also defines new-window,
                                         ;; new-private-window and profile
                                         ;; manager actions.
                                         #:mime-type '("text/html" "text/xml"
                                                       "application/xhtml+xml"
                                                       "x-scheme-handler/http"
                                                       "x-scheme-handler/https"
                                                       "application/x-xpinstall"
                                                       "application/pdf"
                                                       "application/json")
                                         #:startup-w-m-class "zen-alpha"))))
          (add-after 'install-desktop 'install-icons
            (lambda _
              (let* ((out #$output)
                     (icon-source (string-append out
                                   "/lib/zen/browser/chrome/icons/default"))
                     (icon-target (string-append out "/share/icons/hicolor"))
                     (icons '(("16" . "16x16") ("32" . "32x32")
                              ("48" . "48x48")
                              ("64" . "64x64")
                              ("128" . "128x128"))))
                (when (file-exists? icon-source)
                  (for-each (lambda (entry)
                              (let* ((file-size (car entry))
                                     (dir-size (cdr entry))
                                     (icon-file (string-append icon-source
                                                               "/default"
                                                               file-size
                                                               ".png"))
                                     (target-dir (string-append icon-target
                                                                "/" dir-size
                                                                "/apps")))
                                (when (file-exists? icon-file)
                                  (mkdir-p target-dir)
                                  (copy-file icon-file
                                             (string-append target-dir
                                                            "/zen.png")))))
                            icons))))))))
    (native-inputs (list patchelf))
    (inputs (list bash-minimal
                  alsa-lib
                  eudev
                  gcc-toolchain
                  icu4c
                  gtk+
                  glibc
                  libnotify
                  libva
                  pciutils
                  mesa
                  ffmpeg-6
                  libpciaccess
                  pipewire
                  pulseaudio))
    (properties `((upstream-name . "zen")))
    (home-page "https://zen-browser.app/")
    (synopsis "Privacy-focused web browser with a calm interface")
    (description
     "Beautifully designed, privacy-focused, and packed with features.
We care about your experience, not your data.")
    (license (list license:mpl2.0))))

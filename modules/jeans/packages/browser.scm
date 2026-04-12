(define-module (jeans packages browser)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
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
  #:use-module (gnu system shadow)
  #:use-module (guix gexp)
  #:use-module (guix utils))

;;; 保留 LibreWolf 本体，仅修补其对 Mozilla 官方附加组件与语言包服务的限制。
(define librewolf-nongnu
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
                        (("defaultPref\\(\"extensions\\.getAddons\\.search\\.browseURL\", .*")
                         "defaultPref(\"extensions.getAddons.search.browseURL\", \"https://addons.mozilla.org/%LOCALE%/firefox/search?q=%TERMS%&platform=%OS%&appver=%VERSION%\");\n")
                        (("defaultPref\\(\"extensions\\.getAddons\\.get\\.url\", .*")
                         "defaultPref(\"extensions.getAddons.get.url\", \"https://services.addons.mozilla.org/api/v4/addons/search/?guid=%IDS%&lang=%LOCALE%\");\n")
                        (("defaultPref\\(\"extensions\\.getAddons\\.link\\.url\", .*")
                         "defaultPref(\"extensions.getAddons.link.url\", \"https://addons.mozilla.org/%LOCALE%/firefox/\");\n")
                        (("defaultPref\\(\"extensions\\.getAddons\\.discovery\\.api_url\", .*")
                         "defaultPref(\"extensions.getAddons.discovery.api_url\", \"https://services.addons.mozilla.org/api/v4/discovery/?lang=%LOCALE%&edition=%DISTRIBUTION%\");\n")
                        (("defaultPref\\(\"extensions\\.getAddons\\.langpacks\\.url\", .*")
                         "defaultPref(\"extensions.getAddons.langpacks.url\", \"https://services.addons.mozilla.org/api/v4/addons/language-tools/?app=firefox&type=language&appversion=%VERSION%\");\n")
                        (("defaultPref\\(\"lightweightThemes\\.getMoreURL\", .*")
                         "defaultPref(\"lightweightThemes.getMoreURL\", \"https://addons.mozilla.org/%LOCALE%/firefox/themes\");\n"))
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
                   "-c"
                   (string-append
                    "import pathlib, re, shutil, tempfile, zipfile\n"
                    "omni = pathlib.Path('" omni-file "')\n"
                    "with tempfile.TemporaryDirectory() as td:\n"
                    "    root = pathlib.Path(td)\n"
                    "    with zipfile.ZipFile(omni) as zin:\n"
                    "        zin.extractall(root)\n"
                    "    # Patch 1: Fix MOZ_APP_VERSION in AppConstants\n"
                    "    app = root / 'modules' / 'AppConstants.sys.mjs'\n"
                    "    text = app.read_text()\n"
                    "    text = re.sub(r'MOZ_APP_VERSION: \"([0-9]+\\.[0-9]+)-[0-9]+\"', r'MOZ_APP_VERSION: \"\\1\"', text)\n"
                    "    text = re.sub(r'MOZ_APP_VERSION_DISPLAY: \"([0-9]+\\.[0-9]+)-[0-9]+\"', r'MOZ_APP_VERSION_DISPLAY: \"\\1\"', text)\n"
                    "    app.write_text(text)\n"
                    "    # Patch 2: Skip compat check for locale addons in XPIDatabase\n"
                    "    db = root / 'modules' / 'addons' / 'XPIDatabase.sys.mjs'\n"
                    "    db_text = db.read_text()\n"
                    "    old_compat = 'if (lazy.AddonManager.checkCompatibility) {'\n"
                    "    new_compat = 'if (aAddon.type != \"locale\" && lazy.AddonManager.checkCompatibility) {'\n"
                    "    if old_compat in db_text:\n"
                    "        db_text = db_text.replace(old_compat, new_compat, 1)\n"
                    "        db.write_text(db_text)\n"
                    "        print('Patched XPIDatabase: bypassed compat check for locale addons')\n"
                    "    else:\n"
                    "        print('WARNING: could not find compat check in XPIDatabase')\n"
                    "    # Rebuild omni.ja\n"
                    "    rebuilt = root / 'omni-fixed.ja'\n"
                    "    with zipfile.ZipFile(rebuilt, 'w', compression=zipfile.ZIP_DEFLATED) as zout:\n"
                    "        for path in sorted(root.rglob('*')):\n"
                    "            if path.is_file() and path != rebuilt:\n"
                    "                zout.write(path, path.relative_to(root).as_posix())\n"
                    "    shutil.move(str(rebuilt), omni)\n"))
           (chmod omni-file #o444))

         ;; 2.3 修补 browser/omni.ja：移除启动时无条件卸载所有语言包的逻辑
         (let ((browser-omni-file (string-append out "/lib/librewolf/browser/omni.ja")))
           (dereference! browser-omni-file)
           (chmod browser-omni-file #o644)
           (invoke #$(file-append python "/bin/python3")
                   "-c"
                   (string-append
                    "import pathlib, shutil, tempfile, zipfile\n"
                    "omni = pathlib.Path('" browser-omni-file "')\n"
                    "target = '''const removeLangpacks = async () => {\n"
                    "      for (const addon of await lazy.AddonManager.getAddonsByTypes([\"locale\"])) {\n"
                    "        await addon.uninstall();\n"
                    "      }\n"
                    "    };\n"
                    "    \n"
                    "    removeLangpacks().catch(err => {\n"
                    "      console.error(\"Could not remove langpacks\", err);\n"
                    "    });\n"
                    "'''\n"
                    "with tempfile.TemporaryDirectory() as td:\n"
                    "    root = pathlib.Path(td)\n"
                    "    with zipfile.ZipFile(omni) as zin:\n"
                    "        zin.extractall(root)\n"
                    "    glue = root / 'modules' / 'BrowserGlue.sys.mjs'\n"
                    "    text = glue.read_text()\n"
                    "    if target in text:\n"
                    "        text = text.replace(target, '', 1)\n"
                    "        glue.write_text(text)\n"
                    "        print('Patched BrowserGlue: removed startup langpack uninstall hook')\n"
                    "    else:\n"
                    "        print('WARNING: could not find startup langpack uninstall hook in BrowserGlue')\n"
                    "    rebuilt = root / 'browser-omni-fixed.ja'\n"
                    "    with zipfile.ZipFile(rebuilt, 'w', compression=zipfile.ZIP_DEFLATED) as zout:\n"
                    "        for path in sorted(root.rglob('*')):\n"
                    "            if path.is_file() and path != rebuilt:\n"
                    "                zout.write(path, path.relative_to(root).as_posix())\n"
                    "    shutil.move(str(rebuilt), omni)\n"))
           (chmod browser-omni-file #o444))

         ;; 3. Patch policies.json: 允许安装语言包，并显示语言切换 UI
         (let ((policies-file (string-append out "/lib/librewolf/distribution/policies.json")))
           (dereference! policies-file)
           (chmod policies-file #o644)
           (substitute* policies-file
                        (("\"allowed_types\": \\[\"dictionary\", \"extension\", \"sitepermission\", \"theme\"\\]")
                         "\"allowed_types\": [\"dictionary\", \"extension\", \"locale\", \"sitepermission\", \"theme\"]"))
           (substitute* policies-file
                        (("\"blocked_install_message\": \"LibreWolf does not allow installing Language Packs\\.\"")
                         "\"blocked_install_message\": \"LibreWolf allows installing language packs from Mozilla Add-ons.\""))
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
       (synopsis
        "Custom version of Firefox, focused on privacy, security and freedom. (revert guix patch)")
       (description
        "LibreWolf is designed to increase protection against tracking and
   fingerprinting techniques, while also including a few security improvements.
   This is achieved through our privacy and security oriented settings and
   patches.  LibreWolf also aims to remove all the telemetry, data collection and
   annoyances, as well as disabling anti-freedom features like DRM. (revert guix patch)")
       (license license:mpl2.0)))

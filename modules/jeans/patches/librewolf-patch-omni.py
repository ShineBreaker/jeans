# SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only
#
# Patch omni.ja for librewolf-nongnu:
#   1. Fix MOZ_APP_VERSION in AppConstants.sys.mjs (strip Guix release suffix)
#   2. Bypass compat check for locale addons in XPIDatabase.sys.mjs
#   3. Remove the BrowserGlue startup hook that unconditionally uninstalls
#      all language packs
#
# Usage: python3 librewolf-patch-omni.py <omni.ja>

import pathlib, re, shutil, sys, tempfile, zipfile

omni = pathlib.Path(sys.argv[1])
with tempfile.TemporaryDirectory() as td:
    root = pathlib.Path(td)
    with zipfile.ZipFile(omni) as zin:
        zin.extractall(root)

    # Patch 1: Fix MOZ_APP_VERSION in AppConstants
    # 上游 156 起 MOZ_APP_VERSION 已不带发行版后缀，仅 MOZ_APP_VERSION_DISPLAY
    # 保留（如 "156.0.1-1"）；152 时代两行都带后缀。正则对两种格式都工作：
    # 有后缀则剥离，无后缀原样保留。
    app = root / "modules" / "AppConstants.sys.mjs"
    text = app.read_text()
    text, n_ver = re.subn(
        r'MOZ_APP_VERSION(_DISPLAY)?: "([0-9.]+)(?:-[0-9]+)?"',
        r'MOZ_APP_VERSION\1: "\2"',
        text,
    )
    if n_ver < 2:
        sys.exit(
            f"ERROR: only {n_ver}/2 MOZ_APP_VERSION patterns found in AppConstants "
            "(upstream changed?)"
        )
    if re.search(r'MOZ_APP_VERSION(?:_DISPLAY)?: "[0-9.]+-[0-9]+"', text):
        sys.exit("ERROR: MOZ_APP_VERSION still carries a release suffix after patching")
    app.write_text(text)

    # Patch 2: Skip compat check for locale addons in XPIDatabase
    db = root / "modules" / "addons" / "XPIDatabase.sys.mjs"
    db_text = db.read_text()
    old_compat = "if (lazy.AddonManager.checkCompatibility) {"
    new_compat = (
        'if (aAddon.type != "locale" && lazy.AddonManager.checkCompatibility) {'
    )
    if old_compat in db_text:
        db_text = db_text.replace(old_compat, new_compat, 1)
        db.write_text(db_text)
        print("Patched XPIDatabase: bypassed compat check for locale addons")
    else:
        sys.exit("ERROR: could not find compat check in XPIDatabase (upstream changed?)")

    # Patch 3: Remove the startup hook that unconditionally uninstalls all
    # language packs.
    # Firefox ~159 把 BrowserGlue.sys.mjs 从 browser/omni.ja 的 modules/ 挪进
    # 根 omni.ja 的 moz-src/ 树（159.0.1 实测）；两个候选路径都试，防上游
    # 再挪。上游空行缩进不固定（149.0 为真空行，152.0.4 带尾随缩进），
    # 用 \s* 做空白不敏感匹配。
    glue = None
    for cand in ("moz-src/browser/components/BrowserGlue.sys.mjs",
                 "modules/BrowserGlue.sys.mjs"):
        p = root / cand
        if p.exists():
            glue = p
            break
    if glue is None:
        sys.exit("ERROR: BrowserGlue.sys.mjs not found in omni.ja "
                 "(upstream layout changed?)")
    pattern = re.compile(
        r'[ \t]*const removeLangpacks = async \(\) => \{\s*'
        r'for \(const addon of await lazy\.AddonManager\.getAddonsByTypes\(\["locale"\]\)\) \{\s*'
        r'await addon\.uninstall\(\);\s*'
        r'\}\s*\};\s*'
        r'removeLangpacks\(\)\.catch\(err => \{\s*'
        r'console\.error\("Could not remove langpacks", err\);\s*'
        r'\}\);[ \t]*\n'
    )
    text, n = pattern.subn("", glue.read_text(), count=1)
    if n == 0:
        sys.exit(
            "ERROR: could not find startup langpack uninstall hook in BrowserGlue "
            "(upstream changed?)"
        )
    glue.write_text(text)
    print("Patched BrowserGlue: removed startup langpack uninstall hook")

    # Rebuild omni.ja
    rebuilt = root / "omni-fixed.ja"
    with zipfile.ZipFile(rebuilt, "w", compression=zipfile.ZIP_DEFLATED) as zout:
        for path in sorted(root.rglob("*")):
            if path.is_file() and path != rebuilt:
                zout.write(path, path.relative_to(root).as_posix())
    shutil.move(str(rebuilt), omni)

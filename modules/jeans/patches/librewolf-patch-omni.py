# SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only
#
# Patch omni.ja for librewolf-nongnu:
#   1. Fix MOZ_APP_VERSION in AppConstants.sys.mjs (strip Guix release suffix)
#   2. Bypass compat check for locale addons in XPIDatabase.sys.mjs
#
# Usage: python3 librewolf-patch-omni.py <omni.ja>

import pathlib, re, shutil, sys, tempfile, zipfile

omni = pathlib.Path(sys.argv[1])
with tempfile.TemporaryDirectory() as td:
    root = pathlib.Path(td)
    with zipfile.ZipFile(omni) as zin:
        zin.extractall(root)

    # Patch 1: Fix MOZ_APP_VERSION in AppConstants
    # 版本号段数不固定（149.0 / 152.0.4），字符类 [0-9.]+ 兼容任意段数
    app = root / "modules" / "AppConstants.sys.mjs"
    text = app.read_text()
    text, n_ver = re.subn(
        r'MOZ_APP_VERSION(_DISPLAY)?: "([0-9.]+)-[0-9]+"',
        r'MOZ_APP_VERSION\1: "\2"',
        text,
    )
    if n_ver < 2:
        sys.exit(
            f"ERROR: only {n_ver}/2 MOZ_APP_VERSION patterns found in AppConstants "
            "(upstream changed?)"
        )
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

    # Rebuild omni.ja
    rebuilt = root / "omni-fixed.ja"
    with zipfile.ZipFile(rebuilt, "w", compression=zipfile.ZIP_DEFLATED) as zout:
        for path in sorted(root.rglob("*")):
            if path.is_file() and path != rebuilt:
                zout.write(path, path.relative_to(root).as_posix())
    shutil.move(str(rebuilt), omni)

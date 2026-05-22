# SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only
#
# Patch browser/omni.ja for librewolf-nongnu:
#   Remove the startup hook that unconditionally uninstalls all language packs.
#
# Usage: python3 librewolf-patch-browser-omni.py <browser/omni.ja>

import pathlib, shutil, sys, tempfile, zipfile

omni = pathlib.Path(sys.argv[1])
target = """const removeLangpacks = async () => {
      for (const addon of await lazy.AddonManager.getAddonsByTypes(["locale"])) {
        await addon.uninstall();
      }
    };

    removeLangpacks().catch(err => {
      console.error("Could not remove langpacks", err);
    });
"""

with tempfile.TemporaryDirectory() as td:
    root = pathlib.Path(td)
    with zipfile.ZipFile(omni) as zin:
        zin.extractall(root)
    glue = root / "modules" / "BrowserGlue.sys.mjs"
    text = glue.read_text()
    if target in text:
        text = text.replace(target, "", 1)
        glue.write_text(text)
        print("Patched BrowserGlue: removed startup langpack uninstall hook")
    else:
        print("WARNING: could not find startup langpack uninstall hook in BrowserGlue")
    rebuilt = root / "browser-omni-fixed.ja"
    with zipfile.ZipFile(rebuilt, "w", compression=zipfile.ZIP_DEFLATED) as zout:
        for path in sorted(root.rglob("*")):
            if path.is_file() and path != rebuilt:
                zout.write(path, path.relative_to(root).as_posix())
    shutil.move(str(rebuilt), omni)

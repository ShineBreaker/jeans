# SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only
#
# Patch browser/omni.ja for librewolf-nongnu:
#   Remove the startup hook that unconditionally uninstalls all language packs.
#
# Usage: python3 librewolf-patch-browser-omni.py <browser/omni.ja>

import pathlib, re, shutil, sys, tempfile, zipfile

omni = pathlib.Path(sys.argv[1])

# 匹配 LibreWolf 启动时无条件卸载所有语言包的钩子。
# 上游空行缩进不固定（149.0 为真空行，152.0.4 带尾随缩进），用 \s* 做空白不敏感匹配。
pattern = re.compile(
    r'[ \t]*const removeLangpacks = async \(\) => \{\s*'
    r'for \(const addon of await lazy\.AddonManager\.getAddonsByTypes\(\["locale"\]\)\) \{\s*'
    r'await addon\.uninstall\(\);\s*'
    r'\}\s*\};\s*'
    r'removeLangpacks\(\)\.catch\(err => \{\s*'
    r'console\.error\("Could not remove langpacks", err\);\s*'
    r'\}\);[ \t]*\n'
)

with tempfile.TemporaryDirectory() as td:
    root = pathlib.Path(td)
    with zipfile.ZipFile(omni) as zin:
        zin.extractall(root)
    glue = root / "modules" / "BrowserGlue.sys.mjs"
    text, n = pattern.subn("", glue.read_text(), count=1)
    if n == 0:
        sys.exit(
            "ERROR: could not find startup langpack uninstall hook in BrowserGlue "
            "(upstream changed?)"
        )
    glue.write_text(text)
    print("Patched BrowserGlue: removed startup langpack uninstall hook")
    rebuilt = root / "browser-omni-fixed.ja"
    with zipfile.ZipFile(rebuilt, "w", compression=zipfile.ZIP_DEFLATED) as zout:
        for path in sorted(root.rglob("*")):
            if path.is_file() and path != rebuilt:
                zout.write(path, path.relative_to(root).as_posix())
    shutil.move(str(rebuilt), omni)

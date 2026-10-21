#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only
"""版本候选的合法性检查。

grep 守护：update_versions.py 在候选版本含 '/' 时必须拒绝写盘。
issue #57（2026-10-20）：erfanoabdi/gbinder-python 的 /releases/latest
404，回退到 tags 接口（按字节序返回，upstream/1.1.1 排在 1.3.1 前），
updater 把 upstream/1.1.1 写进 version 字段，guix 报
invalid character '/' in name。
"""

from pathlib import Path

SOURCE = (
    Path(__file__).resolve().parent.parent / "update_versions.py"
).read_text(encoding="utf-8")

# 候选被拒绝的分支必须出现在 update_package_in_file 之前。
GUARD = 'if "/" in cand.version:'
UPDATE = "change = update_package_in_file("

assert GUARD in SOURCE, "候选版本 '/' 守护缺失"
assert SOURCE.index(GUARD) < SOURCE.index(UPDATE), "守护必须位于写盘之前"

print("release candidate guard checks passed")

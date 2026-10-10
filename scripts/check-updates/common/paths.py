# SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only
"""check-updates 全库唯一路径锚点，其余路径一律由此派生。"""
import os
from pathlib import Path

CHECK_UPDATES_DIR = Path(__file__).resolve().parent.parent
PACKAGES_DIR = CHECK_UPDATES_DIR.parent.parent / "modules" / "jeans" / "packages"
CONFIG_FILE = CHECK_UPDATES_DIR / "config.json"
REPORT_FILE = Path(os.path.realpath(CHECK_UPDATES_DIR / "report.json"))
MISANS_STATE_FILE = CHECK_UPDATES_DIR / "font-misans-state.json"
STALE_STATE_FILE = CHECK_UPDATES_DIR / "stale-state.json"
REFRESH_UPDATES_FILE = CHECK_UPDATES_DIR / "refresh-updates.json"
BUILD_REPORT_FILE = Path(os.path.realpath(CHECK_UPDATES_DIR / "build-report.json"))

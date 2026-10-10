# SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only
"""特殊源包处理器注册表：包名 → 处理函数。"""
from pathlib import Path
from typing import Any, Callable, Dict, Optional

from handlers.amber_pm import update_amber_pm
from handlers.font_misans import update_font_misans
from handlers.jdtls_bin import update_jdtls_bin
from handlers.lem_next_bin import update_lem_next_bin
from handlers.mysql_workbench_bin import update_mysql_workbench_bin
from handlers.prettier_bin import update_prettier_bin
from handlers.zcode import update_zcode


SPECIAL_UPDATERS: Dict[str, Callable[[Dict[str, Any], Dict[str, Any], Path], Optional[Dict[str, Any]]]] = {
    "zcode": update_zcode,
    "amber-pm": update_amber_pm,
    "jdtls-bin": update_jdtls_bin,
    "font-misans": update_font_misans,
    "lem-next-bin": update_lem_next_bin,
    "mysql-workbench-community-bin": update_mysql_workbench_bin,
    "prettier-bin": update_prettier_bin,
}

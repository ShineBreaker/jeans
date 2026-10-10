# SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only
"""配置加载。"""
import json
from pathlib import Path
from typing import Any

from common.paths import CONFIG_FILE

# 已废弃：保留防外部引用
NEW_BASE32 = "0000000000000000000000000000000000000000000000000000"


def load_config(config_path: Path = CONFIG_FILE) -> dict[str, Any]:
    """加载配置文件"""
    try:
        with open(config_path, "r", encoding="utf-8") as f:
            config = json.load(f)
            config.setdefault("check_pre_release", [])
            config.setdefault("skip_packages", [])
            config.setdefault("skip_files", [])
            config.setdefault("notes", {})
            config.setdefault("tag_prefix", {})
            return config
    except FileNotFoundError:
        print(f"⚠️  配置文件不存在: {config_path}")
        print("   使用默认配置")
        return {
            "check_pre_release": [],
            "skip_packages": [],
            "skip_files": [],
            "notes": {},
            "tag_prefix": {},
        }
    except json.JSONDecodeError as e:
        print(f"⚠️  配置文件格式错误: {e}")
        print("   使用默认配置")
        return {
            "check_pre_release": [],
            "skip_packages": [],
            "skip_files": [],
            "notes": {},
            "tag_prefix": {},
        }

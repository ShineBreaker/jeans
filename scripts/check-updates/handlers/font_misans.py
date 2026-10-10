# SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only
"""font-misans 特例处理器：以 Last-Modified 为更新信号。"""
import json
import re
from pathlib import Path
from typing import Any, Dict, Optional

import requests

from common.changes import update_package_in_file
from common.hashing import get_base32_from_guix_download
from common.http import ensure_public_http_url, head
from common.paths import MISANS_STATE_FILE
from common.retry import RetryableError, with_retry


MISANS_URL = ensure_public_http_url("https://hyperos.mi.com/font-download/MiSans.zip")



def update_font_misans(package: dict[str, Any], _config: dict[str, Any], scm_file: Path) -> Optional[Dict[str, Any]]:
    """font-misans：zip 无版本号，以 Last-Modified 判断上游是否更新。

    MiSans.zip 有 227MB，不能每次 CI 都下载算 hash。用 Last-Modified 作为
    更新信号：与 font-misans-state.json 记录比较，变了才下载重算 hash。
    state 文件随自动更新提交，首跑只记基线不动包。
    """
    try:
        response = head(MISANS_URL, 30)
        if 500 <= response.status_code <= 599:
            raise RetryableError(f"HTTP {response.status_code}")
        response.raise_for_status()
    except requests.exceptions.Timeout as e:
        raise RetryableError(f"请求超时: {e}")
    except requests.exceptions.ConnectionError as e:
        raise RetryableError(f"网络连接错误: {e}")

    last_modified = response.headers.get("Last-Modified")
    if not last_modified:
        raise RetryableError("响应缺少 Last-Modified 头")
    print(f"     上游 Last-Modified: {last_modified}")

    state: Dict[str, Any] = {}
    if MISANS_STATE_FILE.exists():
        state = json.loads(MISANS_STATE_FILE.read_text(encoding="utf-8"))

    if state.get("last_modified") == last_modified:
        print(f"     ✓ 上游未变化（与记录一致）")
        return None

    if "last_modified" not in state:
        state["last_modified"] = last_modified
        state["base32"] = package["base32"]
        MISANS_STATE_FILE.write_text(
            json.dumps(state, indent=2, ensure_ascii=False) + "\n", encoding="utf-8"
        )
        print(f"     📝 首次记录 MiSans 基线")
        return None

    new_base32 = with_retry(
        get_base32_from_guix_download, MISANS_URL, max_retries=1, base_delay=5,
        timeout=600,
    )
    if not new_base32 or not re.fullmatch(r"[0-9a-z]{52}", new_base32) or re.fullmatch(r"0{52}", new_base32):
        raise RetryableError("无法计算下载 hash")

    state["last_modified"] = last_modified
    state["base32"] = new_base32
    MISANS_STATE_FILE.write_text(
        json.dumps(state, indent=2, ensure_ascii=False) + "\n", encoding="utf-8"
    )

    if new_base32 == package["base32"]:
        print(f"     ✓ Last-Modified 变了但内容 hash 未变")
        return None
    print(f"     ✅ MiSans 内容有变化")
    return update_package_in_file(scm_file, package, package["version"], new_base32)

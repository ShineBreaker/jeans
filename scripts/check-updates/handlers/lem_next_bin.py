# SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only
"""lem-next-bin 特例处理器：跟踪滚动 release nightly-latest。"""
import re
from pathlib import Path
from typing import Any, Dict, Optional

import requests

from common.changes import update_package_in_file
from common.github import get_github_token
from common.hashing import get_base32_from_guix_download
from common.http import github_api_get
from common.retry import RetryableError, with_retry


def update_lem_next_bin(package: dict[str, Any], _config: dict[str, Any], scm_file: Path) -> Optional[Dict[str, Any]]:
    """lem-next-bin：跟踪上游滚动 release nightly-latest。

    上游 2025-08 起停发 dated nightly，只在移动 tag nightly-latest
    上滚动覆盖同一资产（Lem-x86_64.AppImage，URL 恒定无版本号）。
    版本信号取 release 标题里的构建戳（"Nightly Build - YYYYMMDD-HHMM"）：
    与包内 version 不同即下载重算 hash，走通用 version/base32 替换。
    """
    headers = {}
    _token = get_github_token()
    if _token:
        headers["Authorization"] = f"token {_token}"
    try:
        response = github_api_get(
            "lem-project/lem", "releases/tags/nightly-latest", headers
        )
        if 500 <= response.status_code <= 599:
            raise RetryableError(f"GitHub API 服务器错误: {response.status_code}")
        response.raise_for_status()
    except requests.exceptions.Timeout as e:
        raise RetryableError(f"请求超时: {e}")
    except requests.exceptions.ConnectionError as e:
        raise RetryableError(f"网络连接错误: {e}")

    title = response.json().get("name") or ""
    match = re.search(r"Nightly Build - (\d{8}-\d{4})", title)
    if not match:
        raise RetryableError(f"nightly-latest 标题无构建戳: {title!r}")
    latest = match.group(1)
    print(f"     最新 nightly 构建: {latest}")
    if latest == package["version"]:
        print(f"     ✓ 已是最新 nightly")
        return None

    url = (
        "https://github.com/lem-project/lem/releases/download/"
        "nightly-latest/Lem-x86_64.AppImage"
    )
    new_base32 = with_retry(
        get_base32_from_guix_download, url, max_retries=1, base_delay=5,
        timeout=600,
    )
    if not new_base32 or not re.fullmatch(r"[0-9a-z]{52}", new_base32) or re.fullmatch(r"0{52}", new_base32):
        raise RetryableError("无法计算下载 hash")
    print(f"     ✅ 发现新 nightly: {latest}")
    return update_package_in_file(scm_file, package, latest, new_base32)

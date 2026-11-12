# SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only
"""crommacode 特例处理器：闭源 agent 终端，只经自家 CDN 发布。

上游没有 GitHub release，Tauri 更新清单是唯一版本信号：

    https://dl.cromma.ai/code/stable/latest.json

清单的 platforms.linux-x86_64.installer 指向版本化 deb
（artifacts/<version>/CrommaCode-<version>-linux-amd64.deb），因此 URI 可由
version 重建，`update_package_in_file` 只改 version 与 base32 即可。

清单里的 sha256 是 AppImage archive 的，不能用于 deb 的 pin 或重钉判断；
deb 的 hash 一律下载现算。同版本不重钉：清单没有 deb 字节信号，无从判断
上游是否原地重传，宁可下一版再收。
"""
from pathlib import Path
from typing import Any, Dict, Optional

import requests

from common.changes import update_package_in_file
from common.hashing import get_base32_from_guix_download
from common.http import ensure_public_http_url, get
from common.retry import RetryableError, with_retry
from common.versions import compare_versions

MANIFEST_URL = "https://dl.cromma.ai/code/stable/latest.json"
# 只认自家 artifacts 域：清单给出别处地址时宁可失败，也不把包钉到陌生主机。
ARTIFACTS_PREFIX = "https://dl.cromma.ai/code/artifacts/"
PLATFORM = "linux-x86_64"


def update_crommacode(package: dict[str, Any], config: dict[str, Any],
                      scm_file: Path) -> Optional[Dict[str, Any]]:
    """读 Tauri 更新清单，版本变高时重钉版本与 hash。"""
    try:
        response = get(ensure_public_http_url(MANIFEST_URL), timeout=30)
    except requests.exceptions.Timeout as e:
        raise RetryableError(f"请求超时: {e}")
    except requests.exceptions.ConnectionError as e:
        raise RetryableError(f"网络连接错误: {e}")
    if 500 <= response.status_code <= 599:
        raise RetryableError(f"HTTP {response.status_code}")
    response.raise_for_status()

    try:
        payload = response.json()
        latest = payload["version"]
        installer = payload["platforms"][PLATFORM]["installer"]
    except (ValueError, KeyError, TypeError) as e:
        raise RetryableError(f"清单结构不符合预期: {e}")

    if not isinstance(installer, str) or not installer.startswith(ARTIFACTS_PREFIX):
        raise RetryableError(f"清单给出了 artifacts 域之外的地址: {str(installer)[:80]}")
    print(f"     CrommaCode CDN 最新版: {latest}")

    if not compare_versions(package["version"], latest):
        return None

    # 与 zcode 一致：大文件慢速 CDN 给足超时余量。
    new_base32 = with_retry(
        get_base32_from_guix_download, installer, max_retries=2, base_delay=5,
        timeout=600,
    )
    if (not new_base32
            or not isinstance(new_base32, str)
            or len(new_base32) != 52):
        raise RetryableError("无法计算下载 hash")
    return update_package_in_file(scm_file, package, latest, new_base32)

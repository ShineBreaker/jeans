# SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only
"""mysql-workbench-community-bin 特例处理器：版本信号在下载页。"""
import re
from pathlib import Path
from typing import Any, Dict, Optional

import requests

from common.changes import update_package_in_file
from common.hashing import get_base32_from_guix_download
from common.http import ensure_public_http_url, get
from common.retry import RetryableError, with_retry
from common.versions import compare_versions


def update_mysql_workbench_bin(package: dict[str, Any], _config: dict[str, Any], scm_file: Path) -> Optional[Dict[str, Any]]:
    """mysql-workbench-community-bin：版本信号在 dev.mysql.com 下载页，不在 GitHub。

    MySQL 官方二进制只从 cdn.mysql.com 分发（无 API、无目录列表）。
    下载页 ?tpl=files&os=2（Linux - Generic）是服务器端渲染的文件列表，
    直接包含 linux-glibc 归档完整文件名；从 x86_64 zip 文件名提取版本号
    与 glibc 段。glibc 段不在 version 里（如 linux-glibc2.28），上游提高
    最低 glibc 时通过 extra_replacements 一并改写 URI 字面量。
    """
    try:
        response = get(
            ensure_public_http_url(
                "https://dev.mysql.com/downloads/workbench/?tpl=files&os=2"
            ),
            timeout=30,
        )
        if 500 <= response.status_code <= 599:
            raise RetryableError(f"HTTP {response.status_code}")
        response.raise_for_status()
    except requests.exceptions.Timeout as e:
        raise RetryableError(f"请求超时: {e}")
    except requests.exceptions.ConnectionError as e:
        raise RetryableError(f"网络连接错误: {e}")

    m = re.search(
        r"mysql-workbench-([0-9][0-9a-zA-Z.]*)-(linux-glibc[0-9.]+)-x86_64\.zip",
        response.text,
    )
    if not m:
        raise RetryableError("下载页未找到 linux-glibc x86_64 zip 文件名")
    latest, glibc_frag = m.group(1), m.group(2)
    print(f"     dev.mysql.com 最新版: {latest} ({glibc_frag})")
    if not compare_versions(package["version"], latest):
        return None

    url = (
        "https://cdn.mysql.com/Downloads/MySQLGUITools/"
        f"mysql-workbench-{latest}-{glibc_frag}-x86_64.zip"
    )
    new_base32 = with_retry(
        get_base32_from_guix_download, url, max_retries=2, base_delay=5
    )
    if not new_base32 or not re.fullmatch(r"[0-9a-z]{52}", new_base32) or re.fullmatch(r"0{52}", new_base32):
        raise RetryableError("无法计算下载 hash")
    print(f"     ✅ 发现新版本: {latest}")
    change = update_package_in_file(scm_file, package, latest, new_base32)

    old_glibc = re.search(r"(linux-glibc[0-9.]+)", package["uri_expr"])
    if change and old_glibc and old_glibc.group(1) != glibc_frag:
        change["extra_replacements"] = [(old_glibc.group(1), glibc_frag)]
    return change

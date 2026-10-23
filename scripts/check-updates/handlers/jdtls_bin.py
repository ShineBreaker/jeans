# SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only
"""jdtls-bin 特例处理器：GitHub tags + Eclipse 目录页时间戳。"""
import re
from pathlib import Path
from typing import Any, Dict, Optional

import requests

from common.changes import update_package_in_file
from common.github import get_latest_github_tag
from common.hashing import get_base32_from_guix_download
from common.http import ensure_public_http_url, get
from common.retry import RetryableError, with_retry
from common.versions import compare_versions


def update_jdtls_bin(package: dict[str, Any], _config: dict[str, Any], scm_file: Path) -> Optional[Dict[str, Any]]:
    """jdtls-bin：GitHub tags 发现版本 + milestones/<v>/latest.txt 时间戳。

    URL 模板是 milestones/<version>/jdt-language-server-<version>-<时间戳>.tar.gz，
    时间戳是字面量，不在 version 里。发现新版本后从该版本的 latest.txt
    抓取归档文件名（download.eclipse.org 目录索引页已换成基金会通用壳页，
    无文件列表可解析；官方发现端点是每版本目录下的 latest.txt 纯文本），
    并返回 extra_replacements 让 apply_pending_updates 一并替换字面量。
    """
    tag = get_latest_github_tag("eclipse-jdtls/eclipse.jdt.ls", tag_prefix="v")
    if not tag:
        raise RetryableError("无法获取 GitHub tags")
    latest = tag.lstrip("v")
    print(f"     GitHub 最新 tag: {tag}")
    if not compare_versions(package["version"], latest):
        return None

    try:
        response = get(
            ensure_public_http_url(
                f"https://download.eclipse.org/jdtls/milestones/{latest}/latest.txt"
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
        rf"jdt-language-server-{re.escape(latest)}-(\d{{12}})\.tar\.gz", response.text
    )
    if not m:
        raise RetryableError(f"latest.txt 未找到 {latest} 的归档文件名")
    ts = m.group(1)
    url = (f"https://download.eclipse.org/jdtls/milestones/{latest}/"
           f"jdt-language-server-{latest}-{ts}.tar.gz")
    new_base32 = with_retry(
        get_base32_from_guix_download, url, max_retries=2, base_delay=5,
        timeout=300,
    )
    if not new_base32 or not re.fullmatch(r"[0-9a-z]{52}", new_base32) or re.fullmatch(r"0{52}", new_base32):
        raise RetryableError("无法计算下载 hash")

    change = update_package_in_file(scm_file, package, latest, new_base32)
    old_ts_match = re.search(r"-(\d{12})\.tar\.gz", package["uri_expr"])
    if change and old_ts_match and old_ts_match.group(1) != ts:
        change["extra_replacements"] = [
            (f"-{old_ts_match.group(1)}.tar.gz", f"-{ts}.tar.gz")
        ]
    return change

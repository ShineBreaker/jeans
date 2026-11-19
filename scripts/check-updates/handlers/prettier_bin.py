# SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only
"""npm registry 处理器：版本信号在 npm registry（prettier-bin、
typescript-language-server 等直接以 npm 包为分发源的包）。"""
import re
from pathlib import Path
from typing import Any, Dict, Optional

import requests

from common.changes import update_package_in_file
from common.hashing import get_base32_from_guix_download
from common.http import ensure_public_http_url, get
from common.retry import RetryableError, with_retry
from common.versions import compare_versions


# Guix 包名 → npm 包名。二者不同时才需要映射（prettier-bin 的 npm 名是
# prettier）；其余直接同名。
NPM_NAME_BY_PACKAGE = {
    "prettier-bin": "prettier",
    "typescript-language-server": "typescript-language-server",
}


def update_npm_package(package: dict[str, Any], _config: dict[str, Any], scm_file: Path) -> Optional[Dict[str, Any]]:
    """版本信号在 npm registry，不在 GitHub。

    上游以 npm 包为官方分发（源码 tarball 或预构建产物）。抓
    registry.npmjs.org/<name>/latest 的 version 字段（等价 dist-tags.latest，
    恒为稳定版，无预发布问题）；包定义的 URI 用 string-append 内嵌 version，
    替换 version 字段即可，URL 自动跟随。
    """
    npm_name = NPM_NAME_BY_PACKAGE.get(package["name"])
    if not npm_name:
        raise RetryableError(f"未配置 npm 包名映射: {package['name']}")
    try:
        response = get(
            ensure_public_http_url(f"https://registry.npmjs.org/{npm_name}/latest"),
            timeout=20,
        )
        if 500 <= response.status_code <= 599:
            raise RetryableError(f"HTTP {response.status_code}")
        response.raise_for_status()
    except requests.exceptions.Timeout as e:
        raise RetryableError(f"请求超时: {e}")
    except requests.exceptions.ConnectionError as e:
        raise RetryableError(f"网络连接错误: {e}")

    latest = response.json().get("version")
    if not latest:
        raise RetryableError("npm registry 未返回 version")
    print(f"     npm 最新稳定版: {latest}")
    if not compare_versions(package["version"], latest):
        return None

    url = f"https://registry.npmjs.org/{npm_name}/-/{npm_name}-{latest}.tgz"
    new_base32 = with_retry(
        get_base32_from_guix_download, url, max_retries=2, base_delay=5
    )
    if not new_base32 or not re.fullmatch(r"[0-9a-z]{52}", new_base32) or re.fullmatch(r"0{52}", new_base32):
        raise RetryableError("无法计算下载 hash")
    print(f"     ✅ 发现新版本: {latest}")
    return update_package_in_file(scm_file, package, latest, new_base32)


# 兼容旧引用名。
update_prettier_bin = update_npm_package

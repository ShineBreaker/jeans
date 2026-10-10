# SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only
"""zcode 特例处理器：官网稳定版 + CDN 灰度版扫描。"""
import re
from pathlib import Path
from typing import Any, Dict, Optional

import requests

from common.changes import update_package_in_file
from common.hashing import get_base32_from_guix_download
from common.http import ensure_public_http_url, get
from common.retry import RetryableError, with_retry
from common.versions import compare_versions


def _zcode_scan_cdn_prerelease(stable_version: str) -> Optional[str]:
    """扫描 z.ai CDN 上的灰度先行版（官网版本列表不展示）。

    灰度版直接出现在 CDN 且各平台目录带 latest.yml（如 3.8.1：先发
    Linux/macOS 灰度、无 Windows 资产、官网/changelog 均不列）。CDN
    目录不可列举（OSS list 关闭），只能基于稳定版号向三个方向递增
    探测 <v>/linux-x64/latest.yml。
    """
    major, minor, patch = (int(x) for x in stable_version.split("."))
    candidates = (
        # minor+1 段：灰度版最常见的位置（如稳定 3.7.7 → 灰度 3.8.1）
        [f"{major}.{minor + 1}.{p}" for p in range(0, 10)]
        # minor+2 段：保守扫前 3 个，防跳两个 minor
        + [f"{major}.{minor + 2}.{p}" for p in range(0, 3)]
        # 当前 minor 的后续 patch
        + [f"{major}.{minor}.{patch + p}" for p in range(1, 6)]
    )

    found = []
    for v in candidates:
        url = (f"https://cdn-zcode.z.ai/zcode/electron/releases/"
               f"{v}/linux-x64/latest.yml")
        try:
            r = get(ensure_public_http_url(url), timeout=15)
        except requests.exceptions.RequestException:
            continue  # 单个探测点的网络抖动不影响整体
        if r.status_code == 200:
            found.append(v)
    if not found:
        return None
    return max(found, key=lambda v: tuple(int(x) for x in v.split(".")))


def update_zcode(package: dict[str, Any], config: dict[str, Any], scm_file: Path) -> Optional[Dict[str, Any]]:
    """zcode：z.ai CDN 无目录列表，官网 JS 内嵌稳定版列表 + CDN 灰度版扫描。

    抓 https://zcode.z.ai/cn 里的 releases/X.Y.Z 得稳定版最大号；当包名在
    config['check_pre_release'] 中时，再扫描 CDN 灰度先行版取最大。
    """
    try:
        response = get(ensure_public_http_url("https://zcode.z.ai/cn"), timeout=30)
        if 500 <= response.status_code <= 599:
            raise RetryableError(f"HTTP {response.status_code}")
        response.raise_for_status()
    except requests.exceptions.Timeout as e:
        raise RetryableError(f"请求超时: {e}")
    except requests.exceptions.ConnectionError as e:
        raise RetryableError(f"网络连接错误: {e}")

    versions = sorted(
        set(re.findall(r"releases/(\d+\.\d+\.\d+)", response.text)),
        key=lambda v: tuple(int(x) for x in v.split(".")),
    )
    if not versions:
        print(f"     ⚠️  官网未找到版本列表")
        return None
    latest = versions[-1]
    print(f"     z.ai 官网最新稳定版: {latest}")

    if package["name"] in config.get("check_pre_release", []):
        beta = _zcode_scan_cdn_prerelease(latest)
        if beta and tuple(int(x) for x in beta.split(".")) > tuple(
            int(x) for x in latest.split(".")
        ):
            print(f"     🔍 CDN 灰度先行版: {beta}")
            latest = beta

    if not compare_versions(package["version"], latest):
        return None
    url = (f"https://cdn-zcode.z.ai/zcode/electron/releases/"
           f"{latest}/linux-x64/ZCode-{latest}-linux-x64.deb")
    # z.ai CDN 实测 ~1MB/s，138MB 的 .deb 需要 ~145s，默认 120s 不够；
    # 与 font-misans 一致给大文件慢速 CDN 留足余量。
    new_base32 = with_retry(
        get_base32_from_guix_download, url, max_retries=2, base_delay=5,
        timeout=600,
    )
    if not new_base32 or not re.fullmatch(r"[0-9a-z]{52}", new_base32) or re.fullmatch(r"0{52}", new_base32):
        raise RetryableError("无法计算下载 hash")
    return update_package_in_file(scm_file, package, latest, new_base32)

# SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only
"""conda-forge 预编译包：文件名带不可推导的构建后缀。

ghostty-bin 从 conda-forge 取 linux-64 .conda 包，文件名形如
ghostty-<version>-h<hash>_<build>.conda：h 段是 feedstock 构建哈希，
无法由版本推导，因此包定义里的 URL 不能写成 string-append。

anaconda API 的 files 列表带精确 basename 与 build_number：按版本取最大、
同版本取 build_number 最大，再下载实际文件复算 base32（不直接采信 API
给出的 sha256，防上游在重传窗口内换字节）。
"""
import re
from pathlib import Path
from typing import Any, Dict, Optional, Tuple

import common.http as http
from common.changes import update_package_in_file
from common.hashing import get_base32_from_guix_download
from common.retry import RetryableError, with_retry
from common.versions import compare_versions

# 包名 → (anaconda owner, 包名, conda subdir)
CONDA_PACKAGES = {
    "ghostty-bin": ("conda-forge", "ghostty", "linux-64"),
}


def _version_key(version: str) -> Optional[Tuple[int, ...]]:
    if not re.fullmatch(r"\d+(?:\.\d+)*", version):
        return None
    return tuple(int(part) for part in version.split("."))


def update_conda_bin(
    package: dict[str, Any], _config: dict[str, Any], scm_file: Path
) -> Optional[Dict[str, Any]]:
    entry = CONDA_PACKAGES.get(package["name"])
    if not entry:
        raise RetryableError(f"没有为 {package['name']} 配置 conda 源")
    owner, conda_name, subdir = entry

    api_url = f"https://api.anaconda.org/package/{owner}/{conda_name}"
    response = with_retry(http.get, api_url, 30, max_retries=2, base_delay=5)
    response.raise_for_status()
    data = response.json()

    candidates = [
        f
        for f in data.get("files", [])
        if (f.get("attrs") or {}).get("subdir") == subdir
        and f.get("basename", "").endswith(".conda")
    ]
    if not candidates:
        raise RetryableError(f"anaconda 元数据里没有 {subdir} 的 .conda 资产")

    latest = max(
        candidates,
        key=lambda f: (
            _version_key(f.get("version", "")) or (),
            (f.get("attrs") or {}).get("build_number", 0),
        ),
    )
    version = latest["version"]
    basename = latest["basename"]
    print(f"     conda 最新: {basename}")

    if not compare_versions(package["version"], version):
        return None

    url = f"https://conda.anaconda.org/{owner}/{basename}"
    base32 = with_retry(
        get_base32_from_guix_download, url, max_retries=2, base_delay=5,
        timeout=300,
    )
    if not (
        base32
        and re.fullmatch(r"[0-9a-z]{52}", base32)
        and not re.fullmatch(r"0{52}", base32)
    ):
        raise RetryableError("无法计算 conda 资产 base32")

    old_url_match = re.search(r'"([^"]+\.conda)"', package["uri_expr"] or "")
    if not old_url_match:
        raise RetryableError("包定义里找不到 conda 资产 URL")
    old_url = old_url_match.group(1)

    change = update_package_in_file(scm_file, package, version, base32)
    if not change:
        return None
    change["extra_replacements"] = [(old_url, url)]
    return change

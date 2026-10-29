# SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only
"""gh 特例处理器：cli/cli 的双架构 release 资产。

gh 的 origin 用 (match ...) 按系统选资产后缀与 hash（amd64 / arm64 两个
arm）。通用 url-fetch 路径处理不了这种形态，两处都会坏：

1. construct_download_url_from_uri 把 uri 表达式里所有字符串字面量拼成
   URL，match 分支的系统名（"x86_64-linux" "amd64" ...）也被拼进去——
   2026-10-29 issue #63 实证，拼出
   gh_2.103.3_linux_x86_64-linuxamd64aarch64-linuxarm64.tar.gz → 404；
2. sha256 是 (base32 (match ...)) 而非 (base32 "...") 字面形态，解析器
   取不到旧 hash，apply 的 hash 替换被跳过——版本写进而 hash 不写进，
   构建必挂（静默损坏，比 404 更危险）。

本处理器按架构分别构造 URL、下载并计算 hash，用 extra_replacements 逐
arm 替换 sha256 match 里的旧值；任一 arm 的旧 hash 找不到就整体失败，
不写半截更新。
"""
import re
from pathlib import Path
from typing import Any, Dict, Optional

import requests

from common.changes import update_package_in_file
from common.github import get_latest_github_release
from common.hashing import get_base32_from_guix_download
from common.retry import RetryableError, with_retry
from common.versions import compare_versions, normalize_tag_to_version

# GitHub 资产架构后缀 ↔ Guix 系统名（与包定义里 match 的两个 arm 对应）。
GH_ARCHES = (("x86_64-linux", "amd64"), ("aarch64-linux", "arm64"))


def update_gh(package: dict[str, Any], _config: dict[str, Any], scm_file: Path) -> Optional[Dict[str, Any]]:
    """gh：GitHub release 稳定版 + 逐架构下载算 hash。"""
    tag = get_latest_github_release("cli/cli")
    if not tag:
        raise RetryableError("无法获取 GitHub release")
    latest = normalize_tag_to_version(tag)
    print(f"     GitHub 最新 release: {tag}")
    if not compare_versions(package["version"], latest):
        return None

    # 资产 URL 形如 .../releases/download/<tag>/gh_<ver>_linux_<arch>.tar.gz。
    hashes: Dict[str, str] = {}
    for system, arch in GH_ARCHES:
        url = (
            f"https://github.com/cli/cli/releases/download/{tag}/"
            f"gh_{latest}_linux_{arch}.tar.gz"
        )
        base32 = with_retry(
            get_base32_from_guix_download, url, max_retries=2, base_delay=5,
            timeout=300,
        )
        if not base32 or not re.fullmatch(r"[0-9a-z]{52}", base32) or re.fullmatch(r"0{52}", base32):
            raise RetryableError(f"无法计算 {arch} 资产 hash")
        hashes[system] = base32
        print(f"     ✓ {arch} hash: {base32}")

    change = update_package_in_file(
        scm_file, package, latest, hashes["x86_64-linux"]
    )
    if not change:
        return None

    # 逐 arm 替换 sha256 match 里的旧 hash（旧值从包块原文提取）。
    replacements = []
    for system, _arch in GH_ARCHES:
        old = re.search(
            rf'\("{re.escape(system)}"\s+"([0-9a-z]{{52}})"\)',
            package["content"],
        )
        if not old:
            raise RetryableError(f"包定义里找不到 {system} 的旧 hash")
        replacements.append(
            (f'("{system}" "{old.group(1)}")', f'("{system}" "{hashes[system]}")')
        )
    change["extra_replacements"] = replacements
    return change

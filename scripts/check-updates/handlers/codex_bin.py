# SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only
"""codex-bin 特例处理器：GitHub 的 rust-v* 发布线。

上游 openai/codex 的 release 资产多达 ~190 个，`releases?per_page=100`
分页接口会让 GitHub 侧超时返回 "couldn't respond in time"（2026-11-19
实测），而通用 tag_prefix 分支正是走分页扫描。这里改用单条
/releases/latest（~400 KB，稳定版指针即 rust-v* 最新），再剥 rust-v
前缀得到版本号。
"""
import re
from pathlib import Path
from typing import Any, Dict, Optional

from common.changes import update_package_in_file
from common.github import get_latest_github_release
from common.hashing import get_base32_from_guix_download
from common.retry import RetryableError, with_retry
from common.versions import compare_versions

PREFIX = "rust-v"


def update_codex_bin(package: dict[str, Any], _config: dict[str, Any], scm_file: Path) -> Optional[Dict[str, Any]]:
    tag = get_latest_github_release("openai/codex", include_pre_release=False)
    if not tag or not tag.startswith(PREFIX):
        raise RetryableError(f"最新稳定 release 不是 {PREFIX}* 系列: {tag}")
    latest = tag[len(PREFIX):]
    print(f"     最新 release: {tag} -> {latest}")
    if not compare_versions(package["version"], latest):
        return None
    url = (
        "https://github.com/openai/codex/releases/download/"
        f"{tag}/codex-x86_64-unknown-linux-musl.tar.gz"
    )
    new_base32 = with_retry(
        get_base32_from_guix_download, url, max_retries=2, base_delay=5
    )
    if (
        not new_base32
        or not re.fullmatch(r"[0-9a-z]{52}", new_base32)
        or re.fullmatch(r"0{52}", new_base32)
    ):
        raise RetryableError("无法计算下载 hash")
    print(f"     ✅ 发现新版本: {latest}")
    return update_package_in_file(scm_file, package, latest, new_base32)

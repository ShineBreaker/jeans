# SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only
"""amber-pm 特例处理器：gitee 无 tag，追踪默认分支最新 commit。"""
import re
from pathlib import Path
from typing import Any, Dict, Optional

import requests

from common.changes import build_let_git_version_change
from common.hashing import get_base32_for_git
from common.http import ensure_public_http_url, get
from common.retry import RetryableError, with_retry


def update_amber_pm(package: dict[str, Any], _config: dict[str, Any], scm_file: Path) -> Optional[Dict[str, Any]]:
    """amber-pm：gitee 仓库、无 tag，let-绑定 git-version 追踪默认分支最新 commit。

    通用逻辑只认 GitHub（extract_github_repo 对 gitee 返回 None），
    这里直接用 gitee API 取 master 分支最新 commit，复用
    build_let_git_version_change 写回 let 绑定的 commit + 自增 revision。
    """
    try:
        response = get(
            ensure_public_http_url(
                "https://gitee.com/api/v5/repos/amber-ce/amber-pm/branches/master"
            ),
            timeout=20,
        )
        if 500 <= response.status_code <= 599:
            raise RetryableError(f"HTTP {response.status_code}")
        response.raise_for_status()
    except requests.exceptions.Timeout as e:
        raise RetryableError(f"请求超时: {e}")
    except requests.exceptions.ConnectionError as e:
        raise RetryableError(f"网络连接错误: {e}")

    new_sha = response.json().get("commit", {}).get("sha")
    if not new_sha:
        raise RetryableError("gitee API 未返回 commit sha")
    current = package["let_commit"]
    print(f"     当前 commit: {current[:12]}, 最新 commit: {new_sha[:12]}")
    if new_sha == current:
        return None

    new_base32 = with_retry(
        get_base32_for_git, "https://gitee.com/amber-ce/amber-pm", new_sha,
        max_retries=2, base_delay=5,
    )
    if not new_base32 or not re.fullmatch(r"[0-9a-z]{52}", new_base32) or re.fullmatch(r"0{52}", new_base32):
        raise RetryableError("无法计算 git-fetch hash")
    return build_let_git_version_change(scm_file, package, new_sha, new_base32)

# SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only
"""GitLab tags 源：版本真值在模块级 %xxx-version 变量里。

libfprint-next / fprintd-next 的上游在 gitlab.freedesktop.org，包体写法：

  (define %libfprint-version "1.94.100")
  ...
  (version %libfprint-version)
  (commit (string-append "v" %libfprint-version))

guix refresh 的 generic-git updater 能读到上游 tag（会打印
"updating from version X to version Y..."）但无法改写 version 变量，
落盘静默为零（2026-11-20 实测）。本处理器直接改模块级 define 与包块
base32；任一替换找不到旧值即整体失败，不写半截更新。
"""
import re
from pathlib import Path
from typing import Any, Dict, Optional, Tuple

import common.http as http
from common.changes import update_package_in_file
from common.hashing import get_base32_for_git
from common.retry import RetryableError, with_retry
from common.versions import compare_versions

# 包名 → (GitLab project path, 模块级版本变量)
GITLAB_PACKAGES = {
    "libfprint-next": ("libfprint/libfprint", "%libfprint-version"),
    "fprintd-next": ("libfprint/fprintd", "%fprintd-version"),
}

_TAG_RE = re.compile(r"v(\d+(?:\.\d+)*)")


def _version_key(version: str) -> Optional[Tuple[int, ...]]:
    if not re.fullmatch(r"\d+(?:\.\d+)*", version):
        return None
    return tuple(int(part) for part in version.split("."))


def _latest_tag(project: str) -> Optional[Tuple[str, str]]:
    """返回 (tag, 纯版本号)。只认 v<数字点分> 形态的 tag。

    tags 接口按更新时间倒序返回，但同一仓库可能并行维护多个版本线
    （例如 1.94.x 与 1.95.x），按版本元组取最大值而不是取第一条。
    """
    encoded = project.replace("/", "%2F")
    url = (
        f"https://gitlab.freedesktop.org/api/v4/projects/{encoded}"
        "/repository/tags?per_page=100"
    )
    response = with_retry(http.get, url, 30, max_retries=2, base_delay=5)
    response.raise_for_status()
    best = None
    for tag in response.json():
        name = tag.get("name") or ""
        match = _TAG_RE.fullmatch(name)
        if not match:
            continue
        key = _version_key(match.group(1))
        if key is None:
            continue
        if best is None or key > best[0]:
            best = (key, name, match.group(1))
    if best is None:
        return None
    return best[1], best[2]


def update_gitlab_package(
    package: dict[str, Any], _config: dict[str, Any], scm_file: Path
) -> Optional[Dict[str, Any]]:
    entry = GITLAB_PACKAGES.get(package["name"])
    if not entry:
        raise RetryableError(f"没有为 {package['name']} 配置 GitLab 源")
    project, version_var = entry

    text = scm_file.read_text(encoding="utf-8")
    current_match = re.search(
        r"\(define\s+" + re.escape(version_var) + r'\s+"([^"]+)"', text
    )
    if not current_match:
        raise RetryableError(f"包定义里找不到 {version_var}")
    current = current_match.group(1)
    print(f"     当前 {version_var}: {current}")

    latest = _latest_tag(project)
    if latest is None:
        raise RetryableError("GitLab tags 里没有可解析的版本")
    tag, version = latest
    print(f"     最新 tag: {tag}")
    if not compare_versions(current, version):
        return None

    git_url_match = re.search(r'\(url\s+"([^"]+)"', package["uri_expr"] or "")
    if not git_url_match:
        raise RetryableError("包定义里找不到 git url")
    git_url = git_url_match.group(1)

    base32 = with_retry(
        get_base32_for_git, git_url, tag, max_retries=2, base_delay=5
    )
    if not (
        base32
        and re.fullmatch(r"[0-9a-z]{52}", base32)
        and not re.fullmatch(r"0{52}", base32)
    ):
        raise RetryableError("无法计算 git-fetch base32")

    if not package.get("base32"):
        raise RetryableError("包定义里找不到旧 base32")
    change = update_package_in_file(scm_file, package, version, base32)
    if not change:
        return None
    change["module_replacements"] = [
        (
            f'(define {version_var} "{current}")',
            f'(define {version_var} "{version}")',
        )
    ]
    return change

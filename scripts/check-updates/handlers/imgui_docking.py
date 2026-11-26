# SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only
"""imgui docking 变体处理器：上游只给部分 release 打 ``v<ver>-docking`` tag。

ocornut/imgui 对同一个提交并行发布 ``v1.93.1`` 与 ``v1.93.1-docking``，但
docking 线不保证跟住每个 release（2026-11-26 实测：``v1.93.1-docking`` 不
存在，最新是 ``v1.93.0-docking``）。guix refresh 的 GitHub updater 只认普通
tag，会把包改写成一个不存在的 docking tag，checkout 阶段直接失败（本地用
``guix refresh -u imgui-docking`` 复现：``fatal: invalid reference:
v1.93.1-docking``）。因此版本信号由本处理器单独扫 tag 列表，取最大的
``-docking`` 版本。
"""
import re
import subprocess
from pathlib import Path
from typing import Any, Dict, Optional

from common.changes import update_package_in_file
from common.hashing import get_base32_for_git
from common.retry import RetryableError

# `v1.93.0-docking` / `v1.92.9b-docking`；imgui 的 patch 号可能带字母后缀。
TAG_RE = re.compile(r"^v(.+)-docking$")


def _version_key(version: str) -> tuple:
    """把 ``1.92.9b`` 这类版本转成可比较的 key（数字段按数值，字母段按字典序）。"""
    return tuple(
        (0, int(part)) if part.isdigit() else (1, part)
        for part in re.findall(r"\d+|[a-z]+", version)
    )


def update_imgui_docking(
    package: dict[str, Any], _config: dict[str, Any], scm_file: Path
) -> Optional[Dict[str, Any]]:
    """扫上游 tag 取最大 ``-docking`` 版本，重钉 version 与 base32。"""
    url = package.get("git_url")
    if not url:
        raise RetryableError("无法从包定义提取上游 URL")

    try:
        result = subprocess.run(
            ["git", "ls-remote", "--tags", "--refs", url],
            capture_output=True,
            text=True,
            timeout=120,
        )
    except subprocess.TimeoutExpired as e:
        raise RetryableError(f"git ls-remote 超时: {e}")
    if result.returncode != 0:
        raise RetryableError(f"git ls-remote 失败: {result.stderr.strip()}")

    candidates = []
    for line in result.stdout.splitlines():
        ref = line.split("\t")[-1]
        match = TAG_RE.match(ref[len("refs/tags/"):]) if ref.startswith("refs/tags/") else None
        if match:
            candidates.append((_version_key(match.group(1)), match.group(1)))
    if not candidates:
        raise RetryableError("上游没有任何 -docking tag")

    latest = max(candidates)[1]
    print(f"     最新 docking tag: v{latest}-docking")
    if latest == package["version"]:
        print("     ✓ 已是最新")
        return None

    base32 = get_base32_for_git(url, f"v{latest}-docking")
    if (
        not base32
        or not re.fullmatch(r"[0-9a-z]{52}", base32)
        or re.fullmatch(r"0{52}", base32)
    ):
        raise RetryableError("无法计算 docking tag 的 base32")

    print(f"     ✅ 发现新版本: {latest}")
    return update_package_in_file(scm_file, package, latest, base32)

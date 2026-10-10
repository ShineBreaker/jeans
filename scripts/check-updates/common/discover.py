# SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only
"""共享 release/tag 发现流程（共享变量分支与 version-commit 分支共用）。

提取自 update_versions.py main() 内两段同构流程：共享变量分支与
is_version_ref 分支（成功后一个调 build_shared_source_change、
一个调 update_package_in_file，落盘留在调用方）。
"""
import re
from dataclasses import dataclass
from typing import Optional

from common.github import (
    get_latest_github_release,
    get_latest_github_tag,
    get_tag_commit_sha,
)
from common.hashing import get_base32_for_git
from common.retry import with_retry
from common.versions import compare_versions, normalize_tag_to_version


@dataclass
class ReleaseCandidate:
    tag: str            # 原始 tag（含前缀）
    version: str        # normalize 后的纯版本号
    base32: str         # get_base32_for_git(tag) 结果
    peel_sha: Optional[str]  # resolve_peel=True 时为 tag peel commit，否则 None


def discover_release_update(
    repo: str, git_url: str, current_version: str,
    *, include_pre_release: bool = False,
    tag_prefix: Optional[str] = None,
    resolve_peel: bool = False,
) -> tuple[str, Optional[ReleaseCandidate], str]:
    try:
        latest_release = with_retry(
            get_latest_github_release,
            repo,
            include_pre_release,
            tag_prefix,
            max_retries=2,
            base_delay=5,
        )
    except Exception as e:
        print(f"     ⚠️  无法获取最新版本信息: {e}")
        return ("failed", None, f"无法获取最新版本信息: {e}")
    if not latest_release:
        print(f"     ℹ️  无 release，尝试获取最新 tag...")
        try:
            latest_release = with_retry(
                get_latest_github_tag,
                repo,
                tag_prefix,
                max_retries=2,
                base_delay=5,
            )
        except Exception as e:
            print(f"     ⚠️  无法获取最新 tag: {e}")
            return ("failed", None, f"无法获取最新 tag: {e}")
    if not latest_release:
        print(f"     ⚠️  无法获取最新版本信息")
        return ("failed", None, "无法获取最新版本信息")
    print(f"     最新版本: {latest_release}")
    normalized_version = normalize_tag_to_version(latest_release, tag_prefix)
    if not compare_versions(current_version, normalized_version):
        print(f"     ✓ 版本已是最新")
        return ("uptodate", None, "")
    print(f"     ✅ 发现新版本: {latest_release}")
    peel_sha: Optional[str] = None
    if resolve_peel:
        try:
            peel_sha = with_retry(
                get_tag_commit_sha,
                git_url,
                latest_release,
                max_retries=2,
                base_delay=5,
            )
        except Exception as e:
            peel_sha = None
            print(f"     ⚠️  无法获取 tag commit: {e}")
        if not peel_sha:
            print(f"     ❌ 无法获取 tag peel commit，已标记为失败并跳过更新")
            return ("failed", None, "无法获取 tag commit")
    try:
        new_base32 = with_retry(
            get_base32_for_git,
            git_url,
            latest_release,
            max_retries=2,
            base_delay=5,
        )
    except Exception as e:
        new_base32 = None
        if resolve_peel:
            # 共享变量分支旧行为：异常时打一行 ⚠️；is_version_ref
            # 分支旧行为无此行（直接落裸错误串），故按分支 gate。
            print(f"     ⚠️  无法计算 hash: {e}")
    if not (new_base32 and re.fullmatch(r"[0-9a-z]{52}", new_base32)
            and not re.fullmatch(r"0{52}", new_base32)):
        print(f"     ❌ 无法计算 git-fetch base32，已标记为失败并跳过更新")
        return ("failed", None, "无法计算 hash")
    print(f"     ✓ 计算得到 base32: {new_base32}")
    return ("candidate", ReleaseCandidate(
        tag=latest_release,
        version=normalized_version,
        base32=new_base32,
        peel_sha=peel_sha,
    ), "")

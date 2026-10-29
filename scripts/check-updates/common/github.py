# SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only

"""GitHub API I/O：token 获取与 release/tag/commit 查询。"""

import os
import re
import subprocess
from typing import Optional, Tuple

import requests

import common.http as http
from common.retry import RetryableError, is_retryable_command_failure, is_retryable_http_error


# GitHub API配置


def get_github_token() -> Optional[str]:
    """取 GitHub token：先读 GITHUB_TOKEN 环境变量，没有则回退到 gh CLI 登录凭证。"""
    token = os.environ.get("GITHUB_TOKEN")  # 可选，用于提高API限制
    if token:
        return token
    # 本地 blue upgrade 不会注入 token，匿名配额（60 次/小时）会被几十个包
    # 的轮询瞬间耗尽（403 rate limit）。回退到 gh CLI 的登录凭证；
    # CI 里 GITHUB_TOKEN 已设置，不会走到这里。
    try:
        _gh = subprocess.run(
            ["gh", "auth", "token"], capture_output=True, text=True, timeout=10,
        )
        if _gh.returncode == 0 and _gh.stdout.strip():
            return _gh.stdout.strip()
    except Exception:
        pass
    return None


# import 时求值一次，保持原顶层语义
GITHUB_TOKEN = get_github_token()


def get_latest_github_release(
    repo: str, include_pre_release: bool = False, tag_prefix: Optional[str] = None
) -> Optional[str]:
    """获取GitHub仓库的最新release版本

    Args:
        repo: GitHub仓库路径 (owner/repo)
        include_pre_release: 是否包含pre-release版本
        tag_prefix: 可选的 tag 前缀。当同一 repo 有多个 release 系列
            （如 v* 和 desktop-v*）时，只返回以此前缀开头的最新 tag。

    Returns:
        最新版本的tag名称，如果获取失败则返回None
    """
    if not re.fullmatch(r"[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+", repo):
        return None
    headers = {}
    if GITHUB_TOKEN:
        headers["Authorization"] = f"token {GITHUB_TOKEN}"

    try:
        # tag_prefix 模式：用列表 API 找匹配前缀的最新（非预）发布。
        # 必须分页扫全列表：固定窗口会被同仓库其他系列的 release 挤爆——
        # trycua/cua 2026-10-29 实证，稳定版 cua-driver-rs-v0.38.0 已排在
        # release 列表第 32 位，per_page=30 够不到，误报
        # "无法获取最新release信息"（issue #63）。
        if tag_prefix:
            page = 1
            while page <= 10:
                response = http.github_api_get(
                    repo, f"releases?per_page=100&page={page}", headers
                )
                if 500 <= response.status_code <= 599:
                    raise RetryableError(f"GitHub API 服务器错误: {response.status_code}")
                response.raise_for_status()
                releases = response.json()
                for rel in releases:
                    tag_name = rel.get("tag_name") or ""
                    if not tag_name.startswith(tag_prefix):
                        continue
                    if rel.get("prerelease", False) and not include_pre_release:
                        continue
                    return tag_name
                if len(releases) < 100:
                    break
                page += 1
            return None

        # 首先尝试获取最新的稳定版release。
        # 注意：仓库只有 pre-release 时，GitHub 的 /releases/latest 会返回
        # 404（如 inso 上游只发 prerelease）。include_pre_release 模式下
        # 本就不需要 latest 端点，直接走 /releases 列表。
        if not include_pre_release:
            response = http.github_api_get(repo, "releases/latest", headers)
            if 500 <= response.status_code <= 599:
                raise RetryableError(f"GitHub API 服务器错误: {response.status_code}")
            response.raise_for_status()
            data = response.json()
            return data.get("tag_name")

        # 如果需要检查pre-release，获取所有release并找到最新的（包括pre-release）
        response_all = http.github_api_get(repo, "releases", headers)
        if 500 <= response_all.status_code <= 599:
            raise RetryableError(f"GitHub API 服务器错误: {response_all.status_code}")
        response_all.raise_for_status()
        releases = response_all.json()

        if not releases:
            return None

        # 获取最新的release（可能是pre-release）
        latest_all = releases[0].get("tag_name")

        # 如果最新的包含pre-release，返回它
        if releases[0].get("prerelease", False):
            print(f"     ℹ️  最新版本是pre-release: {latest_all}")

        return latest_all
    except requests.exceptions.HTTPError as e:
        if is_retryable_http_error(e):
            raise
        print(f"  ⚠️  无法获取GitHub release: {e}")
        return None
    except requests.exceptions.Timeout as e:
        raise RetryableError(f"请求超时: {e}")
    except requests.exceptions.ConnectionError as e:
        raise RetryableError(f"网络连接错误: {e}")
    except requests.exceptions.RequestException as e:
        raise RetryableError(f"网络错误: {e}")


def get_latest_github_tag(repo: str, tag_prefix: Optional[str] = None) -> Optional[str]:
    """获取GitHub仓库的最新tag（当没有release时的备用方案）"""
    if not re.fullmatch(r"[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+", repo):
        return None
    headers = {}
    if GITHUB_TOKEN:
        headers["Authorization"] = f"token {GITHUB_TOKEN}"

    try:
        response = http.github_api_get(repo, "tags", headers)
        if 500 <= response.status_code <= 599:
            raise RetryableError(f"GitHub API 服务器错误: {response.status_code}")
        response.raise_for_status()
        tags = response.json()
        for tag in tags:
            name = tag.get("name") or ""
            if tag_prefix and not name.startswith(tag_prefix):
                continue
            return name
        return None
    except requests.exceptions.HTTPError as e:
        if is_retryable_http_error(e):
            raise
        return None
    except requests.exceptions.Timeout as e:
        raise RetryableError(f"请求超时: {e}")
    except requests.exceptions.ConnectionError as e:
        raise RetryableError(f"网络连接错误: {e}")
    except requests.exceptions.RequestException as e:
        raise RetryableError(f"网络错误: {e}")


def get_latest_commit(repo: str, branch: Optional[str] = None) -> Optional[Tuple[str, str]]:
    """获取GitHub仓库指定分支的最新commit（不指定则用默认分支）

    Returns:
        (commit_sha, date_str) 或 None。date_str 格式为 YYYY-MM-DD。
    """
    if not re.fullmatch(r"[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+", repo):
        return None
    headers = {}
    if GITHUB_TOKEN:
        headers["Authorization"] = f"token {GITHUB_TOKEN}"

    path = "commits"
    if branch:
        if not re.fullmatch(r"[A-Za-z0-9._/-]+", branch):
            return None
        path = f"commits?sha={branch}"

    try:
        response = http.github_api_get(repo, path, headers)
        if 500 <= response.status_code <= 599:
            raise RetryableError(f"GitHub API 服务器错误: {response.status_code}")
        response.raise_for_status()
        commits = response.json()
        if not commits:
            return None

        latest = commits[0]
        sha = latest["sha"]
        # 优先用 committer date（实际提交时间）
        date_str = latest["commit"]["committer"]["date"][:10]  # "2025-10-18T..."
        return (sha, date_str)
    except requests.exceptions.HTTPError as e:
        if is_retryable_http_error(e):
            raise
        print(f"     ⚠️  无法获取最新 commit: {e}")
        return None
    except requests.exceptions.Timeout as e:
        raise RetryableError(f"请求超时: {e}")
    except requests.exceptions.ConnectionError as e:
        raise RetryableError(f"网络连接错误: {e}")
    except requests.exceptions.RequestException as e:
        raise RetryableError(f"网络错误: {e}")
    except KeyError as e:
        print(f"     ⚠️  无法获取最新 commit: {e}")
        return None


def get_tag_commit_sha(url: str, tag: str) -> Optional[str]:
    """取 tag peel 后的 commit sha（annotated tag 取 ^{} 行，否则取 tag 本行）。

    供共享变量结构落盘：%xxx-commit 定义里写的是 peel sha，不是 tag 名。
    网络/超时失败抛 RetryableError；tag 不存在返回 None。
    """
    if not re.fullmatch(r"[A-Za-z0-9._/+~-]+", tag):
        return None
    try:
        result = subprocess.run(
            # ls-remote 精确匹配单个 tag 名时不输出 ^{} peel 行，必须同时
            # 传 <tag>^{}，否则 annotated tag 只能拿到 tag 对象 sha。
            ["git", "ls-remote", url, tag, tag + "^{}"],
            capture_output=True,
            text=True,
            timeout=60,
        )
    except subprocess.TimeoutExpired as e:
        cmd = " ".join(e.cmd) if isinstance(e.cmd, list) else str(e.cmd)
        raise RetryableError(f"命令超时: {cmd}")
    if result.returncode != 0:
        err = result.stderr.strip()
        if is_retryable_command_failure(err):
            raise RetryableError(f"git ls-remote 失败: {err}")
        print(f"     ⚠️  git ls-remote 失败: {err}")
        return None
    fallback = None
    for line in result.stdout.splitlines():
        sha, _, ref = line.partition("\t")
        if not re.fullmatch(r"[0-9a-f]{40}", sha):
            continue
        if ref.endswith("^{}"):
            return sha
        if "refs/tags/" in ref and fallback is None:
            fallback = sha
    return fallback

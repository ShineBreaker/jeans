# SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only

"""CI 失败报告 Issue 创建。"""

import os
from typing import Any, Dict, List, Optional

import requests

import common.http as http
from common.retry import RetryableError, with_retry


def _build_issue_body(failed_packages: List[Dict[str, Any]]) -> str:
    """从失败包列表生成 Markdown 表格。"""
    lines = [
        "| 包名 | 旧版本 | 新版本 | 失败原因 |",
        "| --- | --- | --- | --- |",
    ]
    for pkg in failed_packages:
        name = pkg.get("name", "?")
        old_v = pkg.get("old_version", "?")
        new_v = pkg.get("new_version", "?")
        error = pkg.get("error", "未知")
        lines.append(f"| {name} | {old_v} | {new_v} | {error} |")
    return "\n".join(lines)


def _issue_exists(
    issues_url: str, title: str, headers: Dict[str, str], params: Optional[Dict[str, Any]] = None
) -> bool:
    """检查是否已有同名 open Issue（按日期去重）。"""
    try:
        resp = http.get(
            issues_url,
            headers=headers,
            params=params or {},
            timeout=15,
        )
        resp.raise_for_status()
        for issue in resp.json():
            if issue.get("title", "") == title:
                return True
    except Exception as e:
        print(f"     ⚠️  搜索已有 Issue 失败: {e}")
    return False


def _do_create_issue(
    issues_url: str, headers: Dict[str, str], title: str, body: str
) -> requests.Response:
    """实际执行 POST 创建 Issue（被 with_retry 包装）。"""
    resp = http.post(
        issues_url,
        headers=headers,
        json={"title": title, "body": body},
        timeout=15,
    )
    if 500 <= resp.status_code <= 599:
        raise RetryableError(f"Issue API 服务器错误: {resp.status_code}")
    resp.raise_for_status()
    return resp


def create_github_issue(title: str, body: str) -> None:
    """当处于 GitHub CI 环境时，在 GitHub 上创建 Issue。"""
    token = os.environ.get("GITHUB_TOKEN")
    repo = os.environ.get("GITHUB_REPOSITORY")

    if not token:
        print("⚠️  GITHUB_TOKEN 未设置，跳过 GitHub Issue 创建")
        return
    if not repo:
        print("⚠️  GITHUB_REPOSITORY 未设置，跳过 GitHub Issue 创建")
        return

    issues_url = f"https://api.github.com/repos/{repo}/issues"
    headers = {
        "Authorization": f"Bearer {token}",
        "Accept": "application/vnd.github+json",
        "X-GitHub-Api-Version": "2022-11-28",
    }

    if _issue_exists(issues_url, title, headers, params={"state": "open", "per_page": 50}):
        print(f"ℹ️ GitHub Issue 已存在，跳过创建: {title}")
        return

    try:
        resp = with_retry(
            _do_create_issue,
            issues_url,
            headers,
            title,
            body,
            max_retries=2,
            base_delay=5,
        )
        issue_url = resp.json().get("html_url", "?")
        print(f"✅ 已创建 GitHub Issue: {issue_url}")
    except Exception as e:
        print(f"⚠️  创建 GitHub Issue 失败: {e}")


def create_codeberg_issue(title: str, body: str) -> None:
    """当处于 Forgejo CI 环境时，在 Codeberg 上创建 Issue。"""
    token = os.environ.get("FORGEJO_TOKEN")
    repo = os.environ.get("FORGEJO_REPOSITORY") or os.environ.get("GITHUB_REPOSITORY")

    if not token:
        print("⚠️  FORGEJO_TOKEN 未设置，跳过 Issue 创建")
        return
    if not repo:
        print("⚠️  FORGEJO_REPOSITORY / GITHUB_REPOSITORY 未设置，跳过 Issue 创建")
        return

    issues_url = f"https://codeberg.org/api/v1/repos/{repo}/issues"
    headers = {
        "Authorization": f"token {token}",
        "Content-Type": "application/json",
    }

    # 去重：同日期标题已存在则跳过
    if _issue_exists(issues_url, title, headers, params={"state": "open", "type": "issue", "limit": 50}):
        print(f"ℹ️ Issue 已存在，跳过创建: {title}")
        return

    try:
        resp = with_retry(
            _do_create_issue,
            issues_url,
            headers,
            title,
            body,
            max_retries=2,
            base_delay=5,
        )
        issue_url = resp.json().get("html_url", "?")
        print(f"✅ 已创建 Codeberg Issue: {issue_url}")
    except Exception as e:
        print(f"⚠️  创建 Codeberg Issue 失败: {e}")


def create_ci_issue(title: str, body: str, _config: dict[str, Any]) -> None:
    """根据当前 CI 平台创建失败报告 Issue。"""
    if not os.environ.get("CI"):
        print("ℹ️ 非 CI 环境，跳过 Issue 创建")
        return

    if os.environ.get("GITHUB_ACTIONS"):
        create_github_issue(title, body)
        return

    create_codeberg_issue(title, body)

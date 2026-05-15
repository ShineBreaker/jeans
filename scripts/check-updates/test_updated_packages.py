#!/usr/bin/env python3
"""
Build updated non-binary Guix packages after an auto-update run.

If any build fails in GitHub Actions, create a deduplicated GitHub issue
and exit non-zero so the update does not get committed.
"""

import hashlib
import json
import os
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, List, Optional

import requests

REPORT_FILE = Path(__file__).parent / "report.json"
BUILD_REPORT_FILE = Path(__file__).parent / "build-report.json"


def load_report(path: Path) -> Dict[str, Any]:
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def select_updated_nonbinary_packages(report: Dict[str, Any]) -> List[Dict[str, Any]]:
    packages = report.get("packages", [])
    return [
        pkg
        for pkg in packages
        if pkg.get("status") == "updated" and not str(pkg.get("name", "")).endswith("-bin")
    ]


def summarize_output(stdout: str, stderr: str, limit_lines: int = 80, limit_chars: int = 6000) -> str:
    text = "\n".join(part for part in [stderr.strip(), stdout.strip()] if part).strip()
    if not text:
        return "(no output)"
    lines = text.splitlines()
    if len(lines) > limit_lines:
        lines = lines[-limit_lines:]
    text = "\n".join(lines)
    if len(text) > limit_chars:
        text = text[-limit_chars:]
    return text


def build_package(package_name: str) -> Dict[str, Any]:
    result = subprocess.run(
        ["guix", "build", "-L", "modules", package_name],
        capture_output=True,
        text=True,
    )
    output = summarize_output(result.stdout, result.stderr)
    return {
        "name": package_name,
        "returncode": result.returncode,
        "success": result.returncode == 0,
        "summary": output.splitlines()[-1] if output and output != "(no output)" else output,
        "output": output,
    }


def issue_exists(issues_url: str, title: str, headers: Dict[str, str]) -> bool:
    resp = requests.get(
        issues_url,
        headers=headers,
        params={"state": "open", "per_page": 50},
        timeout=15,
    )
    resp.raise_for_status()
    for issue in resp.json():
        if issue.get("title", "") == title:
            return True
    return False


def build_issue_body(failures: List[Dict[str, Any]], tested_packages: List[Dict[str, Any]]) -> str:
    repo = os.environ.get("GITHUB_REPOSITORY", "?")
    sha = os.environ.get("GITHUB_SHA", "?")
    run_id = os.environ.get("GITHUB_RUN_ID", "")
    server_url = os.environ.get("GITHUB_SERVER_URL", "https://github.com")
    run_url = f"{server_url}/{repo}/actions/runs/{run_id}" if run_id else ""

    lines = [
        f"Repository: `{repo}`",
        f"Base commit: `{sha}`",
        f"Checked at: `{datetime.now(timezone.utc).isoformat(timespec='seconds')}`",
    ]
    if run_url:
        lines.append(f"Workflow run: {run_url}")
    lines.append("")
    lines.append("Updated non-binary packages tested:")
    for pkg in tested_packages:
        lines.append(f"- `{pkg['name']}` ({pkg.get('old_version', '?')} -> {pkg.get('new_version', '?')})")
    lines.append("")
    lines.append("Failures:")
    lines.append("")
    lines.append("| Package | Old Version | New Version | Summary |")
    lines.append("| --- | --- | --- | --- |")
    for failure in failures:
        lines.append(
            f"| {failure['name']} | {failure.get('old_version', '?')} | {failure.get('new_version', '?')} | {failure.get('summary', 'build failed')} |"
        )
    for failure in failures:
        lines.append("")
        lines.append(f"### `{failure['name']}`")
        lines.append("")
        lines.append("```text")
        lines.append(failure.get("output", "(no output)"))
        lines.append("```")
    return "\n".join(lines)


def create_github_issue(title: str, body: str) -> None:
    token = os.environ.get("GITHUB_TOKEN")
    repo = os.environ.get("GITHUB_REPOSITORY")

    if not token or not repo or not os.environ.get("GITHUB_ACTIONS"):
        print("ℹ️  非 GitHub Actions 环境或缺少 GITHUB_TOKEN，跳过 Issue 创建")
        return

    issues_url = f"https://api.github.com/repos/{repo}/issues"
    headers = {
        "Authorization": f"Bearer {token}",
        "Accept": "application/vnd.github+json",
        "X-GitHub-Api-Version": "2022-11-28",
    }

    if issue_exists(issues_url, title, headers):
        print(f"ℹ️  GitHub Issue 已存在，跳过创建: {title}")
        return

    resp = requests.post(
        issues_url,
        headers=headers,
        json={"title": title, "body": body},
        timeout=15,
    )
    resp.raise_for_status()
    print(f"✅ 已创建 GitHub Issue: {resp.json().get('html_url', '?')}")


def main() -> int:
    if not REPORT_FILE.exists():
        print(f"❌ 未找到更新报告: {REPORT_FILE}")
        return 2

    report = load_report(REPORT_FILE)
    packages = select_updated_nonbinary_packages(report)
    build_report: Dict[str, Any] = {
        "timestamp": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "tested_count": len(packages),
        "failed_count": 0,
        "packages": [],
    }

    if not packages:
        print("ℹ️  本次没有更新到需要构建测试的非 binary 包")
        with open(BUILD_REPORT_FILE, "w", encoding="utf-8") as f:
            json.dump(build_report, f, ensure_ascii=False, indent=2)
        return 0

    print(f"🔨 将测试 {len(packages)} 个更新过的非 binary 包")
    failures: List[Dict[str, Any]] = []

    for pkg in packages:
        name = pkg["name"]
        print(f"\n📦 构建测试: {name}")
        result = build_package(name)
        enriched = {**pkg, **result}
        build_report["packages"].append(enriched)
        if result["success"]:
            print(f"   ✓ 构建成功: {name}")
        else:
            print(f"   ❌ 构建失败: {name}")
            failures.append(enriched)

    build_report["failed_count"] = len(failures)
    with open(BUILD_REPORT_FILE, "w", encoding="utf-8") as f:
        json.dump(build_report, f, ensure_ascii=False, indent=2)

    if not failures:
        return 0

    signature = hashlib.sha1(
        "\n".join(sorted(failure["name"] for failure in failures)).encode("utf-8")
    ).hexdigest()[:8]
    title = f"❌ Updated package build failures — {signature}"
    body = build_issue_body(failures, packages)
    try:
        create_github_issue(title, body)
    except Exception as e:
        print(f"⚠️  创建 GitHub Issue 失败: {e}")

    return 1


if __name__ == "__main__":
    sys.exit(main())

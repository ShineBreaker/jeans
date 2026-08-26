#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only
#
"""
Build all updated Guix packages after an auto-update run.

Runs in the same CI job as the updater, before commit/push.
If any build fails, exits non-zero to block the commit and
creates a deduplicated GitHub issue for notification.
"""

import hashlib
import json
import os
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, List

import requests

REPORT_FILE = Path(__file__).parent / "report.json"
REFRESH_UPDATES_FILE = Path(__file__).parent / "refresh-updates.json"
BUILD_REPORT_FILE = Path(os.path.realpath(Path(__file__).parent / "build-report.json"))


def load_report(path: Path) -> Dict[str, Any]:
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def select_updated_packages(report: Dict[str, Any]) -> List[Dict[str, Any]]:
    packages = report.get("packages", [])
    return [pkg for pkg in packages if pkg.get("status") == "updated"]


def load_refresh_updates() -> List[Dict[str, Any]]:
    """读取 guix refresh 步骤产出的更新包列表（refresh-updates.json）。

    refresh-updates.json 由 CI 的 refresh-changed-packages.sh 从 git diff
    提取，记录被 guix refresh 改写的包名。这些包不在 Python updater 的
    report.json 里，需要合并进构建测试集合。
    """
    if not REFRESH_UPDATES_FILE.exists():
        return []
    try:
        with open(REFRESH_UPDATES_FILE, "r", encoding="utf-8") as f:
            data = json.load(f)
    except (json.JSONDecodeError, OSError) as e:
        print(f"⚠️  读取 refresh-updates.json 失败: {e}")
        return []
    return [
        {
            "name": name,
            "status": "updated",
            "old_version": "(refresh)",
            "new_version": "(refresh)",
            "source": "refresh",
        }
        for name in data.get("packages", [])
    ]


def merge_updated_packages(
    python_packages: List[Dict[str, Any]],
    refresh_packages: List[Dict[str, Any]],
) -> List[Dict[str, Any]]:
    """合并 Python updater 和 guix refresh 两个来源的更新集合（按包名去重）。

    Python updater 的结果优先（含具体版本信息），refresh 只补 Python 未覆盖的包。
    """
    merged = list(python_packages)
    seen = {pkg["name"] for pkg in merged}
    for pkg in refresh_packages:
        if pkg["name"] not in seen:
            merged.append(pkg)
    return merged


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
    cmd = ["guix", "build", "-L", "modules"]
    extra_load_path = os.environ.get("GUIX_EXTRA_LOAD_PATH", "")
    for path in extra_load_path.split(":") if extra_load_path else []:
        if path:
            cmd.extend(["-L", path])
    cmd.append(package_name)
    result = subprocess.run(cmd, capture_output=True, text=True)
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
    lines.append("Updated packages tested:")
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
    # 手动模式（--packages a,b）：跳过更新报告合并，直接构建指定包。
    # 用于 workflow_dispatch 触发的按需构建验证；失败不开 issue，
    # 结果只进 build-report.json artifact。
    manual: List[str] = []
    if len(sys.argv) == 3 and sys.argv[1] == "--packages":
        manual = [p.strip() for p in sys.argv[2].split(",") if p.strip()]

    if manual:
        packages = [
            {"name": name, "old_version": "(manual)", "new_version": "(manual)"}
            for name in manual
        ]
    else:
        if not REPORT_FILE.exists():
            print(f"❌ 未找到更新报告: {REPORT_FILE}")
            return 2

        report = load_report(REPORT_FILE)
        python_updated = select_updated_packages(report)
        refresh_updated = load_refresh_updates()
        packages = merge_updated_packages(python_updated, refresh_updated)
        if refresh_updated:
            print(f"📋 合并更新来源: Python updater {len(python_updated)} 个 + guix refresh {len(refresh_updated)} 个")

    build_report: Dict[str, Any] = {
        "timestamp": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "tested_count": len(packages),
        "failed_count": 0,
        "packages": [],
    }

    if not packages:
        print("ℹ️  本次没有更新到需要构建测试的包")
        BUILD_REPORT_FILE.write_text(
            json.dumps(build_report, ensure_ascii=False, indent=2), encoding="utf-8"
        )
        return 0

    print(f"🔨 将测试 {len(packages)} 个更新过的包")
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
    BUILD_REPORT_FILE.write_text(
        json.dumps(build_report, ensure_ascii=False, indent=2), encoding="utf-8"
    )

    if not failures:
        return 0

    signature = hashlib.sha256(
        "\n".join(sorted(failure["name"] for failure in failures)).encode("utf-8")
    ).hexdigest()[:8]
    title = f"❌ Updated package build failures — {signature}"
    body = build_issue_body(failures, packages)
    if manual:
        print("ℹ️  手动模式：跳过 Issue 创建，结果见 build-report artifact")
    else:
        try:
            create_github_issue(title, body)
        except Exception as e:
            print(f"⚠️  创建 GitHub Issue 失败: {e}")

    return 1


if __name__ == "__main__":
    sys.exit(main())

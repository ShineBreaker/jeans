#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only
#
"""
Build all updated Guix packages after an auto-update run.

Runs in the same CI job as the updater, before commit/push.
If any build fails, exits non-zero to block the commit and
creates a deduplicated GitHub issue for notification.

构建成功后还会对产物做 ldd 级 NEEDED 检查：上游重构可能给 ELF
新增 NEEDED（magpie-bin 0.1.1167 新增 libfontconfig 实证），
构建期不报错、运行时直接拒启。
"""

import hashlib
import json
import os
import re
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

import requests


sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from common.paths import BUILD_REPORT_FILE, REFRESH_UPDATES_FILE, REPORT_FILE


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


REPO_ROOT = Path(__file__).resolve().parents[3]


def build_package(package_name: str) -> Dict[str, Any]:
    # -L 锚到 __file__ 而非 CWD：从其他目录运行时相对 -L 会静默落空，
    # 退化到已装频道快照，测到错误的包版本。
    cmd = ["guix", "build", "-L", str(REPO_ROOT / "modules")]
    extra_load_path = os.environ.get("GUIX_EXTRA_LOAD_PATH", "")
    for path in extra_load_path.split(":") if extra_load_path else []:
        if path:
            cmd.extend(["-L", path])
    cmd.append(package_name)
    result = subprocess.run(cmd, capture_output=True, text=True)
    output = summarize_output(result.stdout, result.stderr)
    store_outputs = [
        line.strip() for line in result.stdout.splitlines()
        if line.strip().startswith("/gnu/store/")
    ]
    return {
        "name": package_name,
        "returncode": result.returncode,
        "success": result.returncode == 0,
        "summary": output.splitlines()[-1] if output and output != "(no output)" else output,
        "output": output,
        "outputs": store_outputs,
    }


# ---- ELF NEEDED 检查（ld.so --list）----
#
# 预编译包的依赖清单随上游构建漂移：版本升级后 NEEDED 可能增删，
# 而构建期只验证 hash 与解包，不验证库解析。本检查对每个带
# PT_INTERP 的 ELF 执行 `ld.so --list`：
# - patchelf 过的二进制：用自身 interpreter（store 路径），依赖其
#   自带 RUNPATH 解析；
# - 未 patch 的二进制（ld-linux wrapper）：用 wrapper 脚本 exec 行里
#   的 store ld.so，并带上脚本声明的 --library-path 目录；
# - env wrapper（LD_LIBRARY_PATH 导出）：提取其中的 store 目录一起
#   作为 --library-path 候选。
# 直接 NEEDED 缺失报 stderr "error while loading shared libraries"；
# 传递依赖缺失报 stdout "=> not found" 行——两者命中即判失败。
# interp 既非有效 store 路径、产物里又没有 wrapper ld.so 的（如靠
# 系统 nix-ld 的自定位包）记为 skipped，不阻塞但留痕于报告。

LD_SO_RE = re.compile(r"(/gnu/store/[a-z0-9]{32}[^\s'\"]*ld-linux[^\s'\"]*)")
LIB_DIRS_RE = re.compile(r"--library-path[=\s]+['\"]?([^'\"\s]+)")
STORE_DIR_RE = re.compile(r"/gnu/store/[a-z0-9]{32}[^\"'\s$:}]*")


def _is_elf(path: Path) -> bool:
    try:
        with open(path, "rb") as f:
            return f.read(4) == b"\x7fELF"
    except OSError:
        return False


def _elf_interp(path: Path) -> Optional[str]:
    """返回 64-bit LE ELF 的 PT_INTERP 字符串；非 ELF/32 位/无 interp 返回 None。"""
    try:
        with open(path, "rb") as f:
            hdr = f.read(64)
            if (len(hdr) < 64 or hdr[:4] != b"\x7fELF"
                    or hdr[4] != 2 or hdr[5] != 1):
                return None
            phoff = int.from_bytes(hdr[0x20:0x28], "little")
            phentsize = int.from_bytes(hdr[0x36:0x38], "little")
            phnum = int.from_bytes(hdr[0x38:0x3A], "little")
            f.seek(phoff)
            phdrs = f.read(phentsize * phnum)
            for i in range(phnum):
                off = i * phentsize
                if int.from_bytes(phdrs[off:off + 4], "little") != 3:  # PT_INTERP
                    continue
                p_offset = int.from_bytes(phdrs[off + 8:off + 16], "little")
                p_filesz = int.from_bytes(phdrs[off + 0x20:off + 0x28], "little")
                f.seek(p_offset)
                return f.read(p_filesz).rstrip(b"\0").decode("utf-8", "replace")
    except (OSError, IndexError):
        return None
    return None


def _scan_wrapper_scripts(output: Path) -> Tuple[List[str], List[str]]:
    """扫描产物里的 shebang 脚本，返回 (ld.so 路径列表, 库目录并集)。

    库目录两个来源：ld.so 的 --library-path 参数（ld-linux wrapper），
    以及 wrap-program 生成的 LD_LIBRARY_PATH 导出（electron/Tauri 等
    patchelf + env wrapper）。并集做候选路径，与运行时解析语义一致。
    """
    ldsos: List[str] = []
    lib_dirs: List[str] = []
    for path in output.rglob("*"):
        if not path.is_file() or path.is_symlink():
            continue
        try:
            with open(path, "rb") as f:
                if f.read(2) != b"#!":
                    continue
                text = f.read(65536).decode("utf-8", "replace")
        except OSError:
            continue
        m = LD_SO_RE.search(text)
        if m:
            ldsos.append(m.group(1))
        for m in LIB_DIRS_RE.finditer(text):
            lib_dirs.extend(d for d in m.group(1).split(":") if d)
        for line in text.splitlines():
            if "LD_LIBRARY_PATH" in line:
                lib_dirs.extend(STORE_DIR_RE.findall(line))
    return list(dict.fromkeys(ldsos)), list(dict.fromkeys(lib_dirs))


def check_elf_dependencies(output_paths: List[str]) -> Dict[str, Any]:
    """对每个带 PT_INTERP 的 ELF 跑 `ld.so --list`，not found 即失败。"""
    missing: List[str] = []
    skipped: List[str] = []
    checked = 0
    for out in output_paths:
        root = Path(out)
        if not root.is_dir():
            continue
        ldsos, lib_dirs = _scan_wrapper_scripts(root)
        for elf in sorted(root.rglob("*")):
            if not elf.is_file() or elf.is_symlink() or not _is_elf(elf):
                continue
            interp = _elf_interp(elf)
            if interp is None:
                continue
            if interp.startswith("/gnu/store/") and Path(interp).exists():
                ldso = interp
            elif ldsos:
                ldso = ldsos[0]
            else:
                skipped.append(str(elf))
                continue
            cmd = [ldso, "--list"]
            if lib_dirs:
                cmd += ["--library-path", ":".join(lib_dirs)]
            cmd.append(str(elf))
            try:
                res = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
            except (subprocess.SubprocessError, OSError) as e:
                skipped.append(f"{elf}（ld.so --list 无法执行: {e}）")
                continue
            # 直接 NEEDED 缺失 → stderr 致命错误；深层传递依赖缺失 → stdout
            # 的 "=> not found" 行。两类都收。
            not_found = sorted(set(
                re.findall(r"(\S+) => not found", res.stdout)
                + re.findall(
                    r"error while loading shared libraries: (\S+):",
                    res.stderr)))
            if not_found:
                missing.append(f"{elf}: {', '.join(not_found)}")
            elif res.returncode != 0:
                tail = (res.stderr or res.stdout).strip().splitlines()
                skipped.append(f"{elf}（ld.so --list 退出 {res.returncode}: "
                               f"{tail[-1][:120] if tail else '无输出'}）")
            else:
                checked += 1
    return {"checked": checked, "skipped": skipped, "missing": missing}


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
        if result["success"]:
            dep_report = check_elf_dependencies(result["outputs"])
            enriched["elf_deps"] = dep_report
            if dep_report["missing"]:
                enriched["success"] = False
                enriched["summary"] = f"NEEDED 解析失败: {dep_report['missing'][0]}"
                enriched["output"] = (
                    enriched["output"] + "\n\n=== ld.so --list NEEDED 检查 ===\n"
                    + "\n".join(dep_report["missing"])
                )
            else:
                if dep_report["checked"]:
                    note = f"   ✓ NEEDED 检查通过（{dep_report['checked']} 个 ELF）"
                else:
                    note = "   ⚠ NEEDED 检查未执行（产物无带 interpreter 的 ELF）"
                if dep_report["skipped"]:
                    note += f"；跳过 {len(dep_report['skipped'])} 个（无可用 ld.so）"
                print(note)
        build_report["packages"].append(enriched)
        if enriched["success"]:
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

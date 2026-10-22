#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only
#
"""
Guix包版本检查和更新工具
检查GitHub仓库是否有新版本，并自动更新version和base32
支持通过配置文件自定义检查行为
"""

import argparse
import json
import re
from datetime import datetime
from typing import Any, Dict, List, Optional, Set, Tuple

from common import discover
from common.changes import (
    apply_pending_updates,
    build_let_git_version_change,
    build_shared_source_change,
    update_package_in_file,
)
from common.config import load_config
from common.github import get_latest_commit, get_latest_github_release
from common.hashing import get_base32_for_git, get_base32_from_guix_download
from common.issues import _build_issue_body, create_ci_issue
from common.paths import CONFIG_FILE, PACKAGES_DIR, REPORT_FILE
from common.retry import LAST_RETRIES, RetryableError, with_retry
from common.scm import (
    extract_github_repo,
    find_scm_files,
    is_version_ref,
    parse_package_definitions,
)
from common.state import check_stale_packages
from common.versions import (
    compare_versions,
    construct_download_url_from_uri,
    format_commit_version,
    normalize_tag_to_version,
    package_tag_prefix,
)
from handlers import SPECIAL_UPDATERS


def main():
    """主函数"""
    # --only pkg1,pkg2：只处理指定包。供 CI 构建失败后剔除失败包、
    # 重放成功包子集使用（见 auto-update.yml 的 Recover 步骤）。
    parser = argparse.ArgumentParser(description="Guix 包版本检查和更新工具")
    parser.add_argument(
        "--only",
        default="",
        help="逗号分隔的包名列表：只处理这些包（默认全部）",
    )
    args = parser.parse_args()
    only_set: Optional[Set[str]] = (
        {p.strip() for p in args.only.split(",") if p.strip()} or None
    )

    print("=" * 60)
    print("Guix 包版本检查和更新工具")
    print("=" * 60)
    print()

    # 加载配置文件
    config = load_config(CONFIG_FILE)
    check_pre_release_packages = set(config.get("check_pre_release", []))
    skip_packages = set(config.get("skip_packages", []))
    skip_files = set(config.get("skip_files", []))
    tag_prefix_map = config.get("tag_prefix", {})

    print(f"📋 配置:")
    print(f"   检查pre-release的包: {', '.join(check_pre_release_packages) or '无'}")
    print(f"   跳过检查的包: {', '.join(skip_packages) or '无'}")
    print()

    if not PACKAGES_DIR.exists():
        print(f"❌ 错误: 包目录不存在: {PACKAGES_DIR}")
        return 2

    scm_files = find_scm_files(PACKAGES_DIR)
    if not scm_files:
        print(f"⚠️  未找到.scm文件: {PACKAGES_DIR}")
        return 2

    scm_files = [scm_file for scm_file in scm_files if scm_file.name not in skip_files]

    print(f"📁 找到 {len(scm_files)} 个.scm文件")
    print()

    total_packages = 0
    updated_packages = 0
    skipped_packages = 0
    failed_packages = 0
    uptodate_packages = 0
    has_updates = False
    # 脚本级错误（读 .scm 失败、写盘失败）：说明脚本自身跑不动了，退出码 2
    # 中止流水线。单个包的检查失败不算脚本级错误——它只影响该包，失败详情
    # 进 issue，成功包的更新照常写盘、构建、提交。
    # 2026-10-22 实证：两者混用时退出码恒为 2，auto-update.yml 的 `exit 2`
    # 让 Detect changes / Build test / Commit 全被跳过，单个包失败会挡住
    # 整批更新（issue #59）。
    has_errors = False
    pending_updates: List[Dict[str, Any]] = []
    # 共享变量组去重：同文件同 source 变量只检查一次，后续同组包复用结论
    handled_shared: set = set()
    shared_results: Dict[Any, Tuple[str, str, str]] = {}
    report: Dict[str, Any] = {
        "timestamp": datetime.now().isoformat(timespec="seconds"),
        "total": 0,
        "updated": 0,
        "failed": 0,
        "skipped": 0,
        "uptodate": 0,
        "packages": [],
    }

    for scm_file in scm_files:
        print(f"📄 处理文件: {scm_file.relative_to(PACKAGES_DIR.parent)}")

        try:
            with open(scm_file, "r", encoding="utf-8") as f:
                content = f.read()
        except Exception as e:
            print(f"  ❌ 无法读取文件: {e}")
            has_errors = True
            continue

        packages = parse_package_definitions(content, scm_file)
        print(f"  找到 {len(packages)} 个包定义")

        for package in packages:
            total_packages += 1
            package_name = package["name"]
            package_report: Dict[str, Any] = {
                "name": package_name,
                "file": str(scm_file.relative_to(PACKAGES_DIR.parent)),
                "old_version": package["version"],
                "new_version": package["version"],
                "status": "uptodate",
                "retries": 0,
            }

            def add_retries(func_name: str) -> None:
                package_report["retries"] = int(package_report.get("retries", 0)) + int(
                    LAST_RETRIES.get(func_name, 0)
                )

            def finalize_package_report() -> None:
                nonlocal updated_packages, skipped_packages, failed_packages, uptodate_packages
                status = package_report["status"]
                if status == "updated":
                    updated_packages += 1
                elif status == "skipped":
                    skipped_packages += 1
                elif status == "failed":
                    failed_packages += 1
                else:
                    uptodate_packages += 1
                report["packages"].append(package_report)

            print(f"\n  📦 包名: {package_name}")
            print(f"     当前版本: {package['version']}")

            # --only 过滤：不在指定集合内的包不检查、不落盘
            if only_set and package_name not in only_set:
                package_report["status"] = "skipped"
                finalize_package_report()
                continue

            # 检查是否在跳过列表中
            if package_name in skip_packages:
                print(f"     ⏭️  在跳过列表中，已跳过")
                package_report["status"] = "skipped"
                finalize_package_report()
                continue

            # --- 特殊源包：版本信号不在 GitHub 上，走专属处理器 ---
            # zcode（z.ai CDN 官网 JS）、amber-pm（gitee）、jdtls-bin
            # （Eclipse 目录页 + 日期戳）、font-misans（zip 无版本号，ETag 信号）。
            if package_name in SPECIAL_UPDATERS:
                print(f"     🔧 使用特殊源处理器: {package_name}")
                try:
                    # 处理器抛 RetryableError 表示「值得再试」（上游临时故障、
                    # 网络抖动）。不重试等于把瞬时故障当成永久失败——
                    # 2026-10-22 实测：Eclipse 临时关站时目录页返回 200 +
                    # "Temporary shutdown" 页面，jdtls-bin 一次就被判失败。
                    # with_retry 按函数名记账，handler 各不相同，不会互相覆盖；
                    # 但 LAST_RETRIES 是全局字典，跨包会累加，故先清零。
                    handler = SPECIAL_UPDATERS[package_name]
                    LAST_RETRIES[handler.__name__] = 0
                    change = with_retry(
                        handler, package, config, scm_file,
                        max_retries=2, base_delay=5,
                    )
                    add_retries(handler.__name__)
                except RetryableError as e:
                    print(f"     ❌ 特殊源检查失败（可重试错误）: {e}")
                    package_report["status"] = "failed"
                    package_report["error"] = f"特殊源检查失败: {e}"
                    finalize_package_report()
                    continue
                except Exception as e:
                    print(f"     ❌ 特殊源检查失败: {e}")
                    package_report["status"] = "failed"
                    package_report["error"] = f"特殊源检查失败: {e}"
                    finalize_package_report()
                    continue

                if change:
                    pending_updates.append(change)
                    print(f"     ✅ 发现新版本并记录更新: {package_name}")
                    package_report["new_version"] = change["new_version"]
                    package_report["status"] = "updated"
                    has_updates = True
                else:
                    print(f"     ✓ 已是最新")
                    package_report["status"] = "uptodate"
                finalize_package_report()
                continue

            if not package["uri_expr"] and not package.get("is_shared_source"):
                print(f"     ⚠️  无法提取 URI，跳过")
                package_report["status"] = "skipped"
                package_report["error"] = "无法提取 URI"
                finalize_package_report()
                continue

            # --- git-reference 包的处理 ---
            if package["is_git"]:
                git_url = package["git_url"]
                if not git_url:
                    print(f"     ⚠️  无法从 git-reference 提取 URL，跳过")
                    package_report["status"] = "skipped"
                    package_report["error"] = "无法从 git-reference 提取 URL"
                    finalize_package_report()
                    continue

                print(f"     Git URL: {git_url}")
                print(f"     Commit: {package['commit_expr']}")

                github_repo = extract_github_repo(git_url)
                if not github_repo:
                    print(f"     ⚠️  不是GitHub仓库，跳过检查")
                    package_report["status"] = "skipped"
                    package_report["error"] = "不是 GitHub 仓库"
                    finalize_package_report()
                    continue

                print(f"     GitHub仓库: {github_repo}")

                include_pre_release = package_name in check_pre_release_packages
                if include_pre_release:
                    print(f"     🔍 包含pre-release检查")
                pkg_tag_prefix = package_tag_prefix(package, tag_prefix_map)

                # --- let-绑定 git-version 结构：上游无 tag，追踪 main 分支最新 commit ---
                # 这些包的 version 是 (git-version base revision commit) 表达式，
                # commit 在 let 绑定里。由于本机 Guix 的 with-latest-git-commit
                # property 尚未实现，由本脚本直接追踪 commit 并更新 let 绑定。
                if package.get("is_let_git_version"):
                    current_commit = package["let_commit"]
                    print(f"     📌 let-绑定 git-version，追踪最新 commit...")
                    print(f"     当前 commit: {current_commit[:12]}")

                    try:
                        result = with_retry(
                            get_latest_commit,
                            github_repo,
                            branch=package.get("git_branch"),
                            max_retries=2,
                            base_delay=5,
                        )
                        add_retries("get_latest_commit")
                    except Exception as e:
                        result = None
                        print(f"     ⚠️  无法获取最新 commit: {e}")
                        package_report["status"] = "failed"
                        package_report["error"] = f"无法获取最新 commit: {e}"
                        finalize_package_report()
                        continue

                    if result:
                        new_sha, new_date = result
                        print(f"     最新 commit: {new_sha[:12]}... ({new_date})")

                        if new_sha != current_commit:
                            print(f"     ✅ 发现新提交")

                            try:
                                new_base32 = with_retry(
                                    get_base32_for_git,
                                    git_url,
                                    new_sha,
                                    max_retries=2,
                                    base_delay=5,
                                )
                                add_retries("get_base32_for_git")
                            except Exception as e:
                                new_base32 = None
                                add_retries("get_base32_for_git")
                                package_report["error"] = f"无法计算 hash: {e}"

                            if new_base32 and re.fullmatch(r"[0-9a-z]{52}", new_base32) and not re.fullmatch(r"0{52}", new_base32):
                                print(f"     ✓ 计算得到 base32: {new_base32}")
                            else:
                                print(f"     ❌ 无法计算 git-fetch base32，已标记为失败并跳过更新")
                                package_report["status"] = "failed"
                                package_report["error"] = "无法计算 hash"
                                finalize_package_report()
                                continue

                            change = build_let_git_version_change(
                                scm_file, package, new_sha, new_base32,
                            )
                            if change:
                                pending_updates.append(change)
                                print(f"     ✓ 已更新: {package_name}")
                                has_updates = True
                                package_report["status"] = "updated"
                                finalize_package_report()
                                continue
                            else:
                                print(f"     ❌ 更新失败")
                                package_report["status"] = "failed"
                                package_report["error"] = "更新文件失败"
                        else:
                            print(f"     ✓ commit 已是最新")
                            package_report["status"] = "uptodate"
                    else:
                        print(f"     ⚠️  无法获取最新 commit")
                        package_report["status"] = "failed"
                        package_report["error"] = "无法获取最新 commit"

                    finalize_package_report()
                    continue

                # --- 共享变量结构（nosdshell 类）：version/source 都在模块级 ---
                # commit 引用的是独立版本变量（非 version 非固定 hash），走
                # release/tag 发现流程；落盘改三个模块级 define。
                if package.get("is_shared_source"):
                    shared_key = (str(scm_file), package["shared_source_var"])
                    if shared_key in handled_shared:
                        prev_status, prev_new, prev_err = shared_results[shared_key]
                        package_report["new_version"] = prev_new
                        package_report["status"] = prev_status
                        if prev_err:
                            package_report["error"] = prev_err
                        finalize_package_report()
                        continue
                    print(f"     共享变量源: {package['shared_source_var']}（version 变量 {package['shared_version_var']}）")
                    print(f"     Git URL: {package['git_url']}")

                    def finish_shared(status: str, new_ver: str, err: str = "") -> None:
                        package_report["new_version"] = new_ver
                        package_report["status"] = status
                        if err:
                            package_report["error"] = err
                        shared_results[shared_key] = (status, new_ver, err)
                        handled_shared.add(shared_key)
                        finalize_package_report()

                    github_repo = extract_github_repo(package["git_url"])
                    if not github_repo:
                        print(f"     ⚠️  不是GitHub仓库，跳过检查")
                        finish_shared("skipped", package["version"], "不是 GitHub 仓库")
                        continue
                    print(f"     GitHub仓库: {github_repo}")
                    include_pre_release = package_name in check_pre_release_packages
                    if include_pre_release:
                        print(f"     🔍 包含pre-release检查")
                    pkg_tag_prefix = package_tag_prefix(package, tag_prefix_map)
                    # 只有旧结构（commit 单独存在一个 SHA 变量里）才需要把
                    # tag 解析成 peel commit；tag 由 version 派生的结构里
                    # version 就是唯一真相，落盘只改 version 与 base32。
                    need_peel = bool(package.get("shared_commit_var"))
                    for _fn in (
                        "get_latest_github_release",
                        "get_latest_github_tag",
                        "get_tag_commit_sha",
                        "get_base32_for_git",
                    ):
                        LAST_RETRIES[_fn] = 0
                    outcome, cand, err = discover.discover_release_update(
                        github_repo,
                        package["git_url"],
                        package["version"],
                        include_pre_release=include_pre_release,
                        tag_prefix=pkg_tag_prefix,
                        resolve_peel=need_peel,
                    )
                    for _fn in (
                        "get_latest_github_release",
                        "get_latest_github_tag",
                        "get_tag_commit_sha",
                        "get_base32_for_git",
                    ):
                        add_retries(_fn)
                    if outcome == "failed":
                        finish_shared("failed", package["version"], err)
                        continue
                    if outcome != "candidate" or cand is None:
                        finish_shared("uptodate", package["version"])
                        continue
                    if need_peel and not cand.peel_sha:
                        print(f"     ❌ 无法获取 tag peel commit，已标记为失败并跳过更新")
                        finish_shared("failed", cand.version, "无法获取 tag commit")
                        continue
                    change = build_shared_source_change(
                        scm_file,
                        package,
                        cand.version,
                        cand.peel_sha if need_peel else None,
                        cand.base32,
                    )
                    if change:
                        pending_updates.append(change)
                        print(f"     ✓ 已更新: {package_name}")
                        has_updates = True
                        finish_shared("updated", cand.version)
                    else:
                        print(f"     ❌ 更新失败")
                        finish_shared("failed", cand.version, "更新文件失败")
                    continue


                # --- commit 引用 version 变量：走 release/tag 流程 ---
                if is_version_ref(package["commit_expr"]):
                    for _fn in (
                        "get_latest_github_release",
                        "get_latest_github_tag",
                        "get_base32_for_git",
                    ):
                        LAST_RETRIES[_fn] = 0
                    outcome, cand, err = discover.discover_release_update(
                        github_repo,
                        git_url,
                        package["version"],
                        include_pre_release=include_pre_release,
                        tag_prefix=pkg_tag_prefix,
                        resolve_peel=False,
                    )
                    for _fn in (
                        "get_latest_github_release",
                        "get_latest_github_tag",
                        "get_base32_for_git",
                    ):
                        add_retries(_fn)
                    if outcome == "failed":
                        package_report["status"] = "failed"
                        package_report["error"] = err
                        finalize_package_report()
                        continue
                    if outcome != "candidate" or cand is None:
                        print(f"     ✓ 版本已是最新")
                        package_report["status"] = "uptodate"
                        finalize_package_report()
                        continue
                    package_report["new_version"] = cand.version

                    # 剥离前缀后的版本若仍含 '/'（如 upstream/1.1.1），说明命中的
                    # 是另一条发行线而非本包的版本——写进去会让 guix 报
                    # invalid character '/' in name（issue #57）。
                    if "/" in cand.version:
                        print(f"     ⚠️  候选 tag {cand.tag} 不是版本号，跳过")
                        package_report["status"] = "skipped"
                        package_report["error"] = f"候选 tag 不是版本号: {cand.tag}"
                        finalize_package_report()
                        continue

                    change = update_package_in_file(
                        scm_file, package, cand.version, cand.base32
                    )
                    if change:
                        pending_updates.append(change)
                        print(f"     ✓ 已更新: {package_name}")
                        has_updates = True
                        package_report["status"] = "updated"
                        finalize_package_report()
                        continue
                    else:
                        print(f"     ❌ 更新失败")
                        package_report["status"] = "failed"
                        package_report["error"] = "更新文件失败"
                    finalize_package_report()

                # --- commit 是固定 hash：追踪最新 commit ---
                else:
                    current_commit = package["commit_expr"].strip('"')
                    print(f"     📌 固定 commit，追踪最新提交...")

                    try:
                        result = with_retry(
                            get_latest_commit,
                            github_repo,
                            branch=package.get("git_branch"),
                            max_retries=2,
                            base_delay=5,
                        )
                        add_retries("get_latest_commit")
                    except Exception as e:
                        result = None
                        print(f"     ⚠️  无法获取最新 commit: {e}")
                        package_report["status"] = "failed"
                        package_report["error"] = f"无法获取最新 commit: {e}"
                        finalize_package_report()
                        continue

                    if result:
                        new_sha, new_date = result
                        new_version = format_commit_version(
                            package["version"], new_date
                        )
                        package_report["new_version"] = new_version
                        print(f"     最新 commit: {new_sha[:12]}... ({new_date})")

                        if new_sha != current_commit:
                            print(f"     ✅ 发现新提交")

                            try:
                                new_base32 = with_retry(
                                    get_base32_for_git,
                                    git_url,
                                    new_sha,
                                    max_retries=2,
                                    base_delay=5,
                                )
                                add_retries("get_base32_for_git")
                            except Exception as e:
                                new_base32 = None
                                add_retries("get_base32_for_git")
                                package_report["error"] = f"无法计算 hash: {e}"

                            if new_base32 and re.fullmatch(r"[0-9a-z]{52}", new_base32) and not re.fullmatch(r"0{52}", new_base32):
                                print(f"     ✓ 计算得到 base32: {new_base32}")
                            else:
                                print(f"     ❌ 无法计算 git-fetch base32，已标记为失败并跳过更新")
                                package_report["status"] = "failed"
                                package_report["error"] = "无法计算 hash"
                                finalize_package_report()
                                continue

                            change = update_package_in_file(
                                scm_file, package, new_version, new_base32,
                                new_commit=new_sha,
                            )
                            if change:
                                pending_updates.append(change)
                                print(f"     ✓ 已更新: {package_name}")
                                has_updates = True
                                package_report["status"] = "updated"
                                finalize_package_report()
                                continue
                            else:
                                print(f"     ❌ 更新失败")
                                package_report["status"] = "failed"
                                package_report["error"] = "更新文件失败"
                        else:
                            print(f"     ✓ commit 已是最新")
                            package_report["status"] = "uptodate"
                    else:
                        print(f"     ⚠️  无法获取最新 commit")
                        package_report["status"] = "failed"
                        package_report["error"] = "无法获取最新 commit"

                    finalize_package_report()

            # --- url-fetch 包的处理 ---
            else:
                print(f"     URI: {package['uri_expr'][:80]}...")

                # 从 uri 表达式构造当前版本的 URL 用于提取仓库信息
                current_url = construct_download_url_from_uri(
                    package["uri_expr"], package["version"]
                )
                if not current_url:
                    print(f"     ⚠️  无法构造 URL，跳过")
                    package_report["status"] = "skipped"
                    package_report["error"] = "无法构造 URL"
                    finalize_package_report()
                    continue

                # 提取GitHub仓库
                github_repo = extract_github_repo(current_url)

                if github_repo:
                    print(f"     GitHub仓库: {github_repo}")

                    # 判断是否需要检查pre-release
                    include_pre_release = package_name in check_pre_release_packages
                    if include_pre_release:
                        print(f"     🔍 包含pre-release检查")
                    pkg_tag_prefix = package_tag_prefix(package, tag_prefix_map)

                    # 获取最新release
                    try:
                        latest_release = with_retry(
                            get_latest_github_release,
                            github_repo,
                            include_pre_release,
                            pkg_tag_prefix,
                            max_retries=2,
                            base_delay=5,
                        )
                        add_retries("get_latest_github_release")
                    except Exception as e:
                        latest_release = None
                        package_report["status"] = "failed"
                        package_report["error"] = f"无法获取最新release信息: {e}"
                        finalize_package_report()
                        continue

                    if latest_release:
                        print(f"     最新release: {latest_release}")

                        # Guix version 字段不含 tag 前缀；剥离前缀得到纯版本号
                        normalized_version = normalize_tag_to_version(latest_release, pkg_tag_prefix)

                        # 比较版本
                        if compare_versions(package["version"], normalized_version):
                            print(f"     ✅ 发现新版本: {latest_release}")
                            package_report["new_version"] = normalized_version

                            # 从 uri 表达式构造新版本的下载 URL
                            download_url = construct_download_url_from_uri(
                                package["uri_expr"], normalized_version
                            )

                            if not download_url:
                                print(f"     ⚠️  无法构造下载 URL，跳过")
                                package_report["status"] = "skipped"
                                package_report["error"] = "无法构造下载 URL"
                                finalize_package_report()
                                continue

                            print(f"     下载 URL: {download_url}")

                            # 获取真实的 base32
                            try:
                                new_base32 = with_retry(
                                    get_base32_from_guix_download,
                                    download_url,
                                    max_retries=2,
                                    base_delay=5,
                                )
                                add_retries("get_base32_from_guix_download")
                            except Exception as e:
                                new_base32 = None
                                add_retries("get_base32_from_guix_download")
                                package_report["error"] = f"计算 base32 失败: {e}"

                            if new_base32 and re.fullmatch(r"[0-9a-z]{52}", new_base32) and not re.fullmatch(r"0{52}", new_base32):
                                print(f"     ✓ 计算得到 base32: {new_base32}")
                            else:
                                print(f"     ❌ 无法计算 url-fetch base32，已标记为失败并跳过更新")
                                package_report["status"] = "failed"
                                package_report["error"] = "无法计算 hash"
                                finalize_package_report()
                                continue

                            # 更新文件
                            change = update_package_in_file(
                                scm_file, package, normalized_version, new_base32
                            )
                            if change:
                                pending_updates.append(change)
                                print(f"     ✓ 已更新: {package_name}")
                                has_updates = True
                                package_report["status"] = "updated"
                                finalize_package_report()
                                continue
                            else:
                                print(f"     ❌ 更新失败")
                                package_report["status"] = "failed"
                                package_report["error"] = "更新文件失败"
                        else:
                            print(f"     ✓ 版本已是最新")
                            package_report["status"] = "uptodate"
                    else:
                        print(f"     ⚠️  无法获取最新release信息")
                        package_report["status"] = "failed"
                        package_report["error"] = "无法获取最新release信息"
                else:
                    print(f"     ⚠️  不是GitHub仓库，跳过检查")
                    package_report["status"] = "skipped"
                    package_report["error"] = "不是 GitHub 仓库"

                finalize_package_report()

        print()

    print("=" * 60)
    print(f"📊 总计: {total_packages} 个包")
    print(f"🔄 已更新: {updated_packages} 个包")
    print(f"✓ 保持最新: {uptodate_packages} 个包")
    print(f"⏭️  已跳过: {skipped_packages} 个包")
    print("=" * 60)

    if pending_updates and not apply_pending_updates(pending_updates):
        has_errors = True

    report["total"] = total_packages
    report["updated"] = updated_packages
    report["failed"] = failed_packages
    report["skipped"] = skipped_packages
    report["uptodate"] = uptodate_packages
    # 两类失败分开记账：脚本级错误让退出码为 2（流水线中止），包级失败
    # 只进 issue，不挡成功包的提交。
    report["script_errors"] = bool(has_errors)
    report["package_failures"] = failed_packages > 0

    try:
        REPORT_FILE.write_text(
            json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8"
        )
    except Exception as e:
        print(f"⚠️  写入 report.json 失败: {e}")
        has_errors = True

    # 无法自动更新的包（继承上游 / 有意冻结）：超过 stale_days 天无手动更新
    # 则发提醒 issue。依赖 git diff 判断"是否有手动更新"，因此放在最后。
    # --only 重放模式下工作区 diff 语义已变（可能刚被 checkout 回 HEAD），
    # stale 判定不可靠，跳过。
    if not only_set:
        check_stale_packages(scm_files, config)

    if failed_packages > 0 and not only_set:
        failed_list = [p for p in report["packages"] if p["status"] == "failed"]
        today = datetime.now().strftime("%Y-%m-%d")
        issue_title = f"🔄 自动更新报告 — {today} — {failed_packages} 个失败"
        issue_body = _build_issue_body(failed_list)
        print()
        create_ci_issue(issue_title, issue_body, config)

    # 退出码：0=无更新无错误，1=有更新，2=脚本级错误。
    # 包级失败不影响退出码——失败详情已写进 issue，成功包的更新也已落盘，
    # 流水线要继续跑构建测试并提交（2026-10-22 issue #59 的修复）。
    if has_errors:
        return 2
    if has_updates:
        return 1
    return 0


if __name__ == "__main__":
    exit(main())

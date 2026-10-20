# SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only

"""包更新描述构建与落盘应用。"""

import re
from pathlib import Path
from typing import Any, Dict, List, Optional

from common.http import resolve_safe_path
from common.scm import _extract_define_block


def update_package_in_file(
    file_path: Path,
    package: dict[str, Any],
    new_version: str,
    new_base32: str,
    new_commit: Optional[str] = None,
) -> Optional[Dict[str, Any]]:
    """构建包更新描述（仅内存，不直接写文件）"""
    try:
        return {
            "file_path": file_path,
            "package": package["name"],
            "old_version": package["version"],
            "new_version": new_version,
            "new_base32": new_base32,
            "new_commit": new_commit,
            "content": package["content"],
            "start_pos": package["start_pos"],
            "end_pos": package["end_pos"],
            "old_commit_expr": package.get("commit_expr"),
            "old_base32": package.get("base32"),
        }
    except Exception as e:
        print(f"  ❌ 更新文件失败: {e}")
        return None


def build_let_git_version_change(
    file_path: Path,
    package: dict[str, Any],
    new_commit: str,
    new_base32: str,
) -> Optional[Dict[str, Any]]:
    """为 let-绑定 git-version 结构（无 tag 追踪 commit 模式）构建更新描述。

    与 update_package_in_file 不同，这里需要：
    1. 替换 let 绑定里的 commit 字面值
    2. 自增 revision（0→1→2...）
    version 字符串由 (git-version base revision commit) 在求值时生成，
    无需在文件里写字面 version。
    """
    try:
        old_commit = package["let_commit"]
        old_revision_val = package["let_revision_val"] or "0"
        new_revision_val = str(int(old_revision_val) + 1)
        return {
            "file_path": file_path,
            "package": package["name"],
            "old_version": f"{package['git_version_base']}-{old_revision_val}.{old_commit[:7]}",
            "new_version": f"{package['git_version_base']}-{new_revision_val}.{new_commit[:7]}",
            "new_base32": new_base32,
            "new_commit": new_commit,
            "new_revision": new_revision_val,
            "content": package["content"],
            "start_pos": package["start_pos"],
            "end_pos": package["end_pos"],
            "old_commit_expr": None,
            "old_base32": package.get("base32"),
            # let 结构专用字段
            "is_let_git_version": True,
            "old_let_commit": old_commit,
            "old_let_revision": old_revision_val,
        }
    except Exception as e:
        print(f"  ❌ 构建 let-git-version 更新失败: {e}")
        return None


def build_shared_source_change(
    file_path: Path,
    package: dict[str, Any],
    new_version: str,
    new_commit: Optional[str],
    new_base32: str,
) -> Optional[Dict[str, Any]]:
    """为共享变量结构（nosdshell 类）构建更新描述。

    改模块级 define：%xxx-version、%xxx-source 块内 base32；commit 单独存
    在 SHA 变量的旧结构还要改 %xxx-commit（new_commit 非 None 时）。tag 由
    version 派生的结构（(string-append "v" %xxx-version)）只需改前两者。
    file-name 里的版本引用与 git-reference 里的 commit 引用都是变量或变量
    派生表达式，求值时自动跟随，无需改写。
    """
    try:
        return {
            "file_path": file_path,
            "package": package["name"],
            "old_version": package["version"],
            "new_version": new_version,
            "new_base32": new_base32,
            "new_commit": new_commit,
            "content": package["content"],
            "start_pos": package["start_pos"],
            "end_pos": package["end_pos"],
            "old_commit_expr": None,
            "old_base32": package.get("base32"),
            # 共享变量专用字段
            "is_shared_source": True,
            "shared_version_var": package["shared_version_var"],
            "shared_commit_var": package.get("shared_commit_var"),
            "shared_source_var": package["shared_source_var"],
            "old_commit_value": package.get("shared_commit_value"),
        }
    except Exception as e:
        print(f"  ❌ 构建共享变量更新失败: {e}")
        return None


def apply_pending_updates(pending: List[Dict[str, Any]]) -> bool:
    """应用所有待写入更新（按文件聚合，每个文件写入一次）"""
    try:
        pending_by_file: Dict[Path, List[Dict[str, Any]]] = {}
        for change in pending:
            file_path = change["file_path"]
            pending_by_file.setdefault(file_path, []).append(change)

        for file_path, changes in pending_by_file.items():
            file_path = Path(resolve_safe_path(file_path))
            with open(file_path, "r", encoding="utf-8") as f:
                file_content = f.read()

            # 逆序应用，避免后续替换影响前面区间索引
            for change in sorted(changes, key=lambda c: c["start_pos"], reverse=True):
                start_pos = change["start_pos"]
                end_pos = change["end_pos"]
                package_content = file_content[start_pos:end_pos]

                # let-绑定 git-version 结构（无 tag 追踪 commit 模式）：
                # 替换 let 绑定的 commit 字面值 + 自增 revision + base32，
                # version 字段是 (git-version ...) 表达式，无需写字面值。
                if change.get("is_let_git_version"):
                    old_commit = change["old_let_commit"]
                    old_revision = change["old_let_revision"]
                    new_commit = change["new_commit"]
                    new_revision = change["new_revision"]
                    # 替换 let 绑定的 commit
                    old_commit_pattern = rf'(\({re.escape("commit")}\s+)"{re.escape(old_commit)}"'
                    package_content = re.sub(
                        old_commit_pattern,
                        lambda m: m.group(1) + f'"{new_commit}"',
                        package_content,
                        count=1,
                    )
                    # 自增 let 绑定的 revision（仅当 revision 绑定存在时）
                    if new_revision is not None and old_revision is not None:
                        old_rev_pattern = (
                            rf'(\(revision\s+)"{re.escape(old_revision)}"'
                        )
                        package_content = re.sub(
                            old_rev_pattern,
                            lambda m: m.group(1) + f'"{new_revision}"',
                            package_content,
                            count=1,
                        )
                    # 替换 base32
                    if change.get("old_base32"):
                        old_base32_pattern = (
                            rf'\(base32\s+"{re.escape(change["old_base32"])}"\)'
                        )
                        new_base32_str = f'(base32 "{change["new_base32"]}")'
                        package_content = re.sub(
                            old_base32_pattern,
                            new_base32_str,
                            package_content,
                            count=1,
                        )
                    file_content = (
                        file_content[:start_pos] + package_content + file_content[end_pos:]
                    )
                    continue

                # 共享变量结构：改模块级 define，不碰包块区间。
                # 三处替换任一找不到旧值即整体失败，避免静默半写。
                if change.get("is_shared_source"):
                    applied = file_content
                    vvar = change["shared_version_var"]
                    old_v = rf'\(define\s+{re.escape(vvar)}\s+"{re.escape(change["old_version"])}"'
                    new_v = f'(define {vvar} "{change["new_version"]}"'
                    applied, n_v = re.subn(old_v, new_v, applied, count=1)
                    n_c = 1
                    cvar = change.get("shared_commit_var")
                    if cvar and change.get("old_commit_value") and change.get("new_commit"):
                        old_c = (
                            rf'\(define\s+{re.escape(cvar)}\s+'
                            rf'"{re.escape(change["old_commit_value"])}"'
                        )
                        new_c = f'(define {cvar} "{change["new_commit"]}"'
                        applied, n_c = re.subn(old_c, new_c, applied, count=1)
                    n_b = 0
                    if change.get("old_base32"):
                        src_block = _extract_define_block(
                            applied, change["shared_source_var"]
                        )
                        if src_block is not None:
                            s, e, text = src_block
                            old_b = rf'\(base32\s+"{re.escape(change["old_base32"])}"'
                            new_b = f'(base32 "{change["new_base32"]}"'
                            replaced, n_b = re.subn(old_b, new_b, text, count=1)
                            if n_b:
                                applied = applied[:s] + replaced + applied[e:]
                    if not (n_v and n_c and n_b):
                        print(f"  ❌ 共享变量替换失败: {change['package']}")
                        return False
                    file_content = applied
                    continue

                old_version_pattern = rf'\(version\s+"{re.escape(change["old_version"])}"\)'
                new_version_str = f'(version "{change["new_version"]}")'
                package_content = re.sub(
                    old_version_pattern, new_version_str, package_content, count=1
                )

                # 特殊源（如 jdtls-bin）需要额外替换 URI 里的字面量片段
                # （例如归档时间戳 -202606262232.tar.gz）。
                for old_frag, new_frag in change.get("extra_replacements", []):
                    package_content = re.sub(
                        re.escape(old_frag), new_frag, package_content, count=1
                    )

                if change["new_commit"] and change.get("old_commit_expr"):
                    old_commit = change["old_commit_expr"].strip('"')
                    old_commit_pattern = rf'\(commit\s+"{re.escape(old_commit)}"\)'
                    new_commit_str = f'(commit "{change["new_commit"]}")'
                    package_content = re.sub(
                        old_commit_pattern, new_commit_str, package_content, count=1
                    )

                if change.get("old_base32"):
                    old_base32_pattern = (
                        rf'\(base32\s+"{re.escape(change["old_base32"])}"\)'
                    )
                    new_base32_str = f'(base32 "{change["new_base32"]}")'
                    package_content = re.sub(
                        old_base32_pattern, new_base32_str, package_content, count=1
                    )

                file_content = (
                    file_content[:start_pos] + package_content + file_content[end_pos:]
                )

            file_path.write_text(file_content, encoding="utf-8")

        return True
    except Exception as e:
        print(f"  ❌ 批量写入失败: {e}")
        return False

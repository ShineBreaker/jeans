# SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only
"""SCM 包定义解析。"""
import re
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple


def find_scm_files(directory: Path) -> List[Path]:
    """查找所有的.scm文件"""
    return list(directory.glob("*.scm"))


def extract_github_repo(url: str) -> Optional[str]:
    """从URL中提取GitHub仓库路径 (owner/repo)"""
    # 匹配 github.com/owner/repo 或 github.com/owner/repo/
    patterns = [
        r"github\.com/([^/]+)/([^/]+?)(?:\.git|/|$)",
        r"api\.github\.com/repos/([^/]+)/([^/]+)",
    ]

    for pattern in patterns:
        match = re.search(pattern, url)
        if match:
            return f"{match.group(1)}/{match.group(2)}"

    return None


def extract_git_reference_url(uri_expr: str) -> Optional[str]:
    """从git-reference表达式中提取URL"""
    url_match = re.search(r'\(url\s+"([^"]+)"', uri_expr)
    return url_match.group(1) if url_match else None


def extract_commit_expr(uri_expr: str) -> Optional[str]:
    """从git-reference中提取commit表达式，正确处理嵌套括号"""
    start = uri_expr.find("(commit")
    if start == -1:
        return None
    pos = start + len("(commit")
    depth = 0
    while pos < len(uri_expr):
        if uri_expr[pos] == '(':
            depth += 1
        elif uri_expr[pos] == ')':
            if depth == 0:
                return uri_expr[start + len("(commit"):pos].strip()
            depth -= 1
        pos += 1
    return None


def is_version_ref(commit_expr: str) -> bool:
    """判断commit表达式是否引用了version变量（可以自动更新）"""
    if not commit_expr:
        return False
    # version 变量引用
    if commit_expr == "version":
        return True
    # (string-append "v" version) 等包含 version 的表达式
    if "version" in commit_expr and not commit_expr.startswith('"'):
        return True
    return False


def _balanced_expr_range(content: str, start: int) -> Optional[Tuple[int, int]]:
    """从 start（表达式首字符 '('）起做括号配平，跳过字符串与注释。

    返回 (start, end)，end 为配对右括号的后一位；括号不平衡返回 None。
    """
    pos = start
    depth = 0
    n = len(content)
    while pos < n:
        ch = content[pos]
        if ch == ";":
            nl = content.find("\n", pos)
            pos = n if nl == -1 else nl + 1
            continue
        if ch == '"':
            pos += 1
            while pos < n:
                if content[pos] == "\\":
                    pos += 2
                    continue
                if content[pos] == '"':
                    pos += 1
                    break
                pos += 1
            continue
        if ch == "(":
            depth += 1
        elif ch == ")":
            depth -= 1
            if depth == 0:
                return (start, pos + 1)
        pos += 1
    return None


def _extract_define_block(content: str, var: str) -> Optional[Tuple[int, int, str]]:
    """提取顶层 (define <var> ...) 完整块，括号配平（跳过字符串与注释）。

    返回 (start, end, text)，找不到或括号不平衡返回 None。
    """
    m = re.search(r"\(define\s+" + re.escape(var) + r"(?=[\s)])", content)
    if not m:
        return None
    rng = _balanced_expr_range(content, m.start())
    if rng is None:
        return None
    return (rng[0], rng[1], content[rng[0]:rng[1]])


def _extract_uri_expr(package_content: str) -> Optional[str]:
    """提取 (uri <expr>) 中的表达式文本。

    用括号配平而非非贪婪正则：旧写法 `\\(uri\\s+(.+?)\\)\\s*\\(sha256` 在
    uri 与 sha256 之间夹着 (file-name "...") 时会一并捕获该字段，随后
    construct_download_url_from_uri 把 file-name 拼进 URL 造成 404
    （aria2-next-bin，2026-10-13 实证）。
    """
    m = re.search(r"\(uri\s", package_content)
    if not m:
        return None
    start = m.end()
    n = len(package_content)
    while start < n and package_content[start].isspace():
        start += 1
    if start >= n or package_content[start] == ")":
        return None
    if package_content[start] == "(":
        rng = _balanced_expr_range(package_content, start)
        return package_content[rng[0]:rng[1]] if rng else None
    if package_content[start] == '"':
        pos = start + 1
        while pos < n:
            if package_content[pos] == "\\":
                pos += 2
                continue
            if package_content[pos] == '"':
                return package_content[start:pos + 1]
            pos += 1
        return None
    pos = start
    while pos < n and not package_content[pos].isspace() and package_content[pos] != ")":
        pos += 1
    return package_content[start:pos] or None


def _resolve_shared_source(
    content: str, version_var: str, source_var: str
) -> Optional[Dict[str, Any]]:
    """解析模块级共享变量：version 字面量 + source 块内的 git 信息。

    即 nosdshell 结构：包体只写 (version %v)/(source %s)，真值在顶层
    (define %v \"...\") 与 (define %s (origin ...)) 里。任一步失败返回 None，
    调用方回落到旧行为（skipped），不抛异常。
    """
    try:
        vm = re.search(
            r"\(define\s+" + re.escape(version_var) + r'\s+"([^"]+)"', content
        )
        if not vm:
            return None
        block = _extract_define_block(content, source_var)
        if not block:
            return None
        _, _, origin = block
        if not re.search(r"\(method\s+git-fetch\s*\)", origin):
            return None
        url_m = re.search(r'\(url\s+"([^"]+)"', origin)
        base32_m = re.search(r'\(base32\s+"([^"]+)"', origin)
        if not url_m or not base32_m:
            return None
        commit_expr = extract_commit_expr(origin)
        commit_var = None
        commit_value = None
        if commit_expr:
            if commit_expr.startswith("%"):
                commit_var = commit_expr
                cm = re.search(
                    r"\(define\s+" + re.escape(commit_var) + r'\s+"([0-9a-f]{40})"',
                    content,
                )
                if not cm:
                    return None
                commit_value = cm.group(1)
            elif re.fullmatch(r"[0-9a-f]{40}", commit_expr):
                commit_value = commit_expr
            else:
                return None
        return {
            "version": vm.group(1),
            "git_url": url_m.group(1),
            "base32": base32_m.group(1),
            "commit_var": commit_var,
            "commit_value": commit_value,
        }
    except Exception:
        return None


def parse_package_definitions(content: str, _file_path: Path) -> list[dict[str, Any]]:
    """解析.scm文件中的包定义"""
    packages = []

    # 使用正则表达式匹配 define-public 后面的包定义
    # 这个正则表达式需要匹配从 (define-public name 到下一个顶层 define 或文件结尾

    # 顶层 define（含 define-public 与私有 define）都是块边界：
    # 私有 helper（如 quickshell/nosd、ffmpeg-7、%nosdshell-source）若不作为
    # 边界，会被吸入上一个 define-public 的块，导致 version 误取
    # （linux-wallpaperengine 误取 quickshell/nosd 的 0.3.2，2026-10-09 实证）。
    # 私有块只做边界，不产生更新条目（pinned fork 不应自动更新）。
    # 顶层判定用行首锚点：包内缩进的 define 不受影响。
    boundary_pattern = r"^\(define-public\s+(\S+)|^\(define\*?\s+(\S+)"
    boundaries = list(re.finditer(boundary_pattern, content, re.MULTILINE))

    for i, match in enumerate(boundaries):
        is_public = match.group(0).startswith("(define-public")
        package_name = match.group(1) if is_public else match.group(2)
        if not is_public:
            continue
        start_pos = match.start()

        # 确定结束位置（下一个顶层 define-public/define 或文件结尾）
        if i + 1 < len(boundaries):
            end_pos = boundaries[i + 1].start()
        else:
            end_pos = len(content)

        package_content = content[start_pos:end_pos]

        # 提取版本号
        version_match = re.search(r'\(version\s+"([^"]+)"', package_content)
        version = version_match.group(1) if version_match else None
        # 共享变量引用 (version %v)：仅字面量缺失时记录候选
        shared_version_var = None
        if version is None:
            svm = re.search(r"\(version\s+(%[\w-]+)\)", package_content)
            if svm:
                shared_version_var = svm.group(1)

        # 提取完整的 URI 表达式（括号配平；防止 file-name 等后续字段被卷入）
        uri_expr = _extract_uri_expr(package_content)
        # 共享变量引用 (source %s)：仅 uri 缺失时记录候选
        shared_source_var = None
        if uri_expr is None:
            ssm = re.search(r"\(source\s+(%[\w-]+)\)", package_content)
            if ssm:
                shared_source_var = ssm.group(1)

        # 提取base32
        base32_match = re.search(r'\(base32\s+"([^"]+)"', package_content)
        base32 = base32_match.group(1) if base32_match else None

        # 提取下载方法
        method_match = re.search(r"\(method\s+(\S+)", package_content)
        method = method_match.group(1) if method_match else None

        # 检测 git-reference
        is_git = uri_expr is not None and "git-reference" in uri_expr
        git_url = extract_git_reference_url(uri_expr) if is_git and uri_expr else None
        commit_expr = extract_commit_expr(uri_expr) if is_git and uri_expr else None

        # 共享变量回退（nosdshell 类结构）：包体只有 (version %v) 与
        # (source %s) 引用，真值在模块级 define 里。resolve 成功才覆盖
        # 字段；失败则保持 None，走原 skipped 路径（无回归）。
        is_shared_source = False
        shared_commit_var = None
        shared_commit_value = None
        if (
            version is None
            and shared_version_var is not None
            and uri_expr is None
            and shared_source_var is not None
        ):
            shared_info = _resolve_shared_source(
                content, shared_version_var, shared_source_var
            )
            if shared_info is not None:
                is_shared_source = True
                version = shared_info["version"]
                base32 = shared_info["base32"]
                method = "git-fetch"
                is_git = True
                git_url = shared_info["git_url"]
                commit_expr = shared_info["commit_var"] or shared_info["commit_value"]
                shared_commit_var = shared_info["commit_var"]
                shared_commit_value = shared_info["commit_value"]

        # 识别 let-绑定的 git-version 结构（无 tag 追踪 commit 模式）。
        # 结构形如：(let ((commit "...") (revision "...")) (package (version (git-version ...)) ...))
        # 此时 version 字段是表达式而非字面量，commit 在 let 绑定里而非 git-reference。
        let_commit_match = re.search(
            r'\(let\s+\(\((?:commit|rev)\s+"([0-9a-f]{40})"\)\s*'
            r'(?:\((?:revision|rev)\s+"(\d+)"\)\s*)?\)',
            package_content,
        )
        is_let_git_version = (
            let_commit_match is not None
            and version is None
            and re.search(r'\(version\s+\(git-version\b', package_content) is not None
        )
        let_commit = let_commit_match.group(1) if let_commit_match else None
        let_revision_val = let_commit_match.group(2) if let_commit_match else None
        release_tag_prefix_match = re.search(
            r'\(release-tag-prefix\s+\.\s+"([^"]+)"\)', package_content
        )
        release_tag_prefix = (
            release_tag_prefix_match.group(1) if release_tag_prefix_match else None
        )
        # git-branch：let-git-version 包追踪的分支（不设则追踪默认分支）。
        git_branch_match = re.search(
            r'\(git-branch\s+\.\s+"([A-Za-z0-9._/-]+)"\)', package_content
        )
        git_branch = git_branch_match.group(1) if git_branch_match else None
        # git-version 的 base（用于重建 version 字符串）
        git_version_base = None
        if is_let_git_version:
            gv_match = re.search(
                r'\(version\s+\(git-version\s+"([^"]*)"', package_content
            )
            git_version_base = gv_match.group(1) if gv_match else ""

        packages.append(
            {
                "name": package_name,
                "version": version,
                "uri_expr": uri_expr,
                "base32": base32,
                "method": method,
                "is_git": is_git,
                "git_url": git_url,
                "commit_expr": commit_expr,
                # let-绑定 git-version 结构（最新 commit 追踪模式）
                "is_let_git_version": is_let_git_version,
                "let_commit": let_commit,
                "let_revision_val": let_revision_val,
                "git_version_base": git_version_base,
                "release_tag_prefix": release_tag_prefix,
                "git_branch": git_branch,
                # 共享变量结构（nosdshell 类）：常规包全为 False/None
                "is_shared_source": is_shared_source,
                "shared_version_var": shared_version_var,
                "shared_commit_var": shared_commit_var,
                "shared_source_var": shared_source_var,
                "shared_commit_value": shared_commit_value,
                "content": package_content,
                "start_pos": start_pos,
                "end_pos": end_pos,
            }
        )

    return packages

#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only
#
"""
Guix包版本检查和更新工具
检查GitHub仓库是否有新版本，并自动更新version和base32
支持通过配置文件自定义检查行为
"""

import hashlib
import os
import re
import requests
import json
import time
import subprocess
import tempfile
import shutil
from datetime import datetime
from pathlib import Path
from typing import Any, Callable, Dict, List, Optional, Tuple, TypeVar

# GitHub API配置
GITHUB_API_URL = "https://api.github.com/repos"
GITHUB_TOKEN = os.environ.get("GITHUB_TOKEN")  # 可选，用于提高API限制

# 常量
NEW_BASE32 = "0000000000000000000000000000000000000000000000000000"
PACKAGES_DIR = Path(__file__).parent.parent.parent / "modules" / "jeans" / "packages"
CONFIG_FILE = Path(__file__).parent / "config.json"
REPORT_FILE = Path(__file__).parent / "report.json"


# ── Guix/Nix base32 编码 + NAR 序列化（纯 Python，不依赖 guix 命令） ──────────

# Nix/Guix base32 字符表（排除 e/o/t/u，避免与数字混淆）
_BASE32_CHARS = "0123456789abcdfghijklmnpqrsvwxyz"


def _sha256_to_guix_base32(digest: bytes) -> str:
    """将 SHA256 digest (32 字节) 转为 Nix/Guix base32 字符串 (52 字符)。

    Nix base32 从最低位取 5 位一组，结果从右到左填充。
    """
    hash_size = len(digest)
    total_bits = hash_size * 8
    d = (total_bits + 4) // 5  # ceil(256/5) = 52

    result = [''] * d
    for i in range(d):
        digit = 0
        for j in range(5):
            bit = i * 5 + j
            byte_idx = bit // 8
            bit_in_byte = bit % 8
            if byte_idx < hash_size and (digest[byte_idx] >> bit_in_byte) & 1:
                digit |= 1 << j
        result[d - 1 - i] = _BASE32_CHARS[digit]
    return ''.join(result)


def _nar_str(data) -> bytes:
    """编码 NAR 字节串：8 字节 LE 长度前缀 + 数据 + 填充到 8 字节边界。"""
    if isinstance(data, str):
        data = data.encode('utf-8')
    n = len(data)
    pad = (8 - n % 8) % 8
    return n.to_bytes(8, 'little') + data + b'\x00' * pad


def _nar_entry(path: str) -> bytes:
    """递归序列化单个文件系统条目为 NAR 字节流。"""
    # 符号链接必须在 isdir 之前检查
    if os.path.islink(path):
        return (_nar_str("type") + _nar_str("symlink") +
                _nar_str("target") + _nar_str(os.readlink(path)))

    if os.path.isdir(path):
        parts = [_nar_str("type"), _nar_str("directory")]
        for name in sorted(os.listdir(path)):
            child = os.path.join(path, name)
            parts += [_nar_str("entry"), _nar_str("("),
                      _nar_str("name"), _nar_str(name),
                      _nar_str("node"), _nar_str("("),
                      _nar_entry(child),
                      _nar_str(")"), _nar_str(")")]
        return b''.join(parts)

    if os.path.isfile(path):
        with open(path, 'rb') as f:
            content = f.read()
        result = _nar_str("type") + _nar_str("regular")
        # NAR 中可执行文件带有 executable "" 标记
        if os.access(path, os.X_OK):
            result += _nar_str("executable") + _nar_str("")
        result += _nar_str("contents") + _nar_str(content)
        return result

    raise ValueError(f"不支持的文件类型: {path}")


def compute_nar_base32(path: str) -> str:
    """计算目录/文件的 NAR 序列化 SHA256 → Guix base32。等价于 guix hash -rx。"""
    nar = (_nar_str("nix-archive-1") + _nar_str("(") +
           _nar_entry(str(path)) + _nar_str(")"))
    return _sha256_to_guix_base32(hashlib.sha256(nar).digest())


# ── 错误处理 ──────────────────────────────────────────────────────────────────

class RetryableError(Exception):
    """可重试的瞬时错误。"""


T = TypeVar("T")
LAST_RETRIES: Dict[str, int] = {}


def is_retryable_http_error(error: requests.exceptions.HTTPError) -> bool:
    """是否为可重试 HTTP 错误（5xx）。"""
    status_code = error.response.status_code if error.response else None
    return status_code is not None and 500 <= status_code <= 599


def is_retryable_command_failure(text: str) -> bool:
    """根据命令输出文本判断是否是可重试的网络/超时/5xx错误。"""
    lower = text.lower()
    retry_patterns = [
        r"timeout",
        r"timed out",
        r"connection",
        r"network",
        r"temporar",
        r"http\s*5\d\d",
        r"status\s*5\d\d",
        r"\b5\d\d\b",
    ]
    return any(re.search(pattern, lower) for pattern in retry_patterns)


def with_retry(
    func: Callable[..., T], *args: Any, max_retries: int = 2, base_delay: int = 5, **kwargs: Any
) -> T:
    """重试执行函数：重试网络错误/HTTP 5xx/超时，指数退避。"""
    last_error: Optional[Exception] = None
    retries = 0

    for attempt in range(max_retries + 1):
        try:
            result = func(*args, **kwargs)
            LAST_RETRIES[func.__name__] = retries
            return result
        except RetryableError as e:
            last_error = e
        except requests.exceptions.Timeout as e:
            last_error = e
        except requests.exceptions.ConnectionError as e:
            last_error = e
        except requests.exceptions.HTTPError as e:
            if not is_retryable_http_error(e):
                LAST_RETRIES[func.__name__] = retries
                raise
            last_error = e
        except subprocess.TimeoutExpired as e:
            last_error = e

        if attempt < max_retries:
            delay = base_delay ** (attempt + 1)
            print(f"⏳ 重试 {attempt + 1}/{max_retries} (等待 {delay}s)...")
            time.sleep(delay)
            retries += 1
            continue

        LAST_RETRIES[func.__name__] = retries
        raise last_error if last_error else RetryableError("未知错误")

    LAST_RETRIES[func.__name__] = retries
    raise RetryableError("未知错误")


def load_config(config_path: Path) -> dict[str, Any]:
    """加载配置文件"""
    try:
        with open(config_path, "r", encoding="utf-8") as f:
            config = json.load(f)
            config.setdefault("check_pre_release", [])
            config.setdefault("skip_packages", [])
            config.setdefault("skip_files", [])
            config.setdefault("notes", {})
            config.setdefault("tag_prefix", {})
            return config
    except FileNotFoundError:
        print(f"⚠️  配置文件不存在: {config_path}")
        print("   使用默认配置")
        return {
            "check_pre_release": [],
            "skip_packages": [],
            "skip_files": [],
            "notes": {},
            "tag_prefix": {},
        }
    except json.JSONDecodeError as e:
        print(f"⚠️  配置文件格式错误: {e}")
        print("   使用默认配置")
        return {
            "check_pre_release": [],
            "skip_packages": [],
            "skip_files": [],
            "notes": {},
            "tag_prefix": {},
        }


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


def format_commit_version(current_version: str, new_date: str) -> str:
    """保留原版本号前缀，只替换日期部分

    例: "0-unstable-2026-03-01" + "2026-03-16" -> "0-unstable-2026-03-16"
        "2025-10-18" + "2025-11-01"            -> "2025-11-01"
    """
    match = re.match(r'^(.*?)(\d{4}-\d{2}-\d{2})$', current_version)
    if match:
        prefix = match.group(1)
        return f"{prefix}{new_date}"
    return new_date


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
    headers = {}
    if GITHUB_TOKEN:
        headers["Authorization"] = f"token {GITHUB_TOKEN}"

    try:
        # tag_prefix 模式：用列表 API 找匹配前缀的最新（非预）发布
        if tag_prefix:
            url = f"{GITHUB_API_URL}/{repo}/releases?per_page=30"
            response = requests.get(url, headers=headers, timeout=10)
            if 500 <= response.status_code <= 599:
                raise RetryableError(f"GitHub API 服务器错误: {response.status_code}")
            response.raise_for_status()
            for rel in response.json():
                tag_name = rel.get("tag_name") or ""
                if not tag_name.startswith(tag_prefix):
                    continue
                if rel.get("prerelease", False) and not include_pre_release:
                    continue
                return tag_name
            return None

        # 首先尝试获取最新的稳定版release
        url = f"{GITHUB_API_URL}/{repo}/releases/latest"
        response = requests.get(url, headers=headers, timeout=10)
        if 500 <= response.status_code <= 599:
            raise RetryableError(f"GitHub API 服务器错误: {response.status_code}")
        response.raise_for_status()
        data = response.json()
        latest_release = data.get("tag_name")

        if not include_pre_release:
            return latest_release

        # 如果需要检查pre-release，获取所有release并找到最新的（包括pre-release）
        url_all = f"{GITHUB_API_URL}/{repo}/releases"
        response_all = requests.get(url_all, headers=headers, timeout=10)
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


def normalize_tag_to_version(tag: str, tag_prefix: Optional[str] = None) -> str:
    """将 GitHub tag 转为 Guix version（去掉 tag 前缀）。

    有 tag_prefix 时剥离该前缀；否则依次尝试：
      1. npm scoped package tag（形如 ``@scope/name@1.2.3``）——
         取最后一个 ``@`` 之后的部分作为版本号；
      2. 仅去掉前导 'v'（保留原有行为）。
    """
    if tag_prefix:
        if tag.startswith(tag_prefix):
            return tag[len(tag_prefix):]
        return tag.lstrip("v")

    # npm scoped package tag: "@scope/name@version" -> "version"
    # 这类 tag 以 '@' 开头（scope），并在包名后用第二个 '@' 分隔版本号。
    # 取最后一个 '@' 之后的部分作为版本号。
    if tag.startswith("@") and tag.count("@") >= 2:
        return tag.rsplit("@", 1)[1]

    return tag.lstrip("v")


def get_latest_github_tag(repo: str) -> Optional[str]:
    """获取GitHub仓库的最新tag（当没有release时的备用方案）"""
    headers = {}
    if GITHUB_TOKEN:
        headers["Authorization"] = f"token {GITHUB_TOKEN}"

    try:
        url = f"{GITHUB_API_URL}/{repo}/tags"
        response = requests.get(url, headers=headers, timeout=10)
        if 500 <= response.status_code <= 599:
            raise RetryableError(f"GitHub API 服务器错误: {response.status_code}")
        response.raise_for_status()
        tags = response.json()
        if tags:
            return tags[0].get("name")
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


def get_latest_commit(repo: str) -> Optional[Tuple[str, str]]:
    """获取GitHub仓库默认分支的最新commit

    Returns:
        (commit_sha, date_str) 或 None。date_str 格式为 YYYY-MM-DD。
    """
    headers = {}
    if GITHUB_TOKEN:
        headers["Authorization"] = f"token {GITHUB_TOKEN}"

    try:
        url = f"{GITHUB_API_URL}/{repo}/commits"
        response = requests.get(url, headers=headers, timeout=10)
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


def parse_package_definitions(content: str, _file_path: Path) -> list[dict[str, Any]]:
    """解析.scm文件中的包定义"""
    packages = []

    # 使用正则表达式匹配 define-public 后面的包定义
    # 这个正则表达式需要匹配从 (define-public name 到下一个 define-public 或文件结尾

    # 首先找到所有 define-public 的位置
    pattern = r"\(define-public\s+(\S+)"
    matches = list(re.finditer(pattern, content))

    for i, match in enumerate(matches):
        package_name = match.group(1)
        start_pos = match.start()

        # 确定结束位置（下一个 define-public 或文件结尾）
        if i + 1 < len(matches):
            end_pos = matches[i + 1].start()
        else:
            end_pos = len(content)

        package_content = content[start_pos:end_pos]

        # 提取版本号
        version_match = re.search(r'\(version\s+"([^"]+)"', package_content)
        version = version_match.group(1) if version_match else None

        # 提取完整的 URI 表达式
        uri_match = re.search(r"\(uri\s+(.+?)\)\s*\(sha256", package_content, re.DOTALL)
        uri_expr = uri_match.group(1).strip() if uri_match else None

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
                "content": package_content,
                "start_pos": start_pos,
                "end_pos": end_pos,
            }
        )

    return packages


def compare_versions(current_version: str, new_version: str) -> bool:
    """比较两个版本，返回是否需要更新"""
    # 移除版本号前面的'v'前缀
    current = current_version.lstrip("v")
    new = new_version.lstrip("v")

    # 简单的字符串比较（对于语义化版本，可以改进）
    return current != new


def construct_download_url_from_uri(uri_expr: str, version: str) -> Optional[str]:
    """从 uri 表达式构造完整的下载 URL

    解析类似 (string-append "https://..." version "/file.tar.gz") 的表达式
    将 version 变量替换为实际版本号
    """
    # 提取所有字符串字面量和 version 变量
    # 匹配 "string" 或 version 关键字
    tokens = re.findall(r'"([^"]+)"|(?:^|\s)(version)(?:\s|$|\))', uri_expr)

    url_parts = []
    for token in tokens:
        if token[0]:  # 字符串字面量
            url_parts.append(token[0])
        elif token[1] == "version":  # version 变量
            url_parts.append(version)

    if url_parts:
        return "".join(url_parts)
    return None


def get_base32_from_guix_download(url: str) -> Optional[str]:
    """下载文件并计算 SHA256 → Guix base32（纯 Python，不依赖 guix 命令）"""
    try:
        print(f"     🔽 正在下载并计算 base32...")
        response = requests.get(url, timeout=120)
        if 500 <= response.status_code <= 599:
            raise RetryableError(f"HTTP {response.status_code}")
        response.raise_for_status()

        content = response.content
        content_length = response.headers.get("Content-Length")
        if content_length and len(content) != int(content_length):
            print(f"     ⚠️  下载不完整: 预期 {content_length} 字节, 实际 {len(content)} 字节")
            raise RetryableError(f"下载不完整")

        digest = hashlib.sha256(content).digest()
        base32 = _sha256_to_guix_base32(digest)

        if re.fullmatch(r"[0-9a-z]{52}", base32):
            return base32

        print(f"     ⚠️  base32 编码异常")
        return None
    except requests.exceptions.Timeout:
        raise RetryableError("下载超时")
    except requests.exceptions.ConnectionError:
        raise RetryableError("网络连接错误")
    except requests.exceptions.HTTPError as e:
        if is_retryable_http_error(e):
            raise
        print(f"     ⚠️  下载失败: {e}")
        return None
    except RetryableError:
        raise
    except Exception as e:
        print(f"     ⚠️  计算下载 hash 出错: {e}")
        return None


def get_base32_for_git(url: str, ref: str) -> Optional[str]:
    """通过 git clone + NAR 序列化计算 git-fetch 包的 base32 值（纯 Python，不依赖 guix 命令）"""
    tmpdir = tempfile.mkdtemp(prefix="guix-git-hash-")
    try:
        print(f"     🔽 正在克隆源码并计算 base32...")

        is_sha = bool(re.fullmatch(r'[0-9a-f]{40}', ref))

        if is_sha:
            clone_result = subprocess.run(
                ["git", "clone", "--filter=blob:none", url, tmpdir],
                capture_output=True,
                text=True,
                timeout=120,
            )
            if clone_result.returncode == 0:
                checkout_result = subprocess.run(
                    ["git", "checkout", ref],
                    cwd=tmpdir,
                    capture_output=True,
                    text=True,
                    timeout=30,
                )
                if checkout_result.returncode != 0:
                    print(f"     ⚠️  git checkout {ref[:12]} 失败: "
                          f"{checkout_result.stderr.strip()}")
                    return None
        else:
            clone_result = subprocess.run(
                ["git", "clone", "--depth=1", "-b", ref, url, tmpdir],
                capture_output=True,
                text=True,
                timeout=60,
            )

        if clone_result.returncode != 0:
            clone_err = clone_result.stderr.strip()
            if is_retryable_command_failure(clone_err):
                raise RetryableError(f"git clone 失败: {clone_err}")
            print(f"     ⚠️  git clone 失败: {clone_err}")
            return None

        # 统一删除 .git 目录，确保 NAR hash 不含 VCS 元数据
        shutil.rmtree(os.path.join(tmpdir, ".git"), ignore_errors=True)

        # 纯 Python NAR 序列化 + SHA256 + base32
        base32 = compute_nar_base32(tmpdir)

        if base32 and re.fullmatch(r"[0-9a-z]{52}", base32):
            return base32

        print(f"     ⚠️  NAR hash 计算异常")
        return None

    except subprocess.TimeoutExpired as e:
        cmd = " ".join(e.cmd) if isinstance(e.cmd, list) else str(e.cmd)
        raise RetryableError(f"命令超时: {cmd}")
    except FileNotFoundError as e:
        print(f"     ⚠️  未找到命令: {e}")
        return None
    except RetryableError:
        raise
    except Exception as e:
        print(f"     ⚠️  计算 git-fetch base32 出错: {e}")
        return None
    finally:
        shutil.rmtree(tmpdir, ignore_errors=True)


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


def apply_pending_updates(pending: List[Dict[str, Any]]) -> bool:
    """应用所有待写入更新（按文件聚合，每个文件写入一次）"""
    try:
        pending_by_file: Dict[Path, List[Dict[str, Any]]] = {}
        for change in pending:
            file_path = change["file_path"]
            pending_by_file.setdefault(file_path, []).append(change)

        for file_path, changes in pending_by_file.items():
            with open(file_path, "r", encoding="utf-8") as f:
                file_content = f.read()

            # 逆序应用，避免后续替换影响前面区间索引
            for change in sorted(changes, key=lambda c: c["start_pos"], reverse=True):
                start_pos = change["start_pos"]
                end_pos = change["end_pos"]
                package_content = file_content[start_pos:end_pos]

                old_version_pattern = rf'\(version\s+"{re.escape(change["old_version"])}"\)'
                new_version_str = f'(version "{change["new_version"]}")'
                package_content = re.sub(
                    old_version_pattern, new_version_str, package_content, count=1
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

            with open(file_path, "w", encoding="utf-8") as f:
                f.write(file_content)

        return True
    except Exception as e:
        print(f"  ❌ 批量写入失败: {e}")
        return False


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
        resp = requests.get(
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
    resp = requests.post(
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


def main():
    """主函数"""
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
    has_errors = False
    pending_updates: List[Dict[str, Any]] = []
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

            # 检查是否在跳过列表中
            if package_name in skip_packages:
                print(f"     ⏭️  在跳过列表中，已跳过")
                package_report["status"] = "skipped"
                finalize_package_report()
                continue

            if not package["uri_expr"]:
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
                pkg_tag_prefix = tag_prefix_map.get(package_name)

                # --- commit 引用 version 变量：走 release/tag 流程 ---
                if is_version_ref(package["commit_expr"]):
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
                        print(f"     ⚠️  无法获取最新版本信息: {e}")
                        has_errors = True
                        package_report["status"] = "failed"
                        package_report["error"] = f"无法获取最新版本信息: {e}"
                        finalize_package_report()
                        continue

                    if not latest_release:
                        print(f"     ℹ️  无 release，尝试获取最新 tag...")
                        try:
                            latest_release = with_retry(
                                get_latest_github_tag,
                                github_repo,
                                max_retries=2,
                                base_delay=5,
                            )
                            add_retries("get_latest_github_tag")
                        except Exception as e:
                            print(f"     ⚠️  无法获取最新 tag: {e}")
                            has_errors = True
                            package_report["status"] = "failed"
                            package_report["error"] = f"无法获取最新 tag: {e}"
                            finalize_package_report()
                            continue

                    if latest_release:
                        print(f"     最新版本: {latest_release}")

                        # Guix version 字段不含 tag 前缀；剥离前缀得到纯版本号
                        normalized_version = normalize_tag_to_version(latest_release, pkg_tag_prefix)

                        if compare_versions(package["version"], normalized_version):
                            print(f"     ✅ 发现新版本: {latest_release}")
                            package_report["new_version"] = normalized_version

                            try:
                                new_base32 = with_retry(
                                    get_base32_for_git,
                                    git_url,
                                    latest_release,
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
                                has_errors = True
                                package_report["status"] = "failed"
                                package_report["error"] = "无法计算 hash"
                                finalize_package_report()
                                continue

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
                                has_errors = True
                                package_report["status"] = "failed"
                                package_report["error"] = "更新文件失败"
                        else:
                            print(f"     ✓ 版本已是最新")
                            package_report["status"] = "uptodate"
                    else:
                        print(f"     ⚠️  无法获取最新版本信息")
                        package_report["status"] = "failed"
                        package_report["error"] = "无法获取最新版本信息"
                        has_errors = True

                    finalize_package_report()

                # --- commit 是固定 hash：追踪最新 commit ---
                else:
                    current_commit = package["commit_expr"].strip('"')
                    print(f"     📌 固定 commit，追踪最新提交...")

                    try:
                        result = with_retry(
                            get_latest_commit,
                            github_repo,
                            max_retries=2,
                            base_delay=5,
                        )
                        add_retries("get_latest_commit")
                    except Exception as e:
                        result = None
                        print(f"     ⚠️  无法获取最新 commit: {e}")
                        package_report["status"] = "failed"
                        package_report["error"] = f"无法获取最新 commit: {e}"
                        has_errors = True
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
                                has_errors = True
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
                                has_errors = True
                                package_report["status"] = "failed"
                                package_report["error"] = "更新文件失败"
                        else:
                            print(f"     ✓ commit 已是最新")
                            package_report["status"] = "uptodate"
                    else:
                        print(f"     ⚠️  无法获取最新 commit")
                        package_report["status"] = "failed"
                        package_report["error"] = "无法获取最新 commit"
                        has_errors = True

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
                    pkg_tag_prefix = tag_prefix_map.get(package_name)

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
                        has_errors = True
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
                                has_errors = True
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
                                has_errors = True
                                package_report["status"] = "failed"
                                package_report["error"] = "更新文件失败"
                        else:
                            print(f"     ✓ 版本已是最新")
                            package_report["status"] = "uptodate"
                    else:
                        print(f"     ⚠️  无法获取最新release信息")
                        package_report["status"] = "failed"
                        package_report["error"] = "无法获取最新release信息"
                        has_errors = True
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

    try:
        with open(REPORT_FILE, "w", encoding="utf-8") as f:
            json.dump(report, f, ensure_ascii=False, indent=2)
    except Exception as e:
        print(f"⚠️  写入 report.json 失败: {e}")
        has_errors = True

    if failed_packages > 0:
        failed_list = [p for p in report["packages"] if p["status"] == "failed"]
        today = datetime.now().strftime("%Y-%m-%d")
        issue_title = f"🔄 自动更新报告 — {today} — {failed_packages} 个失败"
        issue_body = _build_issue_body(failed_list)
        print()
        create_ci_issue(issue_title, issue_body, config)

    if has_errors:
        return 2
    if has_updates:
        return 1
    return 0


if __name__ == "__main__":
    exit(main())

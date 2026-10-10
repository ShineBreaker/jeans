# SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only
"""纯版本逻辑，零 I/O。"""
import re
from typing import Any, Dict, Optional


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


def package_tag_prefix(package: dict[str, Any], configured_prefixes: dict[str, str]) -> Optional[str]:
    """Return the literal release prefix used by the package's upstream tags.

    ``release-tag-prefix`` in a Guix package is a regular expression (for
    example ``^rust-v``), while the updater needs the literal text to remove
    from a release tag.  The JSON config remains an override for cases where
    the package property cannot be used (such as ``reasonix-desktop-bin``).
    """
    configured = configured_prefixes.get(package["name"])
    if configured:
        return configured

    property_prefix = package.get("release_tag_prefix")
    if property_prefix:
        # The package properties use an anchored prefix regex.  All current
        # channel values are literal prefixes, so only remove the anchor.
        return property_prefix[1:] if property_prefix.startswith("^") else property_prefix
    return None


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

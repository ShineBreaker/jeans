# SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only
#
"""出网请求辅助函数：所有 requests 调用集中于此，统一经公网 URL 校验。

GitHub API 的 URL 由仓库常量与已校验的 repo 参数拼接，请求头可能携带
环境变量令牌。此模块是唯一发出 requests 调用的地方，供 update_versions.py
使用；其余代码不再直接调用 requests。
"""

import ipaddress
import os
from typing import Dict
from urllib.parse import urlsplit

import requests

GITHUB_API_URL = "https://api.github.com/repos"


def ensure_public_http_url(url: str) -> str:
    """校验 URL 只能指向公网 http(s) 主机，拒绝本机/环回/私有/保留地址。

    本脚本的请求 URL 都来自包定义或模块常量（仓库内可信数据），此校验
    是防御性护栏：即使上游 release 元数据被污染，也不会把请求引向内网。
    域名不做 DNS 解析（避免放大攻击面），仅对字面 IP 做地址分类检查。
    """
    parsed = urlsplit(url)
    if parsed.scheme not in ("http", "https"):
        raise ValueError(f"拒绝非 http(s) URL: {url[:80]}")
    host = parsed.hostname
    if not host:
        raise ValueError(f"URL 缺少主机名: {url[:80]}")
    if host == "localhost" or host == "::1":
        raise ValueError(f"拒绝本机地址: {host}")
    try:
        ip = ipaddress.ip_address(host)
    except ValueError:
        return url  # 域名，交由 DNS 解析
    if (ip.is_loopback or ip.is_private or ip.is_link_local
            or ip.is_reserved or ip.is_multicast):
        raise ValueError(f"拒绝非公网地址: {host}")
    return url


def resolve_safe_path(path) -> str:
    """解析写文件目标：消除相对路径与符号链接，防止越界写入。"""
    return os.path.abspath(os.path.realpath(path))


def github_api_get(repo: str, path: str, headers: Dict[str, str]) -> requests.Response:
    """GET GitHub API 端点。repo 必须为 owner/name 格式，path 为相对路径。"""
    url = ensure_public_http_url(f"{GITHUB_API_URL}/{repo}/{path}")
    return requests.get(url, headers=headers, timeout=10)


def head(url: str, timeout: int = 30) -> requests.Response:
    """HEAD 请求；URL 经公网校验后再出网。"""
    checked_url = ensure_public_http_url(url)
    return requests.head(checked_url, timeout=timeout)


def get(url: str, timeout: int = 120) -> requests.Response:
    """GET 请求；URL 经公网校验后再出网。"""
    checked_url = ensure_public_http_url(url)
    return requests.get(checked_url, timeout=timeout)

# SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only
"""qoder-cn 特例处理器：阿里 Qoder 中国版的 electron-builder 更新清单。

上游不给 GitHub release，Linux .deb 只挂在阿里云 OSS 上；官网和下载页给的
是 releases/latest/Qoder-CN-linux-amd64.deb 这个滚动对象——OSS 里一次
CopyObject 出来的副本，每次发版被同名对象原地覆盖，对 Guix 不可用。可用的
是桌面端自更新通道的 electron-builder generic provider 清单：

    https://static.qoder.com.cn/qoder-app/releases/latest-linux.yml

清单字段（0.5.6 实测）：

    version: 0.5.6
    files:
      - url: https://static.qoder.com.cn/qoder-app/releases/0.5.6/Qoder-CN-linux-amd64.deb
        sha256: 7a7d5063…
        size: 292068368
    buildKind: official

三点必须留在处理器里、不能交给通用流程的判断：

1. **下载地址从清单取，不按 version 拼接本地假设**。清单给的是绝对 URL，
   且它才是上游真正分发的那个产物（同一条目带 sha256，可作为现算 hash 的
   交叉校验）。资产目录 releases/<version>/ 里的历史版本一直保留
   （0.3.0 起各版本实测可下载），所以固定到该目录即符合 Guix 的可复现要求。
2. **同版本也要按清单 sha256 重钉**。上游用 CopyObject 重传同名文件，
   version 不变而字节会变（workbuddy-cn 同一结论）；只看 version 的更新器
   会永久停在旧字节上，构建随即 hash mismatch。
3. **buildKind 必须是 official**。该字段区分官方构建与其他通道，非 official
   的版本不进包定义。

清单是 YAML，但 CI 只装 requests（无 PyYAML），这里按行扫描取需要的字段：
顶层 version / buildKind，以及 files 段里 deb 条目的 url + sha256。
"""
import re
from pathlib import Path
from typing import Any, Dict, Optional, Tuple

import requests

from common.changes import update_package_in_file
from common.hashing import _sha256_to_guix_base32, get_base32_from_guix_download
from common.http import ensure_public_http_url, get
from common.retry import RetryableError, with_retry

MANIFEST_URL = "https://static.qoder.com.cn/qoder-app/releases/latest-linux.yml"
# 清单里的资产地址必须落在自家静态域下；返回别处主机时宁可失败，也不把包
# 钉到陌生地址。
ASSET_BASE = "https://static.qoder.com.cn/qoder-app/releases/"
DEB_NAME = "Qoder-CN-linux-amd64.deb"
# 0.5.6 形状：纯数字段。上游用 semver，不带 v 前缀、不带 commit 后缀。
VERSION_RE = re.compile(r"^[0-9]+(?:\.[0-9]+)+$")


def _fetch(url: str) -> requests.Response:
    """GET 一次（公网校验走 common.http），可重试错误抛 RetryableError。"""
    try:
        response = get(ensure_public_http_url(url), timeout=60)
    except requests.exceptions.Timeout as e:
        raise RetryableError(f"请求超时: {e}")
    except requests.exceptions.ConnectionError as e:
        raise RetryableError(f"网络连接错误: {e}")
    if 500 <= response.status_code <= 599:
        raise RetryableError(f"HTTP {response.status_code}")
    return response


def _parse_manifest(text: str) -> Tuple[str, str, str]:
    """latest-linux.yml → (version, deb_url, sha256)。

    只认 files 段里 url 以 DEB_NAME 结尾的条目；缺 version / deb / sha256
    一律视为清单结构不符，抛 RetryableError 而不是把空值写进包定义。
    """
    version = ""
    build_kind = ""
    entries = []
    current = None
    in_files = False

    for raw in text.splitlines():
        line = raw.rstrip()
        if not line or line.lstrip().startswith("#"):
            continue
        if line.startswith("version:"):
            version = line.split(":", 1)[1].strip().strip("'\"")
        elif re.match(r"^files:\s*$", line):
            in_files = True
        elif re.match(r"^[A-Za-z]", line):
            # 顶格键：files 段结束（path / sha512 / releaseDate …）
            in_files = False
            if line.startswith("buildKind:"):
                build_kind = line.split(":", 1)[1].strip().strip("'\"")
        elif in_files:
            matched = re.match(r"^\s*-\s+url:\s*(\S+)\s*$", line)
            if matched:
                current = {"url": matched.group(1).strip("'\"")}
                entries.append(current)
                continue
            field = re.match(r"^\s+(sha256|size):\s*(\S+)\s*$", line)
            if field and current is not None and field.group(1) not in current:
                current[field.group(1)] = field.group(2).strip("'\"")

    if build_kind and build_kind != "official":
        raise RetryableError(f"清单的 buildKind 不是 official: {build_kind}")
    if not VERSION_RE.match(version):
        raise RetryableError(f"版本号形状异常: {version!r}")
    for entry in entries:
        url = entry.get("url", "")
        if url.rsplit("/", 1)[-1] == DEB_NAME:
            sha256 = entry.get("sha256", "").lower()
            if not url.startswith(ASSET_BASE):
                raise RetryableError(f"deb 地址不在静态域下: {url[:100]}")
            if not sha256:
                raise RetryableError(f"{DEB_NAME} 条目缺 sha256")
            return version, url, sha256
    raise RetryableError(f"清单里没有 {DEB_NAME} 条目")


def _version_key(version: str):
    """0.5.6 → (0, 5, 6)；只用于比较，形状已由 VERSION_RE 保证。"""
    return tuple(int(part) for part in version.split("."))


def _pinned_base32(manifest_sha256: str) -> Optional[str]:
    """清单 sha256 → 它对应的 Guix base32；形状不对返回 None。"""
    try:
        digest = bytes.fromhex(manifest_sha256)
    except (TypeError, ValueError):
        return None
    if len(digest) != 32:
        return None
    return _sha256_to_guix_base32(digest)


def _decision(current_version: str, pinned_base32: Optional[str],
              manifest_version: str, manifest_sha256: str) -> str:
    """返回 update（版本变高）、repin（同版本换了字节）或 none。

    版本变低一律 none：CDN 边缘缓存回吐旧清单时不能把包降级。
    """
    try:
        newer = _version_key(manifest_version) > _version_key(current_version)
    except ValueError:
        return "none"
    if newer:
        return "update"
    if manifest_version == current_version and pinned_base32:
        expected = _pinned_base32(manifest_sha256)
        if expected and expected != pinned_base32:
            return "repin"
    return "none"


def update_qoder_cn(package: Dict[str, Any], _config: Dict[str, Any],
                    scm_file: Path) -> Optional[Dict[str, Any]]:
    """Qoder CN：electron-builder 清单定版本与地址，hash 一律现算。"""
    response = _fetch(MANIFEST_URL)
    response.raise_for_status()
    latest, url, sha256 = _parse_manifest(response.text)
    print(f"     更新清单: {latest}  {url}")

    action = _decision(package["version"], package.get("base32"), latest, sha256)
    if action == "none":
        return None

    # 292 MB 的 .deb：workbuddy 同量级给 900 s。
    new_base32 = with_retry(
        get_base32_from_guix_download, url, max_retries=2, base_delay=5,
        timeout=900,
    )
    if (not new_base32 or not re.fullmatch(r"[0-9a-z]{52}", new_base32)
            or re.fullmatch(r"0{52}", new_base32)):
        raise RetryableError("无法计算下载 hash")

    expected = _pinned_base32(sha256)
    if expected and expected != new_base32:
        raise RetryableError(
            f"清单 sha256 与源站实际字节不一致（{latest}）："
            "多半正处在上游原地重传窗口，等下一轮再钉")

    print(f"     {'🔄 重钉 hash' if action == 'repin' else '🆕 新版本'}: {latest}")
    return update_package_in_file(scm_file, package, latest, new_base32)

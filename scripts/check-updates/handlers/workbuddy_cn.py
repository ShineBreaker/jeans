# SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only
"""workbuddy-cn 特例处理器：腾讯 WorkBuddy 中国版，版本只在官方更新通道里。

上游不给 GitHub release，Linux 构建（deb/rpm）只经桌面端更新通道发布：

    主信号  https://download.codebuddy.cn/workbuddy/saas/version.json
    备用    https://copilot.tencent.com/v2/update?platform=workbuddy-linux-x64-deb

主信号与产物同域（CDN 通即可下载），备用信号在清单结构变动时兜底。

两个必须留在处理器里、不能交给通用流程的判断：

1. **版本号带 commit 后缀**。清单的 linux-x64-deb.stable.version 是完整文件名
   主体（<semver>.<build>-<commit>），因此 URI 可由 version 完整重建，不需要
   extra_replacements。上游会用同一数字版本重切构建并换后缀，只比数字版本的
   包永远等不到重钉（flatpark #648 同一结论）。
2. **同版本也要按清单 sha256 重钉**。上游会原地重传同名文件：version 不变而
   字节变了。只看 version 的更新器会永久停在旧字节上，构建随即 hash mismatch。

清单的 sha256 只用来判断「字节变没变」，不作为 pin 的依据：真实 hash 一律从
源站下载后现算。下载走 COS 全球加速端点——CDN 边缘在重传窗口内大陆与海外
字节不一致，按 CDN 算出的 hash 会在另一半地区必然失败。
"""
import re
from pathlib import Path
from typing import Any, Dict, Optional, Tuple

import requests

from common.changes import update_package_in_file
from common.hashing import _sha256_to_guix_base32, get_base32_from_guix_download
from common.http import ensure_public_http_url, get
from common.retry import RetryableError, with_retry

MANIFEST_URL = "https://download.codebuddy.cn/workbuddy/saas/version.json"
FEED_URL = ("https://copilot.tencent.com/v2/update"
            "?platform=workbuddy-linux-x64-deb")
# 与 MANIFEST_URL 同一 COS 桶的全球加速端点：单个对象，各处同字节。
ORIGIN_URL = ("https://acc-1258344699.cos.accelerate.myqcloud.com/workbuddy/"
              "saas/linux-x64-deb/WorkBuddy-linux-x64-deb-{version}.deb")
CDN_DIR = "https://download.codebuddy.cn/workbuddy/saas/linux-x64-deb/"
DEB_PREFIX = "WorkBuddy-linux-x64-deb-"
# 文件名主体：<semver>.<build>-<commit>，例 5.6.2.40046327-c7b525f3
VERSION_RE = re.compile(r"^[0-9]+(?:\.[0-9]+)+-[0-9a-f]+$")


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


def _from_manifest() -> Tuple[str, str]:
    """version.json 的 linux-x64-deb.stable → (version, sha256 hex)。"""
    response = _fetch(MANIFEST_URL)
    response.raise_for_status()
    try:
        entry = response.json()["linux-x64-deb"]["stable"]
        return entry["version"], (entry.get("hash") or "").lower()
    except (ValueError, KeyError, TypeError) as e:
        raise RetryableError(f"清单结构不符合预期: {e}")


def _from_feed() -> Tuple[str, str]:
    """更新接口兜底：文件名主体即版本号。"""
    response = _fetch(FEED_URL)
    response.raise_for_status()
    try:
        payload = response.json()
    except ValueError as e:
        raise RetryableError(f"更新接口返回非 JSON: {e}")
    url = payload.get("url") or ""
    # 只认自家下载域：接口返回别处地址时宁可失败，也不把包钉到陌生主机。
    if not url.startswith(CDN_DIR):
        raise RetryableError(f"更新接口返回了下载域之外的地址: {url[:80]}")
    name = url.rsplit("/", 1)[-1]
    if not (name.startswith(DEB_PREFIX) and name.endswith(".deb")):
        raise RetryableError(f"更新接口返回了无法解析的文件名: {url[:80]}")
    return name[len(DEB_PREFIX):-len(".deb")], (payload.get("sha256hash") or "").lower()


def _version_key(version: str):
    """5.6.2.40046327-c7b525f3 → 可比较元组；数字段按整数比，其余按字典序。"""
    return tuple((0, int(part)) if part.isdigit() else (1, part)
                 for part in re.split(r"[.\-]", version))


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
    if _version_key(manifest_version) > _version_key(current_version):
        return "update"
    if manifest_version == current_version and pinned_base32:
        expected = _pinned_base32(manifest_sha256)
        if expected and expected != pinned_base32:
            return "repin"
    return "none"


def update_workbuddy_cn(package: dict[str, Any], _config: dict[str, Any],
                        scm_file: Path) -> Optional[Dict[str, Any]]:
    """WorkBuddy 中国版：CDN 清单（主）+ 更新接口（备），hash 一律现算。"""
    try:
        latest, sha256 = _from_manifest()
        print(f"     CDN 清单 linux-x64-deb: {latest}")
    except RetryableError as e:
        print(f"     ⚠️  清单不可用（{e}），改用更新接口")
        latest, sha256 = _from_feed()
        print(f"     更新接口最新版: {latest}")

    if not VERSION_RE.match(latest):
        raise RetryableError(f"版本号形状异常: {latest}")

    action = _decision(package["version"], package.get("base32"), latest, sha256)
    if action == "none":
        return None

    url = ORIGIN_URL.format(version=latest)
    # 429 MB 的 .deb：zcode 的 138 MB 给 600 s，这里留足余量。
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

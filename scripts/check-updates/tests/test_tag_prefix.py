#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only
"""Regression checks for release-tag-prefix handling in the updater."""

import json
import re
import sys
import types
from pathlib import Path


sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from common.scm import parse_package_definitions
from common.versions import (
    construct_download_url_from_uri,
    normalize_tag_to_version,
    package_tag_prefix,
)


ROOT = Path(__file__).resolve().parents[3]


def check_release_pagination() -> None:
    """tag_prefix 搜索必须分页扫全列表，固定窗口会被其他系列 release 挤爆。

    trycua/cua 2026-10-29 实证（issue #63）：稳定版 cua-driver-rs-v0.38.0
    已排在 release 列表第 32 位，per_page=30 够不到，updater 误报
    "无法获取最新release信息"。
    """
    try:
        import requests  # noqa: F401
    except ImportError:
        # 无 requests 的环境（本地沙箱）装最小 stub，让 common.http 可导入；
        # 本检查只走 stub 掉的 http.github_api_get，不发起真实请求。
        fake = types.ModuleType("requests")
        fake.Response = type("Response", (), {})
        fake.get = lambda *args, **kwargs: None
        fake.exceptions = types.SimpleNamespace(
            Timeout=Exception,
            ConnectionError=Exception,
            ChunkedEncodingError=Exception,
            HTTPError=Exception,
            RequestException=Exception,
        )
        sys.modules["requests"] = fake

    import common.github as github

    class _Resp:
        def __init__(self, data: list) -> None:
            self._data = data
            self.status_code = 200

        def json(self) -> list:
            return self._data

        def raise_for_status(self) -> None:
            pass

    releases = (
        [
            {
                "tag_name": f"nightly-cua-driver-rs-v0.38.1-nightly.{i:03d}",
                "prerelease": True,
            }
            for i in range(20)
        ]
        + [
            {"tag_name": f"cua-spaces-v0.17.0-beta.{i}", "prerelease": True}
            for i in range(20)
        ]
        + [{"tag_name": "cua-driver-rs-v0.38.0", "prerelease": False}]
    )

    def paged(repo, path, headers):
        page = int(re.search(r"[&?]page=(\d+)", path).group(1))
        return _Resp(releases[(page - 1) * 100 : page * 100])

    github.http.github_api_get = paged
    assert (
        github.get_latest_github_release("trycua/cua", True, "cua-driver-rs-v")
        == "cua-driver-rs-v0.38.0"
    )

    # 反向验证：仅给前 30 条（旧窗口行为）时同一数据必须找不到，
    # 证明上面的断言针对真实失败模式而非恒真。
    github.http.github_api_get = lambda repo, path, headers: _Resp(releases[:30])
    assert (
        github.get_latest_github_release("trycua/cua", True, "cua-driver-rs-v")
        is None
    )

    # 跨页命中：匹配项落在第 2 页。
    big = (
        [
            {"tag_name": f"cua-spaces-v0.17.0-beta.{i}", "prerelease": True}
            for i in range(150)
        ]
        + [{"tag_name": "cua-driver-rs-v0.39.0", "prerelease": False}]
    )

    def paged_big(repo, path, headers):
        page = int(re.search(r"[&?]page=(\d+)", path).group(1))
        return _Resp(big[(page - 1) * 100 : page * 100])

    github.http.github_api_get = paged_big
    assert (
        github.get_latest_github_release("trycua/cua", False, "cua-driver-rs-v")
        == "cua-driver-rs-v0.39.0"
    )

    print("release pagination regression checks passed")


def main() -> None:
    package_file = ROOT / "modules/jeans/packages/agent.scm"
    config_file = ROOT / "scripts/check-updates/config.json"
    packages = {
        package["name"]: package
        for package in parse_package_definitions(
            package_file.read_text(encoding="utf-8"), package_file
        )
    }
    configured_prefixes = json.loads(config_file.read_text(encoding="utf-8"))[
        "tag_prefix"
    ]

    cases = (
        ("reasonix-bin", "v", "v1.17.17", "1.17.17"),
        ("reasonix-studio-bin", "studio-v", "studio-v2.16.0", "2.16.0"),
    )
    for name, prefix, tag, version in cases:
        package = packages[name]
        actual_prefix = package_tag_prefix(package, configured_prefixes)
        normalized = normalize_tag_to_version(tag, actual_prefix)
        download_url = construct_download_url_from_uri(
            package["uri_expr"], normalized
        )
        assert actual_prefix == prefix, (name, actual_prefix)
        assert normalized == version, (name, normalized)
        assert f"/{tag}/" in download_url, (name, download_url)

    check_release_pagination()

    print("release tag prefix regression checks passed")


if __name__ == "__main__":
    main()

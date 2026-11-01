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


class _Resp:
    """stub 掉的 GitHub API 响应（只实现本文件用到的接口）。"""

    def __init__(self, data) -> None:
        self._data = data
        self.status_code = 200

    def json(self):
        return self._data

    def raise_for_status(self) -> None:
        pass


def _import_github():
    """导入 common.github；缺 requests 时装最小 stub。

    本文件所有检查都替换 http.github_api_get，不发起真实请求。
    """
    try:
        import requests  # noqa: F401
    except ImportError:
        # 无 requests 的环境（本地沙箱）装最小 stub，让 common.http 可导入。
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

    return github


def check_release_pagination() -> None:
    """tag_prefix 搜索必须分页扫全列表，固定窗口会被其他系列 release 挤爆。

    trycua/cua 2026-10-29 实证（issue #63）：稳定版 cua-driver-rs-v0.38.0
    已排在 release 列表第 32 位，per_page=30 够不到，updater 误报
    "无法获取最新release信息"。
    """
    github = _import_github()

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


def check_tag_exclude() -> None:
    """tag_exclude 必须跳过并行发布线的 tag，并改走列表扫描。

    TriDefender/zcode-api 2026-10-31 实证（issue #65）：上游先发桌面线
    v4.8.8，随后补发只带 app-debug.apk 的 v4.8.8.android，后者拿到
    Latest 指针；桌面资产只存在于 v4.8.8 下，updater 构造出
    /download/v4.8.8.android/zcode-proxy-linux-x64 后 404，误报
    「无法计算 hash」。
    """
    github = _import_github()

    releases = [
        {"tag_name": "v4.8.8.android", "prerelease": False},
        {"tag_name": "v4.8.8", "prerelease": False},
        {"tag_name": "v4.8.7", "prerelease": False},
    ]
    github.http.github_api_get = lambda repo, path, headers: _Resp(releases)
    assert (
        github.get_latest_github_release(
            "TriDefender/zcode-api", False, None, r"\.android$"
        )
        == "v4.8.8"
    )

    # 反向验证：不带 tag_exclude 时走 /releases/latest，拿到的是 Android
    # 线本身——即真实失败模式，证明上面的断言针对该模式而非恒真。
    def latest_only(repo, path, headers):
        assert path == "releases/latest", path
        return _Resp({"tag_name": "v4.8.8.android"})

    github.http.github_api_get = latest_only
    assert github.get_latest_github_release("TriDefender/zcode-api") == "v4.8.8.android"

    # 配置里的正则本身也要对上：JSON 双反斜杠写错会让过滤静默失效。
    config = json.loads(
        (ROOT / "scripts/check-updates/config.json").read_text(encoding="utf-8")
    )
    pattern = config["tag_exclude"]["zcode-proxy-bin"]
    assert re.search(pattern, "v4.8.8.android"), pattern
    assert not re.search(pattern, "v4.8.8"), pattern

    print("release tag exclude regression checks passed")


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
    check_tag_exclude()

    print("release tag prefix regression checks passed")


if __name__ == "__main__":
    main()

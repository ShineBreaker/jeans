#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only
"""Regression checks for the gh handler's single/double-arch origin shapes.

2026-11-19 issue #101 实证：包定义从 (match ...) 双 arm 收敛为单架构字面
sha256 后，handler 仍按 ("x86_64-linux" "<hash>") 找旧值，每轮报
「包定义里找不到 x86_64-linux 的旧 hash」——gh 因此完全失去自动更新。
本文件同时锁住两种形态。
"""

import sys
import types
from pathlib import Path


sys.path.insert(0, str(Path(__file__).resolve().parent.parent))


def _import_handler():
    """导入 handlers.gh；缺 requests 时装最小 stub（本文件不发真实请求）。"""
    try:
        import requests  # noqa: F401
    except ImportError:
        fake = types.ModuleType("requests")
        fake.exceptions = types.SimpleNamespace(
            Timeout=Exception,
            ConnectionError=Exception,
            ChunkedEncodingError=Exception,
            HTTPError=Exception,
            RequestException=Exception,
        )
        sys.modules["requests"] = fake

    import handlers.gh as gh_handler

    return gh_handler


ROOT = Path(__file__).resolve().parents[3]
GH_FILE = ROOT / "modules/jeans/packages/tools.scm"
OLD_SHA = "07fr7mih1ax8w6jdqymfkgqs8vdcf1nsa0ikhmqfq76fzxw6k02c"
NEW_SHA_X86 = "b" * 52
NEW_SHA_ARM = "c" * 52


def _load_package(text):
    from common.scm import parse_package_definitions

    packages = {
        package["name"]: package
        for package in parse_package_definitions(text, GH_FILE)
    }
    return packages["gh"]


def _stub(gh_handler, releases, hashes):
    calls = []

    def download(url, **_kwargs):
        calls.append(url)
        for suffix, value in hashes.items():
            if url.endswith(suffix):
                return value
        raise AssertionError(f"unexpected asset url: {url}")

    gh_handler.get_latest_github_release = lambda _repo: releases
    gh_handler.get_base32_from_guix_download = download
    return calls


def check_single_arch(gh_handler):
    """单架构字面 sha256：只下载 amd64，hash 走通用 base32 替换。"""
    package = _load_package(GH_FILE.read_text(encoding="utf-8"))
    assert package["base32"] == OLD_SHA, package["base32"]
    calls = _stub(
        gh_handler,
        "v2.103.4",
        {"gh_2.103.4_linux_amd64.tar.gz": NEW_SHA_X86},
    )

    change = gh_handler.update_gh(package, {}, GH_FILE)
    assert change is not None
    assert change["new_version"] == "2.103.4", change["new_version"]
    assert change["new_base32"] == NEW_SHA_X86, change["new_base32"]
    assert len(calls) == 1, calls
    assert calls[0].endswith("gh_2.103.4_linux_amd64.tar.gz"), calls[0]
    # 单架构不再需要 match 内的逐 arm 替换（旧实现正是在这里抛错）。
    assert "extra_replacements" not in change, change.get("extra_replacements")

    print("gh single-arch handler checks passed")


def check_double_arch(gh_handler):
    """(match ...) 双 arm：两个资产都下载，逐 arm 替换旧 hash。"""
    text = GH_FILE.read_text(encoding="utf-8")
    sha_literal = f'(sha256\n        (base32 "{OLD_SHA}"))'
    assert sha_literal in text, "gh sha256 literal shape changed"
    text = text.replace(
        sha_literal,
        f"""(sha256
        (base32
         (match (or (%current-target-system) %current-system)
           ("x86_64-linux" "{OLD_SHA}")
           ("aarch64-linux" "{"0" * 52}"))))""",
        1,
    )
    package = _load_package(text)
    assert package["base32"] is None, package["base32"]
    calls = _stub(
        gh_handler,
        "v2.103.4",
        {
            "gh_2.103.4_linux_amd64.tar.gz": NEW_SHA_X86,
            "gh_2.103.4_linux_arm64.tar.gz": NEW_SHA_ARM,
        },
    )

    change = gh_handler.update_gh(package, {}, GH_FILE)
    assert change is not None
    assert len(calls) == 2, calls
    replacements = dict(change["extra_replacements"])
    assert replacements[f'("x86_64-linux" "{OLD_SHA}")'] == (
        f'("x86_64-linux" "{NEW_SHA_X86}")'
    )
    assert replacements[f'("aarch64-linux" "{"0" * 52}")'] == (
        f'("aarch64-linux" "{NEW_SHA_ARM}")'
    )

    print("gh double-arch handler checks passed")


def main() -> None:
    gh_handler = _import_handler()
    check_single_arch(gh_handler)
    check_double_arch(gh_handler)
    print("gh handler regression checks passed")


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only
"""uri 表达式提取回归检查：file-name 不得被卷入 (uri ...) 捕获。

背景：旧实现用非贪婪正则 `\\(uri\\s+(.+?)\\)\\s*\\(sha256` 提取，当 uri 与
sha256 之间夹着 (file-name ...) 时会把该字段一并捕获，随后
construct_download_url_from_uri 把 file-name 拼进下载 URL 造成 404
（aria2-next-bin 拼出 ...-linux-x86_64aria2-next，2026-10-13 CI 实证）。
"""

import sys
from pathlib import Path


sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from common.scm import parse_package_definitions
from common.versions import construct_download_url_from_uri


ROOT = Path(__file__).resolve().parents[3]

TAIL_SCM = """\
(define-public sample-bin
  (package
    (name "sample-bin")
    (version "1.0.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://example.com/download/"
             "v" version "/sample-" version "-linux-x86_64"))
       (file-name "sample")
       (sha256
        (base32
         "0000000000000000000000000000000000000000000000000000"))))))
"""


def load_packages(package_file: Path) -> dict:
    return {
        p["name"]: p
        for p in parse_package_definitions(
            package_file.read_text(encoding="utf-8"), package_file
        )
    }


def check_real_package() -> None:
    """真实包：aria2-next-bin 的 URL 构造不再多出 file-name 尾巴。"""
    packages = load_packages(ROOT / "modules/jeans/packages/tools.scm")
    pkg = packages["aria2-next-bin"]
    assert "file-name" not in pkg["uri_expr"], pkg["uri_expr"]
    for version in ("2.8.6", "3.0.1"):
        url = construct_download_url_from_uri(pkg["uri_expr"], version)
        assert url == (
            "https://github.com/AnInsomniacy/aria2-next/releases/download/"
            f"v{version}/aria2-next-{version}-linux-x86_64"
        ), url


def check_git_package() -> None:
    """git 包：uri_expr 不再卷入 file-name，url/commit 提取不受影响。"""
    packages = load_packages(ROOT / "modules/jeans/packages/tools.scm")
    pkg = packages["agenote"]
    assert "file-name" not in pkg["uri_expr"], pkg["uri_expr"]
    assert pkg["git_url"] == "https://github.com/ShineBreaker/agenote", pkg["git_url"]
    assert pkg["commit_expr"] == '(string-append "agenote-v" version)', pkg[
        "commit_expr"
    ]


def check_synthetic_tail() -> None:
    """合成样例：uri 与 sha256 之间夹 file-name，URL 与 base32 提取均正确。"""
    packages = {
        p["name"]: p
        for p in parse_package_definitions(TAIL_SCM, Path("/tmp/sample.scm"))
    }
    pkg = packages["sample-bin"]
    assert "file-name" not in pkg["uri_expr"], pkg["uri_expr"]
    assert pkg["base32"] == "0" * 52, pkg["base32"]
    url = construct_download_url_from_uri(pkg["uri_expr"], "2.0.0")
    assert url == "https://example.com/download/v2.0.0/sample-2.0.0-linux-x86_64", url


def main() -> None:
    check_real_package()
    check_git_package()
    check_synthetic_tail()
    print("uri expression extraction regression checks passed")


if __name__ == "__main__":
    main()

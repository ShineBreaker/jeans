#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only
"""Regression checks for shared-variable sources (nosdshell-like packages).

包体只写 (version %v)/(source %s)，真值在模块级 define 里。
覆盖：正例解析、负例（不带 % 前缀的普通变量、let-git-version、缺一半引用）、
落盘三处替换且不误伤同版本字面量的其它包。
"""

import importlib.util
import subprocess
import tempfile
from pathlib import Path
from unittest.mock import patch


UPDATER_PATH = Path(__file__).with_name("update_versions.py")


def load_updater():
    spec = importlib.util.spec_from_file_location("jeans_update_versions", UPDATER_PATH)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load {UPDATER_PATH}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


SHARED_SCM = """\
(define-module (jeans packages sample))

(define %sample-version "1.0.0")
(define %sample-commit "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")

(define %sample-source
  (origin
    (method git-fetch)
    (uri (git-reference
          (url "https://github.com/example/sample")
          (commit %sample-commit)))
    (file-name (git-file-name "sample" %sample-version))
    (sha256
     (base32
      "0000000000000000000000000000000000000000000000000000"))))

(define-public sample-a
  (package
    (name "sample-a")
    (version %sample-version)
    (source %sample-source)))

(define-public sample-b
  (package
    (name "sample-b")
    (version %sample-version)
    (source %sample-source)))

(define-public decoy
  (package
    (name "decoy")
    (version "1.0.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://example.com/decoy-" version ".tar.gz"))
       (sha256
        (base32
         "1111111111111111111111111111111111111111111111111111"))))))
"""


def check_tag_peel(updater) -> None:
    """get_tag_commit_sha：annotated tag 取 ^{} peel 行、lightweight 取 tag 行、
    无 tags 命中回 None；argv 必须同时传 <tag> 与 <tag>^{}（单 pattern 的精确
    匹配不会带回 ^{} 行，2026-10-10 审查实证）。"""
    tag_line = "1" * 39 + "a\trefs/tags/v1.1.1\n"
    peel_line = "b" * 40 + "\trefs/tags/v1.1.1^{}\n"
    branch_line = "d" * 40 + "\trefs/heads/main\n"
    cases = [
        (tag_line + peel_line, "b" * 40),
        (tag_line, "1" * 39 + "a"),
        (branch_line, None),
    ]
    for stdout, expected in cases:
        captured = []

        def run(cmd, **kwargs):
            captured.append(cmd)
            return subprocess.CompletedProcess(cmd, 0, stdout=stdout, stderr="")

        with patch.object(updater.subprocess, "run", run):
            got = updater.get_tag_commit_sha(
                "https://github.com/example/sample", "v1.1.1"
            )
        assert got == expected, (stdout, got, expected)
        assert captured[0][-2:] == ["v1.1.1", "v1.1.1^{}"], captured[0]


def check_apply_atomicity(updater) -> None:
    """三处 define 任一找不到旧值时整体失败，文件保持原样（不半写）。"""
    with tempfile.NamedTemporaryFile(
        "w", suffix=".scm", delete=False, encoding="utf-8"
    ) as f:
        f.write(SHARED_SCM)
        tmp = Path(f.name)
    try:
        pkgs = {
            p["name"]: p
            for p in updater.parse_package_definitions(
                tmp.read_text(encoding="utf-8"), tmp
            )
        }
        change = updater.build_shared_source_change(
            tmp, pkgs["sample-a"], "1.1.0", "b" * 40, "5" * 52
        )
        assert change is not None
        # 模拟并发改动：version define 已被别处改掉，落盘应整体失败
        tmp.write_text(
            tmp.read_text(encoding="utf-8").replace(
                '(define %sample-version "1.0.0")',
                '(define %sample-version "1.0.1")',
            ),
            encoding="utf-8",
        )
        before = tmp.read_text(encoding="utf-8")
        assert updater.apply_pending_updates([change]) is False
        assert tmp.read_text(encoding="utf-8") == before
    finally:
        tmp.unlink()


def main() -> None:
    updater = load_updater()
    fake_path = Path("/tmp/sample.scm")
    packages = {
        p["name"]: p
        for p in updater.parse_package_definitions(SHARED_SCM, fake_path)
    }

    # 正例：两个引用包都解析出共享真值
    for name in ("sample-a", "sample-b"):
        p = packages[name]
        assert p["is_shared_source"] is True, (name, p["is_shared_source"])
        assert p["version"] == "1.0.0", (name, p["version"])
        assert p["git_url"] == "https://github.com/example/sample", (name, p["git_url"])
        assert p["commit_expr"] == "%sample-commit", (name, p["commit_expr"])
        assert p["shared_commit_var"] == "%sample-commit", (name, p["shared_commit_var"])
        assert p["shared_commit_value"] == "a" * 40, (name, p["shared_commit_value"])
        assert p["base32"] == "0" * 52, (name, p["base32"])
        assert p["method"] == "git-fetch", (name, p["method"])
        assert p["is_git"] is True, name
        assert p["shared_version_var"] == "%sample-version", name
        assert p["shared_source_var"] == "%sample-source", name

    # 负例 1：字面量 version 的普通包不受影响
    decoy = packages["decoy"]
    assert decoy["is_shared_source"] is False, decoy
    assert decoy["version"] == "1.0.0", decoy["version"]
    assert decoy["shared_version_var"] is None, decoy
    assert decoy["shared_source_var"] is None, decoy

    # 负例 2：不带 % 前缀的普通 define 变量不被误抓
    plain = """\
(define foo-version "9.9.9")

(define-public foo
  (package
    (name "foo")
    (version "1.2.3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://example.com/foo-" version ".tar.gz"))
       (sha256 (base32 "2222222222222222222222222222222222222222222222222222"))))))
"""
    foo = updater.parse_package_definitions(plain, fake_path)[0]
    assert foo["is_shared_source"] is False, foo
    assert foo["version"] == "1.2.3", foo["version"]

    # 负例 3：let-git-version 包（version 是表达式）不被误抓
    let_scm = """\
(define-public bar
  (package
    (name "bar")
    (version (git-version "0" "1" commit))
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/example/bar")
             (commit commit)))
       (sha256 (base32 "3333333333333333333333333333333333333333333333333333"))))))
"""
    bar = updater.parse_package_definitions(let_scm, fake_path)[0]
    assert bar["is_shared_source"] is False, bar

    # 负例 4：只有 (version %v) 没有 (source %s)，不 resolve，回落旧行为
    half = """\
(define %half-version "2.0.0")

(define-public half
  (package
    (name "half")
    (version %half-version)
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://example.com/half-" version ".tar.gz"))
       (sha256 (base32 "4444444444444444444444444444444444444444444444444444"))))))
"""
    half_pkg = updater.parse_package_definitions(half, fake_path)[0]
    assert half_pkg["is_shared_source"] is False, half_pkg
    assert half_pkg["version"] is None, half_pkg["version"]

    # 落盘：三处替换生效，且同版本字面量的 decoy 包未被误改
    with tempfile.NamedTemporaryFile(
        "w", suffix=".scm", delete=False, encoding="utf-8"
    ) as f:
        f.write(SHARED_SCM)
        tmp = Path(f.name)
    try:
        pkgs = {
            p["name"]: p
            for p in updater.parse_package_definitions(
                tmp.read_text(encoding="utf-8"), tmp
            )
        }
        change = updater.build_shared_source_change(
            tmp, pkgs["sample-a"], "1.1.0",
            "b" * 40, "5" * 52,
        )
        assert change is not None
        assert change["is_shared_source"] is True
        assert updater.apply_pending_updates([change]) is True
        out = tmp.read_text(encoding="utf-8")
        assert '(define %sample-version "1.1.0")' in out, out
        assert f'(define %sample-commit "{"b" * 40}")' in out, out
        assert f'(base32 "{"5" * 52}")' in out, out
        # decoy 的字面量 version 与 base32 原样保留
        assert '(version "1.0.0")' in out, out
        assert '(base32\n         "1111111111111111111111111111111111111111111111111111")' in out, out
        # 引用关系未被破坏
        assert "(version %sample-version)" in out, out
        assert "(source %sample-source)" in out, out
        assert "(commit %sample-commit)" in out, out
    finally:
        tmp.unlink()

    check_tag_peel(updater)
    check_apply_atomicity(updater)

    print("shared-variable source regression checks passed")


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only
"""Regression checks for the guix refresh blacklist driver (`refresh_all.py`).

纯函数测试：解析、守卫规则、黑名单与分块。不发网络请求、不调用 guix。
"""

import json
import sys
import tempfile
from pathlib import Path


sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from refresh_all import (  # noqa: E402
    chunks,
    guard,
    run_batched,
    is_prerelease,
    numeric_prefix,
    parse_upgrades,
    plan,
    read_excludes,
    read_packages,
)


SAMPLE_LOG = """
guix refresh: warning: ambiguous package specification `tuned'
/home/x/modules/jeans/packages/zig.scm:149:15: zig-zigimg would be upgraded from 0.1.0-1.d695acd to 0.17.0
/home/x/modules/jeans/packages/browser.scm:233:13: zen-browser-bin would be upgraded from 1.24.3b to 1.24b
/home/x/modules/jeans/packages/agent.scm:2506:13: eta-host-bin would be upgraded from 0.4.0 to 0.5.0-rc.15
/home/x/modules/jeans/packages/agent.scm:2606:2: warning: no updater for eta-desktop-bin
/home/x/modules/jeans/packages/tools.scm:1611:13: 0.46.1 is already the latest version of zellij-bin
/home/x/modules/jeans/packages/emacs-xyz.scm:871:2: agenote would be upgraded from 0.4.0 to zcode-v0.1.0
/home/x/modules/jeans/packages/desktop.scm:1:1: some-pkg would be upgraded from 1.9.0 to 1.10.0
"""


def check_parse() -> None:
    upgrades = parse_upgrades(SAMPLE_LOG)
    assert set(upgrades) == {
        "zig-zigimg",
        "zen-browser-bin",
        "eta-host-bin",
        "agenote",
        "some-pkg",
    }, upgrades
    assert upgrades["some-pkg"] == ("1.9.0", "1.10.0")

    # 空输出与只有 warning 的输出都不能炸
    assert parse_upgrades("") == {}
    assert parse_upgrades("warning: no tags were found for zig-aro\n") == {}


def check_prerelease() -> None:
    for version in (
        "0.5.0-rc.15",
        "1.0.0-alpha1",
        "2.0.0beta",
        "0-unstable-2026-01-01",
        "1.2.3-nightly-20260101",
        "1.0.0-pre",
        "0.1.0-rc22",
    ):
        assert is_prerelease(version), version
    for version in ("0.4.0", "1.22b", "2026.11.28", "1.0.0", "0.2.0-zig-0.16"):
        # 0.2.0-zig-0.16 里的 zig 不是 prerelease 标记
        assert not is_prerelease(version), version


def check_numeric_prefix() -> None:
    assert numeric_prefix("1.24.3b") == (1, 24, 3)
    assert numeric_prefix("0.5.0-rc.15") == (0, 5, 0)
    assert numeric_prefix("20260101") == (20260101,)
    assert numeric_prefix("v1.2.3") is None
    assert numeric_prefix("zcode-v0.1.0") is None


def check_guard() -> None:
    # 正常升级
    assert guard("0.3.7", "0.3.8") is None
    assert guard("1.9.0", "1.10.0") is None
    assert guard("0.1.0-rc.20", "0.1.0-rc.22") is None  # 本来就跟踪 rc 线
    assert guard("2026-01-01", "2026-02-01") is None
    assert guard("1.0.0", "2.0.0") is None

    # G1 tag 误读
    assert "G1" in guard("0.4.0", "zcode-v0.1.0")
    assert "G1" in guard("0.4.0", "upstream/1.1.1")
    # G2 正式版被推到 prerelease（eta-host-bin / ellsp 类命中）
    assert "G2" in guard("0.4.0", "0.5.0-rc.15")
    assert "G2" in guard("0.1.0", "0.2.0-beta1")
    # G3 降级与数字段缩短（zen-browser-bin）
    assert "G3" in guard("1.24.3b", "1.24b")
    assert "G3" in guard("2.0.0", "1.9.0")
    assert "G3" in guard("1.10.0", "1.9.0")
    # G4 无变化
    assert "G4" in guard("2.0.0", "2.0.0")


def check_plan_and_excludes() -> None:
    packages = [
        "agenote",
        "cargo-hua",
        "eta-host-bin",
        "some-pkg",
        "untouched-pkg",
        "zen-browser-bin",
    ]
    excludes = {"cargo-hua": "rustc 1.99 MSRV 未到", "ghostty": "zig 0.17"}
    decisions, skipped = plan(packages, excludes, parse_upgrades(SAMPLE_LOG))
    by_name = {d.name: d for d in decisions}

    assert skipped == ["cargo-hua"], skipped
    assert "untouched-pkg" not in by_name  # refresh 没报 → 无更新，不判定
    assert by_name["some-pkg"].verdict == "accept"
    assert by_name["eta-host-bin"].verdict == "reject"
    assert "G2" in by_name["eta-host-bin"].reason
    assert by_name["agenote"].verdict == "reject"
    assert "G1" in by_name["agenote"].reason
    assert by_name["zen-browser-bin"].verdict == "reject"

    accepted = sorted(d.name for d in decisions if d.verdict == "accept")
    assert accepted == ["some-pkg"], accepted


def check_chunks() -> None:
    assert chunks([], 8) == []
    assert chunks(list("abcdefghij"), 4) == [
        list("abcd"),
        list("efgh"),
        list("ij"),
    ]
    assert chunks(["a"], 1) == [["a"]]


def check_files() -> None:
    with tempfile.TemporaryDirectory() as tmp:
        packages = Path(tmp, "packages.txt")
        packages.write_text("# comment\nfoo\n\nbar\nfoo\n", encoding="utf-8")
        assert read_packages(str(packages)) == ["bar", "foo"]

        config = Path(tmp, "config.json")
        config.write_text(
            json.dumps({"refresh_exclude": {"foo": "理由"}}), encoding="utf-8"
        )
        assert read_excludes(str(config)) == {"foo": "理由"}
        # 缺文件/缺键都返回空表，不能让 CI 因为配置缺失而中断
        assert read_excludes(str(Path(tmp, "nope.json"))) == {}
        config.write_text("{}", encoding="utf-8")
        assert read_excludes(str(config)) == {}


def check_real_config() -> None:
    """仓库里的 config.json 必须能被解析，且 refresh_exclude 每条都有理由。"""
    root = Path(__file__).resolve().parents[3]
    config_path = root / "scripts" / "check-updates" / "config.json"
    excludes = read_excludes(str(config_path))
    assert excludes, "config.json 缺少 refresh_exclude"
    for name, reason in excludes.items():
        assert reason.strip(), f"{name} 的排除理由为空"
    # 已知必须排除的包（冻结或 refresh 会写坏版本）
    for name in ("cargo-hua", "ghostty", "gamescope", "scrcpy", "librewolf-nongnu"):
        assert name in excludes, f"{name} 应当留在 refresh_exclude 里"
    # 由守卫兜住、不需要排除的包
    for name in ("eta-host-bin", "eta-desktop-bin", "zen-browser-bin"):
        assert name not in excludes, f"{name} 应由守卫处理，不该进黑名单"



def check_run_batched() -> None:
    """用假 guix 验证分块、重试与逐包降级（不发网络、不写盘）。"""
    import os
    import stat

    with tempfile.TemporaryDirectory() as tmp:
        calls = Path(tmp, "calls.txt")
        fake = Path(tmp, "guix")
        fake.write_text(
            "#!/bin/sh\n"
            f'echo "$@" >> {calls}\n'
            'case "$*" in\n'
            "  *boom*) exit 1;;\n"
            "esac\n"
            "exit 0\n",
            encoding="utf-8",
        )
        fake.chmod(fake.stat().st_mode | stat.S_IEXEC)

        out, failed = run_batched(
            str(fake),
            ["/abs/modules"],
            ["aaa", "boom", "bbb"],
            apply=False,
            chunk_size=3,
            retries=1,
            timeout=30,
        )
        assert failed == ["boom"], failed
        recorded = calls.read_text(encoding="utf-8").splitlines()
        # 整块两次（首跑 + 重试）→ 逐包三次 → 共 5 次调用
        assert len(recorded) == 5, recorded
        assert all("-L /abs/modules" in line for line in recorded), recorded
        assert not any("-u" in line for line in recorded), recorded

        # apply 模式必须带上 -u
        calls.write_text("", encoding="utf-8")
        run_batched(
            str(fake),
            ["/abs/modules"],
            ["aaa"],
            apply=True,
            chunk_size=8,
            retries=0,
            timeout=30,
        )
        assert "-u" in calls.read_text(encoding="utf-8"), calls.read_text()

        # 全挂的块不能无限重试：单个包失败一次即放弃
        calls.write_text("", encoding="utf-8")
        _, failed = run_batched(
            str(fake), [], ["boom"], apply=False, chunk_size=8, retries=2, timeout=30
        )
        assert failed == ["boom"], failed
        assert len(calls.read_text(encoding="utf-8").splitlines()) == 3  # 首跑 + 2 重试


def main() -> None:
    check_parse()
    check_prerelease()
    check_numeric_prefix()
    check_guard()
    check_plan_and_excludes()
    check_chunks()
    check_files()
    check_real_config()
    check_run_batched()
    print("refresh blacklist driver checks passed")


if __name__ == "__main__":
    main()

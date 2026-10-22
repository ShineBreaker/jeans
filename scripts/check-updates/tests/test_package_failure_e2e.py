#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only
"""端到端验证：包级失败时退出码不是 2。

不联网：把 handler 换成一个必然抛 RetryableError 的假实现（模拟 jdtls-bin
在 Eclipse 临时关站时的失败），确认 main() 仍返回 0/1 而非 2，且
report.json 里 package_failures 为真、script_errors 为假。
"""
import json
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(HERE))

import update_versions as uv
from common.retry import RetryableError


def main() -> None:
    calls = {"n": 0}

    def failing_handler(package, config, scm_file):
        calls["n"] += 1
        raise RetryableError("模拟：上游临时故障")

    # 只让一个包走特殊源路径，其余包全部跳过，避免联网
    uv.SPECIAL_UPDATERS.clear()
    uv.SPECIAL_UPDATERS["jdtls-bin"] = failing_handler
    uv.find_scm_files = lambda d: [HERE.parent.parent / "modules/jeans/packages/tools.scm"]
    uv.check_stale_packages = lambda *a, **k: None

    original_parse = uv.parse_package_definitions

    def fake_parse(content, path):
        pkgs = original_parse(content, path)
        return [
            p for p in pkgs
            if p["name"] in ("jdtls-bin", "prettier-bin")
        ]

    uv.parse_package_definitions = fake_parse
    # 不写 report.json 到真实路径，避免污染仓库
    uv.REPORT_FILE = Path("/tmp/agenote-test-report.json")
    # 退避压到 0：测试只关心「是否重试」，不等真实退避时长
    import common.retry as retry_mod
    retry_mod.time.sleep = lambda _s: None

    rc = uv.main()
    print(f"\nhandler 被调用 {calls['n']} 次")
    print(f"退出码 = {rc}")

    assert rc != 2, f"包级失败不应返回 2，实际 {rc}（会挡住整批更新）"
    assert calls["n"] >= 2, f"with_retry 应重试，实际调用 {calls['n']} 次"

    report = json.loads(Path("/tmp/agenote-test-report.json").read_text())
    assert report["package_failures"] is True, report
    assert report["script_errors"] is False, report
    assert report["failed"] >= 1, report
    print(f"report: failed={report['failed']} "
          f"package_failures={report['package_failures']} "
          f"script_errors={report['script_errors']}")
    print("端到端检查通过：包级失败 + 重试 → 退出码非 2")


if __name__ == "__main__":
    main()

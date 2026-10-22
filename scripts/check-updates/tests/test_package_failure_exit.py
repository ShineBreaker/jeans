#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only
"""包级失败不得影响退出码。

issue #59（2026-10-22）：单个包的检查失败让 update_versions.py 返回 2，
auto-update.yml 的 `exit 2` 使 Detect changes / Build test / Commit 全被
跳过，一包失败挡住整批更新。

契约：
- 包级失败（status == "failed"）只进 issue，成功包的更新照常提交；
  退出码仍按「有更新=1 / 无更新=0」给。
- 脚本级错误（读 .scm 失败、写盘失败）才返回 2。
"""

import ast
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from common.scm import parse_package_definitions

UPDATER = Path(__file__).resolve().parent.parent / "update_versions.py"
SOURCE = UPDATER.read_text(encoding="utf-8")
TREE = ast.parse(SOURCE)


def _main_fn() -> ast.FunctionDef:
    for node in ast.walk(TREE):
        if isinstance(node, ast.FunctionDef) and node.name == "main":
            return node
    raise AssertionError("找不到 main 函数")


def _assigned_names(fn: ast.FunctionDef) -> set[str]:
    names: set[str] = set()
    for node in ast.walk(fn):
        if isinstance(node, ast.Name) and isinstance(node.ctx, ast.Store):
            names.add(node.id)
    return names


def main() -> None:
    fn = _main_fn()
    stores = _assigned_names(fn)

    # 1) has_errors 必须还��在（脚本级错误仍需中止流水线）
    assert "has_errors" in stores, "脚本级错误标志缺失"

    # 2) has_errors 只允许在脚本级错误点被置位。
    #    判据：置位处要么是函数级 try/except（读 .scm、写 report.json、
    #    apply_pending_updates），要么紧邻 package_report["status"]="failed"
    #    之外——即包级失败点不得再置 has_errors。
    package_level = 0
    script_level = 0
    for node in ast.walk(fn):
        if (
            isinstance(node, ast.Assign)
            and len(node.targets) == 1
            and isinstance(node.targets[0], ast.Name)
            and node.targets[0].id == "has_errors"
            and isinstance(node.value, ast.Constant)
            and node.value.value is True
        ):
            # 向上找最近的 package_report status 赋值
            line = node.lineno
            src_lines = SOURCE.splitlines()
            window = "\n".join(src_lines[max(0, line - 6) : line])
            if 'package_report["status"] = "failed"' in window:
                package_level += 1
            else:
                script_level += 1

    assert package_level == 0, (
        f"包级失败仍在置 has_errors（{package_level} 处），会让退出码变 2"
    )
    assert script_level >= 3, (
        f"脚本级错误点缺失（当前 {script_level} 处，应至少 3：读 .scm、"
        "apply 写盘、report 写盘）"
    )

    # 3) 退出码：脚本级错误 -> 2（包目录缺失/无 .scm/写盘失败），有更新 -> 1，
    #    否则 0。返回 2 的点可以有多处，但都必须是脚本级早退。
    returns = [
        node.value.value
        for node in ast.walk(fn)
        if isinstance(node, ast.Return)
        and isinstance(node.value, ast.Constant)
        and node.value.value in (0, 1, 2)
    ]
    assert returns.count(1) == 1, f"退出码 1 的返回点应唯一：{returns}"
    assert returns.count(0) == 1, f"退出码 0 的返回点应唯一：{returns}"
    assert returns.count(2) >= 1, "缺少退出码 2 的返回点"

    # 4) 报告里两类失败分开记账
    assert '"package_failures"' in SOURCE, "report.json 未记录 package_failures"
    assert '"script_errors"' in SOURCE, "report.json 未记录 script_errors"

    print("package failure exit-code checks passed")


if __name__ == "__main__":
    main()

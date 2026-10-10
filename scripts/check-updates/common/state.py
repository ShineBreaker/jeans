# SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only

"""stale 包监控：手动更新判别与提醒。"""

import json
import os
import subprocess
from datetime import datetime
from pathlib import Path
from typing import Any, Dict, List

from common.issues import create_ci_issue
from common.paths import STALE_STATE_FILE
from common.scm import parse_package_definitions


# 自动更新提交的 subject 标记。git log --since 回溯窗口（stale_days）内
# 新旧两种格式的自动提交会并存，判别手动更新时须同时排除。
AUTO_COMMIT_MARKERS = (
    "feat(packages): auto package update",  # Conventional Commits（2026-08-19 起）
    "UPDATE: auto package update",          # 旧前缀风格（历史提交）
)


def _package_manually_updated(
    pkg_name: str, since_date: str, scm_files: List[Path]
) -> bool:
    """判断该包定义区间在 since_date 之后是否有非自动更新的提交。

    用 git log -L 精确跟随该包的定义区间（行号跟随跨提交），只统计
    触碰该区间的提交；自动更新提交（subject 含 AUTO_COMMIT_MARKERS
    之一）不算手动更新。文件级判定不可靠：同文件的
    其他包（如 tools.scm 的 agenote）变动会误判。
    """
    for scm in scm_files:
        try:
            content = scm.read_text(encoding="utf-8")
        except OSError:
            continue
        if pkg_name not in content:
            continue
        try:
            pkg = next(
                (p for p in parse_package_definitions(content, scm)
                 if p["name"] == pkg_name),
                None,
            )
        except Exception:
            return False
        if pkg is None:
            return False
        start_line = content.count("\n", 0, pkg["start_pos"]) + 1
        end_line = content.count("\n", 0, pkg["end_pos"]) + 1
        try:
            result = subprocess.run(
                ["git", "log", f"--since={since_date}",
                 "-L", f"{start_line},{end_line}:{scm}",
                 "--pretty=format:%x00%H%n%s"],
                capture_output=True, text=True, timeout=20,
            )
        except Exception:
            return False
        # 每个触碰提交输出 "\0hash\nsubject"，diff 内容在后面，不影响判别
        for entry in result.stdout.split("\x00"):
            lines = [ln for ln in entry.splitlines() if ln]
            if len(lines) >= 2 and not any(m in lines[1] for m in AUTO_COMMIT_MARKERS):
                print(f"⏰ {pkg_name}: 检测到手动更新提交（{lines[1][:60]}）")
                return True
    return False


def check_stale_packages(scm_files: List[Path], config: Dict[str, Any]) -> None:
    """对 config['stale_watch'] 中的包：超 stale_days 天无手动更新则发提醒 issue。

    这些包无法自动更新（继承上游 / 有意冻结），只能靠人工跟进。用
    stale-state.json 记录上次提醒日期，避免每次 CI 重复轰炸（幂等 issue
    标题 + 14 天周期双保险）。手动更新（该包所在 .scm 文件的非自动更新
    提交）会重置周期。仅 CI 环境生效。
    """
    if not os.environ.get("CI"):
        return
    stale_watch = config.get("stale_watch", {})
    if not stale_watch:
        return
    stale_days = int(config.get("stale_days", 14))

    state: Dict[str, Any] = {}
    if STALE_STATE_FILE.exists():
        state = json.loads(STALE_STATE_FILE.read_text(encoding="utf-8"))

    today = datetime.now().strftime("%Y-%m-%d")
    state_changed = False

    for pkg_name, reason in stale_watch.items():
        last_checked = state.get(pkg_name, {}).get("last_checked")
        if last_checked is None:
            # 首次纳入监控：记基线，不动作
            state[pkg_name] = {"last_checked": today}
            state_changed = True
            print(f"⏰ {pkg_name}: 首次纳入 stale 监控（{today}）")
            continue
        if _package_manually_updated(pkg_name, last_checked, scm_files):
            state[pkg_name] = {"last_checked": today}
            state_changed = True
            print(f"⏰ {pkg_name}: 已有手动更新，重置提醒周期")
            continue
        days = (datetime.now() - datetime.strptime(last_checked, "%Y-%m-%d")).days
        if days < stale_days:
            print(f"⏰ {pkg_name}: 距上次提醒 {days} 天，未到 {stale_days} 天阈值")
            continue
        # 标题必须与天数无关：_issue_exists 按标题精确匹配防重，
        # 天数嵌进标题会让每次提醒的标题都不同，查重失效（重复发 issue）。
        title = f"⏰ 包 {pkg_name} 长期未手动更新，需要人工检查"
        body = (
            f"**{pkg_name}** 属于无法自动更新的包，已 {days} 天无手动更新。\n\n"
            f"原因：{reason}\n\n"
            f"请手动检查并决定是否更新。若已处理，请关闭本 issue。"
        )
        print(f"⏰ {pkg_name}: 已 {days} 天未更新，发起提醒 issue")
        create_ci_issue(title, body, config)
        state[pkg_name] = {"last_checked": today}
        state_changed = True

    if state_changed:
        try:
            STALE_STATE_FILE.write_text(
                json.dumps(state, indent=2, ensure_ascii=False) + "\n",
                encoding="utf-8",
            )
            print(f"📝 已更新 stale-state.json")
        except Exception as e:
            print(f"⚠️  写入 stale-state.json 失败: {e}")

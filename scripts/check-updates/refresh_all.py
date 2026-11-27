#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only
#
"""
guix refresh 的“黑名单 + 守卫”驱动器。

## 为什么需要它

CI 以前把“归 guix refresh 管的包”写成 `REFRESH_PACKAGES` 白名单。白名单的
失效方式是静默的：新包忘了加进去就永远收不到 refresh 更新，而且不报错。
这里改成黑名单——默认对**全通道**包跑 refresh，只有显式列进
`config.json` 的 `refresh_exclude` 才跳过（每条要写理由）。

## 守卫（`--plan` 阶段）

refresh 有几个已知的静默错误升级模式（见 auto-update skill 与
`conventions-refresh.md` 的盲区清单），黑名单模型必须挡在写盘之前。所以先跑
不带 `-u` 的 dry-run（guix refresh 默认就是只报告不改写），解析出
“would be upgraded from OLD to NEW”，过一遍 `guard()`，只有通过的包才进
`--apply` 的名单：

G1 NEW 不以数字开头（兄弟组件 tag、`upstream/1.1.1` 之类被误读成版本）
G2 OLD 是正式版而 NEW 带 pre-release 标记（`rc`/`alpha`/`beta`/`pre`/…）
   ——命中 guix github updater「首页 30 条全是 prerelease 时 keep everything」
   的退化（eta-host-bin 实测 0.4.0 → 0.5.0-rc.15）
G3 数字段降级（含 `1.24.3b` → `1.24b` 这种前缀变短，zen-browser-bin 实测）
G4 NEW 与 OLD 相同

被拒的包不写盘，仍由 Python 兜底 updater 处理——它本来就是全量黑名单模型。

## 分块与重试

一次 refresh 调用覆盖全通道时，任意一个上游的 TLS 抖动都会抛
`gnutls-error` 打断整轮（本机实测：142 个包跑一半死在 zellij-bin）。所以按
`--chunk` 分批；某批失败先整批重试，仍失败再逐个跑，把网络故障隔离到单个
包，并记进报告。
"""

from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
import time
import tempfile
from dataclasses import dataclass, field
from typing import Iterable, Optional

# ── 输出解析 ──────────────────────────────────────────────────────────────
#
# LC_ALL=C 下 guix refresh 的两种关键行（本地中文 locale 下第二行前缀是
# “警告：”，所以调用方必须把 locale 固定成 C）：
#
#   /abs/path/agent.scm:2506:13: eta-host-bin would be upgraded from 0.4.0 to 0.5.0-rc.15
#   /abs/path/agent.scm:2606:2: warning: no updater for eta-desktop-bin
#
# 包名只取 [A-Za-z0-9_.+-]：guix 包名不会含其他字符，收紧能避免把
# warning 行里的单词当包名。

_UPGRADE_RE = re.compile(
    r"^[^\s:]+:\d+:\d+: (?P<name>[A-Za-z0-9_.+-]+) would be upgraded "
    r"from (?P<old>\S+) to (?P<new>\S+)\s*$"
)


@dataclass
class Decision:
    name: str
    old: str
    new: str
    verdict: str  # "accept" | "reject"
    reason: str = ""


def parse_upgrades(text: str) -> dict[str, tuple[str, str]]:
    """从 refresh 输出里抽出 name -> (old, new)。同一包重复出现时后者覆盖前者。"""
    found: dict[str, tuple[str, str]] = {}
    for line in text.splitlines():
        m = _UPGRADE_RE.match(line)
        if m:
            found[m.group("name")] = (m.group("old"), m.group("new"))
    return found


# ── 守卫规则 ──────────────────────────────────────────────────────────────

_PRERELEASE_MARKERS = (
    "rc", "alpha", "beta", "pre", "preview", "nightly", "snapshot",
    "dev", "unstable", "milestone", "canary", "insider",
)

_PRERELEASE_RE = re.compile(
    # 标记前可以是分隔符，也可以直接贴在数字后面（`2.0.0beta`、`1.0pre2`）。
    r"(?:^|[.\-_+]|\d)(" + "|".join(_PRERELEASE_MARKERS) + r")(?:[.\-_+]?\d|$|[.\-_+])",
    re.IGNORECASE,
)

_NUMERIC_PREFIX_RE = re.compile(r"^(\d+(?:\.\d+)*)")


def is_prerelease(version: str) -> bool:
    return bool(_PRERELEASE_RE.search(version))


def numeric_prefix(version: str) -> tuple[int, ...] | None:
    """`1.24.3b` -> (1, 24, 3)；`0.5.0-rc.15` -> (0, 5, 0)；不以数字开头 -> None。"""
    m = _NUMERIC_PREFIX_RE.match(version)
    if not m:
        return None
    return tuple(int(part) for part in m.group(1).split("."))


def guard(old: str, new: str) -> Optional[str]:
    """返回拒绝理由；None 表示可以交给 `guix refresh -u` 写盘。"""
    if old == new:
        return "G4 版本未变"
    if not new[:1].isdigit():
        return "G1 新版本不以数字开头（tag 被误读成版本）"
    if is_prerelease(new) and not is_prerelease(old):
        return "G2 正式版被升级到 pre-release"
    old_t, new_t = numeric_prefix(old), numeric_prefix(new)
    if old_t is not None and new_t is not None:
        if new_t < old_t:
            return "G3 数字段降级"
        # `1.24.3b` -> `1.24b`：新版本的数字段是老版本的前缀，属版本号退行
        if new_t != old_t and old_t[: len(new_t)] == new_t:
            return "G3 数字段缩短（版本号退行）"
    return None


# ── 名单计算 ──────────────────────────────────────────────────────────────


def read_packages(path: str) -> list[str]:
    names = []
    with open(path, encoding="utf-8") as port:
        for raw in port:
            name = raw.strip()
            if name and not name.startswith("#"):
                names.append(name)
    return sorted(set(names))


def read_excludes(config_path: str) -> dict[str, str]:
    if not config_path or not os.path.exists(config_path):
        return {}
    with open(config_path, encoding="utf-8") as port:
        config = json.load(port)
    excludes = config.get("refresh_exclude") or {}
    if not isinstance(excludes, dict):
        raise SystemExit("config.json: refresh_exclude 必须是 {包名: 理由} 映射")
    return {str(k): str(v) for k, v in excludes.items()}


def plan(
    packages: Iterable[str], excludes: dict[str, str], upgrades: dict[str, tuple[str, str]]
) -> tuple[list[Decision], list[str]]:
    """返回 (逐包判定, 因排除而跳过的包名)。未出现在 refresh 输出里的包即“无更新”。"""
    decisions: list[Decision] = []
    skipped = []
    for name in packages:
        if name in excludes:
            skipped.append(name)
            continue
        if name not in upgrades:
            continue
        old, new = upgrades[name]
        reason = guard(old, new)
        if reason:
            decisions.append(Decision(name, old, new, "reject", reason))
        else:
            decisions.append(Decision(name, old, new, "accept"))
    return decisions, skipped


# ── 调用 guix refresh ─────────────────────────────────────────────────────

ENV = dict(os.environ, LC_ALL="C")


def chunks(items: list[str], size: int) -> list[list[str]]:
    return [items[i : i + size] for i in range(0, len(items), size)]


def call_refresh(
    guix: str, load_paths: list[str], packages: list[str], apply: bool, timeout: int
) -> tuple[bool, str, bool]:
    """返回 (成功, 输出, 是否超时)。超时与崩溃要分开：超时的块直接拆成单包跑，
    崩溃（TLS 抖动之类）先整块重试。"""
    cmd = [guix, "refresh"]
    for path in load_paths:
        cmd += ["-L", path]
    if apply:
        cmd += ["-u"]
    cmd += packages
    try:
        result = subprocess.run(
            cmd, capture_output=True, text=True, env=ENV, timeout=timeout
        )
    except subprocess.TimeoutExpired as expired:
        partial = ""
        if expired.stdout:
            partial = (
                expired.stdout
                if isinstance(expired.stdout, str)
                else expired.stdout.decode("utf-8", "replace")
            )
        # 超时前已经打印的 “would be upgraded” 行仍然有效，保留下来
        return False, partial, True
    return result.returncode == 0, result.stdout + result.stderr, False


def run_batched(
    guix: str,
    load_paths: list[str],
    packages: list[str],
    apply: bool,
    chunk_size: int,
    retries: int,
    timeout: int,
    deadline: float | None = None,
) -> tuple[str, list[str]]:
    """分块跑 refresh。

    失败分两种处理：
    - **崩溃**（TLS 抖动等）：先整块重试 `retries` 次，仍失败再逐包；
    - **超时**：直接逐包，不重试整块（整块再等一遍没有意义）。

    逐包仍然失败/超时的包记进失败清单，交给 Python 兜底 updater。
    `deadline`（time.monotonic 上限）是整轮墙钟预算，超了就停手，把剩下的
    包记成失败，避免个别上游把 CI 拖到超时。
    """
    output: list[str] = []
    failed: list[str] = []
    batches = chunks(packages, chunk_size)
    for index, batch in enumerate(batches, 1):
        if deadline is not None and time.monotonic() > deadline:
            print(
                f"[refresh] 墙钟预算用尽，跳过剩余 {len(batches) - index + 1} 批",
                file=sys.stderr,
            )
            failed.extend(p for b in batches[index - 1 :] for p in b)
            break
        print(
            f"[refresh] 批 {index}/{len(batches)}：{' '.join(batch)}",
            file=sys.stderr,
            flush=True,
        )
        attempt = 0
        while True:
            ok, text, timed_out = call_refresh(
                guix, load_paths, batch, apply, timeout
            )
            output.append(text)
            if ok or timed_out:
                # 成功，或超时：超时不再重试整块（再等一遍没有意义）
                if not ok:
                    print(f"[refresh] 批超时（{timeout}s），改为逐个重跑", file=sys.stderr)
                break
            attempt += 1
            if attempt > retries:
                break

        if ok:
            continue

        if len(batch) == 1:
            # 单包批已经重试过，不再重跑一遍
            print(f"[refresh] 放弃 {batch[0]}（网络/上游故障）", file=sys.stderr)
            failed.append(batch[0])
            continue

        # 逐个重跑本批
        for name in batch:
            if deadline is not None and time.monotonic() > deadline:
                failed.append(name)
                continue
            ok2, text2, timed_out2 = call_refresh(
                guix, load_paths, [name], apply, timeout
            )
            output.append(text2)
            if not ok2:
                why = "超时" if timed_out2 else "网络/上游故障"
                print(f"[refresh] 放弃 {name}（{why}）", file=sys.stderr)
                failed.append(name)
    return "\n".join(output), failed


# ── CLI ───────────────────────────────────────────────────────────────────


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(
        description="guix refresh 黑名单驱动器（plan / apply）"
    )
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--plan", action="store_true", help="dry-run + 守卫，产出可应用名单")
    mode.add_argument("--apply", action="store_true", help="按名单执行 guix refresh -u")
    parser.add_argument(
        "--load-path",
        action="append",
        default=[],
        help="传给 guix refresh 的 -L（必须是绝对路径，可重复）",
    )
    parser.add_argument("--packages", help="--plan：全通道包名清单文件（一行一个）")
    parser.add_argument("--accepted", help="可应用名单文件（plan 写出，apply 读入）")
    parser.add_argument("--report", help="--plan：判定报告 JSON")
    parser.add_argument("--config", default="scripts/check-updates/config.json")
    parser.add_argument("--guix", default="guix")
    parser.add_argument("--chunk", type=int, default=8, help="每批包数（默认 8）")
    parser.add_argument("--retries", type=int, default=1, help="整块重试次数（默认 1）")
    parser.add_argument(
        "--timeout",
        type=int,
        default=300,
        help="单次 guix refresh 调用超时秒数（默认 300；上游慢站点靠它兜底）",
    )
    parser.add_argument(
        "--deadline",
        type=int,
        default=2400,
        help="整轮墙钟预算秒数（默认 2400=40min；超了停止探测，剩余包交 Python 兜底）",
    )
    parser.add_argument("--only", default="", help="只处理逗号分隔的这些包（Recover 用）")
    args = parser.parse_args(argv)

    only = {p.strip() for p in args.only.split(",") if p.strip()}

    if args.plan:
        if not args.packages or not args.accepted:
            parser.error("--plan 需要 --packages 与 --accepted")
        packages = read_packages(args.packages)
        excludes = read_excludes(args.config)
        to_check = [p for p in packages if p not in excludes and (not only or p in only)]
        print(
            f"[refresh] 全通道 {len(packages)} 个包，黑名单排除 {len(excludes)} 个，"
            f"本轮检查 {len(to_check)} 个",
            file=sys.stderr,
        )
        text, failed = run_batched(
            args.guix,
            args.load_path,
            to_check,
            apply=False,
            chunk_size=args.chunk,
            retries=args.retries,
            timeout=args.timeout,
            deadline=time.monotonic() + args.deadline,
        )
        decisions, skipped = plan(packages, excludes, parse_upgrades(text))
        accepted = [d.name for d in decisions if d.verdict == "accept"]
        rejected = [d for d in decisions if d.verdict == "reject"]
        with open(args.accepted, "w", encoding="utf-8") as port:
            port.write(" ".join(accepted) + "\n")
        if args.report:
            with open(args.report, "w", encoding="utf-8") as port:
                json.dump(
                    {
                        "packages_total": len(packages),
                        "checked": len(to_check),
                        "excluded": skipped,
                        "accepted": [
                            {"name": d.name, "old": d.old, "new": d.new}
                            for d in decisions
                            if d.verdict == "accept"
                        ],
                        "rejected": [
                            {
                                "name": d.name,
                                "old": d.old,
                                "new": d.new,
                                "reason": d.reason,
                            }
                            for d in rejected
                        ],
                        "network_failures": failed,
                    },
                    port,
                    ensure_ascii=False,
                    indent=2,
                )
        print(f"[refresh] 可更新 {len(accepted)} 个，守卫拦下 {len(rejected)} 个", file=sys.stderr)
        for d in rejected:
            print(f"[refresh]   拦下 {d.name}: {d.old} -> {d.new}（{d.reason}）", file=sys.stderr)
        if failed:
            print(f"[refresh] 网络失败 {len(failed)} 个: {' '.join(failed)}", file=sys.stderr)
        return 0

    # --apply
    if not args.accepted:
        parser.error("--apply 需要 --accepted")
    names = [n for n in open(args.accepted, encoding="utf-8").read().split() if n]
    if only:
        names = [n for n in names if n in only]
    if not names:
        print("[refresh] 名单为空，跳过 apply", file=sys.stderr)
        return 0
    print(f"[refresh] 应用 {len(names)} 个包的更新", file=sys.stderr)
    _, failed = run_batched(
        args.guix,
        args.load_path,
        names,
        apply=True,
        chunk_size=args.chunk,
        retries=args.retries,
        timeout=args.timeout,
        deadline=time.monotonic() + args.deadline,
    )
    if failed:
        print(f"[refresh] apply 阶段失败 {len(failed)} 个: {' '.join(failed)}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))

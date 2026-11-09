#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only
#
"""静态检查：包名不得渗入安装路径。

`-bin` 等后缀属于 Guix 包名命名空间，上游软件并不认识它。凡是上游会
读取、探测或显示的标识（bin/、lib/、libexec/、share/ 目录名，.desktop
文件名，图标基名）必须用上游原名。唯一例外是 Guix 自用的
share/doc/<package-name>/。

用法：python3 scripts/check-package-paths.py
退出码：0 干净，1 有违规。

覆盖边界：抓字符串字面量与已知关键字参数（#:app-dir、#:program、#:icon），
以及 binary-build-system 的默认 install-plan 陷阱。用 name 变量在
string-append 里拼出的路径抓不到，那类写法仍需人工审查。
"""

import glob
import re
import sys

DEFAULT_PACKAGES = ["modules/jeans/packages/*.scm"]

_DEFINE = re.compile(r"\(define-public\s+([^\s()]+)")
# 路径中紧跟标准顶层目录之后的第一段
_PATH_SEGMENT = re.compile(
    r"(?:^|/)(?:bin|lib|libexec|share|etc|opt|var|include|pixmaps|applications)/"
    r"([A-Za-z0-9_.@+-]+)"
)
_DESKTOP = re.compile(r"(?:^|/)([A-Za-z0-9_.@+-]+)\.desktop")
_ICON = re.compile(r'#:icon\s+"([^"]+)"')
_APP_DIR = re.compile(r'#:app-dir\s+"([^"]+)"')
_PROGRAM = re.compile(r'#:program\s+"([^"]+)"')
_UPSTREAM = re.compile(r'upstream-name\s+\.\s*"([^"]+)"')
_LITERAL = re.compile(r'"([^"\\]*(?:\\.[^"\\]*)*)"')

# 通道自己加在包名上的记号后缀（-bin 之外）。新增记号时同步这里，否则
# 检查抓不到——lem-next-bin 的 -next（追 master 的版本线）就是这样漏掉的。
# 只参与 -bin 包的复合记号判定（base = 包名去掉 -bin）：lem-next-bin 的
# base  lem-next 带 -next，于是 lem-next 也不得进入上游可读标识。
# -se（跟踪我们自己的 fork）目前不与 -bin 复合，先登记备用。
CHANNEL_SUFFIXES = ("-next", "-se")


def strip_comment(line):
    """去掉行尾注释，忽略字符串内的分号。"""
    in_string = False
    for i, ch in enumerate(line):
        if in_string:
            if ch == '"':
                in_string = False
        elif ch == '"':
            in_string = True
        elif ch == ";":
            return line[:i]
    return line


def forms(text):
    """产出 (包名, form 文本, 起始行号)。"""
    for match in _DEFINE.finditer(text):
        start = i = match.start()
        depth = 0
        in_string = False
        while i < len(text):
            ch = text[i]
            if in_string:
                if ch == "\\":
                    i += 2
                    continue
                if ch == '"':
                    in_string = False
            elif ch == '"':
                in_string = True
            elif ch == ";":
                newline = text.find("\n", i)
                i = len(text) if newline < 0 else newline
                continue
            elif ch == "(":
                depth += 1
            elif ch == ")":
                depth -= 1
                if depth == 0:
                    yield (
                        match.group(1),
                        text[start : i + 1],
                        text[:start].count("\n") + 1,
                    )
                    break
            i += 1


def normalize_app_dir(app_dir):
    """去掉 #:app-dir 可选的 lib/ 前缀。"""
    return app_dir[4:] if app_dir.startswith("lib/") else app_dir


def check_file(path):
    findings = []
    with open(path, encoding="utf-8") as handle:
        text = handle.read()
    for name, body, start_line in forms(text):
        code_body = "\n".join(strip_comment(line) for line in body.split("\n"))
        app_dirs = _APP_DIR.findall(code_body)
        programs = _PROGRAM.findall(code_body)
        # 非 -bin 包名通常就是上游名；但 #:program 会揭示真实程序名
        # （workbuddy-cn 的 program 是 workbuddy）。两者不一致而 app-dir
        # 仍用包名时，同样是包名渗入路径。
        if not name.endswith("-bin"):
            for app_dir in app_dirs:
                if (
                    normalize_app_dir(app_dir) == name
                    and any(program != name for program in programs)
                ):
                    findings.append(
                        (path, start_line, name,
                         "#:app-dir 用了包名，但 #:program 是上游名")
                    )
            continue
        upstream = _UPSTREAM.search(body)
        upstream_name = upstream.group(1) if upstream else None
        # upstream-name 恰好等于包名时，说明上游软件自己就叫这个名字。
        if upstream_name == name:
            continue
        # 包名与「去掉 -bin 后仍带通道记号」的名字都不得进入上游可读标识。
        # lem-next-bin：-next 是「追 master」的记号，upstream-name 是 lem；
        # aria2-next-bin：base 就是上游 repo 名（upstream-name 也是它），不算记号。
        base = name[: -len("-bin")]
        is_marker = upstream_name != base and any(
            base.endswith(suffix) for suffix in CHANNEL_SUFFIXES
        )
        bad = {name, base} if is_marker else {name}
        doc_prefix = "share/doc/%s" % name
        # binary-build-system 的默认 install-plan 是 lib/<package-name>/，
        # 即取 Guix 包名。漏传 #:install-plan/#:app-dir 就会把 -bin 带进路径。
        if (
            "binary-build-system" in code_body
            and "#:install-plan" not in code_body
            and "#:app-dir" not in code_body
        ):
            findings.append(
                (path, start_line, name,
                 "未传 #:install-plan/#:app-dir，默认落进 lib/<包名>/")
            )
        for app_dir in app_dirs:
            if normalize_app_dir(app_dir) in bad:
                findings.append(
                    (path, start_line, name, "#:app-dir 使用了包名")
                )
        for program in programs:
            if program in bad:
                findings.append(
                    (path, start_line, name, "#:program 使用了包名")
                )
        for offset, line in enumerate(body.split("\n")):
            code = strip_comment(line)
            for literal in _LITERAL.findall(code):
                if doc_prefix in literal:
                    continue
                for segment in _PATH_SEGMENT.findall(literal):
                    if segment in bad:
                        findings.append(
                            (path, start_line + offset, name,
                             "路径段 %r 使用了包名或通道记号" % segment)
                        )
                for desktop in _DESKTOP.findall(literal):
                    if desktop in bad:
                        findings.append(
                            (path, start_line + offset, name,
                             ".desktop 文件名使用了包名或通道记号")
                        )
            for icon in _ICON.findall(code):
                if icon in bad:
                    findings.append(
                        (path, start_line + offset, name,
                         "图标基名使用了包名")
                    )
    return findings


def main():
    patterns = sys.argv[1:] or DEFAULT_PACKAGES
    findings = []
    for pattern in patterns:
        for path in sorted(glob.glob(pattern)):
            findings.extend(check_file(path))
    for path, line, name, message in findings:
        print("%s:%d: %s: %s" % (path, line, name, message))
    if findings:
        print(
            "\n%d 处违规。包名只是本通道的记号，安装路径请用上游原名"
            "（唯一例外：share/doc/<package-name>/）。" % len(findings)
        )
        return 1
    print("包名未渗入安装路径。")
    return 0


if __name__ == "__main__":
    sys.exit(main())

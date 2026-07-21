#!/bin/sh
# SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only
#
# 从 git diff 提取被 guix refresh 改写的包名，输出 JSON 到 stdout。
#
# 用法：refresh-changed-packages.sh > scripts/check-updates/refresh-updates.json
#
# 工作原理：guix refresh -u 改写 modules/jeans/packages/*.scm 后，
# 本脚本对比工作树与 HEAD 的差异，提取所有改过的 .scm 文件里的
# define-public 包名（排除 rust-crates.scm），输出为 JSON 数组。
# test_updated_packages.py 会读取这个文件，把这些包纳入构建测试。

set -eu

PACKAGES_DIR="modules/jeans/packages"

# 收集所有改动的 .scm 文件（排除由 guix import 管理的 rust-crates.scm）
changed_files=""
for f in $(git diff --name-only -- "$PACKAGES_DIR" 2>/dev/null); do
    case "$f" in
        *rust-crates.scm) continue ;;
        *.scm) ;;
        *) continue ;;
    esac
    # 文件可能已被删除，跳过不存在的
    [ -f "$f" ] || continue
    if [ -z "$changed_files" ]; then
        changed_files="$f"
    else
        changed_files="$changed_files $f"
    fi
done

# 从每个改动文件提取 define-public 的包名
pkgs=""
if [ -n "$changed_files" ]; then
    for f in $changed_files; do
        for pkg in $(grep -oE 'define-public [A-Za-z0-9._+-]+' "$f" | awk '{print $2}'); do
            if [ -z "$pkgs" ]; then
                pkgs="\"$pkg\""
            else
                pkgs="$pkgs, \"$pkg\""
            fi
        done
    done
fi

# 输出 JSON
if [ -n "$pkgs" ]; then
    printf '{"packages": [%s]}\n' "$pkgs"
else
    printf '{"packages": []}\n'
fi

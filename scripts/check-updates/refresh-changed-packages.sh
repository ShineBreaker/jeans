#!/bin/sh
# SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only
#
# 从 git diff 提取被 guix refresh 改写的包名，输出 JSON 到 stdout。
#
# 用法：refresh-changed-packages.sh > scripts/check-updates/refresh-updates.json
#
# 工作原理：guix refresh -u 改写 modules/jeans/packages/*.scm 后，
# 本脚本对比工作树与 HEAD 的差异，只输出定义体内确有改动行的包。
# 旧逻辑列出改动文件里的全部 define-public（如 tools.scm 被 refresh 碰过
# 就把 jdtls-bin 等 19 个包全拉进构建测试），一次 DNS 瞬断就能挡住整批
# 正常更新（2026-10-09 实证）。现按新文件侧改动行号归因到包。
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

pkgs=""
if [ -n "$changed_files" ]; then
    for f in $changed_files; do
        # 顶层包定义行号表（行首 define-public，包内缩进的不算）
        pkgdefs=$(grep -nE '^\(define-public [A-Za-z0-9._+-]+' "$f" \
            | sed -E 's/^([0-9]+).*define-public ([A-Za-z0-9._+-]+).*/\1 \2/')
        [ -z "$pkgdefs" ] && continue
        # 新文件侧改动行号：解析 @@ -a[,b] +c[,d] @@ 的 +c[,d]，
        # 纯删除（d=0）也记 c 行归因（删除点所属的包）。
        changed_lines=$(git diff -U0 -- "$f" | grep -E '^@@ ' \
            | sed -nE 's/^@@.* \+([0-9]+)(,([0-9]+))?.*/\1 \3/p' \
            | while read -r start count; do
                if [ -z "$count" ]; then
                    echo "$start"
                elif [ "$count" -eq 0 ]; then
                    echo "$start"
                else
                    seq "$start" "$((start + count - 1))"
                fi
            done)
        [ -z "$changed_lines" ] && continue
        for ln in $changed_lines; do
            # 改动行之前的最后一个顶层 define-public 即所属包；
            # 第一个包之前的改动（文件头/import）不归因。
            pkg=$(printf '%s\n' "$pkgdefs" \
                | awk -v line="$ln" '$1 <= line {pkg=$2} END {print pkg}')
            [ -z "$pkg" ] && continue
            case " $pkgs " in
                *" \"$pkg\" "*) continue ;;
            esac
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

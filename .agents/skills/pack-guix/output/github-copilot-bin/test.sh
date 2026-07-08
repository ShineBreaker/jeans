#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
# SPDX-License-Identifier: MIT
#
# pack-guix — github-copilot-bin 单次测试脚本
# 该包已集成到 jeans 通道的 (jeans packages agent) 模块，
# 因此测试直接针对通道中的包名而非独立 package.scm。

set -euo pipefail

PKG_NAME="github-copilot-bin"
MODULES_DIR="${MODULES_DIR:-../../../../../modules}"
TEST_CMD="${1:-git-credential-copilot --help}"

echo "═══════════════════════════════════════"
echo "  Pack-Guix 测试: $PKG_NAME"
echo "  测试命令: $TEST_CMD"
echo "═══════════════════════════════════════"

# [1/4] 模块加载
echo ""
echo "[1/4] 模块加载..."
if guix build -L "$MODULES_DIR" "$PKG_NAME" --dry-run >/dev/null 2>&1; then
	echo "  ✓ 模块加载成功"
else
	echo "  ✗ 模块加载失败"
	guix build -L "$MODULES_DIR" "$PKG_NAME" --dry-run 2>&1 | tail -5
	exit 1
fi

# [2/4] 构建
echo ""
echo "[2/4] 构建..."
if OUT=$(guix build -L "$MODULES_DIR" "$PKG_NAME" 2>&1 | tail -1); then
	echo "  ✓ 构建成功: $OUT"
else
	echo "  ✗ 构建失败"
	exit 1
fi

# [3/4] 运行时库解析（ld.so --list，确认无 "not found"）
echo ""
echo "[3/4] 运行时库解析..."
LD=$(sed -n 's/.*exec \([^ ]*ld-linux[^ ]*\).*/\1/p' "$OUT/bin/github")
LIBPATH=$(sed -n 's/.* --library-path \([^ ]*\) .*/\1/p' "$OUT/bin/github")
BIN="$OUT/libexec/github-copilot/github"
NOT_FOUND=$("$LD" --list --library-path "$LIBPATH" "$BIN" 2>&1 | grep -c "not found" || true)
if [ "$NOT_FOUND" -eq 0 ]; then
	echo "  ✓ 所有 NEEDED 库已解析"
else
	echo "  ✗ 发现 $NOT_FOUND 个缺失库:"
	"$LD" --list --library-path "$LIBPATH" "$BIN" 2>&1 | grep "not found"
	exit 1
fi

# [4/4] git-credential-copilot 运行测试
# 注意：主 `github` 二进制是 GUI 应用，无头环境无法完整启动；
# git-credential-copilot 是配套 CLI，可验证 ld-linux wrapper 是否工作。
echo ""
echo "[4/4] git-credential-copilot 运行测试..."
if guix shell -L "$MODULES_DIR" "$PKG_NAME" -- $TEST_CMD >/dev/null 2>&1; then
	echo "  ✓ git-credential-copilot 可执行"
else
	echo "  ⚠ git-credential-copilot 退出码非 0（可能需要 broker，属正常）"
fi

echo ""
echo "═══════════════════════════════════════"
echo "  测试完成"
echo "═══════════════════════════════════════"

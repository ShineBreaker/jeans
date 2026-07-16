#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
#
# SPDX-License-Identifier: MIT
#
# Single-run verification for a standalone package.scm.
# Usage: ./test.sh [package.scm] [package-name] [test-arg ...]

set -euo pipefail

PACKAGE_FILE="package.scm"
if [[ $# -ge 1 ]]; then
  PACKAGE_FILE="$1"
  shift
fi

PACKAGE_NAME=""
if [[ $# -ge 1 ]]; then
  PACKAGE_NAME="$1"
  shift
fi

TEST_ARGS=("$@")
if [[ $# -eq 0 ]]; then
  TEST_ARGS=(--version)
fi

if [[ -z "$PACKAGE_NAME" ]]; then
  PACKAGE_NAME="$(sed -n 's/^[[:space:]]*(name[[:space:]]*"\([^"]*\)".*/\1/p' "$PACKAGE_FILE" | head -1)"
fi
if [[ -z "$PACKAGE_NAME" ]]; then
  echo "Cannot determine package name; pass it as the second argument." >&2
  exit 2
fi

echo "Package: $PACKAGE_NAME"
echo "Definition: $PACKAGE_FILE"

echo "[1/5] Load and dry-run"
guix build -f "$PACKAGE_FILE" --dry-run

echo "[2/5] Build"
OUTPUT_PATH="$(guix build -f "$PACKAGE_FILE")"
test -d "$OUTPUT_PATH"

echo "[3/5] Lint"
guix lint -f "$PACKAGE_FILE"

echo "[4/5] Runtime command"
guix shell -f "$PACKAGE_FILE" -- "$PACKAGE_NAME" "${TEST_ARGS[@]}"

echo "[5/5] ELF interpreter audit"
bad=0
while IFS= read -r -d '' file; do
  interpreter="$(patchelf --print-interpreter "$file" 2>/dev/null || true)"
  if [[ "$interpreter" == /lib64/* || "$interpreter" == /lib/* ]]; then
    printf 'FHS interpreter remains: %s -> %s\n' "$file" "$interpreter" >&2
    bad=1
  fi
done < <(find "$OUTPUT_PATH" -type f -executable -print0)
if (( bad )); then
  exit 1
fi

echo "Verification passed: $OUTPUT_PATH"

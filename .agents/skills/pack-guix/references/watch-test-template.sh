#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
#
# SPDX-License-Identifier: MIT
#
# Re-run the focused package checks when the definition changes.
# Usage: ./watch-test.sh [package.scm] [package-name] [test-arg ...]

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
command -v inotifywait >/dev/null || {
  echo "inotifywait is required for watch mode." >&2
  exit 127
}

run_test() {
  printf '[%s] dry-run: %s\n' "$(date '+%H:%M:%S')" "$PACKAGE_NAME"
  guix build -f "$PACKAGE_FILE" --dry-run >/dev/null

  printf '[%s] build\n' "$(date '+%H:%M:%S')"
  output="$(guix build -f "$PACKAGE_FILE")"
  test -d "$output"

  printf '[%s] lint\n' "$(date '+%H:%M:%S')"
  guix lint -f "$PACKAGE_FILE" >/dev/null

  printf '[%s] runtime\n' "$(date '+%H:%M:%S')"
  guix shell -f "$PACKAGE_FILE" -- "$PACKAGE_NAME" "${TEST_ARGS[@]}"
  printf '[%s] passed: %s\n' "$(date '+%H:%M:%S')" "$output"
}

run_test
while IFS= read -r changed; do
  sleep 0.5
  run_test
done < <(inotifywait -m -e modify -e create -e delete --format '%w%f' "$PACKAGE_FILE")

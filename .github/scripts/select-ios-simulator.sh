#!/usr/bin/env bash
set -euo pipefail

input_file="${1:-/dev/stdin}"

# Prefer the newest iPhone simulator available on the runner without pinning CI
# to a specific Xcode image. xcodebuild exits 70 when the requested destination
# does not exist, so this script selects from `simctl list devices available iOS`.
awk '
  /^-- iOS / { in_ios = 1; next }
  /^-- / { in_ios = 0 }
  in_ios && /iPhone/ && /\(.*\)/ {
    line = $0
    sub(/^[[:space:]]*/, "", line)
    sub(/[[:space:]]+\(.*/, "", line)
    print line
  }
' "$input_file" | tail -n 1

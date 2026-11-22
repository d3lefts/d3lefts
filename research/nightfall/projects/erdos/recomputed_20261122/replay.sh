#!/usr/bin/env bash
# One-command source-pinned replay of recovered NIGHTFALL C1b bounds.
set -euo pipefail
cd "$(dirname "$0")"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
base_arg=()
if [[ $# -gt 0 ]]; then base_arg=(--base-heights "$1"); fi
python3 reconstruct_upper.py "${base_arg[@]}" --out "$tmp/phase_v3_heights_u70.txt"
python3 verify_upper.py "$tmp/phase_v3_heights_u70.txt"
python3 verify_lower.py
echo 'PASS exact upper and conditional intermediate lower; external analytic/referee gates remain open'

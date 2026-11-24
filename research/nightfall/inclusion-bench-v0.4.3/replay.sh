#!/usr/bin/env bash
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
work="${1:?pass a new or existing InclusionBench checkout path}"
if [[ ! -d "$work/.git" ]]; then
  git clone https://github.com/tkwa/inclusion-bench.git "$work"
fi
git -C "$work" checkout --detach 326065e17df73039332b4fd974b1e335dc4b5e68
test "$(git -C "$work" rev-parse HEAD)" = 326065e17df73039332b4fd974b1e335dc4b5e68
cd "$work"
python3 scripts/proofcheck/setup_linux.py --toolchain-path "$HOME/.local/share/inclusion-bench/lean-4.19.0" --image ubuntu:22.04
python3 -m inclusion_bench check-submission "$here/candidate" --runtime .tools/proofcheck-runtime.json

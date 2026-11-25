#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
sha256sum -c SHA256SUMS
RUNTIME=${1:-/mnt/data/lean-workbench/runtime}
export PATH="$RUNTIME/lean/bin:$PATH"
mkdir -p replay-build replay-logs
export LEAN_PATH="$PWD/replay-build:$RUNTIME/mathlib-lib$(printf ':%s' "$RUNTIME"/packages/*)"
export LEAN_NUM_THREADS=1
lean --version
for m in T2UniformParseval T2ClippedEstimator AllOrderCore AllOrderMask AllOrderFourier AllOrderTruncation AllOrderTerminal AllOrderMoments AllOrderChaos AllOrderGeometry AllOrderTensorLocalization AllOrderMixedNorm AllOrderTensorSource AllOrderRowBound AllOrderAnchor AllOrderAnalyticTerminal AllOrderHammingBall AllOrderActiveFiber AllOrderPaddedFiber AllOrderCombinedTerminal AllOrderMaskCost AllOrderNearMask AllOrderPatternGeometry AllOrderPatternMask AllOrderPatternAssembly AllOrderFullForm AllOrderQuantumPath AllOrderQuantumForm AllOrderPhysicalTerminal; do
 lean -o "replay-build/$m.olean" "src/$m.lean" >"replay-logs/$m.log" 2>&1
 if grep -q 'sorryAx' "replay-logs/$m.log"; then exit 1; fi
 leanchecker "$m" >"replay-logs/$m-kernel.log" 2>&1
 echo "PASS $m"
done

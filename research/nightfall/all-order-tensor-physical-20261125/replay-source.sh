#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
python3 - <<'PY'
import hashlib, json, pathlib
for name, expected in json.loads(pathlib.Path('SOURCE_BLOBS.json').read_text()).items():
    data = pathlib.Path(name).read_bytes()
    actual = hashlib.sha1(b'blob ' + str(len(data)).encode() + b'\x00' + data).hexdigest()
    if actual != expected:
        raise SystemExit(f'Source custody mismatch: {name}')
print('Exact archived source and receipt blobs verified')
PY
RUNTIME=${1:?Pass the pinned recovered workbench runtime directory}
export PATH="$RUNTIME/lean/bin:$PATH"
mkdir -p replay-build replay-logs
export LEAN_PATH="$PWD/replay-build:$RUNTIME/mathlib-lib$(printf ':%s' "$RUNTIME"/packages/*)"
export LEAN_NUM_THREADS=1
lean --version
for m in T2UniformParseval T2ClippedEstimator AllOrderCore AllOrderMask AllOrderFourier AllOrderTruncation AllOrderTerminal AllOrderMoments AllOrderChaos AllOrderGeometry AllOrderTensorLocalization AllOrderMixedNorm AllOrderTensorSource AllOrderRowBound AllOrderAnchor AllOrderAnalyticTerminal AllOrderHammingBall AllOrderActiveFiber AllOrderPaddedFiber AllOrderCombinedTerminal AllOrderMaskCost AllOrderNearMask AllOrderPatternGeometry AllOrderPatternMask AllOrderPatternAssembly AllOrderFullForm AllOrderQuantumPath AllOrderQuantumForm AllOrderPhysicalTerminal; do
  lean -o "replay-build/$m.olean" "src/$m.lean" >"replay-logs/$m.log" 2>&1
  python3 - "$m" <<'PY'
import json, pathlib, re, sys
name = sys.argv[1]
log = pathlib.Path(f'replay-logs/{name}.log').read_text()
allowed = {'propext','Classical.choice','Quot.sound'}
found = re.findall(r'depends on axioms: \[([^\]]*)\]', log)
for row in found:
    unexpected = {a.strip() for a in row.split(',') if a.strip()} - allowed
    if unexpected:
        raise SystemExit(f'{name}: unexpected axioms {unexpected}')
if 'sorryAx' in log or 'declaration uses' in log and "'sorry'" in log:
    raise SystemExit(f'{name}: unresolved sorry dependency')
# Some declarations are axiom-free; those audits use a different message.
expected = next(x['audits'] for x in json.loads(pathlib.Path('certificate.json').read_text())['modules'] if x['module']==name)
if len(found)+log.count('does not depend on any axioms') != expected:
    raise SystemExit(f'{name}: unexpected audit count; expected {expected}')
PY
  leanchecker "$m" >"replay-logs/$m-kernel.log" 2>&1
  echo "PASS $m"
done

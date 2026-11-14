#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
python3 semantic_fence.py
python3 independent_audit.py
python3 unbounded_post_certificate_gain.py
python3 atomic_gate_checker.py
python3 sqlite_prototype.py

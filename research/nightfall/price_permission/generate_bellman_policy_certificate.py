#!/usr/bin/env python3
"""Untrusted Bellman policy proposal from the EXISTING semantic_fence solver.

Never use this generator as the certificate verifier. Independent Python
local-action inequalities and JS direct-world budget oracle must accept the
result. The --check flag detects any drift in the committed proof object.
"""
from __future__ import annotations
import argparse
import hashlib
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "research/nightfall/assurance/semantic-fencing-v0.3"))
from semantic_fence import joint_value

TARGET = Path(__file__).with_name("bellman_two_source_policy_certificate.json")


def canonical(obj):
    return json.dumps(obj, sort_keys=True, separators=(",", ":"), ensure_ascii=True).encode()


def construct(original):
    source = original["source_model"]
    n = source["sources"]
    base = source["baseline_worlds"]
    safe = [i not in source["unsafe_worlds"] for i in range(1 << n)]
    root = sum(1 << w for w in base)
    read = [int(v) for v in source["read_costs"]]
    guard = [int(v) for v in source["guard_costs"]]
    states = {}
    for B in range(1, root + 1):
        if B & ~root:
            continue
        value, _, solver = joint_value(B, safe, n, read, guard)
        _, plan = solver(B)
        if plan[0] == "commit":
            choice = {"kind": "grant", "guard": plan[1]}
        elif plan[0] == "read":
            choice = {"kind": "read", "source": plan[1]}
        else:
            raise ValueError("unexpected deny branch in safe base set")
        states[str(B)] = {"value": str(value), "choice": choice}
    return {"schema": original["schema"], "source_model": source,
            "certificate": {
                "source_sha256": hashlib.sha256(canonical(source)).hexdigest(),
                "root_belief": root,
                "claimed_optimal_cost": states[str(root)]["value"],
                "states": states}}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--check", action="store_true")
    args = ap.parse_args()
    given = json.loads(TARGET.read_text())
    candidate = construct(given)
    if args.check:
        if candidate != given:
            raise ValueError("committed policy differs from existing source-bound Bellman solver")
        print("PASS: generator replays original semantic_fence.joint_value, all belief states agree")
    else:
        TARGET.write_text(json.dumps(candidate, indent=2, sort_keys=True) + "\n")


if __name__ == "__main__":
    main()

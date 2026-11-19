#!/usr/bin/env python3
"""Exact rational oracle for a narrowly scoped joint-vs-marginal counterexample."""
import json
import sys
from fractions import Fraction
from pathlib import Path

def parse_dist(obj):
    out = {}
    for key, value in obj.items():
        bits = tuple(int(v) for v in key.split(","))
        if not bits or any(v not in (0, 1) for v in bits):
            raise ValueError("Keys must be comma-separated binary coordinates")
        p = Fraction(value)
        if p < 0:
            raise ValueError("Negative probability")
        if bits in out:
            raise ValueError("Duplicate outcome")
        out[bits] = p
    if sum(out.values()) != 1:
        raise ValueError("Probabilities must sum to one")
    return out

def check(data):
    a = parse_dist(data["a"])
    b = parse_dist(data["b"])
    outcomes = set(a) | set(b)
    dims = {len(x) for x in outcomes}
    if len(dims) != 1 or next(iter(dims)) < 2:
        raise ValueError("Distributions require same dimension >= 2")
    n = next(iter(dims))
    same_marginals = all(
        sum(a.get(x, 0) for x in outcomes if x[i] == 1)
        == sum(b.get(x, 0) for x in outcomes if x[i] == 1)
        for i in range(n)
    )
    different_joint = any(a.get(x, 0) != b.get(x, 0) for x in outcomes)
    return {"valid": same_marginals and different_joint,
            "same_marginals": same_marginals,
            "different_joint": different_joint,
            "dimension": n}

if __name__ == "__main__":
    if len(sys.argv) != 2:
        raise SystemExit("usage: python3 check_theorembreak.py witness.json")
    result = check(json.loads(Path(sys.argv[1]).read_text()))
    print(json.dumps(result, sort_keys=True))
    sys.exit(0 if result["valid"] else 1)

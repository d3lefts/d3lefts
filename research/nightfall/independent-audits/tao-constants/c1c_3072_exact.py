#!/usr/bin/env python3
"""Independent reproduction of rozetyp's historical 3072-grid C1c witness.

Uses independent pair-first correlation helper, with frozen original SHA.
Neither originality nor contemporary best-bound claims are implied.
"""
import argparse
import hashlib
import json
from pathlib import Path
from urllib.request import urlopen
from fractions import Fraction
from c1c_6144_exact import correlate_pair_first

UPSTREAM = (
    "https://raw.githubusercontent.com/rozetyp/barnard-steinerberger-lower-bound/"
    "19f397152222caaef2c838bdd9c41295adb94310/"
    "previous/certificate_K3072.json"
)
EXPECTED_HASH = "788527a6237837e8d5d441cfab3f8b39080165fc207ae6a69678cc5f3a0fdf58"
EXPECTED = Fraction(92043155785589760, 224330199426578281)
K = 3072
N = 3584

def verify(raw):
    assert hashlib.sha256(raw).hexdigest() == EXPECTED_HASH
    data = json.loads(raw)
    assert data["K"] == K and len(data["weights_int"]) == N
    weights = data["weights_int"]
    assert all(type(w) is int and w >= 0 for w in weights)
    sums = correlate_pair_first(weights, K)
    minimum = min(sums)
    lag = sums.index(minimum)
    total = sum(weights)
    assert total > 0
    exact = Fraction(K * minimum, total * total)
    assert exact == EXPECTED
    assert exact == Fraction(data["score_num"], data["score_den"])
    assert lag == 497

    # A local tamper test at the certified minimizer.
    affected = next(i for i in range(N-lag) if weights[i+lag] > 0)
    altered = weights[:]
    altered[affected] += 1
    perturbed = sum(altered[i] * altered[i+lag] for i in range(N-lag))
    assert perturbed != minimum
    return {
        "status": "EXACT_FINITE_WITNESS_REPLAY",
        "source_sha256": EXPECTED_HASH,
        "cells": N,
        "K": K,
        "grid_knots": K+1,
        "minimizer_lag": lag,
        "numerator": str(exact.numerator),
        "denominator": str(exact.denominator),
        "decimal": format(float(exact), ".13f"),
        "mutation_control": "PASS",
        "scope": "historical finite witness, not a new bound",
    }

if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    g = ap.add_mutually_exclusive_group(required=True)
    g.add_argument("--fetch", action="store_true")
    g.add_argument("--file", type=Path)
    a = ap.parse_args()
    if a.fetch:
        with urlopen(UPSTREAM, timeout=45) as f:
            b = f.read()
    else:
        b = a.file.read_bytes()
    print(json.dumps(verify(b), indent=2))

#!/usr/bin/env python3
"""Exact-rational C96 first/second-moment COUNTEREXAMPLE SEARCH, not a proof.

For independent centered scalar increments Yi with |Yi|<=1, check
e=E(H+sum Yi)^2 <= 2*(E|H+sum Yi|)^2 + E|H+sum Yi|.
Enumerate distinct finite-product marginals, including zero-mass atoms.
"""
from fractions import Fraction as Q
from itertools import product
from hashlib import sha256
import argparse
import json

P_GRID = tuple(Q(i, 16) for i in (0, 1, 2, 4, 6, 8))
SHIFTS = tuple(Q(k, 8) for k in range(-16, 17))
EXPECTED_DIGEST_N4 = "66ce3536894ef434e61fc37195683c763e950796f31b96dd2670b04adb8a314b"


def law(p, orientation):
    if p == 1:
        return ((Q(1), Q(0)),)
    return ((p, Q(orientation)), (1 - p, -Q(orientation) * p / (1 - p)))


def convolution(laws):
    pmf = {Q(0): Q(1)}
    for alpha in laws:
        next_pmf = {}
        for s, w in pmf.items():
            for mass, y in alpha:
                if not mass:
                    continue
                k = s + y
                next_pmf[k] = next_pmf.get(k, Q(0)) + w * mass
        pmf = next_pmf
    assert sum(pmf.values(), Q()) == 1
    return pmf


def run(max_n=4):
    checked = 0
    min_margin = None
    witness = None
    digest = sha256()
    for n in range(max_n + 1):
        for pset in product(P_GRID, repeat=n):
            for orient in product((-1, 1), repeat=n):
                laws = [law(p, s) for p, s in zip(pset, orient)]
                for ll in laws:
                    assert sum((w for w, y in ll), Q()) == 1
                    assert sum((w * y for w, y in ll), Q()) == 0
                    assert all(abs(y) <= 1 for w, y in ll)
                pmf = convolution(laws)
                variance = sum((p / (1 - p) for p in pset), Q())
                for H in SHIFTS:
                    u = sum((mass * abs(H + s) for s, mass in pmf.items()), Q())
                    e = H * H + variance
                    margin = 2 * u * u + u - e
                    if min_margin is None or margin < min_margin:
                        min_margin = margin
                        witness = (n, pset, orient, H, u, e, margin)
                    digest.update(f'{n};{pset};{orient};{H};{u};{e};{margin}\n'.encode())
                    checked += 1
                    if margin < 0:
                        raise AssertionError(f'COUNTEREXAMPLE {witness}')
    out = {
        "status": "NO_COUNTEREXAMPLE_ON_GRID_NOT_A_PROOF",
        "checked": checked,
        "max_n": max_n,
        "marginal_grid": [str(p) for p in P_GRID],
        "shifts": "k/8, k=-16,...,16",
        "minimum_gap": str(min_margin),
        "minimizer": dict(n=witness[0], p=[str(x) for x in witness[1]],
                          signs=witness[2], H=str(witness[3]),
                          first=str(witness[4]), second=str(witness[5]),
                          gap=str(witness[6])),
        "sha256_of_exact_case_receipts": digest.hexdigest(),
    }
    if max_n == 4:
        assert checked == 746493, (checked, 'grid drift')
        assert digest.hexdigest() == EXPECTED_DIGEST_N4, 'receipt digest drift'
    return out


def exact_singleton_sanity():
    # p=1/9, Y=-1/8 with probability 8/9 or Y=1 with probability 1/9;
    # shift H=1/8. Then |H+Y|=0 or 9/8.
    law1 = law(Q(1, 9), 1)
    h = Q(1, 8)
    assert law1 == ((Q(1, 9), Q(1)), (Q(8, 9), Q(-1, 8)))
    u = sum((mass * abs(h + y) for mass, y in law1), Q())
    e = sum((mass * (h + y) ** 2 for mass, y in law1), Q())
    assert u == Q(1, 8) and e == Q(9, 64)
    assert 2 * u * u + u - e == Q(1, 64)
    return {"p": "1/9", "c": 1, "u": str(u), "e": str(e),
            "gap": str(2 * u * u + u - e)}


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--max-n", type=int, default=4)
    args = ap.parse_args()
    out = run(args.max_n)
    out["one_increment_exact_example"] = exact_singleton_sanity()
    print(json.dumps(out, indent=2))

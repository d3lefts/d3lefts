#!/usr/bin/env python3
"""Fail-closed exact integer audit of the T2 tensor rank-baseline crossover.

No floating point, external modules or assumed full quantum theorem.
The K_A bound and constant 35 are CONDITIONAL paper-level ingredients.
"""
from itertools import product
from math import comb, isqrt


def gf2_rank(rows):
    pivots = {}
    for row in rows:
        x = row
        while x:
            bit = x.bit_length() - 1
            if bit in pivots:
                x ^= pivots[bit]
            else:
                pivots[bit] = x
                break
    return len(pivots)


def tensor_rows(level):
    # Local nonzero factors 01, 10, 11 in F_2^2.
    for factors in product((1, 2, 3), repeat=level):
        row = 0
        for coordinate in range(1 << level):
            v = 1
            for site, factor in enumerate(factors):
                v &= (factor >> ((coordinate >> site) & 1)) & 1
            row |= v << coordinate
        yield row


def ceil_sqrt(n):
    root = isqrt(n)
    return root + (root * root != n)


def formula_interval(level):
    # PR #1114 all-q paper bound specialized to q=2; PR #1097 constant 35.
    n = 2917  # 1 + 4*3**6
    m2 = 2 * level + 2
    s3 = sum(comb(level, j) for j in range(min(3, level) + 1))
    ka = 52 * n * n * min(n, m2) * s3
    # epsilon=delta=1/4, so 2/(epsilon**2*delta) = 128.
    lo = 128 * (2 * isqrt(ka) + 35 * isqrt(m2)) ** 2
    hi = 128 * (2 * ceil_sqrt(ka) + 35 * ceil_sqrt(m2)) ** 2
    assert 0 <= lo <= hi
    return ka, m2, lo, hi


def main():
    for level in range(1, 5):
        rows = list(tensor_rows(level))
        assert len(rows) == 3**level
        assert len(set(rows)) == len(rows)
        assert gf2_rank(rows) == 2**level
        assert set(1 << j for j in range(2**level)).issubset(rows)
        print(f"GF2_SPAN_PASS L={level} rows={len(rows)} rank={gf2_rank(rows)}")

    # Exact interval logic: if the lower bound is >= the basis cost
    # then the candidate ceiling cannot beat that basis. If its upper
    # bound is strictly below the basis cost, it certainly beats it.
    for level in range(1, 60):
        ka, m2, lower, upper = formula_interval(level)
        assert lower >= 2**level, (level, lower, 2**level)
    ka, m2, lower, upper = formula_interval(60)
    assert upper < 2**60, (upper, 2**60)
    assert lower > 0
    print("RANK_BASELINE_CROSSOVER_EXACT_PASS L=60")
    print(f"K_A_BOUND={ka} M2={m2} CANDIDATE_INTERVAL=[{lower},{upper}] BASIS={2**60}")
    print("PROMOTION_GATE: paper conditional; no Hilbert-energy Lean terminal asserted")


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""Independent exact GF(2) adversarial audit of the six-way tensor secant decomposition.

Audits all subspaces and affine cosets through n=3; all subspaces
of E_2×E_2 for the mixed product lemma; exact set recursion n=0..4.
Finite tests DO NOT constitute a Lean proof of the all-n theorem.
"""
from itertools import combinations
from collections import Counter


def rows(level):
    result = {1}
    for n in range(level):
        width = 1 << n
        result = {v for a in result for v in (a, a << width, a ^ (a << width))}
    assert len(result) == 3 ** level and 0 not in result
    return result


def secants(source):
    return {a ^ b for a in source for b in source}


def six_cases(source, width):
    previous = secants(source)
    pure = {v for x in previous for v in (x, x << width, x ^ (x << width))}
    mixed = {v for r in source for s in source
             for v in (r ^ (s << width),
                       (r ^ s) ^ (s << width),
                       s ^ ((r ^ s) << width))}
    return pure | mixed


def all_rref_bases(n, q):
    for pivots in combinations(range(n), q):
        avail = [[j for j in range(p + 1, n) if j not in pivots] for p in pivots]
        total = sum(map(len, avail))
        for bits in range(1 << total):
            pos, basis = 0, []
            for p, cols in zip(pivots, avail):
                v = 1 << p
                for col in cols:
                    if bits >> pos & 1:
                        v |= 1 << col
                    pos += 1
                basis.append(v)
            yield tuple(basis)


def reduce_mod(v, basis):
    for b in reversed(basis):
        if v & (b & -b):
            v ^= b
    return v


def span(basis):
    out = [0]
    for b in basis:
        out += [x ^ b for x in out]
    return out


def audit():
    for n in range(5):
        source = rows(n)
        observed = secants(rows(n + 1))
        predicted = six_cases(source, 1 << n)
        assert observed == predicted, ("six-slice error", n, observed ^ predicted)
        print("SIX_WAY_EXACT", n, "size", len(observed), flush=True)

    for n in (1, 2, 3):
        dimension = 1 << n
        source = rows(n)
        secant_set = secants(source | {0})
        assert secant_set == secants(source)
        linear_max, affine_max = [], []
        for q in range(dimension + 1):
            linear = affine = total = 0
            for basis in all_rref_bases(dimension, q):
                total += 1
                cosets = Counter(reduce_mod(s, basis) for s in secant_set)
                linear = max(linear, cosets.get(0, 0))
                affine = max(affine, max(cosets.values()))
                assert cosets.get(0, 0) <= 1 + 12 * n * q**4
                assert max(cosets.values()) <= 1 + 12 * n * (q + 1)**4
            linear_max.append(linear)
            affine_max.append(affine)
            print("SECANT_RREF", n, q, total, linear, affine, flush=True)
        if n == 3:
            assert linear_max == [1, 2, 4, 8, 16, 31, 58, 102, 190]
            assert affine_max == [1, 2, 4, 8, 16, 32, 58, 102, 190]

    # Cross pair product is genuinely 8-dimensional for n=2.
    source = rows(2)
    prod = {r | (s << 4) for r in source for s in source}
    for q in range(9):
        worst = 0
        for basis in all_rref_bases(8, q):
            hit = sum(s in prod for s in span(basis))
            worst = max(worst, hit)
            assert hit <= 4 * q**4, ("cross product", q, basis, hit)
        print("CROSS_PRODUCT_ALL_W", q, worst, flush=True)

    print("SUBCUBE_SECANT_STRUCTURAL_FINITE_PASS")


if __name__ == "__main__":
    audit()

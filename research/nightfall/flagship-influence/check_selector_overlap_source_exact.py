#!/usr/bin/env python3
"""Exact independent original-product check for OVERLAPPING categorical selectors.

Full-state resampling influences are computed from f itself, not from the
formula used in the analytic proof. Fraction arithmetic throughout.
Finite testing is NOT a substitute for the missing product-law Lean bridge.
"""
from fractions import Fraction as Q
from itertools import combinations, product
from random import Random
from math import prod


def normalized_law(rng, m, allow_zero):
    vals = [rng.randint(1, 5) for _ in range(m)]
    if allow_zero and m >= 3:
        vals[rng.randrange(m)] = 0
    s = sum(vals)
    return tuple(Q(x, s) for x in vals)


def evaluate(k, t, n, seed, shared):
    rng = Random(seed)
    la = [normalized_law(rng, 2 + ((seed + j) % 2), j == 0)
          for j in range(k)]
    ly = [normalized_law(rng, 2 + ((seed + j) % 2), j % 2 == 0)
          for j in range(n)]
    alist = list(product(*(range(len(x)) for x in la)))
    ylist = list(product(*(range(len(x)) for x in ly)))

    def weight(a, y):
        return prod((la[j][a[j]] for j in range(k)), start=Q(1)) * \
               prod((ly[j][y[j]] for j in range(n)), start=Q(1))

    pa = {a: prod((la[j][a[j]] for j in range(k)), start=Q(1))
          for a in alist}
    py = {y: prod((ly[j][y[j]] for j in range(n)), start=Q(1))
          for y in ylist}

    support = {}
    coefficients = {}
    for a in alist:
        active_count = rng.randint(1, t)
        if shared:
            # Shared coordinate; varying address-dependent support sizes.
            leaves = {0}
            leaves.update(rng.sample(range(1, n),
                                     k=min(active_count - 1, n - 1)))
        else:
            leaves = set(rng.sample(range(n), k=min(active_count, n)))
        support[a] = leaves
        subsets = [s for q in range(1, min(2, len(leaves)) + 1)
                   for s in combinations(sorted(leaves), q)]
        coefficients[a] = (Q(rng.randint(-3, 3)),
                           {s: Q(rng.randint(-3, 3), 2) for s in subsets})

    def g(a, y):
        intercept, cf = coefficients[a]
        return intercept + sum(
            (v * prod((Q(y[i]) for i in s), start=Q(1))
             for s, v in cf.items()), Q(0))

    values = {(a, y): g(a, y) for a in alist for y in ylist}
    active = [(a, y) for a in alist for y in ylist if weight(a, y)]
    lo, hi = min(values[x] for x in active), max(values[x] for x in active)
    B = (hi - lo) / 2
    mean = sum((weight(a, y) * values[a, y]
                for a in alist for y in ylist), Q(0))
    V = sum((weight(a, y) * (values[a, y] - mean)**2
             for a in alist for y in ylist), Q(0))

    def source_influence(pos):
        if pos < k:
            j = pos
            return sum((
                weight(a, y) * la[j][new] *
                (values[a, y] -
                 values[a[:j] + (new,) + a[j+1:], y])**2 / 2
                for a in alist for y in ylist for new in range(len(la[j]))
            ), Q(0))
        j = pos - k
        return sum((
            weight(a, y) * ly[j][new] *
            (values[a, y] -
             values[a, y[:j] + (new,) + y[j+1:]])**2 / 2
            for a in alist for y in ylist for new in range(len(ly[j]))
        ), Q(0))

    infs = [source_influence(i) for i in range(k+n)]
    M = max(infs)
    m = {y: sum((pa[a] * values[a, y] for a in alist), Q(0))
         for y in ylist}
    gmean = sum((py[y] * m[y] for y in ylist), Q(0))
    Vg = sum((py[y] * (m[y] - gmean)**2 for y in ylist), Q(0))
    addr = sum((
        py[y] * pa[a] * (values[a, y] - m[y])**2
        for y in ylist for a in alist
    ), Q(0))
    assert V == addr + Vg

    weights = [sum((pa[a] for a in alist if i in support[a]), Q(0))
               for i in range(n)]
    assert sum(weights) <= t
    for i in range(n):
        Ig = sum((
            py[y] * ly[i][new] *
            (m[y] - m[y[:i] + (new,) + y[i+1:]])**2 / 2
            for y in ylist for new in range(len(ly[i]))
        ), Q(0))
        assert Ig <= weights[i] * infs[k+i], (
            "weighted overlap row failed", seed, i, Ig, weights[i], infs[k+i])

    assert addr <= sum(infs[:k])
    assert Vg <= sum((weights[i] * infs[k+i] for i in range(n)), Q(0))
    assert V <= sum(infs[:k]) + sum(
        (weights[i] * infs[k+i] for i in range(n)), Q(0))
    effective = sum(weights)
    assert effective <= t
    assert V <= (k + effective) * M
    assert V <= (k + t) * M
    assert V <= B * B
    assert V * V <= (k + effective) * B * B * M
    assert V * V <= (k + t) * B * B * M
    return int(sum(1 for a in alist if 0 in support[a]) > 1)


def main():
    count = 0
    shared_count = 0
    for k in (1, 2):
        for t in (1, 2, 3):
            for seed in range(12):
                shared_count += evaluate(k, t, 4, seed+100*k+10*t,
                                         shared=(seed % 3 != 0))
                count += 1
    assert count == 72 and shared_count >= 40
    print("PASS: ", count, "independent exact-rational product models;",
          shared_count, "with overlapping, variable-size source activation")


if __name__ == "__main__":
    main()

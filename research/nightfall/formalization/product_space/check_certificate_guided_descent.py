#!/usr/bin/env python3
"""Independent exact-fraction audit of certificate-overlap sampling.

No Lean imports, symbolic floating point, or Monte Carlo. Enumerates every
nonconstant Boolean function in two finite product configurations and three
nontrivial certificate-row systems. This is a falsification test, not a proof.
"""
from fractions import Fraction as Q
from itertools import product, combinations
from functools import reduce
from math import isqrt


def audit(n, probs, a, b):
    xs = list(product((0, 1), repeat=n))
    px = {
        x: reduce(lambda m, v: m * v,
                  (probs[j] if x[j] else 1 - probs[j] for j in range(n)), Q(1))
        for x in xs
    }
    assert sum(px.values(), Q(0)) == 1
    a, b = tuple(a), tuple(b)
    # Both certificate rows have entries >= 1, hence cover every sensitive block.
    assert all(v >= 1 for v in (*a, *b))
    A, B = sum(a), sum(b)
    roots = [isqrt(a[j] * b[j]) for j in range(n)]
    assert all(roots[j] ** 2 == a[j] * b[j] for j in range(n))
    W = sum(roots)
    pi = [Q(r, W) for r in roots]
    overlap2 = Q(W * W, A * B)
    assert sum(pi, Q(0)) == 1 and 0 < overlap2 < 1
    checked = 0
    min_ratio = None

    for vals in product((0, 1), repeat=len(xs)):
        g = dict(zip(xs, vals))
        mass1 = sum((px[x] for x in xs if g[x]), Q(0))
        mass0 = 1 - mass1
        if not (mass1 > 0 and mass0 > 0):
            continue
        V = mass1 * mass0 / (A * B)
        infl = [
            sum((px[x] * px[y] for x in xs for y in xs
                 if g[x] and not g[x[:j] + (y[j],) + x[j+1:]]), Q(0))
            for j in range(n)
        ]
        gain = sum((pi[j] * infl[j] for j in range(n)), Q(0))
        sharp_floor = V / overlap2
        assert gain >= sharp_floor, (n, vals, gain, sharp_floor)

        T = sum(infl, Q(0))
        posterior = Q(0)
        for j in range(n):
            for val in (0, 1):
                pj = probs[j] if val else 1 - probs[j]
                for x in xs:
                    if x[j] != val:
                        continue
                    conditional_x = px[x] / pj
                    for k in range(n):
                        if k == j:
                            continue
                        for vk in (0, 1):
                            y = x[:k] + (vk,) + x[k+1:]
                            if g[x] and not g[y]:
                                posterior += pi[j] * pj * conditional_x * (
                                    probs[k] if vk else 1 - probs[k])
        assert posterior == T - gain, (n, vals, posterior, T - gain)

        # Independent Hoeffding decomposition by conditional expectations
        # and Möbius subtraction, then direct energy calculation.
        comps = {}
        for m in range(n + 1):
            for S in combinations(range(n), m):
                means = {}
                for x in xs:
                    matches = [y for y in xs if all(x[k] == y[k] for k in S)]
                    denom = sum((px[y] for y in matches), Q(0))
                    means[x] = sum((px[y] * g[y] for y in matches), Q(0)) / denom
                comps[S] = {
                    x: means[x] - sum((comps[R][x] for k in range(m)
                                      for R in combinations(S, k)), Q(0))
                    for x in xs
                }
        energy = {
            S: sum((px[x] * comp[x] ** 2 for x in xs), Q(0))
            for S, comp in comps.items()
        }
        d = max((len(S) for S, e in energy.items() if e), default=0)
        assert d >= 1
        assert sum((e for S, e in energy.items() if S), Q(0)) == mass1 * mass0
        assert sum((len(S) * e for S, e in energy.items()), Q(0)) == T
        K = max(A, B)
        assert posterior <= T * (1 - Q(1, d * K * K))
        ratio = gain / sharp_floor
        min_ratio = ratio if min_ratio is None else min(min_ratio, ratio)
        checked += 1
    print(f"n={n}, row1={a}, row0={b}, overlap²={overlap2}, "
          f"nonconstant={checked}, minimum gain/floor={min_ratio}")
    return checked


def main():
    checked = 0
    checked += audit(2, [Q(1, 4), Q(3, 5)], (9, 1), (1, 4))
    checked += audit(3, [Q(1, 4), Q(2, 5), Q(3, 4)], (9, 1, 1), (1, 4, 1))
    checked += audit(3, [Q(1, 4), Q(2, 5), Q(3, 4)], (4, 1, 1), (1, 4, 1))
    assert checked == 522
    print(f"PASS: {checked} independently enumerated exact cases")


if __name__ == "__main__":
    main()

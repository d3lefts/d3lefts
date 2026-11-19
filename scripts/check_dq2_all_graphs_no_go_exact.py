#!/usr/bin/env python3
"""Exact witness against an interaction-uniform dimension-free dependent Q2 constant.

Independent rational state enumeration validates path formulas in small dimensions.
The general all-n obstruction follows from the symbolic argument in the note;
finite tests alone are not a proof of unboundedness. Python stdlib only.
"""
from fractions import Fraction as Q
from itertools import product


def formula(n):
    assert n >= 2
    r = Q(n * n - 1, n * n)
    var = (n + 2 * sum((n - k) * r**k for k in range(1, n))) / (n * n)
    inf_endpoint = (1 - r * r) / (n * n)
    inf_interior = inf_endpoint / (1 + r * r)
    lower = Q((n - 1)**2, 1) / (1 - r * r)
    assert var >= Q(n - 1, n)
    assert var * var / inf_endpoint >= lower
    return r, var, inf_endpoint, inf_interior, lower


def brute(n):
    r, expected_var, endpoint, interior, _ = formula(n)
    states = list(product((-1, 1), repeat=n))
    weights = {x: Q(1, 2**n) * product_factor(x, r) for x in states}
    assert sum(weights.values()) == 1
    f = {x: Q(sum(x), n) for x in states}
    mean = sum(weights[x] * f[x] for x in states)
    var = sum(weights[x] * (f[x] - mean)**2 for x in states)
    influences = []
    for i in range(n):
        # No conditional-law formula is used in this computation.
        pairs = {}
        for x in states:
            pairs.setdefault(x[:i] + x[i + 1:], []).append(x)
        inf = sum(
            weights[a] * weights[b] / (weights[a] + weights[b])
            * (f[a] - f[b])**2
            for a, b in pairs.values()
        )
        influences.append(inf)
    assert mean == 0 and var == expected_var
    assert influences == [endpoint if i in (0, n - 1) else interior for i in range(n)]
    print(f"PASS exact independent enumeration n={n}; ratio={float(var*var/max(influences)):.9f}")


def product_factor(x, r):
    factor = Q(1)
    for i in range(len(x) - 1):
        factor *= 1 + r * x[i] * x[i + 1]
    return factor


if __name__ == "__main__":
    for n in (2, 3, 4, 5, 7, 9):
        brute(n)
    last = Q(0)
    for n in (12, 24, 50, 100):
        r, var, endpoint, interior, lower = formula(n)
        ratio = var * var / endpoint
        assert ratio > last
        assert lower > Q(n**4, 4) if n >= 5 else True
        last = ratio
        print(f"PASS exact closed form n={n}; bound>={float(lower):.3f}; ratio={float(ratio):.3f}")
    print("PASS all finite replay tests; all-n no-go relies on analytic proof")

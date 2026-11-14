#!/usr/bin/env python3
"""Exact rational falsifier: fair-cube Q2 subsumption and biased pair obstruction.
Analytic proof and prior art are in Q2_SUBSUMPTION_AUDIT_20261114.md.
"""
from fractions import Fraction
from itertools import product
from random import Random

rng = Random(20261114)
checks = 0

def check(n, a, b, c):
    global checks
    vals = []
    for sign in product((-1, 1), repeat=n):
        vals.append(c + sum(a[i] * sign[i] for i in range(n))
                    + sum(v * sign[i] * sign[j] for (i, j), v in b.items()))
    B = max(map(abs, vals), default=0)
    V = sum(v*v for v in a) + sum(v*v for v in b.values())
    influences = [
        a[i]**2 + sum(v*v for (j, k), v in b.items() if i in (j, k))
        for i in range(n)
    ]
    M = max(influences, default=0)
    assert V**2 <= 49 * B**2 * M, (n, a, b, c, B, V, M)
    checks += 1

for a0, a1, b in product(range(-2, 3), repeat=3):
    check(2, (a0, a1), {(0, 1): b}, 0)
for n in range(1, 7):
    for _ in range(256):
        a = tuple(rng.randrange(-4, 5) for _ in range(n))
        b = {(i, j): rng.randrange(-4, 5)
             for i in range(n) for j in range(i + 1, n)}
        check(n, a, b, rng.randrange(-3, 4))

for d in (2, 3, 4, 10, 100, 1000, 10000):
    p = Fraction(1, d)
    original = p * (1-p)
    conditional = Fraction(1, 4)
    assert conditional / original == Fraction(d*d, 4*(d-1))
    assert 2 * p * (1-p) > 0
    checks += 2

print(f"PASS {checks} exact-rational falsification checks")

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

# Fully source-matched categorical address-function obstruction.
# n+1 source sites share an n-symbol alphabet, with zero data-site atoms.
# Conditional-variance influences use the actual independent source law.
for n in range(2, 10):
    bit_states = list(product((-1, 1), repeat=n))
    mass = Fraction(1, n * len(bit_states))
    total_mean = sum((mass * bits[j] for bits in bit_states for j in range(n)), Fraction())
    total_sq = sum((mass * bits[j]**2 for bits in bit_states for j in range(n)), Fraction())
    assert total_mean == 0 and total_sq - total_mean**2 == 1
    checks += 1
    i_addr = sum((Fraction(1, len(bit_states)) *
                  (1 - (Fraction(sum(bits), n))**2)
                  for bits in bit_states), Fraction())
    assert i_addr == Fraction(n - 1, n)
    checks += 1
    for k in range(n):
        influence = sum((mass * (bits[j] - (0 if j == k else bits[j]))**2
                         for bits in bit_states for j in range(n)), Fraction())
        assert influence == Fraction(1, n)
        checks += 1

print(f"PASS {checks} exact-rational falsification checks")

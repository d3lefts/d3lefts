#!/usr/bin/env python3
"""Exact rational adversarial regression for #894 against ≥4r frozen duels.

Checks only finite arithmetic, not a theorem or a substitute for Lean.
"""
from fractions import Fraction as F

r = F(1, 10)
D = 2
gamma = r / (16 * D**2)
assert gamma == F(1, 640)
for m in [100, 101, 200, 1000, 25600, 30000, *range(102, 10001)]:
    p = F(1, 2) - F(20, m)
    q = F(1, 2) + F(20, m)
    a = F(2, 5) - F(10, m)
    b = F(3, 5) + F(10, m)
    gap = b - a
    tv = q - p
    assert 0 <= p <= q <= 1
    assert gap == 2 * r + F(20, m) > 2 * r
    assert tv == F(40, m)
    assert (gap >= 4 * r) == (m <= 100)
    assert (tv > gamma) == (m < 25600)
    assert p * (1-p) <= F(1, 4)
    assert q * (1-q) <= F(1, 4)

# A zero-atom product pair is maximally distinguishable in one query.
P, Q = (F(1), F(0)), (F(0), F(1))
bayes_overlap = sum(min(pi, qi) for pi, qi in zip(P, Q))
assert bayes_overlap == 0

print("PASS: #894 hard family never triggers a 4r duel for m>100;")
print("strict low-TV crossover at m=25600; zero-atom Bayes overlap exact.")

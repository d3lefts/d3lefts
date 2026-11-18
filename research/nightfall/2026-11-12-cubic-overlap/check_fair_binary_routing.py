#!/usr/bin/env python3
"""Exact 256-state audit of the 8-bit pure cubic fair-sign routing witness.

No numerical approximation and no external dependencies. Original-source
sign influence is E[((f(X)-f(X flipped at i))/2)^2].
"""
from fractions import Fraction as F
from itertools import combinations, product
from math import prod

SIGNS = (-1, 1)
ST = tuple(product(SIGNS, repeat=2))
A_INDEX = {st: k for k, st in enumerate(ST)}
STATES = tuple(product(SIGNS, repeat=8))


def observable(x):
    a, b1, b2, c1, c2 = x[:4], x[4], x[5], x[6], x[7]
    total = sum(a[A_INDEX[s, t]] * (b1 + s*b2) * (c1 + t*c2)
                for s, t in ST)
    assert total % 4 == 0
    return total // 4


def flip(x, j):
    return x[:j] + (-x[j],) + x[j+1:]


values = {x: observable(x) for x in STATES}
assert len(values) == 256 and set(values.values()) == {-1, 1}
mean = F(sum(values.values()), 256)
variance = sum((F(v-mean)**2 for v in values.values()), F()) / 256
influences = [sum((F(values[x]-values[flip(x,j)], 2)**2
                   for x in STATES), F()) / 256 for j in range(8)]
assert mean == 0 and variance == 1
assert influences == [F(1,4)]*4 + [F(1,2)]*4

# A second computation derives the entire Fourier support from the full
# truth table; no assumption about degree or coefficient signs is used.
spectrum = {}
for k in range(9):
    for S in combinations(range(8), k):
        coeff = F(sum(values[x] * prod(x[j] for j in S) for x in STATES), 256)
        if coeff:
            spectrum[S] = coeff
            assert k == 3 and len(S) == 3
            assert sum(j < 4 for j in S) == 1
            assert sum(j in (4,5) for j in S) == 1
            assert sum(j in (6,7) for j in S) == 1
            assert abs(coeff) == F(1,4)
assert len(spectrum) == 16
assert sum((q*q for q in spectrum.values()), F()) == variance

# A third computation enumerates only the B/C state space and derives
# each aggregate A-link fourth moment, and the pointwise l1 budget.
row2, row4 = {}, {}
for s, t in ST:
    samples = [F((b1+s*b2)*(c1+t*c2),4)
               for b1,b2,c1,c2 in product(SIGNS, repeat=4)]
    assert set(samples) == {-1,0,1}
    row2[(s,t)] = sum((q*q for q in samples), F()) / 16
    row4[(s,t)] = sum((q**4 for q in samples), F()) / 16
    assert row2[(s,t)] == row4[(s,t)] == F(1,4)
    assert row4[(s,t)] / row2[(s,t)]**2 == 4
for b1,b2,c1,c2 in product(SIGNS, repeat=4):
    q = {st:F((b1+st[0]*b2)*(c1+st[1]*c2),4) for st in ST}
    active = [st for st in ST if q[st] != 0]
    assert len(active) == 1 and active[0] == (b1*b2,c1*c2)
    assert abs(q[active[0]]) == 1
    assert sum(map(abs,q.values()),F()) == 1

B = max(map(abs, values.values()))
V = variance
M = max(influences)
W = sum((row2[st] for st in ST if row4[st] > 3*row2[st]**2),F())
assert (B,V,M,W) == (1,1,F(1,2),1)
assert V**2/(B*B*M) == W**2/(B*B*M) == 2
print("PASS 256-state direct variance/influence audit, all 8 influences")
print("PASS all 256 Walsh coefficients: exactly 16 pure cubic terms")
print("PASS 4 aggregate rows: E Q² = E Q⁴ = 1/4, kappa = 4")
print("PASS W_spike(3)^2/(B^2*M) = Var^2/(B^2*M) = 2")
print("SCOPE: lower-bound witness, not unrestricted cubic upper theorem")

#!/usr/bin/env python3
"""Independent finite stress attack on the PSD/Rademacher transfer.
All quadratic-form arithmetic is exact integers; transcendental tests use
standard-library floats with explicit slack. This is NOT a proof.
"""
from fractions import Fraction
from itertools import product
from math import exp, log, pi, sqrt
from random import Random

rng = Random(20261110)
checked = 0

for r in range(1, 7):
    signs = list(product((-1, 1), repeat=r))
    for n in (r, r + 2, 2 * r + 3):
        for _ in range(12):
            # Ai=sum_k vik(vik)^T, so every matrix is PSD by construction.
            Vs = [
                [tuple(rng.randrange(-4, 5) for _ in range(r))
                 for j in range(rng.randrange(1, 4))]
                for i in range(n)
            ]
            tr = [sum(sum(x*x for x in v) for v in blocks) for blocks in Vs]
            P, M = sum(tr), max(tr)
            if not M:
                continue

            def quad(blocks, eps):
                return sum(sum(x*y for x,y in zip(v,eps))**2 for v in blocks)

            values = [max(quad(blocks, eps) for blocks in Vs) for eps in signs]
            L = min(values)
            if L == 0:
                continue
            for blocks, s in zip(Vs, tr):
                if not s:
                    continue
                mgf = sum(exp(quad(blocks,eps)/(4*s)) for eps in signs)/len(signs)
                assert mgf <= sqrt(2)+1e-11, (r,n,mgf)
            Ez = sum(values)/len(values)
            a = sqrt(2)-1
            assert L <= Ez
            assert Ez <= 4*M*log(1+a*P/M)+1e-10
            assert M+1e-10 >= L/(8*log(1+4*P/L))
            checked += 1

# Exact algebraic coefficients in the capped potential. eta^(-3/2)
# is a COMMON positive factor and cancels in this rational check.
for d in (1,2,3,7,25):
    assert Fraction(d)+Fraction(2*d,3) == Fraction(5*d,3)

c = sqrt(3/12500)/pi**6
assert abs(c-1.611411225376563e-5)<1e-16
print("PASS:", checked, "nondegenerate PSD/Rademacher cases")
print("PASS: 5 exact integral coefficient identities")
print("PASS: finite theorem numerical constant", c)
print("STATUS: numerical finite stress check, not a theorem certificate")

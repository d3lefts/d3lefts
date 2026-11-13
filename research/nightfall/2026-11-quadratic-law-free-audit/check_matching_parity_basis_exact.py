#!/usr/bin/env python3
"""Exhaust all degree<=2 Boolean indicator-monomial parity basis cases.

Checking 0/1/2-coordinate monomials at up to three matched blocks is
an exact finite basis audit. Transfer to all m and arbitrary alphabet
requires the proof by locality and indicator-span; this script is not
a Lean kernel proof or a novelty certificate.
"""
from itertools import combinations, product
from fractions import Fraction

cases=0
for m in (1,2,3):
    coords=tuple(product(range(m),(0,1)))
    for order in (0,1,2):
        for S in combinations(coords,order):
            for tau in product((0,1),repeat=order):
                def g(x): return int(all(x[c]==bit for c,bit in zip(S,tau)))
                even=Fraction(0); odd=Fraction(0)
                for sigma in product((0,1),repeat=m):
                    pe={(e,s):sigma[e] for e,s in coords}
                    po={(e,s):(sigma[e] if s==0 else 1-sigma[e]) for e,s in coords}
                    even+=Fraction(g(pe),2**m)
                    odd+=Fraction(g(po),2**m)
                rect=0
                for e in range(m):
                    def F(a,b):
                        state={c:0 for c in coords}
                        state[e,0]=a; state[e,1]=b
                        return g(state)
                    rect+=F(0,0)-F(0,1)-F(1,0)+F(1,1)
                assert 2*(even-odd)==rect,(m,S,tau,even,odd,rect)
                cases+=1
print(f'PASS {cases} exhaustive Boolean indicator basis parity identities; m=1,2,3')
print('All-n and arbitrary-alphabet transfer is analytic, not kernel-checked.')

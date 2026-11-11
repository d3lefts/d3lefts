#!/usr/bin/env python3
"""Exact weighted hypergraph no-go controls; *not* a bounded-cubic counterexample."""
from fractions import Fraction as Q
from math import comb

def case(n, t, C):
    w=Q(1,n**3)
    W=comb(n,3)*w
    M=comb(n-1,2)*w
    rem=comb(n-t,3)*w if n-t>=3 else Q(0)
    max_matching_square=Q((n//3)**2,n**3)
    assert max_matching_square<=1
    # t >= C/sqrt(M), so failure after t queries implies failure for
    # the stricter <= C/sqrt(M) budget. All claims exact rational.
    assert t*t*M >= C*C
    assert rem*rem > C*C*M
    return W,M,rem
for n,t,C in [(256,64,1),(1024,128,2),(65536,4096,8)]:
    W,M,rem=case(n,t,C)
    print(f'PASS n={n} t={t} C={C}; W={W}; M={M}; W_uncovered={rem}')
print('LIMIT: abstract edge energies need not come from bounded cubics.')

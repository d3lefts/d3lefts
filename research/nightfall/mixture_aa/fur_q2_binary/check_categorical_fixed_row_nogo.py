#!/usr/bin/env python3
"""Exact categorical selector barrier to alphabet-independent pointwise FUR.

One categorical address A in [N], N binary leaves Y_j, f(A,Y)=Y_A.
Degree is globally 2 by sum_j indicator(A=j)*Y_j. For every j, fixing
A=j and changing only Y_j changes output by 1. Any fixed-weight squared
row with coefficient C must therefore assign w_j>=1/C to EVERY leaf.
"""
from fractions import Fraction as F

def selector(a,one_leaf):
    # Sparse input: every leaf is zero except 'one_leaf'.
    return int(a==one_leaf)

for N in (2,3,7,31,127,579,2049):
    C=F(289)
    Wmax=F(2)
    mandatory=F(0)
    for j in range(N):
        # x has all leaf bits zero; y differs only at Y_j.
        x=0
        y=selector(j,j)
        assert x==0 and y==1 and (x-y)**2==1
        mandatory+=F(1)/C
    assert mandatory==F(N)/C
    if N>578:
        assert mandatory>Wmax
    print(f'N={N} global degree=2, fixed-row leaf-weight sum >= {mandatory}; '
          f'Boolean theorem mass cap 2 violated={mandatory>Wmax}')
print('PASS exact categorical selector obstruction, including N=579 > 2*289.')
print('This refutes only alphabet-independent fixed POINTWISE weights, not Hellinger mean FUR or mixture crux.')

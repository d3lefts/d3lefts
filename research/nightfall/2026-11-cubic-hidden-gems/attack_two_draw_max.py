#!/usr/bin/env python3
"""Exact integer occupancy DP for two-draw scalarization obstruction.
The mathematical divergence proof is in AUDIT_TWO_DRAW_MAX.md.
"""
from fractions import Fraction
from math import comb

def expected_occupancy_max(n):
    denominator=n**(2*n)
    total=Fraction(0)
    for cap in range(n):
        dp=[0]*(n+1)
        dp[0]=1
        for _ in range(n):
            nxt=[0]*(n+1)
            for r in range(n+1):
                if not dp[r]:
                    continue
                for a in range(min(cap,n-r)+1):
                    nxt[r+a]+=dp[r]*comb(n-r,a)*(n-1)**a
            dp=nxt
        accepted=sum(dp[r]*n**(n-r) for r in range(n+1))
        assert 0<=accepted<=denominator
        total+=1-Fraction(accepted,denominator)
    return total

previous=Fraction(0)
for n in range(2,15):
    value=expected_occupancy_max(n)
    assert value>previous
    previous=value
    print(f'n={n:2d} E[max N]={float(value):.6f}; ratio lower bound={float(value/4):.6f}')
print('PASS: exact multinomial DP for n=2,...,14; asymptotic theorem is analytic')

#!/usr/bin/env python3
"""Finite exact rational replay of the negative-binomial size-bias identities.
Not a proof of Mira's source-specific forward/reverse factorization or runtime.
Original source Mira-Cult/math@30ddaaad27b48df2002225c3e3f40cffd02c5253.
"""
from math import comb
from fractions import Fraction as F

def nb(k,p,t):
    if t<k:return F(0)
    return F(comb(t-1,k-1))*p**k*(1-p)**(t-k)

def check(p,k):
    assert k>=4 and 0<p<=1
    for t in range(k,101):
        P=nb(k,p,t)
        assert P*F(k-1,t-1)/p==nb(k-1,p,t-1)
        assert P*F(t,k)*p==nb(k+1,p,t+1)
    assert F(k-1,k-2)<=2

def main():
    for k in (4,5,10,25):
        for p in (F(1,2),F(2,7),F(1,19),F(1)):
            check(p,k)
    for T,a in ((F(1,5),F(7,10)),(F(19,3),F(1,10)),(F(1),F(1))):
        for l in (F(1,4),F(1,7)):
            h=a*l/T
            if h>1:continue
            assert l/(l+h)==T/(T+a)
    for p in (F(1,3),F(1,100),F(1,2)):
        assert p/p+(1-p)/(1-p)==2
    print('MIRA_NB_SIZE_BIAS_AND_SOFT_RACE_EXACT_PASS')

if __name__=='__main__':main()

#!/usr/bin/env python3
"""Lemnis independent exact-arithmetic audit of Axiom's *conditional* tail sum.
Source contract: P11(q) <= sum_{n=12}^{2k} C(2k,n) 2^g(k,n), k>=12.
The probabilistic source lemma yielding that contract is NOT checked here.
Independent technique: convex upper envelope + rational root inequality.
"""
from fractions import Fraction as F
from math import comb
A=F(4189,10000)
C=F(46374,10000)

def g(k,n):
    ell=F(369,100)*k+F(46,5)
    return 11*(A*(2*n*n-n)+C*n-2)-25+(n-1-12*k)*ell

def head(k):return g(k,2*k)
def near(k):return 2*k+g(k,2*k-1)
def far(k):return 2*k+g(k,12)
# Monotonicity proof for all integers k>=12: all three series are quadratic.
for name,fun in [('head',head),('tail-n2kminus1',near),('tail-n12',far)]:
    sd=fun(14)-2*fun(13)+fun(12)
    fd=fun(13)-fun(12)
    assert sd<0 and fd<0,(name,sd,fd)
    print(name,'k=12',fun(12),'delta-at-12',fd,'second-difference',sd)
assert head(12)==-96-F(119,1250)
assert head(12)<-96-F(1,16)
assert max(near(12),far(12)) < -605
# For 12<=n<=2k-1 the function n->g(k,n) is strictly convex,
# so all tail exponents <= max(g(k,12),g(k,2k-1)).
assert 22*A>0
# 2^(1/16)>=26/25 follows from rational 16th power check.
assert 26**16 < 2*25**16
# hence head <= 2^-96 * 25/26.
# tail <= 2^-605 < (1/26)*2^-96.
assert 26 < 2**(605-96)
# Independent finite sanity audit of the convex envelope (not proof for all k)
for k in range(12,51):
    upper=max(g(k,12),g(k,2*k-1))
    assert all(g(k,n)<=upper for n in range(12,2*k))
print('PASS: for all integer k>=12, conditional tail sum < 2^-96')
print('SCOPE: imported short-vector span-count lemma and probability normalization remain unverified')


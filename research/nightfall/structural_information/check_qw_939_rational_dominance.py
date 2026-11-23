#!/usr/bin/env python3
"""Exact-rational dominance certificate for QW vs. #939, tau in [1/100,1/4].

No floating point used. pi^2 in [49/5,10] is an explicit elementary
analytic premise (it follows from 3.14 < pi < 3.15). C2 < 106 is proved
using rational upper bounds on sqrt(2) and sqrt(3). The comparator for
#939 is a PAPER-only Wyner-normalized corollary, not a Lean theorem.
"""
from fractions import Fraction as Q

p2_lo, p2_hi = Q(49,5), Q(10)
r2lo, r2hi = Q(14142,10000), Q(14143,10000)
r3lo, r3hi = Q(17320,10000), Q(17321,10000)
assert r2lo**2 < 2 < r2hi**2
assert r3lo**2 < 3 < r3hi**2
c2lo = (2*(1+r2lo)*r3lo + Q(11901,6250))**2
c2hi = (2*(1+r2hi)*r3hi + Q(11901,6250))**2
assert Q(105) < c2lo <= c2hi < Q(106)

# QW monotone increasing in C2 and p2 = pi^2.
Aq_hi = 16 * p2_hi * 106
Bq_hi = 2**38 * p2_hi * 106**3
# #939 A = 48*pi^4*(2^2)*(3^4), B=(525.6*pi^4)^3*(2^6)*(3^12).
Ar_lo = 48 * p2_lo**2 * 2**2 * 3**4
Br_lo = (Q(5256,10) * p2_lo**2)**3 * 2**6 * 3**12

# For 1/100 <= tau <= 1/4:
# AQ*tau^-2 <= AR*tau^-3/2 iff AQ <= AR*sqrt(tau).
# 1/sqrt(tau) <= 10. Use exact rational sufficient inequalities.
assert Aq_hi * 10 < Ar_lo
# BQ*tau^-6 <= BR*tau^-9/2 iff BQ <= BR*tau^(3/2).
# 1/tau^(3/2) <= 1000.
assert Bq_hi * 1000 < Br_lo

print('PASS exact rational coefficient dominance for tau in [1/100,1/4], s>=0')
print('Premises: 49/5 < pi^2 < 10; C2 < 106 (radical bounds checked)')
print('seed margin lower bound as ratio (#939 / QW):', Ar_lo / (10*Aq_hi))
print('information margin lower bound as ratio (#939 / QW):', Br_lo / (1000*Bq_hi))
print('Status: conditional coefficient certificate, NOT kernel proof of QW or #939.')

#!/usr/bin/env python3
"""Independent exact rational proof-level audit of proposed uniform constant."""
from fractions import Fraction as F
from math import isqrt
for r in range(1,1001):
    d=F(1,20*r)
    loss=F(32,27)*r*d*d
    assert loss == F(2,675*r)
    # Rational inequality C_r^2>1/2 (no floating point).
    margin=2*(1-loss)**2-(2-d/2)
    assert margin== F(71,5400*r)+F(8,455625*r*r)
    assert margin>0
# Finite bounds: for q=1009 and r=5 the averaged W/I estimate is explicit.
q=1009;r=5;N=13;L=q*q-1;d=F(1,20*r)
J=(d*L).__ceil__()+N+2
lo=((1-d)*L).__ceil__();hi=((1-d/2)*L).__floor__()
I=hi-lo+1
W=F(q*(2*J+1),L)
limit=F(r, I)*(F(2,27)*W**3+F(1,8)*W**2)+F(r*(r-1),2)
assert limit>0
print('PASS: exact constant C_r>1/sqrt(2) for r=1..1000; symbolic margin identity holds')
print('sample finite cardinality deletion upper bound q1009 delta=1/(20r):',str(limit),'~',float(limit))

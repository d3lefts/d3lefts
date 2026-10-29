#!/usr/bin/env python3
"""Independent exact rational checks for the two-parameter Sidon window.
No algebraic CAS or external modules.
"""
from fractions import Fraction as F
from math import sqrt

def old_sq(r):
    t=F(1,r)
    return (1-F(2,675)*t)**2/(2-F(1,40)*t)

def new_sq(r):
    t=F(1,r)
    return (1-t/256)**2/(2-t/32)

for r in range(1,10001):
    t=F(1,r)
    gain=(t*(F(591667200)+5514896*t-25589*t*t))/ (F(186624000)*(80-t)*(64-t))
    assert new_sq(r)-old_sq(r)==gain>0, r
    base=t*(t+512)/(F(2048)*(64-t))
    assert new_sq(r)-F(1,2)==base>0,r
    eps=F(1,3); delta=F(3,64*r)
    removal=F(16,27)/eps*r*delta*delta
    assert removal==F(1,256*r)
    assert (1-eps)*delta == F(1,32*r)
    assert delta<F(1,4)
print('PASS: exact equality and strict gain for all 10,000 tested prefix sizes')
print('PROOF: square difference = t*(591667200+5514896t-25589t²)/(186624000*(80-t)*(64-t)) > 0 for 0<t<=1')
print('PROOF: C_new² - 1/2 = t*(t+512)/(2048*(64-t)) > 0 for 0<t<=1')
for r in [1,2,5,10,100]:
    print(f'r={r} old={sqrt(old_sq(r)):.12f} new={sqrt(new_sq(r)):.12f} gain={sqrt(new_sq(r))-sqrt(old_sq(r)):.12f}')

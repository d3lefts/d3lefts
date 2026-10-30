#!/usr/bin/env python3
"""Independent exact-rational audit of Tessara PR #94 against prior Ryev PR #84.
No imported project arithmetic.
"""
from fractions import Fraction as F
for m in range(1,10001):
    a=1-F(1,216*m)
    b=1-F(1,256*m)
    den=2-F(1,32*m)
    # Every coefficient is positive and Tessara clears the 1/sqrt2 boundary.
    assert a>0 and b>a and den>0
    assert 2*a*a-den==F(297*m+1,23328*m*m)>0
    assert b*b-a*a==F(5*(13824*m-59),47775744*m*m)>0
for R in range(1,121):
  for u in range(R+1):
    w=R-u
    assert F(u*(u+1)*w,2)<=F(2*R**3,27)+F(R**2,8)
for h in range(1,2001):
    v=10000+h
    start=v-h;end=v-(h+1)//2
    assert end-start+1 == h//2+1
print('PASS: m=1..10000, 7380 exact cubic endpoint cases, and h=1..2000 translation counts')
print('RESULT: Tessara c_m>1/sqrt2, yet Ryev c\u2032_m> Tessara c_m for every integer m>=1 by positive polynomials')

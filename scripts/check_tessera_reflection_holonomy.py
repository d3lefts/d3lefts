#!/usr/bin/env python3
"""Exact rational finite audit; no topology or universal injectivity certification."""
from fractions import Fraction as F
def g(a,b): return (a-2)**2+(b-2)**2-1
def sheet(a,b,sgn):
    # rational square roots on chosen perfect-square inputs
    from math import isqrt
    A,B=isqrt(a),isqrt(b)
    assert A*A==a and B*B==b
    z=g(F(a),F(b))
    return (F(A)+sgn*z*F(B))**2/(1+z*z)
for a,b in [(0,4),(1,4),(4,4),(9,4),(1,1),(4,1)]:
    z=g(F(a),F(b))
    delta=sheet(a,b,1)-sheet(a,b,-1)
    from math import isqrt
    assert delta==4*z*isqrt(a)*isqrt(b)/(1+z*z)
    assert (delta==0)==(a*b==0 or z==0)
# rational projector path nodes: angles 0,45,90,135,180 degrees
vectors=[(F(1),F(0)),(F(1),F(1)),(F(0),F(1)),(F(-1),F(1)),(F(1),F(0))]
projectors=[]
for x,y in vectors:
    d=x*x+y*y
    p=((x*x/d,x*y/d),(x*y/d,y*y/d))
    assert p[0][0]*p[1][1]==p[0][1]*p[1][0]
    assert p[0][0]+p[1][1]==1
    projectors.append(p)
assert projectors[0]==projectors[-1]
sign=1
for (a,b),(c,d) in zip(vectors,vectors[1:]):
    dot=a*c+b*d
    assert dot!=0
    sign*=1 if dot>0 else -1
assert sign==-1
# Reflection-blind five-readings fixture; x3 changes sign, all five unchanged.
def prefix(x):
    a,b,c,d=x
    return (a*a,b*b,d*d,(a+b)**2,(a-d)**2)
for x in [(F(1),F(2),F(3),F(4)),(F(0),F(-2),F(5),F(1))]:
    a,b,c,d=x
    assert prefix(x)==prefix((a,b,-c,d))
print("PASS exact finite fixtures; analytic topology and universal obstruction require proof")

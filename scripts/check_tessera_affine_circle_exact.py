#!/usr/bin/env python3
"""Exact rational fixture for Tessera affine-circle obstruction; NOT a topology proof."""
from fractions import Fraction as F
from itertools import product

def dot(a,b): return sum((x*y for x,y in zip(a,b)),F(0))
def outer(a): return [[x*y for y in a] for x in a]
def quad(Q,x): return dot(x,[dot(row,x) for row in Q])
rows=[(F(1),F(0),F(0),F(0)),(F(0),F(1),F(0),F(0)),
      (F(1),F(1),F(0),F(0)),(F(1),F(-1),F(0),F(0)),
      (F(2),F(1),F(0),F(0))]
Qs=list(map(outer,rows))
c=(F(1),F(2),F(0),F(0))
r=F(3)
# Four rational points on the circle in the common kernel; their antipodes.
vs=[(F(0),F(0),F(1),F(0)),(F(0),F(0),F(0),F(1)),
    (F(0),F(0),F(3,5),F(4,5))]
base=tuple(quad(Q,c) for Q in Qs)
assert base[0]>0
for v in vs:
    assert dot(v,v)==1
    xp=tuple(c[i]+r*v[i] for i in range(4))
    xm=tuple(c[i]-r*v[i] for i in range(4))
    assert tuple(quad(Q,xp) for Q in Qs)==base
    assert tuple(quad(Q,xm) for Q in Qs)==base
    diff=tuple(xp[i]-xm[i] for i in range(4))
    summ=tuple(xp[i]+xm[i] for i in range(4))
    assert min(dot(diff,diff),dot(summ,summ))==4*min(r*r,dot(c,c))
print("PASS: 3 rational antipodal pairs, 5 prefix detectors, exact gap squared =",4*min(r*r,dot(c,c)))

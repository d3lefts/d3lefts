#!/usr/bin/env python3
"""Exact 5-bit homogeneous cubic witness: coefficient 1 is false."""
from fractions import Fraction as Q
from itertools import combinations, product
from math import prod
S=list(combinations(range(5),3))
a=(-1,-1,-1,-1,-1,1,-1,1,-1,1)
assert len(a)==len(S)==10
values=[sum(a[j]*prod(x[i] for i in S[j]) for j in range(10))
        for x in product((-1,1),repeat=5)]
assert set(values)=={-4,0,4}
B=Q(4,8)
V=Q(sum(y*y for y in values),len(values)*64)
I=[Q(sum(a[j]**2 for j,s in enumerate(S) if i in s),64)
   for i in range(5)]
M=max(I)
assert V==Q(5,32) and set(I)=={Q(3,32)}
assert V**2/(B**2*M)==Q(25,24)
print('PASS: B=1/2 V=5/32 M=3/32; V^2/(B^2 M)=25/24 > 1')
print('LIMIT: witness excludes a constant-one bound, not exponent two')

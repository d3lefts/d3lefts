#!/usr/bin/env python3
"""Exact 3-color projection check on a skew product; independent of other audit scripts."""
from fractions import Fraction as Q
from itertools import product, combinations
from math import prod

p=[Q(1,2),Q(1,3),Q(1,4),Q(2,5),Q(3,7)]
n=len(p)
S=list(combinations(range(n),3))
a=[-1,-1,-1,-1,-1,1,-1,1,-1,1]
X=list(product((0,1),repeat=n))
def phi(x,s):
    return prod(Q(x[i])-p[i] for i in s)
F={x:sum((a[j]*phi(x,s) for j,s in enumerate(S)),Q(0)) for x in X}
B=max(map(abs,F.values()))
w=[Q(a[j]*a[j])*prod(p[i]*(1-p[i]) for i in s) for j,s in enumerate(S)]
V=sum(w)
I=[sum(w[j] for j,s in enumerate(S) if i in s) for i in range(n)]
mean=Q(0)
best=Q(0)
count=0
for colors in product(range(3),repeat=n):
    kept=[j for j,s in enumerate(S) if len({colors[i] for i in s})==3]
    vv=sum(w[j] for j in kept)
    vals=[sum((a[j]*phi(x,S[j]) for j in kept),Q(0)) for x in X]
    assert max(map(abs,vals))<=8*B
    assert all(sum(w[j] for j in kept if i in S[j])<=I[i] for i in range(n))
    mean+=vv
    best=max(best,vv)
    count+=1
assert count==243 and mean/count==Q(2,9)*V and best>=Q(2,9)*V
print('PASS: exact 243 colorings, mean energy=2/9 original, norm<=8B, influence monotone')
print('PASS: V=',V,'B=',B,'best retained variance=',best)
print('LIMIT: exact finite check is not a universal proof certificate')

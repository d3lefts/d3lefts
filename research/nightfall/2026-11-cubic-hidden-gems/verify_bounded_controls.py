#!/usr/bin/env python3
"""Exact Fraction checks for bounded controls with arbitrary leaf marginals.
Finite checks, not proof or originality certification.
"""
from fractions import Fraction as Q
from itertools import product
import random

rng=random.Random(20261110)
def trial(r):
    laws=[(Q(1,7),Q(2,7),Q(4,7)),(Q(2,5),Q(3,5)),
          (Q(1,4),Q(3,4)),(Q(2,7),Q(5,7)),(Q(3,8),Q(5,8))]
    sizes=[len(p) for p in laws]
    t=2
    coeffs={}
    center={}
    for a in product(*[range(sizes[j]) for j in range(t)]):
        center[a]=Q(rng.randrange(-4,5))
        for j in range(t,len(laws)):
            vals=[Q(rng.randrange(-4,5)) for _ in laws[j]]
            avg=sum(laws[j][v]*vals[v] for v in range(len(vals)))
            coeffs[(a,j)]=[v-avg for v in vals]
    f={};p={}
    for x in product(*[range(s) for s in sizes]):
        a=x[:t]
        f[x]=center[a]+sum(coeffs[(a,j)][x[j]] for j in range(t,len(laws)))
        pr=Q(1)
        for j,v in enumerate(x): pr*=laws[j][v]
        p[x]=pr
    B=max(abs(v) for v in f.values())
    mu=sum(p[x]*f[x] for x in f)
    V=sum(p[x]*(f[x]-mu)**2 for x in f)
    infl=[]
    for i in range(len(laws)):
        I=Q(0)
        for x in f:
            em=sum(laws[i][v]*f[x[:i]+(v,)+x[i+1:]] for v in range(sizes[i]))
            I+=p[x]*(f[x]-em)**2
        infl.append(I)
    M=max(infl)
    lhs=V-t*M
    assert lhs<=0 or lhs*lhs<=B*B*M,(r,lhs,M,B)
    assert V*V<=(t+1)**2*B*B*M,(r,V,M,B)
    return V,B,M

for r in range(60):trial(r)
for k in (1,2,3,5,8,20):
    B=Q(1); V=Q(1,k); M=Q(1,k*k)
    assert V*V==B*B*M
print('PASS 60 exact rational heterogeneous-product checks')
print('PASS 6 exact leading-constant equality examples')

#!/usr/bin/env python3
"""Exact parity-tilt moment camouflage and heat-bath attenuation audit."""
from fractions import Fraction as F
from itertools import product, combinations
from random import Random
from math import prod

RNG=Random(2026111307)

def var(P,f):
    m=sum((P[x]*f[x] for x in P),F(0))
    return sum((P[x]*(f[x]-m)**2 for x in P),F(0))

def influence(P,f,i):
    groups={}
    for x,p in P.items():
        groups.setdefault(x[:i]+x[i+1:],[]).append((p,f[x]))
    s=F(0)
    for rows in groups.values():
        w=sum((p for p,y in rows),F(0))
        if not w: continue
        mean=sum((p*y for p,y in rows),F(0))/w
        s+=sum((p*(y-mean)**2 for p,y in rows),F(0))
    return s

count={'exact_influence_all_f':0,'degree2_moment_covariance':0,'all_monomials':0}
for n in range(3,9):
    states=list(product((-1,1),repeat=n))
    mu={x:F(1,2**n) for x in states}
    for e in (F(0),F(1,13),F(1,3),F(1,2),F(3,4),F(1)):
        nu={x:mu[x]*(F(1)+(F(1)-e)*F(prod(x))) for x in states}
        assert sum(nu.values(),F(0))==1
        fac=2*e-e*e
        for trial in range(8):
            f={x:F(RNG.randint(-5,5),RNG.choice((1,2,3))) for x in states}
            for i in range(n):
                assert influence(nu,f,i)==fac*influence(mu,f,i),(n,e,i)
                count['exact_influence_all_f']+=1
        for d in range(0,min(3,(n-1)//2)+1):
            if not 2*d<n:continue
            subs=[s for z in range(d+1) for s in combinations(range(n),z)]
            co={s:F(RNG.randint(-4,4),RNG.choice((1,2,3))) for s in subs}
            f={x:sum((co[s]*prod(x[i] for i in s) for s in subs),F(0))
               for x in states}
            assert var(nu,f)==var(mu,f),(n,e,d)
            for s in subs:
                xs={x:F(prod(x[i] for i in s)) for x in states}
                assert sum((nu[x]*xs[x] for x in states),F(0))==sum(
                    (mu[x]*xs[x] for x in states),F(0))
                count['all_monomials']+=1
            count['degree2_moment_covariance']+=1
print({**count,'result':'all exact parity/moment/conditional-influence tests passed'})

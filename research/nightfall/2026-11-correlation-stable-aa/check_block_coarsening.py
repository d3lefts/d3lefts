#!/usr/bin/env python3
"""Exact finite audit of independent correlated blocks and degree preservation.

Constructs pointwise multilinear functions on fair source bits, places
arbitrary (possibly singular) dependence inside independent blocks,
then checks macroblock ANOVA degree and exact posterior influence drift.
"""
from fractions import Fraction as F
from itertools import product,combinations
from random import Random
from math import prod

R=Random(2026111406)

def variance(P,f):
    z=sum((p*f[x] for x,p in P.items()),F(0))
    return sum((p*(f[x]-z)**2 for x,p in P.items()),F(0))

def cond_mean(P,f,blks,S):
    out={};mass={}
    for x,p in P.items():
        key=tuple(tuple(x[j] for j in blks[i]) for i in S)
        mass[key]=mass.get(key,F(0))+p
        out[key]=out.get(key,F(0))+p*f[x]
    return {x: out[tuple(tuple(x[j] for j in blks[i]) for i in S)]/
               mass[tuple(tuple(x[j] for j in blks[i]) for i in S)]
            for x in P}

def anova(P,f,blks,S):
    v={x:F(0) for x in P}
    for z in range(len(S)+1):
        for U in combinations(S,z):
            h=cond_mean(P,f,blks,U)
            sign=(-1)**(len(S)-len(U))
            for x in P:v[x]+=sign*h[x]
    return v

def influence(P,f,blks,i):
    rest=tuple(j for j in range(len(blks)) if j!=i)
    pred=cond_mean(P,f,blks,rest)
    return sum((p*(f[x]-pred[x])**2 for x,p in P.items()),F(0))

def conditional_on_block(P,f,blks,i):
    result=F(0)
    vals={tuple(x[j] for j in blks[i]) for x in P}
    for v in vals:
        event={x:p for x,p in P.items()
               if tuple(x[j] for j in blks[i])==v}
        mass=sum(event.values(),F(0))
        if mass:
            Q={x:p/mass for x,p in event.items()}
            result+=mass*sum((influence(Q,f,blks,j)
                              for j in range(len(blks)) if j!=i),F(0))
    return result

counts={'arbitrary_correlated_blocks':0,
        'degree_component_checks':0,
        'macroblock_drift':0,
        'zero_atom_blocks':0}
for trial in range(110):
    m=R.randint(1,3)
    sizes=[R.randint(1,3) for _ in range(m)]
    blks=[];offset=0
    for a in sizes:
        blks.append(tuple(range(offset,offset+a)))
        offset+=a
    n=offset
    states=list(product((-1,1),repeat=n))
    joint={x:F(1) for x in states}
    used_zero=False
    for b in blks:
        words=list(product((-1,1),repeat=len(b)))
        nums=[R.randint(0,5) for _ in words]
        if not sum(nums):nums[0]=1
        if 0 in nums:used_zero=True
        q={w:F(a,sum(nums)) for w,a in zip(words,nums)}
        for x in states:
            joint[x]*=q[tuple(x[j] for j in b)]
    P={x:p for x,p in joint.items() if p}
    assert sum(P.values(),F(0))==1
    d=R.randint(1,min(3,n))
    mon=[S for z in range(d+1) for S in combinations(range(n),z)]
    coeff={S:F(R.randint(-4,4),R.choice((1,2,3))) for S in mon}
    f={x:sum((c*prod(x[j] for j in S) for S,c in coeff.items()),F(0))
       for x in P}
    v=variance(P,f)
    dactual=min(d,m)
    energy=F(0)
    for z in range(m+1):
        for S in combinations(range(m),z):
            g=anova(P,f,blks,S)
            E=sum((p*g[x]**2 for x,p in P.items()),F(0))
            if z>dactual:
                assert E==0,(trial,m,d,S,E)
            if z>=1:
                energy+=E
            counts['degree_component_checks']+=1
    assert energy==v,(trial,energy,v)
    T=sum((influence(P,f,blks,i) for i in range(m)),F(0))
    assert v<=T<=d*v
    for i in range(m):
        assert conditional_on_block(P,f,blks,i)==T-influence(P,f,blks,i)
        counts['macroblock_drift']+=1
    counts['arbitrary_correlated_blocks']+=1
    counts['zero_atom_blocks']+=used_zero

print({**counts,'result':'all exact tests passed'})

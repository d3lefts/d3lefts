#!/usr/bin/env python3
"""Exact finite original-law audit for fair+categorical cubic transfer.
Author-side examples and independent table evaluator, NOT universal proof.
"""
from fractions import Fraction as Q
from itertools import combinations, product
from math import prod
from random import Random


def test(laws, n, seed):
    rng=Random(seed)
    k=len(laws)
    A=list(product(*(range(len(p)) for p in laws)))
    F=list(product((-1,1),repeat=n))
    masks=[s for t in range(4) for s in combinations(range(n),t)]
    c0={s:Q(rng.randrange(-3,4)) for s in masks}
    single={}
    for j,p in enumerate(laws):
        for s in masks:
            if len(s)>2:continue
            raw=[Q(rng.randrange(-2,3)) for _ in p]
            mean=sum((raw[t]*p[t] for t in range(len(p))),Q())
            single[j,s]=[v-mean for v in raw]
    pairs={}
    for j,l in combinations(range(k),2):
        for s in masks:
            if len(s)>1:continue
            b=Q(rng.randrange(-2,3))
            pairs[j,l,s]=([b*x for x in single[j,s]],single[l,s])

    def chi(x,s):
        result=1
        for i in s:result*=x[i]
        return result
    def f(a,x):
        result=sum((q*chi(x,s) for s,q in c0.items()),Q())
        result+=sum((q[a[j]]*chi(x,s) for (j,s),q in single.items()),Q())
        result+=sum((u[a[j]]*v[a[l]]*chi(x,s)
                    for (j,l,s),(u,v) in pairs.items()),Q())
        return result
    def wt(a):
        return prod((laws[j][a[j]] for j in range(k)),start=Q(1))/2**n

    states=[(a,x) for a in A for x in F]
    vals={(a,x):f(a,x) for a,x in states}
    supported=[vals[a,x] for a,x in states if wt(a)>0]
    B=(max(supported)-min(supported))/2
    mean=sum((wt(a)*vals[a,x] for a,x in states),Q())
    V=sum((wt(a)*(vals[a,x]-mean)**2 for a,x in states),Q())

    influences=[]
    for j in range(k):
        influences.append(sum((
            wt(a)*laws[j][new]*
            (vals[a,x]-vals[a[:j]+(new,)+a[j+1:],x])**2/2
            for a,x in states for new in range(len(laws[j]))
        ),Q()))
    for i in range(n):
        influences.append(sum((
            wt(a)*(vals[a,x]-vals[a,x[:i]+(-x[i],)+x[i+1:]])**2/4
            for a,x in states
        ),Q()))
    M=max(influences,default=Q())

    g={x:sum((wt(a)*2**n*vals[a,x] for a in A),Q()) for x in F}
    assert all(g[x]==sum((q*chi(x,s) for s,q in c0.items()),Q()) for x in F)
    mg=sum(g.values(),Q())/len(F)
    Vg=sum(((g[x]-mg)**2 for x in F),Q())/len(F)
    IA=sum(influences[:k],Q())
    assert Vg<=V
    assert V-Vg<=IA,("original-law conditional Poincare",V,Vg,IA)
    assert Vg*Vg<=220*B*B*M
    assert max(V-IA,Q())**2<=220*B*B*M
    assert M<=B*B
    C={1:251,2:284,3:319}.get(k,(k+15)**2)
    assert V*V<=C*B*B*M,("hybrid constant",k,V,B,M,C)
    return 1


if __name__=="__main__":
    laws=[[Q(1,2),Q(1,2)],[Q(1,5),Q(4,5)],
          [Q(0),Q(1,7),Q(6,7)],[Q(1,4),Q(0),Q(3,4)],
          [Q(1,6),Q(1,3),Q(1,2)]]
    count=0
    for k in (1,2,3):
        for trial in range(12):
            ps=[laws[(2*trial+j)%len(laws)] for j in range(k)]
            count+=test(ps,3,10*k+trial)
    print("PASS source-law exact mixed-cubic replay:",count,
          "models, including zero-probability atoms")

#!/usr/bin/env python3
"""Exact weighted revealment influence inequality for overlapping selector leaves.
All site influences computed independently as conditional-variance buckets.
Finite examples only; analytic theorem in note, not Lean kernel certified.
"""
from fractions import Fraction as F
from itertools import product
from random import Random


def influence(vals, ws, n, i):
    groups={}
    for x,val in vals.items():
        z=groups.setdefault(x[:i]+x[i+1:],[F(0),F(0),F(0)])
        w=ws[x];z[0]+=w;z[1]+=w*val;z[2]+=w*val*val
    return sum((e2-e1*e1/w for w,e1,e2 in groups.values() if w),F(0))


def test(k,nleaf,t,seed):
    rng=Random(seed)
    addr=list(product((0,1), repeat=k))
    p=[F(rng.randrange(1,5),5) for _ in range(k)]
    v=[F(rng.randrange(1,5),5) for _ in range(nleaf)]
    def aw(a):
        out=F(1)
        for i,x in enumerate(a):out*=p[i] if x else 1-p[i]
        return out
    def yw(y):
        out=F(1)
        for i,x in enumerate(y):out*=v[i] if x else 1-v[i]
        return out
    selections={}
    gs={}
    for a in addr:
        size=rng.randrange(1,t+1)
        selection=tuple(sorted(rng.sample(range(nleaf),size)))
        selections[a]=selection
        gs[a]={w:rng.randrange(-7,8) for w in product((0,1),repeat=size)}
    q=[sum((aw(a) for a in addr if i in selections[a]),F(0)) for i in range(nleaf)]
    assert sum(q)<=t
    states=list(product((0,1),repeat=k+nleaf))
    fvals={}; weights={}
    for x in states:
        a=x[:k];y=x[k:];L=selections[a]
        fvals[x]=F(gs[a][tuple(y[j] for j in L)])
        weights[x]=aw(a)*yw(y)
    assert sum(weights.values())==1
    mean=sum((weights[x]*fvals[x] for x in states),F(0))
    V=sum((weights[x]*(fvals[x]-mean)**2 for x in states),F(0))
    active=[fvals[x] for x in states if weights[x]]
    B=F(max(active)-min(active),2)
    I=[influence(fvals,weights,k+nleaf,i) for i in range(k+nleaf)]
    assert V<=sum(I[:k])+sum(q[i]*I[k+i] for i in range(nleaf)),(seed,V,I,q)
    assert V<=(k+t)*max(I)
    assert V*V<=(k+t)*B*B*max(I)
    # Independently compute bar_f = E_A f from its definition and every leaf influence.
    ys=list(product((0,1),repeat=nleaf))
    bars={y:sum((aw(a)*F(gs[a][tuple(y[j] for j in selections[a])]) for a in addr),F(0)) for y in ys}
    bar_I=[]
    for i in range(nleaf):
        w={y:yw(y) for y in ys}
        ii=influence(bars,w,nleaf,i)
        bar_I.append(ii)
        assert ii<=q[i]*I[k+i],(seed,i,ii,q[i],I[k+i])
    return V,I,q,bar_I


def main():
    total=0
    for k,nleaf,t in [(1,3,2),(2,3,1),(2,4,2),(2,5,2),(3,4,2)]:
        for rep in range(40):
            test(k,nleaf,t,91073+k*310+nleaf*31+t*7+rep)
            total+=1
    print('PASS',total,'exact overlapping-leaf selector revealment cases')
    print('Scope: structural selector theorem, NOT universal cubic or all-degree UE2')


if __name__=='__main__':main()

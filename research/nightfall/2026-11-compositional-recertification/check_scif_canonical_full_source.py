#!/usr/bin/env python3
"""Independent exact Fraction audit of SCIF canonical finite-product source transport.

Not Lean, not proof: exhaustive worlds for each frozen finite fixture.
Uses conditional-source sums, NOT supplied pair kernels or SCIF repair formulas.
"""
from __future__ import annotations
from fractions import Fraction as Q
from itertools import product,combinations
from functools import lru_cache
from random import Random
from math import prod
import json

rng=Random(20261114)
n=4; alphabet=range(3); states=list(product(alphabet,repeat=n))
coordsets=[tuple(S) for d in range(5) for S in combinations(range(n),d)]
pairs=list(combinations(range(n),2))

def normalized():
    a=[rng.randrange(5) for _ in alphabet]
    if not sum(a):a[rng.randrange(len(a))]=1
    return tuple(Q(v,sum(a)) for v in a)

def source_f():
    unary=[[Q(rng.randrange(-4,5)) for _ in alphabet] for _ in range(n)]
    pair={ij:[[Q(rng.randrange(-3,4)) for _ in alphabet] for _ in alphabet] for ij in pairs}
    constant=Q(rng.randrange(-3,4))
    return {x: constant+sum(unary[i][x[i]] for i in range(n))+
            sum(pair[i,j][x[i]][x[j]] for i,j in pairs) for x in states}

def new_state(x,i,a):
    x=list(x);x[i]=a;return tuple(x)

class Source:
    def __init__(self,p,f):
        self.p=p;self.f=f
        self.mu={x:prod(p[i][x[i]] for i in range(n)) for x in states}

    @lru_cache(maxsize=None)
    def cond(self,U,vals):
        assert len(U)==len(vals)
        other=[i for i in range(n) if i not in U]
        v=Q()
        for ys in product(alphabet,repeat=len(other)):
            z=[None]*n
            for i,a in zip(U,vals):z[i]=a
            for i,a in zip(other,ys):z[i]=a
            z=tuple(z)
            v+=prod(self.p[i][z[i]] for i in other)*self.f[z]
        return v

    @lru_cache(maxsize=None)
    def es(self,S,vals):
        assert len(S)==len(vals)
        m=dict(zip(S,vals));out=Q()
        for t in range(len(S)+1):
            for U in combinations(S,t):
                out+=(-1)**(len(S)-t)*self.cond(U,tuple(m[i] for i in U))
        return out

    def comp(self,S,x):
        S=tuple(sorted(S)); return self.es(S,tuple(x[i] for i in S))

    def infl(self,i):
        return sum((self.mu[x]*(self.f[x]-sum(self.p[i][a]*self.f[new_state(x,i,a)] for a in alphabet))**2
                    for x in states),Q())

    def energy(self,i):
        return sum((self.mu[x]*self.comp(S,x)**2 for x in states
                    for S in coordsets if i in S and len(S)<=2),Q())


def recenter_run(idx):
    p=tuple(normalized() for _ in range(n))
    f=source_f()
    k=idx%n
    q=normalized()
    if q==p[k]:q=tuple(reversed(q))
    pp=tuple(q if i==k else p[i] for i in range(n))
    old=Source(p,f);new=Source(pp,f)
    beta=sum((q[a]*old.comp((k,),new_state((0,)*n,k,a)) for a in alphabet),Q())
    b={j:{v:sum((q[a]*old.comp((k,j),new_state(new_state((0,)*n,j,v),k,a))
                   for a in alphabet),Q()) for v in alphabet} for j in range(n) if j!=k}
    checks=0
    for x in states:
        assert old.comp((),x)+sum(old.comp((i,),x) for i in range(n))+sum(old.comp(pair,x) for pair in pairs)==f[x]
        assert new.comp((),x)==old.comp((),x)+beta
        assert new.comp((k,),x)==old.comp((k,),x)-beta
        for j in range(n):
            if j!=k:
                assert new.comp((j,),x)==old.comp((j,),x)+b[j][x[j]]
        for i,j in pairs:
            if k in (i,j):
                v=j if i==k else i
                assert new.comp((i,j),x)==old.comp((i,j),x)-b[v][x[v]]
            else:assert new.comp((i,j),x)==old.comp((i,j),x)
        for S in coordsets:
            if len(S)>2:
                assert old.comp(S,x)==new.comp(S,x)==0
        checks+=7+len(pairs)+len(coordsets)
    for j in range(n):
        assert old.infl(j)==old.energy(j)
        assert new.infl(j)==new.energy(j)
        oldinf=old.infl(j)
        newinf=new.infl(j)
        if j==k:
            delta=sum((q[a]*old.comp((k,),new_state((0,)*n,k,a))**2 -
                       p[k][a]*old.comp((k,),new_state((0,)*n,k,a))**2
                       for a in alphabet),Q())-beta*beta
            for v in range(n):
                if v==k: continue
                delta+=sum((p[v][u]*(q[a]-p[k][a])*old.comp((k,v),new_state(new_state((0,)*n,k,a),v,u))**2
                            for a in alphabet for u in alphabet),Q())
                delta-=sum((p[v][u]*b[v][u]**2 for u in alphabet),Q())
        else:
            delta=2*sum((p[j][u]*old.comp((j,),new_state((0,)*n,j,u))*b[j][u]
                         for u in alphabet),Q())
            delta+=sum((p[j][u]*(q[a]-p[k][a])*old.comp((k,j),new_state(new_state((0,)*n,j,u),k,a))**2
                        for a in alphabet for u in alphabet),Q())
        assert newinf-oldinf==delta,(idx,j,newinf-oldinf,delta)
        checks+=3
    eta=sum((abs(q[a]-p[k][a]) for a in alphabet),Q())
    scale=1+min(eta,Q(1))
    for j in range(n):
        if j==k:continue
        C=max((abs(old.comp((k,j),new_state(new_state((0,)*n,k,a),j,u)))
               for a in alphabet for u in alphabet),default=Q())
        assert all(abs(new.comp((k,j),new_state(new_state((0,)*n,k,a),j,u)))<=scale*C
                   for a in alphabet for u in alphabet)
        checks+=1
    return checks,eta

checks=0;etas=[]
for i in range(20):
    c,eta=recenter_run(i); checks+=c;etas.append(eta)
print(json.dumps({'status':'PASS','fixtures':20,'n':n,'alphabet':3,'assertions':checks,
                  'min_l1':str(min(etas)),'max_l1':str(max(etas)),
                  'scope':'actual canonical sources, all configurations, old/new direct influence, exact local recentering'}))

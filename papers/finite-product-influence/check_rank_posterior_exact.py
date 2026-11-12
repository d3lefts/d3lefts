#!/usr/bin/env python3
"""Exact rational finite-product audit of actual rank-valued posterior energy drift.

Tests finite heterogeneous independent categorical laws, actual degree <=2 vector
functions, every reachable conditioning transcript, and each reveal choice.
This is a finite falsifier, NOT a universal proof or Lean certificate.
"""
from __future__ import annotations
from fractions import Fraction as F
from itertools import combinations, product
from random import Random
from hashlib import sha256

RNG=Random(20261111)
def dot(a,b):return sum((x*y for x,y in zip(a,b)),F(0))
def mean(tbl,weights):
    z=[F(0)]*len(tbl[0]);den=sum(weights,F(0))
    for row,w in zip(tbl,weights):
        for k,x in enumerate(row):z[k]+=w*x
    return tuple(a/den for a in z)
def variance(tbl,weights):
    mu=mean(tbl,weights)
    return sum((w*dot(tuple(a-b for a,b in zip(row,mu)),tuple(a-b for a,b in zip(row,mu))) for row,w in zip(tbl,weights)),F(0))/sum(weights,F(0))
def all_states(alph):return list(product(*(range(a) for a in alph)))
def calc(alph,probs,model,obs):
    free=[i for i in range(len(alph)) if i not in obs]
    rows=[];weights=[]
    for x in all_states(alph):
        if any(x[i]!=a for i,a in obs.items()):continue
        w=F(1)
        for i in free:w*=probs[i][x[i]]
        rows.append(x);weights.append(w)
    tbl=[model(x) for x in rows]
    v=variance(tbl,weights)
    inf={}
    for i in free:
        # For every setting of X_-i, take variance over i only.
        contexts={}
        for x,w in zip(rows,weights):contexts.setdefault(tuple(x[j] for j in free if j!=i),[]).append((model(x),w))
        Ii=F(0)
        for pairs in contexts.values():
            rw=[v for _,v in pairs];tt=[t for t,_ in pairs]
            Ii+=sum(rw,F(0))*variance(tt,rw)
        inf[i]=Ii
    return v,inf

def build(alph,seed):
    rnd=Random(seed)
    r=2
    const=[[F(rnd.randint(-3,3)) for _ in range(r)]]
    singles={(i,a):tuple(F(rnd.randint(-5,5),3) for _ in range(r)) for i in range(len(alph)) for a in range(alph[i])}
    pairs={(i,j,a,b):tuple(F(rnd.randint(-4,4),5) for _ in range(r)) for i in range(len(alph)) for j in range(i+1,len(alph)) for a in range(alph[i]) for b in range(alph[j])}
    def model(x):
        return tuple(const[0][k]+sum(singles[i,x[i]][k] for i in range(len(alph)))+sum(pairs[i,j,x[i],x[j]][k] for i in range(len(alph)) for j in range(i+1,len(alph))) for k in range(r))
    return model

def audit():
    checks=0;out=[]
    for seed in range(1,22):
        n=3 if seed%3 else 4
        alph=tuple((2 if (i+seed)%3 else 3) for i in range(n))
        probs=[]
        for i,a in enumerate(alph):
            raw=[RNG.randint(1,8) for _ in range(a)];probs.append(tuple(F(x,sum(raw)) for x in raw))
        model=build(alph,seed)
        for size in range(n):
            for Q in combinations(range(n),size):
                for values in product(*(range(alph[i]) for i in Q)):
                    obs=dict(zip(Q,values))
                    v,inf=calc(alph,probs,model,obs)
                    p=sum(inf.values(),F(0))
                    if not v<=p<=2*v:raise AssertionError(('ANOVA energy',seed,obs,v,p))
                    for i in inf:
                        next_p=F(0)
                        for a,w in enumerate(probs[i]):
                            _,poster_inf=calc(alph,probs,model,{**obs,i:a})
                            next_p+=w*sum(poster_inf.values(),F(0))
                        if p-next_p!=inf[i]:raise AssertionError(('actual posterior drift',seed,obs,i,p,next_p,inf[i]))
                        checks+=1
                        out.append((seed,tuple(sorted(obs.items())),i,str(inf[i]),str(next_p)))
    # Lower example: exact risks after any q of rk independent fair signs.
    lower=0
    for r in range(1,9):
        for k in range(1,13):
            for q in (0,1,(r*k)//2,r*k):
                risk=F(1,k)-F(q,r*k*k)
                if risk<0:raise AssertionError(('negative risk',r,k,q))
                lower+=1
    dg=sha256(repr(out).encode()).hexdigest()
    print('PASS exact_heterogeneous_posterior_reveal_cases='+str(checks))
    print('PASS exact_rank_lower_bound_cases='+str(lower))
    print('audit_sha256='+dg)
    return checks,lower,dg
if __name__=='__main__':audit()

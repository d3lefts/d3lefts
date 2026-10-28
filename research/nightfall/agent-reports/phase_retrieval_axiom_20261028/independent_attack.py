#!/usr/bin/env python3
"""Separate F25 tuple-arithmetic attack on Frobenius-linearization claim.
No source imports from the construction decoder. Run: python3 independent_attack.py.
"""
from itertools import product
from random import Random
import json
Z=(0,0); I=(1,0)
E=list(product(range(5), repeat=2))
def plus(x,y):return ((x[0]+y[0])%5,(x[1]+y[1])%5)
def minus(x,y):return ((x[0]-y[0])%5,(x[1]-y[1])%5)
def times(x,y):return ((x[0]*y[0]+2*x[1]*y[1])%5,(x[0]*y[1]+x[1]*y[0])%5)
def raised(x,n):
    result=I
    for _ in range(n): result=times(result,x)
    return result
INV={a: next(b for b in E if times(a,b)==I) for a in E if a!=Z}
def dot(a,x):
    acc=Z
    for ai,xi in zip(a,x): acc=plus(acc,times(ai,xi))
    return acc

def rank(rows,n):
    # Separate algorithm: incremental span with first-nonzero pivot normalization.
    basis={}
    for original in rows:
        w=list(original)
        for pivot in sorted(basis):
            c=w[pivot]
            if c!=Z:
                w=[minus(a,times(c,b)) for a,b in zip(w,basis[pivot])]
        j=next((i for i,a in enumerate(w) if a!=Z),None)
        if j is None:continue
        inv=INV[w[j]]
        basis[j]=[times(inv,a) for a in w]
    return len(basis)

def linear_row(a,x):
    f=raised(dot(a,x),4)
    return [raised(v,5) for v in a]+[times((4,0),times(f,v)) for v in a]

def zero_polynomial_attack(x,k,seed=100):
    rng=Random(seed)
    zeros=[]
    for t in range(100):
        u=[E[rng.randrange(25)] for _ in range(k)]
        v=[E[rng.randrange(25)] for _ in range(k)]
        if all(val==Z for val in u+v):continue
        # Require (u,v) outside x-derived span.
        true=[raised(z,5) for z in x]+list(x)
        if rank([true,u+v],2*k)==1:continue
        exact_zero_count=0
        for a in product(E,repeat=k):
            lhs=dot([raised(ai,5) for ai in a],u)
            rhs=times(raised(dot(a,x),4),dot(a,v))
            if lhs==rhs:exact_zero_count+=1
        zeros.append(exact_zero_count)
        assert exact_zero_count <= 5*25**(k-1),(x,k,t,exact_zero_count)
    return max(zeros),len(zeros)

def main():
    assert len(set(E))==25
    assert all(times(a,INV[a])==I for a in E if a!=Z)
    assert all(raised(a,25)==a for a in E)
    cases={}
    for k in (1,2):
        if k==2:
            rows=list(product(E,repeat=2))
            full=0
            for x in product(E,repeat=2):
                if x==(Z,Z):continue
                r=rank((linear_row(a,x) for a in rows),4)
                assert r==3,(x,r)
                full+=1
            cases['exhaustive_k2']={'signals':full,'sensing_rows':len(rows),'rank':3}
        x=(I,)*(k)
        maxzeros,tests=zero_polynomial_attack(x,k)
        cases[f'zero_probability_k{k}']={'nontrivial_pairs_tested':tests,'max_zero_rows':maxzeros,'possible_rows':25**k,'schwartz_zippel_limit':5*25**(k-1)}
    # Random designs; independently compare all-signal feature rank to full orbit injection.
    rng=Random(20261028)
    for m in (4,6,8,12,16):
        fullrank=0;injective=0
        for trial in range(8):
            A=[(E[rng.randrange(25)],E[rng.randrange(25)]) for _ in range(m)]
            rankgood=True
            measurements={}
            collides=False
            for x in product(E,repeat=2):
                y=tuple(raised(dot(a,x),4) for a in A)
                # distinct orbits identified by the canonical min tuple
                orbit=tuple(sorted(tuple(times(g,xi) for xi in x) for g in E if g!=Z and raised(g,4)==I))
                canonical=orbit[0]
                if y in measurements and measurements[y]!=canonical:collides=True
                else:measurements[y]=canonical
                if x!=(Z,Z) and rankgood and rank((linear_row(a,x) for a in A),4)!=3:rankgood=False
            fullrank+=int(rankgood)
            injective+=int(not collides)
        cases[f'designs_m{m}']={'trials':8,'linearization_rank_all_signals':fullrank,'actual_injectivity_all_signals':injective}
    print(json.dumps({'status':'PASS','field':'F25 tuple arithmetic independently implemented','cases':cases},indent=2))
if __name__=='__main__':main()

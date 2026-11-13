#!/usr/bin/env python3
"""Exact rational finite falsifier for task-revelation cost theorem (not proof)."""
from fractions import Fraction as F
from itertools import product

def lin_solve(a,b):
    n=len(b)
    z=[list(a[i])+[b[i]] for i in range(n)]
    for i in range(n):
        j=next(j for j in range(i,n) if z[j][i])
        z[i],z[j]=z[j],z[i]
        k=z[i][i];z[i]=[v/k for v in z[i]]
        for j in range(n):
            if i!=j:
                k=z[j][i]
                z[j]=[z[j][h]-k*z[i][h] for h in range(n+1)]
    return [v[-1] for v in z]

tests=0
for beta in (F(1,3),F(1,2),F(2,5)):
    p=(1+beta)/2;q=(1-beta)/2;r=q/p
    for k in range(1,6):
        states=list(range(-k+1,k))
        a=[[F(int(s==t)) for t in states] for s in states]
        err=[F(0) for _ in states]
        ones=[F(1) for _ in states]
        for ix,s in enumerate(states):
            for step,prob in ((1,p),(-1,q)):
                if s+step in states:a[ix][states.index(s+step)]-=prob
                elif s+step==-k:err[ix]+=prob
        e=lin_solve(a,err)[states.index(0)]
        n=lin_solve(a,ones)[states.index(0)]
        assert e==r**k/(1+r**k)
        assert n==F(k)/beta*(1-r**k)/(1+r**k)
        tests+=1

# Adaptively choose second site using the first oracle result.
betas=[F(1,3),F(1,2),F(2,5)]
nus=list(product((-1,1),repeat=3))
atoms=0
for obs in product((-1,1),repeat=3):
    indices=(0,1 if obs[0]==1 else 2,2 if obs[1]==1 else 1)
    probs={}
    for nu in nus:
        x=F(1,8)
        for i,u in zip(indices,obs):
            x*= (1+betas[i]*nu[i]*u)/2
        probs[nu]=x
    total=sum(probs.values(),F(0))
    post={nu:prob/total for nu,prob in probs.items()}
    ms=[sum((post[nu]*nu[i] for nu in nus),F(0)) for i in range(3)]
    for nu in nus:
        prodp=F(1)
        for i in range(3):prodp*=(1+nu[i]*ms[i])/2
        assert post[nu]==prodp
        atoms+=1

# Task-overlap numerator >= denominator; extremal support cases.
pi=[F(1,2),F(1,3),F(1,6)]
sets=[{0,1},{1,2},{2,3}]
w=[F(1),F(2),F(1),F(3)]
early=sum((pi[t]*sum(w[i] for i in s) for t,s in enumerate(sets)),F(0))
late=sum(w,F(0))
assert late>=early>0
assert F(3)==F(3)/sum((F(1,3) for _ in range(3)),F(0))
print('PASS',tests,'independent absorbing chain solves,',atoms,
      'adaptive posterior-factorization atoms, weighted-overlap order')
print('This is a finite exact checker, not a theorem proof or novelty review.')

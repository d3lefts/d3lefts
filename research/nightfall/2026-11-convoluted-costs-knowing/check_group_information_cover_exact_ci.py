#!/usr/bin/env python3
"""Finite exact group-oracle falsifier. Passing is NOT theorem certification."""
from fractions import Fraction as F
from itertools import product

groups=({0,1},{1,2},{0,2})
x=(F(1,2),)*3
y=(F(1,2),)*3
assert all(sum(x[j] for j in range(3) if i in groups[j])>=1 for i in range(3))
assert all(sum(y[i] for i in groups[j])<=1 for j in range(3))
assert sum(x)==sum(y)==F(3,2)
assert F(3,2)/F(1)==F(3,2)

beta=(F(1,3),F(1,2),F(2,5))
hidden=list(product((-1,1),repeat=3))
atoms=0
risks=0
for first in product((-1,1),repeat=2):
    q2=1 if first[0]==1 else 2
    for second in product((-1,1),repeat=2):
        q3=2 if second[-1]==1 else 0
        for third in product((-1,1),repeat=2):
            queries=(0,q2,q3);answers=(first,second,third)
            masses={}
            for nu in hidden:
                p=F(1,8)
                for q,ans in zip(queries,answers):
                    for i,u in zip(sorted(groups[q]),ans):
                        p*=(1+beta[i]*nu[i]*u)/2
                masses[nu]=p
            z=sum(masses.values(),F(0))
            posterior={nu:p/z for nu,p in masses.items()}
            mean=[sum((posterior[nu]*nu[i] for nu in hidden),F(0)) for i in range(3)]
            for nu in hidden:
                prod=F(1)
                for i in range(3):prod*=(1+nu[i]*mean[i])/2
                assert prod==posterior[nu]
                atoms+=1
            for w in ((F(1,2),F(1,2),F(0)),(F(1,3),F(0),F(1,3))):
                a=[w[i]*beta[i] for i in range(3)]
                mm=sum(a[i]*mean[i] for i in range(3))
                lhs=sum((posterior[nu]*(sum(a[i]*nu[i] for i in range(3))-mm)**2
                         for nu in hidden),F(0))
                rhs=sum(a[i]*a[i]*(1-mean[i]*mean[i]) for i in range(3))
                assert lhs==rhs
                risks+=1
assert atoms==512 and risks==128
print('PASS independent-output group oracle exact audit: 3/2 dual; 512 likelihoods, 128 risk identities')
print('Scope: numerical instances only, not a mathematical proof or novelty certificate')

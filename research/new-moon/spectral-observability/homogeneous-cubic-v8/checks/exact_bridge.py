#!/usr/bin/env python3
"""Exact rational controls for NIGHTFALL homogeneous-layer bridge (v8).
Independent of Q2/Lk: reproduces ANOVA projections from conditional expectations.
"""
from fractions import Fraction as Q
from itertools import product, combinations
from functools import lru_cache
from math import prod

p=((Q(1,6),Q(1,3),Q(1,2)),(Q(1,4),Q(3,4)),
   (Q(1,5),Q(2,5),Q(2,5)),(Q(1,3),Q(2,3)),
   (Q(1,4),Q(1,4),Q(1,2)))
n=len(p)
points=list(product(*[range(len(pi)) for pi in p]))
weights={x:prod(p[i][v] for i,v in enumerate(x)) for x in points}
assert sum(weights.values())==1
cent=lambda i,v: Q(v==0)-p[i][0]
coeff={(0,):Q(2,5),(1,):Q(-1,3),(0,1):Q(2,3),
       (0,3):Q(-3,8),(1,4):Q(4,5),(0,1,2):Q(2,7),
       (0,3,4):Q(-3,5),(1,2,4):Q(5,6),(0,1,3):Q(-2,9)}
def raw(x):
    return sum((c*prod(cent(i,x[i]) for i in S)
                for S,c in coeff.items()),Q(0))
scale=max(abs(raw(x)) for x in points)
f={x:raw(x)/scale for x in points}
subsets=[tuple(S) for j in range(n+1)
         for S in combinations(range(n),j)]
@lru_cache(None)
def posterior_mean(A,values):
    A=set(A)
    return sum((f[y]*prod(p[i][y[i]] for i in range(n) if i not in A)
                for y in points
                if all(y[i]==values[j] for j,i in enumerate(sorted(A)))),Q(0))
def cmean(A,x):
    return posterior_mean(tuple(sorted(A)),tuple(x[i] for i in sorted(A)))
@lru_cache(None)
def mobius(S,x):
    return sum(((-1)**(len(S)-len(A))*cmean(A,x)
                for j in range(len(S)+1) for A in combinations(S,j)),Q(0))
components={(S,x):mobius(S,x) for S in subsets for x in points}
count=0
for x in points:
    assert sum((components[S,x] for S in subsets),Q(0))==f[x]
    count+=1
energies={S:sum((weights[x]*components[S,x]**2 for x in points),Q(0))
          for S in subsets}
var=sum((weights[x]*(f[x]-cmean((),x))**2 for x in points),Q(0))
assert var==sum((energies[S] for S in subsets if S),Q(0))
infl={i:sum((energies[S] for S in subsets if i in S),Q(0)) for i in range(n)}
for i in range(n):
    direct=sum((weights[x]*(f[x]-cmean(tuple(j for j in range(n) if j!=i),x))**2
                for x in points),Q(0))
    assert direct==infl[i]
    count+=1
def direct_noise(t,x):
    return sum((f[y]*prod(t*(y[i]==x[i])+(1-t)*p[i][y[i]]
            for i in range(n)) for y in points),Q(0))
for x in points:
    vals=[direct_noise(Q(j,3),x) for j in range(4)]
    a3=Q(9,2)*(vals[3]-3*vals[2]+3*vals[1]-vals[0])
    top=sum((components[S,x] for S in subsets if len(S)==3),Q(0))
    assert a3==top and abs(top)<=32 and abs(f[x]-top)<=33
    count+=1
def posterior_cubic(S,T,x):
    return sum(((-1)**(len(S)-len(A))*cmean(tuple(sorted(set(T)|set(A))),x)
                for j in range(4) for A in combinations(S,j)),Q(0))
resid={frozenset(T):sum((energies[S] for S in subsets if len(S)==3
                       and not set(S).intersection(T)),Q(0))
       for T in subsets}
for T in subsets:
    rem=[i for i in range(n) if i not in T]
    triples=list(combinations(rem,3))
    for x in points:
        direct=sum((posterior_cubic(S,T,x) for S in triples),Q(0))
        target=sum((components[S,x] for S in triples),Q(0))
        assert direct==target
        count+=1
sets=[frozenset(S) for S in subsets]
submod=0
for A in sets:
    for C in sets:
        assert resid[A]+resid[C]<=resid[A|C]+resid[A&C]
        submod+=1
def greedy(h):
    T=frozenset()
    for _ in range(min(h,n)):
        j=max((j for j in range(n) if j not in T),
              key=lambda i:(resid[T]-resid[T|{i}],-i))
        T=T|{j}
    return T
cover=0
for t in range(1,n+1):
    opt=min(resid[S] for S in sets if len(S)<=t)
    for h in range(n+1):
        got=resid[greedy(h)]
        upper=opt+Q(t-1,t)**h*(resid[frozenset()]-opt)
        assert got<=upper
        cover+=1
S3={0,1,2}; S4={0,1,3,4}
assert len(S3&S4)==2 and len(S3 & (S4-{4}))==2
delta=Q(1,4)
assert Q(1,2)*(1+delta)**2>Q(1,2)+delta**2
def cheb3(t): return 32*t**3-48*t**2+18*t-1
assert cheb3(Q(0))==-1 and cheb3(Q(1))==1
assert all(abs(cheb3(Q(i,120)))<=1 for i in range(121))
print('PASS: exact Mobius ANOVA/variance/influence/noise checks:',count)
print('PASS: cubic energy submodularity:',submod)
print('PASS: greedy-cover recurrence:',cover)
print('PASS: posterior-top, cross-degree and adaptive-tail negative controls')
print('LIMIT: does not certify imported Q2/Lk or infinite-product arguments')

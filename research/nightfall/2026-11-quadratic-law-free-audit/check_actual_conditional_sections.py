#!/usr/bin/env python3
"""Exact Fraction regression for actual source finite-neighbor conditional sections.

This test intentionally derives f from arbitrary constant, singleton and pair
coefficient tables, then independently recomputes conditional expectations
and canonical Hoeffding components from the original source f.
It includes heterogeneous alphabets and zero/rare probability atoms.

Falsification only: not a universal proof or independent Lean kernel check.
"""
from fractions import Fraction as Q
from itertools import product, combinations
from random import Random
from collections import Counter

R = Random(20261113)
C = Counter()

def all_configs(sizes):
    return list(product(*(range(n) for n in sizes)))

def p_mass(p, y):
    z = Q(1)
    for k, a in enumerate(y): z *= p[k][a]
    return z

def check_case(sizes, trial):
    n = len(sizes)
    p=[]
    for k in sizes:
        v=[R.choice([1,2,3,5,7,101,100003]) for _ in range(k)]
        if trial % 5 == 0:
            v[R.randrange(k)]=0
        if sum(v) == 0: v[0]=1
        p.append([Q(w,sum(v)) for w in v])
    linear=[[R.randrange(-6,7) for _ in range(k)] for k in sizes]
    pairs={(i,j):[[R.randrange(-4,5) for _ in range(sizes[j])] for _ in range(sizes[i])]
           for i,j in combinations(range(n),2)}
    base=R.randrange(-9,10)
    def f(x):
        return Q(base + sum(linear[i][a] for i,a in enumerate(x))
                 + sum(pair[x[i]][x[j]] for (i,j),pair in pairs.items()))
    space=all_configs(sizes)
    weights={y:p_mass(p,y) for y in space}
    assert sum(weights.values(),Q(0))==1
    def merged(S,x,y):
        return tuple(x[k] if k in S else y[k] for k in range(n))
    def updated(x,i,a):
        return tuple(a if k==i else x[k] for k in range(n))
    def cond(S,x):
        return sum((weights[y]*f(merged(S,x,y)) for y in space), Q(0))
    mu=cond(frozenset(),space[0])
    u={(i,a):cond({i},updated(space[0],i,a))-mu
       for i in range(n) for a in range(sizes[i])}
    h={}
    for i,j in combinations(range(n),2):
        for a,b in product(range(sizes[i]),range(sizes[j])):
            x=updated(updated(space[0],i,a),j,b)
            h[i,j,a,b]=cond({i,j},x)-u[i,a]-u[j,b]-mu
    def pair(i,j,a,b):
        return h[i,j,a,b] if i<j else h[j,i,b,a]
    def section(i,y,a):
        return f(updated(y,i,a))-sum((p[i][b]*f(updated(y,i,b))
                                     for b in range(sizes[i])), Q(0))
    sample_x=space if n<4 else [space[0],space[-1],R.choice(space),R.choice(space)]
    for i in range(n):
        other=[j for j in range(n) if j!=i]
        for mask in range(1<<len(other)):
            S=frozenset(j for t,j in enumerate(other) if (mask>>t)&1)
            for x in sample_x:
                vector=[]
                vector_sq=[]
                for a in range(sizes[i]):
                    z=sum((weights[y]*section(i,merged(S,x,y),a) for y in space), Q(0))
                    rhs=cond(S|{i},updated(x,i,a))-cond(S,x)
                    assert z==rhs,(sizes,trial,i,S,x,a,"conditional identity",z,rhs)
                    pair_sum=u[i,a]+sum((pair(i,j,a,x[j]) for j in S),Q(0))
                    assert z==pair_sum,(sizes,trial,i,S,x,a,"pair projection",z,pair_sum)
                    q=sum((weights[y]*section(i,merged(S,x,y),a)**2 for y in space),Q(0))
                    assert z*z<=q,(sizes,trial,i,S,x,a,"scalar Jensen")
                    vector.append(z)
                    vector_sq.append(q)
                    C['source_conditional_identity']+=1
                    C['degree_two_pair_projection']+=1
                    C['scalar_Jensen_square']+=1
                lhs=sum((p[i][a]*vector[a]**2 for a in range(sizes[i])),Q(0))
                rhs=sum((p[i][a]*vector_sq[a] for a in range(sizes[i])),Q(0))
                assert lhs<=rhs,(sizes,trial,i,S,x,"Hilbert squared Jensen")
                C['Hilbert_squared_Jensen']+=1

for n in (2,3,4):
    for trial in range(14):
        check_case([R.choice((2,3)) for _ in range(n)],trial)
        C['models']+=1
print("PASS independent finite actual-source conditional section exact regression")
for name in sorted(C): print(name,C[name])
print("Scope: exact finite falsifier, not universal or Lean theorem certification.")

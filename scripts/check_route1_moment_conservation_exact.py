#!/usr/bin/env python3
"""Exact finite audits: moment matching conserves low-degree query-tree L2 risk.

Rational / integer only; no epsilon comparison. The universal mathematical
claim has a separate elementary proof. Tests are NOT Lean certificates.
"""
from collections import Counter
from fractions import Fraction as F
from itertools import combinations, product
from math import prod
from random import Random

rng = Random(20261121)
stats = Counter()

def uniform(n):
    return {x: F(1, 2**n) for x in product((-1, 1), repeat=n)}

def parity_blocks(L, r):
    n=L*r
    xs=[x for x in product((-1,1),repeat=n)
        if all(prod(x[g*L:(g+1)*L])==1 for g in range(r))]
    return {x:F(1,len(xs)) for x in xs}

def weighted(mu,fn):
    return sum((p*fn(x) for x,p in mu.items()), F(0))

def monomial(x,S):return prod(x[i] for i in S)

def overlap_marginals(U,V,k):
    n=len(next(iter(U)))
    for m in range(k+1):
        for I in combinations(range(n),m):
            u=Counter()
            v=Counter()
            for x,p in U.items():u[tuple(x[i] for i in I)]+=p
            for x,p in V.items():v[tuple(x[i] for i in I)]+=p
            assert u==v,("marginal mismatch",I,u,v)
            stats["exact_marginals"]+=1

def random_poly(n,d):
    J=[tuple(sorted(rng.sample(range(n),rng.randrange(d+1))))
       for _ in range(5)]
    A=[F(rng.randrange(-6,7),60) for _ in J]
    den=max(F(1),2*sum(map(abs,A)))
    A=[a/den for a in A]
    def f(x):return F(1,2)+sum((a*monomial(x,s) for a,s in zip(A,J)),F(0))
    return f

def random_adaptive_tree(n,q):
    # Each next query may depend on all previous observed values.
    queries={(i,path):rng.randrange(n)
             for i in range(q) for path in product((-1,1),repeat=i)}
    leaves={path:F(rng.randrange(0,7),6)
            for path in product((-1,1),repeat=q)}
    def t(x):
        path=()
        for i in range(q):path=path+(x[queries[(i,path)]],)
        return leaves[path]
    return t

# Both parameter regimes and exponentially growing pointwise R=2^r.
for L,r,d,q,trials in ((4,1,1,2,25),(4,2,1,2,35),
                       (4,3,1,2,15),(5,2,1,3,20),
                       (5,2,2,1,20)):
    assert max(2*d,d+q)<L
    n=L*r
    U=uniform(n)
    V=parity_blocks(L,r)
    assert len(V)==2**(r*(L-1))
    assert all(V.get(x,0) in (0,2**r*p) for x,p in U.items())
    assert max(V.values())/max(U.values())==2**r
    stats["domination_examples"]+=1
    if n<=10:
        overlap_marginals(U,V,L-1)
    for _ in range(trials):
        f=random_poly(n,d)
        t=random_adaptive_tree(n,q)
        assert all(0<=f(x)<=1 for x in U)
        assert weighted(U,lambda x:(f(x)-t(x))**2)==weighted(
            V,lambda x:(f(x)-t(x))**2)
        stats["adaptive_risk_equalities"]+=1

# Sharpness of order 2d, when q≤d: conditional parity on 2d signs.
for d in (1,2,3):
    n=2*d
    U=uniform(n)
    V=parity_blocks(n,1)   # (n-1)-wise identical to U
    A=tuple(range(d))
    B=tuple(range(d,n))
    f=lambda x:F(2+monomial(x,A)+monomial(x,B),4)
    base=weighted(U,lambda x:f(x)**2)
    constrained=weighted(V,lambda x:f(x)**2)
    assert constrained-base==F(1,8)
    stats["sharp_2d_counterexamples"]+=1

# Sharpness of d+q, with q>d, and a deterministic nonadaptive tree.
for d,q in ((1,2),(1,3),(2,3),(2,4)):
    n=d+q
    U=uniform(n);V=parity_blocks(n,1)
    A=tuple(range(d));B=tuple(range(d,n))
    f=lambda x:F(1+monomial(x,A),2)
    t=lambda x:F(1+monomial(x,B),2)
    assert weighted(U,lambda x:(f(x)-t(x))**2)==F(1,2)
    assert weighted(V,lambda x:(f(x)-t(x))**2)==0
    stats["sharp_dq_counterexamples"]+=1

# Tail event probabilities do NOT transfer when loss expectation does.
U=uniform(3); V=parity_blocks(3,1)
f=lambda x:F(3+sum(x),6)
assert weighted(U,lambda x:f(x)**2)==weighted(V,lambda x:f(x)**2)==F(1,3)
assert weighted(U,lambda x:int(f(x)>F(1,2)))==F(1,2)
assert weighted(V,lambda x:int(f(x)>F(1,2)))==F(1,4)
stats["tail_event_counterexamples"]+=1

# Biased-product nonuniform source and an explicitly moment-matched
# global perturbation of its density: ν(x)=Q(x)(1+∏(x_i-p_i)).
n=5
P=[F(1,3),F(2,5),F(3,7),F(4,9),F(5,11)]
states=tuple(product((0,1),repeat=n))
Q={x:prod(P[i] if x[i] else 1-P[i] for i in range(n)) for x in states}
V={x:q*(1+prod((x[i]-P[i]) for i in range(n)))
   for x,q in Q.items()}
assert sum(Q.values())==sum(V.values())==1
assert min(V.values())>=0
overlap_marginals(Q,V,n-1)
for _ in range(30):
    # d=1, q=3; 2d=2 and d+q=4. Use arbitrary 0/1 trees.
    supports=[rng.randrange(n) for j in range(4)]
    weights=[F(rng.randrange(-5,6),40) for j in supports]
    den=max(F(1),2*sum(map(abs,weights)))
    def f(x):
        return F(1,2)+sum((w*(2*x[i]-1)/den
                           for w,i in zip(weights,supports)),F(0))
    t=random_adaptive_tree(n,3)
    assert all(0<=f(x)<=1 for x in states)
    assert weighted(Q,lambda x:(f(x)-t(x))**2)==weighted(
        V,lambda x:(f(x)-t(x))**2)
    stats["biased_product_transfers"]+=1

print("PASS sharp marginal-order conservation of degree-d query risk")
for key in sorted(stats): print(key+":",stats[key])
print("SCOPE: exact finite checks; universal law mathematical proof only, "
      "no high-probability event invariance or Simon convergence claim")

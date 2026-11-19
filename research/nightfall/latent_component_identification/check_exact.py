#!/usr/bin/env python3
"""Exact rational falsifier. Finite tests do NOT prove the analytic lemma."""
from fractions import Fraction as F
from itertools import combinations, product
from random import Random
from pathlib import Path
from hashlib import sha256
r=Random(20261119); nchecks=0
def chk(p, msg):
    global nchecks
    if not p: raise AssertionError(msg)
    nchecks+=1
def mul(seq):
    out=F(1)
    for x in seq:out*=x
    return out
def expectation(f,p):
    return sum(v*mul(pi if xi else 1-pi for xi,pi in zip(x,p)) for x,v in f.items())
def overlap(p,q,S):
    return sum(min(mul(p[i] if z else 1-p[i] for i,z in zip(S,a)),
                   mul(q[i] if z else 1-q[i] for i,z in zip(S,a)))
               for a in product((0,1),repeat=len(S)))
for mi in [100,101,200,1000,100000,10000000]:
    m=F(mi);p=F(1,2)-20/m;q=F(1,2)+20/m
    a=F(2,5)-10/m;b=F(3,5)+10/m;e=F(1,10)
    chk(0<=p<=q<=1 and b-a>2*e,"centres and bounds")
    chk(a-e<=p-10/m and p+10/m<=a+e,"μ concentration interval")
    chk(b-e<=q-10/m and q+10/m<=b+e,"ν concentration interval")
    chk(p*(1-p)<=F(1,4) and q*(1-q)<=F(1,4),"variance")
    chk(q-p==40/m,"marginal TV")
    chk((p*(1-p)/m**2)/(10/m)**2<=F(1,400),"Chebyshev")
support=[F(0),F(1),F(1,1000),F(999,1000),F(1,5),F(4,5),F(1,2),F(1,3),F(2,3)]
for trial in range(1200):
    n=r.randint(1,7);d=r.randint(1,min(n,3))
    monoms=[S for j in range(d+1) for S in combinations(range(n),j)]
    coeff=[r.randint(-4,4) for _ in monoms]
    raw={x:sum(c for S,c in zip(monoms,coeff) if all(x[i] for i in S))
         for x in product((0,1),repeat=n)}
    lo,hi=min(raw.values()),max(raw.values())
    f={x:F(z-lo,hi-lo) if hi>lo else F(1,2) for x,z in raw.items()}
    p=[r.choice(support) for _ in range(n)]
    q=[r.choice(support) for _ in range(n)]
    mu,nu=expectation(f,p),expectation(f,q)
    # Independent monomial expectation (separately from 2^n brute force).
    def via_monomials(ps):
        return (sum(F(c,hi-lo)*mul(ps[i] for i in S)
                    for S,c in zip(monoms,coeff))-F(lo,hi-lo)) if hi>lo else F(1,2)
    chk(mu==via_monomials(p),"μ expectation disagreement")
    chk(nu==via_monomials(q),"ν expectation disagreement")
    eta=max(abs(a-b) for a,b in zip(p,q))
    chk(abs(mu-nu)<=2*d*d*eta,"degree stability violated")
    S=tuple(i for i in range(n) if r.randrange(2))
    T=tuple(i for i in range(n) if i not in S)
    eta_t=max((abs(p[i]-q[i]) for i in T),default=F(0))
    a=r.choice([F(1,10),F(1,3),F(1,2),F(2,3),F(9,10)])
    b=r.choice([F(1,10),F(1,3),F(1,2),F(2,3),F(9,10)])
    eps=r.choice([F(0),F(1,100),F(1,10)])
    g=abs(a-b)-2*eps-2*d*d*eta_t
    if g>0:
        bad0=sum(mul(p[i] if x[i] else 1-p[i] for i in range(n))
                 for x,v in f.items() if abs(v-a)>eps)
        bad1=sum(mul(q[i] if x[i] else 1-q[i] for i in range(n))
                 for x,v in f.items() if abs(v-b)>eps)
        chk(g*overlap(p,q,S)<=bad0+bad1,"overlap transfer violated")
print("PASS",nchecks,"exact-rational assertions; sha256",sha256(Path(__file__).read_bytes()).hexdigest())

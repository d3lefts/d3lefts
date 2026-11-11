#!/usr/bin/env python3
"""Independent exact finite checks of the deterministic-sign Hilbert lift.

No floating point is used. The universal fourth-moment bound is proved in
FINITE_SIGN_CLOSURE_v2.md; this file independently checks rational Gram
matrices, sign moment identities, and outward-directed sqrt lower bounds.
"""
from __future__ import annotations
from fractions import Fraction as F
from itertools import product
from math import isqrt
from hashlib import sha256
from random import Random

SEED=20261111
rng=Random(SEED)

def dot(a,b):
    return sum((x*y for x,y in zip(a,b)), F(0))

def sqrt_lower(q, precision=10**16):
    assert q>=0
    n=isqrt((q.numerator*precision*precision)//q.denominator)
    return F(n,precision)

def check(w):
    r=len(w)
    gram=[[dot(w[i],w[j]) for j in range(r)] for i in range(r)]
    s=sum((gram[i][i] for i in range(r)),F(0))
    moment2=F(0); moment4=F(0); l1_lower=F(0)
    for eps in product((-1,1),repeat=r):
        ss=sum((F(eps[i]*eps[j])*gram[i][j] for i in range(r) for j in range(r)),F(0))
        assert ss>=0
        moment2+=ss
        moment4+=ss*ss
        l1_lower+=sqrt_lower(ss)
    denom=2**r
    moment2/=denom; moment4/=denom; l1_lower/=denom
    exact_formula=s*s+4*sum((gram[i][j]**2 for i in range(r) for j in range(i+1,r)),F(0))
    assert moment2==s, (r,w,moment2,s)
    assert moment4==exact_formula, (r,w,moment4,exact_formula)
    assert moment4<=3*s*s,(w,moment4,3*s*s)
    if s:
        assert l1_lower*l1_lower >=s/3,(w,l1_lower,s)
    return moment4, s

n=0
for rank in range(1,7):
    for dim in range(1,5):
        for _ in range(40):
            vectors=[[F(rng.randint(-7,7),rng.randint(1,9)) for _ in range(dim)] for _ in range(rank)]
            check(vectors)
            n+=1
for rank in range(1,7):
    for dim in range(1,5):
        for choice in range(3):
            base=[F(rng.randint(-5,5),7) for _ in range(dim)]
            vectors=[[F(0)]*dim for _ in range(rank)] if choice==0 else [[F(k+1)*v for v in base] for k in range(rank)] if choice==1 else [[v if k%2==0 else -v for v in base] for k in range(rank)]
            check(vectors);n+=1
assert n==1032,n
receipt=f"PASS exact_sign_hilbert_cases={n} seed={SEED} fourth_ratio_upper=3"
print(receipt)
print("receipt_sha256",sha256(receipt.encode()).hexdigest())

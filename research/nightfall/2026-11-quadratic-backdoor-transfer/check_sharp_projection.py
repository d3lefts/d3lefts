#!/usr/bin/env python3
"""Exact rational independent verifier for sharp top Hoeffding-layer removal.

Tests finite biased Bernoulli models, exact Chebyshev recurrence, and an explicit
asymptotically extremizing sequence for d=1..8. Finite checks do not replace the
analytic interpolation proof or establish prior-art priority.
"""
from fractions import Fraction as Q
from itertools import combinations, product
from math import prod
from random import Random
from hashlib import sha256
import json

SEED=20261111


def plus(a,b):
    out=[Q(0)]*max(len(a),len(b))
    for i,x in enumerate(a):out[i]+=x
    for i,x in enumerate(b):out[i]+=x
    return out


def mul_z(a):
    # Multiply by z=2t-1 in ascending-order t coefficients.
    out=[Q(0)]*(len(a)+1)
    for i,x in enumerate(a):out[i]-=x;out[i+1]+=2*x
    return out


def cheb(d):
    # T_d(2t-1), exact integer coefficients.
    if d==0:return [Q(1)]
    a=[Q(1)];b=[Q(-1),Q(2)]
    for j in range(2,d+1):
        c=plus([2*x for x in mul_z(b)],[-x for x in a])
        a,b=b,c
    return b


def fvals(n,p,coeff):
    pts=list(product((0,1),repeat=n))
    vals={x:sum((a*prod(Q(x[i])-p[i] for i in S)
                 for S,a in coeff.items()),Q(0)) for x in pts}
    return pts,vals


def run():
    rng=Random(SEED)
    model_count=0
    maxratio=Q(0)
    for d in range(1,7):
        coeff_t=cheb(d)
        assert len(coeff_t)==d+1
        assert sum(coeff_t,Q(0))==1
        assert coeff_t[-1]==2**(2*d-1)
        for n in range(max(3,d),8):
            for j in range(12):
                p=[rng.choice([Q(1,2),Q(1,3),Q(1,97),Q(96,97)]) for _ in range(n)]
                c={S:Q(rng.randrange(-5,6),rng.choice([1,2,7]))
                   for deg in range(d+1) for S in combinations(range(n),deg)}
                pts,vals=fvals(n,p,c)
                b=max(abs(v) for v in vals.values())
                proj={x:sum((a*prod(Q(x[i])-p[i] for i in S)
                             for S,a in c.items() if len(S)<d),Q(0)) for x in pts}
                bproj=max(abs(v) for v in proj.values())
                if b:ratio=bproj/b;maxratio=max(maxratio,ratio)
                assert bproj <= (2**(2*d-1)-1)*b
                model_count+=1
    # Explicit finite sharpness witnesses: p_n=1/n^2 and f=T_d(2S/n-1).
    sharp=[]
    for d in range(1,9):
        L=2**(2*d-1)
        assert cheb(d)[-1]==L
        vals=[]
        for n in (100*d,1000*d,10000*d):
            p=Q(1,n*n)
            falling=prod(range(n-d+1,n+1))
            H=Q(L*falling,n**d)*(1-p)**d
            q=1-H
            assert abs(q) <= L-1
            vals.append(q)
        # At the all-ones input, q approaches 1-L from above.
        assert vals[2] < vals[1] < vals[0]
        assert 0 <= vals[2]-(1-L) < Q(L*d*d,10000*d)
        sharp.append({"degree":d,"operator_norm":L-1,
                      "finite_ratio_n_10000d":str(abs(vals[2]))})
    result={"seed":SEED,"model_count":model_count,"max_random_ratio":str(maxratio),
            "sharpness_witnesses":sharp,"arith":"exact rational",
            "independent_global_priority_review":False}
    print("PASS exact_projection_models="+str(model_count))
    print("PASS exact_sharpness_degrees=8")
    print(json.dumps(result,sort_keys=True))
    print("audit_digest_sha256",sha256(json.dumps(result,sort_keys=True).encode()).hexdigest())

if __name__=="__main__":run()

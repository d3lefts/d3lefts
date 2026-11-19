#!/usr/bin/env python3
"""Exact rational falsifier for the binary quadratic arbitrary-coupling bound.

This is not a proof of real Grothendieck's inequality. It independently
checks the algebraic norm reductions and random correlated finite joint laws.
K_G <= 2 is a conservative external upper bound, checked in the literature;
the script uses the exact consequence (max(E|Delta f|-p,0))^2 <= 256*p.
"""
from __future__ import annotations
from fractions import Fraction as Q
from itertools import product, combinations
from random import Random
import json


def parity(x, ids):
    sign=1
    for i in ids:
        sign*=x[i]
    return sign


def make_quadratic(n: int, seed: int):
    rng=Random(seed)
    coefs={ids: Q(rng.randint(-4,4)) for k in (0,1,2)
           for ids in combinations(range(n), k)}
    raw={x:sum((c*parity(x, ids) for ids,c in coefs.items()),Q(0))
         for x in product((-1,1),repeat=n)}
    lo,hi=min(raw.values()),max(raw.values())
    if hi==lo:
        return {():Q(1,2)}, {x:Q(1,2) for x in raw}
    norm={ids:c/(hi-lo) for ids,c in coefs.items()}
    norm[()]-=lo/(hi-lo)
    vals={x:(y-lo)/(hi-lo) for x,y in raw.items()}
    return norm, vals


def norms(coefs: dict, n: int):
    a=[coefs.get((i,),Q(0)) for i in range(n)]
    assert sum(map(abs,a)) <= Q(1,2)
    def bilinear(x,y):
        return sum((coefs.get((i,j),Q(0)) *
                    Q(x[i]*y[j]+x[j]*y[i],2)
                    for i in range(n) for j in range(i+1,n)),Q(0))
    points=list(product((-1,1),repeat=n))
    supB=max(abs(bilinear(x,y)) for x in points for y in points)
    assert supB <= 2
    return supB, sum(map(abs,a))


def correlated_instance(n: int, seed: int):
    coefs, f=make_quadratic(n,seed)
    bnorm, anorm=norms(coefs,n)
    pts=list(f)
    rng=Random(seed+9011)
    # Arbitrarily correlated pairs, NOT product-pair couplings.
    states=[(rng.choice(pts),rng.choice(pts),rng.randint(1,5)) for _ in range(14)]
    total=sum(k for _,_,k in states)
    probability=[Q(k,total) for _,_,k in states]
    q=[sum((w for (x,y,_),w in zip(states,probability) if x[i]!=y[i]),Q(0))
       for i in range(n)]
    p=max(q)
    err=sum((w*abs(f[x]-f[y]) for (x,y,_),w in zip(states,probability)),Q(0))
    assert 0<=err<=1
    # QG with K_G <= 2: err <= p + 16 sqrt(p).
    assert max(Q(0),err-p)**2<=Q(256)*p
    return {
      "n":n, "seed":seed, "max_mismatch":str(p), "mean_absolute_difference":str(err),
      "linear_l1":str(anorm),"bilinear_cut_norm":str(bnorm),
      "exact_qg_with_KG_le_2":True,
      "pairs_independent":False,
    }


def one_hot_nontrivial(n: int=2048):
    # theta,theta' independent uniform, X=e_theta, Y=e_theta'
    # in sign representation. f(x)=(1+x_0*x_1)/2 is bounded degree two.
    # f(e_theta)=0 for theta in {0,1}, otherwise 1.
    p=Q(2*(n-1),n*n)  # any fixed input bit differs between theta/theta'
    err=Q(4*(n-2),n*n)
    assert n>=2048 and p< Q(1,256)
    # Check the nonvacuous bound with K_G=2 in exact rational arithmetic:
    # err <= p+16 sqrt(p), squared after clipping.
    assert max(Q(0),err-p)**2 <= Q(256)*p
    assert err< Q(1,100) and p < Q(1,1024)
    return {
      "n":n, "f":"(1+x_0*x_1)/2",
      "max_fixed_coordinate_mismatch":str(p),
      "mean_absolute_difference":str(err),
      "expected_max_pairwise_mismatch":str(Q(n-1,n)),
      "comparison":"correlated joint pair labels; expected max != max expected",
      "global_degree":2, "global_bound":"[0,1]",
    }


def audit():
    rows=[correlated_instance(n,seed) for n in (2,3,4,5) for seed in range(4)]
    obstruction=one_hot_nontrivial()
    return {
      "schema":"nightfall.fur.binary-q2.grothendieck.exact.v1",
      "status":"exact-finite-falsification-controls-pass",
      "author_side_only":True,
      "real_grothendieck_proved_here":False,
      "lean_certified":False,
      "full_FUR_all_alphabets":False,
      "random_correlated_couplings":len(rows),
      "instances":rows, "one_hot_nontrivial":obstruction,
    }


if __name__=="__main__":
    print(json.dumps(audit(),indent=2,sort_keys=True))

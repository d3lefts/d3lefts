#!/usr/bin/env python3
"""Exact finite-posterior q_i² ≤ 2 Var_theta(p_theta,i) information proxy.

By (external) Bernoulli Pinsker KL(p||mean_p) >= 2(p-mean_p)^2
in natural logarithm units, this implies q_i² <= I(theta;X_i).
This exact checker does NOT prove Pinsker or compute logarithms.
"""
from __future__ import annotations
from fractions import Fraction as Q
from random import Random
import json


def proxy(weights: tuple[Q,...], component_biases: tuple[tuple[Q,...],...]) -> dict:
    if not weights or any(w<0 for w in weights) or sum(weights)!=1:
        raise ValueError("weights must be a normalized nonnegative finite posterior")
    if len(weights)!=len(component_biases):
        raise ValueError("component count mismatch")
    n=len(component_biases[0])
    if any(len(row)!=n or any(not 0<=b<=1 for b in row) for row in component_biases):
        raise ValueError("bad binary component biases")
    coords=[]
    for i in range(n):
        m=sum((weights[t]*component_biases[t][i] for t in range(len(weights))),Q(0))
        variance=sum((weights[t]*(component_biases[t][i]-m)**2 for t in range(len(weights))),Q(0))
        mismatch=sum((weights[t]*weights[u]*abs(component_biases[t][i]-component_biases[u][i])
                     for t in range(len(weights)) for u in range(len(weights))),Q(0))
        squared_pair=sum((weights[t]*weights[u]*(component_biases[t][i]-component_biases[u][i])**2
                         for t in range(len(weights)) for u in range(len(weights))),Q(0))
        assert squared_pair==2*variance
        assert mismatch**2<=squared_pair
        coords.append({"coordinate":i,"mean_bias":str(m),"bias_variance":str(variance),
                       "shared_seed_mismatch":str(mismatch),
                       "exact_variance_pair_identity":str(squared_pair),
                       "mismatch_sq_bounded_by_twice_variance":True})
    return {
      "schema":"nightfall.fur.binary-information-proxy.exact.v1",
      "status":"exact-rational-variance-proxy-pass",
      "components":len(weights),"coordinates":n,
      "coords":coords,
      "external_dependency":"Bernoulli Pinsker I>=2 Var_bias in natural-log units; not proven by checker",
      "conclusion_if_Pinsker":"for every i: q_i^2 <= I(theta;X_i)",
    }


def audit():
    rng=Random(20261119)
    runs=[]
    for m in (2,3,8,16):
        for _ in range(6):
            a=[rng.randint(0,9) for k in range(m)]
            if not sum(a): a[0]=1
            weights=tuple(Q(z,sum(a)) for z in a)
            rows=tuple(tuple(Q(rng.randint(0,16),16) for i in range(5))
                       for j in range(m))
            runs.append(proxy(weights,rows))
    edge=proxy((Q(1,3),Q(2,3)),((Q(0),Q(1)),(Q(1),Q(0))))
    assert edge["coords"][0]["shared_seed_mismatch"]=="4/9"
    return {"schema":"nightfall.fur.binary-information-proxy-audit.v1",
            "status":"pass","random_posteriors":len(runs),
            "zero_atom_edge":edge,"all_exact":True,
            "new_math_certified":False,
            "pinsker_proved_here":False}


if __name__=="__main__":
    print(json.dumps(audit(),indent=2,sort_keys=True))

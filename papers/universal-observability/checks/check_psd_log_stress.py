#!/usr/bin/env python3
"""Finite falsifier for the PSD sign-mgf/log-inversion chain.

Uses integer Gram matrices and deterministic exhaustive sign ensembles. The
only inexact operations are exp/log tests; the mathematical proof is analytic.
"""
import json
import math
import random
from itertools import product

SEED=11112026
rng=random.Random(SEED)

def gram(vectors):
    return [[sum(x[k]*y[k] for k in range(len(x)))
             for y in vectors] for x in vectors]

def quad(A, sign):
    return sum(sign[i]*A[i][j]*sign[j]
               for i in range(len(A)) for j in range(len(A)))

def trace(A):
    return sum(A[i][i] for i in range(len(A)))

def experiment(trials=200):
    per_matrix=0; families=0; inversions=0;zero_sign=0;max_ratio=0.0
    for _ in range(trials):
        r=rng.randint(1,9)
        mats=[]
        for _ in range(rng.randint(1,8)):
            k=rng.randint(1,4)
            A=gram([[rng.randrange(-3,4) for __ in range(k)] for _ in range(r)])
            if trace(A)>0:mats.append(A)
        if not mats:continue
        signs=list(product((-1,1),repeat=r))
        for A in mats:
            s=trace(A)
            moment=sum(math.exp(quad(A,e)/(4*s)) for e in signs)/len(signs)
            assert moment<=math.sqrt(2)+1e-12,(r,s,moment)
            max_ratio=max(max_ratio,moment/math.sqrt(2))
            per_matrix+=1
        m=max(trace(A) for A in mats);p=sum(trace(A) for A in mats)
        L=min(max(quad(A,e) for A in mats) for e in signs)
        if L==0:
            zero_sign+=1
            continue
        assert L<=4*m*math.log(1+(math.sqrt(2)-1)*p/m)+1e-9
        families+=1
        assert m>=L/(8*math.log(1+4*p/L))-1e-9
        inversions+=1
    return {'status':'PASS', 'seed':SEED,'families':families,
            'families_with_zero_sign_floor':zero_sign,
            'integer_Gram_matrices':per_matrix,'log_inversions':inversions,
            'max_mgf_over_sqrt2':max_ratio,
            'scope':'Numerical stress of exact-formula analytic lemma; not an interval proof.'}

if __name__=='__main__':print(json.dumps(experiment(),sort_keys=True,indent=2))

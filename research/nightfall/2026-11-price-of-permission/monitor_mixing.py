#!/usr/bin/env python3
"""Exact minimal deep-monitor fraction when the cheap observation is uninformative.
This is a one-action calibrated model; not a claim for arbitrary AI monitors.
"""
from fractions import Fraction as F
from itertools import combinations

def information_floor(p,delta,eta,alpha):
    p,delta,eta,alpha=map(F,(p,delta,eta,alpha))
    assert 0<p<1 and 0<=delta<1 and 0<=eta<=1 and 0<=alpha<=1
    k=delta*(1-p)/(p*(1-delta))
    a=min(alpha,eta,k*alpha)
    v=alpha-a
    assert 0<=a<=eta and a+v==alpha
    assert (p-delta)*a<=delta*(1-p)*v
    return {'direct_commit':a, 'deep_inspect':v,'deny':1-alpha, 'ratio_k':k}

def independent_vertex_oracle(p,delta,eta,alpha):
    p,delta,eta,alpha=map(F,(p,delta,eta,alpha))
    # ax + by <= c for all feasible a=skip-to-commit, v=deep-check.
    H=[(-1,0,0),(0,-1,0),(1,1,1),(1,0,eta),
       (-1,-1,-alpha),(p-delta,-delta*(1-p),0)]
    candidates=[]
    for i,j in combinations(range(len(H)),2):
        a1,b1,c1=H[i];a2,b2,c2=H[j]
        det=a1*b2-a2*b1
        if det==0:continue
        x=(c1*b2-c2*b1)/det
        y=(a1*c2-a2*c1)/det
        if all(a*x+b*y<=c for a,b,c in H):candidates.append((y,x))
    assert candidates
    min_v,a=min(candidates)
    return a,min_v

if __name__=='__main__':
    from hashlib import sha256
    digest=sha256();cases=0
    for p in [F(1,10), F(1,5), F(1,3), F(1,2), F(3,4)]:
        for d in [F(0),F(1,20),F(1,10),F(1,4),F(1,2)]:
            for eta in [F(0),F(1,20),F(1,5),F(1,2),F(1)]:
                for alpha in [F(1,4),F(1,2),F(3,4),F(1)]:
                    v=information_floor(p,d,eta,alpha)['deep_inspect']
                    a_or,v_or=independent_vertex_oracle(p,d,eta,alpha)
                    assert v==v_or,(p,d,eta,alpha,v,v_or)
                    digest.update(f'{p}|{d}|{eta}|{alpha}|{v}\n'.encode());cases+=1
    print('independent exact LP vertex comparisons',cases,'sha256',digest.hexdigest())
    case=information_floor(F(1,5), F(1,20), F(1,20), F(3,4))
    print('example p=1/5, delta=1/20, eta=1/20, alpha=3/4:',{k:str(v) for k,v in case.items()})

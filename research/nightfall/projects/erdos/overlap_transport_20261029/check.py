#!/usr/bin/env python3
"""Erdos #36 continuum-specification and finite-grid transfer guardrails.
Exact Fraction arithmetic; stdlib only. R1 internal tests, NOT a lower-bound claim.
"""
from fractions import Fraction as Q
from random import Random
import json

def intervals(values):
    n=len(values)
    h=Q(2,n)
    return [(i*h,(i+1)*h,Q(v)) for i,v in enumerate(values)]

def R(values,t):
    """CORRECT f*g correlation: g=(1-f) on [0,2], ZERO outside."""
    a=intervals(values)
    return sum((max(Q(0),min(b,d-t)-max(x,c-t))*p*(1-q)
                for x,b,p in a for c,d,q in a),Q(0))

def wrong_R(values,t):
    """INCORRECT 1-(zero extension of f), used only as a negative control."""
    a=intervals(values)
    mass=sum(((b-x)*p for x,b,p in a),Q(0))
    corr=sum((max(Q(0),min(b,d-t)-max(x,c-t))*p*q
              for x,b,p in a for c,d,q in a),Q(0))
    return mass-corr

def S(values):
    n=len(values);h=Q(2,n)
    # Correlation of aligned step profiles is piecewise affine between kh events.
    return max((R(values,k*h) for k in range(-n,n+1)))

def l1(f,g):
    assert len(f)==len(g)
    return Q(2,len(f))*sum((abs(Q(x)-Q(y)) for x,y in zip(f,g)),Q(0))

def variation(f):
    return Q(f[0])+sum((abs(Q(a)-Q(b)) for a,b in zip(f,f[1:])),Q(0))+Q(f[-1])

def coarse(f,m):
    assert len(f)%m==0
    return [sum((Q(x) for x in f[i:i+m]),Q(0))/m
            for i in range(0,len(f),m)]

def run():
    fixed=[]
    for n in (1,2,3,4,8,16):
        f=[Q(x) for _ in range(n) for x in (1,0)]
        g=coarse(f,2);t=Q(1,n)
        assert all(v==Q(1,2) for v in g)
        assert S(f)==1 and S(g)==Q(1,2)
        assert l1(f,[Q(1,2)]*(2*n))==1
        assert R(f,t)==1 and R(f,-t)==1-Q(1,n)
        assert R(f,0)==0
        assert R(f,t)+R(f,-t)-2*R(f,0)==2-Q(1,n)
        assert 2*R(g,t)-2*R(g,0)==-Q(1,2*n)
        assert R(f,2)==0 and wrong_R(f,2)==1
        fixed.append({"N":n,"S_f":"1","S_cell_average":"1/2",
          "two_lag_of_f":str(2-Q(1,n)),
          "two_lag_of_average":str(-Q(1,2*n))})
    rng=Random(20261029);tested=0
    for n in (2,3,5,8):
        for j in range(40):
            a=[Q(rng.randrange(21),20) for _ in range(n)]
            f=[z for x in a for z in (x,1-x)]
            g=coarse(f,2)
            delta=l1(f,[Q(1,2)]*(2*n))
            assert abs(S(f)-S(g))<=2*delta
            assert delta<=Q(2,n)*variation(f)/2
            assert sum(f,Q(0))*Q(1,n)==1
            tested+=1
    assert R([Q(1,2),Q(1,2)],Q(0))==Q(1,2)
    assert R([Q(1,2),Q(1,2)],Q(2))==0
    assert wrong_R([Q(1,2),Q(1,2)],Q(2))==1
    print(json.dumps({"fixed_grid_adversaries":fixed,
        "independent_random_rational_BV_checks":tested,
        "invalid_outside_complement_rejected":True,"result":"PASS"},indent=2))
if __name__=="__main__":run()

#!/usr/bin/env python3
"""Independent exact-fraction falsifier for weak-cross-factor approximation.
No third-party packages; finite checks are not a universal proof.
"""
from fractions import Fraction as F
from itertools import product, combinations
import json
from hashlib import sha256

N_ASSERT = 0

def checked(value, description):
    global N_ASSERT
    N_ASSERT += 1
    if not value:
        raise AssertionError(description)

def strings(n):
    return list(product((-1, 1), repeat=n))

def normalize(tab):
    s=sum(tab.values(), F(0))
    return {x:v/s for x,v in tab.items()}

def source(n,z,t,eps):
    nu={x: product_weight(x,z,t) for x in strings(n)}
    mu=normalize({x: p * edge_weight(x,eps) for x,p in nu.items()})
    return nu,mu

def product_weight(x,z,t):
    out=F(1)
    for v in x: out*=(1+t*z*v)/2
    return out

def edge_weight(x,eps):
    out=F(1)
    for i in range(len(x)-1):out*=1+eps*x[i]*x[i+1]
    return out

def f(x):
    m=len(x)//2
    return F(sum(x[2*j]*x[2*j+1] for j in range(m)),m)

def predictor(x,T,z,t):
    # Conditional expectation under the reference independent-leaf law.
    out=F(0)
    for j in range(len(x)//2):
        a,b=2*j,2*j+1
        va=x[a] if a in T else z*t
        vb=x[b] if b in T else z*t
        out+=va*vb
    return out/(len(x)//2)

def risk(law,T,z,t):
    return sum((p*(f(x)-predictor(x,T,z,t))**2 for x,p in law.items()),F(0))

def total_variation(mu,nu):
    return sum((abs(mu[x]-nu[x]) for x in nu),F(0))/2

def run():
    runs=[]
    for m in (1,2,3):
        n=2*m
        for t in (F(1,4),F(2,3)):
            for eps in (F(1,100),F(1,20),F(1,4)):
                R=((1+eps)/(1-eps))**(n-1)
                for z in (-1,1):
                    nu,mu=source(n,z,t,eps)
                    checked(sum(nu.values())==1,'nu normalized')
                    checked(sum(mu.values())==1,'mu normalized')
                    checked(all(p>0 for p in mu.values()),'strictly positive source')
                    tv=total_variation(mu,nu)
                    # Optimal oscillation inequality (no floating roots): TV<=(sqrt(R)-1)/(sqrt(R)+1)
                    checked(((1+tv)/(1-tv))**2<=R,'sharp ratio-TV certificate')
                    checked(tv<1,'TV below one')
                    for cardinality in range(n+1):
                        for subset in combinations(range(n),cardinality):
                            T=frozenset(subset)
                            rn=risk(nu,T,z,t)
                            rm=risk(mu,T,z,t)
                            checked(abs(rm-rn)<=4*tv,'bounded-loss TV stability')
                            # Reference lower bound: all pairs with no read leaf stay unpredictable.
                            untouched=sum(1 for j in range(m) if (2*j not in T and 2*j+1 not in T))
                            v=1-t**4
                            checked(rn>=F(untouched,m*m)*v,'unobserved pair lower bound')
                            # Tight reference risk if all pairs either complete or untouched
                            if all((2*j in T)==(2*j+1 in T) for j in range(m)):
                                checked(rn==F(untouched,m*m)*v,'pair-completion exact risk')
                    runs.append({'m':m,'z':z,'t':str(t),'eps':str(eps),
                                 'tv':str(tv),'R':str(R),'subsets':2**n})
    # Sharp ratio-bound endpoint example: choose two levels of rational L so mean is geometric mean.
    # R=9, nu weights (3/4,1/4), L=(1,9) yield E L=3, TV=1/2 = (sqrt(9)-1)/(sqrt(9)+1).
    nu={'lo':F(3,4),'hi':F(1,4)}
    mu=normalize({'lo':F(3,4),'hi':F(9,4)})
    tv=total_variation(mu,nu)
    checked(tv==F(1,2),'sharpness of likelihood-ratio TV bound')
    output={'status':'PASS','checks':N_ASSERT,'models':len(runs),'max_m':3,
            'sharp_ratio_example_TV':str(tv),'first':runs[:2],'last':runs[-2:],
            'scope':'finite exact rational falsification; theorem proof separate'}
    print(json.dumps(output,indent=2))
if __name__=='__main__':run()

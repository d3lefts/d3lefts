#!/usr/bin/env python3
"""Exact Fourier-vs-direct signed-sum obstruction for GF(3)^2 and GF(3)^3.
Sharp max bucket >=14 for seven GF9 coefficients is proved in the note.
"""
from itertools import product
from collections import Counter
from math import comb

def add(u,v):return tuple((x+y)%3 for x,y in zip(u,v,strict=True))
def neg(u):return tuple(-x%3 for x in u)
def dot(u,v):return sum(x*y for x,y in zip(u,v,strict=True))%3
def norm(u):return min(u,neg(u))
def lines(r):return tuple(sorted({norm(x) for x in product(range(3),repeat=r) if any(x)}))

def direct(vs):
    r=len(vs[0]);Z=(0,)*r
    counts=Counter()
    for signs in product((1,2),repeat=len(vs)):
        x=Z
        for sign,c in zip(signs,vs,strict=True):
            x=add(x,c if sign==1 else neg(c))
        counts[norm(x)]+=1
    labels=(Z,)+lines(r)
    assert all(counts[z]%2==0 for z in labels)
    return tuple(counts[z]//2 for z in labels)

def fourier(vs):
    r=len(vs[0]);q=3**r;n=len(vs);Z=(0,)*r
    lambdas={}
    for w in lines(r):
        e=sum(dot(w,c)==0 for c in vs)
        lambdas[w]=(-1)**(n-e)*2**e
    buckets=[]
    for x in (Z,)+lines(r):
        numerator=2**n+sum(
            a*(2 if dot(w,x)==0 else -1)
            for w,a in lambdas.items())
        assert numerator%q==0
        size=numerator//q
        if x==Z:assert size%2==0;size//=2
        buckets.append(size)
    assert sum(buckets)==2**(n-1)
    return tuple(buckets)

def audit():
    reps=lines(2);Z=(0,0)
    checked=0;minimum=65;attainers=0
    for z in range(8):
        for a in range(8-z):
            for b in range(8-z-a):
                for c in range(8-z-a-b):
                    d=7-z-a-b-c
                    vs=[Z]*z+sum(([v]*n for v,n in zip(reps,(a,b,c,d),strict=True)),[])
                    bd=direct(vs);bf=fourier(vs)
                    assert bd==bf,(z,a,b,c,d,bd,bf)
                    m=max(bd)
                    if m<minimum:minimum=m;attainers=1
                    elif m==minimum:attainers+=1
                    checked+=1
    assert (checked,minimum,attainers)==(comb(11,4),14,4)
    # The symbolic proof eliminates all hypothetical 13/13/13/13/12 tables.
    eigen=[(-1)**(7-e)*2**e for e in range(8)]
    close={(i,j) for i in range(8) for j in range(i+1,8)
           if abs(eigen[i]-eigen[j])<=3}
    assert close=={(0,1),(0,2)}
    equal=[(z,e) for z in range(8) for e in range(z,8) if 4*e-3*z==7]
    assert equal==[(3,4),(7,7)]
    for z,e in equal:
        v=[Z]*z+sum(([u]*(e-z) for u in reps),[])
        assert fourier(v)[0] in (0,64)
    # Sharp case: zero + three pairs of independent projective directions.
    v=[Z]+[reps[0]]*2+[reps[1]]*2+[reps[2]]*2
    assert sorted(fourier(v),reverse=True)==[14,14,14,12,10]
    reps3=lines(3);Z3=(0,0,0)
    for i in range(37):
        v=[Z3 if (j+3*i)%11==0 else reps3[(5*j+7*i+j*i)%len(reps3)]
           for j in range(7)]
        assert direct(v)==fourier(v)
    print('PASS: 330 GF9 occupancy types, sharp 14-bound, 37 GF27 controls')
    print('SYMBOLIC: only eigenvalue-gap pairs (0,1),(0,2); both violate n=7')

if __name__=='__main__':audit()

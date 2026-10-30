#!/usr/bin/env python3
"""Independently reproduce the diamond four-tile phase construction.

Theorem target: D=2^d,d>=2, v=(D,D/2), w=(D,-D/2),
G=(Z/pZ)^2, p>=3D; T=[0,D-1]^2 + {0,v,w,v+w}.
Hole m=(max(4D-p-1,0),5D/2-1) is outside T+T.
For prime p, the 2d+2 binary generators give 4D^2 distinct
actual squared F_(p^2) observations.

Uses exact integer rectangle generation PLUS direct GFp^2 squaring.
Compares independent duplicate-pair enumeration for small tests;
the universal lemma is proved in DIAMOND_THEOREM.md, not by CI.
"""
from itertools import product
from math import isqrt


def prime(n):
    return n>=2 and all(n%k for k in range(2,isqrt(n)+1))


def geometry(D,p):
    assert D>=4 and D&(D-1)==0 and p>=3*D
    h=D//2
    v=(D,h)
    w=(D,-h)
    B=range(D)
    I=range(2*D-1)
    tiles=[
        {((i+(a+b)*D)%p,(j+(a-b)*h)%p)
         for i,j in product(B,repeat=2)}
        for a,b in product((0,1),repeat=2)
    ]
    T=set().union(*tiles)
    assert len(T)==4*D*D and all(len(t)==D*D for t in tiles)
    sums={
        ((i+(a+b)*D)%p,(j+(a-b)*h)%p)
        for a,b in product((0,1,2),repeat=2)
        for i,j in product(I,repeat=2)
    }
    hole=(max(4*D-p-1,0),5*D//2-1)
    assert hole not in sums,(D,p,hole)
    return T,sums,hole


def direct_pairs(T,p):
    s=set()
    vals=sorted(T)
    for i,(x,y) in enumerate(vals):
        for a,b in vals[i:]:
            s.add(((x+a)%p,(y+b)%p))
    return s


def squared_outputs(D,p,hole):
    assert prime(p)
    T,_,_=geometry(D,p)
    c=(-hole[0]*pow(2,-1,p)%p,-hole[1]*pow(2,-1,p)%p)
    delta=next(z for z in range(2,p)
               if pow(z,(p-1)//2,p)==p-1)
    table={}
    for a,b in T:
        x=(a+c[0])%p
        y=(b+c[1])%p
        powered=((x*x+delta*y*y)%p,(2*x*y)%p)
        assert powered not in table,(D,p,table[powered],(a,b))
        table[powered]=(a,b)
    assert len(table)==4*D*D
    return delta,len(table)


def run(D,p,brute=False):
    T,S,hole=geometry(D,p)
    if brute:
        assert direct_pairs(T,p)==S
    if prime(p):
        delta,n=squared_outputs(D,p,hole)
        d=D.bit_length()-1
        b=2*d+2
        assert n==1<<b
        # Exact maximal single-observation phase capacity in the
        # interval, without a false claim about p beyond that interval.
        if p<=4*D-1:
            L=(p*p+1)//2
            assert (1<<b)<=L<(1<<(b+1))
            # Tessera's prior product signed-digit lower bound.
            baseline=max(2*((p+1)//2).bit_length()-2,
                         ((p-1)//2).bit_length()-1+p.bit_length()-1)
            assert baseline==b-(p<4*D-1),(D,p,baseline,b)
        return {"D":D,"p":p,"hole":hole,"binary_cube":len(T),
                "field_nonsquare":delta,"powered_outputs":n,
                "capacity_optimal":p<=4*D-1}
    return {"D":D,"modulus":p,"hole":hole,"binary_cube":len(T),
            "field_interpretation":"none, composite modulus"}


if __name__=="__main__":
    for D in (4,8,16,32,64):
        # Exact integer transition at 3D; below this disjointness
        # can fail, and therefore the theorem asserts no code.
        for p in (3*D,3*D+1,3*D+2):
            print("EDGE",run(D,p,brute=D<=8))
    for D,ps in (
        (4,(13,17,19)),
        (8,(29,31,37)),
        (16,(53,59,61)),
        (32,(97,101,103,107,109,113,127)),
        (64,(193,197,199,211,223,251)),
        (128,(389,))):
        for p in ps:
            if prime(p):
                print("PRIME",run(D,p,brute=D<=8))
    print("PASS diamond theorem: exact field-square one-query capacity on a positive-width prime interval")

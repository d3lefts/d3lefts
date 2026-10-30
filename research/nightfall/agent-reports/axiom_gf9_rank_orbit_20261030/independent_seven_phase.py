#!/usr/bin/env python3
"""Independent full 5^7 phase-row enumeration, not the 38-type method.

Field GF9=GF3[v]/(v²+v+2), v²=2v+1. Compute exact +/- sum
distributions for every representative of seven GF9 coefficient classes
modulo coordinatewise sign flips. Verify best bucket 14 and count 2520.
"""
from collections import Counter
from itertools import product

REPS=(0,1,3,4,5)


def add(a,b):
    return (a%3+b%3)%3+3*((a//3+b//3)%3)


def neg(a):
    return (-a%3)+3*((-(a//3))%3)


def square(a):
    x,y=a%3,a//3
    # v² = 2v+1
    return (x*x+y*y)%3+3*((2*x*y+2*y*y)%3)


def audit():
    assert {square(a) for a in range(9)}=={0,1,2,5,7}
    assert {frozenset((x,neg(x))) for x in range(1,9)} == {
        frozenset((1,2)),frozenset((3,6)),
        frozenset((4,8)),frozenset((5,7))}
    assert len(REPS)==5
    best=65
    minima=0
    example=None
    n=0
    outcomes=tuple(sorted({square(a) for a in range(9)}))
    for coeffs in product(REPS,repeat=7):
        # Sum of all 128 independent signed choices.
        dist=[0]*9
        dist[0]=1
        for c in coeffs:
            nxt=[0]*9
            mc=neg(c)
            for z,value in enumerate(dist):
                if value:
                    nxt[add(z,c)]+=value
                    nxt[add(z,mc)]+=value
            dist=nxt
        buckets={out:0 for out in outcomes}
        for z,value in enumerate(dist):
            buckets[square(z)]+=value
        assert all(v%2==0 for v in buckets.values())
        assert sum(buckets.values())==128
        maximum=max(buckets.values())//2
        if maximum<best:
            best=maximum
            minima=1
            example=(coeffs,tuple(sorted((v//2 for v in buckets.values()),reverse=True)))
        elif maximum==best:
            minima+=1
        n+=1
    assert n==5**7==78125
    assert best==14
    assert minima==2520
    assert example[1]==(14,14,14,12,10)
    return {"ambient_field":"F3[v]/(v²+v+2)",
            "exhaustive_rows":n,
            "minimum_worst_phase_bucket":best,
            "attaining_rows":minima,
            "first_attainer":example[0],
            "bucket_sizes":example[1],
            "status":"EXACT_INTERNAL_INDEPENDENT_78125_ROW_REPLAY"}

if __name__=="__main__":
    print("PASS",audit())

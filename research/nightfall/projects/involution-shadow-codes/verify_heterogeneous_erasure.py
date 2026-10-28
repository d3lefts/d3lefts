#!/usr/bin/env python3
"""Exact deterministic regression gate: unequal-rate shadow codes; stdlib only.
See HETEROGENEOUS_ERASURE_COMPLEXITY.md for universal proof and NP reduction.
"""
from collections import Counter
from fractions import Fraction as F
from itertools import product
from math import comb
from random import Random

def formula(a, labels, q):
    assert len(a)==len(labels) and q>=2 and all(x>0 for x in a)
    loads=[sum(w for w,c in zip(a,labels) if c==k) for k in range(q)]
    return F(sum(1<<s for s in loads)-q+1,1<<sum(a))

def direct(a,labels,q):
    n=2*q
    words=[tuple(tuple(sorted(((x+t)%n,(-x-t)%n))) for t in labels)
           for x in range(n)]
    numerator=0
    for mask in range(1<<len(a)):
        projected={tuple(row[j] for j in range(len(a)) if mask>>j&1)
                   for row in words}
        if len(projected)<n:
            weight=1
            for j,w in enumerate(a):
                if mask>>j&1: weight*=((1<<w)-1)
            numerator+=weight
    return F(numerator,1<<sum(a))

def exhaustive(a,q):
    return min((formula(a,lab,q),lab) for lab in product(range(q),repeat=len(a)))

def pareto_dp(a):
    W=sum(a);m=len(a)
    states={(0,0)}
    for w in a:
        states |= {(k+1,s+w) for k,s in states}
    front={}
    for k,s in states:
        d=min(k,m-k)
        v=F((1<<s)+(1<<(W-s))-1,1<<W)
        front[d]=min(front.get(d,v),v)
    return front

def verify():
    weights=[3,1,1,1]
    a=formula(weights,[0,0,1,1],2)
    b=formula(weights,[0,1,1,1],2)
    assert a==direct(weights,[0,0,1,1],2)==F(19,64)
    assert b==direct(weights,[0,1,1,1],2)==F(15,64)
    assert exhaustive(weights,2)[0]==b
    yes=[5,6,7,5,6,7]; no=[5,5,5,7,7,7]
    bound=F(2*(1<<18)-1,1<<36)
    assert exhaustive(yes,2)[0]==bound
    assert exhaustive(no,2)[0]>bound
    rng=Random(20261028)
    direct_tests=0; pareto_tests=0
    for q in [2,3,4]:
        for m in range(1,8):
            for _ in range(12):
                a=[rng.randint(1,5) for j in range(m)]
                c=[rng.randrange(q) for j in range(m)]
                assert direct(a,c,q)==formula(a,c,q)
                direct_tests+=1
    for m in range(2,10):
        for _ in range(15):
            a=[rng.randint(1,8) for j in range(m)]
            brute={}
            for labels in product(range(2),repeat=m):
                d=min(labels.count(0),labels.count(1))
                cost=formula(a,labels,2)
                brute[d]=min(brute.get(d,cost),cost)
            assert pareto_dp(a)==brute
            pareto_tests+=1
    print(f"PASS | {direct_tests} independent group-orbit trials | "
          f"{pareto_tests} exact Pareto fronts | 2 complete 3-PARTITION fixtures")

if __name__=="__main__":
    verify()

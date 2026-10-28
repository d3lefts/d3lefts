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

def exchangeable_failure(labels,q,mass):
    m=len(labels)
    assert sum(mass)==1 and len(mass)==m+1
    ans=mass[0]
    for r in range(1,m+1):
        ans+=mass[r]*F(sum(comb(labels.count(c),r) for c in range(q)
                           if labels.count(c)>=r),comb(m,r))
    return ans

def check_correlated():
    m,q=6,3
    mass=tuple(F(x,20) for x in [1,2,5,3,5,2,2])
    labels=(0,0,1,1,2,2)
    expected=F(1,5)
    assert exchangeable_failure(labels,q,mass)==expected
    n=2*q
    code=[tuple(tuple(sorted(((x+t)%n,(-x-t)%n))) for t in labels)
          for x in range(n)]
    direct_cost=F(0)
    for mask in range(1<<m):
        positions=[j for j in range(m) if mask>>j&1]
        if len({tuple(w[j] for j in positions) for w in code})<n:
            direct_cost+=mass[len(positions)]/comb(m,len(positions))
    assert direct_cost==expected
    ties=0
    for t in product(range(q),repeat=m):
        score=exchangeable_failure(t,q,mass)
        assert score>=expected
        ties+=score==expected
    assert ties==90
    return 729

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
    exchangeable_checks=check_correlated()\n    rng=Random(20261028)
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
          f"{pareto_tests} exact Pareto fronts | {exchangeable_checks} correlated-erasure allocations | 2 complete 3-PARTITION fixtures")

if __name__=="__main__":
    verify()

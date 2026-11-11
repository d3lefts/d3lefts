#!/usr/bin/env python3
"""Independent exact-rational falsification audit for fourth moments of
finite independent centered Hilbert-valued categorical increments.

Checks the analytic covariance-trace formula against direct tensor-product
enumeration (up to four increments), as well as the dimension-free inequality.
Not a proof of universally quantified claims.
"""
from fractions import Fraction as Q
from itertools import product
from random import Random

def dot(u, v):
    return sum((x*y for x,y in zip(u,v)),Q(0))

def moments(law):
    dim=len(law[0][1])
    v=sum((p*dot(x,x) for p,x in law),Q(0))
    v4=sum((p*dot(x,x)**2 for p,x in law),Q(0))
    cov=[[sum((p*x[a]*x[b] for p,x in law),Q(0))
          for b in range(dim)] for a in range(dim)]
    return v,v4,cov

def random_law(rng,dim):
    atoms=rng.randint(2,4)
    weights=[rng.choice([1,1,1,2,3,11,257,65537]) for _ in range(atoms)]
    total=sum(weights)
    probs=[Q(w,total) for w in weights]
    vals=[tuple(Q(rng.randint(-3,3)) for _ in range(dim)) for _ in range(atoms)]
    mu=tuple(sum((p*x[k] for p,x in zip(probs,vals)),Q(0)) for k in range(dim))
    return [(p,tuple(x[k]-mu[k] for k in range(dim))) for p,x in zip(probs,vals)]

def test(laws,brute=True):
    dim=len(laws[0][0][1])
    for law in laws:
        assert sum((p for p,_ in law),Q(0))==1
        for k in range(dim):
            assert sum((p*x[k] for p,x in law),Q(0))==0
    ms=[moments(law) for law in laws]
    v=sum((a for a,_,_ in ms),Q(0))
    v4=sum((a for _,a,_ in ms),Q(0))
    for i in range(len(ms)):
        for j in range(i+1,len(ms)):
            vi,_,ci=ms[i];vj,_,cj=ms[j]
            tr=sum((ci[a][b]*cj[a][b] for a in range(dim) for b in range(dim)),Q(0))
            v4+=2*vi*vj+4*tr
            assert tr<=vi*vj
    assert v4<=sum((e4 for _,e4,_ in ms),Q(0))+3*v*v
    c2=max((dot(x,x) for law in laws for _,x in law),default=Q(0))
    assert all(e4<=c2*vi for vi,e4,_ in ms)
    assert v4<=c2*v+3*v*v
    if brute:
        direct=Q(0)
        for event in product(*laws):
            weight=Q(1);total=[Q(0)]*dim
            for p,x in event:
                weight*=p
                for k in range(dim):total[k]+=x[k]
            direct+=weight*dot(total,total)**2
        assert direct==v4,(direct,v4)
    return v,v4,c2

def main():
    rng=Random(20261111)
    checked=0
    for n in range(1,7):
        for dim in range(1,6):
            for _ in range(35):
                test([random_law(rng,dim) for _ in range(n)],brute=n<=4)
                checked+=1
    print("PASS",checked,"exact rational arbitrary-law Hilbert increment cases")
    print("covariance fourth-moment formula, dimension-free bound; direct products n<=4")

if __name__=="__main__":
    main()

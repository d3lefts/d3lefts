#!/usr/bin/env python3
"""Independent full-state rational audit of the small-component variance bound.
Exact examples; not a universal proof or Lean certificate.
"""
from fractions import Fraction as F
from itertools import product
from random import Random


def check(seed, n, blocks):
    rng=Random(seed)
    ps=[rng.choice([F(0),F(1,10),F(1,4),F(1,2),F(2,3),F(9,10),F(1)]) for _ in range(n)]
    states=list(product((0,1),repeat=n))
    vals={}
    gs=[]
    for block in blocks:
        gs.append({bits:rng.randrange(-9,10) for bits in product((0,1),repeat=len(block))})
    for x in states:
        vals[x]=sum(g[tuple(x[i] for i in block)] for block,g in zip(blocks,gs))
    def weight(x):
        w=F(1)
        for i,a in enumerate(x):w*=ps[i] if a else 1-ps[i]
        return w
    w={x:weight(x) for x in states}
    assert sum(w.values())==1
    mean=sum((w[x]*vals[x] for x in states),F(0))
    V=sum((w[x]*(vals[x]-mean)**2 for x in states),F(0))
    support=[vals[x] for x in states if w[x]]
    B=F(max(support)-min(support),2)
    inf=[]
    for i in range(n):
        I=F(0)
        for other in product((0,1),repeat=n-1):
            x0=other[:i]+(0,)+other[i:];x1=other[:i]+(1,)+other[i:]
            wo=weight(x0)+weight(x1)
            I+=wo*ps[i]*(1-ps[i])*(vals[x1]-vals[x0])**2
        inf.append(I)
    M=max(inf)
    r=max(map(len,blocks))
    assert V*V<=r*B*B*M,(seed,n,blocks,V,B,M)
    return V,B,M


def main():
    ntest=0
    for n in range(1,7):
        for split in range(1,n+1):
            blocks=[tuple(range(0,split))]
            if split<n:blocks.append(tuple(range(split,n)))
            for rep in range(10):
                check(1701+n*131+split*7+rep,n,blocks)
                ntest+=1
    print('PASS exact independent full-state check of',ntest,'nonuniform/degenerate product instances')
    print('Scope: finite examples and coordinate resampling only; classical analytic proof in note')


if __name__=='__main__':main()

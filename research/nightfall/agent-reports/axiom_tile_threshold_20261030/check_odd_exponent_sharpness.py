#!/usr/bin/env python3
"""Independent maximal centrally symmetric sign-separated witnesses in odd cyclic products."""
from itertools import product
from math import lcm

def verify(mods):
    G=list(product(*(range(m) for m in mods)))
    t=(1,)*len(mods)
    z=(0,)*len(mods)
    e=lcm(*mods)
    h=(e-1)//2
    add=lambda a,b:tuple((x+y)%m for x,y,m in zip(a,b,mods))
    neg=lambda a:tuple((-x)%m for x,m in zip(a,mods))
    mul=lambda k,a:tuple((k*x)%m for x,m in zip(a,mods))
    H={mul(k,t) for k in range(e)}
    assert len(H)==e
    remaining=set(G)
    cosets=[]
    while remaining:
        r=min(remaining)
        C=frozenset(add(r,v) for v in H)
        assert len(C)==e
        remaining-=C
        cosets.append((r,C))
    reps={C:r for r,C in cosets}
    A=set()
    done=set()
    for r,C in cosets:
        if C in done:continue
        neg_C=frozenset(neg(v) for v in C)
        assert neg_C in reps
        if C==neg_C:
            assert C==frozenset(H)
            if h%2:
                indices=list(range(-h,h+1,2))
            else:
                indices=[0]+[j*s for j in range(2,h+1,2) for s in (-1,1)]
            assert len(indices)==h+1
            A.update(mul(j,t) for j in indices)
            done.add(C)
        else:
            X={add(r,mul(j,t)) for j in range(0,e-1,2)}
            assert len(X)==h
            A.update(X)
            A.update(neg(x) for x in X)
            done.update((C,neg_C))
    n=len(G)*(e-1)//(2*e)+1
    assert len(A)==n
    assert all(neg(x) in A for x in A)
    assert len(A.intersection(add(x,t) for x in A))==1
    c=mul(-pow(2,-1,e),t)
    D={add(x,c) for x in A}
    assert D.intersection(neg(x) for x in D)=={z}
    print('PASS',mods,'exponent',e,'sharp size',len(D))

for mods in ((3,),(5,),(7,),(9,),(15,),(3,3),(5,5),(9,3),(9,5),
             (3,3,3),(9,3,5),(3,3,5),(23,23)):
    verify(mods)

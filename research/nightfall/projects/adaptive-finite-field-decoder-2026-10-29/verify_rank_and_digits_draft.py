#!/usr/bin/env python3
"""Scoped, independent finite audit of phase packing. Stdlib only.

Representation: F_p^r coordinates. Equality of squares in a field of odd
characteristic is exactly equality of vectors modulo simultaneous +/-.
No dependency on existing NIGHTFALL finite-field programs.
"""
from itertools import product
from random import Random

def orbit(v,p):
    a=tuple(z%p for z in v)
    b=tuple(-z%p for z in v)
    return min(a,b)

def injective(p,r,anchor,coeffs,partial=None):
    n=len(coeffs) if partial is None else partial
    seen=set()
    for sign in product((1,-1),repeat=n):
        padded=sign+(1,)*(len(coeffs)-n)
        z=tuple((anchor[i]+sum(s*c[i] for s,c in zip(padded,coeffs)))%p
                for i in range(r))
        o=orbit(z,p)
        if o in seen:
            return False
        seen.add(o)
    return len(seen)==2**n

def uniform(p,r):
    d=p.bit_length()-1
    anchor=(2**(d-1),)+(0,)*(r-1)
    weights=[]
    for i in range(r):
        for j in range(d-1 if i==0 else d):
            weights.append(tuple(2**j if t==i else 0 for t in range(r)))
    return anchor,weights

def mersenne(p,r):
    d=(p+1).bit_length()-2
    assert p==2**(d+1)-1
    anchor=(2**d-1,)*r
    weights=[tuple(2**j if t==i else 0 for t in range(r))
             for i in range(r) for j in range(d)]
    return anchor,weights

def unpowered_q3_pair_exists(rows,offset):
    seen={}
    for signs in product((1,-1),repeat=len(rows[0])):
        v=tuple((offset[i]+sum(a*b for a,b in zip(row,signs)))%3
                for i,row in enumerate(rows))
        if v in seen:
            return seen[v]!=signs
        seen[v]=signs
    return False

def run():
    # All 3^(2*3) coefficient matrices have indistinguishable sign pairs:
    for z in product(range(3),repeat=6):
        assert unpowered_q3_pair_exists([z[:3],z[3:]],(1,2))
    rng=Random(20261029)
    for _ in range(1000):
        rows=[[rng.randrange(3) for _ in range(5)] for _ in range(4)]
        off=[rng.randrange(3) for _ in range(4)]
        assert unpowered_q3_pair_exists(rows,off)

    cases=[(5,2,(2,0),[(1,0),(0,1),(0,2)]),
           (7,2,(3,3),[(1,0),(0,1),(0,2),(2,0)])]
    for p,r,a,w in cases:
        for n in range(len(w)+1):
            assert injective(p,r,a,w,n), (p,r,n)
    for p in (5,7,11,13,17,19,23,29,31):
        for r in (2,3,4):
            a,w=uniform(p,r)
            assert injective(p,r,a,w), (p,r)
    for p in (7,31):
        for r in (2,3):
            a,w=mersenne(p,r)
            assert injective(p,r,a,w), (p,r)
    assert not injective(5,2,(2,0),[(1,0),(0,1),(0,2),(0,2)])
    assert (5*5+1)//2 < 2**4 and (7*7+1)//2 < 2**5
    print("PASS: 729 exhaustive q3 matrices, 1000 seeded q3 matrices,")
    print("27 uniform square-digit models, 4 Mersenne models,")
    print("all small-case partial blocks and three negative controls")
if __name__=="__main__":
    run()

#!/usr/bin/env python3
"""Independent direct k-subset XOR enumeration for fixed rank-two nonrow target.

Tests depths 2,3,4. No pair-convolution identities, no author imports.
This is finite exact evidence, not a proof for all tensor depths.
"""
from itertools import combinations,product

def tensor_mask(factors):
    positions=[0]
    for factor in factors:
        choices=(0,1) if factor==3 else (factor-1,)
        positions=[2*i+b for i in positions for b in choices]
    return sum(1<<i for i in positions)

def check(L):
    rows=[tensor_mask(t) for t in product((1,2,3),repeat=L)]
    z=tensor_mask((1,)*L)^tensor_mask((2,2)+(1,)*(L-2))
    assert z not in rows
    expected={2:(3,7,6),3:(3,13,60),4:(3,19,144)}[L]
    counts=[]
    for k in (2,3,4):
        total=0
        for s in combinations(rows,k):
            x=0
            for value in s:x^=value
            if x!=z:continue
            if any(a^b^c==0 for a,b,c in combinations(s,3)):
                continue
            total+=1
        counts.append(total)
    assert tuple(counts)==expected,(L,counts,expected)
    print(f"L={L} direct primitive count k2,k3,k4={counts}: PASS")

if __name__=="__main__":
    for L in (2,3,4):check(L)
    print("PASS direct fixed-rank-two subset enumeration L2-L4")

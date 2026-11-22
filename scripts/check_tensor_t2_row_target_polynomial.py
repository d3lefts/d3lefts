#!/usr/bin/env python3
"""Independent exact primitive row-target tensor XOR census (L=1..4).

No import from source PR #1029. Tests A1=1, A2=L, A3=4*C(L,2),
A4=5*C(L,2)+30*C(L,3) as finite examples, NOT all-L proof.
"""
from itertools import combinations
from math import comb


def rows(L):
    r=[1]; size=1
    for _ in range(L):
        r=r+[x<<size for x in r]+[(x<<size)|x for x in r]
        size *= 2
    assert len(r)==3**L and len(set(r))==len(r)
    return r


def independent(group):
    piv={}
    for v in group:
        while v:
            k=v.bit_length()-1
            if k in piv:
                v ^= piv[k]
            else:
                piv[k]=v
                break
        if v==0:
            return False
    return True


def count_at_row(L,target):
    r=rows(L)
    out=[]
    for k in range(1,5):
        count=0
        for C in combinations(r,k):
            z=0
            for v in C: z ^= v
            if z==target and independent(C):
                count+=1
        out.append(count)
    return out


def main():
    for L in range(1,5):
        row=rows(L)
        # Choose two different row targets to test local GL2 invariance.
        expected=[1,L,4*comb(L,2),5*comb(L,2)+30*comb(L,3)]
        for target in (row[0],row[-1]):
            actual=count_at_row(L,target)
            assert actual==expected,(L,target,actual,expected)
        print("PASS row-target independent primitive XOR L=%d rows=%d exact=%s" %
              (L,len(row),expected))
    print("All checks exact; all-L result relies on published tensor-circuit bound.")


if __name__=="__main__":
    main()

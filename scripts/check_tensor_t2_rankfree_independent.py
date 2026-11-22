#!/usr/bin/env python3
"""Independent exact F2 tensor-subcube sanity checks for PR #1016.

Finite evidence only. Not an all-L bound, a simulator, or a Lean proof.
Does not import the candidate's own code.
"""
from collections import Counter
from itertools import combinations, permutations
from math import comb


def rows(L):
    R=[1]; width=1
    for _ in range(L):
        R=R+[x<<width for x in R]+[(x<<width)|x for x in R]
        width *= 2
    assert len(R)==3**L and len(set(R))==len(R)
    return R


def gf2_rank(masks):
    pivots={}
    for x in masks:
        y=x
        while y:
            i=y.bit_length()-1
            if i in pivots:
                y ^= pivots[i]
            else:
                pivots[i]=y
                break
    return len(pivots)


def xor(xs):
    z=0
    for x in xs:
        z ^= x
    return z


def primitive_counts(L):
    D=[0]+rows(L)
    C=Counter()
    for tup in permutations(D,4):
        nz=[x for x in tup if x]
        if gf2_rank(nz)==len(nz):
            C[xor(tup)]+=1
    assert 0 not in C
    return C


def lower_witness(L,i,j,k):
    # Tensor factors: e0=1, e1=2, e2=e0+e1=3.
    factors=[(3,2,2,2) if site==i else
             (1,3,2,2) if site==j else
             (1,1,2,3) if site==k else
             (1,1,1,1) for site in range(L)]
    labels=[1]*4; bits=1
    for values in factors:
        temp=[]
        for old,x in zip(labels,values):
            temp.append(((old<<bits) if x&2 else 0) | (old if x&1 else 0))
        labels=temp;bits*=2
    assert all(x in rows(L) for x in labels)
    assert xor(labels)==1
    assert gf2_rank(labels)==4
    return labels


def main():
    for L in range(1,5):
        D=[0]+rows(L)
        pairs=Counter(a^b for a in D for b in D if a!=b)
        assert max(pairs.values())==2*L+2,(L,max(pairs.values()))
        print('PAIR PASS L=%d M=%d' % (L,max(pairs.values())))
    for L in (1,2,3):
        C=primitive_counts(L)
        print('PRIMITIVE FOUR LIFTS L=%d max=%d frequencies=%d' %
              (L,max(C.values(),default=0),len(C)))
        assert max(C.values(),default=0)=={1:0,2:312,3:1992}[L]
    for L in range(3,8):
        w=set()
        for i,j,k in combinations(range(L),3):
            labels=lower_witness(L,i,j,k)
            w.add(tuple(sorted(labels)))
        assert len(w)==comb(L,3)
        print('CUBIC LOWER WITNESS PASS L=%d distinct=%d' % (L,len(w)))
    print('PASS finite independent algebra only; no general all-circuit proof')


if __name__=='__main__':
    main()

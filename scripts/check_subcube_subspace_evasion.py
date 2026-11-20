#!/usr/bin/env python3
"""Exact finite independent checker for the tensor-subcube Segre intersection bound.

Enumerates every GF(2) subspace of the entire 2**L-dimensional ambient
space through L=3, including all affine row fibers and selected pair-sum
quotient multiplicities. Pure integer checks: no randomness or timeout.
General all-L claim is proved separately in the accompanying source note.
"""
from itertools import combinations, product
from collections import Counter

def subcube_rows(L):
    out=set()
    for u in product((1,2,3),repeat=L):
        row=0
        for z in range(1<<L):
            if all(u[i] & (1<<((z>>i)&1)) for i in range(L)):
                row |= 1<<z
        out.add(row)
    assert len(out)==3**L
    assert 0 not in out
    return out

def all_rref_bases(n,q):
    for pivots in combinations(range(n),q):
        available=[[j for j in range(p+1,n) if j not in pivots]
                   for p in pivots]
        free=sum(map(len,available))
        for mask in range(1<<free):
            pos=0; basis=[]
            for p,cols in zip(pivots,available):
                v=1<<p
                for col in cols:
                    if (mask>>pos)&1: v |= 1<<col
                    pos+=1
                basis.append(v)
            yield tuple(basis)

def reduce_mod_subspace(v, basis):
    for b in reversed(basis):
        if v & (b & -b):
            v ^= b
    return v

def exact_power_envelope(hits,q):
    """Prove hits<=q^(log_2 3) by exact integer arithmetic.

    If q is a power of two, the exponent simplifies exactly.
    Otherwise use the STRONGER rational test hits^12<=q^19,
    since 2^19<3^12, hence 19/12<log_2 3.
    """
    if q==0:return hits==0
    if q & (q-1)==0:return hits <= 3**(q.bit_length()-1)
    assert 2**19 < 3**12
    return hits**12 <= q**19

def audit_level(L):
    n=1<<L;R=subcube_rows(L)
    linear_max=[];fiber_max=[]
    pair_max=[]
    for q in range(n+1):
        lm=fm=pm=0; count=0
        for B in all_rref_bases(n,q):
            count+=1
            span=[0]
            for b in B:
                span += [x^b for x in span]
            linear_hits=sum(v in R for v in span)
            assert exact_power_envelope(linear_hits,q),(L,q,B,linear_hits)
            lm=max(lm,linear_hits)
            # Equal quotient labels index affine W-cosets.
            fibers=Counter(reduce_mod_subspace(row,B) for row in R)
            biggest=max(fibers.values(),default=0)
            assert exact_power_envelope(biggest,q+1),(L,q,B,biggest)
            assert fibers.get(0,0)==linear_hits
            fm=max(fm,biggest)
            if L==3 and q<=2:
                A=set(fibers)|{0}
                collisions=Counter(u^v for u in A for v in A if u!=v)
                pm=max(pm,max(collisions.values(),default=0))
        linear_max.append(lm);fiber_max.append(fm)
        if L==3 and q<=2: pair_max.append(pm)
        print("EVASIVE_EXHAUST",L,q,"spaces",count,
              "linear_max",lm,"affine_fiber_max",fm,flush=True)
    assert linear_max=={1:[0,1,3],
                        2:[0,1,3,5,9],
                        3:[0,1,3,5,9,11,15,19,27]}[L],linear_max
    if L==3:
        assert pair_max == [8,14,20],pair_max
        print("PAIR_QUOTIENT_NEGATIVE_CONTROL",pair_max)
    for k in range(L+1):
        q=1<<k
        assert linear_max[q]==3**k,(L,k,q,linear_max[q])
        print("SHARP_TENSOR_EXTREMIZER",L,q,linear_max[q])
    print("LEVEL_EXACT_PASS",L,"linear_max",linear_max,
          "affine_fiber_max",fiber_max)

if __name__=="__main__":
    for L in (1,2,3):
        audit_level(L)
    print("SUBCUBE_SUBSPACE_EVASION_EXACT_FINITE_PASS")

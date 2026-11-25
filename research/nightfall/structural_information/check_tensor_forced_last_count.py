#!/usr/bin/env python3
"""Independent exact forced-fourth-row and pair-cap audit for tensor T2.

No floating point, no imports from the author's six-site checker.
Distinguishes actual all-distinct Group A from repeated-zero overcount.
Uses integer-square-root intervals to certify theoretical crossover L.
Not a proof of the published LP circuit support or quantum Hilbert lemmas.
"""
from itertools import product, combinations
from collections import Counter
from random import Random
from math import comb, isqrt


def unordered_pair_max(D):
    freq=Counter(a ^ b for a in D for b in D if a != b)
    return max(freq.values(), default=0)


def distinct_four_counts(A):
    counts=Counter()
    for t in combinations(A,4):
        z=t[0]^t[1]^t[2]^t[3]
        if z:
            counts[z]+=24  # all four entries distinct, all 24 orderings
    return counts


def primitive_of_set(t):
    nz=[x for x in t if x]
    return not any(a^b^c==0 for a,b,c in combinations(nz,3))


def tensor_mask(factors):
    pos=[0]
    for f in factors:
        pos=[2*x+b for x in pos
             for b in ((0,1) if f==3 else ((0,) if f==1 else (1,)))]
    return sum(1<<i for i in pos)


def tensor_groupA_max(L):
    rows=[tensor_mask(factors) for factors in product((1,2,3),repeat=L)]
    assert len(set(rows))==3**L
    D=[0]+rows
    freq=Counter()
    for t in combinations(D,4):
        z=t[0]^t[1]^t[2]^t[3]
        if z and primitive_of_set(t):
            freq[z]+=24
    return max(freq.values(),default=0)


def ceil_sqrt(n):
    x=isqrt(n)
    return x+(x*x != n)


def qi_integer_envelope(L, variant):
    N=1+4*3**6
    C=sum(comb(L,j) for j in range(min(6,L)+1))
    M=2*L+2
    if variant=="original":
        K=N**4*C; c=145
    elif variant=="forced":
        K=N**3*C; c=35
    else:
        assert variant=="capped"
        K=N**2*min(N,M)*C; c=35
    # eps=delta=1/4 => eps²delta=1/64. Query count uses factor 2.
    # Q = ceil[128*(2 sqrt K+c sqrt M)^2].
    lower=128*(2*isqrt(K)+c*isqrt(M))**2
    upper=128*(2*ceil_sqrt(K)+c*ceil_sqrt(M))**2
    return lower,upper


def main():
    rng=Random(20261122)
    samples=0
    for size in range(4,15):
        for _ in range(22):
            D=sorted({0,*rng.sample(range(1,32),size-1)})
            A=sorted(rng.sample(D,rng.randint(4,len(D))))
            N=len(A)
            M=unordered_pair_max(D)
            freq=distinct_four_counts(A)
            for z,v in freq.items():
                assert z!=0
                assert v<=N**2*min(N,M),(D,A,z,v,N,M)
            samples+=1
    print(f"FORCED_PAIR_COMPLETION_EXACT_PASS: {samples} finite binary-label models")
    for L, expected in [(1,0),(2,312),(3,1992)]:
        found=tensor_groupA_max(L)
        assert found==expected,(L,found,expected)
        print(f"TENSOR_GROUP_A_EXACT_PASS: L={L} max={found}")
    targets={"original":50,"forced":42,"capped":38}
    for name,target in targets.items():
        for L in range(1,target):
            lower,_=qi_integer_envelope(L,name)
            assert lower>=3**L,(name,L,lower,3**L)
        _,upper=qi_integer_envelope(target,name)
        assert upper<3**target,(name,target,upper,3**target)
        print(f"RATIONAL_CROSSOVER_CERTIFIED: {name} first upper-bound crossover L={target}")
    print("PASS: forced-last/pair cap and exact integer crossover only; no all-L quantum certificate.")


if __name__=="__main__":
    main()

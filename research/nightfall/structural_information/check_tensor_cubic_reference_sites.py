#!/usr/bin/env python3
"""Independent source-algebra adversary for all-frequency cubic tensor lift proof.

Exhausts every primitive representation of lengths <=4 through L=3,
samples 50,000 four-row references at L=4 (incl. rank-four collisions),
and tests the explicit 8-row six-site witness with two different
three-site representations. Bell(5)=52 and integer square-root crossover
are independently checked. No imports from the other tensor checkers,
no randomness without fixed seed, and NO Lean/human certification claim.
"""
from itertools import combinations,product
from collections import Counter
from random import Random
from math import comb,isqrt


def row_mask(fs):
    bits=[0]
    for f in fs:
        bits=[2*x+b for x in bits
              for b in ((0,1) if f==3 else ((0,) if f==1 else (1,)))]
    return sum(1<<i for i in bits)


def xor_rows(rows,values):
    x=0
    for r in rows:x ^= values[r]
    return x


def primitive(rows,values):
    if not rows:return False
    if xor_rows(rows,values)==0:return False
    return all(xor_rows(t,values)!=0 for t in combinations(rows,3))


def variation(rows):
    if not rows:return set()
    n=len(next(iter(rows)))
    return {j for j in range(n) if len({r[j] for r in rows})>1}


def audit(reference,alternative,values):
    assert primitive(reference,values) and primitive(alternative,values)
    assert xor_rows(reference,values)==xor_rows(alternative,values)
    remaining=set(reference)^set(alternative)
    F=set()
    V=set()
    pattern=[]
    while remaining:
        circuit=None
        for k in range(1,len(remaining)+1):
            for sub in combinations(sorted(remaining),k):
                if xor_rows(sub,values)==0:
                    circuit=set(sub)
                    break
            if circuit is not None:break
        assert circuit is not None
        A=circuit&set(reference)
        B=circuit&set(alternative)
        assert A and B
        fi=variation(A)
        si=variation(circuit)
        assert fi <= si
        assert len(fi)>=len(A)-1,("reference variation",reference,A,fi)
        assert len(si)<=len(circuit)-2,("LP site bound finite check",circuit,si)
        F |= fi
        V |= si-fi
        pattern.append(tuple(sorted(A)))
        remaining -= circuit
    assert len(V)<=3,(reference,alternative,F,V,pattern)
    assert len(F|V)<=6,(reference,alternative,F,V,pattern)
    for a in alternative:
        assert any(all(a[j]==c[j] for j in range(len(a))
                       if j not in (F|V)) for c in reference)
    return len(V),len(F|V)


def bell_patterns(n):
    patterns=set()
    for mapping in product(range(n+1),repeat=n):
        # Positive labels: circuit blocks. Zero label: unused references.
        blocks=tuple(sorted(tuple(i for i,v in enumerate(mapping) if v==k)
                            for k in range(1,n+1) if k in mapping))
        patterns.add(blocks)
    return len(patterns)


def check_small(L):
    words=list(product((1,2,3),repeat=L))
    values={w:row_mask(w) for w in words}
    minref={}
    for k in range(1,5):
        for C in combinations(words,k):
            if primitive(C,values):
                minref.setdefault(xor_rows(C,values),C)
    total=0
    maxfree=0
    for k in range(1,5):
        for C in combinations(words,k):
            if primitive(C,values):
                v,_=audit(minref[xor_rows(C,values)],C,values)
                maxfree=max(maxfree,v)
                total+=1
    print(f"L={L} exhaustive primitive families={total} "
          f"minimum targets={len(minref)} extra-site maximum={maxfree} PASS")
    assert maxfree<=3


def check_L4():
    L=4
    words=list(product((1,2,3),repeat=L))
    values={w:row_mask(w) for w in words}
    minref={}
    for k in range(1,4):
        for C in combinations(words,k):
            if primitive(C,values):
                minref.setdefault(xor_rows(C,values),C)
    rank4seen={}
    random=Random(20261122)
    total=0
    collide=0
    maxfree=0
    for _ in range(50000):
        C=tuple(sorted(random.sample(words,4)))
        if not primitive(C,values):continue
        z=xor_rows(C,values)
        ref=minref.get(z)
        if ref is None:
            ref=rank4seen.setdefault(z,C)
            if ref!=C:collide+=1
        free,_=audit(ref,C,values)
        maxfree=max(maxfree,free)
        total+=1
    assert collide>=100 and maxfree<=3
    rank_four=[(1,1,1,1),(1,2,1,2),(2,1,2,1),(2,2,2,2)]
    assert primitive(rank_four,values)
    assert xor_rows(rank_four,values) not in minref
    assert len(variation(rank_four))==4
    print(f"L=4 sample={total}, minimum-rank-four collisions={collide}, "
          f"max new sites={maxfree}, explicit rank-four target PASS")


def check_negative_and_sixsite():
    words2=list(product((1,2,3),repeat=2))
    values2={w:row_mask(w) for w in words2}
    nonminimum=[(1,1),(1,2),(2,1),(3,3)]
    assert primitive(nonminimum,values2)
    assert len(variation(nonminimum))==2 < len(nonminimum)-1
    assert xor_rows(nonminimum,values2) == values2[(2,2)]
    print("MINIMUM_REFERENCE_NECESSARY: primitive nonminimum four-row support violation PASS")

    L=8
    z=(1,)*L
    families=((3,1,1),(2,3,1),(2,2,2),(2,2,3))
    sources=[]
    values={z:row_mask(z)}
    for slots in ((0,1,2),(3,4,5)):
        C=[]
        for entry in families:
            x=[1]*L
            for index,value in zip(slots,entry):x[index]=value
            t=tuple(x)
            C.append(t)
            values[t]=row_mask(t)
        sources.append(C)
    assert xor_rows(sources[0],values)==values[z]
    assert xor_rows(sources[1],values)==values[z]
    assert primitive(sources[0],values) and primitive(sources[1],values)
    for C in sources:
        free,active=audit([z],C,values)
        assert free==3 and active==3,(free,active)
    print("SIX_SITE_NEGATIVE_CONTROL: two disjoint triple-site families "
          "each spend exactly 3 free sites against true minimal row PASS")


def ceil_root(n):
    r=isqrt(n)
    return r+(r*r!=n)


def interval(L,case):
    N=1+4*3**6
    M=2*L+2
    S6=sum(comb(L,j) for j in range(min(L,6)+1))
    S3=sum(comb(L,j) for j in range(min(L,3)+1))
    if case=="original":K=N**4*S6;c=145
    elif case=="sixsite-pair":K=N**2*min(N,M)*S6;c=35
    else:
        assert case=="cubic"
        K=52*N**2*min(N,M)*S3;c=35
    # epsilon=delta=1/4 => epsilon^2*delta=1/64, factor 128.
    lower=128*(2*isqrt(K)+c*isqrt(M))**2
    upper=128*(2*ceil_root(K)+c*ceil_root(M))**2
    return lower,upper


def main():
    assert [bell_patterns(k) for k in range(1,5)]==[2,5,15,52]
    print("REFERENCE_PARTITION_BELL5_EXACT_PASS: 2, 5, 15, 52")
    for L in range(1,4):check_small(L)
    check_L4()
    check_negative_and_sixsite()
    for case,target in (("original",50),("sixsite-pair",38),("cubic",36)):
        for L in range(1,target):
            lower,_=interval(L,case)
            assert lower>=3**L,(case,L,lower)
        _,upper=interval(target,case)
        assert upper<3**target,(case,target,upper)
        print(f"INTEGER_CROSSOVER_CERTIFIED: {case} first L={target}")
    print("CUBIC_REFERENCE_SITE_EXACT_PASS: finite counterexample search "
          "and exact bound comparison only; all-L tensor theorem paper-level.")


if __name__=="__main__":
    main()

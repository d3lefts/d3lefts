#!/usr/bin/env python3
"""Exact local-dimension 3 cubic transfer and dimension 4 reference failure.

Uses integer XOR masks, exact GF(2) rank and independent pair enumeration.
Checks q=2,3 dimensions at tensor depth 1..3; and q=4 at depths 1..2.
Does NOT prove the all-L tensor splitting theorem or a T2 quantum simulator.
"""
from collections import Counter
from itertools import product

def mask(words, q):
    pos=[0]
    for factor in words:
        pos=[q*old+b for old in pos for b in range(q) if factor>>b&1]
    return sum(1<<p for p in pos)

def rank_gf2(rows):
    pivots={}
    for x in rows:
        while x:
            j=x.bit_length()-1
            if j in pivots:x ^= pivots[j]
            else:
                pivots[j]=x
                break
    return len(pivots)

def matrix_rank(flat,q):
    words=[sum(((flat>>(i*q+j))&1)<<j for j in range(q))
           for i in range(q)]
    return rank_gf2(words)

def pair_hist(q,L):
    alphabet=range(1,2**q)
    names=list(product(alphabet,repeat=L))
    rows=[mask(a,q) for a in names]
    assert len(rows)==len(set(rows))==(2**q-1)**L
    R=set(rows)
    unordered=Counter()
    for i,a in enumerate(rows):
        for b in rows[i+1:]:unordered[a^b]+=1
    rowP=L*(2**(q-1)-1)
    labels=Counter()
    for z, p in unordered.items():
        if z in R:
            assert p==rowP,(q,L,"row",z,p)
            labels["row"]+=1
        elif p==3: labels["nonrow-two-site"]+=1
        elif p==1: labels["nonrow-three-plus"]+=1
        else:raise AssertionError((q,L,z,p))
    assert labels["row"]==len(rows)
    assert sum(unordered.values())==len(rows)*(len(rows)-1)//2
    m=max((2*p+2*(z in R) for z,p in unordered.items()), default=2)
    assert m==2*L*(2**(q-1)-1)+2
    print(f"PAIR_HISTOGRAM_GF2_EXACT_PASS: q={q},L={L},rows={len(rows)}, "
          f"row-pair multiplicity={rowP},ordered M={m},class_counts={dict(labels)}")

def local_rank():
    q=3
    # All 512 matrices over F2^(3x3) have rank <=3.
    assert max(matrix_rank(x,q) for x in range(1<<(q*q)))==3
    # A rank-r matrix is a sum of exactly r nonzero elementary matrices;
    # constructive Gaussian row expansion gives <=3 factors for all.
    for z in range(1<<(q*q)):
        terms=[]
        for i in range(q):
            row=sum(((z>>(i*q+j))&1)<<j for j in range(q))
            if row:terms.append(mask((1<<i,row),q))
        assert len(terms)<=3
        x=0
        for t in terms:x^=t
        assert x==z,(z,terms)
    print("Q3_TWO_FACTOR_RANK_COVER_EXACT_PASS: 512 matrices with <=3 pure rows")
    q=4
    identity=sum(1<<(i*q+i) for i in range(q))
    assert matrix_rank(identity,q)==4
    tensors=[mask((1<<i,1<<i),q) for i in range(q)]
    assert len(set(tensors))==4
    assert tensors[0]^tensors[1]^tensors[2]^tensors[3]==identity
    assert rank_gf2(tensors)==4
    # Rank(X+Y)<=rank X+rank Y, so sum of <=3 rank-one matrices
    # cannot have matrix rank 4, giving a genuine minimum 4-row reference.
    print("Q4_REFERENCE_VARIATION_FAILURE_EXACT_PASS: four-row minimum "
          "rank-four identity with only two changing tensor sites")

def main():
    local_rank()
    for q in (2,3):
        for L in (1,2,3):pair_hist(q,L)
    for L in (1,2):pair_hist(4,L)
    print("DIMENSION_THRESHOLD_CHECKS_PASS: finite exact only, all-L proof paper-level")
if __name__=="__main__":
    main()

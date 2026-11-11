#!/usr/bin/env python3
"""Exact prime-by-prime logarithmic capacity audit for the diamond+product pair.

No floating point; bit lengths and integer square roots only. The
diamond mathematical construction is in DIAMOND_THEOREM.md, while the
previous product lower bound is credited to Tessera PR #267.

For D=largest power of two <=p/3, p lies in [3D,6D).
The combined one-query anchored sign construction is optimal except
when p^2+1 >=32D^2, a narrow window before the next diamond scale.
"""
from math import isqrt


def prime_sieve(N):
    v=bytearray([1])*(N+1)
    v[0]=v[1]=0
    for j in range(2,isqrt(N)+1):
        if v[j]:
            for k in range(j*j,N+1,j):
                v[k]=0
    return (j for j in range(2,N+1) if v[j])


def cap(p):
    assert p>=13
    D=1<<((p//3).bit_length()-1)
    d=D.bit_length()-1
    assert 3*D<=p<6*D
    b_diamond=2*d+2
    prod=max(2*(((p+1)//2).bit_length()-1),
             ((p-1)//2).bit_length()-1 + (p.bit_length()-1))
    info=((p*p+1)//2).bit_length()-1
    achieved=max(prod,b_diamond)
    assert achieved<=info
    threshold=32*D*D-1
    L=isqrt(threshold)
    if L*L<threshold:L+=1
    predicted=int(p>=L)
    assert info-achieved==predicted,(p,D,info,achieved,L)
    return D,d,info,prod,b_diamond,achieved,predicted,L


if __name__=="__main__":
    exact=gap=0
    by_d={}
    for p in prime_sieve(20000):
        if p<13:continue
        D,d,info,prod,dia,ach,g,L=cap(p)
        exact+=g==0
        gap+=g
        n=by_d.setdefault(d,[0,0])
        n[g]+=1
    assert gap>0 and exact>gap
    assert cap(23)[-2]==1
    assert cap(47)[-2]==1
    assert cap(191)[-2]==1
    for p in (13,29,31,53,59,61,97,101,103,113,127,193,223,251,389):
        d=cap(p)
        assert d[-2]==0,(p,d)
    print("PASS: exact capacity classification for all primes 13..20000")
    print({"alphabet_optimal_primes":exact,"one_bit_short_primes":gap,
           "by_log2_D":by_d,"remaining_gap_criterion":
           "ceil_sqrt(32 D^2-1) <= prime p < 6D"})

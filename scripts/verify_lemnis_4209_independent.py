#!/usr/bin/env python3
"""Independent exact audit of Lemnis's 4209-dimensional four-copy witness lift.

Independent from Lemnis's Gram/Sage-Fourier implementations:
81 difference fibres, 9x9 integer Gram blocks, exact rational Gaussian
elimination and separate modular rank, plus explicit outside-rectangle
rank-two matrix-unit witness. Checks linear algebra and dimensions only.
The imported nine-word rank-two positivity theorem needs separate audit.
"""
from __future__ import annotations
from collections import Counter, defaultdict
from fractions import Fraction
from itertools import product, combinations
import json

WORDS=tuple(product(range(3),repeat=4))
H=lambda a:((a[2]-a[0]-a[1])%3,(a[3]-a[0]-2*a[1])%3)
S={(0,0),(1,0),(2,0)}
T={(0,0),(0,1),(0,2)}
FIBRES=defaultdict(list)
for a in WORDS:
    if H(a) not in S:
        continue
    for b in WORDS:
        if H(b) in T:
            u=tuple((a[i]-b[i])%3 for i in range(4))
            FIBRES[u].append((a,b))
assert len(FIBRES)==81 and all(len(v)==9 for v in FIBRES.values())


def local(a,b,c,d,scalar):
    # 3 * P_scalar(E_ab,E_cd) or 3 * P_traceless(E_ab,E_cd).
    if scalar:
        return int(a==b and c==d)
    return 3*int(a==c and b==d)-int(a==b and c==d)


def gram_integer(u,m):
    """Return Gram matrix 3^4 * <E_ab, P_{E_m} E_cd>.
    E_m has m local scalar and 4-m local traceless factors.
    """
    vec=FIBRES[u]
    mat=[]
    for a,b in vec:
        row=[]
        for c,d in vec:
            x=0
            for J in combinations(range(4),m):
                z=1
                for i in range(4):
                    z*=local(a[i],b[i],c[i],d[i],i in J)
                x+=z
            row.append(x)
        mat.append(row)
    return mat


def rank_rational(M):
    a=[[Fraction(x) for x in row] for row in M]
    m=len(a);n=len(a[0]);r=0
    for j in range(n):
        v=next((k for k in range(r,m) if a[k][j]),None)
        if v is None:
            continue
        a[v],a[r]=a[r],a[v]
        pivot=a[r][j]
        for col in range(j,n):
            a[r][col]/=pivot
        for k in range(r+1,m):
            factor=a[k][j]
            if factor:
                for col in range(j,n):
                    a[k][col]-=factor*a[r][col]
        r+=1
        if r==m:
            break
    return r


def rank_mod(M,p=101):
    a=[[v%p for v in row] for row in M]
    m=len(a);n=len(a[0]);r=0
    for j in range(n):
        v=next((k for k in range(r,m) if a[k][j]),None)
        if v is None:
            continue
        a[v],a[r]=a[r],a[v]
        inv=pow(a[r][j],-1,p)
        for col in range(j,n):
            a[r][col]=a[r][col]*inv%p
        for k in range(r+1,m):
            factor=a[k][j]
            if factor:
                for col in range(j,n):
                    a[k][col]=(a[k][col]-factor*a[r][col])%p
        r+=1
        if r==m:
            break
    return r


def cross_numerator(a,b,c,d):
    n=1
    for i in range(4):
        n*=2*int(a[i]==c[i] and b[i]==d[i])-int(a[i]==b[i] and c[i]==d[i])
    return n


def main():
    ranks={}
    for level in (0,2,4):
        exact=Counter()
        modular=Counter()
        for u in sorted(FIBRES):
            mat=gram_integer(u,level)
            q=rank_rational(mat)
            r=rank_mod(mat)
            if q!=r:
                raise AssertionError(f"Rank mismatch level={level} difference={u}: {q} vs {r}")
            exact[q]+=1
            modular[r]+=1
        ranks[level]=(sum(k*v for k,v in exact.items()),dict(exact))
    if ranks[0][0]!=728 or ranks[2][0]!=272 or ranks[4][0]!=1:
        raise AssertionError(f"Claimed projection ranks incorrect: {ranks}")
    # Dimension: E_0=8^4=4096; E_2=choose(4,2)*8^2=384.
    ldim=9*9*9+(8**4-ranks[0][0])+(6*8**2-ranks[2][0])
    if ldim!=4209:
        raise AssertionError("4209-dimensional sum incorrect")
    # A minimal strict enlargement: rank-two sum of two disjoint matrix
    # units, the new unit having all four local factors traceless.
    a=b=(0,0,0,0)
    c=(1,1,1,1)
    d=(2,2,2,2)
    if H(a) not in S or H(b) not in T or (H(c) in S and H(d) in T):
        raise AssertionError("Simple witness fails support inclusion")
    if any(ci==di for ci,di in zip(c,d)):
        raise AssertionError("Outside witness does not lie in E_0")
    if a==c or b==d:
        raise AssertionError("The two matrix units must form rank exactly two")
    # Q(E_ab)=(1/2)^4, Q(E_cd)=1, no cross term as W acts
    # with eigenvalue 1 on E_cd in E_0, orthogonal to old matrix unit.
    q_old=Fraction(cross_numerator(a,b,a,b),16)
    q_new=Fraction(cross_numerator(c,d,c,d),16)
    q_cross=Fraction(cross_numerator(a,b,c,d),16)
    if (q_old,q_new,q_cross)!=(Fraction(1,16),Fraction(1),Fraction(0)):
        raise AssertionError("Explicit rank-two enlargement has invalid quadratic-form values")
    report={
        "status":"PASS",
        "old_complex_dimension":729,
        "E0_complex_dimension":4096,
        "E2_complex_dimension":384,
        "projected_U_rank_E0":728,
        "projected_U_rank_E2":272,
        "projected_U_rank_E4":1,
        "added_orthogonal_E0_dimension":3368,
        "added_orthogonal_E2_dimension":112,
        "derived_complex_dimension":ldim,
        "fiber_size":9,
        "difference_fibers":81,
        "E0_ranks_per_fiber":ranks[0][1],
        "E2_ranks_per_fiber":ranks[2][1],
        "exact_arithmetic_paths":["rational Gaussian elimination","modular Gaussian elimination F_101"],
        "strict_rank_two_witness":["E_(0000,0000)","E_(1111,2222)"],
        "Q_of_old":"1/16","Q_of_new":"1","cross_term":"0",
        "Q_of_sum":"17/16",
        "scope":"Dimension and explicit witness verified independently; full restricted positivity uses imported nine-word rank-two theorem."
    }
    print(json.dumps(report,sort_keys=True,indent=2))


if __name__=="__main__":
    main()

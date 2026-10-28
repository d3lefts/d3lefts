#!/usr/bin/env python3
"""Sharp exact operator norms of all 72 four-qutrit Werner sector collisions.

Each off-sector operator is an orthogonal direct sum of nine 9×9 blocks
indexed by the unchanged coordinatewise difference a-b in F3^4.
Entries are rational multiples of 1/16. Exact PSD Schur elimination and
a nontrivial kernel of q² I - NᵀN certify both the bound and sharpness.
No floating-point singular values, spectral approximations, or external libs.
"""
from __future__ import annotations
from collections import Counter, defaultdict
from fractions import Fraction
from itertools import product
import json

V=tuple(product(range(3),repeat=4))
H=lambda a:((a[2]-a[0]-a[1])%3,(a[3]-a[0]-2*a[1])%3)
KEYS=tuple(product(range(3),repeat=2))
S=((0,0),(1,0),(2,0))
T=((0,0),(0,1),(0,2))
BASE={(s,t) for s in S for t in T}
WORDS={s:[a for a in V if H(a)==s] for s in KEYS}


def diff(a,b):
    return tuple((x-y)%3 for x,y in zip(a,b))


def fibres(s,t):
    groups=defaultdict(list)
    for a in WORDS[s]:
        for b in WORDS[t]:
            groups[diff(a,b)].append((a,b))
    if len(groups)!=9 or any(len(group)!=9 for group in groups.values()):
        raise ValueError("Nine difference fibres expected, each with nine coordinate matrix units")
    return groups


def tensor_numerator(ab,cd):
    a,b=ab
    c,d=cd
    v=1
    for i in range(4):
        v*=2*int(a[i]==c[i] and b[i]==d[i])-int(a[i]==b[i] and c[i]==d[i])
    return v


def gram_gap(N,q):
    # N=16*B_u. The desired operator norm bound is q/16.
    return [[(q*q if i==j else 0)-sum(row[i]*row[j] for row in N)
             for j in range(9)] for i in range(9)]


def psd_and_nullity(A):
    """Symmetric exact semidefinite elimination by congruence.

    A zero diagonal pivot is admissible only when the remaining coupling
    in its row vanishes. Positive pivots are removed by exact Schur updates.
    """
    A=[[Fraction(x) for x in row] for row in A]
    n=len(A)
    nullity=0
    for k in range(n):
        pivot=A[k][k]
        if pivot<0:
            return False,0
        if pivot==0:
            if any(A[k][j] for j in range(k+1,n)):
                return False,0
            nullity+=1
            continue
        for i in range(k+1,n):
            for j in range(i,n):
                A[i][j]-=A[k][i]*A[k][j]/pivot
                A[j][i]=A[i][j]
    return True,nullity


def evaluate():
    old_by_delta={diff(s,t):(s,t) for s,t in BASE}
    if len(old_by_delta)!=9:
        raise ValueError("Old syndrome rectangle not a perfect difference system")
    hist=Counter()
    records=[]
    for new in product(KEYS,KEYS):
        if new in BASE:
            continue
        old=old_by_delta[diff(*new)]
        fg= fibres(*old)
        gg= fibres(*new)
        if set(fg)!=set(gg):
            raise ValueError("Syndrome collision has inconsistent difference fibres")
        all_six=True
        all_eight=True
        six_equality=False
        eight_equality=False
        for u in fg:
            N=[[tensor_numerator(x,y) for y in gg[u]] for x in fg[u]]
            if len(N)!=9 or any(len(row)!=9 for row in N):
                raise ValueError("Invalid exact 9×9 coupling block")
            at_six,ker_six=psd_and_nullity(gram_gap(N,6))
            at_eight,ker_eight=psd_and_nullity(gram_gap(N,8))
            all_six &= at_six
            all_eight &= at_eight
            six_equality |= at_six and ker_six>0
            eight_equality |= at_eight and ker_eight>0
        if not all_eight:
            raise ValueError("Universal candidate 1/2 coupling bound failed")
        q=6 if all_six else 8
        if q==6 and not six_equality or q==8 and not eight_equality:
            raise ValueError("Sharpness missing an exact nullspace witness")
        hist[q]+=1
        records.append({"old":"".join(map(str,old[0]))+":"+ "".join(map(str,old[1])),
                        "added":"".join(map(str,new[0]))+":"+ "".join(map(str,new[1])),
                        "sharp_norm_numerator":q})
    if hist!=Counter({6:16,8:56}) or len(records)!=72:
        raise ValueError(f"Sharp operator-norm classification changed: {hist}")
    # Negative fixture: a forged oversized interaction must fail the PSD bound.
    corrupted=[[0]*9 for _ in range(9)]
    corrupted[0][0]=9
    if psd_and_nullity(gram_gap(corrupted,8))[0]:
        raise AssertionError("PSDs accepted a forged excessive coupling")
    return {"status":"PASS","scope":"Four qutrit sites at t=1/2; 72 off-sector cross-operator norms",
            "verified_sector_pairs":72,
            "difference_fibres_per_pair":9,
            "matrix_size_per_fibre":"9x9",
            "sharp_operator_norm_histogram":{"3/8":16,"1/2":56},
            "method":"Exact rational Schur-PSD upper bound plus exact nullity as sharpness certificate",
            "negative_control":"Forged operator > 1/2 rejected"}


if __name__=="__main__":
    print(json.dumps(evaluate(),indent=2,sort_keys=True))

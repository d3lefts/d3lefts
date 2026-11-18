#!/usr/bin/env python3
"""Exact genuine-source two-replica cubic→quadratic gate witness.

Full 512 difference-mask × 512 source-sign enumeration, and actual fair
Walsh coefficients. All integer/Fraction arithmetic, no approximate inputs.
This is a lower-bound witness for gate K, not a universal theorem.
"""
from fractions import Fraction as F
from itertools import product

T=(
 ((0,-1,-1),(1,1,0),(-1,0,1)),
 ((1,-1,0),(0,1,-1),(1,0,-1)),
 ((1,0,1),(1,0,1),(0,0,0)),
)
E=tuple((i,3+j,6+k,T[i][j][k])
        for i in range(3) for j in range(3) for k in range(3)
        if T[i][j][k])
edge_masks=tuple((1<<i)|(1<<j)|(1<<k) for i,j,k,w in E)
words=tuple(product((-1,1),repeat=9))
mon=tuple(tuple(w*x[i]*x[j]*x[k] for i,j,k,w in E) for x in words)
A=0
U_count=0
J_count=[0]*9
amp_hist={}
for D in range(512):
    groups={}
    kept=[]
    for e,m in enumerate(edge_masks):
        a=m&D
        if a.bit_count()==3:
            continue
        groups.setdefault(a,[]).append(e)
        kept.append(e)
    local_A=0
    for row in mon:
        # For every pair X,Z, D indicates exactly the coordinates where
        # X and Z disagree. Original f on fair selectors eps=+1 evaluates
        # to mon(X). Other eps signs can be absorbed into X, leaving D fixed.
        q=sum(row[e] for e in kept)
        local_A=max(local_A,abs(q))
        # An original cubic monomial contributes fair Walsh support
        # m & D. Project away precisely support-cardinality three.
        for a,edges in groups.items():
            if a==0:
                continue
            coeff=sum(row[e] for e in edges)
            U_count+=coeff*coeff
            for i in range(9):
                if (a>>i)&1:
                    J_count[i]+=coeff*coeff
    A=max(A,local_A)
    amp_hist[local_A]=amp_hist.get(local_A,0)+1
N=512*512
U=F(U_count,N)
J=tuple(F(q,N) for q in J_count)
assert (A,U)==(7,12),(A,U)
assert J==(F(9,4),F(9,4),F(3,2),F(9,4),F(9,4),F(3,2),F(9,4),F(3,2),F(9,4)),J
assert U*U/(A*A*max(J))==F(64,49)
assert amp_hist=={4:223,5:76,6:160,7:52,0:1},amp_hist
print('PASS 512 pair masks × 512 true source words: exact source-consistent quadratic image')
print('PASS A=7, U=12, max mean fair influence J=9/4, normalized K lower=64/49')
print('PASS full conditional amplitude histogram:',amp_hist)
print('SCOPE finite exact lower witness, not source-consistent annealed Q2 upper theorem')

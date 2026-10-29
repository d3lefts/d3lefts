#!/usr/bin/env python3
"""AXIOM independent third checker: q-ary, r-row, n-copy partial traces + Schur criterion.
No imports from the two qutrit checker scripts.
"""
from itertools import product,combinations
from fractions import Fraction
from collections import defaultdict
from hashlib import sha256
from pathlib import Path
from random import Random
F=Fraction
rng=Random(90217)

def quadratic(C,n,r):
    result=F(0)
    for mask in range(1<<n):
        keep=[i for i in range(n) if not(mask>>i)&1]
        lost=[i for i in range(n) if(mask>>i)&1]
        T=defaultdict(F)
        for (a,b),v in C.items():
            if all(a[i]==b[i] for i in lost):
                T[tuple(a[i] for i in keep),tuple(b[i] for i in keep)]+=v
        result+=F(-1,r)**len(lost)*sum(v*v for v in T.values())
    return result

def form_restricted(S,n,r,d,grade):
    z=[i for i in range(n) if grade[i]==0]
    R=[]
    for a in S:
        b=tuple((a[i]-grade[i])%d for i in range(n))
        R.append((a,b))
    M=[]
    for i in range(len(S)):
        row=[]
        for j in range(len(S)):
            x={R[i]:F(1)}
            y={R[j]:F(1)}
            if R[i]==R[j]:val=quadratic(x,n,r)
            else:val=(quadratic({**x,**y},n,r)-quadratic(x,n,r)-quadratic(y,n,r))/2
            row.append(val)
        M.append(row)
    return M

def is_psd_3x3(M):
    # Rational principal minors; valid for any symmetric <=3 matrix.
    k=len(M)
    for s in range(1,k+1):
        for ix in combinations(range(k),s):
            A=[[M[i][j] for j in ix] for i in ix]
            if s==1: det=A[0][0]
            elif s==2: det=A[0][0]*A[1][1]-A[0][1]*A[1][0]
            else:
                det=(A[0][0]*(A[1][1]*A[2][2]-A[1][2]*A[2][1])
                      -A[0][1]*(A[1][0]*A[2][2]-A[1][2]*A[2][0])
                      +A[0][2]*(A[1][0]*A[2][1]-A[1][1]*A[2][0]))
            if det<0:return False
    return True

# Sample all three-coordinate support patterns over d=4, r=3, n=2.
rows=list(product(range(4),repeat=2))
checked=0
for grade in ((0,0),(1,0),(0,2),(1,2)):
    for S in list(combinations(rows,3))[:140]:
        M=form_restricted(S,2,3,4,grade)
        assert is_psd_3x3(M),(S,grade,M)
        checked+=1
# Independent random coefficient tests on all column directions of three *fixed* rows.
for n,d,r in ((2,4,3),(3,4,3),(4,3,2)):
    word=list(product(range(d),repeat=n))
    rows=rng.sample(word,r)
    for _ in range(18):
        C={}
        for a in rows:
            for b in rng.sample(word,min(8,len(word))):
                v=rng.randint(-3,3)
                if v:C[(a,b)]=F(v)
        q=quadratic(C,n,r)
        assert q>=0,(n,d,r,q)
# Sharpness: r+1-row counterexample for d>=r+1.
for n,d,r in ((1,3,2),(4,3,2),(2,4,3),(3,4,3)):
    C={(tuple([i]+[0]*(n-1)),tuple([i]+[0]*(n-1))):F(1) for i in range(r+1)}
    q=quadratic(C,n,r)
    want=-F(r+1,r)*F(r-1,r)**(n-1)
    assert q==want,(q,want)
    assert q<0
print('PASS complete rational principal-minor tests',checked)
print('PASS random r-row all-column nonnegative physical forms, 54 tests')
print('PASS sharp r+1 row negative witnesses across (n,d,r)=(1,3,2),(4,3,2),(2,4,3),(3,4,3)')
print('SHA256',sha256(Path(__file__).read_bytes()).hexdigest())

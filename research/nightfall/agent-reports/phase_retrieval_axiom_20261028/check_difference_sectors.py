#!/usr/bin/env python3
"""Axiom independent exact check of the 2026-10-28 four-qutrit difference-sector improvement.
Uses literal sparse matrix coordinates and local operator expansion, NOT Lemnis's checker.
"""
from itertools import product
from fractions import Fraction as F
from collections import defaultdict
from hashlib import sha256
from pathlib import Path

zero=(0,0,0,0)

def E(a,b,v=1):return {(tuple(a),tuple(b)):F(v)}
def add(*terms):
    z=defaultdict(F)
    for obj in terms:
        for key,val in obj.items():z[key]+=val
    return {k:v for k,v in z.items() if v}
def scale(obj,v):return {k:val*F(v) for k,val in obj.items()}
def inner(a,b):return sum(v*b.get(k,0) for k,v in a.items())
def norm2(a):return inner(a,a)
def diff(key):return tuple((a-b)%3 for a,b in zip(*key))
def sectors(a):
    out=defaultdict(dict)
    for key,val in a.items():out[diff(key)][key]=val
    return dict(out)
def K_one(src):
    # Four-fold product of the local I - |Omega><Omega|/2 operator.
    # Each diagonal local coordinate is sent to its own identity column
    # minus one half of every equal-row-column local coordinate.
    out=defaultdict(F)
    for (a,b),value in src.items():
        modes=[]
        for u,v in zip(a,b):
            if u!=v: modes.append([((u,v),F(1))]);continue
            weights=defaultdict(F);weights[(u,v)]+=F(1)
            for j in range(3):weights[(j,j)]-=F(1,2)
            modes.append([(key,v) for key,v in weights.items() if v])
        for positions in product(*modes):
            aa=tuple(q[0][0] for q in positions)
            bb=tuple(q[0][1] for q in positions)
            coeff=value
            for p in positions:coeff*=p[1]
            out[(aa,bb)]+=coeff
    return {k:v for k,v in out.items() if v}

def Q(a):return inner(a,K_one(a))
def H(a):return ((a[2]-a[0]-a[1])%3,(a[3]-a[0]-2*a[1])%3)
def inU(key):a,b=key;return H(a)[1]==0 and H(b)[0]==0
def keepU(a):return {k:v for k,v in a.items() if inU(k)}
def removeU(a):return {k:v for k,v in a.items() if not inU(k)}

def rank(A):
    rows=sorted(set(a for a,b in A));cols=sorted(set(b for a,b in A))
    mat=[[A.get((a,b),F(0)) for b in cols] for a in rows]
    r=0
    for j in range(len(cols)):
        p=next((i for i in range(r,len(rows)) if mat[i][j]),None)
        if p is None:continue
        mat[r],mat[p]=mat[p],mat[r]
        fac=mat[r][j]
        mat[r]=[q/fac for q in mat[r]]
        for i in range(r+1,len(rows)):
            factor=mat[i][j]
            if factor:mat[i]=[u-factor*v for u,v in zip(mat[i],mat[r])]
        r+=1
        if r==len(rows):break
    return r

# Model independent of imported source implementation
A=E(zero,zero,4)
B=add(E(zero,(1,1,1,1)),E((1,0,0,0),(2,1,2,1)))
M=E(zero,(0,1,2,1))
R={((u,0,0,0),(u,1,2,1)):F(1,3) for u in range(3)}
D=add(B,M,scale(R,-1))
assert all(not inU(k) for k in D) and all(not inU(k) for k in R)
assert add(D,R)==add(B,M)
assert rank(add(A,B,M))==2 and rank(R)==3
assert all(diff(k)==(0,2,1,2) for k in R)
assert all(diff(k)==(0,0,0,0) for k in A)
assert set(sectors(A))&set(sectors(R))==set()
assert all(diff(k)==(0,2,1,2) for k in M)
assert Q(A)==F(1)
assert Q(B)==F(2)
assert Q(R)==-F(1,6)
assert norm2(D)==F(8,3)
assert Q(D)==norm2(D)
assert Q(add(A,B,M))==F(7,2)
assert Q(add(A,D,R))==F(7,2)
assert inner(A,K_one(R))==0
assert inner(D,K_one(R))==0
assert inner(A,K_one(D))==0
assert norm2(removeU(K_one(A)))==F(9,2)

# The new example is a strict separation from the previous anisotropic tube.
for t in [F(1,2),F(1),F(1,4)]:
    C=add(A,scale(B,t),scale(M,t))
    r2=t*t*F(1,3);w=t*t*F(8,3)
    # Lemnis previously required w>=2*h*r +r^2/2, where h^2=9/2.
    # To test failure with exact fractions, both sides are positive:
    older_pass=(w-r2/F(2))>=0 and (w-r2/F(2))**2>=4*F(9,2)*r2
    new_margin=w-r2/F(2)  # exact zero cross: source and residual are disjoint difference grades
    assert rank(C)==2 and Q(C)==F(1)+F(5,2)*t*t
    assert new_margin>0
    assert older_pass == (t == F(1))
    print({'t':str(t),'rank':rank(C),'Q_exact':str(Q(C)),
           'new_lower_bound':str(new_margin),'old_anisotropic_pass':older_pass})

# Invariance: every K-image retains its coordinate difference, for 6561 basis entries.
words=list(product(range(3),repeat=4))
for a in words:
    for b in words:
        grade=diff((a,b))
        assert all(diff(k)==grade for k in K_one(E(a,b)))
print('PASS: 6561 coordinate basis directions preserve difference grade')
print('PASS: exact rank-two witness, no cross-sector leakage, strict grade-aware enlargement')
print('FILE_SHA256:',sha256(Path(__file__).read_bytes()).hexdigest())

#!/usr/bin/env python3
"""Axiom standalone exact GF25 fixtures: decoder rank defect vs actual ambiguity.
No NumPy, field represented as a+5*b for a+b*u, u*u=2 over F5.
"""
from itertools import product

MUL=[]
for i in range(25):
    a,b=i%5,i//5
    MUL.append([((a*(j%5)+2*b*(j//5))%5)+5*((a*(j//5)+b*(j%5))%5) for j in range(25)])
ADD=[[(i%5+j%5)%5+5*((i//5+j//5)%5) for j in range(25)] for i in range(25)]
NEG=[(-i%5)+5*((-(i//5))%5) for i in range(25)]
def power(a,n):
    v=1
    while n:
        if n&1:v=MUL[v][a]
        a=MUL[a][a];n>>=1
    return v
def dot(a,b):
    v=0
    for x,y in zip(a,b):v=ADD[v][MUL[x][y]]
    return v
def rank(A):
    A=[list(x) for x in A]
    n=len(A); cols=len(A[0]); r=0
    for j in range(cols):
        pivot=next((i for i in range(r,n) if A[i][j]!=0),None)
        if pivot is None:continue
        A[r],A[pivot]=A[pivot],A[r]
        t=power(A[r][j],23)
        A[r]=[MUL[t][z] for z in A[r]]
        for i in range(n):
            if i==r:continue
            alpha=A[i][j]
            if alpha:
                A[i]=[ADD[x][NEG[MUL[alpha][y]]] for x,y in zip(A[i],A[r])]
        r+=1
        if r==n:break
    return r
def check(A,k,expected_rank,expected_count):
    planted=(1,)+tuple(0 for _ in range(k-1))
    y=[power(a[0],4) for a in A]
    R=[[power(v,5) for v in a]+[NEG[MUL[t][v]] for v in a] for a,t in zip(A,y)]
    rk=rank(R)
    assert rk==expected_rank,(rk,expected_rank)
    roots=[v for v in range(25) if power(v,4)==1]
    orbit={(v,)+tuple(0 for _ in range(k-1)) for v in roots}
    preimages=[]
    for x in product(range(25),repeat=k):
        if all(power(dot(a,x),4)==t for a,t in zip(A,y)):
            preimages.append(x)
    assert len(preimages)==expected_count,(len(preimages),expected_count)
    assert orbit <=set(preimages)
    return dict(k=k,m=len(A),rank=rk,kernel_dimension=2*k-rk,
                preimages=len(preimages),phase_orbit=len(roots),
                genuine_ambiguity=(len(preimages)>len(orbit)),
                first_extra=next((x for x in preimages if x not in orbit),None))

# Explicit frozen seed-1729 cases, independently transcribed to packed F25 digits:
A3=[[2,11,15],[10,22,22],[20,21,13],[19,6,2],[19,12,9],[5,11,19]]
A4=[[22,19,8,23],[19,4,11,12],[15,8,4,14],[21,7,2,21],
    [19,20,6,5],[19,22,18,22],[9,17,24,15],[8,3,4,17]]
if __name__=="__main__":
    a=check(A3,3,4,8)
    b=check(A4,4,6,4)
    assert a["genuine_ambiguity"] and not b["genuine_ambiguity"]
    print({"status":"PASS","genuine_ambiguity":a,"rank_only_defect":b})

#!/usr/bin/env python3
"""Exact independent checks: low-degree Simon spectral profiles and general Gram transfer.
No imports from PR #987/988 scripts. Finite checks do not certify universal theorems.
"""
from fractions import Fraction as F
from itertools import permutations
from math import comb, factorial


def simon_tables(N):
    for s in range(1,N):
        cosets=[]; seen=set()
        for x in range(N):
            if x in seen: continue
            cosets.append((x,x^s)); seen.update((x,x^s))
        for labels in permutations(range(N),N//2):
            table=[-1]*N
            for (a,b),lab in zip(cosets,labels):
                table[a]=lab;table[b]=lab
            yield table


def audit_simon(N):
    pair=[[0]*N for _ in range(N)]
    triple=[[[0]*N for _ in range(N)] for _ in range(N)]
    count=0;four=0
    for x in simon_tables(N):
        count+=1;pair[x[0]][x[1]]+=1;triple[x[0]][x[1]][x[2]]+=1
        four+=int(x[0]==x[1] and x[2]==x[3])
    assert count==(N-1)*factorial(N)//factorial(N//2)
    assert F(four,count)==F(1,N-1)

    def dp(u,v):
        p=F(pair[u][v],count)
        goal=F(1,N*(N-1)) if u==v else F(N-2,N*(N-1)**2)
        assert p==goal
        return p*N*N-1

    def dt(u,v,w):
        p=F(triple[u][v][w],count)
        if u==v==w: goal=F(0)
        elif u==v or u==w or v==w: goal=F(1,N*(N-1)**2)
        else: goal=F(N-4,N*(N-1)**2*(N-2))
        assert p==goal
        return p*N**3-1-dp(u,v)-dp(u,w)-dp(v,w)

    e2=sum((dp(u,v)**2 for u in range(N) for v in range(N)),F(0))/N**2
    e3=sum((dt(u,v,w)**2 for u in range(N) for v in range(N) for w in range(N)),F(0))/N**3
    assert e2==F(1,(N-1)**3)
    assert e3==F((N+2)**2,(N-1)**3*(N-2))
    for u in range(N):
        for v in range(N):
            assert sum((dt(u,v,w) for w in range(N)),F(0))==0
    lam2=comb(N,2)*e2;lam3=lam2+comb(N,3)*e3
    assert lam2==F(N,2*(N-1)**2)
    assert lam3==F(N*(N*N+4*N+7),6*(N-1)**2)
    p=F(1,N*N);delta=F(four,count)-p
    lb4=delta**2/(p*(1-p))
    assert lb4==F((N*N-N+1)**2,(N-1)**2*(N*N-1))
    print(f'Simon N={N}: {count} tables, Lambda2^2={lam2}, Lambda3^2={lam3}, Lambda4^2>={lb4}')


def solve(A,b):
    # Independent exact-rational Gaussian elimination for a full Gram basis.
    n=len(b);mat=[list(map(F,row))+[F(bi)] for row,bi in zip(A,b)]
    for i in range(n):
        pivot=next(k for k in range(i,n) if mat[k][i])
        mat[i],mat[pivot]=mat[pivot],mat[i]
        scale=mat[i][i]
        mat[i]=[v/scale for v in mat[i]]
        for k in range(n):
            if k==i: continue
            scale=mat[k][i]
            mat[k]=[a-scale*bb for a,bb in zip(mat[k],mat[i])]
    return [row[-1] for row in mat]


def audit_gram():
    points=((0,0),(0,1),(1,0),(1,1))
    Q=(F(1,3),F(1,6),F(1,6),F(1,3))
    V=(F(1,2),F(1,4),F(1,8),F(1,8))
    def expectation(v,law):return sum((a*b for a,b in zip(v,law)),F(0))
    vectors=[[F(x) for x,y in points],
             [F(y) for x,y in points],
             [F(x*y) for x,y in points]]
    phi=[[z-expectation(v,Q) for z in v] for v in vectors]
    G=[[expectation([v*w for v,w in zip(u,z)],Q) for z in phi] for u in phi]
    b=[expectation(u,V)-expectation(u,Q) for u in phi]
    c=solve(G,b)
    energy=sum((x*y for x,y in zip(b,c)),F(0))
    density_energy=sum(((v-q)**2/q for q,v in zip(Q,V)),F(0))
    assert energy==density_energy
    f=[F(x) for x,y in points]
    t=[F(y) for x,y in points]
    risk=[(u-v)**2 for u,v in zip(f,t)]
    diff=expectation(risk,V)-expectation(risk,Q)
    assert 4*diff**2 <= energy
    Q1=(F(1,2),F(1,2));V1=(F(1,4),F(3,4))
    lambda_sq=sum(((v-q)**2/q for q,v in zip(Q1,V1)),F(0))
    difference=V1[1]-Q1[1]
    assert 4*difference**2==lambda_sq
    print(f'General nonproduct Gram inverse: Lambda2^2={energy}; sharp factor 1/2 validated')


if __name__=='__main__':
    audit_gram()
    for N in (4,8):audit_simon(N)
    print('PASS: exact rational independent spectral and Gram audits')

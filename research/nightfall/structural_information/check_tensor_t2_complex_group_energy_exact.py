#!/usr/bin/env python3
"""Independent exact Gaussian-rational T2 grouped-energy adversarial checker.

L=1,2 only. Uses rational orthogonal mixing with independent complex
quarter-turn phase diagonals and real nonprojective high-rank effects.
No floating point is used in assertions. This is a finite independent
experiment, not a full arbitrary-Hilbert quantum simulation proof.
"""
from fractions import Fraction as Q
from collections import defaultdict
from itertools import product

def mm(A,B):
    return [[sum((A[i][k]*B[k][j] for k in range(len(B))),Q(0))
        for j in range(len(B[0]))] for i in range(len(A))]
def tr(A): return list(map(list,zip(*A)))
def eye(n): return [[Q(int(i==j)) for j in range(n)] for i in range(n)]
def rotate(n,sgn):
    O=eye(n)
    for k in (range(n-1) if sgn==1 else range(n-2,-1,-1)):
        R=eye(n);R[k][k]=R[k+1][k+1]=Q(3,5)
        R[k][k+1]=Q(4*sgn,5);R[k+1][k]=Q(-4*sgn,5)
        O=mm(R,O)
    assert mm(O,tr(O))==eye(n)
    return O
def tensor_row(t):
    v=[0]
    for f in t:
        v=[2*i+j for i in v for j in ((0,1) if f==3 else (f-1,))]
    return sum(1<<i for i in v)
def gauss(q,e):
    e%=4
    return (q,Q(0)) if e==0 else (
        (Q(0),q) if e==1 else ((-q,Q(0)) if e==2 else (Q(0),-q)))
def add(x,y): return x[0]+y[0],x[1]+y[1]
def mul(x,y):
    return (x[0]*y[0]-x[1]*y[1],x[0]*y[1]+x[1]*y[0])
def conj(x): return x[0],-x[1]
def abs2(x): return x[0]*x[0]+x[1]*x[1]
def sg(z,s): return -1 if (z&s).bit_count()%2 else 1
Z=(Q(0),Q(0))

def check(L,efftype):
    D=[0]+[tensor_row(t) for t in product((1,2,3),repeat=L)]
    n=len(D);size=2**(2**L)
    V=rotate(n,-1);U=rotate(n,1);Qv=rotate(n,-1)
    lambdas=[Q(i+1,n+2) if efftype=='full'
             else (Q(0) if i==0 else Q(1)) for i in range(n)]
    B=mm(mm(V,[[Q(i==j)*lambdas[i] for j in range(n)]
               for i in range(n)]),tr(V))
    pU=[(3*j+1)%4 for j in range(n)]
    pI=[(j*j+2)%4 for j in range(n)]
    pP=[(j*7+1)%4 for j in range(n)]
    pPsi=[(2*j*j+j+1)%4 for j in range(n)]
    psi=[Qv[a][0] for a in range(n)]
    t=[[U[b][a]*psi[a] for a in range(n)] for b in range(n)]
    p=[x*x for x in psi]
    q=[sum((t[b][a]**2 for a in range(n)),Q(0)) for b in range(n)]
    assert sum(p)==sum(q)==1
    terms=[];fc=defaultdict(lambda:Z)
    for a in range(n):
        for b in range(n):
            for ap in range(n):
                for bp in range(n):
                    amp=t[b][a]*t[bp][ap]*B[bp][b]
                    ex=(pU[b]+pI[a]+pPsi[a]-pU[bp]-pI[ap]-
                        pPsi[ap]+pP[bp]-pP[b])%4
                    c=gauss(amp,ex)
                    z=D[a]^D[b]^D[ap]^D[bp]
                    terms.append((a,b,ap,bp,z,c))
                    fc[z]=add(fc[z],c)
    assert all(im==0 for _,im in fc.values())
    def tail(g,W):
        return sum((abs2(v) for z,v in g.items() if z not in W),Q(0))
    for s in range(size):
        state=[]
        for b in range(n):
            x=Z
            for a in range(n):
                x=add(x,gauss(t[b][a]*sg(D[a],s),
                                  pU[b]+pI[a]+pPsi[a]))
            state.append(mul(x,gauss(Q(sg(D[b],s)),0)))
        total=Z
        for bp in range(n):
            for b in range(n):
                total=add(total,mul(mul(conj(state[bp]),
                        gauss(B[bp][b],pP[bp]-pP[b])),state[b]))
        assert total[1]==0 and 0<=total[0]<=1,(L,efftype,s,total)
        assert total[0]==sum((val[0]*sg(z,s) for z,val in fc.items()),Q(0))
    M=max(sum(D[a]^D[b]==z for a in range(n) for b in range(n))
          for z in range(1,size))
    events=[
        lambda a,b,ap,bp:a==ap,lambda a,b,ap,bp:b==bp,
        lambda a,b,ap,bp:a==b,lambda a,b,ap,bp:ap==bp,
        lambda a,b,ap,bp:a==bp,lambda a,b,ap,bp:b==ap]
    for eta in [Q(1,100),Q(1,10),Q(1,2)]:
        H=[i for i in range(1,n) if p[i]>=eta or q[i]>=eta]
        W={0}
        for a in H:W|={z^D[a] for z in tuple(W)}
        for ei,e in enumerate(events):
            group=defaultdict(lambda:Z)
            for a,b,ap,bp,z,c in terms:
                if e(a,b,ap,bp):group[z]=add(group[z],c)
            assert tail(group,W)<=2*M*eta,(L,efftype,eta,ei,tail(group,W),2*M*eta)
        for survivor in range(4):
            group=defaultdict(lambda:Z)
            for a,b,ap,bp,z,c in terms:
                labs=(a,b,ap,bp)
                if z and all(labs) and len(set(labs))==4:
                    if (D[labs[(survivor+1)%4]]^D[labs[(survivor+2)%4]]
                        ^D[labs[(survivor+3)%4]])==0:
                        group[z]=add(group[z],c)
            assert tail(group,W)<=20*M*eta,(L,efftype,eta,survivor)
        print(f'PASS Gaussian-rational L={L} P={efftype} eta={eta} M={M}',
              flush=True)

if __name__=='__main__':
    for L in (1,2):
        for efftype in ('full','projection'):
            check(L,efftype)
    print('PASS exact Gaussian-rational full-rank and high-rank POVM group tests')

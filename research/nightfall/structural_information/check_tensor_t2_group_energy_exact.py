#!/usr/bin/env python3
"""Independent exact-rational two-query high-rank audit, tensor levels L=1,2.

Tests six repeated-slot grouped Fourier bounds, four zero-triple group bounds,
Walsh expansion and conditioning. Finite tests do NOT establish all-L quantum
or tensor-circuit inequalities. No imports from the author's T2 implementation.
"""
from collections import defaultdict
from fractions import Fraction as F
from itertools import product

def mm(A,B):
    return [[sum((A[i][k]*B[k][j] for k in range(len(B))),F(0))
             for j in range(len(B[0]))] for i in range(len(A))]
def tr(A):return list(map(list,zip(*A)))
def eye(n):return [[F(i==j) for j in range(n)] for i in range(n)]
def rotation(n, steps):
    O=eye(n)
    for i,j,sgn in steps:
        R=eye(n);R[i][i]=R[j][j]=F(3,5)
        R[i][j]=F(4*sgn,5);R[j][i]=F(-4*sgn,5)
        O=mm(R,O)
    assert mm(O,tr(O))==eye(n)
    return O
def row(ts):
    p=[0]
    for f in ts:
        p=[2*i+j for i in p for j in ((0,1) if f==3 else (f-1,))]
    return sum(1<<i for i in p)
def sign(z,s):return F(-1 if (z&s).bit_count()%2 else 1)
def norm_tail(vals,W):
    return sum((v*v for z,v in vals.items() if z not in W),F(0))
def check(L):
    D=[0]+[row(t) for t in product((1,2,3),repeat=L)]
    n=len(D);size=2**(2**L)
    Q=rotation(n,[(i,i+1,1 if i%2==0 else -1) for i in range(n-1)])
    U=rotation(n,[(i,i+1,-1 if i%2==0 else 1) for i in range(n-2,-1,-1)])
    V=rotation(n,[(i,i+1,1) for i in range(n-2,-1,-1)])
    P=mm(mm(V,[[F(i==j and i<n-1) for j in range(n)]
                   for i in range(n)]),tr(V))
    assert mm(P,P)==P
    psi=[Q[i][0] for i in range(n)]
    t=[[U[b][a]*psi[a] for a in range(n)] for b in range(n)]
    p=[x*x for x in psi];q=[sum((t[b][a]**2 for a in range(n)),F(0)) for b in range(n)]
    assert sum(p)==sum(q)==1
    fc=defaultdict(F);terms=[]
    for a in range(n):
      for b in range(n):
       for ap in range(n):
        for bp in range(n):
         z=D[a]^D[b]^D[ap]^D[bp]
         c=t[b][a]*P[bp][b]*t[bp][ap]
         fc[z]+=c;terms.append((a,b,ap,bp,z,c))
    f={}
    for s in range(size):
        state=[sign(D[b],s)*sum((t[b][a]*sign(D[a],s) for a in range(n)),F(0))
               for b in range(n)]
        actual=sum((state[i]*P[i][j]*state[j] for i in range(n)
                        for j in range(n)),F(0))
        assert 0<=actual<=1
        assert actual==sum((v*sign(z,s) for z,v in fc.items()),F(0))
        f[s]=actual
    M=max(sum(D[a]^D[b]==z for a in range(n) for b in range(n))
          for z in range(1,size))
    events=[
      lambda a,b,ap,bp:a==ap,lambda a,b,ap,bp:b==bp,
      lambda a,b,ap,bp:a==b,lambda a,b,ap,bp:ap==bp,
      lambda a,b,ap,bp:a==bp,lambda a,b,ap,bp:b==ap]
    for eta in (F(1,1000),F(1,100),F(1,10),F(1,2)):
        heavy=[i for i in range(1,n) if p[i]>=eta or q[i]>=eta]
        W={0}
        for i in heavy:W|={z^D[i] for z in tuple(W)}
        # Direct conditional-expectation Walsh identity.
        classes=defaultdict(list)
        for s in range(size):
            classes[tuple(sign(D[i],s) for i in heavy)].append(s)
        mse=F(0)
        for group in classes.values():
            mean=sum((f[s] for s in group),F(0))/len(group)
            mse+=sum(((f[s]-mean)**2 for s in group),F(0))/size
        assert mse==norm_tail(fc,W)
        # Six equality-event grouped coefficients; source manuscript ≤2Mη.
        for e in events:
            grouped=defaultdict(F)
            for a,b,ap,bp,z,c in terms:
                if e(a,b,ap,bp):grouped[z]+=c
            assert norm_tail(grouped,W)<=2*M*eta
        # Four unique zero-triple survivor locations; ≤(1+2sqrt(3))² Mη <20Mη.
        for survivor in range(4):
            grouped=defaultdict(F)
            for a,b,ap,bp,z,c in terms:
                labs=(a,b,ap,bp)
                if z and all(labs) and len(set(labs))==4:
                    if not (D[labs[(survivor+1)%4]]^D[labs[(survivor+2)%4]]
                            ^D[labs[(survivor+3)%4]]):
                        grouped[z]+=c
            assert norm_tail(grouped,W)<=20*M*eta
        print(f"L={L} rankP={n-1} eta={eta} M={M} Walsh+6equalities+4triples PASS")
if __name__=="__main__":
    check(1);check(2)
    print("PASS: exact finite arbitrary-rank-style audit only; no all-L theorem.")

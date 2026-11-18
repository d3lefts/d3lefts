#!/usr/bin/env python3
"""Exact rational Brownian-bridge/threshold-Gram + full-row cone audit.

Finite facts only. NOT a proof of the missing universal bilinear (R4) gate.
No floating point, SciPy, network, or reliance on guessed ANOVA components.
"""
from fractions import Fraction as Q
from itertools import combinations, product
from math import prod


def determinant(a):
    n=len(a)
    if n==0:return Q(1)
    if n==1:return a[0][0]
    return sum(((-1)**j*a[0][j]*
                determinant([row[:j]+row[j+1:] for row in a[1:]])
                for j in range(n)),Q())


def psd_exact(a):
    n=len(a)
    assert all(a[i][j]==a[j][i] for i in range(n) for j in range(n))
    for size in range(1,n+1):
        for S in combinations(range(n),size):
            sub=[[a[i][j] for j in S] for i in S]
            assert determinant(sub)>=0,('negative principal minor',S,sub)


def bilinear(v,A,w):
    return sum((v[i]*A[i][j]*w[j]
                for i in range(len(v)) for j in range(len(w))),Q())


def matrices(laws, f, label):
    n=len(laws)
    support=[tuple(j for j,p in enumerate(law) if p>0) for law in laws]
    X=tuple(product(*support))
    mu={x:prod(laws[i][x[i]] for i in range(n)) for x in X}
    assert sum(mu.values(),Q())==1
    vals={x:Q(f(x)) for x in X}
    levels=sorted(set(vals.values()))
    m=len(levels)
    assert 2<=m<=7,(label,m,levels,len(X),vals)
    r=[sum((mu[x] for x in X if vals[x]==z),Q()) for z in levels]
    assert all(z>0 for z in r) and sum(r,Q())==1
    h=m-1
    g={(k,x):Q(int(vals[x]>=levels[k+1])) for k in range(h) for x in X}
    p=[sum((mu[x]*g[k,x] for x in X),Q()) for k in range(h)]
    C=[[sum((mu[x]*g[k,x]*g[l,x] for x in X),Q())-p[k]*p[l]
        for l in range(h)] for k in range(h)]
    s=[sum(r[:k+1],Q()) for k in range(h)]
    for k in range(h):
        for l in range(h):
            assert C[k][l]==min(s[k],s[l])-s[k]*s[l]
            assert C[k][l]>=0
    assert determinant(C)>0
    precision=[[Q(0) for _ in range(h)] for _ in range(h)]
    for k in range(h):
        precision[k][k]=1/r[k]+1/r[k+1]
        if k<h-1:
            precision[k][k+1]=precision[k+1][k]=-1/r[k+1]
    for i in range(h):
        for j in range(h):
            value=sum((precision[i][k]*C[k][j] for k in range(h)),Q())
            assert value==Q(int(i==j)),(label,i,j,value)
    psd_exact(C)
    J=[]
    for coord in range(n):
        Jpair=[[Q() for _ in range(h)] for _ in range(h)]
        for x in X:
            for a,pa in enumerate(laws[coord]):
                if not pa:continue
                y=x[:coord]+(a,)+x[coord+1:]
                for k in range(h):
                    dk=g[k,x]-g[k,y]
                    for l in range(h):
                        Jpair[k][l]+=mu[x]*pa*dk*(g[l,x]-g[l,y])/2
        # Independent computation via conditional threshold covariances.
        Jcond=[[Q() for _ in range(h)] for _ in range(h)]
        others=[j for j in range(n) if j!=coord]
        for base in product(*(support[j] for j in others)):
            partial={j:a for j,a in zip(others,base)}
            pminus=prod(laws[j][partial[j]] for j in others)
            mean=[Q() for _ in range(h)]
            second=[[Q() for _ in range(h)] for _ in range(h)]
            for a,pa in enumerate(laws[coord]):
                if not pa:continue
                x=tuple(a if j==coord else partial[j] for j in range(n))
                for k in range(h):
                    mean[k]+=pa*g[k,x]
                    for l in range(h):
                        second[k][l]+=pa*g[k,x]*g[l,x]
            for k in range(h):
                for l in range(h):
                    Jcond[k][l]+=pminus*(second[k][l]-mean[k]*mean[l])
        assert Jpair==Jcond,(label,coord)
        assert all(z>=0 for row in Jpair for z in row)
        psd_exact(Jpair)
        psd_exact([[C[k][l]-Jpair[k][l] for l in range(h)] for k in range(h)])
        J.append(Jpair)
    psd_exact([[sum(Ji[k][l] for Ji in J)-C[k][l]
                for l in range(h)] for k in range(h)])
    for delta in [
        tuple(Q(1) for k in range(h)),
        tuple(Q(k+1,3) for k in range(h)),
        tuple(Q((k+1)**2,5) for k in range(h)),
    ]:
        ff={x:sum((delta[k]*g[k,x] for k in range(h)),Q()) for x in X}
        mean=sum(mu[x]*ff[x] for x in X)
        V=sum(mu[x]*(ff[x]-mean)**2 for x in X)
        assert V==bilinear(delta,C,delta)
        for coord in range(n):
            I=Q()
            for x in X:
                for a,pa in enumerate(laws[coord]):
                    if pa:
                        y=x[:coord]+(a,)+x[coord+1:]
                        I+=mu[x]*pa*(ff[x]-ff[y])**2/2
            assert I==bilinear(delta,J[coord],delta)
    print('PASS',label,'states',len(X),'levels',m,'Brownian-bridge inverse / PSD source sandwich / 3 exact gap energies')
    return X,vals,levels,mu,C,J


def primal_dual_fourbit():
    words=tuple(product((-1,1),repeat=4))
    def f(x):
        a,b,c,d=x
        return Q(-a+b-c-d,2)+Q((a+b)*(c-d),4)
    vals={x:f(x) for x in words}
    levels=sorted(set(vals.values()))
    gaps=[levels[k+1]-levels[k] for k in range(len(levels)-1)]
    assert gaps==[1,1,1,1]
    x=(-1,1,-1,-1)
    targets=[(-1,-1,1,-1),(1,1,-1,1)]
    # Exact dual feasible packing lambda_y1=lambda_y2=1. Disagreement
    # indicator columns are disjoint, so no coordinate's dual load exceeds 1.
    loads=[sum(int(y[i]!=x[i]) for y in targets) for i in range(4)]
    assert loads==[1,1,1,1]
    value=Q()
    for y in targets:
        a=levels.index(vals[x])
        b=levels.index(vals[y])
        crossed=sum((gaps[k] for k in range(min(a,b),max(a,b))),Q())
        assert crossed==abs(vals[x]-vals[y])==3
        value+=crossed
    assert value==6
    print('PASS fourbit true-row LP dual gap gauge at x=(-1,1,-1,-1) value=6, all site loads exactly 1')


if __name__=='__main__':
    fair=[(Q(1,2),Q(1,2))]*4
    def f4(x):
        a,b,c,d=x
        return Q(-a+b-c-d,2)+Q((a+b)*(c-d),4)
    matrices(fair,lambda x:f4(tuple(2*z-1 for z in x)),'fourbit PSI')
    mixed=[
      (Q(0),Q(1,3),Q(2,3)),
      (Q(2,5),Q(3,5)),
      (Q(1,3),Q(1,3),Q(1,3)),
    ]
    matrices(mixed,lambda x: Q(((x[0]+2*x[1]+3*x[2])%5)-2),'mixed categorical with zero atom')
    primal_dual_fourbit()
    # Exact sharp *all-degree-one* negative control for naive entrywise
    # covariance<=conditional-influence claims: global C offdiagonal is
    # strictly positive but each source J_i has ZERO offdiagonals.
    for n in (2,3,4,5):
        laws=[(Q(1,2),Q(1,2))]*n
        X,vals,levels,mu,C,J=matrices(
            laws,lambda x: Q(sum(x)),f'additive fair n={n}')
        assert levels==list(range(n+1))
        ones=tuple(Q(1) for _ in range(n))
        V=bilinear(ones,C,ones)
        infs=[bilinear(ones,Ji,ones) for Ji in J]
        assert V==Q(n,4) and infs==[Q(1,4)]*n
        for k in range(n):
            assert all(Ji[k][k]==Q(__import__('math').comb(n-1,k),4*2**(n-1)) for Ji in J)
            for l in range(n):
                if k!=l:
                    assert C[k][l]>0
                    assert all(Ji[k][l]==0 for Ji in J)
        # Unit global rows certify K<=n; n disjoint singleton demands
        # from the all-zero point force K>=n.
        K=n
        assert Q(4)*V*V==K*K*max(infs)
        assert all(abs(vals[x]-vals[y])<=sum(x[i]!=y[i] for i in range(n))
                   for x in X for y in X)
        zero=tuple(0 for _ in range(n))
        assert all(abs(vals[zero]-vals[zero[:i]+(1,)+zero[i+1:]])==1 for i in range(n))
        print(f'PASS additive n={n}: K*=n, sharp c=4 equality, C dense positive vs J_i strictly diagonal')
    print('SCOPE exact matrix and row-polytope identities, NOT a proof of row bilinear conjecture R4')

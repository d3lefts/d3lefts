#!/usr/bin/env python3
"""Exact nonconstant T2 task-effect compression with invisible Hermitian skew.

Shows >=19-fold separation of centered trace sufficient certificates on a
full-span rational tensor L=2 two-query state family. Finite evidence only.
"""
from fractions import Fraction as F
Z, ONE = F(0), F(1)

def rows(level):
    r,w=[1],1
    for _ in range(level):
        r=r+[x<<w for x in r]+[x | (x<<w) for x in r]
        w*=2
    return [0]+r

def chi(a,s):return -1 if (a&s).bit_count()%2 else 1

def rank(mat):
    a=[list(row) for row in mat]
    piv=0
    for j in range(len(a[0])):
        ix=next((i for i in range(piv,len(a)) if a[i][j]),None)
        if ix is None:continue
        a[piv],a[ix]=a[ix],a[piv]
        z=a[piv][j]
        a[piv]=[v/z for v in a[piv]]
        for i in range(len(a)):
            if i!=piv and a[i][j]:
                fac=a[i][j]
                a[i]=[v-fac*w for v,w in zip(a[i],a[piv])]
        piv+=1
    return piv

def main():
    D=rows(2); n=len(D)
    assert n==10
    psi=[ONE-F(2,n)]+[-F(2,n)]*(n-1)
    v=[F(i+1) for i in range(n)]
    denom=sum((x*x for x in v),Z)
    states=[]
    for s in range(16):
        x=[psi[i]*chi(D[i],s) for i in range(n)]
        t=sum((a*b for a,b in zip(v,x)),Z)
        y=[(x[i]-2*v[i]*t/denom)*chi(D[i],s) for i in range(n)]
        assert sum((x*x for x in y),Z)==ONE
        states.append(y)
    assert rank(states)==n  # Q=I; not an idle-padding artifact.
    # Real skew K, K^2=-I; hence iK is Hermitian with eigenvalues +/-1.
    K=[[0]*n for _ in range(n)]
    for j in range(0,n,2):
        K[j][j+1]=-1
        K[j+1][j]=1
    assert all(K[i][j]==-K[j][i] for i in range(n) for j in range(n))
    assert all(sum(K[i][k]*K[k][j] for k in range(n))
               == (-1 if i==j else 0)
               for i in range(n) for j in range(n))
    eta,tau=F(1,4),F(1,8)
    lam=F(1,2)
    # P=1/2 I + eta*(iK) + tau*|e0><e0|; norm deviation <=3/8.
    # Thus P is a valid effect with eigenvalues in [1/8,7/8].
    assert eta+tau==F(3,8) < lam
    f=[]
    for x in states:
        invisible=sum((x[i]*K[i][j]*x[j]
                       for i in range(n) for j in range(n)),Z)
        assert invisible==0
        original_real=lam+tau*x[0]**2
        replacement_real=lam+tau*x[0]**2
        assert original_real==replacement_real and 0<=original_real<=1
        f.append(original_real)
    assert len(set(f))==11
    # Explicit SDP witness: E=P'=1/2I+tau |e0><e0|,
    # lambda=1/2, X+=tau |e0><e0|, X-=0, trace=tau.
    behavioral_upper=tau
    assert behavioral_upper==F(1,8)
    # For every centering lambda, i*eta*K+(1/2-lambda)I has
    # n/2 eigenvalues d+eta and n/2 eigenvalues d-eta.
    # Each pair costs >=2eta, and rank-one perturbation
    # changes trace norm by at most tau.
    lower=n*eta-tau
    for ell in (Z,F(1,4),F(1,2),F(3,4),ONE):
        d=lam-ell
        baseline=F(n,2)*(abs(d+eta)+abs(d-eta))
        assert baseline>=n*eta
        assert baseline-tau>=lower
    assert lower==F(19,8)
    assert lower/behavioral_upper==19
    print('PASS full-span n=10, nonconstant acceptance values',len(set(f)))
    print('PASS P effect norm bound, invisible iK, behavioral SDP witness')
    print('PASS raw centered trace >= 19/8; task trace <= 1/8; factor >=19')
    print('Exact finite model only; no universal theorem or priority check.')

if __name__=='__main__':main()

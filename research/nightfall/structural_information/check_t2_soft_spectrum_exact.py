#!/usr/bin/env python3
"""Exact spectral-soft-threshold certificate test on full-span T2 circuit.

L=2 tensor R_2, 10 sectors, 16 secrets. Rational Householder
inter-query unitary and dense initial state give span of dimension 10.
This finite replay does not prove the universal T2 theorem.
"""
from fractions import Fraction as F
from collections import Counter
Z, ONE = F(0), F(1)

def rows(level):
    r=[1]; width=1
    for _ in range(level):
        r=r+[x<<width for x in r]+[x | (x<<width) for x in r]
        width *= 2
    return [0]+r

def chi(mask, s):
    return -1 if (mask&s).bit_count() & 1 else 1

def rank(mat):
    r=[list(x) for x in mat]
    nr, nc=len(r),len(r[0]); piv=0
    for j in range(nc):
        k=next((i for i in range(piv,nr) if r[i][j]),None)
        if k is None:continue
        r[piv],r[k]=r[k],r[piv]
        t=r[piv][j]
        r[piv]=[v/t for v in r[piv]]
        for i in range(nr):
            if i!=piv and r[i][j]:
                c=r[i][j]
                r[i]=[u-c*v for u,v in zip(r[i],r[piv])]
        piv+=1
        if piv==nr: break
    return piv

def main():
    D=rows(2); n=len(D)
    assert n==10 and len(set(D))==n
    # H_ones*e0 is rational, normalized, and dense.
    psi=[ONE-F(2,n)]+[-F(2,n)]*(n-1)
    v=[F(i+1) for i in range(n)]
    denom=sum((x*x for x in v),Z)
    assert sum((a*a for a in psi),Z)==1
    states=[]
    for s in range(16):
        x=[a*chi(D[i],s) for i,a in enumerate(psi)]
        t=sum((a*b for a,b in zip(v,x)),Z)
        y=[(x[i]-2*v[i]*t/denom)*chi(D[i],s) for i in range(n)]
        assert sum((z*z for z in y),Z)==1
        states.append(y)
    assert rank(states)==10, 'Attainable states must span full Hilbert space'
    # Five low eigenvalues, four high-bulk, one outlier.
    mu=[F(9,20)]*5+[F(11,20)]*4+[F(9,10)]
    center=F(1,2)
    theta=sum((abs(x-center) for x in mu),Z)
    assert theta==F(17,20)
    # Center at 11/20 and soft-threshold at kappa=1/10.
    lam=F(11,20); kappa=F(1,10)
    soft=[(ONE if x>=lam else -ONE)*max(abs(x-lam)-kappa,Z) for x in mu]
    assert soft==[Z]*9+[F(1,4)]
    soft_trace=sum((abs(x) for x in soft),Z)
    assert soft_trace==F(1,4)
    assert max(abs(x-lam-b) for x,b in zip(mu,soft))==kappa
    assert soft_trace < theta
    eps=F(1,2)
    old_factor=theta/(eps*eps)
    soft_factor=soft_trace/((eps-kappa)**2)
    assert old_factor/soft_factor==F(272,125)
    # Independently evaluate true acceptance and soft approximation.
    full=[]; approximants=[]
    for x in states:
        f=sum((mu[i]*x[i]*x[i] for i in range(n)),Z)
        h=lam+soft_trace*x[9]**2
        assert 0<=f<=1 and 0<=h<=1
        assert abs(f-h)<=kappa
        full.append(f);approximants.append(h)
    assert len(set(full))>1
    # Direct Walsh coefficients of the soft rank-one amplitude.
    coeff={z:sum((states[s][9]*chi(z,s) for s in range(16)),Z)/16
           for z in range(16)}
    for s in range(16):
        assert sum((v*chi(z,s) for z,v in coeff.items()),Z)==states[s][9]
    avg=sum((x[9] for x in states),Z)/16
    mse=sum((soft_trace*(x[9]-avg)**2 for x in states),Z)/16
    assert mse==soft_trace*sum((v*v for z,v in coeff.items() if z!=0),Z)
    assert mse==F(48,5929)
    M=max(Counter(a^b for a in D for b in D if a!=b).values())
    assert M==6
    print('PASS full-span T2 rank=%d, original_theta=%s, soft_trace=%s, '
          'factor=%s, kappa=%s, amplitude_mse=%s, acceptance_values=%d' %
          (rank(states),theta,soft_trace,old_factor/soft_factor,kappa,mse,len(set(full))))
    print('Exact example only; universal spectral-tail theorem requires review.')

if __name__=='__main__':
    main()

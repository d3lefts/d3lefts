#!/usr/bin/env python3
"""Exact finite checks for aggregate-link fourth-moment overlap lemma.

These tests replay *necessary arithmetic*, not a proof or a novelty certificate.
Third party dependencies: none.
"""
from fractions import Fraction as F
from itertools import product
from random import Random


def check_links(B, v, q, M, tag):
    assert B > 0 and M >= 0 and len(v)==len(q)
    V = sum(v, F(0))
    assert all(x>=0 for x in v)
    goodK = max((q0/x**2 for x,q0 in zip(v,q) if x>0), default=F(1))
    assert all(q0>=x**2 for x,q0 in zip(v,q))
    assert all(x<=M for x in v)
    assert V**2 <= goodK*B**2*M, (tag,"regularity inequality false",V,goodK,B,M)
    # Tail decomposition for each integer K, verified without radicals:
    for K in (F(1),F(2),F(3),F(5),F(9),F(81)):
        wbad=sum((x for x,q0 in zip(v,q) if x>0 and q0>K*x*x),F(0))
        assert (V-wbad)**2 <= K*B**2*M, (tag,"tail bound false",K)
    return V,goodK

# Hard dense-overlap Hadamard family, exact moments for n=4^k.
for n in (4,16,64,256):
    v=F(1,n*n)
    q=F(3*n*n-2*n,n**6)
    V,K=check_links(F(1),[v]*n,[q]*n,v,f'Hadamard n={n}')
    assert V==F(1,n) and K==F(3*n-2,n)
    assert V**2==v, 'Hadamard exact variance-squared saturation'
    if n==4:
        # Independent direct 2^n evaluation of a Sylvester-Hadamard row.
        vals=[]
        for signs in product((-1,1),repeat=n):
            vals.append(F(sum(signs),n*2))
        assert sum((x*x for x in vals),F())/len(vals)==v
        assert sum((x**4 for x in vals),F())/len(vals)==q
    print(f'HADAMARD n={n}: V={V}, M={v}, K={K}, exact squared ratio=1')

# Categorical address link family with unbounded kurtosis, but high B/C influences.
for m in (2,3,5,10,25):
    p=F(1,m)
    v=(p*(1-p))**2
    one4=p*(1-p)**4+(1-p)*p**4
    q=one4**2
    B=(2*(1-p))**2   # Exact uniform pointwise ℓ1 norm of output family
    V=m*m*v          # input B/C are each a single categorical coordinate
    M=V              # full-input B and C influences dominate output rows
    VV,K=check_links(B,[v]*(m*m),[q]*(m*m),M,f'Address m={m}')
    assert VV==V
    assert K==((1-p)**3+p**3)**2/(p**2*(1-p)**2)
    print(f'ADDRESS m={m}: V={V}, M={M}, K={K}, amplitude budget={B}')

# Random overlapping 3-partite fair-sign cubics, all exact by enumeration.
rng=Random(20261112)
for trial in range(120):
    na,nb,nc=3,3,3
    coeff={(a,b,c):F(rng.randint(-4,4),7) for a,b,c in product(range(na),range(nb),range(nc))}
    inputs=list(product((-1,1),repeat=nb+nc))
    Q=[]
    for y in inputs:
        b=y[:nb];c=y[nb:]
        Q.append([sum((coeff[a,j,k]*b[j]*c[k] for j in range(nb) for k in range(nc)), F(0)) for a in range(na)])
    B=max(sum(abs(z) for z in vec) for vec in Q)
    if B==0:continue
    v=[sum((vec[a]**2 for vec in Q),F(0))/len(Q) for a in range(na)]
    q=[sum((vec[a]**4 for vec in Q),F(0))/len(Q) for a in range(na)]
    # Influence formula for a full 3-partite fair-sign cubic.
    ia=v
    ib=[sum((coeff[a,j,k]**2 for a in range(na) for k in range(nc)),F(0)) for j in range(nb)]
    ic=[sum((coeff[a,j,k]**2 for a in range(na) for j in range(nb)),F(0)) for k in range(nc)]
    M=max(ia+ib+ic)
    V,K=check_links(B,v,q,M,f'random {trial}')
    assert V==sum((z*z for z in coeff.values()),F(0))
print('PASS: 120 random exact overlapping cubic forms; every K tail threshold')
print('SCOPE: proves no universal large-atom overlap bound; no theorem self-certification')

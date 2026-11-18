#!/usr/bin/env python3
"""Exact finite-dimensional DQ2 audit (stdlib only, not a proof of theorem)."""
from fractions import Fraction as F
from itertools import product, combinations
from random import Random
S = tuple(product((-1,1),repeat=3))

def determinants_psd(A):
    def det(M):
        if len(M)==1:return M[0][0]
        if len(M)==2:return M[0][0]*M[1][1]-M[0][1]*M[1][0]
        return sum((-1)**j*M[0][j]*det([r[:j]+r[j+1:] for r in M[1:]]) for j in range(len(M)))
    return all(det([[A[i][j] for j in idx] for i in idx])>=0
               for k in range(1,4) for idx in combinations(range(3),k))

def test(weights):
    Z=sum(weights);p={x:F(w,Z) for x,w in zip(S,weights)}
    assert all(y>0 for y in p.values())
    def pplus(i,where):
        eligible=[x for x in S if all(x[j]==v for j,v in where.items())]
        return sum(p[x] for x in eligible if x[i]==1)/sum(p[x] for x in eligible)
    cond={};var={}
    for i in range(3):
        for x in S:
            pp=pplus(i,{j:x[j] for j in range(3) if j!=i})
            cond[i,x]=2*pp-1;var[i,x]=4*pp*(1-pp)
    C=[[F(0) for _ in range(3)] for _ in range(3)]
    for i in range(3):
        for j in range(3):
            if i==j:continue
            k=3-i-j
            C[i][j]=max(abs(pplus(i,{j:1,k:t})-pplus(i,{j:-1,k:t})) for t in (-1,1))
    kap=max(sum(row) for row in C)
    if kap>=1:return False,kap
    v=[sum(p[x]*var[i,x] for x in S) for i in range(3)]
    means=[sum(p[x]*x[i] for x in S) for i in range(3)]
    G=[[sum(p[x]*(x[i]-cond[i,x])*(x[j]-cond[j,x]) for x in S) for j in range(3)] for i in range(3)]
    Sigma=[[sum(p[x]*(x[i]-means[i])*(x[j]-means[j]) for x in S) for j in range(3)] for i in range(3)]
    diag=lambda A,i,j:A[i] if i==j else F(0)
    assert determinants_psd([[(1+kap)*diag(v,i,j)-G[i][j] for j in range(3)] for i in range(3)])
    assert determinants_psd([[G[i][j]-(1-kap)*diag(v,i,j) for j in range(3)] for i in range(3)])
    assert determinants_psd([[(1+kap)*Sigma[i][j]-diag(v,i,j) for j in range(3)] for i in range(3)])
    assert determinants_psd([[diag(v,i,j)-(1-kap)*Sigma[i][j] for j in range(3)] for i in range(3)])
    return True,kap

if __name__=='__main__':
    chain=[(2+x[0]*x[1])*(2+x[1]*x[2]) for x in S]
    good,kap=test(chain)
    assert good and kap==F(4,5)
    rng=Random(2702)
    for t in range(12):
        weights=[100+rng.randrange(-t-8,t+9) for _ in S]
        good,kap=test(weights)
        assert good
    print('PASS: 13 rational laws, residual Gram and covariance Loewner checks by exact principal minors')

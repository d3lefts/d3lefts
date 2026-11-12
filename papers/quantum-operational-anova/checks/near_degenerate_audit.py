#!/usr/bin/env python3
"""Independent exact near-degenerate noncommuting 3-qubit audit."""
from itertools import product
from functools import reduce
import sympy as s
n=3
p=[s.Rational(1,3),s.Rational(2,5),s.Rational(3,7)]
b=[s.diag(1-s.Rational(1,2**k),s.Rational(1,2**k)) for k in (8,9,10)]
d=[s.Matrix([[s.Rational(1,8192),s.Rational(1,90)],[s.Rational(1,90),-s.Rational(1,8192)]]),
   s.Matrix([[-s.Rational(1,8192),s.Rational(1,120)],[s.Rational(1,120),s.Rational(1,8192)]]),
   s.Matrix([[s.Rational(1,16384),s.Rational(1,160)],[s.Rational(1,160),-s.Rational(1,16384)]])]
for i in range(n):
    assert b[i]*d[i]!=d[i]*b[i]
    for M in [b[i]+p[i]*d[i],b[i]-(1-p[i])*d[i]]:
        assert M.det()>0 and M[0,0]>0 and s.trace(M)==1
rho=[(b[i]+p[i]*d[i],b[i]-(1-p[i])*d[i]) for i in range(n)]
def kp(a):return reduce(s.kronecker_product,a,s.ones(1,1))
c={1:s.Rational(1,2),2:-s.Rational(1,4),4:s.Rational(2,5),
   3:s.Rational(2,3),5:-s.Rational(1,3),6:s.Rational(3,7),7:s.Rational(1,5)}
var=[x*(1-x) for x in p]
def target(x):
    t=[p[i] if x[i]==0 else -(1-p[i]) for i in range(3)]
    return sum((v*s.prod(t[i] for i in range(3) if mask&(1<<i)) for mask,v in c.items()),s.Integer(0))
def lyap(B,A):
    lam=list(B.diagonal())
    L=s.Matrix(A.rows,A.cols,lambda i,j:s.factor(2*A[i,j]/(lam[i]+lam[j])))
    assert B*L+L*B==2*A
    return L
def gain(mask):
    inds=[i for i in range(3) if mask&(1<<i)]
    if not inds:return s.Integer(0)
    B=kp([b[i] for i in inds]);A=s.zeros(2**len(inds))
    for x in product([0,1],repeat=3):
        wt=s.prod(p[i] if x[i] else 1-p[i] for i in range(3))
        A+=wt*target(x)*kp([rho[i][x[i]] for i in inds])
    return s.factor(s.trace(A*lyap(B,A)))
G={m:gain(m) for m in range(8)}
gamma={}
for mask,v in c.items():
    inds=[i for i in range(3) if mask&(1<<i)]
    B=kp([b[i] for i in inds])
    A=v*s.prod(var[i] for i in inds)*kp([d[i] for i in inds])
    gamma[mask]=s.factor(s.trace(A*lyap(B,A)))
    assert gamma[mask]>0
    assert s.factor(gamma[mask]-sum((-1)**((mask^T).bit_count())*G[T]
                                    for T in range(8) if mask&T==T))==0
assert all(s.factor(G[m]-sum(g for S,g in gamma.items() if m&S==S))==0 for m in range(8))
for i in range(3):
    for A in range(8):
        for B in range(8):
            if (A&B)==A and not B&(1<<i):
                assert G[A|(1<<i)]-G[A] <= G[B|(1<<i)]-G[B]
assert s.prod(bi[0,0]/bi[1,1] for bi in b)==133302015
print("PASS exact near-degenerate noncommuting cases, kappa=133302015, all supports and inequalities")
print("G(full) =",G[7])

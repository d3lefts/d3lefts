#!/usr/bin/env python3
"""Exact audit: three noncommuting locally encoded qubits.
Requires sympy; derives full optimal SLD gains independently of
local Hoeffding component gains with rational Lyapunov residual checks.
"""
from itertools import product
from functools import reduce
import sympy as s

n = 3
ps = [s.Rational(1,3),s.Rational(2,5),s.Rational(3,7)]
bs = [s.diag(s.Rational(3,5),s.Rational(2,5)),
      s.diag(s.Rational(2,3),s.Rational(1,3)),
      s.diag(s.Rational(4,7),s.Rational(3,7))]
ds = [s.Matrix([[s.Rational(1,12),s.Rational(1,9)],[s.Rational(1,9),-s.Rational(1,12)]]),
      s.Matrix([[-s.Rational(1,14),s.Rational(1,11)],[s.Rational(1,11),s.Rational(1,14)]]),
      s.Matrix([[s.Rational(1,15),s.Rational(1,12)],[s.Rational(1,12),-s.Rational(1,15)]])]
rs = [(b+p*d,b-(1-p)*d) for b,p,d in zip(bs,ps,ds)]
for i in range(n):
    assert bs[i]*ds[i] != ds[i]*bs[i]
    assert (1-ps[i])*rs[i][0]+ps[i]*rs[i][1] == bs[i]
    for state in rs[i]:
        assert s.trace(state)==1 and state.det()>0 and state[0,0]>0
coeff = {1:s.Rational(1,3),2:-s.Rational(2,5),4:s.Rational(3,7),
         3:s.Rational(5,9),5:-s.Rational(3,11),6:s.Rational(4,13),
         7:-s.Rational(5,17)}
vs = [p*(1-p) for p in ps]
def kp(mats):
    return reduce(s.kronecker_product,mats,s.ones(1,1))
def eval_f(bits):
    t=[p if not x else -(1-p) for p,x in zip(ps,bits)]
    return sum((c*s.prod(t[i] for i in range(n) if S&(1<<i))
                for S,c in coeff.items()),s.Integer(0))
def direct_A(Q):
    if not Q: return s.zeros(1,1)
    acc=s.zeros(2**len(Q),2**len(Q))
    for bits in product([0,1],repeat=n):
        wt=s.prod((ps[i] if bits[i] else 1-ps[i]) for i in range(n))
        acc += wt*eval_f(bits)*kp([rs[i][bits[i]] for i in Q])
    return acc
def direct_B(Q):
    return kp([bs[i] for i in Q])
def lyap(B,A):
    assert B.is_diagonal()
    lam=list(B.diagonal())
    L=s.Matrix(B.rows,B.cols,lambda i,j:s.cancel(2*A[i,j]/(lam[i]+lam[j])))
    assert B*L+L*B==2*A
    return L
def gain(Q):
    if not Q:return s.Integer(0)
    B,A=direct_B(Q),direct_A(Q)
    L=lyap(B,A)
    v=s.factor(s.trace(B*L*L))
    assert s.factor(v-s.trace(A*L))==0
    return v
def component_gain(S):
    Q=[i for i in range(n) if S&(1<<i)]
    As=coeff[S]*s.prod(vs[i] for i in Q)*kp([ds[i] for i in Q])
    return s.factor(s.trace(As*lyap(direct_B(Q),As)))
G={m:gain([i for i in range(n) if m&(1<<i)]) for m in range(8)}
gamma={S:component_gain(S) for S in coeff}
for S in coeff:
    mob=sum((-1)**((S^T).bit_count())*G[T] for T in range(8) if T&S==T)
    assert s.factor(mob-gamma[S])==0 and gamma[S]>0
for m in range(8):
    assert s.factor(G[m]-sum(v for S,v in gamma.items() if m&S==S))==0
    assert G[m]>=0
for i in range(n):
    for A in range(8):
        if A&(1<<i):continue
        for B in range(8):
            if (B&A)!=A or B&(1<<i):continue
            assert G[A|(1<<i)]-G[A] <= G[B|(1<<i)]-G[B]
V=s.factor(sum(coeff[S]**2*s.prod(vs[i] for i in range(n) if S&(1<<i)) for S in coeff))
assert G[7]<=V
print("PASS exact rational noncommuting SLD, all 8 subset scores, 7 positive supports, all supermodular inequalities")
print("V =",V)
print("G(full) =",G[7])

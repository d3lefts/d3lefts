#!/usr/bin/env python3
"""Rational 3-partite link bookkeeping: A fair, B/C heterogeneous."""
from fractions import Fraction as Q
from itertools import product
from math import prod
A=(0,1); D=(2,3); C=(4,5)
p=[Q(1,2),Q(1,2),Q(1,3),Q(1,4),Q(2,5),Q(3,7)]
coef={(i,j,k): (-1 if (i+2*j+3*k)%3 else 2)
      for i in A for j in D for k in C}
var=lambda i:p[i]*(1-p[i])
links={i:sum((Q(v*v)*var(i)*var(j)*var(k)
     for (a,j,k),v in coef.items() if a==i),Q(0)) for i in A}
V=sum(links.values())
I={i:sum((Q(v*v)*var(a)*var(j)*var(k)
     for (a,j,k),v in coef.items() if i in (a,j,k)),Q(0))
     for i in range(6)}
assert all(links[i]==I[i] for i in A)
W={}
for bc in product((0,1),repeat=4):
    x={D[0]:bc[0],D[1]:bc[1],C[0]:bc[2],C[1]:bc[3]}
    q={i:sum((v*prod(Q(x[t])-p[t] for t in (j,k))
        for (a,j,k),v in coef.items() if a==i),Q(0)) for i in A}
    # Conditional on B,C, f = sum_{i in A} (X_i-1/2)*q_i.
    # Pointwise sup over A = sum_i abs(q_i)/2 = sum_i ||Q_i||_L2(A).
    W[bc]=sum(abs(z) for z in q.values())/2
B=max(W.values())
assert B>0 and all(z<=B for z in W.values())
assert V==sum(I[i] for i in A)
print('PASS: pointwise block-l1 budget, V=sum_A I_a, exact link influences')
print('B=',B,'V=',V,'M=',max(I.values()))
print('LIMIT: finite check cannot certify link-energy conjecture LE(C)')

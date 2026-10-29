#!/usr/bin/env python3
"""Independent exact heterogeneous t_j partial-trace check of sharp two-block theorem."""
from itertools import product
from fractions import Fraction as F
from collections import defaultdict

def Q_aniso(C, ts):
    n=len(ts);result=F(0)
    for mask in range(1<<n):
        removed=[j for j in range(n) if mask>>j&1]
        kept=[j for j in range(n) if not(mask>>j&1)]
        T=F(1)
        for j in removed:T*=-ts[j]
        reduced=defaultdict(lambda:F(0))
        for (a,b),value in C.items():
            if all(a[j]==b[j] for j in removed):
                reduced[(tuple(a[j] for j in kept),tuple(b[j] for j in kept))]+=value
        result+=T*sum(v*v for v in reduced.values())
    return result

for n in range(1,5):
    a=(0,)*n;b=(1,)*n
    witness={(a,a):F(1),(b,b):F((-1)**(n+1))}
    opts=[F(1,4),F(1,3),F(1,2),F(2,3)]
    for shift in range(3):
        ts=[opts[(j+shift)%4] for j in range(n)]
        L=F(1);M=F(1)
        for t in ts:L*=1-t;M*=t
        assert Q_aniso(witness,ts)==2*(L-M)

for ts in [[F(1,4),F(1,3),F(1,2),F(2,3)],[F(3,4),F(1,3),F(1,2),F(2,3)]]:
    n=4;a=(0,)*n;b=(1,)*n
    C={(a,a):F(1),(b,b):F(-1)}
    L=F(1);M=F(1)
    for t in ts:L*=1-t;M*=t
    print('ts=',[str(t) for t in ts],'L=',L,'M=',M,'Q=',Q_aniso(C,ts))
    assert (Q_aniso(C,ts)>=0)==(L>=M)
print('PASS sharp necessary-and-sufficient heterogeneous product threshold in exact partial traces')
# The local-disjointness hypothesis cannot be weakened to global orthogonality.
shared={( (0,0),(0,0) ):F(1),((1,0),(1,0)):F(1)}
ts=[F(3,4),F(1,10)]
assert Q_aniso(shared,ts)==-F(9,10)
assert (1-ts[0])*(1-ts[1]) >= ts[0]*ts[1]
print('PASS local-disjointness scope mutation: n=2 global-orthogonal shared-site Q=-9/10')

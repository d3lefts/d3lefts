#!/usr/bin/env python3
"""Exact dense Hadamard quadratic influence and graph certificate benchmark."""
from fractions import Fraction as Q

def check(k):
    n=4**k
    H=[[1 if (u&v).bit_count()%2==0 else -1 for v in range(n)] for u in range(n)]
    x=[1 if sum(((u>>(2*j))&1)*((u>>(2*j+1))&1) for j in range(k))%2==0
       else -1 for u in range(n)]
    htx=[sum(H[u][v]*x[u] for u in range(n)) for v in range(n)]
    assert all(abs(s)==2**k for s in htx)
    y=[1 if z>0 else -1 for z in htx]
    max_bilinear=sum(x[u]*H[u][v]*y[v] for u in range(n) for v in range(n))
    assert max_bilinear==n*2**k
    for u in range(n):
        for w in range(n):
            assert sum(H[u][v]*H[w][v] for v in range(n))==(n if u==w else 0)
    B=Q(max_bilinear,n*2**k)
    V=Q(n*n,(n*2**k)**2)
    M=Q(n,(n*2**k)**2)
    assert B==1 and V==Q(1,n) and M==Q(1,n*n) and V*V==B*B*M
    kappa=min(a+b+(4*max(n-a,n-b) if a<n and b<n else 0)
              for a in range(n+1) for b in range(n+1))
    assert kappa==n
    return n,B,V,M,kappa

for k in (1,2,3):
    print('PASS:',check(k))
print('SCOPE: exact dense benchmark, not a counterexample to exponent two')

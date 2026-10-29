#!/usr/bin/env python3
"""Independent exact physical-partial-trace and theorem-bound replay, no K/graded routines."""
from fractions import Fraction as F
from collections import defaultdict
from itertools import product
from math import prod
n=4
A=(0,0,0,0);B=(1,1,1,1);C=(2,2,2,0);E=(0,0,0,1);G=(0,0,0,2);D=(2,2,2,2)
u={A:F(1),C:F(1),E:F(1),G:F(1,10)}
v={A:F(1),C:F(1),D:F(1,10)}
X={(a,b):i*j for a,i in u.items() for b,j in v.items()}
Y={(B,B):F(-1)}
Z={**X,**Y}
def reduced(X,mask):
    out=defaultdict(F)
    keep=[k for k in range(n) if not (mask>>k)&1]
    for (a,b),coeff in X.items():
        if all(a[j]==b[j] for j in range(n) if mask>>j&1):
            out[(tuple(a[k] for k in keep),tuple(b[k] for k in keep))]+=coeff
    return out

def form(X):
    t=F(1,2)
    return sum(((-t)**mask.bit_count())*sum(z*z for z in reduced(X,mask).values()) for mask in range(1<<n))

Q=form(Z);QX=form(X);QY=form(Y);cross=Q-QX-QY
assert Q==F(39201,20000),(Q,F(39201,20000))
assert cross==F(-1,4),(cross,QX,QY)
# For every proper partial trace, cross of X,Y is zero (Y reduces to a basis diagonal)
for mask in range((1<<n)-1):
    rx=reduced(X,mask);ry=reduced(Y,mask)
    assert sum(val*ry.get(k,0) for k,val in rx.items())==0,mask
# Orthogonal row or column local support at each of 4 sites
for j in range(n):
    row1={a[j] for a in u};row2={B[j]}
    col1={b[j] for b in v};col2={B[j]}
    assert row1.isdisjoint(row2) or col1.isdisjoint(col2)
assert all({a[j] for a in list(u)+[B]}=={0,1,2} for j in range(n))
assert all({a[j] for a in list(v)+[B]}=={0,1,2} for j in range(n))
# Exact stronger lower: even n, L=M=1/16, z1=2,z2=-1, bound 1/16
traceX=sum(x for (a,b),x in X.items() if a==b)
assert traceX==2
lower=F(1,16)*(traceX-1)**2
assert lower==F(1,16) and Q>lower
# Ambient coordinate negativity: odd rainbow for A,C,B => negative signed Gram eigen
H=lambda a,b:sum(s!=t for s,t in zip(a,b))
assert (H(A,C)+H(A,B)+H(C,B))%2==1
# compute negative sign minimizer on this triple using exact 16 physical partial traces
neg=min((form({(A,A):F(1),(C,C):F(s),(B,B):F(t)}) for s in (-1,1) for t in (-1,1)))
assert neg==F(-3,16),neg
print('PASS: exact Q',Q,'cross',cross,'theorem positive lower',lower,'negative rank3 mutation',neg)
print('PASS: all proper partial traces crossed zero; full local row and column alphabet; rank=2')

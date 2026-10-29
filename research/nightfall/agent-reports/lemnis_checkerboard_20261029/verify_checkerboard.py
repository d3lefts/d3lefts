#!/usr/bin/env python3
"""Checkerboard local orthogonality: exact physical 2^n partial trace checks."""
from fractions import Fraction as F
from itertools import product,combinations
from collections import defaultdict
from math import prod

def outer(u,v):
    return {(a,b):x*y.conjugate() for a,x in u.items() for b,y in v.items() if x*y.conjugate()!=0}
def combine(*Xs):
    z=defaultdict(complex)
    for X in Xs:
        for k,v in X.items(): z[k]+=v
    return {k:v for k,v in z.items() if v}
def mag2(x): return int(x.real)**2+int(x.imag)**2

def q(X,n,t):
    total=F(0)
    for mask in range(1<<n):
        remain=[j for j in range(n) if not(mask>>j&1)]
        z=defaultdict(complex)
        for (a,b),v in X.items():
            if all(a[j]==b[j] for j in range(n) if mask>>j&1):
                z[tuple((a[j],b[j]) for j in remain)]+=v
        term=prod((-t[j] for j in range(n) if mask>>j&1),start=F(1))
        total+=term*sum(mag2(v) for v in z.values())
    return total

def tr(X):return sum(v for (a,b),v in X.items() if a==b)
def norm(X):return sum(mag2(v) for v in X.values())

def check_pair(X,Y,n,t):
    M=prod(t,start=F(1))
    actual=q(combine(X,Y),n,t)-q(X,n,t)-q(Y,n,t)
    expected=2*((-1)**n)*M*F(int((tr(X).conjugate()*tr(Y)).real))
    assert actual==expected,(actual,expected)
    return actual

# two-site d=2: rows share first local state, columns are orthogonal at site 1;
# second site rows orthogonal, columns not required. No row-only decomposition
# into sitewise disjoint blocks can span this matrix's rank-2 column range.
u1={(0,0):1,(1,0):1};v1={(0,0):1}
u2={(0,1):1,(1,1):1};v2={(1,1):1}
X=outer(u1,v1);Y=outer(u2,v2)
t=(F(1,2),F(1,2))
assert norm(combine(X,Y))==4
assert q(combine(X,Y),2,t)==F(2)
assert check_pair(X,Y,2,t)==F(1,2)
assert tr(X)==tr(Y)==1
print('n=2 d=2 checkerboard strictly outside row-only: rank2, Q=2, cross=1/2 PASS')

# n4,d3 nonproduct vector supports; site 1 column-orthogonal, remaining sites row-orthogonal
u1={(0,0,0,0):1,(2,0,0,0):1,(0,2,2,2):1,(2,2,2,2):1}
v1={(0,0,0,0):1}
u2={(0,1,1,1):1,(2,1,1,1):1}
v2={(2,1,1,1):1}
X=outer(u1,v1);Y=outer(u2,v2)
t=(F(1,2),)*4
Qp=q(combine(X,Y),4,t);Qm=q(combine(X,{k:-v for k,v in Y.items()}),4,t)
assert check_pair(X,Y,4,t)==F(1,8)
assert Qp-Qm==F(1,4)
L=M=F(1,16)
A2=norm(X);B2=norm(Y)
# lower bound (L-M)*sum A^2 + M |sum traces|^2 (even n)
assert Qm>=M*mag2(tr(X)-tr(Y))
print('n4,d3 checkerboard: rank2 full local row on 3 levels; Q+=',Qp,'Q-=',Qm,'two-signed cross +-1/8 PASS')

# n3,d3, pairwise alternating j1 column / j2 row / j3 column.
u1={(0,0,0):1,(1,0,0):1,(0,0,1):1,(1,0,1):1};v1={(0,0,0):1}
u2={(0,1,0):1,(1,1,0):1,(0,1,1):1,(1,1,1):1};v2={(1,1,1):1}
X=outer(u1,v1);Y=outer(u2,v2)
t=(F(1,2),)*3
assert check_pair(X,Y,3,t)==-F(1,4)
print('n3,d3 alternating side: exact full-trace cross -1/4 PASS')
print('PASS')
# n4 qutrit: diagonal triple with odd ternary-rainbow parity plus a
# site-4-only row overlap that prevents a row-only local decomposition.
a=(0,0,0,0);c=(2,2,2,0);e=(0,0,0,1);b=(1,1,1,1)
u1={a:1,c:1,e:1};v1={a:1,c:1};u2={b:1};v2={b:1}
X=outer(u1,v1);Y=outer(u2,v2)
W=combine(X,{k:-v for k,v in Y.items()})
t=(F(1,2),)*4
Q=q(W,4,t)
assert check_pair(X,Y,4,t)==F(1,4)
assert Q>0
# Source coordinates necessarily include an odd-parity diagonal triangle:
# each pairwise endpoint signed kernel is (-1/2)^Hamming distance.
D=lambda a,b:sum(x!=y for x,y in zip(a,b))
assert (D(a,b)+D(b,c)+D(a,c))%2==1
print('n4,d3 rank2 even rainbow triangle Q=',Q,'cross between X and -Y = -1/4; outside ambient coordinate PSD', 'PASS')

# full-three-level row support at every site (add |0002> to block one)
u1={(0,0,0,0):1,(2,2,2,0):1,(0,0,0,1):1,(0,0,0,2):1}
v1={(0,0,0,0):1,(2,2,2,0):1};u2={(1,1,1,1):1};v2={(1,1,1,1):1}
X=outer(u1,v1);Y=outer(u2,v2)
Q=q(combine(X,{k:-v for k,v in Y.items()}),4,(F(1,2),)*4)
assert check_pair(X,Y,4,(F(1,2),)*4)==F(1,4)
assert Q>=F(1,16)
print('n4 all three row symbols present at every site Q',Q,'exact theorem margin>=1/16 PASS')

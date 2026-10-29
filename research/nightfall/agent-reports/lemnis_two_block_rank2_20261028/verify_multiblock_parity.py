#!/usr/bin/env python3
"""Direct 2^n partial-trace audit of restricted rank-r parity threshold.
No swap-operator matrix or grading assumptions imported.
"""
from fractions import Fraction as F
from itertools import product
from math import prod
from collections import defaultdict

def q(C,n,t):
    ans=F(0)
    for mask in range(1<<n):
        keep=[j for j in range(n) if not (mask>>j)&1]
        red=defaultdict(complex)
        for (a,b),v in C.items():
            if all(a[j]==b[j] for j in range(n) if (mask>>j)&1):
                red[(tuple(a[j] for j in keep),tuple(b[j] for j in keep))]+=v
        w=prod((-t[j] for j in range(n) if (mask>>j)&1),start=F(1))
        ans+=w*sum(int(z.real)**2+int(z.imag)**2 for z in red.values())
    return ans

def diagonal(n,i,z):
    w=(i,)*n
    return {(w,w):z}

def combine(*blocks):
    out=defaultdict(complex)
    for B in blocks:
        for key,v in B.items():out[key]+=v
    return {key:v for key,v in out.items() if v}

def outer(u,v):
    return {(a,b):x*y.conjugate() for a,x in u.items() for b,y in v.items()}

def trace(B):
    return sum(v for (a,b),v in B.items() if a==b)
def abs2(z):return int(z.real)**2+int(z.imag)**2

for n,r in product(range(1,6),range(2,5)):
    t=[F(1,2)]*n
    L=M=F(1,2**n)
    if n%2:
        C=combine(*(diagonal(n,i,1) for i in range(r)))
        assert q(C,n,t)==r*(L-(r-1)*M)
    else:
        phases=([1,-1] if r==2 else [1,1,-2] if r==3 else [1,-1,1j,-1j])
        C=combine(*(diagonal(n,i,z) for i,z in enumerate(phases)))
        assert q(C,n,t)==0
print("PASS: 20 sharp endpoint tests n=1..5,r=2..4")

for n in (1,3,5):
    C=combine(*(diagonal(n,i,1) for i in range(3)))
    assert q(C,n,[F(1,2)]*n)==-F(3,2**n)
print("PASS: odd-n rank-3 negative values -3/2,-3/8,-3/32")

for n in (2,4):
    Cs=[diagonal(n,i,z) for i,z in enumerate((1,1,-2))]
    t=[F(11,20)]*n
    L=F(9,20)**n;M=F(11,20)**n
    assert q(combine(*Cs),n,t)==6*(L-M)<0
print("PASS: strict even-n rank-3 negative examples above t=1/2")

for n in (2,3):
    t=[F(2,5),F(1,2)] if n==2 else [F(2,5),F(1,2),F(1,3)]
    first=(0,)*n;second=(1,)*n
    mixed=(0,1) if n==2 else (0,1,0)
    alt=(1,0) if n==2 else (1,0,0)
    u={first:1,second:1j,mixed:2}
    v={first:1,second:2,alt:1j}
    blocks=[outer(u,v),diagonal(n,2,1),diagonal(n,3,-1)]
    C=combine(*blocks)
    M=prod(t,start=F(1))
    taus=[trace(B) for B in blocks]
    cross=q(C,n,t)-sum(q(B,n,t) for B in blocks)
    target=(-1)**n*M*(abs2(sum(taus))-sum(abs2(z) for z in taus))
    assert cross==target,(n,cross,target)
    A_sq=[sum(abs2(z) for z in u.values())*sum(abs2(z) for z in v.values()),1,1]
    L=prod((1-z for z in t),start=F(1))
    if n%2:
        bound=(L-2*M)*sum(A_sq)
    else:
        bound=(L-M)*sum(A_sq)+M*abs2(sum(taus))
    assert q(C,n,t)>=bound,(n,q(C,n,t),bound)
print("PASS: independent complex exact cross identity and heterogeneous bounds")

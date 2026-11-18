#!/usr/bin/env python3
"""Exact rational attack against an OPEN source-coupled linear-degree annealed-Q2 gate.

PASS means the sampled cases do not refute C=1; it does not establish it.
Run: python3 -I research/nightfall/flagship-influence/check_poly_d_proxy_gate_stress.py
"""
from fractions import Fraction as F
from math import comb
from random import Random


def pop(k): return k.bit_count()


def transform(a):
    a = list(a)
    t = 1
    while t < len(a):
        for i in range(0, len(a), 2*t):
            for j in range(t):
                p,q = a[i+j], a[i+j+t]
                a[i+j],a[i+j+t] = p+q,p-q
        t *= 2
    return a


def from_values(vals):
    return transform(vals)


def amp(n,coeff):
    N=1<<n
    ans=0
    for live in range(N):
        h=[v if 1<=pop(s&live)<=2 else 0 for s,v in enumerate(coeff)]
        ans=max(ans,max(map(abs,transform(h))))
    return ans


def score(n,d,coeff):
    assert len(coeff)==1<<n and all(v==0 or pop(s)<=d for s,v in enumerate(coeff))
    m=max(1,(d-1).bit_length())
    U=F(0);Js=[F(0)]*n
    for s,a in enumerate(coeff):
        order=pop(s)
        if not order or not a:continue
        uw,jw=F(0),F(0)
        for k in range(1,m+1):
            t=F(1,2**k)
            uw += (order*t*(1-t)**(order-1) + (comb(order,2)*t*t*(1-t)**(order-2) if order>=2 else 0))/m
            jw += (t*(1-t)**(order-1) + ((order-1)*t*t*(1-t)**(order-2) if order>=2 else 0))/m
        U+=a*a*uw
        for i in range(n):
            if s&(1<<i):Js[i]+=a*a*jw
    if not U:return F(0)
    A=amp(n,coeff)
    return U**2/(d*A*A*max(Js))


def selector(n=6):
    assert n==6
    return from_values([2*((x>>(2+((x&1)+2*((x>>1)&1))))&1)-1 for x in range(1<<n)])


def tribes(n=6):
    return from_values([int(any((x>>(2*b))&3==3 for b in range(n//2))) for x in range(1<<n)])


def cheb(n,d):
    vals=[]
    for x in range(1<<n):
        t=F(2*pop(x)-n,n)
        if d==0: y=F(1)
        elif d==1: y=t
        else:
            u,v=F(1),t
            for k in range(2,d+1):u,v=v,2*t*v-u
            y=v
        vals.append(int(y*n**d))
    return from_values(vals)


if __name__=='__main__':
    n=6;N=1<<n
    families=[('additive',1,[0]+[1 if pop(s)==1 else 0 for s in range(1,N)]),
              ('parity2',2,[1 if s==3 else 0 for s in range(N)]),
              ('parity6',6,[1 if s==63 else 0 for s in range(N)]),
              ('selector',3,selector()),('tribes',6,tribes())]
    families += [(f'chebyshev{d}',d,cheb(n,d)) for d in range(2,7)]
    rng=Random(20261118)
    for j in range(100):
        d=rng.randrange(2,7)
        candidates=[s for s in range(1,N) if pop(s)<=d]
        picked=rng.sample(candidates,rng.randrange(3,min(20,len(candidates))+1))
        a=[0]*N
        for s in picked:a[s]=rng.choice((-3,-2,-1,1,2,3))
        families.append((f'random{j}',d,a))
    best=(F(0),None)
    for name,d,coeff in families:
        r=score(n,d,coeff)
        if r>best[0]:best=(r,name)
        if name in ('additive','parity2','parity6','selector','tribes'):
            print(name,'d=',d,'exact C_required=',r,'decimal=',float(r))
    print('max of',len(families),'models:',best,'~',float(best[0]))
    assert best[0]<=1, 'Exact counterexample to experimental C=1 gate; investigate'
    print('PASS finite attack; linear-degree source-coupled gate remains OPEN')

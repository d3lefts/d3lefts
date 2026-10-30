#!/usr/bin/env python3
"""Standalone exact F_(p^2) audit, p in {3,5}; no third-party packages."""
from itertools import product
from hashlib import sha256
import json

def verify(p, nonsquare=2):
    assert p in (3, 5)
    vals = range(p*p)
    def pair(z): return z % p, z // p
    def encode(a,b): return a % p + p*(b % p)
    def add(x,y):
        a,b=pair(x); c,d=pair(y)
        return encode(a+c,b+d)
    def mul(x,y):
        a,b=pair(x); c,d=pair(y)
        return encode(a*c+nonsquare*b*d,a*d+b*c)
    def power(x,n):
        y=1
        for _ in range(n): y=mul(y,x)
        return y
    n=p-1
    def signature(x,y):
        sx,sy=power(x,n),power(y,n)
        c=p if sx==sy and sx != 0 else 1
        return sx,sy,power(add(x,mul(c,y)),n)
    def canonical(x,y):
        return min((mul(w,x),mul(w,y)) for w in range(1,p))
    seen={}
    for x,y in product(vals,repeat=2):
        out=signature(x,y)
        orb=canonical(x,y)
        if out in seen:
            assert seen[out]==orb, (p,seen[out],orb,out)
        seen[out]=orb
    distinct_orbits={canonical(x,y) for x,y in product(vals,repeat=2)}
    assert len(seen)==len(distinct_orbits)==1+(p**4-1)//(p-1)
    A=1+(p*p-1)//(p-1)
    assert A*A<len(distinct_orbits)
    return dict(p=p,q=p*p,power=n,orbits=len(distinct_orbits),
        signatures=len(seen),two_query_capacity=A*A,collisions=0,minimum_queries=3)

if __name__=='__main__':
    print(json.dumps([verify(3),verify(5)],indent=2))

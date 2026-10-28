#!/usr/bin/env python3
"""Third arithmetic model: degree-2 extensions F_{p^2}, p in {3,5,7}.
Checks all nonzero k=2 signals for p=3 and selected p=7; supports p=5 cross-check.
"""
from itertools import product
import json

def field(p):
    squares={x*x%p for x in range(p)}
    d=next(a for a in range(2,p) if a not in squares)
    vals=[(a,b) for a in range(p) for b in range(p)]
    def add(x,y):return ((x[0]+y[0])%p,(x[1]+y[1])%p)
    def mul(x,y):return ((x[0]*y[0]+d*x[1]*y[1])%p,(x[0]*y[1]+x[1]*y[0])%p)
    def power(x,n):
        ans=(1,0)
        while n:
            if n&1:ans=mul(ans,x)
            x=mul(x,x);n//=2
        return ans
    inv={x:power(x,p*p-2) for x in vals if x!=(0,0)}
    return vals,add,mul,power,inv,d

def run(p,exhaustive):
    V,add,mul,power,inv,d=field(p)
    zero=(0,0);q=p*p
    def rank(rows):
        pivots={}
        for input_row in rows:
            r=list(input_row)
            for j,b in sorted(pivots.items()):
                c=r[j]
                if c!=zero:
                    r=[add(z,mul(((p-c[0])%p,(p-c[1])%p),b_i)) for z,b_i in zip(r,b)]
            j=next((j for j,v in enumerate(r) if v!=zero),None)
            if j is not None:
                factor=inv[r[j]]
                pivots[j]=[mul(factor,v) for v in r]
        return len(pivots)
    def dot(a,b):return add(mul(a[0],b[0]),mul(a[1],b[1]))
    def feature(a,x):
        t=dot(a,x);y=power(t,p-1)
        return [power(a[0],p),power(a[1],p),mul(((p-y[0])%p,(p-y[1])%p),a[0]),mul(((p-y[0])%p,(p-y[1])%p),a[1])]
    import random
    rng=random.Random(20261028+p)
    xs=list(product(V,repeat=2)) if exhaustive else [(V[rng.randrange(q)],V[rng.randrange(q)]) for _ in range(30)]
    rows=list(product(V,repeat=2)) if exhaustive else list(product(V,repeat=2))
    good=0
    for x in xs:
        if x==(zero,zero):continue
        assert rank(feature(a,x) for a in rows)==3,x
        good+=1
    return {'prime':p,'field_size':q,'quadratic_nonsquare':d,'tested_nonzero_signals':good,'sensing_rows':len(rows),'rank':3}

if __name__=='__main__':
    print(json.dumps({'status':'PASS','cases':[run(3,True),run(5,False),run(7,False)]},indent=2))

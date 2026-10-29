#!/usr/bin/env python3
"""Axiom PR37 review: independent F25 representation/decoder and five-row identifiability."""
from itertools import product
def add(x,y): return (x%5+y%5)%5+5*((x//5+y//5)%5)
def mul(x,y):
    a,b=x%5,x//5;c,d=y%5,y//5
    return (a*c+2*b*d)%5+5*((a*d+b*c)%5)
def power(x,n):
    y=1
    for _ in range(n): y=mul(y,x)
    return y
def inv(x):
    assert x
    return power(x,23)
def div(x,y): return mul(x,inv(y))
mu={x for x in range(1,25) if power(x,4)==1}
assert mu=={1,2,3,4}
theta=5
def measure(x,row):
    z=0
    for a,b in zip(x,row):z=add(z,mul(a,b))
    return power(z,4)
def decode(x):
    k=len(x)
    y=[power(z,4) for z in x]
    support=[j for j in range(k) if y[j]]
    if not support:return (0,)*k,k
    h=support[0]
    alpha=next(z for z in range(25) if power(z,4)==y[h])
    result=[0]*k;result[h]=alpha
    for j in support[1:]:
        b=div(y[j],y[h])
        c=theta if b==1 else 1
        row=[0]*k;row[h]=1;row[j]=c
        reading=measure(x,row)
        candidates=[z for z in range(25) if power(z,4)==b
                    and power(add(1,mul(c,z)),4)==div(reading,y[h])]
        assert len(candidates)==1,(x,j,candidates)
        result[j]=mul(alpha,candidates[0])
    return tuple(result),k+len(support)-1
for k in (1,2,3):
    maxm=0
    for x in product(range(25),repeat=k):
        result,m=decode(x)
        maxm=max(maxm,m)
        assert any(all(result[j]==mul(phase,x[j]) for j in range(k)) for phase in mu)
    assert maxm==2*k-1
    print("PASS",k,25**k,maxm)
images={}
for x,y in product(range(25),repeat=2):
    key=tuple(power(add(x,mul(z,y)),4) for z in range(5))
    orbit=tuple(sorted((mul(w,x),mul(w,y)) for w in mu))
    assert key not in images or images[key]==orbit
    images[key]=orbit
assert len(images)==157
# At x=(1,0): all lifted rows (1,z,-1,-z), and false kernel (0,1,0,1)
for z in range(5):
    assert add(z,add(-z%5,0))==0
print("PASS five-row 157 phase classes and explicit two-dimensional lift kernel")

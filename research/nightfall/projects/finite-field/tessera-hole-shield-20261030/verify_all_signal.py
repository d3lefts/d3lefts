#!/usr/bin/env python3
"""Same-oracle full-support and sparse GF(13^3) decoder, independent of seed checker."""
from itertools import product
from random import Random
p=13;q=p**3;Z=(0,0,0);I=(1,0,0)
def add(x,y):return tuple((a+b)%p for a,b in zip(x,y))
def negative(x):return tuple(-a%p for a in x)
def mul(x,y):
    z=[0]*5
    for i in range(3):
        for j in range(3):z[i+j]=(z[i+j]+x[i]*y[j])%p
    z[0]=(z[0]+2*z[3])%p
    z[1]=(z[1]+2*z[4])%p
    return tuple(z[:3])
def exponent(x,n):
    res=I
    while n:
        if n&1:res=mul(res,x)
        x=mul(x,x);n>>=1
    return res
def inverse(x):
    assert x!=Z
    a=exponent(x,q-2)
    assert mul(a,x)==I
    return a
w=((1,0,0),(2,0,0),(0,1,0),(0,2,0),(7,5,0),(12,5,0),
   (0,0,1),(0,0,2),(0,0,4))
a=[mul((7,0,0),v) for v in w]
a0=(10,2,0)
for v in a:a0=add(a0,v)
field=list(product(range(p),repeat=3))
roots={}
for x in field:roots.setdefault(mul(x,x),x)
assert len(roots)==(q+1)//2
lookup={}
for n in range(1,10):
    intercept=a0
    for j in range(n,9):intercept=add(intercept,a[j])
    tab={}
    for signs in product((-1,1),repeat=n):
        x=intercept
        for sign,coef in zip(signs,a):
            x=add(x,coef if sign==1 else negative(coef))
        result=mul(x,x)
        assert result not in tab
        tab[result]=signs
    assert len(tab)==1<<n
    lookup[n]=(intercept,tab)
def decode(x):
    y=[mul(v,v) for v in x] # exactly 10 paid coordinate-square queries
    support=[i for i,v in enumerate(y) if v!=Z]
    if not support:return [Z]*10,10
    u=[roots[v] for v in y]
    anchor=support[0]
    out=[Z]*10;out[anchor]=u[anchor]
    nqueries=10
    other=support[1:]
    for start in range(0,len(other),9):
        indices=other[start:start+9]
        intercept,table=lookup[len(indices)]
        row={anchor:mul(intercept,inverse(u[anchor]))}
        row.update({j:mul(a[pos],inverse(u[j])) for pos,j in enumerate(indices)})
        z=Z
        for index,coefficient in row.items():z=add(z,mul(coefficient,x[index]))
        response=mul(z,z);nqueries+=1
        signs=table[response]
        for pos,j in enumerate(indices):
            out[j]=u[j] if signs[pos]==1 else negative(u[j])
    assert out==list(x) or out==[negative(v) for v in x]
    return out,nqueries
rng=Random(20261030)
vectors=[[Z]*10]
for j in range(10):
    x=[Z]*10;x[j]=(1,5,7);vectors.append(x)
for n in range(1,11):
    x=[Z]*10
    for j in range(n):x[j]=field[(j*113+17)%q] or I
    vectors.append(x)
for i in range(3500):
    vectors.append([field[rng.randrange(q)] if rng.randrange(10)<(2 if i%2 else 9)
                    else Z for _ in range(10)])
maxcalls=0;supports=set()
for x in vectors:
    _,calls=decode(x)
    assert calls<=11
    maxcalls=max(maxcalls,calls)
    supports.add(sum(z!=Z for z in x))
assert maxcalls==11 and supports==set(range(11))
print("PASS all-signal GF13^3 square-oracle replay",len(vectors),
      "support sizes",sorted(supports),"max legal calls",maxcalls)

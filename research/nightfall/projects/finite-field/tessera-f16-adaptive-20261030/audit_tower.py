#!/usr/bin/env python3
"""Independent F4-quadratic-tower audit, not importing the primary F2 polynomial code."""
from collections import defaultdict
from itertools import combinations,product

def m4(a,b):
    c=0
    for i in range(2):
        for j in range(2):
            if a&(1<<i) and b&(1<<j):c^=1<<(i+j)
    if c&4:c^=7
    return c

def mul(x,y):
    a,b=x&3,x>>2
    c,d=y&3,y>>2
    bd=m4(b,d)
    return (m4(a,c)^m4(2,bd)) | ((m4(a,d)^m4(b,c)^bd)<<2)

def powe(x,n):
    z=1
    while n:
        if n&1:z=mul(z,x)
        x=mul(x,x);n//=2
    return z

assert all(any(mul(x,y)==1 for y in range(1,16)) for x in range(1,16))
roots=[a for a in range(16) if powe(a,4)^a^1==0]
assert len(roots)==4
alpha=roots[0]
def iso(c):
    res=0
    for i in range(4):
        if c&(1<<i):res^=powe(alpha,i)
    return res
I=[iso(i) for i in range(16)]
assert len(set(I))==16
assert set((I[1],I[6],I[7]))=={1,2,3}
assert all(iso(a^b)==iso(a)^iso(b) for a in range(16) for b in range(16))
assert all(iso(a^b)==iso(a)^iso(b) for a in range(16) for b in range(16))
H=(1,2,3)
F=(1,2,3,4)
B={I[0]:(0,0,0,1),I[1]:(1,0,2,8),I[8]:(0,1,4,8),
   I[10]:(0,1,2,4),I[12]:(0,1,8,4),I[15]:(0,1,2,4)}
def query(row,eta):
    y=0
    for a,h in zip(row,eta):y^=mul(I[a],h)
    return powe(y,3)

states=list(product(H,repeat=3))
fibers=defaultdict(list);words={}
for eta in states:
    x=(1,)+eta
    y1=query(F,x)
    assert y1 in B
    y2=query(B[y1],x)
    assert (y1,y2) not in words,(eta,words.get((y1,y2)))
    words[y1,y2]=eta
    fibers[y1].append(eta)
assert len(words)==27
assert sorted(len(v) for v in fibers.values())==[1,5,5,5,5,6]

# Secondary exhaustive checker: orbit equality is tested in a new field basis.
signatures=set()
pairs=list(combinations(range(27),2))
for start in range(4):
    for suffix in product(range(16),repeat=3-start):
        row=(0,)*start+(1,)+suffix
        values=[query(row,(1,)+eta) for eta in states]
        signature=sum(1<<i for i,(x,y) in enumerate(pairs) if values[x]==values[y])
        signatures.add(signature)
assert len(signatures)==439
assert min((a&b).bit_count() for a in signatures for b in signatures)==4

print("PASS independent GF4 quadratic tower: isomorphism, all 27 adaptive outcomes")
print("PASS independent 4369-row / 439-pattern fixed-code obstruction; min=4")
print("Tower alpha",alpha,"full-phase subgroup",I[1],I[6],I[7])

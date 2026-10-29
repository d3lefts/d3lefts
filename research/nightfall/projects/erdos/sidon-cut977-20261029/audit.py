#!/usr/bin/env python3
"""NIGHTFALL exact finite Sidon audit (2026-10-29). Standard library only.
This is a fixed-template optimum, not an asymptotic result or worldwide record.
"""
from collections import defaultdict
from hashlib import sha256
from math import isqrt

p=1009
v=p*p-1
assert all(p%d for d in range(2,isqrt(p)+1))
assert pow(11,(p-1)//2,p)==p-1
def mul(a,b):
    return ((a[0]*b[0]+11*a[1]*b[1])%p,
            (a[0]*b[1]+a[1]*b[0])%p)
def power(a,n):
    r=(1,0)
    while n:
        if n&1:r=mul(r,a)
        a=mul(a,a);n//=2
    return r
theta=(7,1)
assert power(theta,v)==(1,0)
assert all(power(theta,v//f)!=(1,0) for f in (2,3,5,7,101))
source=[]
point=(1,0)
for e in range(v):
    if point[1]==1:source.append(e)
    point=mul(point,theta)
assert point==(1,0) and len(source)==p and source[224]==230092
Q=sorted((s-230092)%v for s in source)
assert Q[0]==0 and len(Q)==1009

# Verify every unordered modular source sum, including diagonals.
mod_sums=set()
for i,a in enumerate(Q):
    for b in Q[i:]:
        z=(a+b)%v
        assert z not in mod_sums
        mod_sums.add(z)
assert len(mod_sums)==509545

prefix=[1,2,4,8,13]
translation=752750
deleted=set((13,15,17,18,28,29,38,43,55,83,85,88,94,127,144,
             387,467,488,516,577,582,589,836,839,845,889,898,907,
             916,921,934,939,940,950,956,958,974))
assert len(deleted)==37
full=prefix+[translation+x for x in Q]
by_sum=defaultdict(list)
for i,a in enumerate(full):
    for j in range(i,len(full)):
        by_sum[a+full[j]].append((i,j))
conflicts=set()
for reps in by_sum.values():
    for i,(a,b) in enumerate(reps):
        for x,y in reps[i+1:]:
            edge=frozenset(z-5 for z in (a,b,x,y) if z>=5)
            assert edge
            conflicts.add(edge)
assert len(conflicts)==57
assert all(edge & deleted for edge in conflicts)

# Disjoint collision hyperedges: each requires a distinct deleted mark.
packing=[
(1,185,956),(3,73,836),(5,154,934),(9,151,940),(13,173,959),
(15,122,913),(16,49,839),(17,71,849),(18,216,1004),(23,48,845),
(24,172,974),(25,83,879),(27,85,885),(28,109,918),(29,160,976),
(31,118,939),(38,62,876),(40,120,950),(41,127,965),(43,112,945),
(45,67,889),(46,97,921),(53,66,898),(55,82,915),(59,80,916),
(68,108,958),(75,144,999),(87,88),(94,105,980),(386,387),
(466,467),(487,488),(515,516),(576,577),(581,582),(588,589),(906,907)]
assert len(packing)==37
seen=set()
for edge in packing:
    e=frozenset(edge)
    assert e in conflicts and not (e & seen)
    seen.update(e)
assert len(deleted)==len(packing)==37

survivors=sorted(prefix+[translation+x for i,x in enumerate(Q) if i not in deleted])
assert len(survivors)==977 and survivors[-1]==1766378
sums=set()
for i,x in enumerate(survivors):
    for y in survivors[i:]:
        z=x+y
        assert z not in sums
        sums.add(z)
assert len(sums)==477753
digest=sha256(''.join(str(n)+'\n' for n in survivors).encode()).hexdigest()
assert digest=='12a705e48f71b1d6a01dae51e560573c7da678a123368cbdb82ed2715b53bed8'
margin=977**2*1794091-974**2*1766378
assert margin==36791472611>0
print('PASS 977 marks; endpoint 1766378; 477753 unique sums')
print('PASS 57 collisions; 37 disjoint blockers; 37 cover (fixed-template optimum)')
print('PASS SHA256',digest,'exact density-margin',margin)

#!/usr/bin/env python3
"""Lemnis independent field/poly/oracle audit of Tessera PR #255.
Uses no producer code. Tests legal-output branching and fixed collision obstruction.
"""
from itertools import product
from collections import Counter
import hashlib

def mul(a,b):
    ans=0
    while b:
        if b&1:ans^=a
        a<<=1
        if a&16:a^=19
        b>>=1
    return ans

def cube(a):return mul(mul(a,a),a)
def lin(row,vec):
    z=0
    for a,b in zip(row,vec,strict=True):z^=mul(a,b)
    return z
H=[a for a in range(1,16) if cube(a)==1]
assert H==[1,6,7]
vs=[(1,)+p for p in product(H,repeat=3)]
first=(1,2,3,4)
branches={0:(0,0,0,1),1:(1,0,2,8),8:(0,1,4,8),10:(0,1,2,4),12:(0,1,8,4),15:(0,1,2,4)}
firstf=Counter(cube(lin(first,v)) for v in vs)
assert dict(sorted(firstf.items()))=={0:1,1:5,8:5,10:6,12:5,15:5},firstf
seen={};rset=[]
for v in vs:
    y=cube(lin(first,v))
    assert y in branches
    z=cube(lin(branches[y],v))
    assert (y,z) not in seen,(v,seen[(y,z)])
    seen[(y,z)]=v
    rset.append((y,z))
assert len(seen)==27
print('PASS F16 27/27 branch transcripts; all second rows selected from only first cube')
# Prove exactly 4369 projective-normalized rows; pair collision bitmasks.
pairs=list(__import__('itertools').combinations(range(27),2))
rows=[]
for pivot in range(4):
    for tail in product(range(16),repeat=3-pivot):
        rows.append((0,)*pivot+(1,)+tail)
assert len(rows)==4369
masks={}
for row in rows:
    vals=[cube(lin(row,v)) for v in vs]
    mask=sum((1<<j) for j,(a,b) in enumerate(pairs) if vals[a]==vals[b])
    masks.setdefault(mask,row)
assert len(masks)==439,len(masks)
# Every pair of distinct normalized masks and itself: include exact 0 row in separate bound.
minimum=352;minimum_rows=None
keys=list(masks)
for i,a in enumerate(keys):
    for b in keys[i:]:
        count=(a&b).bit_count()
        if count<minimum:minimum=count;minimum_rows=masks[a],masks[b]
assert minimum==4,(minimum,minimum_rows)
print('PASS exhaustive 4369 normalized nonzero rows, 439 masks, exact min 4 fixed pair collisions')
print('One exact minimizer:',minimum_rows)
print('All H phases:',H)

# All-signal adaptive decoder, full k4 and all 5461 seven-dimensional phase/support sectors.
from itertools import combinations
ROOTS={cube(a):min(b for b in range(16) if cube(b)==cube(a)) for a in range(16)}
INV={a:next(b for b in range(1,16) if mul(a,b)==1) for a in range(1,16)}
assert len(ROOTS)==6 and set(ROOTS.values()).issubset(range(16))

def solve_signal(x):
    k=len(x);cubes=[]
    for j in range(k):
        row=[0]*k;row[j]=1
        cubes.append(cube(lin(row,x)))
    S=[j for j,y in enumerate(cubes) if y]
    if not S:return (0,)*k,k
    root={j:ROOTS[cubes[j]] for j in S}
    anchor=S[0]
    out=[0]*k;out[anchor]=root[anchor]
    idx=S[1:];query=k
    for start in range(0,len(idx),3):
        block=idx[start:start+3]
        if len(block)==3:
            row=[0]*k
            row[anchor]=mul(first[0],INV[root[anchor]])
            for z,j in enumerate(block): row[j]=mul(first[z+1],INV[root[j]])
            observed=cube(lin(row,x));query+=1
            assert observed in branches
            second=branches[observed]
            row2=[0]*k
            row2[anchor]=mul(second[0],INV[root[anchor]])
            for z,j in enumerate(block):row2[j]=mul(second[z+1],INV[root[j]])
            observed2=cube(lin(row2,x));query+=1
            phases=seen[(observed,observed2)][1:]
            for j,z in zip(block,phases,strict=True):out[j]=mul(z,root[j])
        else:
            # One legal cube query per residual relative H phase.
            for j in block:
                row=[0]*k;row[anchor]=INV[root[anchor]];row[j]=mul(2,INV[root[j]])
                y=cube(lin(row,x));query+=1
                tbl={cube(1 ^ mul(2,z)):z for z in H}
                assert len(tbl)==3
                out[j]=mul(tbl[y],root[j])
    assert query==k+2*((len(S)-1)//3)+((len(S)-1)%3)
    assert any(tuple(mul(h,w) for w in out)==x for h in H),(x,out)
    return tuple(out),query

k4=Counter()
for x in product(range(16),repeat=4):
    _,cost=solve_signal(x)
    k4[cost]+=1
assert k4=={4:61,5:1350,6:64125},k4
print('PASS F16 all 65536 k4 signals',dict(k4))

k7=Counter();reps=0
for s in range(1,8):
    for support in combinations(range(7),s):
        for ph in product(H,repeat=s-1):
            x=[0]*7
            for j,h in zip(support,(1,)+ph,strict=True):x[j]=h
            solve_signal(tuple(x));reps+=1
            k7[s]+=1
assert reps==5461
assert k7=={1:7,2:63,3:315,4:945,5:1701,6:1701,7:729},k7
print('PASS F16 all 5461 k7 support/relative-phase representatives',dict(k7))

#!/usr/bin/env python3
"""Lemnis: independent quadratic-tower exact F16/F4 adaptive decoder audit.
No imports from the construction under review. Python 3 standard library only.
"""
from itertools import product
from collections import defaultdict,Counter

# F4 = F2[w]/(w^2+w+1), encoded a+b*w by a+2*b.
def m4(a,b):
    x,y=a&1,(a>>1)&1
    u,v=b&1,(b>>1)&1
    return (x*u^y*v) | ((x*v^y*u^y*v)<<1)

# K = F4[t]/(t^2+t+w), with t=z, w=z^2+z.
def pair(i):
    a,b,c,d=(i>>j)&1 for j in range(4)
    return a|((c^d)<<1),(b^c^d)|(d<<1)
enc=[pair(i) for i in range(16)]
assert len(set(enc))==16
dec={v:i for i,v in enumerate(enc)}
def mul(a,b):
    x,y=enc[a];z,t=enc[b]
    h=m4(y,t)
    return dec[m4(x,z)^m4(2,h),m4(x,t)^m4(y,z)^h]
M=[[mul(x,y) for y in range(16)] for x in range(16)]
C=[M[M[x][x]][x] for x in range(16)]
H=(1,6,7)
assert [C[h] for h in H]==[1,1,1]
assert sorted(Counter(C).values())==[1,3,3,3,3,3]
INV={x:next(j for j in range(1,16) if M[x][j]==1) for x in range(1,16)}
R={v:min(x for x in range(16) if C[x]==v) for v in set(C)}

A=((14,12,15,3,7),(15,4,9,6,8),(5,5,3,14,6))
def obs(row,x):
    y=0
    for a,b in zip(row,x):y^=M[a][b]
    return C[y]
blocks={}
for eta in product(H,repeat=4):
    out=tuple(obs(row,(1,)+eta) for row in A)
    assert out not in blocks,(out,eta)
    blocks[out]=eta
assert len(blocks)==81
one={C[1^M[2][h]]:h for h in H}
assert len(one)==3

def recover(x):
    k=len(x)
    readings=[C[v] for v in x]
    support=[j for j,v in enumerate(readings) if v]
    if not support:return (0,)*k,k
    rt={j:R[readings[j]] for j in support}
    anchor=support[0]
    reconstructed=[0]*k
    reconstructed[anchor]=rt[anchor]
    n=k
    residual=support[1:]
    for start in range(0,len(residual),4):
        g=residual[start:start+4]
        if len(g)==4:
            values=[]
            for row in A:
                v=M[M[row[0]][INV[rt[anchor]]]][x[anchor]]
                for i,j in enumerate(g):
                    v^=M[M[row[i+1]][INV[rt[j]]]][x[j]]
                values.append(C[v])
                n+=1
            eta=blocks[tuple(values)]
            for j,h in zip(g,eta):reconstructed[j]=M[h][rt[j]]
        else:
            for j in g:
                v=M[INV[rt[anchor]]][x[anchor]]^M[M[2][INV[rt[j]]]][x[j]]
                reconstructed[j]=M[one[C[v]]][rt[j]]
                n+=1
    return tuple(reconstructed),n

by_support=Counter()
max_by_support=defaultdict(int)
nclasses=1
canonical=sorted({min(M[h][a] for h in H) for a in range(1,16)})
assert len(canonical)==5
for anchor in range(5):
    for first in canonical:
        for tail in product(range(16),repeat=4-anchor):
            x=(0,)*anchor+(first,)+tail
            y,queries=recover(x)
            ratio=M[x[anchor]][INV[y[anchor]]]
            assert ratio in H and all(M[ratio][v]==u for u,v in zip(x,y))
            s=sum(v!=0 for v in x)
            by_support[s]+=1
            max_by_support[s]=max(max_by_support[s],queries)
            nclasses+=1
assert nclasses==349526
assert [by_support[s] for s in range(1,6)]==[25,750,11250,84375,253125]
assert [max_by_support[s] for s in range(1,6)]==[5,6,7,8,8]
assert 6**7<nclasses

# Exact projective-pencil test for pair differing in a single phase.
mult=Counter()
for a in range(16):
    for b in range(16):
        x=a^b
        y=a^M[b][6]
        nh=sum(x==M[h][y] for h in H)
        assert (C[x]==C[y])==(nh>0)
        mult[nh]+=1
assert mult=={0:210,1:45,3:1}

bad=((15,15,12,14,1,3,10),(4,2,11,7,9,5,1),
     (11,8,14,14,5,4,0),(14,10,11,5,6,4,15))
outputs=defaultdict(int)
for eta in product(H,repeat=6):
    out=tuple(obs(row,(1,)+eta) for row in bad)
    outputs[out]+=1
assert len(outputs)==570
assert sum(n*(n-1)//2 for n in outputs.values())==174
assert sum(n>1 for n in outputs.values())==144
print("PASS: 81 distinct 3-query phase words")
print("PASS: 349526 global-H classes exhaustively recovered, k5 worst 8")
print("PASS: 6^7 < 349526 exact information bound")
print("PASS: 46/256 projective-pencil one-row collision probability")
print("PASS: failed 4x7 matrix has exactly 174 colliding pairs")
print("UNRESOLVED: 4x7 injective matrix existence and worldwide priority")

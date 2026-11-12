#!/usr/bin/env python3
"""Independent F16 cube-oracle audit (12 Nov 2026), written without reusing NIGHTFALL checker code.

Checks for papers/specialized-complexity/MANUSCRIPT.md: H=F4^x, 6-element cube image, the 81-state
fixed block (20), the 27-state adaptive table, the 1+z*eta remainder code, exhaustive minimum of 4
colliding state-pairs over all pairs of the 4369 normalized fixed rows, and the k=4,5,7 counting
bounds. Finite arithmetic only; it does not certify the all-signal reduction or priority.
Requires numpy. Run: python3 -I research/nightfall/projects/adaptive-finite-field-decoder-2026-10-29/check_f16_independent_20261112.py
"""
import itertools, numpy as np
def mul(a,b):
    r=0
    for i in range(4):
        if b>>i&1: r^=a<<i
    for i in (6,5,4):
        if r>>i&1: r^=0b10011<<(i-4)
    return r
MUL=[[mul(a,b) for b in range(16)] for a in range(16)]
cube=[MUL[MUL[x][x]][x] for x in range(16)]
H=[h for h in range(1,16) if cube[h]==1]; print("H =",H," |image of cube| =",len(set(cube)))
def dot(row,v):
    s=0
    for a,x in zip(row,v): s^=MUL[a][x]
    return s
# 81-state fixed block
A=[[14,12,15,3,7],[15,4,9,6,8],[5,5,3,14,6]]
outs={tuple(cube[dot(r,(1,)+e)] for r in A) for e in itertools.product(H,repeat=4)}
print("81-state fixed block injective:",len(outs)==81)
# 27-state adaptive table
second={0:(0,0,0,1),1:(1,0,2,8),8:(0,1,4,8),10:(0,1,2,4),12:(0,1,8,4),15:(0,1,2,4)}
fib={};tr=set()
for e in itertools.product(H,repeat=3):
    v=(1,)+e; y=cube[dot((1,2,3,4),v)]
    fib[y]=fib.get(y,0)+1
    tr.add((y,cube[dot(second[y],v)]))
print("fiber sizes:",dict(sorted(fib.items()))," distinct transcripts:",len(tr))
# leftover 1+z*eta
print("1+z*eta cubes distinct:",len({cube[1^MUL[2][h]] for h in H})==3)
# fixed-row pairs: 4369 normalized rows, min collisions over 27 states
states=[(1,)+e for e in itertools.product(H,repeat=3)]
rows=[]
for r in itertools.product(range(16),repeat=4):
    nz=[c for c in r if c]
    if nz and nz[0]==1: rows.append(r)
print("normalized rows:",len(rows))
M=np.array([[cube[dot(r,s)] for s in states] for r in rows],dtype=np.int16)  # 4369x27
codes={v:i for i,v in enumerate(sorted(set(cube)))}
M=np.vectorize(codes.get)(M).astype(np.int16)
iu=np.triu_indices(27,1)
EQ=(M[:,iu[0]]==M[:,iu[1]]).astype(np.uint8)  # 4369 x 351 colliding pairs per row
best=10**9
for s in range(0,len(rows),256):
    C=EQ[s:s+256].astype(np.int32)@EQ.T.astype(np.int32)  # pairs colliding in both
    best=min(best,C.min())
print("min colliding state-pairs over all pairs of fixed rows:",best)
# counting lower bounds
for k,n in ((4,6),(5,8),(7,11)):
    S=1+(16**k-1)//3; print(k,"S_k",S,"6^(n-1)<S:",6**(n-1)<S, " upper k+2*floor((k-1)/3)+((k-1)%3):",k+2*((k-1)//3)+((k-1)%3))

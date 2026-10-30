#!/usr/bin/env python3
"""Tessera F16 full-H cubing: exact adaptive phase block + fixed-row obstruction.
No external packages. Proof scope: computationally finite 27-state and 4369-row
certificates, plus algebraic support/anchor decoder; no novelty promotion.
"""
from collections import defaultdict
from itertools import combinations, product
from random import Random

H=(1,6,7)
FIRST=(1,2,3,4)
BRANCH={0:(0,0,0,1),1:(1,0,2,8),8:(0,1,4,8),
        10:(0,1,2,4),12:(0,1,8,4),15:(0,1,2,4)}
OLD=((14,12,15,3,7),(15,4,9,6,8),(5,5,3,14,6))

def mul(a,b):
    r=0
    for i in range(4):
        for j in range(4):
            if a&(1<<i) and b&(1<<j):r ^= 1<<(i+j)
    for i in (6,5,4):
        if r&(1<<i):r ^= 19<<(i-4)
    return r
M=[[mul(a,b) for b in range(16)] for a in range(16)]
C=[M[M[a][a]][a] for a in range(16)]
assert set(x for x in range(16) if C[x]==1)==set(H)
assert len(set(C))==6
def powered(row,v):
    return C[__import__('functools').reduce(
        lambda x,ab:x^M[ab[0]][ab[1]],zip(row,v),0)]

STATES=list(product(H,repeat=3))
first_values=[powered(FIRST,(1,)+e) for e in STATES]
fibers=defaultdict(list)
for i,w in enumerate(first_values):fibers[w].append(i)
assert {w:len(v) for w,v in sorted(fibers.items())}=={0:1,1:5,8:5,10:6,12:5,15:5}
table={}
for i,eta in enumerate(STATES):
    y1=first_values[i]
    y2=powered(BRANCH[y1],(1,)+eta)
    assert (y1,y2) not in table
    table[y1,y2]=eta
assert len(table)==27

def normalized_rows():
    # Any nonzero row can be rescaled to put its first nonzero entry at 1.
    for leading in range(4):
        for suffix in product(range(16),repeat=3-leading):
            yield (0,)*leading+(1,)+suffix

pair_indices=list(combinations(range(27),2))
masks={}
for row in normalized_rows():
    codes=[powered(row,(1,)+e) for e in STATES]
    mask=sum(1<<k for k,(i,j) in enumerate(pair_indices) if codes[i]==codes[j])
    masks.setdefault(mask,row)
assert sum(1 for _ in normalized_rows())==4369
assert len(masks)==439
assert min((a&b).bit_count() for a in masks for b in masks)==4
STATIC=((1,5,1,13),(1,6,3,3))
static_values=[[powered(row,(1,)+eta) for eta in STATES] for row in STATIC]
colliding=[(STATES[i],STATES[j]) for i,j in pair_indices
           if all(v[i]==v[j] for v in static_values)]
assert colliding==[
 ((1,1,6),(6,1,7)),((1,6,7),(6,6,1)),
 ((6,6,6),(6,7,7)),((7,6,7),(7,7,1))]
assert len({(static_values[0][i],static_values[1][i]) for i in range(27)})==23

# Input-power identity control: 2 unpowered linear rows inject 3 phases;
# the original *powered* rows are insufficient.
plain={(M[1][e[0]]^M[2][e[1]],e[2]) for e in STATES}
assert len(plain)==27
assert len({(C[x],C[y]) for x,y in plain})<27

# Original three-query 4-phase block, same cubing oracle.
old={tuple(powered(row,(1,)+eta) for row in OLD)
     for eta in product(H,repeat=4)}
assert len(old)==81
assert 3**5>6**3

roots={v:min(x for x in range(16) if C[x]==v) for v in set(C)}
inverses={x:next(y for y in range(1,16) if M[x][y]==1)
          for x in range(1,16)}
one_phase={powered((1,2),(1,e)):e for e in H}
assert len(one_phase)==3

def recover(x):
    k=len(x); values=[C[v] for v in x]
    support=[i for i,y in enumerate(values) if y]
    if not support:return (0,)*k,k
    u=[roots[y] for y in values]
    anchor=support[0];chosen={anchor:1};queries=k
    def observe(indices,row):
        j=(anchor,)+tuple(indices)
        pre=0
        for t,a in zip(j,row):
            pre^=M[a][M[x[t]][inverses[u[t]]]]
        return C[pre]
    rem=support[1:]
    for offset in range(0,len(rem),3):
        group=rem[offset:offset+3]
        if len(group)==3:
            y1=observe(group,FIRST)
            y2=observe(group,BRANCH[y1])
            queries+=2
            chosen.update(zip(group,table[y1,y2]))
        else:
            for j in group:
                chosen[j]=one_phase[observe((j,),(1,2))]
                queries+=1
    xhat=tuple(M[chosen[i]][u[i]] if i in chosen else 0
               for i in range(k))
    assert any(all(a==M[h][b] for a,b in zip(x,xhat)) for h in H)
    s=len(support)
    assert queries==k+2*((s-1)//3)+(s-1)%3
    return xhat,queries

counts=defaultdict(int)
for x in product(range(16),repeat=4):
    _,n=recover(x);counts[n]+=1
assert dict(counts)=={4:61,5:1350,6:64125}
sectors=0
for s in range(1,8):
    for J in combinations(range(7),s):
        for eta in product(H,repeat=s-1):
            x=[0]*7
            for j,v in zip(J,(1,)+eta):x[j]=v
            assert recover(tuple(x))[1]<=11
            sectors+=1
assert sectors==5461 and recover((0,)*7)[1]==7
R=Random(41539)
for _ in range(12000):
    assert recover(tuple(R.randrange(16) for _ in range(7)))[1]<=11
assert 6**5 < (16**4-1)//3+1 <= 6**6
assert 6**10 < (16**7-1)//3+1 <= 6**11

print("PASS: 27/27 adaptive three-phase transcripts; output fibers 1,5,5,5,5,6")
print("PASS: all 4369 normalized fixed rows / 439 distinct collision patterns")
print("PASS: minimum fixed 2-row collision pairs = 4, attained exactly")
print("PASS: 65536 GF16^4 signals; 5461 7D support/phase states; 12000 full-amplitude cases")
print("PASS: k4 six queries and k7 eleven queries match information lower bounds")

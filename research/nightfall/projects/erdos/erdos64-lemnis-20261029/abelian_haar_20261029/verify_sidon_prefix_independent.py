#!/usr/bin/env python3
"""Independent exact Axiom #49 cross-audit: reconstruct Bose-Chowla exponents and ALL integer pair sums.
No imports from builder, no reliance on claimed solver output. Python standard library only.
"""
from collections import Counter
from hashlib import sha256
from itertools import combinations
from json import dumps
p=1009;mod=p*p-1;shift=776795
A=[1,2,4,8,13]
removed=(1,8,15,18,20,23,24,43,52,55,70,75,87,97,118,122,125,132,133,155,310,312,611,691,712,740,800,806,813,872,914,941,945,962,977,978,979,981,983,988,989,994,1002,1006)
# Enumerate all 1009^2-1 nonzero elements in F1009[u]/(u^2-11) via theta=7+u
alpha,beta=1,0;seen=set();exponents=[]
for e in range(mod):
    assert (alpha,beta) not in seen
    seen.add((alpha,beta))
    if beta==1:exponents.append(e)
    alpha,beta=((7*alpha+11*beta)%p,(alpha+7*beta)%p)
assert (alpha,beta)==(1,0) and len(seen)==mod and len(exponents)==p
assert len(removed)==44 and len(set(removed))==44
B=[shift+v for i,v in enumerate(exponents) if i not in set(removed)]
assert len(B)==965 and max(B)==1794316
assert sha256(dumps(B,separators=(',',':')).encode()).hexdigest()=="27f98a734c11e21bc1392442e055a41f70aa7f435eef91879258ea232cc01234"
S=A+B
pairs={};ct=Counter();diagnostic=Counter()
for i,x in enumerate(S):
    for j in range(i,len(S)):
        y=S[j];total=x+y
        typ=('A' if i<len(A) else 'B')+('A' if j<len(A) else 'B')
        assert total not in pairs,(total,pairs.get(total),(x,y))
        pairs[total]=(x,y,typ)
        ct[typ]+=1
assert len(pairs)==len(S)*(len(S)+1)//2==470935
assert ct=={'AA':15,'AB':4825,'BB':466095},ct
assert 2*len(B)**2-max(S)==68134
assert S[:5]==A

# Stronger finite property: none of the 44 excluded original block marks can
# individually be reinserted into the final 970-mark Sidon set.
blocked=[];cause_counts=Counter()
for i in removed:
    z=shift+exponents[i]
    hit=[]
    for x in S+[z]:
        total=z+x
        if total in pairs:hit.append((total,x,pairs[total]))
    assert hit,(i,z,'reinsertable')
    # the collision witness consists of z+x and an old pair p+q
    total,x,old=hit[0]
    assert z+x==old[0]+old[1]
    blocked.append((i,z,x,old[0],old[1]))
    cause_counts[('A' if x in A else 'B')+old[2]]+=1
assert len(blocked)==44
print('PASS field primitive generator and 1009 Bose-Chowla exponents')
print('PASS B digest, exact 970 marks, every one of 470935 sums distinct')
print('exact pair-type split',dict(ct))
print('PASS all 44 individually excluded marks have an explicit new collision (local inclusion-maximality)')
print('first 6 exclusion certificates (index, new_z, other_x, old_u, old_v):')
for row in blocked[:6]:print(row)
print('witness-type counts',dict(cause_counts))
print('REMOVAL_WITNESS_SHA256',sha256(('\n'.join(','.join(map(str,x)) for x in blocked)+'\n').encode()).hexdigest())

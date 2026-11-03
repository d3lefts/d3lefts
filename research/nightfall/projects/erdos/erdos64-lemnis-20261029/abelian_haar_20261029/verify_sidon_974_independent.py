#!/usr/bin/env python3
"""Independent exact 974-point prefix Sidon audit in the alternate theta polynomial basis.
Uses t^2=14t-38 over F_1009, not the original u^2=11 source implementation.
"""
from hashlib import sha256
from json import dumps
from collections import Counter
p=1009;v=p*p-1;shift=776570
R={28,33,39,41,49,52,54,57,72,78,84,91,98,103,121,176,310,312,611,691,712,740,801,806,813,849,859,868,878,908,943,949,955,961,962,984,991,998,1003,1005}
assert len(R)==40
# Work in F_p[t]/(t^2-14t+38), t=7+u, u^2=11.
a,b=1,0
seen=set();expo=[]
for e in range(v):
    assert (a,b) not in seen,(e,a,b)
    seen.add((a,b))
    if b==1:expo.append(e)
    a,b=((-38*b)%p,(a+14*b)%p)
assert (a,b)==(1,0) and len(seen)==v and len(expo)==p
B=[shift+x for i,x in enumerate(expo) if i not in R]
A=[1,2,4,8,13];assert len(B)==969 and len(B+A)==974 and max(B)==1794091
h=sha256(dumps(B,separators=(',',':')).encode()).hexdigest()
assert h=='5c7d0e030377f9d441dc1e613a20d0902fe14c84cfccf69b63fc8f5f947bef7d'
# Verify modular Sidon source independently of finite prefix.
ms={}
for i,x in enumerate(expo):
    for y in expo[i:]:
        z=(x+y)%v
        assert z not in ms,(z,(x,y),ms.get(z))
        ms[z]=(x,y)
assert len(ms)==509545
D=A+B;S={};cnt=Counter()
for i,x in enumerate(D):
    for j in range(i,len(D)):
        y=D[j];sum_=x+y
        assert sum_ not in S,(sum_,(x,y),S.get(sum_))
        kind=('A' if i<5 else 'B')+('A' if j<5 else 'B')
        S[sum_]=(x,y,kind);cnt[kind]+=1
assert len(S)==474825 and cnt=={'AA':15,'AB':4845,'BB':469965}
assert 974**2*1794316-970**2*1794091==14164303716
# New finite falsifier: all 40 excluded generator positions have an explicit
# overlapping sum with the final set, so each is individually blocked.
witness=[]
for i in sorted(R):
    z=shift+expo[i]
    hits=[(z+x,x,S[z+x]) for x in D+[z] if z+x in S]
    assert hits,(i,z,'reinsertable')
    total,x,(a,b,kind)=hits[0]
    assert total==z+x==a+b
    witness.append((i,z,x,a,b))
assert len(witness)==40
text='\n'.join(','.join(map(str,w)) for w in witness)+'\n'
print('PASS alternate theta-field basis: full 1,018,080 powers, 509,545 modular sums')
print('PASS pinned B digest',h)
print('PASS 974 marks, 474,825 unique integer sums, exact pair split',dict(cnt))
print('PASS squared-density comparison',14164303716)
print('PASS 40 individual restoration collisions, first five:',witness[:5])
print('COLLISION_WITNESS_SHA256',sha256(text.encode()).hexdigest())

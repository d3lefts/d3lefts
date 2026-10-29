#!/usr/bin/env python3
"""Literal unordered pair + old mark support enumeration, independent of differential checker."""
from itertools import combinations,combinations_with_replacement
from collections import Counter
DSETS={7:[0,1,3],13:[0,1,3,9],21:[0,1,4,14,16],31:[0,1,3,8,12,18],57:[0,1,3,13,32,36,43,52],73:[0,1,3,7,15,31,36,54,63],91:[0,1,3,9,27,49,56,61,77,81]}
for v,D in DSETS.items():
 k=len(D)
 count=Counter((a-b)%v for a in D for b in D if a!=b)
 assert len(count)==v-1 and set(count.values())=={1}
 E=[a for a in range(v) if a not in D]
 supports={a:{frozenset((x,y,z)) for x,y in combinations_with_replacement(D,2) for z in D if (x+y-z)%v==a} for a in E}
 assert all(len(s)>0 for s in supports.values())
 vals=[];maxshared=0;minc=10**8;worst=None;maxdiag=0
 for a,b in combinations(E,2):
  common=len(supports[a]&supports[b]);maxshared=max(maxshared,common)
  degree=Counter(t for s in supports[a]|supports[b] for t in s)
  c=sum(1 for t in D if degree[t]>=3)
  if c<minc:minc=c;worst=(a,b)
  assert c>=max(0,(k-6+1)//2),(v,k,a,b,c,(k-6+1)//2)
  vals.append(c)
 print('v',v,'k',k,'pair_count',len(vals),'minimum_high',minc,'maximum_high',max(vals),'shared_max',maxshared,'bound',max(0,(k-6+1)//2),'worst',worst)

# Adversarial controls: diagonal doubletons and incomplete Sidon source.
assert any(len(S)==2 for S in {frozenset((x,y,z)) for x,y in combinations_with_replacement(DSETS[91],2) for z in DSETS[91] if (x+y-z)%91==4})
small={frozenset((x,y,z)) for x,y in combinations_with_replacement((0,1,3),2) for z in (0,1,3) if (x+y-z)%101 in (50,75)}
assert not small
print("PASS: 6894 full outside-batch cases, diagonal and nonperfect controls")

#!/usr/bin/env python3
"""Tessera #125: exact Singer source-switch orientation conservation.
Independent cyclic-arc sweep versus direct unordered differences; stdlib only.
"""
from itertools import combinations
from collections import Counter
from math import gcd
from hashlib import sha256
import json

CASES=[
 (31,(0,1,3,8,12,18),(1,2,4,9,13,19)),
 (57,(0,7,16,21,22,24,34,53),(1,8,17,22,23)),
 (57,(0,7,16,21,22,24,34,53),(1,8,17,22,23,25,35,54)),
 (133,(0,1,3,15,46,71,75,84,94,101,112,128),(1,2,4,8,13))
]
def positive(A):
 ds=[b-a for a,b in combinations(sorted(A),2)]
 assert len(ds)==len(set(ds))
 return tuple(ds)
def source_map(D,v):
 mp={}
 for x in D:
  for y in D:
   if x==y:continue
   d=(x-y)%v
   assert d and d not in mp,'not a perfect difference set'
   mp[d]=(x,y)
 assert len(mp)==v-1
 return mp
def sweep(v,D,ds):
 pairs=source_map(D,v)
 delta=[0]*(v+1)
 for d in ds:
  y=pairs[d][1]
  start=(v-d-y)%v
  end=start+d
  if end<=v:
   delta[start]+=1;delta[end]-=1
  else:
   delta[start]+=1;delta[v]-=1
   delta[0]+=1;delta[end-v]-=1
 bad=0;out=[]
 for c in range(v):
  bad+=delta[c]
  out.append(len(ds)-bad)
 return tuple(out)
def direct(v,D,ds):
 target=set(ds)
 result=[]
 for c in range(v):
  Q=sorted((x+c)%v for x in D)
  differences={b-a for a,b in combinations(Q,2)}
  assert len(differences)==len(Q)*(len(Q)-1)//2
  result.append(len(target&differences))
 return tuple(result)
def variance_numerator(v,D,ds):
 pairs=source_map(D,v)
 arcs=[]
 for d in ds:
  y=pairs[d][1]
  arc={c for c in range(v) if (y+c)%v>=v-d}
  assert len(arc)==d
  arcs.append(arc)
 return v*sum(len(a&b) for a in arcs for b in arcs)-sum(ds)**2
def mincover(K,edges):
 maxind=0
 for mask in range(1<<K):
  if all(not ((mask>>i)&1 and (mask>>j)&1) for i,j in edges):
   maxind=max(maxind,mask.bit_count())
 return K-maxind
def coverbest(v,D,A,u):
 ds=set(positive(A));B=[(u*x)%v for x in D]
 stats=[]
 for c in range(v):
  Q=sorted((b+c)%v for b in B)
  edges=[(i,j) for i,j in combinations(range(len(Q)),2) if Q[j]-Q[i] in ds]
  stats.append((mincover(len(Q),edges),len(edges),c))
 return min(stats),sum(e for _,e,_ in stats)
def main():
 ledger=[]
 for v,D,A in CASES:
  ds=positive(A);units=[u for u in range(1,v) if gcd(u,v)==1]
  target=sum(v-d for d in ds);hist=Counter()
  for u in units:
   source=tuple(u*x%v for x in D)
   a=sweep(v,source,ds)
   b=direct(v,source,ds)
   assert a==b,(v,u,'direct disagreement')
   assert sum(a)==target,(v,u,'first moment')
   assert v*sum(e*e for e in a)-sum(a)**2==variance_numerator(v,source,ds)
   hist.update(a)
  record=dict(v=v,m=len(A),K=len(D),units=len(units),cases=v*len(units),
              mean_num=target,minimum=min(hist),
              histogram=dict(sorted(hist.items())))
  ledger.append(record)
  print('PASS',record)
 v,D,A=CASES[1]
 low,total1=coverbest(v,D,A,1)
 high,total29=coverbest(v,D,A,29)
 assert total1==total29==454
 assert low==(3,4,36) and high==(2,5,45),(low,high)
 print('PASS same mean=454/57 yet best AB/AB cover u=1 is 3; u=29 is 2')
 corrupted=list(D);corrupted[-1]=corrupted[0]
 try:source_map(corrupted,v)
 except AssertionError:pass
 else:raise AssertionError('invalid source accepted')
 print('PASS malformed-source negative control')
 digest=sha256(json.dumps(ledger,sort_keys=True,separators=(',',':')).encode()).hexdigest()
 assert digest=='f07595256d1b8703113070c1da555dc7d691c30ac3bf2c01b7a251aa763fd75a'
 assert sum(z['cases'] for z in ledger)==19398
 print('PASS 19,398 complete affine-source/cut cases, report SHA256',digest)
if __name__=='__main__':main()

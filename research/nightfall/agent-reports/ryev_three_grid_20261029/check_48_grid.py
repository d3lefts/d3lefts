#!/usr/bin/env python3
"""Ryev: independent direct F25 fourth-power and F5 line-formula verification."""
from itertools import combinations_with_replacement
from collections import Counter
import json
P=5
C=tuple((x,y) for x in range(5) for y in range(5))
INV={1:1,2:3,3:2,4:4}
def multiply(x,y):
 a,b=x;c,d=y
 return ((a*c+2*b*d)%5,(a*d+b*c)%5)
def fourth(x):
 s=multiply(x,x)
 return multiply(s,s)
def slope(x):
 a,b=x
 return 0 if x==(0,0) else 6 if a==0 else 1+b*INV[a]%5
OUTPUTS=sorted({fourth(x) for x in C})
assert len(OUTPUTS)==7
ROOT_SLOPE={fourth(x):slope(x) for x in C}
assert len(ROOT_SLOPE)==7
def direct(centers,u,v):
 hist=Counter()
 for c in centers:
  for s in range(1,5):
   for t in range(1,5):
    w=((c[0]+s*u[0]+t*v[0])%5,(c[1]+s*u[1]+t*v[1])%5)
    hist[fourth(w)]+=1
 return {ROOT_SLOPE[q]:hist[q] for q in OUTPUTS}
def closed(centers):
 gen=[(a,b) for a,b in centers if a and b]
 T=len(gen)
 A_x=sum(a==0 and b!=0 for a,b in centers)
 A_y=sum(a!=0 and b==0 for a,b in centers)
 A=A_x+A_y
 Z=sum(a==0 and b==0 for a,b in centers)
 r={0:T,1:3*T+4*A_x,6:3*T+4*A_y}
 for slope_id in range(1,5):
  r[1+slope_id]=2*T+3*A+4*Z+sum(b*INV[a]%5==slope_id for a,b in gen)
 assert sum(r.values())==48
 return r
def run():
 ranks=[("rank2",(1,0),(0,1),9),
        ("rank1_both",(1,0),(1,0),10),
        ("rank1_one",(1,0),(0,0),12),
        ("rank0",(0,0),(0,0),16)]
 result={}
 for name,u,v,expected in ranks:
  minimum=99;where=None;n=0
  for c in combinations_with_replacement(C,3):
   hist=direct(c,u,v)
   assert sum(hist.values())==48
   if name=="rank2":assert hist==closed(c),(c,hist,closed(c))
   maximum=max(hist.values())
   assert maximum>=9,(name,c,hist)
   if maximum<minimum:
    minimum=maximum;where={"centers":c,"counts":hist}
   n+=1
  assert n==2925 and minimum==expected,(name,n,minimum)
  result[name]={"translationMultisets":n,"minimumLargestBucket":minimum,"example":where}
 print(json.dumps({"status":"PASS","field":"F5[u]/(u^2-2)",
   "exactFourthPowerOutputSymbols":len(OUTPUTS),
   "states":48,"universalLargestBucketAtLeast":9,
   "cases":result,
   "scope":"Sharp finite lemma, not an unrestricted 8-query impossibility."},indent=2))
if __name__=="__main__":run()

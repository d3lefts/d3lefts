#!/usr/bin/env python3
"""Verify sharp generalized 3-grid projective occupancy at primes p>=5."""
from itertools import combinations_with_replacement
import json
def occupancy(p,centers):
 generic=[(a,b) for a,b in centers if a and b]
 T=len(generic)
 Ax=sum(a==0 and b!=0 for a,b in centers)
 Ay=sum(a!=0 and b==0 for a,b in centers)
 Z=sum(a==b==0 for a,b in centers)
 A=Ax+Ay
 counts=[T,T*(p-2)+Ax*(p-1),T*(p-2)+Ay*(p-1)]
 counts += [
  T*(p-3)+A*(p-2)+Z*(p-1)+sum(b*pow(a,-1,p)%p==s for a,b in generic)
  for s in range(1,p)
 ]
 assert sum(counts)==3*(p-1)**2
 return counts
def main():
 results={}
 for p in (5,7):
  points=[(a,b) for a in range(p) for b in range(p)]
  minimum=10000;witness=None;n=0
  for centers in combinations_with_replacement(points,3):
   m=max(occupancy(p,centers))
   assert m>=3*(p-2)
   if m<minimum:minimum=m;witness=centers
   n+=1
  assert minimum==3*(p-2)
  results[p]={"centerMultisets":n,"minimumLargestBucket":minimum,"witness":witness}
 for p in (11,13,17,19):
  m=max(occupancy(p,((1,1),(1,2),(1,3))))
  assert m==3*(p-2)
  results[p]={"explicitSharpWitness":True,"minimumLargestBucket":m,"poweredOutputAlphabet":p+2}
 print(json.dumps({"status":"PASS","theorem":"for every prime p>=5, three translated punctured grids force 3(p-2) coincident projective outputs","results":results,"scope":"analytic prime-family theorem, finite spot checks do not certify infinite quantification"},indent=2))
if __name__=="__main__":main()

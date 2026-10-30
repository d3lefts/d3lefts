#!/usr/bin/env python3
"""Separate literal integer-Sidon oracle. Does not import CNF nor residue formula."""
from itertools import combinations
from collections import Counter

def sidon(A):
 sums=[a+b for i,a in enumerate(A) for b in A[i:]]
 return len(sums)==len(set(sums))

def coverage(A,N):
 A=set(A);old={a+b for a in A for b in A}
 blocked=set()
 for x in range(1,N+1):
  if x in A:continue
  if 2*x in old or any(x+a in old for a in A):blocked.add(x)
 return blocked

def direct_counts(A,m):
 A=tuple(A);c=Counter(a%m for a in A)
 mixed=Counter();mid_possible=Counter()
 for i,u in enumerate(A):
  for v in A[i:]:
   for w in A:
    if w not in (u,v):mixed[(u+v-w)%m]+=1
 for i,u in enumerate(A):
  for v in A[i+1:]:
   for t in range(m):
    if (u+v-2*t)%m==0:mid_possible[t]+=1
 return c,mixed,mid_possible

def audit():
 from residue_bounds import residue_capacity
 nc=ns=0
 for N in range(3,15):
  for k in range(2,min(5,N+1)):
   for A in combinations(range(1,N+1),k):
    if not sidon(A):continue
    ns+=1
    sat=len(coverage(A,N))==N-k
    for m in range(2,10):
     nc+=1
     actual,mixed,pair=direct_counts(A,m)
     counts=tuple(actual[t] for t in range(m))
     calc=residue_capacity(counts,N)
     assert [mixed[t] for t in range(m)] == calc['mixed'],('mixed',N,A,m)
     assert [pair[t] for t in range(m)] == calc['midpoint_upper'],('mid',N,A,m)
     if sat:
      assert all(a<=b for a,b in zip(calc['needs'],calc['capacity'])),('SAT rejected',N,A,m)
 fixture=(1,2,4,10,14,37,91,109,154)
 assert sidon(fixture)
 blockers=coverage(fixture,184)
 assert len(blockers)<184-len(fixture)
 c=tuple(sum(a%9==r for a in fixture) for r in range(9))
 assert max(c)==6
 calc=residue_capacity(c,184)
 assert any(a>b for a,b in zip(calc['needs'],calc['capacity']))
 sample=(4,6,7)
 assert sidon(sample) and len(coverage(sample,10))==7
 print(f'PASS independent literal oracle: {ns} Sidon subsets, {nc} modular comparisons, all saturated cases accepted')
 print(f'PASS nine-point SIDON but UNSATURATED fixture: {fixture}, missed={184-9-len(blockers)}')
 print(f'PASS residue profile {c} mod9 violates sectors {[r for r in range(9) if calc["needs"][r]>calc["capacity"][r]]}')
 print('PASS small saturated witness N10 k3',sample)
if __name__=='__main__':audit()

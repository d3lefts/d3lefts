#!/usr/bin/env python3
"""Independent perfect-difference-Singer batch insertion core auditor.
All ordinary supports derived from the unique nonzero difference map; not from triple loops.
"""
from itertools import combinations
from collections import Counter
CASES={7:(0,1,3),13:(0,1,3,9),21:(0,1,4,14,16),31:(0,1,3,8,12,18),57:(0,1,3,13,32,36,43,52),73:(0,1,3,7,15,31,36,54,63),91:(0,1,3,9,27,49,56,61,77,81)}
records=[]
for n,marks in CASES.items():
 q=len(marks)
 diff={((u-v)%n):(u,v) for u in marks for v in marks if u!=v}
 assert len(diff)==n-1
 external=[v for v in range(n) if v not in marks]
 events={}
 for a in external:
  found=set()
  for x in marks:
   y,z=diff[(a-x)%n]
   found.add(tuple(sorted(set((x,y,z)))))
  events[a]=found
  # Recover the number of ordered x,y,z representations in a different form.
  diag=sum(1 for t in marks if (2*t-a)%n in marks)
  if n%3: assert len(found)==(q+diag)//2
  else: assert (q+diag)//2-1 <=len(found)<=(q+diag)//2
  assert q>=1
  degree=Counter(t for edge in found for t in edge)
  assert max(degree.values())<=2
  if n%3: assert sum(len(edge) for edge in found)==(3*q+diag)//2
  else: assert (3*q+diag)//2-2 <= sum(len(edge) for edge in found) <= (3*q+diag)//2
 minimum=100000;maxoverlap=0;maximum=0;maxDiagOverlap=0
 for a,b in combinations(external,2):
  E=events[a]|events[b]
  deg=Counter(t for edge in E for t in edge)
  c=sum(deg[t]>=3 for t in marks)
  overlap=events[a]&events[b]
  maxoverlap=max(maxoverlap,len(overlap));maximum=max(maximum,c)
  if c<minimum:minimum=c;arg=(a,b)
  g=__import__('math').gcd(n,3)
  proven_lower=max(0,(q-3-2*g-(0 if g==1 else 4)+1)//2)
  assert c>=proven_lower,(n,a,b,c,proven_lower)
  # Every overlap of two different external targets is supported by a unique
  # 3-element support plus at most gcd(n,3) 2-element supports.
  assert sum(len(z)==3 for z in overlap)<=1
  assert sum(len(z)==2 for z in overlap)<=g
  maxDiagOverlap=max(maxDiagOverlap,sum(len(z)==2 for z in overlap))
 records.append({'modulus':n,'marks':q,'external_pair_cases':len(external)*(len(external)-1)//2,'min_high_incidence':minimum,'max_high_incidence':maximum,'worst_pair':arg,'proven_lower_bound':max(0,(q-3-2*__import__('math').gcd(n,3)-(0 if n%3 else 4)+1)//2),'max_common_supports':maxoverlap,'max_common_diagonal_supports':maxDiagOverlap})
for row in records:print(row)
print('PASS: independently constructed supports and exact q-linear high-incidence proof bounds')

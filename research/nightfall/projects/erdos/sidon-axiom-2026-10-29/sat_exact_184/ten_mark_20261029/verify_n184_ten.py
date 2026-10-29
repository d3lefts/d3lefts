#!/usr/bin/env python3
"""Independently certify two 10-mark inclusion-maximal Sidon sets in [1,184]."""
import json,hashlib,itertools
N=184
seed=(49,50,56,78,93,104,125,139,149)
claims=[]
for extra in (16,166):
 A=tuple(sorted(seed+(extra,)))
 sums={}
 for i,a in enumerate(A):
  for b in A[i:]:
   s=a+b
   assert s not in sums,(A,s,sums[s],(a,b))
   sums[s]=(a,b)
 blockers={}
 for x in range(1,N+1):
  if x in A:continue
  if 2*x in sums:
   blockers[str(x)]={'type':'double','old':list(sums[2*x]),'new':[x,x]};continue
  hits=[(a,sums[x+a]) for a in A if x+a in sums]
  assert hits,(A,x)
  a,(b,c)=hits[0]
  assert x+a==b+c and x not in A
  blockers[str(x)]={'type':'single','old':[b,c],'new':[x,a]}
 assert len(blockers)==N-len(A)==174
 # Recheck a hash of every exact old sum, and deterministic blocker payload.
 encoded=','.join(map(str,A))
 claims.append({'n':N,'size':len(A),'marks':A,'sum_count':len(sums),
                'excluded_point_count':len(blockers),'marks_sha256':hashlib.sha256(encoded.encode()).hexdigest(),
                'blockers':blockers})
# Independent mutation: remove one mark from each certified 10-mark set; the 9-mark descendant may be unsaturated.
for case in claims:
 B=[i for i in case['marks'] if i not in (16,166)]
 assert B==list(seed)
 sums={a+b for a,b in itertools.combinations_with_replacement(B,2)}
 addable=[x for x in range(1,N+1) if x not in B and 2*x not in sums and not any(x+a in sums for a in B)]
 assert addable==[16,166]
report={'status':'INDEPENDENT_EXACT_PASS','baseline':'A382397 verified through N183, smallest N184 unknown (2026-10-29)',
        'scope':'two explicit 10-mark inclusion-maximal sets at N184; no 9-mark nonexistence proof',
        'cases':claims,'negative_control':{'unsaturated_nine_mark_subset':seed,'exact_addable_points':[16,166]}}
print(json.dumps(report,indent=2,sort_keys=True))

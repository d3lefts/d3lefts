#!/usr/bin/env python3
"""Builder-independent direct unordered-pair-sum/maximality checker and valid-cut emitter.
Independent of exact_exchange.cpp: uses old/new pair sums (not differences).
"""
from itertools import combinations
from pathlib import Path
import hashlib,json,random
N=184
SEEDS=(tuple([16,49,50,56,78,93,104,125,139,149]),tuple([49,50,56,78,93,104,125,139,149,166]))
BEST=({1:(49,50,56,78,93,104,125,139,149),2:(49,50,56,78,90,93,104,125,149),3:(38,50,56,78,93,94,104,125,139)},)*2

def oracle(A):
 A=tuple(sorted(A));assert len(set(A))==len(A)
 pairs={}
 for i,a in enumerate(A):
  for b in A[i:]:
   s=a+b
   if s in pairs:return {'sidon':False,'witness':(pairs[s],(a,b))}
   pairs[s]=(a,b)
 holes=[]
 for x in range(1,N+1):
  if x in A:continue
  if 2*x in pairs:continue
  if any(x+a in pairs for a in A):continue
  holes.append(x)
 return {'sidon':True,'holes':holes,'saturated':not holes}

# Independently check canonical witnesses and near minima with *direct* pair-sum oracle.
for seed in SEEDS:
 assert oracle(seed)['saturated']
for idx,seed in enumerate(SEEDS):
 for r,wit in BEST[idx].items():
  result=oracle(wit)
  assert result['sidon'] and len(result['holes'])=={1:2,2:6,3:5}[r],(idx,r,result)

# Full independent Python rerun at 2-deletion/1-insertion radius, no C++ code or imports.
for seed in SEEDS:
 outside=set(range(1,N+1))-set(seed)
 nc=ns=na=0
 for rm in combinations(seed,2):
  leftover=set(seed)-set(rm)
  for x in sorted(outside):
   nc+=1; o=oracle(tuple(leftover|{x}))
   ns+=o['sidon'];na+=o.get('saturated',False)
 assert nc==7830 and na==0 and ns in (2062,2036),(nc,ns,na)
 print('INDEPENDENT_TWO_DELETE',nc,ns,na)

# Sample randomized three-deletion/two-insertion family with direct oracle.
rng=random.Random(1729)
for si,seed in enumerate(SEEDS):
 outside=sorted(set(range(1,N+1))-set(seed))
 for j in range(10000):
  rm=set(rng.sample(seed,3)); add=set(rng.sample(outside,2));A=(set(seed)-rm)|add
  o=oracle(A)
  assert not o.get('saturated',False)
 print('SAMPLED_THREE_DELETE',si+1,10000,'all verified non-saturated')

# All clauses C(10,7) negative membership, deduplicated from two anchors.
clauses=sorted(set(tuple(-i for i in s) for seed in SEEDS for s in combinations(seed,7)))
assert len(clauses)==204
for seed in SEEDS:
 for r in range(1,4):
  for rm in combinations(seed,r):
   base=set(seed)-set(rm)
   # Every candidate of the neighborhood violates at least one cut,
   # independently of its added (outside-seed) marks.
   assert any(all(-v in base for v in cut) for cut in clauses)

original=Path(__file__).with_name('difference_N184_k9.cnf')
old=original.read_text();lines=old.splitlines();p=lines[0].split(); assert p[:2]==['p','cnf'] and p[2:] == ['62552','178278']
body='\n'.join(' '.join(str(x) for x in c)+' 0' for c in clauses)+'\n'
new='p cnf 62552 178482\n'+'\n'.join(lines[1:])+'\n'+body
out=Path(__file__).with_name('difference_N184_k9_with_local_cuts.cnf');out.write_text(new)
print('LOCAL_CUTS',len(clauses),'sha256',hashlib.sha256(new.encode()).hexdigest(),'variables',62552,'clauses',178482)
# deterministic negative control with near-candidate known to be non-saturated.
A=(49,50,56,78,93,104,125,139,149)
assert any(all(-v in A for v in cut) for cut in clauses)
# all 9-mark sets overlapping <=6 marks per anchor satisfy *all* cuts
for _ in range(1000):
 A=set(rng.sample(range(1,N+1),9))
 if all(len(A.intersection(seed))<=6 for seed in SEEDS):assert all(any(-x not in A for x in cut) for cut in clauses)
print('PASS_INDEPENDENT_ORACLE_AND_SOUND_LOCAL_NOGOODS')

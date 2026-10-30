#!/usr/bin/env python3
"""Independent check of PR62 matching repair using NetworkX graph matching
against exhaustive original pair-sum Sidon testing, all D in Z/vZ for v<=11.
No import of Axiom PR62 builder or checker.
"""
import itertools,networkx as nx,json

def sidon(D,v):
 s=set()
 for i,a in enumerate(D):
  for b in D[i:]:
   z=(a+b)%v
   if z in s:return False
   s.add(z)
 return True

def predicted(D,a,v):
 D=tuple(D)
 pairs={(x+y)%v:(x,y) for i,x in enumerate(D) for y in D[i:]}
 C=set()
 for z in D:
  p=pairs.get((a+z)%v)
  if p is not None:C.add(frozenset((*p,z)))
 special=pairs.get((2*a)%v)
 def cover(uncovered):
  uncovered=set(uncovered);vertices=list(uncovered)
  graph=nx.Graph();graph.add_nodes_from(range(len(vertices)))
  for t in D:
   positions=[j for j,B in enumerate(vertices) if t in B]
   assert len(positions)<=2,(v,D,a,t,positions)
   if len(positions)==2:graph.add_edge(*positions)
  return len(vertices)-len(nx.max_weight_matching(graph,maxcardinality=True))
 if special is None:return cover(C)
 return 1+min(cover([s for s in C if t not in s]) for t in special)

def brute(D,a,v):
 for r in range(len(D)+1):
  for R in itertools.combinations(D,r):
   if sidon([x for x in D if x not in R]+[a],v):return r
 raise AssertionError

num=0;max_card=0
for v in range(3,12):
 for k in range(min(v,5)+1):
  for D in itertools.combinations(range(v),k):
   if not sidon(D,v):continue
   for a in range(v):
    if a in D:continue
    x=predicted(D,a,v);y=brute(D,a,v)
    assert x==y,(v,D,a,x,y)
    num+=1;max_card=max(max_card,k)
D=(0,1,3,9);a=7;v=13
assert sidon(D,v) and predicted(D,a,v)==brute(D,a,v)==2
print(json.dumps({'status':'PASS','independent_modular_cases':num,'max_card':max_card,'exceptional_pair_fixture':'Z13 D={0,1,3,9},a=7 minimum deletions=2'},sort_keys=True))


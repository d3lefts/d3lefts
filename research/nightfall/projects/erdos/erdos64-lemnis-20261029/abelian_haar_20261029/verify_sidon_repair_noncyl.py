#!/usr/bin/env python3
"""Independent one-point Sidon repair audit on noncyclic finite abelian groups.
Derives collision supports and maximum matching from scratch; compares exhaustive deletion oracle.
"""
from itertools import combinations
from functools import lru_cache

def check(G,add):
  tot=0;exceptional=0;duplicated=0
  for size in range(1,min(5,len(G))+1):
    for D in combinations(G,size):
      def sidon(X):
        s=[]
        for i,x in enumerate(X):
          for y in X[i:]:s.append(add(x,y))
        return len(s)==len(set(s))
      if not sidon(D):continue
      mp={add(x,y):(x,y) for i,x in enumerate(D) for y in D[i:]}
      for a in G:
        if a in D:continue
        triples=set()
        for z in D:
          pair=mp.get(add(a,z))
          if pair is not None:triples.add(frozenset((*pair,z)))
        exceptional_pair=mp.get(add(a,a))
        T=list(triples)
        if exceptional_pair is not None:exceptional+=1
        if len(T)<sum(mp.get(add(a,z)) is not None for z in D):duplicated+=1
        incid={v:[i for i,t in enumerate(T) if v in t] for v in D}
        assert all(len(v)<=2 for v in incid.values())
        def matching_cost(forced):
          supports=[t for t in T if forced not in t]
          adj=[set() for _ in supports]
          for x in D:
            if x==forced:continue
            ids=[i for i,t in enumerate(supports) if x in t]
            if len(ids)==2:adj[ids[0]].add(ids[1]);adj[ids[1]].add(ids[0])
          @lru_cache(None)
          def match(mask):
            if not mask:return 0
            u=(mask&-mask).bit_length()-1
            best=match(mask^(1<<u))
            for v in adj[u]:
              if mask>>v&1:best=max(best,1+match(mask^(1<<u)^(1<<v)))
            return best
          return len(supports)-match((1<<len(supports))-1)
        expect=matching_cost(None) if exceptional_pair is None else 1+min(matching_cost(v) for v in exceptional_pair)
        actual=None
        for r in range(len(D)+1):
          for delset in combinations(D,r):
            Y=[x for x in D if x not in delset]+[a]
            if sidon(Y):actual=r;break
          if actual is not None:break
        assert expect==actual,(G,D,a,expect,actual)
        tot+=1
  return tot,exceptional,duplicated
for p in (3,4):
 G=list((x,y) for x in range(p) for y in range(p))
 result=check(G,lambda x,y:((x[0]+y[0])%p,(x[1]+y[1])%p))
 print('Z_%s^2'%p,'PASS cases, exceptional 2a, deduplicated supports',result)

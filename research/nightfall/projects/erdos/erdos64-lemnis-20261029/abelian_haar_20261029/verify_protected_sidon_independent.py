#!/usr/bin/env python3
"""Independent adversarial reconstruction of Vesper PR71 protected Sidon repair.
Uses full old/new pair-sum brute-force for ground truth, separate matching DP for prediction.
"""
from itertools import combinations
from functools import lru_cache
from collections import Counter

def audit(G,add):
    stats=Counter()
    for n in range(1,min(5,len(G))+1):
      for D in combinations(G,n):
        def is_sidon(Y):
          sums=[]
          for i,x in enumerate(Y):
            for y in Y[i:]:sums.append(add(x,y))
          return len(sums)==len(set(sums))
        if not is_sidon(D):continue
        pair={add(x,y):frozenset((x,y)) for i,x in enumerate(D) for y in D[i:]}
        for a in G:
          if a in D:continue
          ordinary=set()
          for z in D:
            hit=pair.get(add(a,z))
            if hit is not None:
              ordinary.add(hit|frozenset((z,)))
          special=pair.get(add(a,a))
          # One old point can have an exceptional 2a hit even in groups with 2-torsion.
          if special is not None:stats['exceptional_inputs']+=1
          n_raw=sum(add(a,z) in pair for z in D)
          if n_raw>len(ordinary):stats['duplicate_support_inputs']+=1
          C=list(ordinary)
          for mask in range(1<<n):
            F=frozenset(D[i] for i in range(n) if mask>>i&1)
            movable=[x for x in D if x not in F]
            best=None
            for q in range(len(movable)+1):
              for gone in combinations(movable,q):
                rest=[x for x in D if x not in gone]
                if is_sidon(rest+[a]):
                  best=q;break
              if best is not None:break
            options=(special & frozenset(movable)) if special is not None else (None,)
            predicts=[]
            for forced in options:
              other=[x for x in movable if x!=forced]
              remaining=[T for T in C if forced not in T]
              m=len(remaining)
              memberships=[{j for j,T in enumerate(remaining) if x in T} for x in other]
              assert all(len(ids)<=2 for ids in memberships)
              if any(not any(j in ids for ids in memberships) for j in range(m)):
                continue
              edges=set()
              for ids in memberships:
                if len(ids)==2:
                  u,v=sorted(ids);edges.add((u,v))
              adj={j:set() for j in range(m)}
              for u,v in edges:
                adj[u].add(v);adj[v].add(u)
              @lru_cache(None)
              def mm(mask):
                if not mask:return 0
                u=(mask&-mask).bit_length()-1
                best=mm(mask ^ (1<<u))
                for v in adj[u]:
                  if mask>>v&1:best=max(best,1+mm(mask^(1<<u)^(1<<v)))
                return best
              predicts.append((1 if forced is not None else 0)+m-mm((1<<m)-1))
            expected=min(predicts) if predicts else None
            assert best==expected,(G,D,a,F,C,special,best,expected)
            stats['cases']+=1
            stats['feasible' if best is not None else 'infeasible']+=1
    return stats
for p in (3,4):
 G=list((x,y) for x in range(p) for y in range(p))
 stats=audit(G,lambda x,y:((x[0]+y[0])%p,(x[1]+y[1])%p))
 print(f'Z_{p}²:',dict(stats))
# explicit Z4 torsion singleton case: D={0}, a=2, protected F={0} impossible.
assert not (len({(0+0)%4,(0+2)%4,(2+2)%4})==3)
print('PASS protected Sidon oracle, noncyclic torsion groups and frozen infeasibility control')

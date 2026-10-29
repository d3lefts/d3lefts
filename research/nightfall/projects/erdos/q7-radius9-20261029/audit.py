#!/usr/bin/env python3
"""Independent exact finite Q7 witness audit and 9-flip local exclusion.
No MILP or external packages. This is not a global f(7) upper-bound proof.
"""
from pathlib import Path
from itertools import combinations, product
from collections import Counter
from hashlib import sha256
P=Path(__file__).with_name('seed_edges.txt')
raw=P.read_bytes()
S={tuple(map(int,line.split())) for line in raw.decode().splitlines()}
V=range(128)
E={(u,v) for u in V for v in range(u+1,128) if (u^v).bit_count()==1}
assert len(E)==448 and len(S)==304 and S<=E
assert raw==''.join(f'{u} {v}\n' for u,v in sorted(S)).encode()
assert sha256(raw).hexdigest()=='b47c7bba3cf07ea8db4b424c1d96e46957049656111ae035166edb19d4739655'
# Enumerate squares from opposite vertex pairs, not coordinate-face indexing.
squares=set()
for u in V:
 for v in range(u+1,128):
  if (u^v).bit_count()!=2:continue
  w,z=[a for a in V if (a^u).bit_count()==1 and (a^v).bit_count()==1]
  squares.add(frozenset((tuple(sorted((u,w))),tuple(sorted((w,v))),tuple(sorted((v,z))),tuple(sorted((z,u))))))
assert len(squares)==672
hist=Counter(len(s&S) for s in squares)
assert hist=={1:36,2:120,3:516}
# Separate path-multiplicity C4 audit.
adj={u:set() for u in V}
for u,v in S:adj[u].add(v);adj[v].add(u)
cherries=Counter((a,b) for w in V for a,b in combinations(sorted(adj[w]),2))
assert max(cherries.values())<=1
M=sorted(E-S)
block={e:[tuple(sorted(q&S)) for q in squares if e in q and len(q&S)==3] for e in M}
assert Counter(map(len,block.values()))=={3:60,4:84}
assert all(not set(a)&set(b) for B in block.values() for a,b in combinations(B,2))
# Every missing edge needs >=3 deletions before it can be inserted.
# For 3 deletions, list every transversal of its three disjoint blockers.
tr3={}
for j,e in enumerate(M):
 if len(block[e])!=3:continue
 for t in product(*block[e]):
  key=tuple(sorted(t));tr3[key]=tr3.get(key,0)|(1<<j)
assert len(tr3)==1576
assert max(m.bit_count() for m in tr3.values())<=3
# For 4 deletions, all possibilities are supersets of tr3 transversals
# or transversals of four disjoint blockers.
tr4={}
for j,e in enumerate(M):
 if len(block[e])!=4:continue
 for t in product(*block[e]):
  key=tuple(sorted(t));tr4[key]=tr4.get(key,0)|(1<<j)
assert len(tr4)==6804
R4=set(tr4)
for tri in tr3:
 for e in S:
  if e not in tri:R4.add(tuple(sorted((*tri,e))))
assert len(R4)==475234
max_unblocked=0
for R in R4:
 mask=tr4.get(R,0)
 for tri in combinations(R,3):mask|=tr3.get(tri,0)
 max_unblocked=max(max_unblocked,mask.bit_count())
assert max_unblocked==3
# Improving 304 to 305 within 9 flips would require 0..4 deletions
# and respectively 1..5 additions. All cases are excluded above.
print('PASS: Q7 448 edges; 672 squares; 304 selected; zero C4; SHA256',sha256(raw).hexdigest())
print('PASS: no >=305 C4-free graph within <=9 edge flips of this seed')
print('EXACT: 1576 three-deletion and 475234 four-deletion relevant sets; max 3 insertions')

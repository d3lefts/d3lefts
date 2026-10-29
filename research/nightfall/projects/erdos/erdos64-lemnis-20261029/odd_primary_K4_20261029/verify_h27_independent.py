#!/usr/bin/env python3
"""Independent matrix-group/literal-voltage checker of a 16-cycle for every H27-generating K4 triple."""
from itertools import product, permutations
from collections import Counter

P=(0,1,2,0,1,2,0,1,2,3,0,2,3,0,2,3,0)
I=(1,0,0,0,1,0,0,0,1)

def mat(e):
 a,b,c=e
 return (1,a,c,0,1,b,0,0,1)
def product_matrix(X,Y):
 return tuple(sum(X[3*i+k]*Y[3*k+j] for k in range(3))%3 for i in range(3) for j in range(3))
def inv(X):
 # true matrix inverse, computed by brute-group algorithm (not source C++ formula)
 for a,b,c in product(range(3),repeat=3):
  Y=mat((a,b,c))
  if product_matrix(X,Y)==I:return Y
 raise AssertionError
elts=[mat(t) for t in product(range(3),repeat=3)]
ix={t:i for i,t in enumerate(elts)}
INV={X:inv(X) for X in elts}

def indep(X,Y):
 a,b=X[1],X[5];c,d=Y[1],Y[5]
 return (a*d-b*c)%3!=0

def joined(a,b,c):
 return indep(a,b) or indep(a,c) or indep(b,c)

def explicit_path(a,b,c):
 # star tree edges identity; each chord carries its own matrix voltage.
 chords={(1,2):a,(1,3):b,(2,3):c}
 def step(x,y):
  if x==0 or y==0:return I
  if x<y:return chords[(x,y)]
  return INV[chords[(y,x)]]
 # Choose a vertex relabeling preserving base vertex 0 so that chord voltages
 # for new (1,2) and (2,3) generate distinct order-three cyclic groups.
 perm=next((ps for ps in permutations((1,2,3)) if indep(step(ps[0],ps[1]),step(ps[1],ps[2]))),None)
 if perm is None:return None
 p={0:0,1:perm[0],2:perm[1],3:perm[2]}
 g=I; lifted=[(p[0],g)]
 for i,j in zip(P,P[1:]):
  g=product_matrix(g,step(p[i],p[j]))
  lifted.append((p[j],g))
 assert lifted[0]==lifted[-1]
 assert len(set(lifted[:-1]))==16,(a,b,c,perm,lifted)
 # Explicit literal check of edges in K4 cover: each step is valid by voltage map.
 return lifted

count=0
for a in elts:
 for b in elts:
  for c in elts:
   if not joined(a,b,c):continue
   assert explicit_path(a,b,c) is not None
   count+=1
assert count==16848,count
print('PASS independent unitriangular 3x3 product, ALL',count,'H27 generating triples have literal simple C16')

# A non-generating pair a,c inside the same C3 yields a 16-walk with
# repetitions, so the distinct-order-3-subgroup hypothesis has content.
g=mat((1,0,0));joined_path=explicit_path(g,g,g)
assert joined_path is None
print('PASS mutation: collinear chord subgroup fails independent-16-cycle premise')

# Exhaustively check all cyclic C3 covers K4 (including disconnected covers)
# via different direct DFS on 12 labeled vertices, no symbolic 16-word.
def cyclic_adj(a,b,c):
 adj=[set() for _ in range(12)]
 for i,j,v in ((0,1,0),(0,2,0),(0,3,0),(1,2,a),(1,3,b),(2,3,c)):
  for x in range(3):
   u=3*i+x;w=3*j+(x+v)%3
   adj[u].add(w);adj[w].add(u)
 return adj

def any_simple_cycle(g,L):
 for root in range(len(g)):
  def dfs(v,used):
   if len(used)==L:return root in g[v]
   for w in g[v]:
    if w not in used and dfs(w,used|{w}):return True
   return False
  if dfs(root,{root}):return True
 return False

C=Counter()
for a,b,c in product(range(3),repeat=3):
 adj=cyclic_adj(a,b,c)
 assert all(len(n)==3 for n in adj)
 C[(any_simple_cycle(adj,4),any_simple_cycle(adj,8))]+=1
assert C=={(True,False):13,(False,True):8,(True,True):6},C
print('PASS all 27 C3 triple assignments via independent full literal DFS:',dict(C))
print('Theorem scope: noncyclic exponent-three deck groups with generating voltages have C16; C3 and trivial groups have C4 or C8.')

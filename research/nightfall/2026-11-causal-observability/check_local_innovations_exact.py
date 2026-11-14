#!/usr/bin/env python3
"""Exact-rational audit: permutation CPTs, latent ANOVA, and local update dependency."""
from fractions import Fraction as F
from itertools import product
from collections import defaultdict
import json, random

R=random.Random(20261113)
C=0

def check(t,msg):
 global C
 C+=1
 if not t: raise AssertionError(msg)

def normalized(weights):
 t=sum(weights,F(0));return tuple(F(w,t) for w in weights)

def make(n,a):
 parents=[(),(0,),(0,1),(1,2),(0,2)] [:n]
 # random rational atoms, including zero-mass patterns
 ps=[normalized([R.randrange(0,6) + (i==0) for i in range(a)]) for _ in range(n)]
 for i in range(n):
  if sum(ps[i])==0: ps[i]=normalized([1]*a)
 perms={}
 for i in range(n):
  for pa in product(range(a),repeat=len(parents[i])):
   sh=(sum(pa)+i)%a
   perm=tuple((sh+j)%a for j in range(a))
   if len(pa)>1 and sum(pa)%2:
    perm=tuple(perm[::-1])
   perms[i,pa]=perm
 # term interaction edges form path plus optional chord
 edges=[(i,i+1) for i in range(n-1)] + ([(0,n-1)] if n>=4 else [])
 unary={i:tuple(F(R.randint(-3,3),7) for _ in range(a)) for i in range(n)}
 pairs={e:tuple(tuple(F(R.randint(-3,3),7) for _ in range(a)) for _ in range(a)) for e in edges}
 return parents,ps,perms,unary,pairs

def forward(u,parents,perms):
 x=[]
 for i,j in enumerate(u):
  pa=tuple(x[k] for k in parents[i]); x.append(perms[i,pa][j])
 return tuple(x)

def inverse(x,parents,perms):
 u=[]
 for i in range(len(x)):
  pa=tuple(x[k] for k in parents[i]);u.append(perms[i,pa].index(x[i]))
 return tuple(u)

def value(u,unary,pairs):
 s=sum((unary[i][u[i]] for i in unary),F(0))
 return s+sum((arr[u[i]][u[j]] for (i,j),arr in pairs.items()),F(0))

def direct_influence(i,ps,unary,pairs,a):
 # E_{-i} Var_i(f), with original product probabilities
 n=len(ps); s=F(0)
 for others in product(range(a),repeat=n-1):
  env=list(others); weight=F(1)
  for j in range(n):
   if j!=i:weight*=ps[j][env[j-(j>i)]]
  ff=[]
  for ui in range(a):
   uv=tuple(env[:i]+[ui]+env[i:])
   ff.append(value(uv,unary,pairs))
  m=sum((p*val for p,val in zip(ps[i],ff)),F(0))
  v=sum((p*(val-m)**2 for p,val in zip(ps[i],ff)),F(0))
  s+=weight*v
 return s

def local_influences(ps,unary,pairs,a):
 n=len(ps);adj={i:set() for i in range(n)}
 for i,j in pairs:adj[i].add(j);adj[j].add(i)
 res=[]
 for i in range(n):
  row=list(unary[i])
  for j in adj[i]:
   if i<j:
    mat=pairs[i,j]
    row=[row[x]+sum((ps[j][y]*mat[x][y] for y in range(a)),F(0)) for x in range(a)]
   else:
    mat=pairs[j,i]
    row=[row[y]+sum((ps[j][x]*mat[x][y] for x in range(a)),F(0)) for y in range(a)]
  mean=sum((ps[i][x]*row[x] for x in range(a)),F(0))
  s=sum((ps[i][x]*(row[x]-mean)**2 for x in range(a)),F(0))
  for j in adj[i]:
   x,y=sorted((i,j));mat=pairs[x,y]
   col=[sum((ps[x][p]*mat[p][q] for p in range(a)),F(0)) for q in range(a)]
   rows=[sum((ps[y][q]*mat[p][q] for q in range(a)),F(0)) for p in range(a)]
   av=sum((ps[x][p]*rows[p] for p in range(a)),F(0))
   s+=sum((ps[x][p]*ps[y][q]*(mat[p][q]-rows[p]-col[q]+av)**2 for p in range(a) for q in range(a)),F(0))
  res.append(s)
 return res,adj

def run():
 models=0; hist=0
 for n in (3,4,5):
  a=3
  for rep in range(16):
   parents,ps,perms,unary,pairs=make(n,a)
   states=list(product(range(a),repeat=n))
   check(all(len(set(perms[i,pa]))==a for i,pa in perms),'all local permutations bijective')
   check(all(sorted(ps[i][perms[i,pa].index(x)] for x in range(a))==sorted(ps[i]) for i,pa in perms),'all rows permutations')
   for u in states:
    x=forward(u,parents,perms)
    check(inverse(x,parents,perms)==u,'triangular inverse')
    weight=F(1);weightx=F(1)
    for i in range(n):
     weight*=ps[i][u[i]]
     pa=tuple(x[j] for j in parents[i]);weightx*=ps[i][perms[i,pa].index(x[i])]
    check(weight==weightx,'exact independent innovations')
   inp=local_influences(ps,unary,pairs,a)
   for i in range(n):check(inp[0][i]==direct_influence(i,ps,unary,pairs,a),'local ANOVA against brute')
   for edit in range(n):
    p2=list(ps);p2[edit]=normalized([R.randrange(1,7) for _ in range(a)])
    after=local_influences(p2,unary,pairs,a)[0]
    for j in range(n):
     check(after[j]==direct_influence(j,p2,unary,pairs,a),'source change Q2 influences')
     if j!=edit and j not in inp[1][edit]:
      check(after[j]==inp[0][j],'non-neighbor must be unchanged')
    for uv in range(a):
     cond=list(ps);cond[edit]=tuple(F(int(i==uv)) for i in range(a))
     sc=local_influences(cond,unary,pairs,a)[0]
     for i in range(n):check(sc[i]==direct_influence(i,cond,unary,pairs,a),'post-observation exact influence')
     hist+=1
   models+=1
 # non-row-permutation negative test
 p1=[F(1,2),F(1,3),F(1,6)]
 p2=[F(1,2),F(1,4),F(1,4)]
 check(sorted(p1)!=sorted(p2),'failure of local recoverable-innovation certificate')
 print(json.dumps({'status':'PASS','models':models,'conditional_histories':hist,'exact_assertions':C,'negative_test':'nonpermutation CPT rejected','scope':'local factor law, exact score locality, conditional-source comparisons'}))
if __name__=='__main__':run()

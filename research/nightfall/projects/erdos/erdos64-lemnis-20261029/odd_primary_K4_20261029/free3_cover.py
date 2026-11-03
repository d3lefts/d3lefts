#!/usr/bin/env python3
"""Literal rooted simple cycle search in the 729-element free class-two exponent-three group on three generators."""
from itertools import product

def mul(x,y):
 a,b,c,d,e,f=x;p,q,r,s,t,u=y
 return ((a+p)%3,(b+q)%3,(c+r)%3,(d+s+a*q-b*p)%3,(e+t+a*r-c*p)%3,(f+u+b*r-c*q)%3)
def inv(x):return tuple(-v%3 for v in x)
id=(0,)*6
G=[id,(1,0,0,0,0,0),(0,1,0,0,0,0),(0,0,1,0,0,0)]
rev=[inv(g) for g in G]
edge={(0,1):0,(0,2):0,(0,3):0,(1,2):1,(1,3):2,(2,3):3}
adj={i:[] for i in range(4)}
for (i,j),k in edge.items():adj[i].append((j,G[k]));adj[j].append((i,rev[k]))
for n in (4,8,16,32):
 found=None
 def dfs(root,vertex,group,seen,seq):
  if len(seq)==n:
   for j,gv in adj[vertex]:
    if j==root and mul(group,gv)==id:
     return seq+[root]
   return None
  for j,gv in adj[vertex]:
   new=mul(group,gv);state=(j,new)
   if state in seen:continue
   got=dfs(root,j,new,seen|{state},seq+[j])
   if got:return got
  return None
 for root in range(4):
  found=dfs(root,root,id,{(root,id)},[root]);
  if found:break
 print('FREE_CLASS2_EXP3 base K4 cover on 2916 nodes: C',n,'EXISTS' if found else 'ABSENT', 'witness',found)
 if found:break

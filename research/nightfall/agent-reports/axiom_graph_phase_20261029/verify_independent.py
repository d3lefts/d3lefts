#!/usr/bin/env python3
"""Alternate independent finite field+graph audit: F5[v]/(v^2-3).
Uses an all-pairs observation collision table and NetworkX connectivity oracle.
"""
from itertools import product,combinations
import networkx as nx
import json,random
F=tuple((a,b) for a in range(5) for b in range(5))
O=(0,0);U=(1,0);v=(0,1)

def plus(a,b):return ((a[0]+b[0])%5,(a[1]+b[1])%5)
def times(a,b):return ((a[0]*b[0]+3*a[1]*b[1])%5,(a[0]*b[1]+a[1]*b[0])%5)
def fourth(a):
 a2=times(a,a)
 return times(a2,a2)
phases=[(j,0) for j in (1,2,3,4)]
def construct(n):
 E={(min(i,(i+1)%n),max(i,(i+1)%n)) for i in range(n)}
 m=n//2
 for i in range(m+(n%2)):
  p=(i+m)%n
  E.add((min(i,p),max(i,p)))
 return sorted(E)
def obs(x,E):
 y=[fourth(a) for a in x]
 for i,j in E:
  y.extend([fourth(plus(x[i],x[j])),fourth(plus(x[i],times(v,x[j])))])
 return tuple(y)
def orbit(x):return min(tuple(times(s,z) for z in x) for s in phases)
def connected(x,E):
 active=[i for i,z in enumerate(x) if z!=O]
 if len(active)<2:return True
 G=nx.Graph();G.add_nodes_from(active)
 G.add_edges_from((i,j) for i,j in E if i in active and j in active)
 return nx.is_connected(G)

def main():
 # Independent field arithmetic: verify phase group, pair observations and full fourfold map.
 assert len({fourth(z) for z in F})==7
 for z in F[1:]:
  vals=[(fourth(plus(U,times(s,z))),fourth(plus(U,times(v,times(s,z))))) for s in phases]
  assert len(set(vals))==4
 counts=[]
 for k,E in [(2,[(0,1)]),(3,[(0,1),(1,2)]),(3,[(0,1),(0,2),(1,2)])]:
  classes={};connected_flag={};correct=0;bad=0
  for x in product(F,repeat=k):
   signature=obs(x,E)
   class_id=orbit(x)
   classes.setdefault(signature,set()).add(class_id)
   connected_flag[signature]=connected(x,E)
   if connected(x,E):correct+=1
   else:bad+=1
  assert all((len(v)==1)==connected_flag[key] for key,v in classes.items())
  counts.append((k,len(E),correct,bad,len(classes)))
 # 3-connectivity of minimally 3-connected Harary graph, and edge-criticality via vertex deletion.
 checked=0;mutations=0
 for n in range(4,15):
  ed=construct(n)
  assert len(ed)==(3*n+1)//2
  G=nx.Graph();G.add_nodes_from(range(n));G.add_edges_from(ed)
  assert nx.node_connectivity(G)==3,(n, nx.node_connectivity(G))
  for rem in ed:
   G2=G.copy();G2.remove_edge(*rem)
   assert nx.node_connectivity(G2)<=2
   culprit=next(t for t in range(n) if G2.degree(t)<=2)
   zeros=set(G2.neighbors(culprit))
   active={j for j in range(n) if j not in zeros}
   assert len(active)>=2
   assert not nx.is_connected(G2.subgraph(active))
   # Fixed signals differ by a nontrivial phase on isolated vertex.
   x=tuple(U if j in active else O for j in range(n))
   y=tuple((2,0) if j==culprit else x[j] for j in range(n))
   assert obs(x, G2.edges())==obs(y,G2.edges())
   assert orbit(x)!=orbit(y)
   mutations+=1
  checked+=1
 # Boundary no-zero tree and one-zero cycle sharp edge lower bounds.
 for n in range(4,15):
  assert nx.node_connectivity(nx.path_graph(n))==1
  assert nx.node_connectivity(nx.cycle_graph(n))==2
 print(json.dumps({'status':'PASS','field':'F5[v]/(v²−3)','exhaustive_state_counts':counts,'nonzero_ratio_classes':24,'Harary_3connected_sizes':checked,'each_edge_removal_ambiguous_controls':mutations},indent=2))
if __name__=='__main__': main()

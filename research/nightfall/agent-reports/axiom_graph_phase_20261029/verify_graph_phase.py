#!/usr/bin/env python3
"""Independent finite exact phase-graph oracle over F5[u]/(u^2-2).
No outside packages, no dependency on a theorem implementation.
"""
from itertools import product,combinations
import json,random
P=5; E=range(25); Z=0; ONE=1; THETA=5

def add(x,y): return ((x%5+y%5)%5)+5*((x//5+y//5)%5)
def mul(x,y):
 a,b=x%5,x//5;c,d=y%5,y//5
 return (a*c+2*b*d)%5 +5*((a*d+b*c)%5)
def power(x,n):
 v=1
 while n:
  if n&1:v=mul(v,x)
  x=mul(x,x);n//=2
 return v
POW=[power(a,4) for a in E]
MU=[a for a in E if a and POW[a]==1]
assert MU==[1,2,3,4]
ROOTS={z:[a for a in E if POW[a]==z] for z in set(POW)}

def graph(k,mode):
 if mode=='complete':return list(combinations(range(k),2))
 if mode=='path':return [(i,i+1) for i in range(k-1)]
 if mode=='cycle':return sorted({tuple(sorted((i,(i+1)%k))) for i in range(k)})
 if mode=='harary3':
  edges=set(graph(k,'cycle'))
  m=k//2
  for i in range(m if k%2==0 else m+1):
   edges.add(tuple(sorted((i,(i+m)%k))))
  return sorted(edges)
 raise ValueError(mode)

def observe(x,edges):
 y=tuple(POW[a] for a in x)
 for i,j in edges:
  y+=(POW[add(x[i],x[j])],POW[add(x[i],mul(THETA,x[j]))])
 return y

def canonical(x): return min(tuple(mul(p,a) for a in x) for p in MU)

def connected_supp(x,edges):
 s={i for i,z in enumerate(x) if z}
 if len(s)<2:return True
 seen={min(s)}; todo=[min(s)]
 while todo:
  v=todo.pop()
  for a,b in edges:
   if a==v and b in s and b not in seen:seen.add(b);todo.append(b)
   if b==v and a in s and a not in seen:seen.add(a);todo.append(a)
 return seen==s

def decode(y,k,edges):
 roots=[ROOTS[v][0] if v else 0 for v in y[:k]]
 active={i for i,a in enumerate(roots) if a}
 if not active:return tuple([0]*k)
 if len(active)==1:return tuple(roots)
 from collections import deque
 adj=[[] for _ in range(k)]
 idx=k
 for i,j in edges:
  obs=(y[idx],y[idx+1]);idx+=2
  if i not in active or j not in active:continue
  ratios=[q for q in MU if (POW[add(roots[i],mul(q,roots[j]))], POW[add(roots[i],mul(THETA,mul(q,roots[j])))])==obs]
  assert len(ratios)==1,('pair phase separation',i,j,ratios)
  r=ratios[0]
  adj[i].append((j,r));adj[j].append((i,next(z for z in MU if mul(z,r)==1)))
 anchor=min(active);phase={anchor:1};queue=deque([anchor])
 while queue:
  u=queue.popleft()
  for v,q in adj[u]:
   val=mul(phase[u],q)
   if v in phase:assert phase[v]==val
   else:phase[v]=val;queue.append(v)
 if set(phase)!=active:return None
 ans=tuple(mul(phase[i],roots[i]) if i in active else 0 for i in range(k))
 assert observe(ans,edges)==y
 return ans

def exhaustive(k,mode):
 edges=graph(k,mode); classes={}; decoded=0; ambiguous=0; good=0
 for x in product(E,repeat=k):
  y=observe(x,edges)
  c=canonical(x)
  bucket=classes.setdefault(y,set());bucket.add(c)
  out=decode(y,k,edges)
  if connected_supp(x,edges):
   assert out is not None and canonical(out)==c,(k,x)
   good+=1
  else:
   assert out is None,(k,x)
   ambiguous+=1
  decoded+=1
 assert all((len(v)==1)==(decode(y,k,edges)is not None) for y,v in classes.items())
 return {'k':k,'mode':mode,'rows':k+2*len(edges),'signals':decoded,'signatures':len(classes),'connected_support_signals':good,'disconnected_support_signals':ambiguous}

def main():
 # Complete pair equality checking with ratio classes both field-sensitive and exceptional.
 for z in range(1,25):
  for p in MU:
   vals=[(POW[add(1,mul(q,z))],POW[add(1,mul(THETA,mul(q,z)))]) for q in MU]
   assert len(set(vals))==4
 results=[exhaustive(2,'complete'),exhaustive(3,'path'),exhaustive(3,'complete')]
 for k in range(4,15):
  for t,mode in [(0,'path'),(1,'cycle'),(2,'harary3')]:
   G=graph(k,mode)
   if k==4 and mode=='harary3':assert len(G)==6
   if mode=='harary3':assert len(G)==(3*k+1)//2
   for deleted in (set(d) for sz in range(t+1) for d in combinations(range(k),sz)):
    active=tuple(1 if i not in deleted else 0 for i in range(k))
    assert connected_supp(active,G),(k,t,deleted)
 # Nonadaptive zero-support counterexample: path endpoints disconnect.
 path=graph(3,'path');bad1=(1,0,1);bad2=(1,0,2)
 assert canonical(bad1)!=canonical(bad2)
 assert observe(bad1,path)==observe(bad2,path)
 # Remove one edge in a cycle: zero middle vertex disconnects endpoints.
 results.append({'zero_counterexample':[list(bad1),list(bad2)],'path_ambiguous':True})
 print(json.dumps({'status':'PASS','field':'F5[u]/(u²−2)','pair_ratios_checked':24,'phase_candidates_checked':96,'graph_robustness':'k=4..14, t=0,1,2 (all deletion subsets)','exhaustive':results},sort_keys=True,indent=2))
if __name__=='__main__':main()

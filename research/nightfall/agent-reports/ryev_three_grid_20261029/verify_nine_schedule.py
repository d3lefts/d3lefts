#!/usr/bin/env python3
"""Exact adaptive F25 nine-reading decoder and full 256-phase witness audit."""
from itertools import product
import random,json
F=tuple((a,b) for a in range(5) for b in range(5))
Z=(0,0);E=(1,0);T=(0,1);G=range(1,5)
def add(a,b):return ((a[0]+b[0])%5,(a[1]+b[1])%5)
def mul(a,b):return ((a[0]*b[0]+2*a[1]*b[1])%5,(a[0]*b[1]+a[1]*b[0])%5)
def power(a,n):
 b=E
 while n:
  if n&1:b=mul(b,a)
  a=mul(a,a);n//=2
 return b
def fourth(a):return power(a,4)
def scalar(s,a):return (s*a[0]%5,s*a[1]%5)
ROOT={fourth(x):x for x in F}
assert len(ROOT)==7
def measure(row,x):
 w=Z
 for a,b in zip(row,x):w=add(w,mul(a,b))
 return fourth(w)
def coordinate(i):
 return tuple(E if i==j else Z for j in range(5))
def separator(candidates):
 for row in product(F,repeat=3):
  outputs=[measure(row,c) for c in candidates]
  if len(outputs)==len(set(outputs)):return row
 raise AssertionError("Three-state separation impossible")
def decode(x):
 y=[measure(coordinate(i),x) for i in range(3)];alpha=[ROOT[z] for z in y];queries=3
 candidates=None
 if all(v!=Z for v in y):
  row=(power(alpha[0],23),mul(T,power(alpha[1],23)),
       mul(add(E,T),power(alpha[2],23)))
  observed=measure(row,x);queries+=1
  candidates=[(alpha[0],scalar(s,alpha[1]),scalar(t,alpha[2]))
    for s,t in product(G,repeat=2)
    if measure(row,(alpha[0],scalar(s,alpha[1]),scalar(t,alpha[2])))==observed]
  assert 1<=len(candidates)<=3
 else:queries+=1 # fourth measurement: zero row in the already known span
 y.extend(measure(coordinate(j),x) for j in (3,4));queries+=2
 alpha.extend(ROOT[z] for z in y[3:])
 if candidates is not None:
  row=separator(candidates)
  observed=measure(row,x);queries+=1
  good=[c for c in candidates if measure(row,c)==observed]
  assert len(good)==1
  guess=list(good[0])+[Z,Z];h=0;remaining=(3,4)
 else:
  guess=[Z]*5
  active=[j for j in range(5) if y[j]!=Z]
  if not active:
   assert all(z==Z for z in x)
   return queries
  h=active[0];guess[h]=alpha[h];remaining=active[1:]
 for j in remaining:
  if y[j]==Z:continue
  ratio=mul(y[j],power(y[h],23))
  c=T if ratio==E else E
  row=list(coordinate(h));row[j]=c
  observed=measure(row,x);queries+=1
  possible=[]
  for s in G:
   r=scalar(s,mul(alpha[j],power(alpha[h],23)))
   if fourth(add(E,mul(c,r)))==mul(observed,power(y[h],23)):possible.append(r)
  assert len(possible)==1
  guess[j]=mul(guess[h],possible[0])
 assert queries<=9
 assert any(all(a==scalar(s,b) for a,b in zip(x,guess)) for s in G),(x,guess)
 return queries
def run():
 row=(E,T,add(E,T))
 hist={}
 for s,t in product(G,repeat=2):
  q=measure(row,(E,(s,0),(t,0)))
  hist[q]=hist.get(q,0)+1
 assert sorted(hist.values())==[1,2,2,2,3,3,3]
 counts={}
 def check(x):
  n=decode(x);counts[n]=counts.get(n,0)+1
 for a in product(G,repeat=4):check((E,)+tuple((z,0) for z in a))
 random.seed(1729)
 for _ in range(3000):check(tuple(random.choice(F) for _ in range(5)))
 for a in product([E,Z],repeat=5):check(a)
 assert sum(counts.values())==3288
 print(json.dumps({"status":"PASS","fullSupportPhasePatterns":256,
   "randomVectors":3000,"supportPatterns":32,
   "firstPhaseBucketSizes":sorted(hist.values()),"readingHistogram":counts,
   "maximumReadings":max(counts),"scope":"All signals, prescribed adaptive 3+1+2+3 schedule."},indent=2))
if __name__=="__main__":run()

#!/usr/bin/env python3
"""Lemnis self-contained adversarial *partial* audit of Axiom #142 q27 invariants.
Does not attempt exhaustive codimension-2 direction census; THAT gate remains open.
"""
from itertools import combinations
F=range(27)
def trits(x):return [x%3,(x//3)%3,x//9]
def encode(c):return sum((c[i]%3)*(3**i) for i in range(3))
def add(a,b):return encode([x+y for x,y in zip(trits(a),trits(b))])
def neg(a):return encode([-x for x in trits(a)])
def mul(a,b):
 a=trits(a);b=trits(b);c=[0]*5
 for i in range(3):
  for j in range(3):c[i+j]+=a[i]*b[j]
 # T^3=T-1, T^4=T^2-T, reduce descending coefficients
 c[2]+=c[4];c[1]-=c[4]
 c[1]+=c[3];c[0]-=c[3]
 return encode(c)
def powf(a,n):
 r=1
 for _ in range(n):r=mul(r,a)
 return r
def pol(e,x,y):return add(add(powf(add(x,y),e),neg(powf(x,e))),neg(powf(y,e)))
def mat(e,x):return tuple(tuple(trits(pol(e,x,3**j))[i] for j in range(3)) for i in range(3))
def prod(A,B):return tuple(tuple(sum(A[i][k]*B[k][j] for k in range(3))%3 for j in range(3)) for i in range(3))
def inv(A):
 for r in range(3**9):
  B=tuple(tuple((r//(3**(3*i+j)))%3 for j in range(3)) for i in range(3))
  if prod(A,B)==((1,0,0),(0,1,0),(0,0,1)):return B
 raise ValueError('singular')
def rank(A):
 B=[list(row) for row in A];p=0
 for c in range(3):
  k=next((i for i in range(p,3) if B[i][c]),None)
  if k is None:continue
  B[k],B[p]=B[p],B[k]
  if B[p][c]==2:B[p]=[(2*a)%3 for a in B[p]]
  for i in range(3):
   if i!=p:
    m=B[i][c]
    B[i]=[(a-m*b)%3 for a,b in zip(B[i],B[p])]
  p+=1
 return p
counts={}
for e in (2,4):
 Z=inv(mat(e,1)); Ns={a:prod(mat(e,a),Z) for a in range(1,27)}
 h={0:0,1:0,2:0,3:0}
 for a in range(1,27):
  for b in range(1,27):
   A=prod(Ns[a],Ns[b]);B=prod(Ns[b],Ns[a])
   h[rank(tuple(tuple((A[i][j]-B[i][j])%3 for j in range(3)) for i in range(3)))]+=1
 counts[e]=h
assert counts[2]=={0:676,1:0,2:0,3:0}
assert counts[4]=={0:244,1:0,2:432,3:0}
for e in (2,4):
 Ps={(t,powf(t,e),0) for t in F}
 Cs={(0,neg(powf(t,e)),t) for t in F}
 S=Ps|Cs
 assert len(S)==53
 lines={tuple(sorted({t,mul(2,t)})) for t in range(1,27)}
 assert len(lines)==13
 pack=[]
 for L in lines:
  pack.append((Ps|{(0,neg(powf(t,e)),t) for t in L},'P'))
  pack.append((Cs|{(t,powf(t,e),0) for t in L},'C'))
 assert len(pack)==26 and all(len(a)==29 for a,_ in pack)
 stats={'27':0,'5':0}
 for (a,x),(b,y) in combinations(pack,2):
  k=len(a&b)
  assert k==(27 if x==y else 5),(k,x,y)
  stats[str(k)]+=1
 assert stats=={'27':156,'5':169}
 print('PASS 26 explicit 29-point sections, intersection pairs',stats, 'e=',e)
print('PASS independent F27 normalized-operator rank histograms',counts)
print('UNTESTED: uniqueness of 26 sections among all 8,069,620 codim2 directions; verify separately')


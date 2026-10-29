#!/usr/bin/env python3
"""TESSERA: independent exact Singer Sidon 975-mark and matching/cover checker.
Fixed-template theorem only. Standard library, no solver or builder imports.
"""
from collections import defaultdict
from math import isqrt
from hashlib import sha256
p=1009
v=p*p+p+1
A=(1,2,4,8,13)
assert v==1019091
assert all(p % d for d in range(2,isqrt(p)+1)) # primality of base field
assert 3*37*9181==v and all(all(f % d for d in range(2,isqrt(f)+1)) for f in (3,37,9181)) # prime projective factors
assert all((x*x*x+2)%p for x in range(p)) # irreducible cubic X^3+2

def mul(s,t):
 a,b,c=s; d,e,f=t
 return ((a*d-2*(b*f+c*e))%p,
         (a*e+b*d-2*c*f)%p,
         (a*f+b*e+c*d)%p)
def power(z,n):
 out=(1,0,0)
 while n:
  if n&1:out=mul(out,z)
  z=mul(z,z);n//=2
 return out
theta=(2,1,0)
assert power(theta,v)[1:]==(0,0)
assert all(power(theta,v//factor)[1:]!=(0,0) for factor in (3,37,9181))

# Deliberately use a specialized recurrence, unlike the generic field-power check.
state=(1,0,0);D=[]
for exp in range(v):
 if state[2]==0:D.append(exp)
 a,b,c=state
 state=((2*a-2*c)%p,(a+2*b)%p,(b+2*c)%p)
assert state[1:]==(0,0) and len(D)==1010
seen=bytearray(v)
for i,a in enumerate(D):
 for j,b in enumerate(D):
  if i!=j:
   d=(a-b)%v
   assert d>0 and seen[d]==0
   seen[d]=1
assert sum(seen)==v-1

cut=386
assert D[cut]==363760
Q=sorted((e-D[cut])%v for e in D)
T=734950
R=set((14,20,27,29,61,68,75,96,101,162,264,285,411,419,621,625,
       717,818,834,849,855,885,887,888,889,891,893,900,911,916,921,
       948,961,964,970,982,990,991,996,1008))
assert len(R)==40
full=list(A)+[T+x for x in Q]
assert len(full)==1015
representations=defaultdict(list)
for i,x in enumerate(full):
 for j in range(i,len(full)):
  representations[x+full[j]].append((i,j))
constraints=set()
for group in representations.values():
 for i,(a,b) in enumerate(group):
  for c,d in group[i+1:]:
   edge=frozenset(x-5 for x in (a,b,c,d) if x>=5)
   assert edge
   constraints.add(edge)
assert len(constraints)==52
assert all(edge & R for edge in constraints)

PACK=[
 (1,140,885),(2,222,990),(4,209,970),(6,138,888),(12,90,849),
 (13,14,748),(16,182,964),(17,147,916),(18,148,921),
 (20,126,894),(26,64,834),(27,33,789),(29,141,919),
 (30,160,961),(31,70,855),(32,128,911),(34,41,818),
 (35,96,882),(36,98,887),(38,139,948),(42,175,996),
 (44,61,865),(45,83,891),(49,74,889),(59,69,900),
 (60,75,908),(68,130,973),(80,133,991),(93,119,982),
 (101,111,985),(118,122,1008),(161,162),(263,264),(284,285),
 (410,411),(418,419),(621,622),(624,625),(716,717),(892,893)]
assert len(PACK)==40
occupied=set()
for entry in PACK:
 edge=frozenset(entry)
 assert edge in constraints and not (occupied&edge)
 occupied.update(edge)
assert len(PACK)==len(R)==40

V=sorted(A+tuple(T+x for i,x in enumerate(Q) if i not in R))
assert len(V)==975 and V[-1]==1753998
sums=set()
for i,x in enumerate(V):
 for y in V[i:]:
  s=x+y
  assert s not in sums
  sums.add(s)
assert len(sums)==475800
sha=sha256(''.join(f'{x}\n' for x in V).encode()).hexdigest()
assert sha=='a237ac6f1d246a58ae292c813c4c8b0daf72f67ef46f7b5baf7a01e47bd6ccc8'
assert 975**2*1766378-977**2*1753998==4921129308>0
assert 975**2*1783622-982**2*1753998==4133296398>0
print('PASS: Singer 1010-point difference set with 1,019,090 distinct nonzero differences')
print('PASS: 52 constraints; 40 disjoint matching lower bound and 40-cover upper bound')
print('PASS: 975 Sidon marks, endpoint 1,753,998, 475,800 distinct sums')
print('PASS: exact same-prefix density improvement over 977 and 982')
print('PASS SHA256:',sha)

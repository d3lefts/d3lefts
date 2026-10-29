#!/usr/bin/env python3
"""Independent fixed-F25 prime-subfield decoder + exact probability controls.
Arithmetic: polynomial basis F5[z]/(z^2-2), no external packages."""
from fractions import Fraction
from itertools import product
from math import comb
import random, hashlib
Q=25
E=tuple(range(25))
def unpack(t): return t%5,t//5
def pack(a,b):return a%5+5*(b%5)
def add(x,y):
 a,b=unpack(x);c,d=unpack(y);return pack(a+c,b+d)
def mul(x,y):
 a,b=unpack(x);c,d=unpack(y);return pack(a*c+2*b*d,a*d+b*c)
def pw(x,n):
 v=1
 while n:
  if n&1:v=mul(v,x)
  x=mul(x,x);n>>=1
 return v
def dot(row,x):
 v=0
 for a,b in zip(row,x):v=add(v,mul(a,b))
 return v
ROOTS={}
for x in E:ROOTS.setdefault(pw(x,4),[]).append(x)
assert len(ROOTS)==7 and all(len(t)==4 for y,t in ROOTS.items() if y)
def mat(y,A):
 out=[];k=len(A[0]);w=5
 for row,yy in zip(A,y):
  if yy==0:
   cs=[]
   for bas in (0,1):
    v=[]
    for a in row:
     for e in (1,5):v.append(unpack(mul(a,e))[bas])
    cs.append(v)
   out.extend(cs)
  else:
   root=ROOTS[yy][0];inv=pw(root,23)
   out.append([unpack(mul(mul(a,e),inv))[1] for a in row for e in (1,5)])
 return out
def nullspace(A,n):
 B=[row[:] for row in A];m=len(B);i=0;piv=[]
 for j in range(n):
  r=next((r for r in range(i,m) if B[r][j]),None)
  if r is None:continue
  B[i],B[r]=B[r],B[i]
  z=pow(B[i][j],-1,5);B[i]=[(z*x)%5 for x in B[i]]
  for row in range(m):
   if row!=i and B[row][j]:
    z=B[row][j];B[row]=[(u-z*v)%5 for u,v in zip(B[row],B[i])]
  piv.append(j);i+=1
  if i==m:break
 free=[j for j in range(n) if j not in piv]
 vec=[]
 for j in free:
  z=[0]*n;z[j]=1
  for r,p in enumerate(piv):z[p]=(-B[r][j])%5
  vec.append(z)
 return vec
def combine(basis,cs,k):
 v=[0]*(2*k)
 for c,z in zip(cs,basis):
  for i,a in enumerate(z):v[i]=(v[i]+c*a)%5
 return [pack(v[2*i],v[2*i+1]) for i in range(k)]
def phase(x):return min(tuple(mul(t,a) for a in x) for t in [1,2,3,4])
def decode(A,y):
 k=len(A[0]);basis=nullspace(mat(y,A),2*k)
 if len(basis)>2:return None,len(basis)
 candidates=set()
 for cs in product(range(5),repeat=len(basis)):
  v=combine(basis,cs,k)
  if all(pw(dot(row,v),4)==yy for row,yy in zip(A,y)):
   candidates.add(phase(v))
 return candidates,len(basis)
# t^-1 = t^23 in F25.
def in_line(t,b):return (t==0 and b==0) or (t!=0 and mul(b,pw(t,23)) in (0,1,2,3,4))
assert sum(in_line(t,b) for t in E for b in E)==121
assert sum(in_line(t,b) and in_line(t,c) for t in E for b in E for c in E)==601
# rank-2 triple: x=e1,z=e2,z'=theta*z ; theta=z basis element
th=5
assert sum(in_line(t,b) and in_line(t,mul(th,b)) for t in E for b in E)==25
# Source theorem integer certificates (exact)
assert 97**83 < 625**59
assert 5**24*601**83 < 15625**59
assert 97**69 > 625**49
assert 4**20*601**69 < 15625**49
assert Fraction(1,24)+Fraction(1,32)+Fraction(1,25)+Fraction(1,125)<1
for k in range(1,100):
 m=(83*k+23)//24+1
 if k>=2:assert m>=2*k+4
 # include rank failure, pair collisions, rank-2 and rank-3 auxiliary triple events
 p=Fraction(25**k-1,24*25**m)+Fraction((25**k-1)*(25**k-25),32)*Fraction(97,625)**m
 if k>=2:p+=Fraction(25**(2*k+2),25**m)
 if k>=3:p+=Fraction(25**(3*k))*Fraction(601,15625)**m
 assert p<Fraction(1,5),(k,p)
print('PASS: exact 121/625 line and 601/15625 triple incidences; rank-two 25/625')
print('PASS: two integer certificates and k=1..99 exact total failure estimate s=1')
random.seed(1729)
for k,cnt in ((2,6),(3,2)):
 m=(83*k+23)//24+1
 for attempt in range(cnt):
  A=[[random.randrange(25) for i in range(k)] for j in range(m)]
  signals=list(product(E,repeat=k)) if k==2 else [tuple(random.randrange(25) for i in range(k)) for _ in range(300)]
  for x in signals:
   y=[pw(dot(a,x),4) for a in A]
   out,dim=decode(A,y)
   assert out=={phase(x)},('fail',k,attempt,x,dim,out)
  print('PASS design',k,attempt,'m',m,'signals',len(signals),'max_dim',max(len(nullspace(mat([pw(dot(a,x),4) for a in A],A),2*k)) for x in signals))
print('PASS sub-3.5k polynomial-time list decoder')
print('sha',hashlib.sha256(open(__file__,'rb').read()).hexdigest())

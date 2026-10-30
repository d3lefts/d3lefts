#!/usr/bin/env python3
"""Independent verification: tuple field F5[u]/(u²-3), trace-linear constraints."""
from itertools import product
from fractions import Fraction as F
import random, hashlib
E=list(product(range(5),repeat=2));z=(0,0);one=(1,0);u=(0,1)
def plus(a,b):return ((a[0]+b[0])%5,(a[1]+b[1])%5)
def times(a,b):return ((a[0]*b[0]+3*a[1]*b[1])%5,(a[0]*b[1]+a[1]*b[0])%5)
def power(a,n):
 r=one
 while n:
  if n&1:r=times(r,a)
  a=times(a,a);n//=2
 return r
def trace(a):
 s=plus(a,power(a,5));assert s[1]==0
 return s[0]
def inner(row,v):
 a=z
 for b,c in zip(row,v):a=plus(a,times(b,c))
 return a
roots={}
for t in E:roots.setdefault(power(t,4),[]).append(t)
phase=[(i,0) for i in range(1,5)]
def canonical(v):return min(tuple(times(a,w) for a in v) for w in phase)
def solve_linear(mat,n):
 a=[r[:] for r in mat];rank=0;pivots=[]
 for j in range(n):
  idx=next((l for l in range(rank,len(a)) if a[l][j]),None)
  if idx is None:continue
  a[rank],a[idx]=a[idx],a[rank];d=pow(a[rank][j],-1,5)
  a[rank]=[d*x%5 for x in a[rank]]
  for h in range(len(a)):
   if h==rank or not a[h][j]:continue
   t=a[h][j];a[h]=[(w-t*v)%5 for w,v in zip(a[h],a[rank])]
  pivots.append(j);rank+=1
  if rank==len(a):break
 free=[j for j in range(n) if j not in pivots]
 basis=[]
 for col in free:
  v=[0]*n;v[col]=1
  for i,j in enumerate(pivots):v[j]=-a[i][col]%5
  basis.append(v)
 return basis
def constraints(A,y):
 output=[];k=len(A[0]);n=2*k
 for row,p in zip(A,y):
  for mode in ([0,1] if p==z else [2]):
   inv=power(roots[p][0],23) if p!=z else one
   coeff=[]
   for a in row:
    for unit in (one,u):
     b=times(a,unit)
     if mode==2:coeff.append(trace(times(u,times(b,inv))))
     else:coeff.append(b[mode])
   output.append(coeff)
 return output
def dec(A,y):
 k=len(A[0]);basis=solve_linear(constraints(A,y),2*k)
 if len(basis)>2:return None,len(basis)
 matches=set()
 for cs in product(range(5),repeat=len(basis)):
  coords=[sum(cs[h]*basis[h][j] for h in range(len(basis)))%5 for j in range(2*k)]
  x=[(coords[2*i],coords[2*i+1]) for i in range(k)]
  if all(power(inner(row,x),4)==p for row,p in zip(A,y)):
   matches.add(canonical(x))
 return matches,len(basis)
def flag(t,b):return (t==z and b==z) or (t!=z and times(b,power(t,23))[1]==0)
assert sum(flag(t,b) for t in E for b in E)==121
assert sum(flag(t,b) and flag(t,c) for t,b,c in product(E,repeat=3))==601
assert sum(flag(t,b) and flag(t,times(u,b)) for t,b in product(E,repeat=2))==25
# The previously known 5-row interpolation design is information-theoretically unique yet has a two-dimensional F5-list kernel.
A=[(one,(t,0)) for t in range(5)];x=[one,z];y=[power(inner(a,x),4) for a in A]
out,dim=dec(A,y)
assert dim==2 and out=={canonical(x)}
# Coordinate-only identity design is still ambiguous: 16 signals, 4 phase orbits.
A=[(one,z),(z,one)];x=[one,one];y=[power(inner(a,x),4) for a in A]
out,dim=dec(A,y)
assert dim==2 and len(out)==4
print('PASS alternate GF25 exact incidence 121,601,25 and both adversarial 2D fixtures')
random.seed(20261029)
for k,nsamples in ((2,3),(3,1)):
 m=(83*k+23)//24+1
 for sample in range(nsamples):
  A=[tuple(random.choice(E) for _ in range(k)) for _ in range(m)]
  tests=product(E,repeat=k) if k==2 else [tuple(random.choice(E) for _ in range(k)) for _ in range(125)]
  for x in tests:
   y=[power(inner(a,x),4) for a in A]
   result,dim=dec(A,y)
   assert result=={canonical(x)},(k,sample,x,dim,result)
  print('PASS independent field design',k,sample,'m',m,'signals',625 if k==2 else 125)
print('PASS all exact independent tests')
print('sha',hashlib.sha256(open(__file__,'rb').read()).hexdigest())

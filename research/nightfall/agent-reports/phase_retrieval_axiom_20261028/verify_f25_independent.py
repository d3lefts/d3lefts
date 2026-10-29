#!/usr/bin/env python3
"""AXIOM independent finite-field checker, different GF(25) model F5[v]/(v²-3).
Exact full coefficient enumeration + exact random-design all-signal rank audit.
Does not import any previous Axiom or Lemnis decoder source.
"""
from itertools import product
from collections import Counter
from hashlib import sha256
from pathlib import Path
from random import Random

Q=25
E=list(range(Q))
# Encode a+b*v as a+5*b, v²=3 in F5.
def mul(x,y):
 a,b=x%5,x//5;c,d=y%5,y//5
 return (a*c+3*b*d)%5+5*((a*d+b*c)%5)
def minus(x):return ((-x%5)+5*((-(x//5))%5))
def add(x,y):return ((x%5+y%5)%5)+5*((x//5+y//5)%5)
def sub(x,y):return add(x,minus(y))
def power(x,n):
 v=1
 while n:
  if n&1:v=mul(v,x)
  x=mul(x,x);n>>=1
 return v
assert all(power(x,25)==x for x in E)
assert all(power(x,24)==1 for x in E if x)
# All 3-coefficient monomials for fixed signal x=(1,0):
# P(t,b)=(alpha)*t^5 + B*b^5 - C*t^4*b.
# Homogeneity reduces exact 625 row count to 24*N_roots + (25 if B=0 else 1).
hist=Counter();highest=0;maximizers=[]
P5=[power(t,5) for t in E]
for alpha,B,C in product(E,repeat=3):
 if alpha==B==C==0:continue
 roots=sum(add(add(alpha,mul(B,P5[u])),minus(mul(C,u)))==0 for u in E)
 zeros=(25 if B==0 else 1)+24*roots
 assert zeros<=121,(alpha,B,C,zeros)
 hist[zeros]+=1
 if zeros>highest:highest=zeros;maximizers=[(alpha,B,C)]
 elif zeros==highest:maximizers.append((alpha,B,C))
assert sum(hist.values())==25**3-1
assert highest==121
# Nonplanted equality example; for x=(1,0) choose alpha=0,B=C=1:
assert (0,1,1) in maximizers

def dot(a,b):
 z=0
 for x,y in zip(a,b):z=add(z,mul(x,y))
 return z

def rank(rows):
 rows=[row[:] for row in rows];n=len(rows[0]);m=len(rows);r=0
 for j in range(n):
  i=next((i for i in range(r,m) if rows[i][j]),None)
  if i is None:continue
  rows[i],rows[r]=rows[r],rows[i]
  t=power(rows[r][j],23)
  for v in range(j,n):rows[r][v]=mul(rows[r][v],t)
  for i2 in range(r+1,m):
   t=rows[i2][j]
   if t:
    for v in range(j,n):rows[i2][v]=sub(rows[i2][v],mul(t,rows[r][v]))
  r+=1
  if r==m:break
 return r

def M(A,x):
 return [ [power(a,5) for a in row]+[minus(mul(power(dot(row,x),4),a)) for a in row] for row in A ]

def kernel_unique(rows):
    # Entirely separate reduced-row-echelon decoder, with explicit ambiguity status.
    A=[row[:] for row in rows]
    n=len(A[0]);m=len(A)
    piv=[];p=0
    for col in range(n):
        pivot=next((i for i in range(p,m) if A[i][col]!=0),None)
        if pivot is None:continue
        A[p],A[pivot]=A[pivot],A[p]
        z=power(A[p][col],23)
        A[p]=[mul(z,v) for v in A[p]]
        for i in range(m):
            if i==p:continue
            factor=A[i][col]
            if factor:
                A[i]=[sub(A[i][j],mul(factor,A[p][j])) for j in range(n)]
        piv.append(col);p+=1
        if p==m:break
    free=[i for i in range(n) if i not in piv]
    if len(free)!=1:return None
    j=free[0];z=[0]*n;z[j]=1
    for row,col in enumerate(piv):z[col]=minus(A[row][j])
    assert all(dot(row,z)==0 for row in rows)
    return z

def decode(A,ys):
    k=len(A[0])
    if all(y==0 for y in ys):
        if rank(A)==k:return {(0,)*k}
        return None
    L=[[power(a,5) for a in row]+[minus(mul(y,a)) for a in row] for row,y in zip(A,ys)]
    z=kernel_unique(L)
    if z is None:return None
    u,v=z[:k],z[k:]
    ind=next((i for i in range(k) if v[i]),None)
    if ind is None:return None
    if u[ind]==0:return None
    target=mul(power(v[ind],5),power(u[ind],23))
    results=set()
    for beta in E:
        if beta and power(beta,4)==target:
            inv=power(beta,23)
            xc=tuple(mul(vi,inv) for vi in v)
            if all(power(dot(row,xc),4)==y for row,y in zip(A,ys)):
                results.add(xc)
    return results

seed=330417
rng=Random(seed)
# For k=2, m=13 suffices for s=1; enumerate every nonzero signal for each design.
rank_failures=0
for design in range(4):
 A=[[rng.randrange(25) for _ in range(2)] for _ in range(13)]
 assert rank(A)==2
 for x in product(E,repeat=2):
  ys=[power(dot(row,x),4) for row in A]
  if x==(0,0):
   assert decode(A,ys)=={(0,0)}
   continue
  if rank(M(A,x))!=3:rank_failures+=1
  phases=[b for b in E if power(b,4)==1]
  expected={tuple(mul(b,xi) for xi in x) for b in phases}
  assert decode(A,ys)==expected,(design,x)
assert rank_failures==0
# Independent k3 sampled decoder checks, under m=ceil(2941k/500)+1=19.
for design in range(3):
 A=[[rng.randrange(25) for _ in range(3)] for _ in range(19)]
 assert rank(A)==3
 for _ in range(25):
  x=tuple(rng.randrange(25) for _ in range(3))
  ys=[power(dot(row,x),4) for row in A]
  phases=[b for b in E if power(b,4)==1]
  expected={tuple(mul(b,xi) for xi in x) for b in phases}
  assert decode(A,ys)==expected

# Explicit rank-defective and nonlinear-ambiguous design fixture.
A_bad=[[0,0] for _ in range(13)]
assert rank(M(A_bad,(1,0)))==0
assert decode(A_bad,[0]*13) is None
# Gaussian matrix rank for k1 and x!=0: if a!=0, two columns are proportional.
assert rank(M([[1]],(1,)))==1
# Exact integer proof of advertised 5.882 coefficient.
assert 11**5882<5**8764
assert 121*5<625
print('PASS full polynomial coefficient enumeration: 15624 triples; max zero rows=121/625')
print('PASS max-attainment count:',len(maximizers),'zero-count histogram:',dict(sorted(hist.items())))
print('PASS GF25 v²=3; seed',seed,'4x625 full decoder outputs at k2,m13 and 3x25 sampled outputs k3,m19')
print('PASS zero input and zero-design boundary logic; exact 11^5882 < 5^8764')
print('SOURCE_SHA256',sha256(Path(__file__).read_bytes()).hexdigest())

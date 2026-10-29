#!/usr/bin/env python3
"""Independent exact rational, grade-by-grade spectral projection checker.
Proves failed predecessor sufficiency predicates for an explicit rank-two matrix.
No numerical pseudoinverse, floating point, or physical trace imports.
"""
from fractions import Fraction as F
from itertools import product,combinations
from collections import defaultdict
import sympy as S
N=4
WORDS=list(product(range(3),repeat=N))
A=(0,0,0,0);B=(1,1,1,1);C=(2,2,2,0);D=(2,2,2,2)
def H(a):return((a[2]-a[0]-a[1])%3,(a[3]-a[0]-2*a[1])%3)
def g(x):return tuple((x[0][j]-x[1][j])%3 for j in range(4))
SS={(i,0) for i in range(3)};TT={(0,i) for i in range(3)}
U=[(a,b) for a in WORDS for b in WORDS if H(a) in SS and H(b) in TT]
Uset=set(U);bygrade=defaultdict(list)
for x in U:bygrade[g(x)].append(x)
assert len(U)==729 and len(bygrade)==81 and all(len(z)==9 for z in bygrade.values())

def plus(a,b,t=1):
  d=a.copy()
  for k,v in b.items():
    d[k]=d.get(k,F(0))+t*v
    if not d[k]:del d[k]
  return d

def inn(a,b):return sum(v*b.get(k,0) for k,v in a.items())
def norm(a):return inn(a,a)

def scalar_traceless(a,b,sc):
  if a!=b: return [] if sc else [((a,b),F(1))]
  if sc:return [((z,z),F(1,3)) for z in range(3)]
  return [((z,z), F(2,3) if z==a else F(-1,3)) for z in range(3)]

def pm_unit(x,m):
  a,b=x;out={}
  for ss in combinations(range(N),m):
    opts=[scalar_traceless(a[j],b[j],j in ss) for j in range(N)]
    for choice in product(*opts):
      pair=(tuple(c[0][0] for c in choice),tuple(c[0][1] for c in choice))
      val=F(1)
      for c in choice:val*=c[1]
      out[pair]=out.get(pair,F(0))+val
  return {k:v for k,v in out.items() if v}

def pm(C,m):
  out={}
  for u,v in C.items():out=plus(out,pm_unit(u,m),v)
  return out

def D_m(C,m):
  out=pm(C,m)
  grades={g(u) for u in out}
  for gg in grades:
    basis=bygrade[gg]
    G=S.Matrix([[pm_unit(u,m).get(v,0) for u in basis] for v in basis])
    y=S.Matrix([out.get(v,0) for v in basis])
    assert G.rank()==G.row_join(y).rank()
    coef,free=G.gauss_jordan_solve(y)
    coef=[F(c.subs({v:0 for v in list(free)})) for c in coef]
    for u,c in zip(basis,coef):
      if c:out=plus(out,pm_unit(u,m),-c)
  return out

def K_unit(x):
  a,b=x;opts=[]
  for aj,bj in zip(a,b):
    if aj!=bj:opts.append([((aj,bj),F(1))])
    else:opts.append([((i,i),F(1,2) if i==aj else F(-1,2)) for i in range(3)])
  out={}
  for c in product(*opts):
    item=(tuple(i[0][0] for i in c),tuple(i[0][1] for i in c))
    v=F(1)
    for i in c:v*=i[1]
    out[item]=v
  return out

def K(C):
  o={}
  for u,v in C.items():o=plus(o,K_unit(u),v)
  return o

u={A:F(1),C:F(1),D:F(1)}
X={(a,b):x*y for a,x in u.items() for b,y in u.items()};X[(B,B)]=F(-1)
C0={k:v for k,v in X.items() if k in Uset}
D0=D_m(X,0);D2=D_m(X,2)
R=plus(plus(plus(X,C0,-1),D0,-1),D2,-1)
leak={k:v for k,v in K(C0).items() if k not in Uset}
h0={k:v for k,v in leak.items() if g(k)==(0,0,0,0)}
r0={k:v for k,v in R.items() if g(k)==(0,0,0,0)}
vals={'C0_norm':norm(C0),'Q0':inn(C0,K(C0)), 'D0_norm':norm(D0),'D2_norm':norm(D2),'R_norm':norm(R),'h_0_sq':norm(h0),'r_0_sq':norm(r0),'Q_total':inn(X,K(X)),'cross_C0_R':2*inn(C0,K(R)), 'R_rank_witness':len(R)}
expected={'C0_norm':F(2),'Q0':F(9,16),'D0_norm':F(86,27),'D2_norm':F(26,27),'R_norm':F(104,27),'h_0_sq':F(9,32),'r_0_sq':F(20,9),'Q_total':F(3),'cross_C0_R':F(-1,8)}
for key,value in expected.items():assert vals[key]==value,(key,vals[key],value)
assert all(inn(y,z)==0 for y,z in ((D0,D2),(D0,C0),(D2,C0),(D0,R),(D2,R),(C0,R)))
assert sum(1 for _,v in X.items() if v)==10
# All leak contributions with a nonzero matching residual are in the zero grade.
for gg in set(g(x) for x in leak):
  if gg!=(0,0,0,0):
    assert not any(g(k)==gg for k in R)
# Previous graded sufficient lower bound is 3/2-sqrt(5/2)<0.
w=norm(D0)+norm(D2)/4
assert w==F(185,54)
assert w-norm(R)/2==F(3,2)
assert norm(h0)*norm(r0)==F(5,8)
assert F(3,2)**2 < 4*F(5,8)
# Earlier ungraded input-sensitive and uniform sufficient bounds are weaker.
assert norm(leak)>=norm(h0)
print('PASS exact rational spectral projections and grade tube failure')
for k,v in vals.items():print(k,'=',v)
print('w =',w,'grade bound = 3/2-sqrt(5/2)<0','nonzero same-grade cross = -1/8')

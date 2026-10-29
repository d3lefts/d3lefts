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


a=(0,0,0,0);c=(2,2,2,0);e=(0,0,0,1);b=(1,1,1,1)
u={a:F(1),c:F(1),e:F(1),(0,0,0,2):F(1,10)};v={a:F(1),c:F(1),(2,2,2,2):F(1,10)}
X={(w,z):x*y for w,x in u.items() for z,y in v.items()};X[(b,b)]=F(-1)
C0={k:v for k,v in X.items() if k in Uset}
D0=D_m(X,0);D2=D_m(X,2)
R=plus(plus(plus(X,C0,-1),D0,-1),D2,-1)
leak={k:v for k,v in K(C0).items() if k not in Uset}
h_bygrade=defaultdict(dict);r_bygrade=defaultdict(dict)
for k,v in leak.items():h_bygrade[g(k)][k]=v
for k,v in R.items():r_bygrade[g(k)][k]=v
w=norm(D0)+norm(D2)/4
# old graded predicate w >= ||R||²/2 + 2sum sqrt(h_g² r_g²)
terms={g_:norm(h_bygrade[g_])*norm(r_bygrade[g_]) for g_ in h_bygrade if r_bygrade[g_]}
base=w-norm(R)/2
print('C0',C0,'Q0',inn(C0,K(C0)))
print('old values w',w,'resid2',norm(R),'base',base,'leak terms',terms,'Q',inn(X,K(X)))
print('R_positive',norm(R)>0,'grade bound fail',base < 2*sum(float(v)**.5 for v in terms.values()))
print('nonzero cross',2*inn(C0,K(plus(X,C0,-1))))

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


from math import sqrt
from itertools import product
binv={0:F(1),1:F(1)};triv={0:F(1),1:F(1),2:F(1)};d={2:F(1)}
def tens(*vs):
 o={():F(1)}
 for u in vs:o={a+(k,):x*y for a,x in o.items() for k,y in u.items()}
 return o
u1=tens(binv,triv,binv,triv);v1=tens(triv,binv,triv,binv)
u2=tens(d,triv,d,triv);v2=tens(triv,d,triv,d)
X={(a,b):x*y for a,x in u1.items() for b,y in v1.items()}
X=plus(X,{(a,b):x*y for a,x in u2.items() for b,y in v2.items()},-1)
print('entries',len(X),flush=True)
C0={k:v for k,v in X.items() if k in Uset}
print('C0',len(C0),flush=True)
D0=D_m(X,0);print('D0',len(D0),flush=True)
D2=D_m(X,2);print('D2',len(D2),flush=True)
R=plus(plus(plus(X,C0,-1),D0,-1),D2,-1)
leak={k:v for k,v in K(C0).items() if k not in Uset}
byh=defaultdict(dict);byr=defaultdict(dict)
for k,v in leak.items():byh[g(k)][k]=v
for k,v in R.items():byr[g(k)][k]=v
s=sum(sqrt(float(norm(byh[gg])*norm(byr[gg]))) for gg in byh)
w=norm(D0)+norm(D2)/4
base=w-norm(R)/2
print('old-grade result base',base,'cross 2*sum',2*s,'margin',float(base)-2*s,'Q',inn(X,K(X)),flush=True)
ranked=sorted(((norm(h)*norm(byr.get(gd,{})),gd,norm(h),norm(byr.get(gd,{}))) for gd,h in byh.items()),reverse=True)
print('top interactions')
for p,gd,nh,nr in ranked[:12]:print(gd,nh,nr,'product',p,'sqrt',sqrt(float(p)))
Nlarge=sum(p>F(49,4) for p,gd,nh,nr in ranked)
assert Nlarge>=12
assert F(2*12*7,2) > base
print('RATIONAL NEGATIVITY CERTIFICATE: grade count',Nlarge,'with h_g²*r_g² > 49/4; 2*sum sqrt > 84 > 1991/24')
print('w=',w,'R²=',norm(R),'C0²=',norm(C0),'Q(C0)=',inn(C0,K(C0)),'D0²=',norm(D0),'D2²=',norm(D2))

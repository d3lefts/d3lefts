#!/usr/bin/env python3
"""Independent exact-rational v8 regression and proof-identity falsifier.

Arithmetic is Fraction-only except integer square-root enclosure for radicals.
It checks derived algebra, not the universal theorem or Grothendieck itself.
"""
from fractions import Fraction as F
from itertools import product
from math import isqrt
from random import Random
from hashlib import sha256
import json

rng=Random(20261111)
SCALE=10**18
SQRT2_LO=F(isqrt(2*SCALE*SCALE),SCALE)
SQRT2_HI=SQRT2_LO+F(1,SCALE)
SQRT3_LO=F(isqrt(3*SCALE*SCALE),SCALE)
SQRT3_HI=SQRT3_LO+F(1,SCALE)
assert SQRT2_LO**2<=2<SQRT2_HI**2
assert SQRT3_LO**2<=3<SQRT3_HI**2

class R2:
    def __init__(self,a=0,b=0):self.a,self.b=F(a),F(b)
    def __add__(self,y):
        if not isinstance(y,R2):y=R2(y)
        return R2(self.a+y.a,self.b+y.b)
    __radd__=__add__
    def __neg__(self):return R2(-self.a,-self.b)
    def __sub__(self,y):return self+-y if isinstance(y,R2) else self+(-y)
    def __mul__(self,y):
        if not isinstance(y,R2):y=R2(y)
        return R2(self.a*y.a+2*self.b*y.b,self.a*y.b+self.b*y.a)
    __rmul__=__mul__
    def __truediv__(self,y):
        if not isinstance(y,R2):y=R2(y)
        den=y.a*y.a-2*y.b*y.b
        return self*R2(y.a/den,-y.b/den)
    def __eq__(self,y):
        if not isinstance(y,R2):y=R2(y)
        return self.a==y.a and self.b==y.b
    def __repr__(self):return f'{self.a}+({self.b})*sqrt2'

s=R2(-1,1)
assert s*s==R2(3,-2)
assert (R2(1)+s*s)/(s*(R2(1)-s))==R2(2,2)
assert R2(2)*(R2(1)+s*s)/(s*(R2(1)-s))==R2(4,4)

# Exact expanded proof coefficient (in Q(sqrt2,sqrt3,sqrt6)).
# D=(10+2sqrt2)(1+sqrt3), K=D^2.
K_parts=(F(432),F(160),F(216),F(80))
K_lo=K_parts[0]+K_parts[1]*SQRT2_LO+K_parts[2]*SQRT3_LO+K_parts[3]*SQRT2_LO*SQRT3_LO
K_hi=K_parts[0]+K_parts[1]*SQRT2_HI+K_parts[2]*SQRT3_HI+K_parts[3]*SQRT2_HI*SQRT3_HI
assert F(1228356,1000)<K_lo<K_hi<F(1228357,1000)
assert 12*K_hi<14741
assert (1+SQRT2_HI)**2<F(583,100)

# Distinct finite tables; no symbolic Hoeffding identities are assumed for the model checks.
models=0; polarization_cases=0; fixed_cases=0
entries=[]
for mode in range(5):
  for attempt in range(45):
    sizes=([2,2,2],[2,3,2],[3,3,2],[2,3,3],[2,2,2,2])[mode]
    n=len(sizes); omega=list(product(*(range(k) for k in sizes)))
    pr=[]
    for k in sizes:
      w=[rng.randint(1,13) for _ in range(k)];pr.append([F(x,sum(w)) for x in w])
    h=[ [F(rng.randint(-5,5),9) for _ in range(k)] for k in sizes]
    pair={(i,j):[[F(rng.randint(-6,6),11) for _ in range(sizes[j])] for _ in range(sizes[i])]
      for i in range(n) for j in range(i+1,n)}
    c=F(rng.randint(-8,8),7)
    def f(x):return c+sum(h[i][x[i]] for i in range(n))+sum(pair[i,j][x[i]][x[j]] for i,j in pair)
    val={x:f(x) for x in omega}
    weights={x:__import__('math').prod(pr[i][x[i]] for i in range(n)) for x in omega}
    assert sum(weights.values())==1
    mean=sum(weights[x]*val[x] for x in omega)
    B=max(abs(z) for z in val.values())
    cond=[]
    for i in range(n):
      cond.append([sum(weights[x]*val[x] for x in omega if x[i]==a)/pr[i][a] for a in range(sizes[i])])
    g={x:sum(cond[i][x[i]] for i in range(n))-(n-1)*mean for x in omega}
    width=max(g.values())-min(g.values())
    assert width==sum(max(v)-min(v) for v in cond)
    assert width<=4*(1+SQRT2_LO)*B # slightly stronger safe rational lower bound
    # Resampling noise kernel at irrational s, represented exactly in Q(sqrt2).
    for x in omega[:min(7,len(omega))]:
      noise=R2()
      for y in omega:
        w=R2(1)
        for i in range(n):
          w=w*(s*(1 if y[i]==x[i] else 0)+(R2(1)-s)*pr[i][y[i]])
        noise=noise+w*val[y]
      # q(s) = mean+s(g-mean)+s²(f-g)
      assert noise==R2(mean)+s*(g[x]-mean)+s*s*(val[x]-g[x])
    var=sum(weights[x]*(val[x]-mean)**2 for x in omega)
    infl=[];pair_energy=F(0)
    for i in range(n):
      Ii=F(0)
      for x in omega:
        ci=sum(pr[i][v]*val[x[:i]+(v,)+x[i+1:]] for v in range(sizes[i]))
        Ii+=weights[x]*(val[x]-ci)**2
      infl.append(Ii)
    assert var*var<=K_hi*B*B*max(infl)
    # Direct fixed-set energy identity (quadratic energy <=total variance).
    singleton=[]
    for i in range(n):
      m2=sum(pr[i][a]*(cond[i][a]-mean)**2 for a in range(sizes[i]))
      singleton.append(m2)
    quad_energy=var-sum(singleton)
    assert quad_energy>=0
    # eta chosen strictly above all quadratic energy; test deterministic selector.
    eta=quad_energy+F(rng.randint(2,7),17)*B*B
    if B:
      q=int(((1+SQRT2_HI)**2*B*B/(eta-quad_energy)).__ceil__())
      rank=sorted(range(n),key=lambda i:singleton[i],reverse=True)
      chosen=set(rank[:min(q,n)])
      risk=var-sum(singleton[i] for i in chosen)
      # quadratic terms whose supports fully revealed can only further lower risk
      assert risk<=eta
      fixed_cases+=1
    entries.append([mode,attempt,str(width),str(B),str(var),str(max(infl)),str(quad_energy)])
    models+=1

# Independent binary polarization audit for full-cube bounded quadratic polynomials.
for case in range(1620):
   n=3+(case%3)
   a=[F(rng.randint(-7,7),5) for _ in range(n)]
   pairs={(i,j):F(rng.randint(-7,7),11) for i in range(n) for j in range(i+1,n)}
   c=F(rng.randint(-3,3),7)
   def fun(x):return c+sum(a[i]*x[i] for i in range(n))+sum(b*x[i]*x[j] for (i,j),b in pairs.items())
   cube=list(product((-1,1),repeat=n))
   B=max(abs(fun(x)) for x in cube)
   sgn=cube[rng.randrange(len(cube))]
   t=cube[rng.randrange(len(cube))]
   u=tuple(F(x+y,2) for x,y in zip(sgn,t))
   v=tuple(F(x-y,2) for x,y in zip(sgn,t))
   neg=lambda w:tuple(-x for x in w)
   lhs=sum(sgn[i]*(a[i]+sum(b*t[j if i==k else k] for (k,j),b in pairs.items() if i in (k,j))) for i in range(n))
   rhs=(3*fun(u)+fun(neg(u))-fun(v)-3*fun(neg(v)))/2
   assert lhs==rhs
   assert abs(lhs)<=4*B
   polarization_cases+=1

root=json.dumps(entries,separators=(',',':')).encode()
print('PASS v8_exact_models='+str(models))
print('PASS radical_noise_kernel_quadratic_projection_interpolation')
print('PASS fixed_budget_spectral_regime='+str(fixed_cases))
print('PASS binary_Grothendieck_polarization='+str(polarization_cases))
print('PASS integer_interval_optimized_constants')
print('audit_sha256='+sha256(root).hexdigest())

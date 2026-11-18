#!/usr/bin/env python3
"""Independent exact enumeration of pure cubic with heterogeneous binary/ternary alphabets."""
from fractions import Fraction as F
from itertools import product, combinations
from math import prod
laws=[(F(2,3), F(1,3)), (F(1,2), F(1,3), F(1,6)), (F(3,5), F(2,5)), (F(4,7), F(3,7))]
n=4
Ω=list(product(*(range(len(p)) for p in laws)))
prob={x:prod(laws[i][x[i]] for i in range(n)) for x in Ω}
base=lambda i,a,x: F(x[i]==a)-laws[i][a]
f=lambda x: base(0,1,x)*base(1,0,x)*base(2,1,x) +base(0,1,x)*base(1,2,x)*base(3,1,x)
vals={x:f(x) for x in Ω}
B=max(abs(u) for u in vals.values())
mean=sum(prob[x]*vals[x] for x in Ω)
assert mean==0
V=sum(prob[x]*vals[x]**2 for x in Ω)
I={}
for i in range(n):
    I[i]=sum(prob[x] * sum(laws[i][a]*(vals[x] - f(tuple(a if j==i else x[j] for j in range(n))))**2 for a in range(len(laws[i]))) for x in Ω)/2
    # Above is half the resampling squared difference = conditional variance
levels=[F(0) for _ in range(5)]
AV=F(0)
AJ={i:F(0) for i in range(4)}
epslist=list(product((0,1),repeat=n))
Ts=[T for k in range(n+1) for T in combinations(range(n),k)]
for x in Ω:
  for z in Ω:
    w=prob[x]*prob[z]
    y={bits: vals[tuple(x[i] if bits[i] else z[i] for i in range(n))] for bits in epslist}
    hats={T:sum((-1)**sum(bits[i] for i in T)*y[bits] for bits in epslist)/16 for T in Ts}
    assert all(hats[T]==0 for T in Ts if len(T)>3)
    for T in Ts:
      levels[len(T)]+=w*hats[T]**2
      if 1<=len(T)<=2:
        AV+=w*hats[T]**2
        for i in T:AJ[i]+=w*hats[T]**2
    for bits in epslist:
      q=sum((-1)**sum(bits[i] for i in T)*hats[T] for T in Ts if len(T)<=2)
      assert abs(q)<=5*B
assert AV==F(3,4)*V,(AV,V)
assert all(AJ[i]==F(3,8)*I[i] for i in range(n)),(AJ,I)
assert levels==[V/F(8),3*V/F(8),3*V/F(8),V/F(8),F(0)],(levels,V)
print('PASS heterogeneous categorical pure cubic; variance',V,'original influences',I)
print('replica fair Walsh levels',levels,'quadratic variance',AV,'quadratic influences',AJ,'amplitude B',B)

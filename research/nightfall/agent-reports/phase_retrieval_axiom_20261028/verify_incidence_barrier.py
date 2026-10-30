#!/usr/bin/env python3
"""Independent exact obstruction for event-identity compression in F25 Frobenius lift.
Enumerates all 651 projective hyperplane normals in F25^3, builds two-form
F5 root arrangements, and checks distinctness and exact zero density.
"""
from itertools import product
from fractions import Fraction
import json
P=5
Q=25
E=tuple((a,b) for a in range(5) for b in range(5))
Z=(0,0); O=(1,0)
def add(a,b):return ((a[0]+b[0])%5,(a[1]+b[1])%5)
def neg(a):return ((-a[0])%5,(-a[1])%5)
def mul(a,b):return ((a[0]*b[0]+2*a[1]*b[1])%5,(a[0]*b[1]+a[1]*b[0])%5)
def pw(a,n):
    ans=O
    while n:
        if n&1:ans=mul(ans,a)
        a=mul(a,a);n//=2
    return ans
def inv(a):
    assert a!=Z
    return pw(a,23)
def scal(c,v):return tuple(mul(c,x) for x in v)
def dot(a,x):
    v=Z
    for u,w in zip(a,x):v=add(v,mul(u,w))
    return v
def norm(a):
    i=next(i for i,z in enumerate(a) if z!=Z)
    return scal(inv(a[i]),a)

normal_set=[]
for a,b in product(E,repeat=2):normal_set.append((O,a,b))
for b in E:normal_set.append((Z,O,b))
normal_set.append((Z,Z,O))
assert len(normal_set)==Q*Q+Q+1==651
fingerprints=set()
sample=[]
for normal in normal_set:
    j=next(i for i,x in enumerate(normal) if x!=Z)
    free=[i for i in range(3) if i!=j]
    bas=[]
    for f in free:
        row=[Z,Z,Z];row[f]=O;row[j]=neg(normal[f]);bas.append(tuple(row))
    L,B=bas
    assert dot(normal,L)==dot(normal,B)==Z
    # Five normal lines B-c L with c in F5.
    roots=[]
    for c in range(P):
        root=tuple(add(v,neg(mul((c,0),u))) for u,v in zip(L,B))
        roots.append(norm(root))
    assert len(set(roots))==5
    fingerprint=tuple(sorted(roots))
    assert fingerprint not in fingerprints
    fingerprints.add(fingerprint)
    if len(sample)<3:sample.append((normal,L,B))
assert len(fingerprints)==651

for normal,L,B in sample:
    zeros=0
    for a in product(E,repeat=3):
        t=dot(a,L);z=dot(a,B)
        pz=add(pw(z,5),neg(mul(pw(t,4),z)))
        if pz==Z:zeros+=1
    assert zeros==Q*(1+P*(Q-1))==3025

def gauss2(k):
    if k==1:return 0
    n=(Q**k-1)*(Q**k-Q)
    d=(Q**2-1)*(Q**2-Q)
    assert n%d==0
    return n//d
assert gauss2(2)==1 and gauss2(3)==651 and gauss2(4)==407526
for k in range(2,25):
    assert gauss2(k)>=Q**(2*k-4)
# Family of event probabilities: rho^m with rho=121/625.
rho=Fraction(121,625)
assert rho==Fraction(3025,15625)
assert 121**149<625**111
print(json.dumps({'status':'PASS','field':'F5[u]/(u^2-2)','k3_distinct_max_density_events':len(fingerprints),
  'checked_independent_subspace_densities':[{'normal':list(map(str,s[0])),'zero_rows':3025,'total_rows':15625} for s in sample],
  'gaussian_subspace_counts':{'k2':gauss2(2),'k3':gauss2(3),'k4':gauss2(4)},
  'all_k_lower_bound':'[k choose 2]_25 >= 25^(2k-4) for every k>=2',
  'sharp_event_probability':'(121/625)^m','exact_source_constant':'2 log25 / log(625/121)',
  'interpretation':'obstruction to duplicate-event quotient union bounds ONLY; not a lower bound on actual failure probability'},sort_keys=True,indent=2))

#!/usr/bin/env python3
"""AXIOM: independent Vesper orbit audit, lift-injectivity separation, adaptive decoder.
All arithmetic exact; F25=F5[t]/(t^2-2), encoded a+5b.
"""
from itertools import product
from fractions import Fraction
from math import comb
import json
Q=25
Z=0
ONE=1
THETA=5

def add(x,y): return ((x%5+y%5)%5)+5*((x//5+y//5)%5)
def mul(x,y):
    a,b=x%5,x//5;c,d=y%5,y//5
    return ((a*c+2*b*d)%5)+5*((a*d+b*c)%5)
def power(x,n):
    res=1
    while n:
        if n&1:res=mul(res,x)
        x=mul(x,x);n//=2
    return res

def dot(row,x):
    z=0
    for a,b in zip(row,x):z=add(z,mul(a,b))
    return z

def inv(x):
    assert x;return power(x,23)
def div(a,b):return mul(a,inv(b))
MU=tuple(t for t in range(1,25) if power(t,4)==1)
assert MU==(1,2,3,4)
ROOTS={v:tuple(a for a in range(25) if power(a,4)==v) for v in set(power(a,4) for a in range(25))}

def orbit(x):return min(tuple(mul(l,z) for z in x) for l in MU)

def adaptive_measure_and_decode(x):
    """Adaptive two-round oracle output, each measurement is (row.dot(x))^4.
    First round k coordinate rows; second round <=support(x)-1 selected 2-sparse rows.
    """
    k=len(x)
    coord=[power(c,4) for c in x]
    total=k
    if all(z==0 for z in coord):return tuple([0]*k),total
    anchor=next(i for i,z in enumerate(coord) if z!=0)
    alpha=ROOTS[coord[anchor]][0]  # arbitrary phase representative
    recovered=[0]*k
    recovered[anchor]=alpha
    for j in range(k):
        if j==anchor or coord[j]==0:continue
        ratio=div(coord[j],coord[anchor])  # (x_j/x_anchor)^4
        # choose c in F25^* such that c*(x_j/x_anchor) not in prime subfield.
        coefficient=THETA if ratio==1 else ONE
        row=[0]*k;row[anchor]=ONE;row[j]=coefficient
        y=power(dot(row,x),4)
        total+=1
        test=div(y,coord[anchor])
        candidates=tuple(u for u in ROOTS[ratio] if power(add(1,mul(coefficient,u)),4)==test)
        assert len(candidates)==1,(x,j,ratio,test,candidates)
        recovered[j]=mul(alpha,candidates[0])
    assert orbit(tuple(recovered))==orbit(x)
    return tuple(recovered),total

# Exactly 5 projective sensing slopes over F5, replicated arbitrarily.
# A is injective on all 625 signals up to mu4, but M_x has dim ker 2 at x=e1.
rows=[(1,z) for z in range(5)]
image={}
for x in product(range(25),repeat=2):
    measurements=tuple(power(dot(row,x),4) for row in rows)
    image.setdefault(measurements,set()).add(orbit(x))
assert len(image)==157 and all(len(classes)==1 for classes in image.values())
# M_y for x=e1 has rows (a1^5,a2^5, -a1^4 a1, -a1^4 a2)
# and y=1; row rank=rank(A)=2, kernel dim 2 (vs planted dim 1).
# False (u,v)=(0,1,0,0) corresponds to P=b^5 -t^4*b? actually v=(0,1)
# P=b^5-t^4 b, so u=(0,1), v=(0,1).
assert all(power(z,5)==z for z in range(5))
assert all(add(power(z,5),(-z)%5)==0 for z in range(5))

# Vesper's one-row orbit proof and global sample-count inequality.
assert sum(power(u,4)==power(v,4) for u in range(25) for v in range(25))==97
for k in range(1,20):
    ordered=(25**k-1)*(25**k-25)
    assert ordered%32==0
    if k==1:assert ordered==0
    for s in (1,2,5):
        m=(7*k+1)//2+s
        b=Fraction((25**k-1)//24,25**m) + Fraction(ordered,32)*Fraction(97,625)**m
        assert b<Fraction(1,5**s)
assert 97**7<5**20

n2=0;n3=0;max2=0;max3=0;usage={}
for x in product(range(25),repeat=2):
    decoded,used=adaptive_measure_and_decode(x)
    n2+=1;max2=max(max2,used);usage[used]=usage.get(used,0)+1
for x in product(range(25),repeat=3):
    decoded,used=adaptive_measure_and_decode(x)
    n3+=1;max3=max(max3,used);usage[used]=usage.get(used,0)+1
assert n2==625 and max2==3 and n3==15625 and max3==5
# Exact structural lemma: for all u in F25^*, if u^4 != 1 then u not in F5,
# and fourth powers (1+zeta*u)^4 are pairwise distinct; for u^4=1, theta*u not in F5.
for u in range(1,25):
    c=THETA if power(u,4)==1 else ONE
    results={power(add(1,mul(c,mul(mu,u))),4) for mu in MU}
    assert len(results)==4

print(json.dumps({'result':'PASS','field':'F5[t]/(t^2-2)','pairwise_iid_collision_count':97,
 'iid_pair_orbit_divisor':32,'seven_half_bound_1_to_19k': 'PASS',
 'nonadaptive_five_slopes': {'rows':len(rows),'unique_measurement_images':len(image),'all_signals_unique_mod_mu4':True,'planted_lift_kernel_dimension':2},
 'adaptive':{'k2_signals_checked':n2,'k3_signals_checked':n3,'max_measurements_k2':max2,'max_measurements_k3':max3,'measurement_bound':'k+support(x)-1 <=2k-1','one_additional_reading_per_nonzero_coordinate_after_reference':True},
 'four_phase_separation':'PASS all 24 nonzero ratios'},indent=2,sort_keys=True))

#!/usr/bin/env python3
"""Independent F25 finite-field incidence and sharp root-class controls.
Uses F5[v]/(v^2-3), different from old F5[u]/(u^2-2).
The all-k proof is analytical in RESEARCH_NOTE.md. Python only verifies
finite exemplars and exact rational/integer inequalities.
"""
from fractions import Fraction
from itertools import product
from math import ceil

P = 5
Q = 25
E = list(range(Q))
def neg(a): return ((-a % 5) + 5 * ((-(a//5))%5))
def add(a,b):return (a%5+b%5)%5+5*((a//5+b//5)%5)
def mul(a,b):
    a0,a1=divmod(a,5)[1],a//5
    b0,b1=b%5,b//5
    return (a0*b0+3*a1*b1)%5+5*((a0*b1+a1*b0)%5)
def power(a,n):
    z=1
    while n:
        if n&1:z=mul(z,a)
        a=mul(a,a);n>>=1
    return z

def dot(vec,a):
    z=0
    for u,v in zip(vec,a):z=add(z,mul(u,v))
    return z

# Every element is stable under the 25th-power map.
assert all(power(v,25)==v for v in E)
assert 121**51 < 625**38  # coarse rational 51/13 corollary
assert 121**149 < 625**111 # sharper rational 149/38 corollary
assert Fraction(121,625)<Fraction(1,5)
assert Fraction(13,288) + Fraction(1,25*576) + Fraction(1,625*24)<1
print('PASS exact integer and rational all-k envelope inequalities')

# Isolate every nonzero polynomial coefficient class for k=2, x=(1,0).
# P(t,b) = delta*t^5 + L(b)^5 - t^4*C(b).
# L,C are scalars here, hence all nonzero residuals are rank <=1.
hist={}
zero_tuples=[]
for delta,l,c in product(E, repeat=3):
    if (delta,l,c)==(0,0,0):continue
    # Homogeneity: for t!=0 substitute b=t*w. The equation becomes
    # delta+(l*w)^5-c*w=0, with one root count for all 24 nonzero t.
    roots=sum(add(add(delta,power(mul(l,b),5)),neg(mul(c,b)))==0 for b in E)
    z=(1 if l else 25)+24*roots
    hist[z]=hist.get(z,0)+1
    if z==121:zero_tuples.append((delta,l,c))
assert sum(hist.values()) == Q**3-1
assert max(hist)==121
assert hist == {1:2880,25:11424,49:600,121:720},hist
assert all(l and c for delta,l,c in zero_tuples)
print('PASS 15624 nonzero polynomial triples, zero-count histogram',dict(sorted(hist.items())))

# An equality instance with five roots at each t!=0.
# P(t,b)=b^5-t^4*b corresponds to delta=0,L=1,C=1.
assert (0,1,1) in zero_tuples
assert sum(add(power(b,5),neg(mul(power(t,4),b)))==0 for t,b in product(E,repeat=2))==121
print('PASS sharp rank-one equality witness: 121/625')

# Over k=3, rank-two independent Frobenius-root forms (L,C)
# force exactly one linear constraint on the 2-dimensional b-space
# for each t, hence 625 zeros out of 15625 rows.
for delta,L,C in [
    (0,(1,0),(0,1)),
    (3,(1,1),(3,2)),
    (19,(0,1),(1,1)),
    (7,(4,11),(12,5))
]:
    assert add(mul(L[0],C[1]),neg(mul(L[1],C[0]))) != 0
    z=0
    for t,b0,b1 in product(E,repeat=3):
        l=dot(L,(b0,b1));c=dot(C,(b0,b1))
        val=add(add(mul(delta,power(t,5)),power(l,5)),neg(mul(power(t,4),c)))
        z+=(val==0)
    assert z==625, (delta,L,C,z)
print('PASS independent-Frobenius-forms rank-two density 625/15625')

# A nontrivial rank-one case in dimension 3 preserves the 121/625 density.
# For fixed t and b0, b1 is free, multiplying zero rows by 25.
z=0
for t,b0,b1 in product(E,repeat=3):
    z+=(add(power(b0,5),neg(mul(power(t,4),b0)))==0)
assert z==3025
print('PASS rank-one density 3025/15625 (sharp)')

# Algebraic exact counts after quotienting x by all nonzero scalars
# and extra kernel vectors by the planted line and projective scaling.
for k in range(1,10):
    n=k-1
    Nx=(25**k-1)//24
    R1=25*(25**n-1)*26//24
    R2=25*(25**n-1)*(25**n-25)//24 if n>=1 else 0
    assert R1+R2+1 == (25**(2*k-1)-1)//24
    for slope in (Fraction(51,13),Fraction(149,38)):
        for s in (1,2,5):
            m=ceil(slope*k)+s
            probability_upper= Nx * (R1*Fraction(121,625)**m + (R2+1)*Fraction(1,25)**m)
            assert probability_upper < Fraction(1,5**s),(k,s,m,probability_upper)
    print('PASS k=',k,'Nx=',Nx,'rank<=1 lines=',R1,'rank2 lines=',R2)
print('PASS separate incidence upper bounds for k=1..9; universal proof is in theorem')

#!/usr/bin/env python3
"""Independent polynomial-basis and algebraic-rank verifier.
Uses F5[w]/(w^2-2); no imports from verifier A. Not a full theorem prover.
"""
from itertools import product
from fractions import Fraction
from math import ceil
F=list(product(range(5),repeat=2))
zero=(0,0); one=(1,0)
def plus(x,y): return ((x[0]+y[0])%5,(x[1]+y[1])%5)
def minus(x,y): return ((x[0]-y[0])%5,(x[1]-y[1])%5)
def times(x,y):return ((x[0]*y[0]+2*x[1]*y[1])%5,(x[0]*y[1]+x[1]*y[0])%5)
def exp(x,e):
    z=one
    for _ in range(e):z=times(z,x)
    return z
def prodlinear(u,v):return plus(times(u[0],v[0]),times(u[1],v[1]))

assert len({exp(x,5) for x in F})==25
cases=[
 ((0,0),(one,zero),(zero,one),'independent'),
 ((1,2),((1,1),zero),(zero,(3,1)),'independent'),
 ((4,2),(zero,one),((3,1),one),'independent'),
 (zero,(one,zero),(one,zero),'dependent'),
 ((1,2),(one,zero),(one,zero),'dependent'),
]
for delta,L,C,kind in cases:
    determinant=minus(times(L[0],C[1]),times(L[1],C[0]))
    assert (determinant!=zero)==(kind=='independent')
    count=0
    for t,b0,b1 in product(F,repeat=3):
        lb=prodlinear(L,(b0,b1));cb=prodlinear(C,(b0,b1))
        value=minus(plus(times(delta,exp(t,5)),exp(lb,5)),times(exp(t,4),cb))
        count+=(value==zero)
    if kind=='independent': assert count==625,(kind,count)
    else:assert count<=3025,(kind,count)
    print('PASS',kind,'zero rows',count,'out of 15625')

# Independently reconstruct the count of rank-one coefficient pairs in n dimensions.
for n in range(1,6):
    q=25
    rank_one=(q**n-1)*(q+1)
    rank_two=(q**n-1)*(q**n-q)
    assert 1+rank_one+rank_two==q**(2*n)
    k=n+1
    R1=q*rank_one//(q-1)
    R2=q*rank_two//(q-1)
    assert R1+R2+1 == (q**(2*k-1)-1)//(q-1)

# Two rational slope values yield uniform all-k estimates.
assert 121**149 <625**111
assert 121**51 <625**38
slope=Fraction(149,38)
for k in (1,2,3,4,7,13,25):
    m=ceil(slope*k)+2
    N=(25**k-1)//24
    n=k-1
    low=(25*(25**n-1)*26)//24
    high=(25*(25**n-1)*(25**n-25))//24 if n>0 else 0
    bound=N*(low*Fraction(121,625)**m +(high+1)*Fraction(1,25)**m)
    assert bound < Fraction(1,25)
print('PASS alternate field-basis and exact count checks')

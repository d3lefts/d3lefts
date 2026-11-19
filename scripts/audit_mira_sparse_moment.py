#!/usr/bin/env python3
"""Finite algebra replay of Mira's sparse second-moment GHIM reduction.
Does not certify external asymptotic GHIM estimates or the sampler.
Source: GHIM https://arxiv.org/html/2601.04822v1 (Theorems 2.1-2.2).
Mira pinned source: 30ddaaad27b48df2002225c3e3f40cffd02c5253.
"""
from fractions import Fraction as Q
from itertools import product
from math import comb, factorial, lgamma, log, pi

def audit(n,d,j):
    assert 3<=d<=n and 0<=j<=n
    s0=n*(d-2);s=s0+j
    u=Q((d-1)*j,s)
    S2=(d-2)*(n*(d-3)+2*j)
    F2=j*(d-1)**2+2*(n-j)*(d-2)**2
    assert Q(S2,s)==d-3+u
    assert Q(F2,s)==2*(d-2)-(d-3)*u
    q0=-Q((d-1)**2,2)
    q1=-Q((d-2)**2,2)
    q2=-Q(S2*S2,2*s*s)
    assert q2+q0-2*q1-Q(F2,s)+2*(d-1)==1-u*u/2
    x=Q(1,(d-1)**2)
    a,b,c=n*(d-2),n*(d-1),n*d
    assert Q(a**a*c**c,b**(2*b))*Q(d-1,d)**(2*n)==(1-x)**a
    assert Q(a*c,b*b)==1-x
    r0=Q(factorial(a)*factorial(c),factorial(b)**2)*Q(d-1,d)**(2*n)
    rj=r0*Q(factorial(s),factorial(s0))*x**j
    direct=Q(factorial(s)*factorial(c),factorial(b)**2)*Q((d-1)**(2*(n-j)),d**(2*n))
    assert rj==direct

def nb(n,d,j):
    s0=n*(d-2);x=Q(1,(d-1)**2)
    return comb(s0+j,j)*(1-x)**(s0+1)*x**j

def main():
    cases=0
    for n,d in product(range(3,25),range(3,20)):
        if d>n:continue
        for j in range(n+1):
            audit(n,d,j);cases+=1
    print("EXACT_GHIM_RATIO_IDENTITIES_PASS",cases)
    for n,d in [(20,3),(20,5),(25,7),(100,3),(100,10)]:
        p=sum((nb(n,d,j) for j in range(n+1)),Q(0))
        assert 0<p<=1
        x=Q(1,(d-1)**2)
        a=n*(d-2)
        mean=Q(a+1)*x/(1-x)
        assert mean==Q(n,d)+Q(1,d*(d-2))
        var=Q(a+1)*x/(1-x)**2
        print("NB",n,d,"truncated_mass",float(p),"mean",float(mean),"var",float(var))
    for n,d in [(10,3),(30,3),(100,5),(500,20)]:
        a,b,c=n*(d-2),n*(d-1),n*d
        def rem(k):return lgamma(k+1)-(k+.5)*log(k)+k-.5*log(2*pi)
        assert abs(rem(a)+rem(c)-2*rem(b)) < 1/(12*a)+1/(12*c)+2/(12*b)+1e-10
    print("SPARSE_SECOND_MOMENT_AUDIT_PASS algebra only")

if __name__=="__main__":main()

#!/usr/bin/env python3
"""Exact small-case geometry controls and universal affine-shift proof description.

A self-test of two independently constructed formulas, not a replacement for
symbolic justification of all dimensions.
"""
from fractions import Fraction
from random import Random

def direct_geometry(A, D, t):
    n=len(A); total=Fraction(0)
    for i,a in enumerate(A):
        if a==0: continue
        for j,b in enumerate(A):
            if b==D: continue
            length=max(Fraction(0),min(Fraction(i+1),j+1-t)-max(Fraction(i),j-t))
            total+=a*(D-b)*length
    return total

def interpolation(A, D, t):
    n=len(A);k=t.numerator//t.denominator
    theta=t-k
    C=lambda m: sum(A[i]*(D-A[i+m]) for i in range(n) if 0<=i+m<n)
    return (1-theta)*C(k)+theta*C(k+1)

def self_test():
    r=Random(0xEA36)
    count=0
    for n in (1,2,4,7,11):
        for _ in range(8):
            a=[r.randint(0,32) for j in range(n)]
            for numerator in range(-4*n-1, 4*n+2):
                t=Fraction(numerator,4)
                assert direct_geometry(a,32,t)==interpolation(a,32,t),(n,a,t)
                count+=1
    return count
if __name__=='__main__':
    print('PASS: geometric overlap equals affine grid interpolation in',self_test(),'exact-rational small cases')

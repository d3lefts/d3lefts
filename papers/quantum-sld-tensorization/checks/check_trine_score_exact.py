#!/usr/bin/env python3
"""NIGHTFALL: exact independent check of an operational SLD sharpness candidate.

Checks the physical trine encoding by enumerating all 3**d input strings,
all entries of the resulting 2**d x 2**d score matrix, and the exact
Personick/SLD gain. Arithmetic is in Q(omega), omega**2+omega+1=0.
This is a finite exact checker, NOT a Lean formalization or global-priority audit.
"""
from fractions import Fraction as F
from itertools import product

ZERO=(F(0),F(0)); ONE=(F(1),F(0)); OMEGA=(F(0),F(1))
def add(x,y): return (x[0]+y[0],x[1]+y[1])
def mul(x,y):
    a,b=x;c,d=y
    return (a*c-b*d,a*d+b*c-b*d)
def sc(x,s): return (x[0]*s,x[1]*s)
def omega(n): return [ONE,OMEGA,(F(-1),F(-1))][n%3]
def get_rho(x,row,col,p,q,r):
    if row==col:return (p if row==0 else q,F(0))
    return sc(omega(-x if row==0 else x),r)
def check(d,p=F(9,10),r=F(3,20)):
    q=1-p
    assert p>0 and q>0 and r>0 and p*q>r*r, "local states not faithful"
    n=1<<d
    A=[[ZERO for _ in range(n)] for _ in range(n)]
    for xs in product(range(3),repeat=d):
        f=F(1) if sum(xs)%3==0 else F(-1,2)
        weight=f/F(3)**d
        for row in range(n):
            for col in range(n):
                term=ONE
                for j,x in enumerate(xs):
                    ib=(row>>(d-1-j))&1
                    jb=(col>>(d-1-j))&1
                    term=mul(term,get_rho(x,ib,jb,p,q,r))
                A[row][col]=add(A[row][col],sc(term,weight))
    for row in range(n):
        for col in range(n):
            want=(r**d/F(2),F(0)) if (row,col) in ((0,n-1),(n-1,0)) else ZERO
            assert A[row][col]==want,(d,row,col,A[row][col],want)
    B=[p**(d-k)*q**k for i in range(n) for k in [i.bit_count()]]
    gain=sum(F(2)*A[i][j][0]**2/(B[i]+B[j]) for i in range(n) for j in range(n))
    expected=r**(2*d)/(p**d+q**d)
    assert gain==expected
    a=2*r*r
    V=F(1,2)
    ratio=gain/(a**d*V)
    coeff=F(2)**(1-d)/(p**d+q**d)
    assert ratio==coeff
    kappa=p/q
    optimal=F(2)**(1-d)*(1+kappa)**d/(1+kappa**d)
    assert optimal==coeff
    print(f"d={d} exact gain={gain}; ratio={ratio}; full physical matrix verified")
if __name__=='__main__':
    for d in range(1,5):check(d)
    print('PASS: all trine scores, PSD conditions, gains, and optimal ratios exact.')

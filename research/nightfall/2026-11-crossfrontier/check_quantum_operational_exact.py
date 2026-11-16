#!/usr/bin/env python3
"""Exact-rational independent quantum character and SLD operational witness.
Uses Q[omega] with omega^2+omega+1=0, not NumPy or complex floats.
Finite enumeration is a checker, not an all-dimensional or POVM formal proof.
"""
from fractions import Fraction as Q
from itertools import product
from hashlib import sha256
from pathlib import Path

def add(a,b): return (a[0]+b[0],a[1]+b[1])
def mul(a,b):
    z=a[1]*b[1]
    return (a[0]*b[0]-z,a[0]*b[1]+a[1]*b[0]-z)
ONE=(Q(1),Q(0)); ZERO=(Q(0),Q(0)); W=(Q(0),Q(1)); W2=(Q(-1),Q(-1))
ROOT=(ONE,W,W2)
def check():
    cases=0
    for d in range(1,7):
        x_space=tuple(product(range(3),repeat=d))
        for mask in range(1<<d):
            accum=ZERO
            for xs in x_space:
                s=sum(xs)%3
                fx=Q(1) if s==0 else Q(-1,2)
                exp=(-sum(xs[j] for j in range(d) if mask&(1<<j)))%3
                term=tuple(fx*v for v in ROOT[exp])
                accum=add(accum,term)
            got=tuple(v/(3**d) for v in accum)
            want=(Q(1,2),Q(0)) if mask==(1<<d)-1 else ZERO
            assert got==want,(d,mask,got,want)
            cases+=1
        p,q=Q(3,4),Q(1,4)
        b0,b1=p**d,q**d
        c2=(p*q)**d/Q(4)
        gain_sld=4*c2/(b0+b1)
        ghz_prob=(b0+b1)/2
        ghz_mean_square=4*c2/(b0+b1)**2
        gain_measured=2*ghz_prob*ghz_mean_square
        gain_closed=(p*q)**d/(p**d+q**d)
        assert gain_measured==gain_sld==gain_closed
        assert 0<gain_closed<=Q(1,2)
        ratio=gain_closed/((2*p*q)**d*Q(1,2))
        assert ratio==Q(2**(d+1),3**d+1)
    for d in range(7,65):
        p,q=Q(3,4),Q(1,4)
        gain=4*((p*q)**d/4)/(p**d+q**d)
        assert gain==Q(3**d,4**d*(3**d+1))
    print(f'PASS: {cases} exact proper/full-support ternary character cases; 64 exact SLD/GHZ gains')
    print('source sha256:',sha256(Path(__file__).read_bytes()).hexdigest())
if __name__=='__main__':check()

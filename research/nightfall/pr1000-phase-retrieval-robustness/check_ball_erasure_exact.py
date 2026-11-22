#!/usr/bin/env python3
"""Independent exact-rational probe: whole-ball erasure, high-noise saturation.

Finite regression only. The universal theorem is mathematical; passing probes
does NOT constitute a proof, Lean certificate, or novelty validation.
"""
from fractions import Fraction as Q
from itertools import product
from random import Random
from hashlib import sha256
import json

rng=Random(10011234)

def row(j,h,n):
    # Deliberately depends on the *observed* history; L1 bound enforces norm <=1.
    a=[Q(((j+2)*(i+1))%7-3, (j+3)*7*n) for i in range(n)]
    attenuation=1+sum(abs(t) for t in h)
    a=[q/attenuation for q in a]
    assert sum(abs(v) for v in a) <=1
    return tuple(a)

def dot(a,x):
    return sum((ai*xi for ai,xi in zip(a,x)),Q(0))

def erasing_noise(x,sigma,j):
    h=(sigma,)*j
    intensity=dot(row(j,h,len(x)),x)**2
    return sigma-intensity

def replay(x,sigma,m):
    h=()
    for j in range(m):
        a=row(j,h,len(x))
        h=(dot(a,x)**2+erasing_noise(x,sigma,j),)+h
    return h

def pm_sq(x,z):
    return min(sum((v-w)**2 for v,w in zip(x,z)),
               sum((v+w)**2 for v,w in zip(x,z)))

def main():
    checked=0
    # General causal history; x ranges through a rational cube, filtered to ball.
    for n,m,sigma in product((2,3,5,8),(0,1,2,5,9),(Q(0),Q(1,64),Q(1,8),Q(1,2),Q(3,2))):
        for t in range(16):
            x=tuple(Q(rng.randint(-4,4), 8) for i in range(n))
            if sum(z*z for z in x)>2*sigma:
                continue
            for j in range(m):
                e=erasing_noise(x,sigma,j)
                assert -sigma<=e<=sigma
            assert replay(x,sigma,m)==(sigma,)*m
            checked+=1

    # Exact saturation at R=1, sigma=1/2, on the full unit disk. Any z
    # is defeated by a perpendicular unit signal, not by optimizing a sample.
    for k in range(41):
        z=(Q(k-20,5)*Q(3,5), Q(k-20,5)*Q(4,5))
        x=(Q(-4,5),Q(3,5))  # perpendicular to z, norm exactly one
        assert dot(z,x)==0
        assert sum(xi*xi for xi in x)==1
        assert pm_sq(z,x)==1+sum(zi*zi for zi in z)
        assert pm_sq(z,x)>=1
        for m in (0,1,3,7):
            assert replay(x,Q(1,2),m)==(Q(1,2),)*m

    # Need n>=2: sign-quotient of a real interval [0,1] has center 1/2
    # and radius 1/2 (strictly less than the n>=2 ball radius 1).
    assert max(pm_sq((Q(1,2),),(Q(0),)),
               pm_sq((Q(1,2),),(Q(1),))) == Q(1,4)

    print("PASS exact-rational full-ball erasure cases:",checked)
    print("PASS exact perpendicular minimax witnesses: 41")
    print("PASS n=1 dimension-hypothesis countercheck")
    print("STATUS: finite falsification only; full theorem still needs Lean and prior-art review")

if __name__=="__main__":
    main()

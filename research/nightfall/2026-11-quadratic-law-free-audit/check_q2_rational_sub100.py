#!/usr/bin/env python3
"""Independent exact finite check for Q2 rational (t=2/5) switching.

This is NOT a proof of the source mask identity for all sizes or the missing
Hilbert c/5 probabilistic lemma. No numerical assertion of unconditional C99.
"""
from fractions import Fraction as Q
from functools import reduce
from itertools import product
from math import sqrt
from random import Random

t=Q(2,5)
assert t*(1-t)==Q(6,25)
assert t*t==Q(4,25)
assert 2*(1+t*t)/(t*(1-t))==Q(29,3)
assert Q(26,15)**2>3
assert Q(29,6)*Q(26,15)+Q(8,5)==Q(449,45)<10

rng=Random(20261114)
count_id=count_law=0
max_ratio=0.
for n,alphabet,reps in ((2,3,50),(3,2,70),(4,2,35)):
    states=list(product(range(alphabet),repeat=n))
    masks=list(product((0,1),repeat=n))
    for _ in range(reps):
        const=Q(rng.randint(-3,3))
        h={(i,a):Q(rng.randint(-3,3)) for i in range(n)
           for a in range(alphabet)}
        k={(i,j,a,b):Q(rng.randint(-3,3))
           for i in range(n) for j in range(i+1,n)
           for a in range(alphabet) for b in range(alphabet)}
        def f(x):
            return const+sum(h[i,x[i]] for i in range(n))+sum(
                k[i,j,x[i],x[j]] for i in range(n)
                for j in range(i+1,n))
        F={x:f(x) for x in states}
        B=max(map(abs,F.values()))
        if B==0: continue
        def P(x,y):
            return sum(reduce(lambda a,b:a*b,
                    (t if mask[i] else (1-t) for i in range(n)),Q(1))
                    *F[tuple(y[i] if mask[i] else x[i] for i in range(n))]
                    for mask in masks)
        for x in states[:8]:
            yy=states if n<=3 else states[:8]
            for y in yy:
                Dy=sum(F[x[:i]+(y[i],)+x[i+1:]]-F[x] for i in range(n))
                Py=P(x,y)
                assert abs(Py)<=B
                for z in yy:
                    Dz=sum(F[x[:i]+(z[i],)+x[i+1:]]-F[x] for i in range(n))
                    Pz=P(x,z)
                    assert 6*(Dy-Dz)==25*(Py-Pz)-4*(F[y]-F[z])
                    assert Dy-Dz<=Q(29,3)*B
                    count_id+=1
        weights=[[rng.choice([0,1,1,2,3,5,7]) for _ in range(alphabet)]
                 for i in range(n)]
        for w in weights:
            if sum(w)==0: w[0]=1
        p=[[Q(w,sum(ws)) for w in ws] for ws in weights]
        section=0.
        for x in states:
            mass=reduce(lambda a,b:a*b,(p[i][x[i]] for i in range(n)),Q(1))
            u=0.
            for i in range(n):
                xs=[F[x[:i]+(a,)+x[i+1:]] for a in range(alphabet)]
                avg=sum(p[i][a]*xs[a] for a in range(alphabet))
                v=sum(p[i][a]*(xs[a]-avg)**2 for a in range(alphabet))
                assert v>=0 and 4*v<=(max(xs)-min(xs))**2
                u+=sqrt(float(v))
            section+=float(mass)*u
        ratio=section/float(B)
        assert ratio<=29/6+1e-10
        max_ratio=max(max_ratio,ratio)
        count_law+=1

print("PASS: 2/5 identity, 29/3 range, and conditional C<100, exact fractions")
print("PASS:",count_id,"rational quadratic-mask comparisons")
print("PASS:",count_law,"biased/zero-mass source tests; max section/B",round(max_ratio,8))
print("OPEN: universal shifted c/5 probabilistic lemma and end-to-end original-source Lean theorem")

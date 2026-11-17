#!/usr/bin/env python3
"""Independent exact-rational separation between global pointwise degree and
original-source L² Efron–Stein degree. Finite regression, not an infinite proof.
"""
from itertools import product
from fractions import Fraction as Q
from functools import reduce

n = 3
p = ((Q(1, 2), Q(1, 2), Q(0)),
     (Q(1, 3), Q(2, 3), Q(0)),
     (Q(2, 5), Q(3, 5), Q(0)))
X = list(product(range(3), repeat=n))
mass = {x:reduce(lambda a,b:a*b,(p[i][x[i]] for i in range(n)),Q(1))
        for x in X}
assert sum(mass.values())==1
def f(x):
    # globally pointwise cubic on NULL source configurations only
    return (Q(1, 3)*x[0]-Q(1,5)*x[1]+Q(2,7)*x[2]+
            Q(1,11)*x[0]*x[1]-Q(3,13)*x[1]*x[2]+
            Q(17)*all(x[i]==2 for i in range(n)))

def E(i, fn, x):
    return sum(p[i][a]*fn(tuple(a if j==i else x[j] for j in range(n)))
               for a in range(3))
def D(i, fn, x):
    return fn(x)-E(i,fn,x)
def DDD(fn,x):
    return D(0,lambda y:D(1,lambda z:D(2,fn,z),y),x)
def corner(fn,a,b):
    t=Q(0)
    for bits in product(range(2),repeat=n):
        x=tuple(a[i] if bits[i] else b[i] for i in range(n))
        t+=(-1)**sum(bits)*fn(x)
    return t

# Positive source atoms: third residual vanishes, despite
# nonzero global pointwise mixed difference at zero-mass inputs.
assert all(DDD(f,x)==0 for x in X if mass[x]>0)
assert sum(mass[x]*DDD(f,x)**2 for x in X)==0
null_corner=corner(f,(2,2,2),(0,0,0))
assert abs(null_corner)==17, null_corner
B=max(abs(f(x)) for x in X if mass[x]>0)
assert max(abs(f(x)) for x in X)>B

# Positive source label letters 0,1; the third label 2 is a null atom.
# A positive-cell projection retains source f on {0,1}³. On null labels,
# extend coordinatewise by the public default 0.
def retract(y):
    return tuple(a if a<2 else 0 for a in y)
def g(y):
    return f(retract(y))

assert all(corner(g,a,b)==0 for a in X for b in X)
assert max(abs(g(y)) for y in X)<=B

def mean(fn):
    return sum(mass[x]*fn(x) for x in X)
def var(fn):
    m=mean(fn)
    return sum(mass[x]*(fn(x)-m)**2 for x in X)
def influence(fn,i):
    return sum(mass[x]*D(i,fn,x)**2 for x in X)

assert var(g)==var(f)
assert all(influence(g,i)==influence(f,i) for i in range(n))
print("PASS original L2 degree-two ≠ global pointwise degree-two")
print("null-word 8-corner mixed difference:",null_corner,
      "| supported essential bound:",B)
print("supported original residual norm²:",sum(mass[x]*DDD(f,x)**2 for x in X))
print("source variance:",var(f),
      "| original heat-bath influences:",[influence(f,i) for i in range(n)])
print("PASS globally bounded coordinatewise null-word repair with exact source energies")
print("This is a finite exact regression, NOT a universal/infinite Lean certificate.")

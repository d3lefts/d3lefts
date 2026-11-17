#!/usr/bin/env python3
"""Independent exact-rational Q2 finite-cell falsification checks.
This tests finite instances, not the arbitrary-product theorem or Lean kernel.
Uses direct probability-table enumeration, not the producer's Lean operators.
"""
from fractions import Fraction as Q
from itertools import product
from functools import reduce

N = 4
p = [
    (Q(1,2), Q(1,2), Q(0)),
    (Q(1,3), Q(2,3), Q(0)),
    (Q(1,5), Q(2,5), Q(2,5)),
    (Q(2,7), Q(5,7), Q(0)),
]
labels = [(0,0,1), (0,1,1), (0,0,1), (0,0,0)]
z = [(-2,1,5), (3,-1,4), (2,-3,1), (-1,4,2)]
coef = [Q(1,3), Q(-2,5), Q(3,7), Q(-1,2)]
pairs = {(0,1):Q(1,10), (0,2):Q(-1,13), (1,3):Q(2,11), (2,3):Q(1,8)}

def f(x):
    return (sum(coef[i]*z[i][x[i]] for i in range(N)) +
            sum(c*z[i][x[i]]*z[j][x[j]] for (i,j), c in pairs.items()))

X = list(product(range(3), repeat=N))
Y = list(product(range(2), repeat=N))
weights = {x: reduce(lambda a,b:a*b, (p[i][x[i]] for i in range(N)), Q(1)) for x in X}
q = [tuple(sum(p[i][a] for a in range(3) if labels[i][a] == y)
           for y in range(2)) for i in range(N)]
def m(y):
    return reduce(lambda a,b:a*b, (q[i][y[i]] for i in range(N)), Q(1))
def label(x):
    return tuple(labels[i][x[i]] for i in range(N))

positive = {}
for y in Y:
    if m(y) > 0:
        positive[y] = (sum(weights[x] * f(x) for x in X if label(x) == y) / m(y))
defaults = [next(v for v in range(2) if q[i][v] > 0) for i in range(N)]
def g(y):
    return positive[tuple(y[i] if q[i][y[i]] else defaults[i] for i in range(N))]
def h(x):
    return g(label(x))

# Independent eight-corner degree test on all 2^4 finite label words
for y in Y:
    for abc in product(range(2), repeat=6):
        alternatives = ((abc[0],abc[1]), (abc[2],abc[3]), (abc[4],abc[5]))
        degree3 = Q(0)
        for bits in product(range(2), repeat=3):
            v = list(y)
            for j in range(3):
                v[j] = alternatives[j][bits[j]]
            degree3 += (-1)**sum(bits)*g(tuple(v))
        assert degree3 == 0, ("third difference", y, alternatives, degree3)
assert max(abs(g(y)) for y in Y) <= max(abs(f(x)) for x in X)

def variance_source(fn):
    avg = sum(weights[x] * fn(x) for x in X)
    return sum(weights[x] * (fn(x)-avg)**2 for x in X)
def influence_source(fn,i):
    return sum(weights[x] *
        (fn(x)-sum(p[i][a] * fn(tuple(a if j==i else x[j]
                                         for j in range(N))) for a in range(3)))**2
        for x in X)
def influence_labels(i):
    return sum(m(y) *
        (g(y)-sum(q[i][a]*g(tuple(a if j==i else y[j] for j in range(N)))
                  for a in range(2)))**2 for y in Y)

mean_y = sum(m(y)*g(y) for y in Y)
variance_y = sum(m(y)*(g(y)-mean_y)**2 for y in Y)
assert variance_source(h) == variance_y
for i in range(N):
    assert influence_source(h,i) == influence_labels(i)
    assert influence_labels(i) <= influence_source(f,i)
assert sum(m(y)==0 for y in Y) == 12

# Negative control: a dependent binary source defeats commuting
# conditional projections, so the product hypothesis is indispensable.
joint = {(0,0):Q(2,5), (0,1):Q(1,10),
         (1,0):Q(1,10), (1,1):Q(2,5)}
marginal = Q(1,2)
# f(x0,x1) = x1; T=E[.|x0], E0=E[.|x1].
T = {a: sum(joint[(a,b)]*b for b in range(2))/marginal for a in range(2)}
E0_T_at_00 = sum(joint[(a,0)]*T[a] for a in range(2))/marginal
T_E0_at_00 = T[0]
assert E0_T_at_00 != T_E0_at_00
print("PASS: degree-2 finite-cell extension, null labels, "
      "original/table variance and coordinate influences; exact Fractions")
print("12 zero-mass label words, variance before", variance_source(f),
      "after", variance_y)
print("source/table influences", [influence_labels(i) for i in range(N)])
print("PASS dependent-source negative control:",
      "E0(T f) at 00 =", E0_T_at_00, "; T(E0 f) at 00 =", T_E0_at_00)
print("Scope: finite exact falsification only; no infinite theorem or Lean terminal")

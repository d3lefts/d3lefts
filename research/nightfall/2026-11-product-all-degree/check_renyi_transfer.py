#!/usr/bin/env python3
"""Exact rational spot audit for the Rényi-stable query simulation draft.
This tests finite examples; it is NOT an all-instance proof or Lean certificate.
"""
from collections import defaultdict
from fractions import Fraction as Q
from itertools import combinations, product
from math import pi, sqrt

alphabets = [range(2), range(3), range(2)]
laws = [(Q(1, 5), Q(4, 5)), (Q(1, 2), Q(1, 3), Q(1, 6)),
        (Q(7, 11), Q(4, 11))]
states = list(product(*alphabets))
mu = {x: laws[0][x[0]] * laws[1][x[1]] * laws[2][x[2]] for x in states}
assert sum(mu.values()) == 1

def f(x):
    return (Q(1, 3) + Q(1, 9) * (x[0] - 1)
            + Q(1, 12) * (x[1] - 1) + Q(1, 15) * (x[2] - 1)
            + Q(1, 20) * (x[0] - 1) * (x[1] - 1))

assert all(0 <= f(x) <= 1 for x in states)

def mean(dist, fun):
    return sum((w * fun(x) for x, w in dist.items()), Q(0))

def var(dist, fun):
    m = mean(dist, fun)
    return mean(dist, lambda x: (fun(x) - m)**2)

def cond_mean(dist, fun, x, indices):
    group = [(y, w) for y, w in dist.items()
             if all(y[i] == x[i] for i in indices)]
    weight = sum((w for _, w in group), Q(0))
    assert weight > 0
    return sum((w * fun(y) for y, w in group), Q(0)) / weight

def influence(dist, fun, i):
    other = [j for j in range(3) if j != i]
    return mean(dist, lambda x: (fun(x)-cond_mean(dist, fun, x, other))**2)

def total_influence(dist, fun, free):
    return sum((influence(dist, fun, i) for i in free), Q(0))

def component(S, x):
    return sum(((-1)**(len(S)-len(T)) * cond_mean(mu, f, x, T)
                for j in range(len(S)+1) for T in combinations(S, j)), Q(0))

energy = {}
for j in range(1, 4):
    for S in combinations(range(3), j):
        energy[S] = mean(mu, lambda x: component(S, x)**2)
V = var(mu, f)
J = total_influence(mu, f, range(3))
assert V == sum(energy.values())
assert J == sum(len(S)*e for S, e in energy.items())
assert energy[(0, 1, 2)] == 0
assert J <= 2*V

for i in range(3):
    remaining = [j for j in range(3) if j != i]
    after = Q(0)
    for a in alphabets[i]:
        p = laws[i][a]
        branch = {x: w/p for x, w in mu.items() if x[i] == a}
        after += p*total_influence(branch, f, remaining)
    assert J-after == influence(mu, f, i)

raw = {x: Q(4, 3) if x[0] == x[2] else Q(2, 3) for x in states}
normalizer = mean(mu, lambda x: raw[x])
h = {x: raw[x]/normalizer for x in states}
nu = {x: mu[x]*h[x] for x in states}
assert sum(nu.values()) == 1
a, b = min(h.values()), max(h.values())
assert var(nu, f) <= b*V
for i in range(3):
    assert a*influence(mu, f, i) <= influence(nu, f, i)
    assert influence(nu, f, i) <= b*influence(mu, f, i)

event = lambda x: x[0] == x[2]
muE = mean(mu, lambda x: int(event(x)))
nuE = mean(nu, lambda x: int(event(x)))
second_moment = mean(mu, lambda x: h[x]**2)
assert nuE**2 <= second_moment*muE  # α=2 Hölder, exact.

par = {(a, b): Q(1, 4) for a in (-1, 1) for b in (-1, 1)}
parity = lambda x: Q(1+x[0]*x[1], 2)
pv = var(par, parity)
after_var = sum((Q(1, 2)*var({x: Q(1, 2) for x in par if x[0] == a}, parity)
                for a in (-1, 1)), Q(0))
assert pv == Q(1, 4) and after_var == pv  # no variance decrease!
c = 8*sqrt(3/12500)/pi**6
assert 2**1.5/c < 22000


# Exact adversarial correlated-source obstruction (two nondegenerate bits).
# The upper density stays <=2 relative to the fair independent reference,
# yet true conditional ν-influence tends to zero while Var_ν=1/4.
q = Q(1, 10000)
nucorr = {(0, 0): (1-q)/2, (1, 1): (1-q)/2,
          (0, 1): q/2, (1, 0): q/2}
muref = {x: Q(1, 4) for x in nucorr}
signal = lambda x: Q(x[0])
assert sum(nucorr.values()) == 1
assert all(0 < nucorr[x] <= 2*muref[x] for x in nucorr)
assert var(nucorr, signal) == Q(1, 4)
def true_corr_influence(i):
    others = [j for j in range(2) if j != i]
    return mean(nucorr, lambda x: (signal(x)-cond_mean(nucorr, signal, x, others))**2)
assert true_corr_influence(0) == q*(1-q)
assert true_corr_influence(1) == 0
assert true_corr_influence(0) < Q(1, 1000)
print("PASS: exact correlated-source counterexample under D_inf <= log 2")

print("PASS: exact heterogeneous degree-2 ANOVA, variance, spectral J, all J decrements")
print("PASS: exact correlated tilt, heat-bath comparisons, α=2 Hölder")
print("PASS: parity variance counterexample; numerical coefficient check")
print("V=", V, " J=", J, " density bounds=", (a, b))

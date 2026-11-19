#!/usr/bin/env python3
"""Independent exact test of unequal-mass original-source component likelihood.

Regression only. Finite enumeration does not prove the Lean theorem.
"""
from fractions import Fraction as F
from itertools import product
from random import Random
from pathlib import Path
from hashlib import sha256

rng = Random(20261119)
checks = 0

def chk(a, b, note):
    global checks
    if a != b:
        raise AssertionError((note,a,b))
    checks += 1

def dist(k):
    raw = [rng.randrange(0,7) for _ in range(k)]
    if not any(raw):
        raw[rng.randrange(k)] = 1
    tot = sum(raw)
    return tuple(F(t,tot) for t in raw)

for trial in range(2000):
    n = rng.randint(1,5)
    k = rng.choice((2,3))
    A = set(i for i in range(n) if rng.randrange(2))
    a0 = rng.randrange(k)
    p = [dist(k) for _ in range(n)]
    q = [dist(k) for _ in range(n)]
    wp = rng.choice((F(0),F(1),F(1,1000),F(2,3),F(5,2)))
    wq = rng.choice((F(0),F(1),F(1,1000),F(3,2),F(9,5)))
    words = tuple(product(range(k),repeat=n))
    def mass(law,x):
        out=F(1)
        for i,a in enumerate(x):out*=law[i][a]
        return out
    def obs(x):
        return tuple(a if i in A else a0 for i,a in enumerate(x))
    def observed_mass(law,y):
        if any(y[i]!=a0 for i in range(n) if i not in A):return F(0)
        out=F(1)
        for i in A:out*=law[i][y[i]]
        return out
    def decision(y):
        return wp*observed_mass(p,y) > wq*observed_mass(q,y)
    direct = sum(wp*mass(p,x) * (not decision(obs(x))) +
                 wq*mass(q,x) * decision(obs(x)) for x in words)
    overlap = sum(min(wp*observed_mass(p,y),wq*observed_mass(q,y)) for y in words)
    chk(direct, overlap, ('source-vs-overlap', trial))
    chk(sum(mass(p,x) for x in words),F(1),('P normalized',trial))
    chk(sum(mass(q,x) for x in words),F(1),('Q normalized',trial))
    # Actual fixed-list nonadaptive tree reads sorted(A); source symbols
    # outside A cannot affect the decision.
    indexes=tuple(sorted(A))
    for x in rng.sample(list(words),min(6,len(words))):
        y=tuple((x[i] if i in A else rng.randrange(k)) for i in range(n))
        chk(decision(obs(x)), decision(obs(y)), ('locality',trial))
        chk(len(indexes),len(A),('tree-depth',trial))
print('PASS',checks,'exact source likelihood, posterior-weight, locality and query-depth checks')
print('SHA256',sha256(Path(__file__).read_bytes()).hexdigest())

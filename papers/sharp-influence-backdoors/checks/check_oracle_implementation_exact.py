#!/usr/bin/env python3
"""Independent exact finite checks of the conditional quadratic-observer mechanics.

It does NOT verify universal Q2 influence, concentration, a sampling oracle,
external novelty, or a Lean terminal theorem. Python standard library only.
"""
from fractions import Fraction as F
from itertools import product, combinations
from random import Random

rng = Random(20261112)
checks = 0


def evaluate(coeff, x):
    c, lin, pair = coeff
    v = c + sum(lin[i] * x[i] for i in range(len(x)))
    v += sum(w * x[i] * x[j] for (i, j), w in pair.items())
    return v


def moments(coeff, probs, revealed):
    # Direct table enumeration under independent, possibly heterogeneous biases.
    n = len(probs)
    unknown = tuple(i for i in range(n) if i not in revealed)
    out = []
    for vals in product((-1, 1), repeat=len(unknown)):
        x = [revealed.get(i) for i in range(n)]
        mass = F(1)
        for j, i in enumerate(unknown):
            x[i] = vals[j]
            p = probs[i]
            mass *= p if vals[j] == 1 else (1-p)
        out.append((tuple(x), mass, evaluate(coeff, x)))
    mean = sum((pr * v for _, pr, v in out), F(0))
    var = sum((pr * (v - mean)**2 for _, pr, v in out), F(0))
    influences = {}
    for i in unknown:
        inf = F(0)
        for x, pr, val in out:
            y = list(x); y[i] = -x[i]
            pflip = (1-probs[i]) if x[i] == 1 else probs[i]
            inf += pr * pflip * (val - evaluate(coeff, tuple(y)))**2 / 2
        influences[i] = inf
    return mean, var, influences


for n in (2, 3, 4, 5):
    for attempt in range(8):
        probs = [rng.choice([F(1,2),F(1,3),F(1,5),F(4,5)]) for _ in range(n)]
        coeff = (F(rng.randint(-2,2)),
                 [F(rng.randint(-2,2)) for _ in range(n)],
                 {(i,j):F(rng.randint(-2,2)) for i in range(n) for j in range(i+1,n)})
        for size in range(n):
            for obs in combinations(range(n), size):
                for vals in product((-1,1), repeat=size):
                    revealed = dict(zip(obs, vals))
                    _, var, influences = moments(coeff, probs, revealed)
                    p = sum(influences.values(), F(0))
                    assert var <= p <= 2 * var, (n, attempt, revealed, var, p)
                    checks += 1
                    for i, I in influences.items():
                        next_p = F(0)
                        for s, pr in ((1,probs[i]),(-1,1-probs[i])):
                            _, _, after = moments(coeff, probs, {**revealed, i:s})
                            next_p += pr * sum(after.values(), F(0))
                        assert p - next_p == I, (n, attempt, revealed, i, p, next_p, I)
                        checks += 1
print(f"PASS {checks} exact finite ANOVA and posterior-influence-drift assertions")
print("SCOPE: finite rational tests; concentration and general theorem are analytic")

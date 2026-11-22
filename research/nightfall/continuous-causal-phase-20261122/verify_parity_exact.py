#!/usr/bin/env python3
"""Independent exact-arithmetic audit of causal two-colour history identities.

Tests finite algebraic parity/transcript identities; it does NOT certify the
product Borsuk-Ulam zero, Tietze extension, global theorem, or novelty.
"""
from fractions import Fraction as Q
from random import Random

def policy(j, history, n):
    # Nontrivial continuous rational dependence on the first two readings.
    a = [Q(((3*j + 5*i + 1) % 11) - 5, 17) for i in range(n)]
    for k, h in enumerate(history[:2]):
        f = h / (1 + h)
        for i in range(n):
            a[i] += f * Q(((i + 2*j + 3*k) % 7) - 3, 101)
    return a

def dot(a, b):
    return sum((x*y for x, y in zip(a, b)), Q(0))

def artificial(u, v, assignment):
    n = len(u)
    h, g = [], []
    for j, tag in enumerate(assignment):
        a = policy(j, h, n)
        killed, survivor = (u, v) if tag == 'U' else (v, u)
        g.append(dot(a, killed))
        h.append(dot(a, survivor)**2)
    return h, g

def actual(x, m):
    h = []
    for j in range(m):
        a = policy(j, h, len(x))
        h.append(dot(a, x)**2)
    return h

def check():
    rng = Random(20261122)
    trials = 0
    for n in range(2, 7):
        m = 2*n - 2
        assignment = ['U' if j%2 == 0 else 'V' for j in range(m)]
        assert assignment.count('U') <= n-1
        assert assignment.count('V') <= n-1
        for _ in range(24):
            u = [Q(rng.randint(-4,4),rng.randint(1,5)) for _ in range(n)]
            v = [Q(rng.randint(-4,4),rng.randint(1,5)) for _ in range(n)]
            h, g = artificial(u, v, assignment)
            h1, g1 = artificial([-x for x in u], v, assignment)
            h2, g2 = artificial(u, [-x for x in v], assignment)
            assert h == h1 == h2
            assert all(g1[j] == (-g[j] if tag == 'U' else g[j])
                       for j, tag in enumerate(assignment))
            assert all(g2[j] == (-g[j] if tag == 'V' else g[j])
                       for j, tag in enumerate(assignment))
            # Independent original-history formula, checked at any exact zero.
            xp = [u[i]+v[i] for i in range(n)]
            xm = [u[i]-v[i] for i in range(n)]
            tp, tm = actual(xp, m), actual(xm, m)
            if all(c == 0 for c in g):
                assert tp == tm == h
            trials += 1
    print(f'PASS: {trials} exact rational parity cases (n=2..6).')
    print('Finite algebraic checks only; existence of zero needs topology.')

if __name__ == '__main__':
    check()

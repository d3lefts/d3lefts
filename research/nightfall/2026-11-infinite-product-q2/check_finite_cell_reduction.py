#!/usr/bin/env python3
"""Exact-rational falsification oracle for the finite-cell reduction
(Lemma 4 of PROOF.md). It attacks algebraic errors only; it does not
prove density, conditional-expectation factorization or the infinite
limit. Laws include zero-probability letters; partitions are random.

Checks, for a pointwise degree-<=2 table f on a finite heterogeneous
product and the cell-conditional table phi on positive-mass cells:
  (a) |phi| <= B where B = max |f| on positive-mass words;
  (b) source variance of h = phi(Y) equals native variance of phi;
  (c) source influence of h equals native heat-bath influence of phi;
  (d) phi is pointwise degree two on positive cells;
  (e) every influence and the variance contract: I_i(phi) <= I_i(f);
  (f) the identity partition reproduces f exactly.
"""
from fractions import Fraction as Fr
from itertools import product, combinations
import random, sys

def rand_law(k, rng):
    w = [rng.randint(0, 4) for _ in range(k)]
    if sum(w) == 0: w[0] = 1
    if rng.random() < 0.7 and k > 2: w[rng.randrange(k)] = 0          # zero atom
    if sum(w) == 0: w[-1] = 3
    s = sum(w); return [Fr(x, s) for x in w]

def mass(laws, x):
    m = Fr(1)
    for i, a in enumerate(x): m *= laws[i][a]
    return m

def words(sizes): return list(product(*[range(k) for k in sizes]))

def mean(laws, sizes, g): return sum(mass(laws, x) * g(x) for x in words(sizes))
def var(laws, sizes, g):
    m = mean(laws, sizes, g); return sum(mass(laws, x) * (g(x) - m) ** 2 for x in words(sizes))
def upd(x, i, b): y = list(x); y[i] = b; return tuple(y)
def infl(laws, sizes, g, i):
    return sum(mass(laws, x) * (g(x) - sum(laws[i][b] * g(upd(x, i, b)) for b in range(sizes[i]))) ** 2
               for x in words(sizes))

def deg2_table(sizes, rng):
    n = len(sizes); parts = {}
    for S in [()] + [(i,) for i in range(n)] + list(combinations(range(n), 2)):
        parts[S] = {xs: Fr(rng.randint(-6, 6), rng.randint(1, 4)) for xs in product(*[range(sizes[i]) for i in S])}
    return lambda x: sum(t[tuple(x[i] for i in S)] for S, t in parts.items())

def pointwise_deg2(sizes, g):
    n = len(sizes)
    for i, j, k in combinations(range(n), 3):
        for x in words(sizes):
            for a, b, c in product(range(sizes[i]), range(sizes[j]), range(sizes[k])):
                s = Fr(0)
                for ea, eb, ec in product((0, 1), repeat=3):
                    y = list(x)
                    if ea: y[i] = a
                    if eb: y[j] = b
                    if ec: y[k] = c
                    s += (-1) ** (ea + eb + ec) * g(tuple(y))
                if s != 0: return False
    return True

def trial(rng, identity=False):
    n = rng.choice([3, 4]); sizes = [rng.randint(2, 4) for _ in range(n)]
    laws = [rand_law(k, rng) for k in sizes]; f = deg2_table(sizes, rng)
    cell = [list(range(k)) if identity else [rng.randrange(max(1, k - 1)) for _ in range(k)] for k in sizes]
    pos = [sorted({cell[i][a] for a in range(sizes[i]) if laws[i][a] > 0}) for i in range(n)]
    idx = [{c: r for r, c in enumerate(p)} for p in pos]
    nu = [[sum(laws[i][a] for a in range(sizes[i]) if cell[i][a] == c) for c in pos[i]] for i in range(n)]
    csz = [len(p) for p in pos]
    assert all(v > 0 for row in nu for v in row)
    def phi(y):
        num = den = Fr(0)
        for x in words(sizes):
            m = mass(laws, x)
            if m and all(cell[i][x[i]] == pos[i][y[i]] for i in range(n)):
                num += m * f(x); den += m
        return num / den
    tab = {y: phi(y) for y in words(csz)}; ph = lambda y: tab[y]
    def h(x):  # h = phi(Y(x)) on support; arbitrary-but-fixed off support
        return tab[tuple(idx[i].get(cell[i][x[i]], 0) for i in range(n))]
    B = max(abs(f(x)) for x in words(sizes) if mass(laws, x) > 0)
    ok = {}
    ok['a'] = max(abs(v) for v in tab.values()) <= B
    ok['b'] = var(laws, sizes, h) == var(nu, csz, ph)
    ok['c'] = all(infl(laws, sizes, h, i) == infl(nu, csz, ph, i) for i in range(n))
    ok['d'] = pointwise_deg2(csz, ph)
    ok['e'] = (all(infl(nu, csz, ph, i) <= infl(laws, sizes, f, i) for i in range(n))
               and var(nu, csz, ph) <= var(laws, sizes, f))
    if identity:
        ok['f'] = var(nu, csz, ph) == var(laws, sizes, f) and all(
            infl(nu, csz, ph, i) == infl(laws, sizes, f, i) for i in range(n))
    return ok

def main():
    seed = int(sys.argv[1]) if len(sys.argv) > 1 else 20261117
    trials = int(sys.argv[2]) if len(sys.argv) > 2 else 60
    rng = random.Random(seed); fails = 0
    for t in range(trials):
        ok = trial(rng, identity=(t % 10 == 0))
        if not all(ok.values()):
            fails += 1; print('FAIL trial', t, ok)
    print(f'{"PASS" if fails == 0 else "FAIL"}: {trials - fails}/{trials} trials, seed {seed}')
    sys.exit(1 if fails else 0)

if __name__ == '__main__': main()

#!/usr/bin/env python3
"""Independent finite audit: sharper TV bound, exact N=2 sign sectors, support rank.

Fractions for probability and TV computations, no randomness or third-party
dependencies. DOES NOT certify arbitrary N, the Gaussian arcsine identity or Lean.
"""
from fractions import Fraction as F
from itertools import combinations, product
from math import log, pi


def entropy(values):
    return -sum(float(p) * log(float(p)) for p in values if p > 0)


def h2(t):
    return entropy((t, 1 - t))


def phi(t):
    if t == 1:
        return log(2)
    return ((1 + t) * log(1 + t) + (1 - t) * log(1 - t)) / 2


def marg(p, axis):
    out = {}
    for k, v in p.items():
        out[k[axis]] = out.get(k[axis], F(0)) + v
    return out


def hcond(p):
    return entropy(p.values()) - entropy(marg(p, 1).values())


def mi(p):
    return entropy(marg(p, 0).values()) + entropy(marg(p, 1).values()) - entropy(p.values())


def tv(p, q):
    return sum((abs(p.get(k, F(0)) - q.get(k, F(0)))
                for k in p.keys() | q.keys()), F(0)) / 2


def rank(mat):
    a = [[F(x) for x in row] for row in mat]
    m, n = len(a), len(a[0])
    r = 0
    for j in range(n):
        pivot = next((i for i in range(r, m) if a[i][j]), None)
        if pivot is None:
            continue
        a[r], a[pivot] = a[pivot], a[r]
        v = a[r][j]
        a[r] = [x / v for x in a[r]]
        for i in range(m):
            if i != r:
                v = a[i][j]
                a[i] = [x - v * y for x, y in zip(a[i], a[r])]
        r += 1
        if r == m:
            break
    return r


def exact_n2_forrelation():
    H = ((1, 1), (1, -1))
    reps = ((2, 1), (1, 2), (-1, 2), (-2, 1),
            (-2, -1), (-1, -2), (1, -2), (2, -1))
    p = {}
    for z in reps:
        f = tuple(1 if t > 0 else -1 for t in z)
        g = tuple(1 if sum(H[j][i] * z[i] for i in range(2)) > 0
                  else -1 for j in range(2))
        p[f, g] = p.get((f, g), F(0)) + F(1, 8)
    assert len(p) == 8 and set(p.values()) == {F(1, 8)}
    rows = sorted({k[0] for k in p})
    cols = sorted({k[1] for k in p})
    assert all(x == F(1, 4) for x in marg(p, 0).values())
    assert all(x == F(1, 4) for x in marg(p, 1).values())
    mat = [[p.get((f, g), F(0)) for g in cols] for f in rows]
    assert rank(mat) == 3, rank(mat)

    # Every nonnegative product factor's support must be a rectangle.
    support = set(p)
    rectangles = []
    for u in range(1, 1 << 4):
        for v in range(1, 1 << 4):
            rectangle = {(rows[i], cols[j]) for i in range(4)
                         for j in range(4) if (u >> i & 1) and (v >> j & 1)}
            if rectangle <= support:
                rectangles.append(rectangle)
    assert max(map(len, rectangles)) == 2
    assert len(support) == 8
    # Four components suffice: fix F, and G|F has two outputs
    # differing in exactly one coordinate, hence a product distribution.
    for f in rows:
        possible = [g for g in cols if (f, g) in support]
        assert len(possible) == 2
        assert sum(a != b for a, b in zip(*possible)) == 1
    assert abs(mi(p) - log(2)) < 1e-12
    print("PASS N=2 exact Gaussian-sector distribution; rank=3, minimum M=4")
    return p, rows, cols


def continuity_exhaustive():
    atoms = tuple(product((0, 1), repeat=2))
    laws = []
    for a in range(7):
        for b in range(7-a):
            for c in range(7-a-b):
                d = 6-a-b-c
                laws.append({x: F(k, 6) for x, k in zip(atoms, (a, b, c, d))})
    trials = 0
    for p, q in combinations(laws, 2):
        e = float(tv(p, q))
        assert abs(hcond(p) - hcond(q)) <= e*log(2) + h2(e) + 1e-12
        trials += 1
    assert trials == 3486
    print(f"PASS classical conditional entropy continuity for {trials} rational pairs")


def robust_n2(p, rows, cols):
    uniform = {(f, g): F(1, 16) for f in rows for g in cols}
    point = {(f, g): F(int((f, g) == (rows[0], cols[0])))
             for f in rows for g in cols}
    for r in (uniform, point):
        for t in (F(1, 100), F(1, 10), F(1, 4)):
            q = {x: (1-t)*p.get(x, F(0)) + t*r[x] for x in uniform}
            e = float(tv(p, q))
            # Dimension N=2; the exact N=2 mutual information is log 2.
            assert mi(q) + 1e-12 >= mi(p) - 4*e*log(2) - 2*h2(e)
            # Strong universal Forrelation certificate (conservative at N=2).
            assert mi(q) + 1e-12 >= 2*phi(2/pi)-4*e*log(2)-2*h2(e)
    print("PASS exact-rational TV examples, including nonuniform marginals")


def rates():
    e = 0.01
    c = phi(2/pi)
    old = c - 4*e*log(2)
    new = c - 2*e*log(2)
    assert .2053376 < new < .2053377 and new > old
    print(f"phi(2/pi)={c:.12f}; previous TV rate={old:.12f}; "
          f"new TV rate={new:.12f}; offset={2*h2(e):.12f}")
    print(f"positive asymptotic rate for eta < {c/(2*log(2)):.12f}")


if __name__ == "__main__":
    continuity_exhaustive()
    p, rows, cols = exact_n2_forrelation()
    robust_n2(p, rows, cols)
    rates()
    print("PASS (finite checker, not general proof or Lean certificate)")

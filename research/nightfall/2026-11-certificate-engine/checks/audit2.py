"""Independent audit of new claims (exact rational arithmetic where possible).
(1) Where-Influence-Lives exact witness: rows valid, V, I, L, loads p,q, B^2.
(2) Pointer tree h_{2,r} on FAIR BITS (r=2): degree exactly r+1, every fixed q-set explains <= q/2^r.
(3) Level-crossing theorem on random product spaces with LP rows:
    max_j Pr(f(X)>t>=f(X^(j))) >= E[(f-t)_+/|a|] E[(t-f)_+/|a|] at t = E f (and >= (E|f-Ef|)^2/(4K^2)).
"""
import itertools, math, random
from fractions import Fraction as Fr
import numpy as np
from scipy.optimize import linprog

# ---------- (1)
mu1 = {0: Fr(3, 4), 1: Fr(1, 4)}; mu2 = {0: Fr(1, 16), 1: Fr(15, 16)}
pts = [(a, b) for a in (0, 1) for b in (0, 1)]
mu = {x: mu1[x[0]] * mu2[x[1]] for x in pts}
f = {x: Fr(x[0] * (1 + x[1]), 2) for x in pts}
rows = {(0, 0): (Fr(1, 2), Fr(1, 2)), (0, 1): (Fr(1), Fr(0)), (1, 0): (Fr(1, 2), Fr(1, 2)), (1, 1): (Fr(1), Fr(1, 2))}
for x in pts:
    for y in pts:
        assert abs(f[x] - f[y]) <= sum(rows[x][i] for i in range(2) if x[i] != y[i]), (x, y)
Ef = sum(mu[x] * f[x] for x in pts); V = sum(mu[x] * (f[x] - Ef) ** 2 for x in pts)
margs = [mu1, mu2]
def res(x, j, s): y = list(x); y[j] = s; return tuple(y)
I = [sum(mu[x] * margs[j][s] * (f[x] - f[res(x, j, s)]) ** 2 for x in pts for s in (0, 1)) / 2 for j in range(2)]
L = [2 * sum(mu[x] * margs[j][s] * abs(f[x] - f[res(x, j, s)]) for x in pts for s in (0, 1)) for j in range(2)]
print("(1) V", V, "I", I, "L", L)
m = 0  # median claimed
assert sum(mu[x] for x in pts if f[x] <= m) >= Fr(1, 2) and sum(mu[x] for x in pts if f[x] >= m) >= Fr(1, 2)
nrm = {x: sum(rows[x]) for x in pts}
P = [sum(mu[x] * (f[x] - m) ** 3 * rows[x][j] / nrm[x] ** 2 for x in pts if f[x] > m) for j in range(2)]
Q = [sum(mu[x] * rows[x][j] / nrm[x] ** 2 for x in pts if f[x] <= m) for j in range(2)]
p = [v / sum(P) for v in P]; q = [v / sum(Q) for v in Q]
B2 = sum(math.sqrt(p[j] * q[j]) for j in range(2)) ** 2
print("    p", p, "q", q, "B^2 %.10f" % B2, "claimed 0.8186142140")
R = [j for j in range(2) if 5 * sum(L) * I[j] < 2 * V * L[j]]
print("    R =", R)

# ---------- (2) pointer tree on fair bits, n=2, r=2: coords = selectors s0 (root), s1,s2 (children), leaves z0..z3
names = ["s0", "s1", "s2", "z0", "z1", "z2", "z3"]
def h(b):
    s0, s1, s2, *z = b
    child = s1 if s0 == 0 else s2
    leaf = 2 * s0 + child
    return 1 if z[leaf] else -1
W = list(itertools.product((0, 1), repeat=7))
vals = {w: h(w) for w in W}
# Fourier degree on {0,1}^7 with chi_S = prod (-1)^{w_i}
deg = 0
for S in itertools.chain.from_iterable(itertools.combinations(range(7), k) for k in range(8)):
    c = sum(vals[w] * (-1) ** sum(w[i] for i in S) for w in W)
    if c != 0: deg = max(deg, len(S))
worst = Fr(0)
for qq in range(0, 8):
    for S in itertools.combinations(range(7), qq):
        cond = {}
        for w in W:
            key = tuple(w[i] for i in S); cond.setdefault(key, []).append(vals[w])
        ev = sum(Fr(len(v), 128) * Fr(sum(v), len(v)) ** 2 for v in cond.values())
        worst = max(worst, ev / max(qq, 1) * 4 if qq else ev)
        assert ev <= Fr(qq, 4), (S, ev)
print("(2) fair-bit pointer tree: Fourier degree", deg, "(claim 3); all fixed sets satisfy Var(E[h|S]) <= q/4: OK")

# ---------- (3) level crossing
rng = np.random.default_rng(11); worst3 = 0
for trial in range(1200):
    n = int(rng.integers(1, 4)); sizes = [int(rng.integers(2, 4)) for _ in range(n)]
    ms = [rng.dirichlet(np.ones(s) * 0.5) + 1e-9 for s in sizes]; ms = [v / v.sum() for v in ms]
    P_ = list(itertools.product(*[range(s) for s in sizes]))
    mu_ = {x: float(np.prod([ms[i][x[i]] for i in range(n)])) for x in P_}
    F = {x: float(rng.normal()) for x in P_}
    rows_ = {}
    for x in P_:
        A = [[-(1.0 if x[i] != y[i] else 0.0) for i in range(n)] for y in P_ if y != x]
        bb = [-abs(F[x] - F[y]) for y in P_ if y != x]
        r = linprog(rng.exponential(size=n) ** 3, A_ub=A, b_ub=bb, bounds=[(0, None)] * n, method="highs")
        rows_[x] = np.maximum(r.x, 0)
    t = sum(mu_[x] * F[x] for x in P_)
    V1 = sum(mu_[x] * max(F[x] - t, 0) / rows_[x].sum() for x in P_)
    V0 = sum(mu_[x] * max(t - F[x], 0) / rows_[x].sum() for x in P_)
    cross = max(sum(mu_[x] * ms[j][s] for x in P_ for s in range(sizes[j])
                    if F[x] > t >= F[x[:j] + (s,) + x[j + 1:]]) for j in range(n))
    if V1 * V0 > 0: worst3 = max(worst3, V1 * V0 / cross)
print("(3) level crossing: worst ratio (averaged-cost RHS)/(max crossing) = %.6f (must be <= 1)" % worst3)

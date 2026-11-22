#!/usr/bin/env python3
"""Audit for UPSTREAM_DIMENSION_CONTROLLED_TRANSFER_20261122.md.

A. Hadamard-sign obstruction (Theorem 2): exact rational arithmetic at n=8, exact float
   enumeration at n=16 (all 1- and 2-marginals, all 3-marginals at n=8), closed form for E_nu f.
B. Degree-1 dimension-free transfer (Theorem 1): exact check of the termwise inequality on random
   instances with random adaptive trees.
C. Scale-aware chi-square transfer (Theorem 4): Risk_nu <= Risk_Q + sqrt(Risk_Q) * LD_K on random
   cube instances, LD_K computed exactly from Fourier coefficients.
"""
import itertools, math, sys
from fractions import Fraction as Fr
import numpy as np

def sylvester(n):
    H = np.array([[1]])
    while H.shape[0] < n:
        H = np.block([[H, H], [H, -H]])
    return H

FAIL = []
def check(cond, msg):
    if not cond:
        FAIL.append(msg); print("FAIL", msg)

# ---------------- A. obstruction ----------------
def obstruction(n, kmax, exact):
    H = sylvester(n)
    X = ((np.arange(2 ** n)[:, None] >> np.arange(n)) & 1) * 2 - 1
    S = X @ H
    if exact:
        half = Fr(1, 2)
        Py = [[Fr(1) if s > 0 else (Fr(0) if s < 0 else half) for s in row] for row in S]
        Px = [[Fr(1) if v > 0 else Fr(0) for v in row] for row in X]
        P = [px + py for px, py in zip(Px, Py)]
        N = Fr(1, 2 ** n)
    else:
        P = np.concatenate([(X > 0).astype(float), np.where(S > 0, 1., np.where(S < 0, 0., .5))], 1)
    Ef_enum = Fr(int(np.abs(S).sum()), 2 ** n * n)          # (1/n) sum_j E|(H^T x)_j|
    # closed form: E|S_n| = n * C(n, n/2) / 2^n  (n even)
    E_abs = Fr(n * math.comb(n, n // 2), 2 ** n)
    worst = {}
    m = 2 * n
    for k in range(1, kmax + 1):
        best = 0
        for U in itertools.combinations(range(m), k):
            tv = 0
            for b in itertools.product([0, 1], repeat=k):
                if exact:
                    tot = Fr(0)
                    for row in P:
                        pr = Fr(1)
                        for c, bb in zip(U, b):
                            pr *= row[c] if bb else 1 - row[c]
                        tot += pr
                    tv += abs(tot * N - Fr(1, 2 ** k))
                else:
                    pr = np.ones(len(P))
                    for c, bb in zip(U, b):
                        pr = pr * (P[:, c] if bb else 1 - P[:, c])
                    tv += abs(pr.mean() - 2.0 ** -k)
            best = max(best, tv / 2)
        worst[k] = best
    return E_abs, Ef_enum, worst

print("A. Hadamard-sign obstruction")
for n, kmax, ex in [(8, 3, True), (16, 2, False)]:
    E_abs, Ef_enum, worst = obstruction(n, kmax, ex)
    Ef = float(E_abs) / math.sqrt(n)            # E_nu f = n^{-3/2} * n * E|S_n|
    if ex:
        check(Ef_enum == E_abs, f"n={n}: enumeration of E|(H^T x)_j| != E|S_n| closed form")
    print(f"  n={n}: E_nu f = {Ef:.6f} (limit {math.sqrt(2/math.pi):.6f}), E_U f = 0, E_U f^2 = 1/n;"
          f" max k-marginal TV = " + ", ".join(f"k={k}: {float(v):.6f}" for k, v in worst.items())
          + f"; sqrt(n)*max = {math.sqrt(n)*float(max(worst.values())):.4f}")
    check(worst[1] == 0, f"n={n}: 1-marginals not exactly uniform")
    check(Ef > 0.77, f"n={n}: E_nu f too small")
    check(math.sqrt(n) * float(max(worst.values())) < 0.45, f"n={n}: marginal TV not O(1/sqrt n)")
    # |f|<=1 certificate: ||H||_op = sqrt n
    H = sylvester(n)
    check(np.allclose(H @ H.T, n * np.eye(n)), "Hadamard")

# ---------------- B. degree-1 transfer ----------------
print("B. Degree-1 dimension-free transfer (termwise inequality)")
rng = np.random.default_rng(20261122)

def random_tree(n, q, A, rng):
    """adaptive tree as nested tuples: ('leaf', value) | ('q', i, [children per letter])"""
    if q == 0:
        return ('leaf', rng.random())
    i = int(rng.integers(n))
    return ('q', i, [random_tree(n, q - 1, A, rng) for _ in range(A)])

def leaf_of(t, x, path=()):
    while t[0] == 'q':
        path = path + ((t[1], x[t[1]]),); t = t[2][x[t[1]]]
    return path, t[1]

ntrials = 0
for trial in range(60):
    n, A, q = int(rng.integers(3, 6)), int(rng.integers(2, 4)), int(rng.integers(0, 3))
    pts = list(itertools.product(range(A), repeat=n))
    nu = rng.dirichlet(np.ones(len(pts)) * 0.3)
    Qm = rng.dirichlet(np.ones(A), size=n)
    Q = np.array([np.prod([Qm[i][x[i]] for i in range(n)]) for x in pts])
    g = rng.normal(size=(n, A)); g -= g.mean(1, keepdims=True)
    osc = g.max(1) - g.min(1); g /= osc.sum(); g -= (g.max(1) + g.min(1))[:, None] / 2
    G = np.array([sum(g[i][x[i]] for i in range(n)) for x in pts])          # |G|<=1/2
    c = 0.5
    f = c + G                                                              # f in [0,1]
    T = random_tree(n, q, A, rng)
    tv = [leaf_of(T, x) for x in pts]
    Tv = np.array([v for _, v in tv])
    risk = lambda w: w @ (f - Tv) ** 2
    dR = abs(risk(nu) - risk(Q))
    def law_tv(keyfun):
        d = {}
        for w, x in zip(nu - Q, pts):
            k = keyfun(x); d[k] = d.get(k, 0) + w
        return sum(abs(v) for v in d.values()) / 2
    A_T = law_tv(lambda x: leaf_of(T, x)[0])
    A_Ti = max(law_tv(lambda x, i=i: (leaf_of(T, x)[0], x[i])) for i in range(n))
    d2 = max(law_tv(lambda x, i=i, j=j: (x[i], x[j])) for i in range(n) for j in range(n))
    o = g.max(1) - g.min(1)
    bound = (1.5 ** 2) * A_T + 2 * 2 * 1.5 * (o.sum() / 2) * A_Ti + (o.sum() ** 2 / 2) * d2
    check(dR <= bound + 1e-12, f"deg-1 transfer violated trial {trial}: {dR} > {bound}")
    ntrials += 1
print(f"  {ntrials} random instances (alphabets 2-3, n 3-5, adaptive depth 0-2): all satisfy the bound")

# ---------------- C. chi-square transfer ----------------
print("C. Scale-aware low-degree chi-square transfer")
def chars(n):
    return [S for k in range(n + 1) for S in itertools.combinations(range(n), k)]
cnt = 0
for trial in range(60):
    n, d, q = 6, int(rng.integers(1, 3)), int(rng.integers(0, 3))
    pts = np.array(list(itertools.product([-1, 1], repeat=n)))
    nu = rng.dirichlet(np.ones(2 ** n) * 0.5)
    r = nu * 2 ** n                                                   # density wrt uniform
    K = max(2 * d, d + q)
    chi = {S: np.prod(pts[:, list(S)], 1) if S else np.ones(2 ** n) for S in chars(n)}
    LD = math.sqrt(sum((chi[S] @ r / 2 ** n) ** 2 for S in chars(n) if 0 < len(S) <= K))
    # random bounded degree-d f in [0,1]
    p = sum(rng.normal() * chi[S] for S in chars(n) if len(S) <= d)
    f = (p - p.min()) / (p.max() - p.min())
    T = random_tree(n, q, 2, rng)
    Tv = np.array([leaf_of(T, ((x + 1) // 2).tolist())[1] for x in pts])
    RU = np.mean((f - Tv) ** 2); Rn = nu @ (f - Tv) ** 2
    check(Rn <= RU + math.sqrt(RU) * LD + 1e-12, f"chi2 transfer violated trial {trial}")
    cnt += 1
print(f"  {cnt} random instances (n=6, d<=2, adaptive depth<=2, arbitrary nu): all satisfy the bound")

print("RESULT:", "FAIL" if FAIL else "PASS")
sys.exit(1 if FAIL else 0)

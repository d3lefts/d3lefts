"""Numerical check of the component-identification lemma (binary case).

Checks, on random and adversarial small instances:
 (B) Bernstein step: for every assignment x_L of the large-gap coordinates,
     |E_{P_R} f_{x_L} - E_{Q_R} f_{x_L}| <= (pi/4) d gamma_R / c.
 (T) TV step: TV(P_L, Q_L) >= 1 - 2 delta / (|u - v| - 3 eps)
     where delta = max(Pr_P[|f-u|>eps], Pr_Q[|f-v|>eps]).
Exact enumeration, n <= 10.
"""

import itertools
import math
import sys

import numpy as np

from progress_experiment import all_points, product_weights


def rand_lowdeg(rng, n, d, X):
    v = np.zeros(len(X))
    for S in itertools.chain.from_iterable(itertools.combinations(range(n), k) for k in range(d + 1)):
        if rng.random() < 0.5:
            v += rng.normal() * X[:, list(S)].prod(axis=1) if S else rng.normal()
    lo, hi = v.min(), v.max()
    return (v - lo) / (hi - lo) if hi > lo else np.full(len(X), 0.5)


def cond_mean(f, w, mask):
    m = w[mask].sum()
    return (f[mask] * w[mask]).sum() / m


def check(seed, trials=400, n=8):
    rng = np.random.default_rng(seed)
    X = all_points(n)
    worst_B, worst_T, tested_T = 0.0, 1.0, 0
    for _ in range(trials):
        d = int(rng.integers(1, 4))
        c = rng.uniform(0.05, 0.4)
        eps = rng.uniform(0.02, 0.12)
        eta0 = 4 * eps * c / (math.pi * d)
        q = rng.uniform(c, 1 - c, n)
        # mix of large and small gaps
        gaps = np.where(rng.random(n) < 0.4,
                        rng.uniform(eta0, 0.5, n),
                        rng.uniform(0, eta0 * 0.999, n)) * rng.choice([-1, 1], n)
        p = np.clip(q + gaps, c, 1 - c)
        f = rand_lowdeg(rng, n, d, X)
        P, Q = product_weights(n, p), product_weights(n, q)
        L = [i for i in range(n) if abs(p[i] - q[i]) >= eta0]
        R = [i for i in range(n) if i not in L]
        gR = max([abs(p[i] - q[i]) for i in R], default=0.0)
        # (B): every assignment of L
        bound = (math.pi / 4) * d * gR / c
        for a in itertools.product((0, 1), repeat=len(L)):
            mask = np.ones(len(X), bool)
            for i, b in zip(L, a):
                mask &= X[:, i] == b
            diff = abs(cond_mean(f, P, mask) - cond_mean(f, Q, mask))
            if bound > 0:
                worst_B = max(worst_B, diff / bound)
            elif diff > 1e-12:
                worst_B = float("inf")
        # (T): choose u, v as best centres; test when |u - v| > 3 eps
        def centre(w):
            best = (2.0, 0.0)
            for u in np.linspace(0, 1, 201):
                fail = w[np.abs(f - u) > eps].sum() / w.sum()
                best = min(best, (fail, u))
            return best
        dP, u = centre(P)
        dQ, v = centre(Q)
        if abs(u - v) > 3 * eps:
            delta = max(dP, dQ)
            # TV of the L-marginals
            PL = {}
            QL = {}
            for a in itertools.product((0, 1), repeat=len(L)):
                mask = np.ones(len(X), bool)
                for i, b in zip(L, a):
                    mask &= X[:, i] == b
                PL[a], QL[a] = P[mask].sum() / P.sum(), Q[mask].sum() / Q.sum()
            overlap = sum(min(PL[a], QL[a]) for a in PL)
            allowed = 2 * delta / (abs(u - v) - 3 * eps)
            tested_T += 1
            worst_T = min(worst_T, allowed - overlap)  # must be >= 0
    return worst_B, worst_T, tested_T


if __name__ == "__main__":
    seed = int(sys.argv[1]) if len(sys.argv) > 1 else 0
    wb, wt, nt = check(seed)
    print(f"seed {seed}: max (B) ratio diff/bound = {wb:.4f} (must be <= 1)")
    print(f"seed {seed}: min (T) slack allowed-overlap = {wt:.4g} over {nt} separated cases (must be >= 0)")

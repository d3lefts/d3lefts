#!/usr/bin/env python3
"""Independent FUR(2) LP: globally shared-fiber rows, independent of the transition proof.

Numerically finds candidates via SciPy HiGHS, then EXACTLY certifies each
rounded-up rational candidate against ALL pairwise row inequalities.
No numeric LP optimum is claimed as an exact lower bound.
"""
from fractions import Fraction as F
from itertools import combinations
from math import ceil
from random import Random
import argparse
import numpy as np
from scipy.optimize import linprog
from scipy.sparse import lil_matrix


def fvals(n, seed):
    r = Random(20261119 + seed + n * 997)
    c = [F(r.randint(-8, 8), 11) for _ in range(n)]
    p = {(i, j): F(r.randint(-8, 8), 13) for i, j in combinations(range(n), 2)}
    raw = []
    for x in range(1 << n):
        raw.append(sum((c[i] * (x >> i & 1) for i in range(n)), F(0)) +
                   sum((p[i, j] * (x >> i & 1) * (x >> j & 1) for i, j in p), F(0)))
    lo, hi = min(raw), max(raw)
    return [(v - lo) / (hi - lo) if hi > lo else F(0) for v in raw]


def idx(n, x, j):
    return j * (1 << (n - 1)) + (x & ((1 << j) - 1)) + ((x >> (j + 1)) << j)


def solve(n, seed):
    f = fvals(n, seed)
    N = 1 << n
    D = n * (N // 2)
    pairs = [(x, y) for x in range(N) for y in range(x + 1, N) if f[x] != f[y]]
    mat = lil_matrix((len(pairs) + N, D + 1), dtype=float)
    rhs = np.zeros(len(pairs) + N)
    for row, (x, y) in enumerate(pairs):
        rhs[row] = -float(abs(f[x] - f[y]))
        for j in range(n):
            if x >> j & 1 != y >> j & 1:
                mat[row, idx(n, x, j)] = -1
    for x in range(N):
        row = len(pairs) + x
        for j in range(n):
            mat[row, idx(n, x, j)] = 1
        mat[row, D] = -1
    obj = np.zeros(D + 1)
    obj[-1] = 1
    res = linprog(obj, A_ub=mat.tocsr(), b_ub=rhs, bounds=[(0, None)] * (D + 1), method="highs")
    if not res.success:
        raise AssertionError((n, seed, res.message))
    scale = 10**8
    # Numerical LP provides candidates ONLY. Exact verification below is the certificate.
    w = [F(max(0, ceil(z * scale)), scale) + F(1, 10**6) for z in res.x[:D]]
    for x, y in pairs:
        observed = sum((w[idx(n, x, j)] for j in range(n) if x >> j & 1 != y >> j & 1), F(0))
        assert observed >= abs(f[x] - f[y]), (n, seed, x, y)
    C = max(sum((w[idx(n, x, j)] for j in range(n)), F(0)) for x in range(N))
    assert C < F(166), ("violates conservative bound", n, seed, C)
    return n, seed, float(C), float(res.fun), len(pairs)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--seeds", type=int, default=20)
    args = parser.parse_args()
    out = []
    for n in (3, 4, 5, 6):
        for seed in range(args.seeds):
            out.append(solve(n, seed))
    for n in (3, 4, 5, 6):
        vals = [x for x in out if x[0] == n]
        print(f"n={n}, seeds={len(vals)}, max_exact_feasible_cost={max(x[2] for x in vals):.10f}, "
              f"max_numeric_LP_optimum={max(x[3] for x in vals):.10f}, "
              f"pairs_up_to={max(x[4] for x in vals)}")
    print(f"PASS {len(out)} independent LP instances; each candidate row and its budget "
          "rechecked using exact rationals")


if __name__ == "__main__":
    main()

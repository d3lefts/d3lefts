"""Search for counterexamples to sum_i |G(u)-G(u^i)| <= 2 D^2 (claimed FHKL Thm 3.3).
Maximize sum_i eps_i (G(1) - G(1^i)) over multilinear G of degree <= D, |G|<=1 on {-1,1}^n.
By symmetry it suffices to use G depending only on (#flips in S, #flips in S^c), |S|=a.
"""
import itertools, sys
import numpy as np
from scipy.optimize import linprog

def run(n, D, a):
    S = list(range(a)); Sc = list(range(a, n))
    mons = [m for r in range(D + 1) for m in itertools.combinations(range(n), r)]
    pts = list(itertools.product([1, -1], repeat=n))
    A = np.array([[np.prod([p[i] for i in m]) if m else 1.0 for m in mons] for p in pts])
    one = tuple([1] * n)
    def row(p): return A[pts.index(p)]
    obj = np.zeros(len(mons))
    for i in range(n):
        q = list(one); q[i] = -1
        diff = row(one) - row(tuple(q))
        obj += diff if i in S else -diff     # S: G drops when flipped; S^c: G rises
    res = linprog(-obj, A_ub=np.vstack([A, -A]), b_ub=np.ones(2 * len(pts)),
                  bounds=[(None, None)] * len(mons), method="highs")
    return -res.fun

for D in (1, 2, 3):
    for n in range(D, 10 if D < 3 else 9):
        best = max((run(n, D, a), a) for a in range(0, n + 1))
        print(f"D={D} n={n} max={best[0]:.4f} (a={best[1]})  2D^2={2*D*D}", flush=True)

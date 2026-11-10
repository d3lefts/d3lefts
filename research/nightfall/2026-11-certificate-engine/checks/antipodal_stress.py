"""Adversarial test of the imported antipodal inequality as stated in main.tex eq (2.1):
sum_{u in Z} 1/sum_i w_i l^u_i l^{-u}_i <= sum_i b_i / w_i,
Z={u: g(u)=1, g(-u)=0}, b_i=#{u: g(u)=1, g(u^i)=0}, rows: l>=0, sum_{Delta(u,v)} l >= 1 when g(u)!=g(v).
Rows are random LP vertices (small rows maximize LHS)."""
import itertools, random
import numpy as np
from scipy.optimize import linprog
random.seed(1); np.random.seed(1)
worst = 0.0
for k in (2, 3, 4):
    V = list(itertools.product([1, -1], repeat=k))
    idx = {v: j for j, v in enumerate(V)}
    tables = itertools.product([0, 1], repeat=len(V)) if k <= 3 else (tuple(np.random.randint(0, 2, len(V))) for _ in range(300))
    for g in tables:
        Z = [u for u in V if g[idx[u]] == 1 and g[idx[tuple(-x for x in u)]] == 0]
        if not Z: continue
        b = [sum(1 for u in V if g[idx[u]] == 1 and g[idx[tuple(-u[j] if j == i else u[j] for j in range(k))]] == 0) for i in range(k)]
        for trial in range(6):
            rows = {}
            for u in V:
                A = [[-(1.0 if u[i] != v[i] else 0.0) for i in range(k)] for v in V if g[idx[v]] != g[idx[u]]]
                c = np.random.exponential(size=k) ** 3
                r = linprog(c, A_ub=A, b_ub=[-1.0] * len(A), bounds=[(0, None)] * k, method="highs")
                rows[u] = r.x
            w = np.random.exponential(size=k) ** 2
            lhs = sum(1.0 / sum(w[i] * rows[u][i] * rows[tuple(-x for x in u)][i] for i in range(k)) for u in Z)
            rhs = sum(b[i] / w[i] for i in range(k))
            worst = max(worst, lhs / rhs)
    print(f"k={k}: worst LHS/RHS so far = {worst:.6f}", flush=True)

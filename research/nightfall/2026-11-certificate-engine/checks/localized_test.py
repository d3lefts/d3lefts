"""Test on random finite product spaces (arbitrary masses):
 (T1) two-sided:  V1*V0 <= max_j I_j
 (T2) localized:  V1*V0 <= sum_j sqrt(I_j X_j Y_j)
 where V1=E[1{g=1}/|l|], X_j=E[1{g=1} l_j/|l|^2], I_j=Pr(g(X)=1,g(X^(j))=0) (resampling).
 (T3) real localized threshold: W1*W0 <= sum_j sqrt(1.5*L_j*X_j*Y_j), L_j = 2E|f-f^(j)|,
      W1=E[(f-r)_+^3/|a|], W0=E[1{f<=r}/|a|], X_j=E[(f-r)_+^3 a_j/|a|^2], Y_j=E[1{f<=r} a_j/|a|^2].
 Rows: random LP vertices of the row polytope (small rows are the adversarial case)."""
import itertools, random, math
import numpy as np
from scipy.optimize import linprog
rng = np.random.default_rng(7)

def rows_for(vals, pts, n, scale_fn):
    rows = {}
    for x in pts:
        A, b = [], []
        for y in pts:
            d = abs(vals[x] - vals[y])
            if d > 0:
                A.append([-(1.0 if x[i] != y[i] else 0.0) for i in range(n)]); b.append(-d)
        if not A:
            rows[x] = np.ones(n); continue
        c = rng.exponential(size=n) ** 3
        r = linprog(c, A_ub=A, b_ub=b, bounds=[(0, None)] * n, method="highs")
        rows[x] = np.maximum(r.x, 0)
    return rows

worst = {"T1": 0, "T2": 0, "T3": 0}
for trial in range(1500):
    n = int(rng.integers(1, 4)); sizes = [int(rng.integers(2, 4)) for _ in range(n)]
    masses = [rng.dirichlet(np.ones(s) * 0.4) + 1e-9 for s in sizes]
    masses = [m / m.sum() for m in masses]
    pts = list(itertools.product(*[range(s) for s in sizes]))
    mu = {x: float(np.prod([masses[i][x[i]] for i in range(n)])) for x in pts}
    # Boolean part
    g = {x: int(rng.integers(0, 2)) for x in pts}
    if len(set(g.values())) == 2:
        lam = rows_for(g, pts, n, None)
        V1 = sum(mu[x] / lam[x].sum() for x in pts if g[x] == 1)
        V0 = sum(mu[x] / lam[x].sum() for x in pts if g[x] == 0)
        X = [sum(mu[x] * lam[x][j] / lam[x].sum() ** 2 for x in pts if g[x] == 1) for j in range(n)]
        Y = [sum(mu[x] * lam[x][j] / lam[x].sum() ** 2 for x in pts if g[x] == 0) for j in range(n)]
        I = [sum(mu[x] * masses[j][s] for x in pts for s in range(sizes[j])
                 if g[x] == 1 and g[x[:j] + (s,) + x[j+1:]] == 0) for j in range(n)]
        lhs = V1 * V0
        worst["T1"] = max(worst["T1"], lhs / max(I))
        worst["T2"] = max(worst["T2"], lhs / sum(math.sqrt(I[j] * X[j] * Y[j]) for j in range(n)))
    # real part
    f = {x: float(rng.integers(-3, 4)) for x in pts}
    if len(set(f.values())) >= 2:
        a = rows_for(f, pts, n, None)
        vs = sorted(set(f.values()))
        r = vs[int(rng.integers(0, len(vs) - 1))]
        W1 = sum(mu[x] * (f[x] - r) ** 3 / a[x].sum() for x in pts if f[x] > r)
        W0 = sum(mu[x] / a[x].sum() for x in pts if f[x] <= r)
        X = [sum(mu[x] * (f[x] - r) ** 3 * a[x][j] / a[x].sum() ** 2 for x in pts if f[x] > r) for j in range(n)]
        Y = [sum(mu[x] * a[x][j] / a[x].sum() ** 2 for x in pts if f[x] <= r) for j in range(n)]
        L = [2 * sum(mu[x] * masses[j][s] * abs(f[x] - f[x[:j] + (s,) + x[j+1:]]) for x in pts for s in range(sizes[j])) for j in range(n)]
        rhs = sum(math.sqrt(1.5 * L[j] * X[j] * Y[j]) for j in range(n))
        worst["T3"] = max(worst["T3"], W1 * W0 / rhs)
print({k: round(v, 6) for k, v in worst.items()})

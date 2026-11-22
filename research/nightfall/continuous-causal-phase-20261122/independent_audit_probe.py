"""Independent falsification probe for PR #995 (continuous causal phase retrieval, m <= 2n-2).

Different method from the PR's phase_collision_probe.py:
  * random smooth history-dependent policies (tanh networks of the full history), mixed colourings;
  * zero of the (Z/2)^2-equivariant map g found by Levenberg-Marquardt / TRF on S^{n-1} x S^{n-1}
    (float64), actual transcripts then recomputed in 80-bit extended precision (np.longdouble);
  * the ACTUAL causal transcripts of x+ = u+v and x- = u-v are recomputed independently with the
    original policy (no virtual history) and compared;
  * generalized responses (Section 7 of the passport + rank-k blocks): y = Phi(h, B(h) x), Phi even;
  * negative control: m = 2n-1 with a fixed generic frame (no zero should exist).
"""
import numpy as np, itertools
from scipy.optimize import least_squares
rng = np.random.default_rng(995)

def make_policy(n, ranks, rng):
    # stage j: B_j(h) = C_j + D_j * tanh(E_j h + f_j)  (k_j x n), continuous in h
    P = []
    for j, k in enumerate(ranks):
        hd = max(j, 1)
        P.append(dict(C=rng.normal(size=(k, n)), D=rng.normal(size=(k, n, 3)),
                      E=rng.normal(size=(3, hd)), f=rng.normal(size=3)))
    return P

def B_of(p, h, lib):
    dt = lib
    hh = np.array(h if len(h) else [0.0], dtype=dt)
    t = np.tanh(p['E'].astype(dt) @ hh + p['f'].astype(dt))
    return p['C'].astype(dt) + p['D'].astype(dt) @ t

PHI = {
  'square': lambda z, lib: sum(zi * zi for zi in z),
  'even_nonpoly': lambda z, lib: (np.cos(sum(zi*zi for zi in z)) + sum(abs(zi) for zi in z) ** 3),
}

def virtual_g(P, colours, phi, u, v, lib):
    h, g = [], []
    for p, c in zip(P, colours):
        B = B_of(p, h, lib)
        Bu = [sum(B[r][i] * u[i] for i in range(len(u))) for r in range(len(B))]
        Bv = [sum(B[r][i] * v[i] for i in range(len(v))) for r in range(len(B))]
        if c == 'U': g += Bu; h = h + [PHI[phi](Bv, lib)]
        else:        g += Bv; h = h + [PHI[phi](Bu, lib)]
    return g

def transcript(P, phi, x, lib):
    h = []
    for p in P:
        B = B_of(p, h, lib)
        z = [sum(B[r][i] * x[i] for i in range(len(x))) for r in range(len(B))]
        h = h + [PHI[phi](z, lib)]
    return h

def solve(n, ranks, colours, phi, tries=40):
    P = make_policy(n, ranks, rng)
    def F(w):
        u, v = w[:n], w[n:]
        g = virtual_g(P, colours, phi, u, v, np.float64)
        return np.array(g + [u @ u - 1, v @ v - 1])
    best = None
    for _ in range(tries):
        w0 = rng.normal(size=2 * n)
        w0[:n] /= np.linalg.norm(w0[:n]); w0[n:] /= np.linalg.norm(w0[n:])
        r = least_squares(F, w0, method='lm' if len(F(w0)) >= 2 * n else 'trf', xtol=1e-15, ftol=1e-15, gtol=1e-15)
        if best is None or r.cost < best.cost: best = r
        if r.cost < 1e-26: break
    return P, best

def polish_and_check(P, colours, phi, n, w):
    L = np.longdouble
    W = np.array(w, dtype=L)
    u, v = W[:n] / np.sqrt(W[:n] @ W[:n]), W[n:] / np.sqrt(W[n:] @ W[n:])
    res = max(abs(x) for x in virtual_g(P, colours, phi, u, v, L))
    xp, xm = u + v, u - v
    tp, tm = transcript(P, phi, xp, L), transcript(P, phi, xm, L)
    disc = max(abs(a - b) for a, b in zip(tp, tm)) / max(1, max(abs(a) for a in tp))
    sep = min(np.linalg.norm((xp - xm).astype(float)), np.linalg.norm((xp + xm).astype(float)))
    return float(disc), float(sep), float(res)

print("POSITIVE: m <= 2n-2 (collision must exist)")
cases = [(3, [1]*4, 'square'), (4, [1]*6, 'square'), (5, [1]*8, 'square'),
         (4, [1]*6, 'even_nonpoly'), (5, [2, 1, 2, 1, 2], 'square'), (5, [2, 2, 1, 2, 1], 'even_nonpoly')]
allok = True
for n, ranks, phi in cases:
    # colouring: greedy partition of ranks into two bins of capacity n-1
    colours, cu, cv = [], 0, 0
    for k in ranks:
        if cu + k <= n - 1: colours.append('U'); cu += k
        else: colours.append('V'); cv += k
    assert cv <= n - 1
    P, r = solve(n, ranks, colours, phi)
    disc, sep, res = polish_and_check(P, colours, phi, n, r.x)
    ok = disc < 1e-12 and res < 1e-12 and sep > 0.1
    allok &= ok
    print(f"  n={n} ranks={ranks} phi={phi} colours={''.join(colours)}: virtual residual={res:.2e} "
          f"actual-transcript rel. discrepancy={disc:.2e} separation={sep:.3f} {'OK' if ok else 'FAIL'}")

print("NEGATIVE CONTROL: m = 2n-1 fixed generic frame (no virtual zero for any split)")
for n in (3, 4):
    m = 2 * n - 1
    A = rng.normal(size=(m, n))
    worst = np.inf
    for split in itertools.product('UV', repeat=m):
        U = [i for i in range(m) if split[i] == 'U']; V = [i for i in range(m) if split[i] == 'V']
        # zero needs u in ker A_U, v in ker A_V, both nonzero: impossible iff one block has rank n
        ru = np.linalg.matrix_rank(A[U]) if U else 0; rv = np.linalg.matrix_rank(A[V]) if V else 0
        worst = min(worst, max(ru, rv))
    print(f"  n={n}, m={m}: every split has a full-rank block: {worst == n}")
    allok &= worst == n
print("RESULT:", "PASS" if allok else "FAIL")

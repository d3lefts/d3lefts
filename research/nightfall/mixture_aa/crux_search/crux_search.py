"""Falsification search for the Mixture-AA crux (PR #919).

Crux (informal): if Var_nu(f) >= tau, some coordinate j has either
  A_j = sum_theta pi_theta L_{theta,j}(f) >= c(d, tau)     (within-component increment), or
  I_j = I(theta; x_j) >= c(d, tau)                          (component information),
with c independent of the number of components M.

We minimise C = max_j max(A_j, I_j) over degree-<=d functions f: {0,1}^n -> [0,1] and mixtures
of M product laws, subject to Var_nu(f) >= tau, and watch how min C behaves as M grows.
"""
import itertools, sys, json
import numpy as np
from scipy.optimize import minimize

def setup(n, d):
    pts = np.array(list(itertools.product([0, 1], repeat=n)), dtype=float)  # 2^n x n
    sets = [S for k in range(d + 1) for S in itertools.combinations(range(n), k)]
    chi = np.stack([np.prod(1 - 2 * pts[:, list(S)], axis=1) if S else np.ones(len(pts)) for S in sets], 1)
    # index of x with bit j flipped
    flip = np.array([[int(''.join(str(int(b)) for b in np.where(np.arange(n) == j, 1 - x, x)), 2)
                      for j in range(n)] for x in pts])
    return pts, chi, flip

def evaluate(f, w, P, pts, flip):
    """f: values on 2^n points; w: (M,) weights; P: (M,n) probs of bit=1."""
    M, n = P.shape
    # component point masses (M x 2^n)
    mass = np.prod(np.where(pts[None, :, :] == 1, P[:, None, :], 1 - P[:, None, :]), axis=2)
    nu = w @ mass
    mean = nu @ f
    V = nu @ (f - mean) ** 2
    # A_j: sum_theta w_theta * E_{x~mu_theta, b~mu_theta_j} |f(x) - f(x_j:=b)|
    # resample x_j: differs only if b != x_j; prob of b != x_j is P (if x_j=0) or 1-P (if x_j=1)
    diff = np.abs(f[:, None] - f[flip])               # 2^n x n
    pchange = np.where(pts[None, :, :] == 0, P[:, None, :], 1 - P[:, None, :])  # M x 2^n x n
    A = np.einsum('m,mx,mxj,xj->j', w, mass, pchange, diff)
    # I_j = I(theta; x_j)
    def h(p):
        p = np.clip(p, 1e-15, 1 - 1e-15)
        return -(p * np.log(p) + (1 - p) * np.log(1 - p))
    pbar = w @ P
    I = h(pbar) - w @ h(P)
    return V, A, I

def unpack(z, n, M, nS):
    c = z[:nS]
    w = np.exp(z[nS:nS + M] - z[nS:nS + M].max()); w /= w.sum()
    P = 1 / (1 + np.exp(-z[nS + M:].reshape(M, n)))
    return c, w, P

def search(n, d, M, tau, seeds=20, rng=None):
    pts, chi, flip = setup(n, d)
    nS = chi.shape[1]
    best = None
    for s in range(seeds):
        z0 = np.concatenate([rng.normal(0, 0.5, nS), rng.normal(0, 1, M), rng.normal(0, 3, M * n)])
        z0[0] = 0.5
        def obj(z):
            c, w, P = unpack(z, n, M, nS)
            f = chi @ c
            V, A, I = evaluate(f, w, P, pts, flip)
            C = np.max(np.maximum(A, I))
            pen = 200 * (np.sum(np.maximum(0, -f) ** 2) + np.sum(np.maximum(0, f - 1) ** 2))
            pen += 200 * max(0.0, tau - V) ** 2 * 100
            return C + pen
        r = minimize(obj, z0, method='L-BFGS-B', options={'maxiter': 3000})
        c, w, P = unpack(r.x, n, M, nS)
        f = chi @ c
        # project to a feasible [0,1]-valued degree-d function (affine map keeps degree)
        lo, hi = f.min(), f.max()
        if lo < 0 or hi > 1:
            f = (f - lo) / max(hi - lo, 1e-12) if hi - lo > 1 else f - min(lo, 0) - max(hi - 1, 0)
        V, A, I = evaluate(f, w, P, pts, flip)
        if V < tau * 0.98:
            continue
        C = float(np.max(np.maximum(A, I)))
        if best is None or C < best[0]:
            best = (C, float(V), float(A.max()), float(I.max()), int((w > 1e-3).sum()))
    return best

if __name__ == '__main__':
    n, d, tau = int(sys.argv[1]), int(sys.argv[2]), float(sys.argv[3])
    Ms = [int(m) for m in sys.argv[4].split(',')]
    seeds = int(sys.argv[5]) if len(sys.argv) > 5 else 20
    rng = np.random.default_rng(1)
    for M in Ms:
        b = search(n, d, M, tau, seeds, rng)
        print(json.dumps({'n': n, 'd': d, 'M': M, 'tau': tau, 'minC': b and b[0], 'V': b and b[1],
                          'maxA': b and b[2], 'maxI': b and b[3], 'activeM': b and b[4]}), flush=True)

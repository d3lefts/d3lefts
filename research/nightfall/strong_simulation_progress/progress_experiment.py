"""Exact small-instance test bench for coordinate-selection rules in
strong (log 1/delta) classical simulation.

Model.  A bounded function f: {0,1}^n -> [0,1] (the acceptance probability of a
query algorithm, degree <= 2T), and a known input law mu given by unnormalised
point weights (product or finite mixture of products).  A classical decision
tree queries coordinates adaptively and outputs a constant c at each leaf.  It
FAILS on z if |f(z) - c| > eps.  We count queries only; computation is free.

Rules compared (all use exact conditional laws, so mixtures are handled via the
posterior automatically):
  var      one-step variance reduction  Var(E[f | z_i])
  inf      resampling influence          E|f(z) - f(z^{i <- z_i'})|
  thr      thresholded influence         Pr[|f(z) - f(z^{i <- z_i'})| > eps]
  bad      bad-set influence             E[|f(z) - f(z^{i <- z_i'})| ; z in B]
           where B = {z : |f(z) - c*| > eps} for the current best leaf c*.
Stopping (all greedy rules): stop when the conditional bad mass is <= delta.
OPT: minimum worst-case depth over all trees with total failure <= delta
(exact DP over restrictions; small n only).
"""

from __future__ import annotations

import itertools
import math
from functools import lru_cache

import numpy as np


# ---------------------------------------------------------------- utilities

def all_points(n):
    idx = np.arange(1 << n)
    return ((idx[:, None] >> np.arange(n)) & 1).astype(np.int8)


def product_weights(n, p):
    X = all_points(n)
    p = np.asarray(p, float)
    return np.prod(np.where(X == 1, p, 1 - p), axis=1)


def mixture_weights(n, comps):
    """comps: list of (prior, bias-vector)."""
    return sum(pr * product_weights(n, p) for pr, p in comps)


def best_leaf(vals, w, eps):
    """Constant c minimising the mass of {|f - c| > eps}; returns (c, bad_mass)."""
    if w.sum() == 0:
        return 0.0, 0.0
    order = np.argsort(vals)
    v, ww = vals[order], w[order]
    cw = np.concatenate([[0.0], np.cumsum(ww)])
    total = cw[-1]
    best, bc = -1.0, v[0]
    j = 0
    for i in range(len(v)):  # window [v[i], v[i] + 2 eps]
        while j < len(v) and v[j] <= v[i] + 2 * eps + 1e-12:
            j += 1
        covered = cw[j] - cw[i]
        if covered > best:
            best, bc = covered, v[i] + eps
    return bc, total - best


# ---------------------------------------------------------------- greedy trees

class Instance:
    def __init__(self, f, w, name=""):
        self.f = np.asarray(f, float)
        self.w = np.asarray(w, float)
        self.n = int(round(math.log2(len(self.f))))
        self.name = name
        self.idx = np.arange(len(self.f))


def scores(inst, mask, free, eps, rule):
    f, w = inst.f, inst.w * mask
    tot = w.sum()
    c, _ = best_leaf(f[mask], inst.w[mask], eps)
    bad = (np.abs(f - c) > eps + 1e-12) & mask
    out = {}
    for i in free:
        j = inst.idx ^ (1 << i)
        # conditional probability that resampled coordinate takes the other value
        denom = w + w[j]
        pother = np.divide(w[j], denom, out=np.zeros_like(w), where=denom > 0)
        d = np.abs(f - f[j])
        if rule == "var":
            bit = (inst.idx >> i) & 1
            m1 = w[bit == 1].sum()
            m0 = tot - m1
            if m1 == 0 or m0 == 0:
                out[i] = 0.0
                continue
            e1 = (w * f)[bit == 1].sum() / m1
            e0 = (w * f)[bit == 0].sum() / m0
            mu = (m1 * e1 + m0 * e0) / tot
            out[i] = (m1 * (e1 - mu) ** 2 + m0 * (e0 - mu) ** 2) / tot
        elif rule == "inf":
            out[i] = (w * pother * d).sum() / tot
        elif rule == "thr":
            out[i] = (w * pother * (d > eps + 1e-12)).sum() / tot
        elif rule == "bad":
            out[i] = (w * bad * pother * d).sum() / tot
        elif rule == "esc":
            # resampling i moves a bad point out of the bad set B
            out[i] = (w * bad * pother * (~bad[j])).sum() / tot
        elif rule == "red":
            # one-step reduction of bad mass after re-optimising both leaves
            bit = (inst.idx >> i) & 1
            after = 0.0
            for b in (0, 1):
                mk = mask & (bit == b)
                after += best_leaf(f[mk], inst.w[mk], eps)[1]
            out[i] = (_ := best_leaf(f[mask], inst.w[mask], eps)[1]) - after
        else:
            raise ValueError(rule)
    return out


def greedy_tree(inst, eps, delta, rule, cap=None, stop="kraft"):
    """Returns (worst depth, expected depth, total failure).

    stop="node":  stop when conditional bad mass <= delta.
    stop="kraft": stop when conditional bad <= delta/2 or absolute bad
                  <= (delta/2) 2^-depth; Kraft gives total failure <= delta.
    """
    n = inst.n
    cap = n if cap is None else cap
    worst, exp_depth, fail = 0, 0.0, 0.0
    total_w = inst.w.sum()

    def rec(mask, free, depth):
        nonlocal worst, exp_depth, fail
        m = inst.w[mask].sum()
        if m == 0:
            return
        c, badm = best_leaf(inst.f[mask], inst.w[mask], eps)
        if stop == "node":
            done = badm / m <= delta
        else:
            done = (badm / m <= delta / 2
                    or badm / total_w <= (delta / 2) * 2.0 ** (-depth))
        if done or not free or depth >= cap:
            worst = max(worst, depth)
            exp_depth += depth * m / total_w
            fail += badm / total_w
            return
        sc = scores(inst, mask, free, eps, rule)
        i = max(free, key=lambda k: (sc[k], -k))
        if sc[i] <= 0 and rule in ("thr", "bad", "esc", "red"):
            # statistic sees nothing to do: stop (this is the rule's own verdict)
            worst = max(worst, depth)
            exp_depth += depth * m / total_w
            fail += badm / total_w
            return
        bit = (inst.idx >> i) & 1
        rest = [k for k in free if k != i]
        rec(mask & (bit == 1), rest, depth + 1)
        rec(mask & (bit == 0), rest, depth + 1)

    rec(np.ones(len(inst.f), bool), list(range(n)), 0)
    return worst, exp_depth, fail


# ---------------------------------------------------------------- OPT (exact DP)

def opt_depth(inst, eps, delta, maxd=None):
    n = inst.n
    maxd = n if maxd is None else maxd
    f, w = inst.f, inst.w
    total = w.sum()
    X = all_points(n)

    @lru_cache(maxsize=None)
    def leaf(rho):
        mask = np.ones(len(f), bool)
        for i, r in enumerate(rho):
            if r != 2:
                mask &= X[:, i] == r
        return best_leaf(f[mask], w[mask], eps)[1]

    @lru_cache(maxsize=None)
    def G(rho, D):
        best = leaf(rho)
        if D == 0 or best == 0:
            return best
        for i, r in enumerate(rho):
            if r == 2:
                a = rho[:i] + (0,) + rho[i + 1:]
                b = rho[:i] + (1,) + rho[i + 1:]
                v = G(a, D - 1) + G(b, D - 1)
                if v < best:
                    best = v
        return best

    root = (2,) * n
    for D in range(maxd + 1):
        if G(root, D) <= delta * total + 1e-15:
            return D
    return None


# ---------------------------------------------------------------- instances

def rare_and_noise(k, m, eps, b):
    """f = 3 eps AND_k(y) + b avg(x); y = first k bits, x = last m bits; uniform."""
    n = k + m
    X = all_points(n)
    f = 3 * eps * X[:, :k].all(axis=1) + b * X[:, k:].mean(axis=1)
    return Instance(f, product_weights(n, [0.5] * n), f"rareAND k={k} m={m}")


def parity_noise(k, m, b):
    n = k + m
    X = all_points(n)
    par = X[:, :k].sum(axis=1) % 2
    f = (1 - b) * par + b * X[:, k:].mean(axis=1)
    return Instance(f, product_weights(n, [0.5] * n), f"parity k={k} m={m}")


def collective_noise(m):
    X = all_points(m)
    return Instance(X.mean(axis=1), product_weights(m, [0.5] * m), f"avg m={m}")


def mixture_rare_and(k, m, eps, b, hi=0.9, tilt=0.3):
    """Latent theta: y-bits Bern(hi) if theta=1 else Bern(0.5);
    x-bits Bern(0.5 +/- tilt) reveal theta.  f as in rare_and_noise."""
    n = k + m
    X = all_points(n)
    f = 3 * eps * X[:, :k].all(axis=1) + b * X[:, k:].mean(axis=1)
    c1 = [hi] * k + [0.5 + tilt] * m
    c0 = [0.5] * k + [0.5 - tilt] * m
    w = mixture_weights(n, [(0.5, c1), (0.5, c0)])
    return Instance(f, w, f"mixAND k={k} m={m}")


def hidden_and_in_noise(k, m, eps):
    """The rare event is AND of y, but its effect is only visible jointly with
    noise: f = 3 eps AND_k(y) * (1 - avg(x)/2) + avg(x)/ (4m) ... kept bounded."""
    n = k + m
    X = all_points(n)
    ax = X[:, k:].mean(axis=1)
    f = 3 * eps * X[:, :k].all(axis=1) * (0.5 + ax / 2) + 0.18 * eps * ax
    return Instance(f, product_weights(n, [0.5] * n), f"hiddenAND k={k} m={m}")


RULES = ("var", "inf", "thr", "bad", "esc", "red")


def run(inst, eps, deltas, with_opt=True):
    rows = []
    for d in deltas:
        row = {"inst": inst.name, "delta": d}
        for r in RULES:
            wd, ed, fl = greedy_tree(inst, eps, d, r)
            row[r] = (wd, round(ed, 2), fl <= d + 1e-12)
        row["opt"] = opt_depth(inst, eps, d / 2) if with_opt else None
        rows.append(row)
    return rows


def fmt(rows):
    for r in rows:
        cells = "  ".join(
            f"{k}={r[k][0]}/{r[k][1]}{'' if r[k][2] else '!'}" for k in RULES)
        print(f"{r['inst']:<22} delta={r['delta']:<7} {cells}  opt={r['opt']}")


if __name__ == "__main__":
    eps = 0.1
    deltas = [0.1, 0.01, 0.001]
    print("cells: worst/expected depth; '!' = total failure exceeded delta\n")
    for k in (3, 4, 5, 6):
        fmt(run(rare_and_noise(k, 9 - k + 3, eps, b=0.18), eps, deltas,
                with_opt=(k + 9 - k + 3) <= 12))
    print()
    for k in (2, 3, 4):
        fmt(run(parity_noise(k, 6, b=0.15), eps, deltas))
    print()
    fmt(run(collective_noise(10), eps, deltas))
    print()
    fmt(run(mixture_rare_and(4, 6, eps, b=0.18), eps, deltas))
    fmt(run(hidden_and_in_noise(4, 6, eps), eps, deltas))

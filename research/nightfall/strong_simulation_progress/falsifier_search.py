"""Random + structured falsifier search: where does a selection rule need many
more queries than OPT?  n = 8, exact.

Usage: python3 falsifier_search.py SEED TRIALS
Each trial is reproducible from (SEED, trial) via make_instance.
Greedy rules use Kraft stopping (total failure <= delta); they are compared
with OPT at delta/2, since a factor 2 in delta is immaterial for log(1/delta).
"""

import sys
import numpy as np

from progress_experiment import (Instance, all_points, product_weights,
                                 mixture_weights, greedy_tree, opt_depth)

N = 8
X = all_points(N)
RULES = ("esc", "bad", "inf", "var", "red")


def rescale(v):
    lo, hi = v.min(), v.max()
    return (v - lo) / (hi - lo) if hi > lo else np.zeros_like(v)


def rand_poly(rng, deg):
    v = np.zeros(len(X))
    for _ in range(rng.integers(2, 7)):
        S = rng.choice(N, size=rng.integers(1, deg + 1), replace=False)
        v += rng.normal() * (1 - 2 * X[:, S]).prod(axis=1)
    return rescale(v)


def rand_rare_events(rng):
    v = np.zeros(len(X))
    for _ in range(rng.integers(1, 4)):
        S = rng.choice(N, size=rng.integers(2, 6), replace=False)
        pat = rng.integers(0, 2, size=len(S))
        v += rng.uniform(0.1, 0.5) * (X[:, S] == pat).all(axis=1)
    T = rng.choice(N, size=rng.integers(2, N), replace=False)
    v += rng.uniform(0, 0.3) * X[:, T].mean(axis=1)
    return np.clip(v / max(1.0, v.max()), 0, 1)


def rand_law(rng):
    kind = rng.integers(0, 3)
    if kind == 0:
        return product_weights(N, [0.5] * N), "uniform"
    if kind == 1:
        return product_weights(N, rng.uniform(0.05, 0.95, N)), "product"
    M = int(rng.integers(2, 4))
    pri = rng.dirichlet(np.ones(M))
    return (mixture_weights(N, [(pri[j], rng.uniform(0.05, 0.95, N))
                                for j in range(M)]), f"mixture M={M}")


def make_instance(seed, trial):
    rng = np.random.default_rng([seed, trial])
    f = rand_poly(rng, 3) if trial % 2 else rand_rare_events(rng)
    w, law = rand_law(rng)
    return Instance(f, w, f"s{seed}t{trial} {'poly3' if trial % 2 else 'rare'} {law}")


def search(seed, trials, rules=RULES, epss=(0.05, 0.1), deltas=(0.05, 0.005, 0.0005)):
    rows = []
    for t in range(trials):
        inst = make_instance(seed, t)
        for eps in epss:
            for delta in deltas:
                o = opt_depth(inst, eps, delta / 2)
                res = {r: greedy_tree(inst, eps, delta, r) for r in rules}
                rows.append((inst.name, eps, delta, o, res))
    return rows


def report(rows, rules=RULES, focus="esc"):
    print("depth gaps vs OPT(delta/2), worst-case depth")
    for r in rules:
        g = np.array([res[r][0] - o for _, _, _, o, res in rows])
        print(f"  {r}: mean {g.mean():.3f}  max {g.max()}  "
              f"hist {dict(zip(g.tolist() and np.unique(g).tolist(), np.unique(g, return_counts=True)[1].tolist()))}")
    others = [r for r in rules if r not in (focus, "red")]  # red fails delta; not a valid comparator
    lose = [(res[focus][0] - min(res[r][0] for r in others), n, e, d, o, res)
            for n, e, d, o, res in rows]
    lose.sort(key=lambda t: -t[0])
    print(f"\nlargest losses of '{focus}' to the best other rule:")
    for L, n, e, d, o, res in lose[:8]:
        if L <= 0:
            break
        print(f"  +{L} {n} eps={e} delta={d} opt={o} "
              + " ".join(f"{r}={res[r][0]}" for r in rules))


if __name__ == "__main__":
    seed = int(sys.argv[1]) if len(sys.argv) > 1 else 0
    trials = int(sys.argv[2]) if len(sys.argv) > 2 else 120
    report(search(seed, trials))

#!/usr/bin/env python3
"""Exact finite audit of Q2 original-source greedy-owned observation.

Independent Fraction implementation, not a universal proof or Lean
certificate. It tests pointwise kernel orientation/summation, distinct
coordinate product law, and original source owned-second-moment energy.
"""
from fractions import Fraction as Q
from itertools import combinations, product
from functools import lru_cache
from random import Random

SEED = 20261113
NUM_MODELS = 40

def check():
    rng = Random(SEED)
    checks = dict(pointwise=0, law=0, energy=0)
    for trial in range(NUM_MODELS):
        n = rng.choice([2, 3, 4])
        A = rng.choice([2, 3])
        weights = []
        for i in range(n):
            raw = [rng.randrange(0, 5) for _ in range(A)]
            if not sum(raw):
                raw[rng.randrange(A)] = 1
            weights.append([Q(t, sum(raw)) for t in raw])
        states = list(product(range(A), repeat=n))
        f = {x: Q(rng.randrange(-5, 6)) for x in states}
        costs = [rng.randrange(0, 6) for _ in range(n)]
        base = states[0]

        @lru_cache(None)
        def mass(x):
            ans = Q(1)
            for i, a in enumerate(x):
                ans *= weights[i][a]
            return ans

        @lru_cache(None)
        def cached_conditional(U, x):
            return sum((mass(y) *
                        f[tuple(x[k] if k in U else y[k] for k in range(n))]
                        for y in states), Q(0))

        def conditional(U, x):
            return cached_conditional(frozenset(U), x)

        @lru_cache(None)
        def pair_component(i, j, x):
            return (conditional({i, j}, x) - conditional({i}, x)
                    - conditional({j}, x) + conditional(set(), x))

        @lru_cache(None)
        def kernel(i, j, a, b):
            x = list(base)
            x[i], x[j] = a, b
            return pair_component(i, j, tuple(x))

        owned = {i: [] for i in range(n)}
        for i, j in combinations(range(n), 2):
            owner = i if costs[j] <= costs[i] else j
            neighbor = j if owner == i else i
            owned[owner].append(neighbor)

        for i in range(n):
            J = owned[i]
            assert len(J) == len(set(J))
            for sample in product(range(A), repeat=len(J)):
                observed_mass = sum((mass(x) for x in states
                                     if tuple(x[j] for j in J) == sample), Q(0))
                independent_mass = Q(1)
                for j, b in zip(J, sample):
                    independent_mass *= weights[j][b]
                assert observed_mass == independent_mass, (trial, i, sample)
                checks["law"] += 1

            def section(x, a):
                changed = tuple(a if k == i else x[k] for k in range(n))
                return sum((pair_component(i, j, changed) for j in J), Q(0))

            for x in states:
                for a in range(A):
                    source = section(x, a)
                    observed = sum((kernel(i, j, a, x[j]) for j in J), Q(0))
                    assert source == observed, (trial, i, J, x, a)
                    checks["pointwise"] += 1

            source_energy = sum(
                (mass(x) * weights[i][a] * section(x, a) ** 2
                 for x in states for a in range(A)), Q(0))
            canonical_energy = sum(
                (weights[i][a] * weights[j][b] * kernel(i, j, a, b) ** 2
                 for j in J for a in range(A) for b in range(A)), Q(0))
            assert source_energy == canonical_energy, (trial, i)
            checks["energy"] += 1
    assert checks == {"pointwise": 10037, "law": 539, "energy": 115}, checks
    print("PASS", "seed", SEED, "models", NUM_MODELS, "checks", checks)

if __name__ == "__main__":
    check()

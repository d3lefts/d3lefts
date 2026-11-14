#!/usr/bin/env python3
"""Independent operational and exact integer-budget audit for semantic fencing.

Budget feasibility is intentionally separate from the minimax cost optimizer;
the guard checker scans actual admitted effect states rather than hyperedges.
"""
import random
from functools import lru_cache
from semantic_fence import min_fence, joint_value, standard_classification_only, min_fence_from_edges


def direct_guard(B, safe, n, weights):
    states = [x for x in range(1 << n) if B & (1 << x)]
    assert all(safe[x] for x in states)
    mincost = None
    arg = None
    for J in range(1 << n):
        admitted_safe = True
        for snapshot in states:
            for actual in range(1 << n):
                if ((snapshot ^ actual) & J) == 0 and not safe[actual]:
                    admitted_safe = False
                    break
            if not admitted_safe:
                break
        if admitted_safe:
            price = sum(weights[j] for j in range(n) if (J >> j) & 1)
            if mincost is None or price < mincost:
                mincost, arg = price, J
    return mincost, arg


def budget_policy_possible(B, budget, safe, n, tests, guards):
    """Independent yes/no decision-tree feasibility at fixed integer budget."""
    @lru_cache(None)
    def can(class_mask, left):
        if left < 0:
            return False
        worlds = [x for x in range(1 << n) if class_mask & (1 << x)]
        if all(not safe[x] for x in worlds):
            return True
        if all(safe[x] for x in worlds):
            for J in range(1 << n):
                if sum(guards[i] for i in range(n) if (J >> i) & 1) > left:
                    continue
                if all(safe[actual] or ((base ^ actual) & J)
                       for base in worlds for actual in range(1 << n)):
                    return True
        for k in range(n):
            if tests[k] > left:
                continue
            low = sum(1 << x for x in worlds if not (x & (1 << k)))
            high = class_mask ^ low
            if low and high and can(low, left - tests[k]) and can(high, left - tests[k]):
                return True
        return False
    return can(B, budget)


def heterogeneous_change_audit():
    """Change histories on heterogeneous 2×3×4 states, including ABA writes."""
    from itertools import product
    rng = random.Random(141126)
    worlds = list(product(range(2), range(3), range(4)))
    assert len(worlds) == 24
    cases = 350
    for case in range(cases):
        safe = tuple(bool(rng.getrandbits(1)) for _ in worlds)
        B = {i for i in range(24) if safe[i] and rng.random() < .6}
        if not B:
            continue
        weights = [rng.randint(1, 7) for _ in range(3)]
        permitted = []
        for _ in range(130):
            b = rng.randrange(24)
            y = rng.randrange(24)
            need = sum(1 << i for i in range(3) if worlds[b][i] != worlds[y][i])
            touched = need
            for i in range(3):
                if rng.random() < .15:
                    touched |= 1 << i
            permitted.append((b, y, touched))
        edges = frozenset(D for b, y, D in permitted if b in B and not safe[y])
        value, _ = min_fence_from_edges(edges, weights)
        candidates = []
        for J in range(8):
            admits_unsafe = any((b in B and not safe[y] and (D & J) == 0)
                                for b, y, D in permitted)
            if not admits_unsafe:
                candidates.append(sum(weights[i] for i in range(3) if (J >> i) & 1))
        independent = min(candidates) if candidates else None
        assert value == independent, (case, value, independent)
    print("HETEROGENEOUS_HISTORIES_AUDIT_PASS", cases, "sampled scenarios on 24-world 2x3x4 domains")


def audit():
    rng = random.Random(20261114)
    num = 0
    naive_gap = 0
    finite_states = 0
    for n, reps in [(2, 500), (3, 1200)]:
        W = 1 << n
        for case in range(reps):
            safe = tuple(bool(rng.getrandbits(1)) for _ in range(W))
            B = rng.randrange(1, 1 << W)
            tests = tuple(rng.randint(1, 4) for _ in range(n))
            guards = tuple(rng.randint(2, 8) for _ in range(n))
            safe_worlds = [x for x in range(W) if safe[x] and (B & (1 << x))]
            if safe_worlds:
                pure = sum(1 << x for x in safe_worlds)
                got, _ = min_fence(pure, safe, n, guards)
                independent, _ = direct_guard(pure, safe, n, guards)
                assert got == independent, ("guard", n, case, got, independent)
            optimum, ci, _ = joint_value(B, safe, n, tests, guards)
            assert budget_policy_possible(B, optimum, safe, n, tests, guards), ("upper", n, case)
            assert not budget_policy_possible(B, optimum - 1, safe, n, tests, guards), ("lower", n, case)
            naive = standard_classification_only(B, safe, n, tests, guards)
            assert optimum <= naive
            if optimum < naive:
                naive_gap += 1
            finite_states += ci.currsize
            num += 1
    safe = [True, True, True, False]
    B = 0b0111
    tests = (1, 1)
    guards = (4, 4)
    exact, _, _ = joint_value(B, safe, 2, tests, guards)
    naive = standard_classification_only(B, safe, 2, tests, guards)
    assert (exact, naive) == (5, 8)
    assert budget_policy_possible(B, 5, safe, 2, tests, guards)
    assert not budget_policy_possible(B, 4, safe, 2, tests, guards)
    heterogeneous_change_audit()
    print("INDEPENDENT_AUDIT_PASS", num, "models,", finite_states, "belief entries evaluated")
    print("SYNERGY_CASES", naive_gap, "of", num, "(read-after-certified reduces cost)")
    print("EXPLICIT_COUPLING optimum=5/4, stop-when-classified=2, gap=3/8")
    print("Every optimum passed independent budget yes/no and operational guard scan.")


if __name__ == "__main__":
    audit()

#!/usr/bin/env python3
"""Exact source-fence and evidence + fence minimax, finite model.

All integers are exact. World IDs are 0..(2**n-1), source values are bits.
Observation steps are coherent-snapshot reads; source changes occur AFTER
classification and BEFORE the protected commit. Gate sees version equality only.
"""
from functools import lru_cache


def feasible_guard(J, baselines, safe, n, histories=None):
    """Independent semantic scan over permitted source-change histories."""
    if histories is None:
        histories = ((b, y, b ^ y) for b in baselines for y in range(1 << n))
    for b, y, touched in histories:
        if b in baselines and not safe[y] and not (touched & J):
            return False
    return True


def hyperedges(baselines, safe, n, histories=None):
    if histories is None:
        histories = ((b, y, b ^ y) for b in baselines for y in range(1 << n))
    return frozenset(touched for b, y, touched in histories if b in baselines and not safe[y])


def min_fence_from_edges(edges, costs):
    n = len(costs)
    best = None
    chosen = None
    for J in range(1 << n):
        if all((J & edge) != 0 for edge in edges):
            price = sum(costs[i] for i in range(n) if J & (1 << i))
            if best is None or price < best:
                best, chosen = price, J
    return best, chosen


def min_fence(Bmask, safe, n, costs):
    baselines = [b for b in range(1 << n) if Bmask & (1 << b)]
    assert baselines and all(safe[b] for b in baselines)
    return min_fence_from_edges(hyperedges(baselines, safe, n), costs)


def joint_value(Bmask, safe, n, read_prices, fence_prices):
    """Exact worst-case acquisition + effect-time guard cost in integer units.

    Unlike ordinary classification recursion, tests are allowed EVEN when all
    baseline candidate worlds are safe. A new observation may lower the fence.
    """
    nworlds = 1 << n
    assert Bmask and Bmask < (1 << nworlds)

    @lru_cache(None)
    def solve(B):
        worlds = [b for b in range(nworlds) if B & (1 << b)]
        assert worlds
        safe_all = all(safe[b] for b in worlds)
        bad_all = all(not safe[b] for b in worlds)
        if bad_all:
            best, plan = 0, ("deny",)
        elif safe_all:
            guard_cost, J = min_fence(B, safe, n, fence_prices)
            best, plan = guard_cost, ("commit", J)
        else:
            best, plan = None, None
        for i in range(n):
            groups = [sum((1 << b) for b in worlds if not (b & (1 << i))),
                      sum((1 << b) for b in worlds if b & (1 << i))]
            if not groups[0] or not groups[1]:
                continue
            q0, _ = solve(groups[0])
            q1, _ = solve(groups[1])
            price = read_prices[i] + max(q0, q1)
            if best is None or price < best:
                best, plan = price, ("read", i, groups[0], groups[1])
        return best, plan
    return solve(Bmask)[0], solve.cache_info(), solve


def standard_classification_only(Bmask, safe, n, read_prices, fence_prices):
    """Natural but SUBOPTIMAL approach: stop when initial safety label is known."""
    @lru_cache(None)
    def v(B):
        xs = [x for x in range(1 << n) if B & (1 << x)]
        if all(not safe[x] for x in xs):
            return 0
        if all(safe[x] for x in xs):
            return min_fence(B, safe, n, fence_prices)[0]
        return min(
            read_prices[i] + max(v(z), v(B ^ z))
            for i in range(n)
            if (z := sum((1 << x) for x in xs if not (x & (1 << i)))) and z != B
        )
    return v(Bmask)


if __name__ == "__main__":
    n = 2
    safe = [True, True, True, False]
    B = (1 << 0) | (1 << 1) | (1 << 2)
    print("EXAMPLE baseline worlds:", [0, 1, 2])
    print("SAFE baseline:", all(safe[x] for x in range(3)))
    print("DIRECT_FENCE_COST:", min_fence(B, safe, n, [4, 4]))
    print("JOINT_COST (quarter units):", joint_value(B, safe, n, [1, 1], [4, 4])[0])
    print("STOP_WHEN_CLASSIFIED_COST:", standard_classification_only(B, safe, n, [1, 1], [4, 4]))

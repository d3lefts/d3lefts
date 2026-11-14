#!/usr/bin/env python3
"""Exact nonlinear selector examples for post-certification evidence gains."""
from itertools import product
from semantic_fence import min_fence_from_edges

def evaluate(r, selector_price=.25):
    worlds = list(product(range(r), *[(0, 1) for _ in range(r)]))
    allowed = lambda w: w[1 + w[0]] == 0
    safe = [allowed(w) for w in worlds]
    B = [w for w in worlds if sum(w[1:]) == r-1 and w[1+w[0]] == 0]
    assert len(B) == r
    def guard_cost(baselines):
        edges = set()
        for b in baselines:
            for t, ok in zip(worlds, safe):
                if not ok:
                    touched = sum(1 << i for i in range(r+1) if b[i] != t[i])
                    edges.add(touched)
        direct, J = min_fence_from_edges(edges, [1] * (r+1))
        return direct, J, edges
    initial_cost, initial_mask, E = guard_cost(B)
    perselector = []
    for selector in range(r):
        leaf = [b for b in B if b[0] == selector]
        perselector.append(guard_cost(leaf)[0])
    assert initial_cost == r+1, (r, initial_cost)
    assert perselector == [2] * r, (r, perselector)
    joint = selector_price + max(perselector)
    print(f"r={r}: initial safe label, stop-now guard={initial_cost}, one extra selector read + guard={joint:.2f}, improvement={initial_cost/joint:.3f}x; worlds={len(worlds)}")

if __name__ == "__main__":
    for r in range(2, 7):
        evaluate(r)
    print("UNBOUNDED_POST_CERTIFICATE_GAIN_PASS")

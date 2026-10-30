#!/usr/bin/env python3
"""Exact integer C7^5 adjacency + independently solved *restricted* MILP.

Scope: retain the published Polak--Schrijver 327-word core as candidate words,
and allow all other words conflicting with at most TWO of those core words.
The solver's zero-gap integer optimum does NOT provide a portable exact proof
certificate, and does NOT bound alpha(C7^5) globally. No 368 claim.
"""
import argparse
import math
from itertools import combinations, product
import numpy as np
from scipy.optimize import Bounds, LinearConstraint, milp
from scipy.sparse import coo_matrix
from verify_367 import APPEND, check_code, neighbors, source_and_core


def solve(degree_limit):
    _, core = source_and_core()
    C = sorted(core)
    core_lut = {w: i for i, w in enumerate(C)}
    all_words = ("".join(p) for p in product("0123456", repeat=5))
    collisions = {}
    for j, c in enumerate(C):
        for p in neighbors(c):
            collisions.setdefault(p, []).append(j)
    universe = [
        w for w in all_words
        if w not in core and len(collisions.get(w, ())) <= degree_limit
    ]
    n = len(universe)
    index = {w: i for i, w in enumerate(universe)}
    constraint_i, constraint_j, coefficients, upper = [], [], [], []

    def restrict(vars_, rhs):
        r = len(upper)
        constraint_i.extend([r] * len(vars_))
        constraint_j.extend(vars_)
        coefficients.extend([1] * len(vars_))
        upper.append(rhs)

    edges = 0
    for i, w in enumerate(universe):
        for v in neighbors(w):
            j = index.get(v)
            if j is not None and j > i:
                restrict((i, j), 1)
                edges += 1
        for core_index in collisions.get(w, ()):
            restrict((i, n + core_index), 1)
    count = n + len(C)
    matrix = coo_matrix((coefficients, (constraint_i, constraint_j)),
                        shape=(len(upper), count)).tocsr()
    res = milp(
        -np.ones(count),
        integrality=np.ones(count),
        bounds=Bounds(np.zeros(count), np.ones(count)),
        constraints=LinearConstraint(matrix, -math.inf, upper),
        options={"time_limit": 60, "mip_rel_gap": 0.0},
    )
    assert res.status == 0 and res.success, (res.status, res.message)
    assert res.mip_gap == 0, res.mip_gap
    chosen = [universe[i] for i in range(n) if res.x[i] > .5]
    chosen += [C[j] for j in range(len(C)) if res.x[n + j] > .5]
    assert len(chosen) == 367, len(chosen)
    check_code(sorted(chosen))  # independent exact integer checker
    # Because we minimize -(chosen words), the following certifies the
    # SOLVER-REPORTED restricted cardinality upper bound, not a formal proof.
    assert abs(res.mip_dual_bound + 367) < 1e-7, res.mip_dual_bound
    check_code(sorted(core | set(APPEND)))  # 367 feasible lower bound
    print("RESTRICTED SOLVER OPTIMUM =", len(chosen))
    print("degree_limit =", degree_limit, "candidate_words =", n,
          "external_edges =", edges, "constraints =", len(upper))
    print("MIP status =", res.message, "MIP gap =", res.mip_gap)
    print("CERTIFICATE STATUS: solver-optimal within a defined domain only")
    print("GLOBAL alpha(C7^5) STILL OPEN: 367 <= alpha <= 401")


if __name__ == "__main__":
    arg = argparse.ArgumentParser()
    arg.add_argument("--max-core-conflicts", type=int, default=2, choices=(0, 1, 2))
    solve(arg.parse_args().max_core_conflicts)

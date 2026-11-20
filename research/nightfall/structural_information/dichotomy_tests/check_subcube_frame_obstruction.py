#!/usr/bin/env python3
"""Independent exact finite audit of NIGHTFALL subcube-frame obstruction.

This script checks finite combinatorics only. It cannot prove the all-L theorem
or establish quantum-query complexity or global novelty. No external libraries.
"""
from __future__ import annotations

from itertools import product


def binary_rank(values: list[int]) -> int:
    pivots: dict[int, int] = {}
    for original in values:
        x = original
        while x:
            lead = x.bit_length() - 1
            if lead not in pivots:
                pivots[lead] = x
                break
            x ^= pivots[lead]
    return len(pivots)


def subcube_instance(L: int):
    specs = list(product((0, 1, 2), repeat=L))
    positions = {a: idx for idx, a in enumerate(specs)}
    rows = []
    for a in specs:
        row = 0
        for z in range(1 << L):
            if all(t == 2 or t == ((z >> i) & 1) for i, t in enumerate(a)):
                row |= 1 << z
        rows.append(row)
    return specs, positions, rows


def splitting_relations(L: int, specs, positions) -> list[int]:
    result = []
    for a in specs:
        for i in range(L):
            if a[i] != 2:
                continue
            a0 = list(a)
            a1 = list(a)
            a0[i] = 0
            a1[i] = 1
            result.append(
                (1 << positions[a])
                ^ (1 << positions[tuple(a0)])
                ^ (1 << positions[tuple(a1)])
            )
    return result


def relation_violations(rows, relations) -> int:
    count = 0
    for rel in relations:
        xor_value = 0
        while rel:
            lowbit = rel & (-rel)
            idx = lowbit.bit_length() - 1
            xor_value ^= rows[idx]
            rel ^= lowbit
        if xor_value:
            count += 1
    return count


def check(L: int) -> None:
    specs, positions, rows = subcube_instance(L)
    m, n = 1 << L, 3**L
    assert len(rows) == n and len(set(rows)) == n
    assert binary_rank(rows) == m

    relations = splitting_relations(L, specs, positions)
    assert relation_violations(rows, relations) == 0
    assert binary_rank(relations) == n - m, (L, "split relations not complete")

    # Each nonzero coefficient functional lambda on the m singleton coordinates
    # produces a column satisfying all split relations. Check its exact distance.
    # For L=4 we exhaust all 65535 possible nonzero functionals on F_2^16.
    minimum = n + 1
    minimum_count = 0
    for lam in range(1, 1 << m):
        weight = sum((lam & r).bit_count() & 1 for r in rows)
        if weight < minimum:
            minimum, minimum_count = weight, 1
        elif weight == minimum:
            minimum_count += 1
        assert weight >= (1 << L), (L, lam, weight)
    assert minimum == 1 << L
    assert minimum_count > 0

    # Singleton original rows form a legitimate h-independent frame for all h.
    singleton = [rows[positions[tuple((z >> i) & 1 for i in range(L))]]
                 for z in range(m)]
    assert singleton == [1 << z for z in range(m)]
    canonical_weights = [r.bit_count() for r in rows]
    assert max(canonical_weights) == m
    assert sum(canonical_weights) == 4**L
    assert sum(canonical_weights) == m * (1 << L)
    assert n * m >= 4**L

    # Negative/mutation control: a corrupted all-star incidence row violates
    # the local split identities and is rejected independently.
    changed = list(rows)
    changed[positions[(2,) * L]] ^= 1
    assert relation_violations(changed, relations) > 0

    lower_ceil = (4**L + 3**L - 1) // (3**L)
    assert lower_ceil <= m
    print(
        "SUBCUBE_EXACT_PASS",
        "L", L, "m", m, "n", n,
        "relations_rank", binary_rank(relations),
        "code_min_distance", minimum,
        "min_weight_codewords", minimum_count,
        "frame_c_lower_ceiling", lower_ceil,
        "canonical_frame_c", m,
        "mutation_rejected", True,
        flush=True,
    )



def check_general_tensor(a: int, L: int) -> None:
    """Exhaustive code distance and local-relation rank for rank-one tensor rows."""
    factors = list(product(range(1, 1 << a), repeat=L))
    where = {w: i for i, w in enumerate(factors)}
    m, n = a**L, (2**a - 1)**L
    rows = []
    for v in factors:
        row = 0
        for coord in product(range(a), repeat=L):
            if all((v[i] >> coord[i]) & 1 for i in range(L)):
                row |= 1 << sum(coord[i] * a**i for i in range(L))
        rows.append(row)
    assert len(rows) == n and len(set(rows)) == n
    assert binary_rank(rows) == m
    rels = []
    for word in factors:
        for i in range(L):
            for u in range(1, 1 << a):
                for v in range(u + 1, 1 << a):
                    w1, w2, w3 = list(word), list(word), list(word)
                    w1[i], w2[i], w3[i] = u, v, u ^ v
                    rels.append(
                        (1 << where[tuple(w1)])
                        ^ (1 << where[tuple(w2)])
                        ^ (1 << where[tuple(w3)])
                    )
    assert relation_violations(rows, rels) == 0
    assert binary_rank(rels) == n - m
    distance = n + 1
    for lam in range(1, 1 << m):
        weight = sum((lam & row).bit_count() & 1 for row in rows)
        distance = min(distance, weight)
        assert weight >= (1 << (a - 1))**L
    assert distance == (1 << (a - 1))**L
    lower_num = m * distance
    print(
        "TENSOR_SIMPLEX_EXACT_PASS", "a", a, "L", L,
        "m", m, "n", n, "relation_rank", n - m,
        "distance", distance,
        "frame_c_lower_ceil", (lower_num + n - 1) // n,
        flush=True,
    )


if __name__ == "__main__":
    for length in (1, 2, 3, 4):
        check(length)
    for a, L in ((2, 2), (3, 1), (3, 2)):
        check_general_tensor(a, L)
    print("SUBCUBE_FRAME_OBSTRUCTION_FINITE_PASS")

#!/usr/bin/env python3
"""Exact combinatorial regression for binary-character T2 fiber invariants.

Two independent enumeration algorithms. This is not a quantum operator/Lean proof.
"""
from collections import Counter
from itertools import combinations, product
from math import factorial


def tensor_rows(depth):
    rows = []
    for factors in product((1, 2, 3), repeat=depth):
        coords = [1]
        for factor in factors:
            old = coords
            coords = [bit * (factor & 1) for bit in old] + [bit * (factor >> 1) for bit in old]
        rows.append(sum(bit << j for j, bit in enumerate(coords)))
    assert 0 not in rows and len(rows) == len(set(rows))
    return rows


def independent(vectors):
    pivots = {}
    for vector in vectors:
        x = vector
        while x:
            i = x.bit_length() - 1
            if i not in pivots:
                pivots[i] = x
                break
            x ^= pivots[i]
        if x == 0:
            return False
    return True


def count_by_subsets(rows):
    """Method A: enumerate unordered supports and count ordered placements."""
    primitive = Counter()
    for k in range(1, 5):
        for support in combinations(rows, k):
            if independent(support):
                z = 0
                for v in support:
                    z ^= v
                assert z != 0
                primitive[z] += factorial(4) // factorial(4-k)
    pairs = Counter()
    for a in [0] + rows:
        for b in [0] + rows:
            if a != b:
                pairs[a ^ b] += 1
    return max(primitive.values(), default=0), max(pairs.values(), default=0)


def count_by_tuples(rows):
    """Method B: direct ordered 4-tuples, all nonempty subset-XOR tests."""
    D = [0] + rows
    primitive, pairs = Counter(), Counter()
    for a, b in product(D, repeat=2):
        if a != b:
            pairs[a ^ b] += 1
    for t in product(D, repeat=4):
        nz = [a for a in t if a]
        if len(nz) != len(set(nz)):
            continue
        dependent = False
        for mask in range(1, 1 << len(nz)):
            xor_sum = 0
            for j, label in enumerate(nz):
                if mask & (1 << j):
                    xor_sum ^= label
            if xor_sum == 0:
                dependent = True
                break
        if dependent:
            continue
        z = t[0] ^ t[1] ^ t[2] ^ t[3]
        if z:
            primitive[z] += 1
    return max(primitive.values(), default=0), max(pairs.values(), default=0)


def main():
    cases = [
        ("independent-4", [1, 2, 4, 8], (24, 2)),
        ("tensor-L1", tensor_rows(1), (16, 4)),
        ("tensor-L2", tensor_rows(2), (348, 6)),
        ("tensor-L3", tensor_rows(3), (2004, 8)),
    ]
    for name, rows, expected in cases:
        a, b = count_by_subsets(rows), count_by_tuples(rows)
        assert a == b == expected, (name, a, b, expected)
        print(f"PASS {name:16} rows={len(rows):3} K4={a[0]:5} M2={a[1]:3}")
    print("Combinatorics only: no quantum/Lean/priority certificate.")


if __name__ == "__main__":
    main()

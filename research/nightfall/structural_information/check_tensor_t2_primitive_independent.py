#!/usr/bin/env python3
"""Independent exact GF(2) enumeration for PR #1016: primitive 1--4-row XOR fibers.

Only tests L <= 4.  Not an all-depth proof and not a quantum circuit simulator.
Does not import the project's tensor generator or use floating-point arithmetic.
"""
from collections import Counter
from itertools import combinations, product
from math import comb


def original_row(local_factors):
    """Expand an L-fold pure tensor with e0=1, e1=2, e0+e1=3."""
    coordinates = [0]
    for factor in local_factors:
        bits = (0, 1) if factor == 3 else ((0,) if factor == 1 else (1,))
        coordinates = [2 * old + b for old in coordinates for b in bits]
    return sum(1 << i for i in coordinates)


def primitive_nonzero_xor(rows):
    z = 0
    for row in rows:
        z ^= row
    if z == 0:
        return None
    # Each input is a distinct nonzero vector, so 1- and 2-subsets never vanish.
    for triple in combinations(rows, 3):
        if triple[0] ^ triple[1] ^ triple[2] == 0:
            return None
    return z


def verify(L):
    rows = [original_row(t) for t in product((1, 2, 3), repeat=L)]
    assert len(rows) == 3**L == len(set(rows))
    assert all(r != 0 for r in rows)
    all_primitive, primitive_four = Counter(), Counter()
    for size in range(1, min(4, len(rows)) + 1):
        for selection in combinations(rows, size):
            z = primitive_nonzero_xor(selection)
            if z is not None:
                all_primitive[z] += 1
                if size == 4:
                    primitive_four[z] += 1
    result = (max(all_primitive.values()),
              max(primitive_four.values(), default=0),
              primitive_four[1])
    if L >= 3:
        rows4 = []
        for local in ((3, 1, 1), (2, 3, 1), (2, 2, 2), (2, 2, 3)):
            factors = [1] * L
            for index, factor in enumerate(local):
                factors[index] = factor
            rows4.append(original_row(factors))
        assert len(set(rows4)) == 4
        assert primitive_nonzero_xor(rows4) == 1
        assert primitive_four[1] >= comb(L, 3)
    return result


def main():
    expected = {1:(2, 0, 0), 2:(16, 6, 5), 3:(84, 72, 45), 4:(179, 150, 150)}
    for level, target in expected.items():
        found = verify(level)
        assert found == target, (level, found, target)
        print(f'L={level}: maximum primitive <=4 count={found[0]}, '
              f'four-row count={found[1]}, four-row count at e0={found[2]}')
    print('PASS: scoped exact enumeration only (all L<=4).')


if __name__ == '__main__':
    main()

#!/usr/bin/env python3
"""Independent exhaustive finite tensor-simplex minimum-distance check."""
from itertools import product


def tensor_rows(q, L):
    rows = []
    factors = range(1, 1 << q)
    for spec in product(factors, repeat=L):
        mask = 0
        for z in range(q ** L):
            t = z
            bit = 1
            for f in spec:
                bit &= (f >> (t % q)) & 1
                t //= q
                if not bit:
                    break
            mask |= bit << z
        rows.append(mask)
    return rows


def check(q, L):
    m = q ** L
    assert m <= 16
    R = tensor_rows(q, L)
    codewords = [(S, sum((S & row).bit_count() % 2 for row in R))
                 for S in range(1, 1 << m)]
    d = min(w for _, w in codewords)
    expected = 2 ** ((q - 1) * L)
    assert d == expected, (q, L, d, expected)
    assert len(R) == (2 ** q - 1) ** L
    print("TENSOR_SIMPLEX_DISTANCE_PASS", "q=", q, "L=", L,
          "m=", m, "n=", len(R), "d=", d, "nonzero=", len(codewords))


for q, L in ((2, 1), (2, 2), (2, 3), (2, 4),
             (3, 1), (3, 2), (4, 1), (4, 2), (5, 1)):
    check(q, L)
print("TENSOR_SIMPLEX_ALL_EXACT_PASS cases=9")

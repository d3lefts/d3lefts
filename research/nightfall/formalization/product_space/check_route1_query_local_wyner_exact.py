#!/usr/bin/env python3
"""Independent exact finite checks for the Route 1 query-local Wyner paper proof.

Checks all binary observed cylinder basis elements through degree <=3 for N<=7,
on *every* latent word, including contradictory duplicate-coordinate
assignments. Then verifies the literal one-query recovery promise.
Rational tests check event TV domination, not the analytic Wyner infimum.
Python integer and fractions.Fraction arithmetic only.
"""
from fractions import Fraction
from itertools import combinations, product


def check_diagonal_cylinders(n: int, max_degree: int = 3) -> int:
    latent_words = list(product((0, 1), repeat=n))
    num_checked = 0
    for d in range(min(max_degree, 2 * n) + 1):
        for observed_indices in combinations(range(2 * n), d):
            for symbols in product((0, 1), repeat=d):
                specified = dict(zip(observed_indices, symbols))
                latent_spec = {}
                conflicting = False
                for i, a in specified.items():
                    j = i % n
                    if j in latent_spec and latent_spec[j] != a:
                        conflicting = True
                    latent_spec[j] = a
                assert len(latent_spec) <= d
                for z in latent_words:
                    x = z + z
                    actual = int(all(x[i] == a for i, a in specified.items()))
                    expected = 0 if conflicting else int(
                        all(z[j] == a for j, a in latent_spec.items())
                    )
                    assert actual == expected, (n, d, specified, z)
                num_checked += 1

    # Recovery D_j reads the observed coordinate j: one query, exactly correct.
    for z in latent_words:
        x = z + z
        for j in range(n):
            assert x[j] == z[j]
    return num_checked


def check_tv_event_transfer():
    # All arithmetic exact; target ν=(1/3)Q+(2/3)P.
    q = [Fraction(1, 4)] * 4
    p = [Fraction(1, 2), Fraction(1, 2), Fraction(0), Fraction(0)]
    nu = [Fraction(1, 3) * a + Fraction(2, 3) * b
          for a, b in zip(q, p)]
    tv = sum((abs(a - b) for a, b in zip(nu, q)), Fraction(0)) / 2
    assert tv == Fraction(1, 3)
    for mask in range(16):
        nu_e = sum((nu[k] for k in range(4) if (mask >> k) & 1), Fraction(0))
        q_e = sum((q[k] for k in range(4) if (mask >> k) & 1), Fraction(0))
        assert nu_e <= q_e + tv
    return tv


if __name__ == "__main__":
    total = 0
    for n in range(1, 8):
        count = check_diagonal_cylinders(n)
        total += count
        print(f"PASS N={n}; checked {count} cylinders, degree<=3")
    tv = check_tv_event_transfer()
    print(f"PASS all 16 event transfer inequalities; exact TV={tv}")
    print(f"PASS total {total} cylinder pullbacks and all one-query recoveries")

#!/usr/bin/env python3
"""Exact quartic antipodal falsification checks. No external dependencies.

This checks identities, not the universal inequality. Run with Python 3.8+:
    python3 research/nightfall/2026-11-certificate-engine/checks/check_quartic_antipodal_exact.py
"""
from fractions import Fraction
from itertools import product
from math import comb
from random import Random


def rows_global_edges(vals, n):
    N = 1 << n
    lip = tuple(max(abs(vals[x] - vals[x ^ (1 << i)])
                    for x in range(N)) for i in range(n))
    return tuple(lip for _ in range(N))


def rows_suffix_telescope(vals, n):
    """Valid input-dependent rows: update low-index bits first."""
    N = 1 << n
    rows = []
    for x in range(N):
        a = []
        for i in range(n):
            suffix = sum(1 << j for j in range(i + 1, n))
            a.append(max(abs(vals[v] - vals[v ^ (1 << i)])
                         for v in range(N)
                         if (v & suffix) == (x & suffix)))
        rows.append(tuple(a))
    return tuple(rows)


def valid_rows(vals, rows, n):
    N = 1 << n
    return all(abs(vals[x] - vals[y]) <=
               sum(rows[x][i] for i in range(n)
                   if (x ^ y) & (1 << i))
               for x in range(N) for y in range(N))


def aq_ratio(vals, rows, weights, n):
    """LHS of (AQ) divided by (1/2) sum_i E_cube(delta_i f)^2/w_i."""
    N = 1 << n
    numerator = Fraction(0)
    for x in range(N):
        change = vals[x] - vals[x ^ (N - 1)]
        if change > 0:
            denom = sum(weights[i] * rows[x][i]
                        * rows[x ^ (N - 1)][i] for i in range(n))
            assert denom > 0, "Positive change with zero denominator"
            numerator += Fraction(change ** 4, denom)
    lhs = numerator / N
    unit_rhs = sum((Fraction(
        sum((vals[x] - vals[x ^ (1 << i)]) ** 2 for x in range(N)),
        2 * N * weights[i]) for i in range(n)), Fraction(0))
    return lhs / unit_rhs if unit_rhs else Fraction(0)


def test_additive_sharpness():
    for n in range(1, 9):
        N = 1 << n
        # Values and rows multiply f_n=(sum of signs)/n by n.
        # The quartic ratio is invariant under joint scaling of f and rows.
        vals = tuple(2 * x.bit_count() - n for x in range(N))
        rows = tuple((2,) * n for _ in range(N))
        assert valid_rows(vals, rows, n)
        needed = aq_ratio(vals, rows, (1,) * n, n)
        assert needed == 3 - Fraction(2, n), (n, needed)

        # Independent two-draw ratio, conditional on k differing positions.
        pairs = 3 - Fraction(4, n) * (1 - Fraction(1, 2 ** n))
        via_binomial = sum(
            (Fraction(comb(n, k), 2 ** n)
             * Fraction(2 * (3 * k - 2), n ** 2)
             for k in range(1, n + 1)), Fraction(0)) * n
        assert pairs == via_binomial
        if n <= 6:
            numerator = Fraction(0)
            for x in range(N):
                for y in range(N):
                    k = (x ^ y).bit_count()
                    change = vals[x] - vals[y]
                    if change > 0:
                        assert k > 0
                        numerator += Fraction(change ** 4, 4 * k)
            # The scaled f has sum_i I_i=n.
            assert numerator / (N * N * n) == pairs
        print(f"additive n={n}: antipodal={needed}; independent pairs={pairs}")


def test_nonlinear_finite_screen():
    count = 0
    for n, alphabet, repetitions in (
        (3, (-1, 0, 1), None),
        (4, (-1, 1), 512),
    ):
        rng = Random(20261110)
        values = (product(alphabet, repeat=1 << n)
                  if repetitions is None else
                  (tuple(rng.choice(alphabet) for _ in range(1 << n))
                   for _ in range(repetitions)))
        local_count = 0
        maximum = Fraction(0)
        for vals in values:
            if len(set(vals)) == 1:
                continue
            for row_builder in (rows_global_edges, rows_suffix_telescope):
                rows = row_builder(vals, n)
                assert valid_rows(vals, rows, n)
                for w in ((1,) * n, tuple(range(1, n + 1))):
                    required_C = aq_ratio(vals, rows, w, n)
                    # Finite counterexample screen only; not a proof of C=3.
                    assert required_C <= 3, (n, vals, w, required_C)
                    maximum = max(maximum, required_C)
                    local_count += 1
        count += local_count
        print(f"screen n={n}: {local_count} row/weight cases; max={maximum}")
    assert count == 28280
    print(f"PASS {count} finite screen cases; universal AQ(C) remains OPEN")


if __name__ == "__main__":
    test_additive_sharpness()
    test_nonlinear_finite_screen()

#!/usr/bin/env python3
"""Independent exhaustive, exact-rational audit of the greedy projection telescope.

All 3x2 matrices with entries in {-1,0,1} except the zero matrix, and
all nine initial errors in {-1,0,1}^2. 6,552 systems, eight updates each.
This is a finite falsifier, not a proof or a historical-originality check.
No randomized inputs; no dependency on the original seeded checker.
"""
from fractions import Fraction
from itertools import product

def inner(u, v):
    return sum((a*b for a, b in zip(u, v)), Fraction(0))

def main():
    systems = steps = 0
    for entries in product((-1, 0, 1), repeat=6):
        rows = [tuple(Fraction(v) for v in entries[j:j+2]) for j in (0, 2, 4)]
        norms = [inner(row, row) for row in rows]
        W = sum(norms)
        if W == 0:
            continue
        for initial in product((-1, 0, 1), repeat=2):
            e = tuple(Fraction(z) for z in initial)  # Translate exact solution to zero.
            E0 = inner(e, e)
            cumulative_residual_sq = Fraction(0)
            for step in range(8):
                residual = [inner(a, e) for a in rows]
                residual_sq = sum((z*z for z in residual), Fraction(0))
                cumulative_residual_sq += residual_sq
                assert cumulative_residual_sq <= W * E0, (entries, initial, step, "prefix")
                idx = max((j for j in range(3) if norms[j]),
                          key=lambda j: residual[j]**2 / norms[j])
                before = inner(e, e)
                e = tuple(e[k] - residual[idx] / norms[idx] * rows[idx][k]
                          for k in range(2))
                after = inner(e, e)
                assert before - after == residual[idx]**2 / norms[idx]
                assert W * (before - after) >= residual_sq
                steps += 1
            systems += 1
    assert (systems, steps) == (6552, 52416), (systems, steps)
    print("PASS: 6,552 exact matrices/starting-errors and 52,416 projection steps")
    print("PASS: Pythagorean identity, weighted maximum, every prefix sum")

if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""Independent exact spectral checker for the SLD tensor comparison.

Works entirely over fractions. It does not import the trine score checker
and cannot substitute for a proof for all spectra/dimensions.
"""
from fractions import Fraction as F
from itertools import product


def sharp_constant(kappas):
    assert len(kappas) > 0 and all(k >= 1 for k in kappas)
    numerator = F(2) ** (1 - len(kappas))
    denominator = F(1)
    for k in kappas:
        numerator *= 1 + k
        denominator *= k
    return numerator / (1 + denominator)


def matrix_unit_ratio(ps, q_values, row, col):
    n = len(ps)
    a, b = F(1), F(1)
    numerator = F(2) ** (1 - n)
    for i in range(n):
        ai = ps[i] if row[i] == 0 else q_values[i]
        bi = ps[i] if col[i] == 0 else q_values[i]
        a *= ai
        b *= bi
        numerator *= ai + bi
    return numerator / (a + b)


def check(kappas):
    ps = tuple(k / (1 + k) for k in kappas)
    qs = tuple(1 / (1 + k) for k in kappas)
    indices = list(product(range(2), repeat=len(kappas)))
    constant = sharp_constant(kappas)
    ratios = [matrix_unit_ratio(ps, qs, u, v) for u in indices for v in indices]
    assert min(ratios) == constant, (kappas, min(ratios), constant)
    assert matrix_unit_ratio(ps, qs, (0,) * len(kappas), (1,) * len(kappas)) == constant

    # A physical full-rank ternary-to-qubit encoding with these marginals
    # is obtained by choosing 0 < r_i^2 < p_i*q_i, e.g. r_i=p_i*q_i/2.
    rs = tuple(p * q / 2 for p, q in zip(ps, qs))
    assert all(0 < r*r < p*q for p, q, r in zip(ps, qs, rs))
    prod_p, prod_q, prod_r = F(1), F(1), F(1)
    for p, q, r in zip(ps, qs, rs):
        prod_p *= p
        prod_q *= q
        prod_r *= r
    gain = prod_r**2 / (prod_p + prod_q)
    a_product = F(1)
    for r in rs:
        a_product *= 2 * r*r
    ratio = gain / (a_product * F(1, 2))
    assert ratio == constant, (kappas, ratio, constant)
    print(f"PASS kappas={kappas} constant={constant} units={len(ratios)}")


if __name__ == "__main__":
    for parameters in ((F(1),), (F(9),), (F(1), F(9)), (F(2), F(5)),
                       (F(1), F(3), F(9)), (F(9),) * 4):
        check(parameters)
    print("Exact spectral comparisons and nonuniform ternary realizations pass.")

#!/usr/bin/env python3
"""Independent finite-state audit for dependent-Q2 v0.1.

This audits exact finite laws and Gram formulas with fractions; it does NOT
prove the arbitrary-measure, infinite-product, or transfer statements.
Run: python3 scripts/check_dependent_q2_pair_exact.py
"""
from fractions import Fraction
from itertools import product


STATES = tuple(product((-1, 1), repeat=2))


def law(r):
    assert Fraction(-1) < r < Fraction(1)
    return {(x, y): (1 + r * x * y) / 4 for (x, y) in STATES}


def expectation(p, f):
    return sum((p[(x, y)] * f(x, y) for x, y in STATES), Fraction(0))


def variance(p, f):
    m = expectation(p, f)
    return expectation(p, lambda x, y: (f(x, y) - m) ** 2)


def q1(r, f, x, y):
    """E[f | Y=y]: delete X."""
    return sum(((1 + r * xx * y) * f(xx, y) / 2 for xx in (-1, 1)), Fraction(0))


def q2(r, f, x, y):
    """E[f | X=x]: delete Y."""
    return sum(((1 + r * x * yy) * f(x, yy) / 2 for yy in (-1, 1)), Fraction(0))


def influence(p, r, f, i):
    q = q1 if i == 1 else q2
    return expectation(p, lambda x, y: (f(x, y) - q(r, f, x, y)) ** 2)


def audit(r):
    p = law(r)
    assert sum(p.values()) == 1
    x = lambda xx, yy: Fraction(xx)
    y = lambda xx, yy: Fraction(yy)
    assert expectation(p, x) == expectation(p, y) == 0
    assert variance(p, x) == 1
    assert influence(p, r, x, 1) == 1 - r*r
    assert influence(p, r, x, 2) == 0

    # Noncommutation: f=Y has zero X influence; P_X f=rX has positive X influence.
    projected_y = lambda xx, yy: r * xx
    assert influence(p, r, y, 1) == 0
    assert influence(p, r, projected_y, 1) == r*r*(1-r*r)

    # Entire 3D centered-function space has explicit variance and energy forms.
    for a, b, c in product(range(-2, 3), repeat=3):
        h = lambda xx, yy: a*xx + b*yy + c*(xx*yy-r)
        v = variance(p, h)
        e = influence(p, r, h, 1) + influence(p, r, h, 2)
        assert v == a*a + b*b + 2*r*a*b + (1-r*r)*c*c
        assert e == (1-r*r)*(a*a+b*b+2*c*c)
        assert v <= e / (1-abs(r))

    # Sharp within-block tensorization factor, attained by h=X+sign(r)*Y.
    s = 1 if r >= 0 else -1
    h = lambda xx, yy: xx + s*yy
    v = variance(p, h)
    e = influence(p, r, h, 1) + influence(p, r, h, 2)
    assert v * (1-abs(r)) == e
    return {"rho": str(r), "site_influence_x": str(1-r*r),
            "block_AT_constant": str(1/(1-abs(r))),
            "noncommuting_projection_influence": str(r*r*(1-r*r))}


def main():
    for r in (Fraction(-9,10), Fraction(-1,2), Fraction(0), Fraction(1,2),
              Fraction(3,4), Fraction(9,10), Fraction(999,1000)):
        print(audit(r))
    # C=106 is larger than the reference product coefficient C_2~105.416.
    # Its proposed unmodified dependent-law extension already fails.
    r = Fraction(999,1000)
    assert Fraction(106)*(1-r*r) < 1
    print("PASS: exact rational pair audit + failure of C<=106 under dependence.")
    print("LIMIT: finite exhaustive sample over coefficients, not a Lean proof.")


if __name__ == "__main__":
    main()

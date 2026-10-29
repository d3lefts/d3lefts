#!/usr/bin/env python3
"""Vesper independent exact audit of the nested-Sidon certificate ceiling.

Scope: proof method / abstract score oracle, not a global upper bound on
actual infinite Sidon sets. All comparison inequalities use integer/Fraction
arithmetic. Implements neither Axiom nor Ryev verifier modules.
"""
from fractions import Fraction as Q
from math import isqrt


def proxy_square(r, alpha, beta):
    assert isinstance(alpha, Q) and isinstance(beta, Q)
    assert 0 < beta < alpha <= Q(1, 4) and r >= 1
    loss = Q(16 * r, 27) * alpha**3 / (alpha - beta)
    if loss >= 1:
        return None  # nonpositive certified numerator; cannot beat 1/sqrt(2)
    return (1 - loss)**2 / (2 - beta)


def finite_grid_audit():
    cases = 0
    strict = 0
    for r in range(1, 41):
        for i in range(2, 81):
            alpha = Q(i, 320)  # <= 1/4
            for j in range(1, i):
                beta = Q(j, 320)
                # Global minimum of alpha^3/(alpha-beta) is 27 beta^2/4.
                assert alpha**3 / (alpha - beta) >= Q(27, 4) * beta**2
                square = proxy_square(r, alpha, beta)
                cases += 1
                if square is None:
                    continue
                if square > Q(1, 2):
                    strict += 1
                    # New forced boundary-retreat/finite-horizon inequalities.
                    assert beta < Q(1, 8 * r)
                    assert square < Q(1, 1) / (2 - Q(1, 8 * r))
                # The proxy is a lower guarantee, not an upper bound on
                # actual Sidon density. The test only checks the formula.
    assert cases == 40 * sum(i - 1 for i in range(2, 81))
    assert strict > 0
    print("PASS: exact proxy inequalities", cases, "parameter cases;", strict,
          "strictly super-baseline cases")


def oracle_stages():
    # Purely abstract endpoint-count oracle (NOT a Sidon construction).
    # Every state has arbitrarily large successor endpoints with
    # stage-score tending to 1/sqrt(2), despite per-stage strict excess.
    r = 1
    checkpoints = []
    for stage in range(6):
        n = 10000 * r  # sqrt(new endpoint M), with unlimited larger choices
        # target c_r^2 = 1/2 + 1/(512r); exact floor(n*c_r).
        numerator = n * n * (256 * r + 1)
        denominator = 512 * r
        next_r = isqrt(numerator // denominator)
        assert next_r > r and next_r <= n
        assert 2 * next_r**2 > n**2, "strictly superbaseline stage failed"
        # The exact lower score condition follows from floor-sqrt:
        assert next_r**2 * denominator <= numerator
        assert (next_r + 1)**2 * denominator > numerator
        checkpoints.append((stage, len(str(r)), len(str(n)),
                            len(str(2 * next_r**2 - n**2))))
        r = next_r
    print("PASS: six exact abstract-oracle levels; "
          "(step, digits(initial marks), digits(sqrt M), digits(excess margin)):")
    for item in checkpoints:
        print("  ", item)
    print("ANALYTIC LIMIT: r grows unbounded, n grows unbounded, "
          "floor(n*c_r)/n -> 1/sqrt(2).")


def negative_controls():
    # A forged bound claiming strict fixed beta with arbitrarily large r
    # must be rejected by the exact loss inequality.
    alpha, beta = Q(1, 10), Q(1, 15)
    assert proxy_square(1, alpha, beta) is not None
    assert proxy_square(1000, alpha, beta) is None

    # A purported >baseline claim with beta >=1/(8r) is impossible.
    for r in (1, 2, 5, 10, 100):
        beta = Q(1, 8 * r)
        alpha = Q(3, 2) * beta
        if alpha <= Q(1, 4):
            sq = proxy_square(r, alpha, beta)
            assert sq is None or sq <= Q(1, 2)
    print("PASS: fixed-window and forced-retreat negative controls")


if __name__ == "__main__":
    finite_grid_audit()
    oracle_stages()
    negative_controls()

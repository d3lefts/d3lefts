#!/usr/bin/env python3
"""Exact rational checker for adaptive phase-transcript scaling and phase-class risk.

No external packages. This is a finite test, NOT a ProductSphereZero proof.
Run: python3 scripts/check_phase_causal_scaling_exact.py
"""
from fractions import Fraction as F
from itertools import product


def dot(a, b):
    return sum((x * y for x, y in zip(a, b)), F(0))


def add(a, b):
    return tuple(x + y for x, y in zip(a, b))


def sub(a, b):
    return tuple(x - y for x, y in zip(a, b))


def scale(c, a):
    return tuple(c * x for x in a)


def squared_norm(a):
    return dot(a, a)


def row(stage, history, n):
    """Nonconstant rational history-dependent sensor with quadratic feedback."""
    total = sum(history, F(0))
    quadratic = sum((v * v for v in history), F(0))
    return tuple(F((stage + 1) * (i + 1), 2)
                 + F(i - stage, 3) * total
                 + F(i + 1, 5) * quadratic for i in range(n))


def transcript(signal, stages, policy=row):
    h = []
    for stage in range(stages):
        h.append(dot(policy(stage, tuple(h), len(signal)), signal) ** 2)
    return tuple(h)


def rescaled_policy(lam):
    return lambda j, h, n: row(j, tuple(lam ** 2 * v for v in h), n)


def WRONG_linear_rescaling(lam):
    return lambda j, h, n: row(j, tuple(lam * v for v in h), n)


def risk_square(estimate, signal):
    """Squared sign-orbit distance; exact rational, no sqrt/floats."""
    return min(squared_norm(sub(estimate, signal)),
               squared_norm(add(estimate, signal)))


def verify():
    scaling_checks = 0
    mutation_detected = 0
    alphabet = (F(-1), F(-1, 2), F(0), F(1, 2), F(1))
    for n in (2, 3):
        for signal in product(alphabet, repeat=n):
            for stages in (1, 2, 3):
                for lam in (F(1, 2), F(3, 2), F(2)):
                    actual = transcript(scale(lam, signal), stages)
                    proper = scale(lam ** 2, transcript(signal, stages, rescaled_policy(lam)))
                    assert actual == proper, (n, stages, lam, signal, actual, proper)
                    scaling_checks += 1
                    incorrect = scale(lam ** 2, transcript(signal, stages, WRONG_linear_rescaling(lam)))
                    if stages > 1 and actual != incorrect:
                        mutation_detected += 1
    assert scaling_checks == 1350
    assert mutation_detected > 0, "negative mutation control failed"

    risk_checks = 0
    unit_pairs = (
        ((F(1), F(0), F(0)), (F(0), F(1), F(0))),
        ((F(3, 5), F(4, 5), F(0)), (F(5, 13), F(12, 13), F(0))),
        ((F(1), F(0), F(0)), (F(1), F(0), F(0))),
    )
    for u, v in unit_pairs:
        assert squared_norm(u) == squared_norm(v) == 1
        for lam in (F(1, 3), F(1), F(5, 2)):
            x = scale(lam, add(u, v))
            y = scale(lam, sub(u, v))
            assert squared_norm(sub(x, y)) == squared_norm(add(x, y)) == 4 * lam ** 2
            for estimate in product((F(-2), F(-1), F(0), F(1), F(2)), repeat=3):
                assert risk_square(estimate, x) + risk_square(estimate, y) >= 2 * lam ** 2
                risk_checks += 1
    assert risk_checks == 1125
    print(f"PASS: {scaling_checks} exact causal transcript scaling instances")
    print(f"PASS: {mutation_detected} incorrect-history scaling counterexamples")
    print(f"PASS: {risk_checks} exact phase-orbit risk lower-bound checks")
    print("LIMIT: Finite rational replay, not all-dimensional topology, Lean compilation or global originality.")


if __name__ == "__main__":
    verify()

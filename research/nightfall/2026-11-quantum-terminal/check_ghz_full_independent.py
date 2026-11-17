#!/usr/bin/env python3
"""Direct independent matrix audit; finite tests, not universal Lean certification."""
import itertools
from fractions import Fraction
import numpy as np

def operators(d):
    omega = complex(-.5, 3**.5 / 2)
    states = list(itertools.product(range(3), repeat=d))
    labels = list(itertools.product(range(2), repeat=d))
    n = 1 << d
    B = np.zeros((n, n), dtype=complex)
    A = np.zeros_like(B)
    for x in states:
        v = np.array([np.prod([((3/4)**.5 if bit == 0
            else (1/4)**.5 * omega**x[j])
            for j, bit in enumerate(s)]) for s in labels])
        rho = np.outer(v, v.conj())
        assert abs(np.vdot(v, v).real - 1) < 1e-12
        B += rho / len(states)
        A += (omega**sum(x)).real * rho / len(states)
    return B, A

def ghz(n):
    plus = np.zeros(n, dtype=complex)
    plus[0] = plus[-1] = 1 / 2**.5
    minus = plus.copy()
    minus[-1] = -minus[-1]
    ep = np.outer(plus, plus.conj())
    em = np.outer(minus, minus.conj())
    return [ep, em, np.eye(n) - ep - em]

def gain(B, A, effects):
    ans = 0.
    for E in effects:
        w = np.trace(B @ E).real
        a = np.trace(A @ E)
        assert abs(a.imag) < 1e-10
        assert w >= -1e-12
        if w > 1e-13: ans += (a.real)**2 / w
        else: assert abs(a) < 1e-11
    return ans

def check(d):
    B, A = operators(d)
    n = 1 << d
    predicted = Fraction(3, 16)**d / (
        Fraction(3, 4)**d + Fraction(1, 4)**d)
    off = A.copy()
    off[0, -1] = off[-1, 0] = 0
    assert np.max(np.abs(off)) < 2e-12
    assert abs(A[0, -1].real - (3**.5 / 4)**d/2) < 2e-12
    assert abs(B[0, 0].real - .75**d) < 2e-12
    assert abs(B[-1, -1].real - .25**d) < 2e-12
    assert np.max(np.abs(B - np.diag(np.diag(B)))) < 2e-12
    E = ghz(n)
    assert np.max(np.abs(sum(E) - np.eye(n))) < 1e-12
    assert all(np.min(np.linalg.eigvalsh(e)) > -1e-12 for e in E)
    measured = gain(B, A, E)
    assert abs(measured - float(predicted)) < 2e-12
    rng = np.random.default_rng(9 + d)
    for _ in range(20):
        M = rng.normal(size=(n, n)) + 1j * rng.normal(size=(n, n))
        U, _ = np.linalg.qr(M)
        effects = [np.outer(U[:, i], U[:, i].conj()) for i in range(n)]
        assert gain(B, A, effects) <= measured + 3e-12
    if n > 2:
        assert np.max(np.abs(E[0] + E[1] - np.eye(n))) > .5
    return (d, n, str(predicted))

if __name__ == "__main__":
    for d in range(1, 5): print(check(d))
    print("PASS direct-state Born/POVM finite audit, all 4 dimensions")

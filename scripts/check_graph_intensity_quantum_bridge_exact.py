#!/usr/bin/env python3
"""Exact indexed-intensity response-oracle to phase-kickback regression.

Small rational instances only; no all-n Lean or T2 simulator certificate.
"""
from sympy import Matrix, Rational, sqrt, eye, zeros, kronecker_product


def graphs():
    yield 3, [(0, 1), (1, 2), (0, 2)]
    yield 4, [(0, 1), (1, 2), (2, 3), (0, 3), (0, 2)]


def signs_of(s, n):
    return [-1 if (s >> v) & 1 else 1 for v in range(n)]


def check(n, edges):
    D = [(None, None)] + edges
    size = len(D)
    z = Matrix([Rational(j+1, 2*size) for j in range(size)])
    minus = Matrix([1, -1]) / sqrt(2)
    plus = Matrix([1, 1]) / sqrt(2)
    work = Matrix([Rational(3, 5), Rational(4, 5)])
    wrong_phase = False
    codewords = set()
    for s in range(1 << n):
        signs = signs_of(s, n)
        intensities = []
        dvals = []
        for uv in D:
            if uv == (None, None):
                d = 0
            else:
                u, v = uv
                # Unit sensing row (e_u+e_v)/sqrt(2), unit sign-signal.
                y = Rational((signs[u]+signs[v])**2, 2*n)
                assert y == Rational(1 + signs[u]*signs[v], n)
                assert y in (0, Rational(2, n))
                intensities.append(y)
                d = 1 - Rational(n, 2)*y
                assert d in (0, 1)
                assert (-1)**int(d) == signs[u]*signs[v]
            dvals.append(int(d))
        codewords.add(tuple(intensities))
        Q = zeros(2*size)
        for j, d in enumerate(dvals):
            if d:
                Q[2*j, 2*j+1] = Q[2*j+1, 2*j] = 1
            else:
                Q[2*j, 2*j] = Q[2*j+1, 2*j+1] = 1
        assert Q.T*Q == eye(2*size)
        phased = Matrix([((-1)**d)*z[j] for j, d in enumerate(dvals)])
        state = kronecker_product(z, minus, work)
        assert kronecker_product(Q, eye(2))*state == kronecker_product(phased, minus, work)
        plus_state = kronecker_product(z, plus, work)
        plus_after = kronecker_product(Q, eye(2))*plus_state
        assert plus_after == plus_state
        if plus_after != kronecker_product(phased, plus, work):
            wrong_phase = True
    assert len(codewords) == 2**(n-1)
    assert wrong_phase

    # Spanning tree: first n-1 edges make a path and recover all sign classes.
    tree = edges[:n-1]
    tree_words = {
        tuple(signs_of(s,n)[u]*signs_of(s,n)[v] for u,v in tree)
        for s in range(1 << n)
    }
    assert len(tree_words) == 2**(n-1)
    print(f"PASS graph n={n}: all {1<<n} sign assignments, "
          f"{len(codewords)} sign classes, one-call phase kickback, "
          "wrong-|+> negative control and n-1 tree reconstruction")


if __name__ == "__main__":
    for n, edges in graphs():
        check(n, edges)
    print("Finite exact coherent-response test, not full T2 or Lean certification.")

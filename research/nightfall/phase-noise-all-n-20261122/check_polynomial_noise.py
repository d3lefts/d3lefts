#!/usr/bin/env python3
"""Exact fraction checks for the all-dimensional fixed-row noise-modulus note.

Scope: arithmetic, Vandermonde inverse, polynomial factorization, exact noisy
fibers and negative controls. NOT a general theorem prover, Lean replay, or
independent non-author mathematical proof.
"""
from fractions import Fraction as Q
import random

SEED = 20261122
EXPECTED = {
    2: (Q(5), Q(36), Q(576)),
    3: (Q(209), Q(5272), Q(84352)),
    4: (Q(10625), Q(1364096), Q(21825536)),
    5: (Q(580865), Q(371819136), Q(5949106176)),
}


def poly_mul(a, b):
    c = [Q(0)] * (len(a) + len(b) - 1)
    for i, x in enumerate(a):
        for j, y in enumerate(b):
            c[i + j] += x * y
    return c


def poly_eval(a, x):
    value = Q(0)
    for coefficient in reversed(a):
        value = value * x + coefficient
    return value


def roots_poly(nodes):
    p = [Q(1)]
    for node in nodes:
        p = poly_mul(p, [-node, Q(1)])
    return p


def matrix_inverse(A):
    n = len(A)
    X = [[Q(A[i][j]) for j in range(n)] +
         [Q(int(i == j)) for j in range(n)] for i in range(n)]
    for k in range(n):
        i = next(i for i in range(k, n) if X[i][k])
        X[k], X[i] = X[i], X[k]
        scale = X[k][k]
        X[k] = [v / scale for v in X[k]]
        for i in range(n):
            if i == k:
                continue
            coef = X[i][k]
            X[i] = [X[i][j] - coef * X[k][j] for j in range(2 * n)]
    return [row[n:] for row in X]


def vecnorm2(a):
    return sum((v * v for v in a), Q(0))


def anisotropic_norm2(x, eps):
    return vecnorm2(x[:-1]) + eps * eps * x[-1] ** 2


def normalized_reading2(x, node, eps):
    d = len(x) - 1
    F = sum((x[k] * node ** k for k in range(d)), Q(0))
    F += eps * x[d] * node ** d
    denominator = sum((node ** (2 * k) for k in range(d)), Q(0))
    denominator += eps * eps * node ** (2 * d)
    return F * F / denominator


def node_data(n):
    d = n - 1
    m = 2 * d
    nodes = [Q(i, m) for i in range(m)]
    V = [[t ** k for k in range(m)] for t in nodes]
    B = matrix_inverse(V)
    for i in range(m):
        for j in range(m):
            assert sum((V[i][k] * B[k][j] for k in range(m)), Q(0)) == (i == j)
    S = sum((abs(B[k][i]) for k in range(m) for i in range(m)), Q(0))
    M = 4 ** d * (Q(n, 2) * S + 2 ** m)
    K = 16 * max(Q(1), M)
    assert (S, M, K) == EXPECTED[n], (n, S, M, K)
    return nodes, B, M, K


def exact_interpolation(n, nodes, Binv, rng, trials=75):
    d = n - 1
    W = roots_poly(nodes)
    m = 2 * d
    for _ in range(trials):
        P = [Q(rng.randrange(-5, 6), 7) for _ in range(d + 1)]
        T = [Q(rng.randrange(-5, 6), 9) for _ in range(d + 1)]
        H = poly_mul(P, T)
        lead = H[m]
        J = [H[k] - lead * W[k] for k in range(m)]
        evals = [poly_eval(H, node) for node in nodes]
        recovered = [sum((Binv[k][i] * evals[i] for i in range(m)), Q(0))
                     for k in range(m)]
        assert recovered == J
        # The polynomial-product coercivity used in the paper is a theorem.
        # A finite sample probes but does not establish its universal inequality.
        assert vecnorm2(H) * 16 ** d >= vecnorm2(P) * vecnorm2(T)
    # Include degree drops and zero factors explicitly.
    assert poly_mul([Q(0)] * (d + 1), [Q(1)]) == [Q(0)] * (d + 1)
    return trials


def signed_distance2(x, y):
    return min(vecnorm2([a - b for a, b in zip(x, y)]),
               vecnorm2([a + b for a, b in zip(x, y)]))


def check_noisy_pair(n, nodes, M, K, x, y, eps):
    s = eps * eps
    assert vecnorm2(x) <= 1 and vecnorm2(y) <= 1
    vals_x = [normalized_reading2(x, t, eps) for t in nodes]
    vals_y = [normalized_reading2(y, t, eps) for t in nodes]
    for a, b in zip(vals_x, vals_y):
        assert abs(a - b) <= 2 * s
        # The midpoint is a lawful common noisy transcript, with errors <= s.
        z = (a + b) / 2
        assert abs(z - a) <= s and abs(z - b) <= s
    p = [(a + b) / 2 for a, b in zip(x, y)]
    q = [(a - b) / 2 for a, b in zip(x, y)]
    assert anisotropic_norm2(p, eps) * anisotropic_norm2(q, eps) <= (M * s) ** 2
    if vecnorm2(x[:-1]) > (K * eps) ** 2:
        assert signed_distance2(x, y) < Q(1, 16)  # d_pm < 1/4
        return "away"
    assert vecnorm2(x[:-1]) <= (K * eps) ** 2
    near_center = [Q(0)] * (n - 1) + [Q(1, 2)]
    assert signed_distance2(x, near_center) <= (Q(1, 2) + K * K * s) ** 2
    return "near"


def exact_fibers(n, nodes, M, K):
    d = n - 1
    eps = Q(1, 10000)
    first = roots_poly(nodes[:d])
    second = roots_poly(nodes[d:])
    p = [eps * a / 4 for a in first[:d]] + [Q(1, 4)]
    q = [eps * b / 4 for b in second[:d]] + [Q(1, 4)]
    x = [a + b for a, b in zip(p, q)]
    y = [a - b for a, b in zip(p, q)]
    mode1 = check_noisy_pair(n, nodes, M, K, x, y, eps)
    # All sampled readings coincide exactly because P_p P_q is a multiple
    # of the root polynomial W.
    assert [normalized_reading2(x, t, eps) for t in nodes] == [
        normalized_reading2(y, t, eps) for t in nodes]
    # A very small rational noise level forces an away-axis branch.
    eps2 = Q(1, 8 * K)
    x2 = [Q(1, 2)] + [Q(0)] * (n - 1)
    y2 = [Q(1, 2) + eps2 * eps2 / 4] + [Q(0)] * (n - 1)
    mode2 = check_noisy_pair(n, nodes, M, K, x2, y2, eps2)
    assert mode2 == "away"
    return mode1, mode2


def main():
    rng = random.Random(SEED)
    for n in range(2, 6):
        nodes, Binv, M, K = node_data(n)
        trials = exact_interpolation(n, nodes, Binv, rng)
        modes = exact_fibers(n, nodes, M, K)
        print(f"PASS n={n}, m={2*n-2}, S={EXPECTED[n][0]}, M={M}, K={K}, "
              f"interpolation/product checks={trials}, exact/noisy fiber modes={modes}")
    print("PASS: all rational assertions. Scope: arithmetic and finite examples only; "
          "the all-n theorem needs independent mathematical review.")


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""Exact finite falsification for NIGHTFALL fair-sign mixed-Littlewood influence.

Source-derived claims tested:
 * vector degree <= 2 on fair controls: W^2 <= 16 A^2 M;
 * signed one-leaf Q_L: ||Q_L||_1 <= A, W_Q^2 <= 4 A^2 M;
 * exact average_L W(Q_L) = W(G)/2;
 * pure tripartite trilinear: V^2 <= 4 B^2 M;
 * centered arbitrary (including rare) rank-one leaves: V^2 <= 25 B^2 M.
All checks are integer or Fraction exact. Finite tests do not prove the theorem.
"""
from fractions import Fraction as Q
from itertools import product
from random import Random

RNG = Random(20261111)
CHECKS = 0


def eval_coeff(c, lin, pairs, x):
    return c + sum(a * x[i] for i, a in enumerate(lin)) + sum(
        a * x[i] * x[j] for (i, j), a in pairs.items()
    )


def table_stats(table, states):
    k = len(table[0])
    n = len(states[0])
    avg = [Q(sum(row[a] for row in table), len(states)) for a in range(k)]
    W = sum((Q(sum((row[a] - avg[a])**2 for row in table), len(states))
             for a in range(k)), Q())
    loc = {x: i for i, x in enumerate(states)}
    J = []
    for i in range(n):
        t = sum(
            sum((table[r][a] - table[loc[x[:i]+(-x[i],)+x[i+1:]][a])**2
                for a in range(k))
            for r, x in enumerate(states)
        )
        J.append(Q(t, 4 * len(states)))
    return W, J


def random_vector_quadratics():
    global CHECKS
    for n, k in ((2, 2), (3, 4), (4, 3), (5, 4)):
        states = list(product((-1, 1), repeat=n))
        for _ in range(125):
            coeffs = []
            for _a in range(k):
                coeffs.append((
                    RNG.randrange(-3, 4),
                    [RNG.randrange(-3, 4) for _ in range(n)],
                    {(i, j): RNG.randrange(-3, 4)
                     for i in range(n) for j in range(i + 1, n)}
                ))
            table = [tuple(eval_coeff(*c, x) for c in coeffs) for x in states]
            A = max(sum(abs(y) for y in row) for row in table)
            W, J = table_stats(table, states)
            M = max(J)
            assert W**2 <= 16 * A*A*M, ("vector quadratic", n, k, W, M, A)

            # Flip every sign in L: odd parity extracts precisely one-leaf
            # Fourier terms at degree <=2. Independent direct table check.
            projection_variance = Q()
            for bits in product((0, 1), repeat=n):
                L = [i for i in range(n) if bits[i]]
                loc = {x: i for i, x in enumerate(states)}
                qt = []
                for x, row in zip(states, table):
                    flip = tuple(-x[i] if i in L else x[i] for i in range(n))
                    other = table[loc[flip]]
                    qt.append(tuple(Q(row[a] - other[a], 2) for a in range(k)))
                assert max(sum(abs(v) for v in q) for q in qt) <= A
                Wq, Jq = table_stats(qt, states)
                assert all(Jq[i] <= J[i] for i in range(n))
                assert Wq**2 <= 4 * A*A*M, ("mixed slice", n, bits)
                projection_variance += Wq
            assert projection_variance / (2**n) == W / 2, (
                "one-leaf retention", n, projection_variance, W)
            CHECKS += 1


def exhaustive_tripartite():
    global CHECKS
    signs = list(product((-1, 1), repeat=2))
    for coefficients in product((-1, 0, 1), repeat=8):
        if not any(coefficients):
            continue
        B = max(abs(sum(
            coefficients[(a*2+b)*2+c]*x[a]*y[b]*z[c]
            for a in range(2) for b in range(2) for c in range(2)
        )) for x in signs for y in signs for z in signs)
        V = sum(t*t for t in coefficients)
        influence = (
            [sum(coefficients[(a*2+b)*2+c]**2
                 for a in range(2) for c in range(2)) for b in range(2)]
            + [sum(coefficients[(a*2+b)*2+c]**2
                   for b in range(2) for c in range(2)) for a in range(2)]
            + [sum(coefficients[(a*2+b)*2+c]**2
                   for a in range(2) for b in range(2)) for c in range(2)]
        )
        M = max(influence)
        assert V*V <= 4*B*B*M, ("tripartite", coefficients, V, M, B)
        CHECKS += 1


def rare_leaf_selector():
    global CHECKS
    # One arbitrary high-bias leaf per branch, independent controls.
    # Y in {0,1}; P(Y=1)=1/101. phi(1)=100, phi(0)=-1 has E phi=0.
    ctrl = list(product((-1, 1), repeat=3))
    control_values = []
    for _ in range(30):
        coeff = [
            (RNG.randrange(-2, 3),
             [RNG.randrange(-2, 3) for _ in range(3)],
             {(i, j):RNG.randrange(-2, 3)
              for i in range(3) for j in range(i+1, 3)})
            for k in range(2)]
        control_values = [[Q(eval_coeff(*c, x), 101) for c in coeff]
                          for x in ctrl]
        phi = (-1, 100)
        law = (Q(100, 101), Q(1, 101))
        states = list(product(range(2), repeat=2))
        vals = [(x, y,
                 sum((control_values[i][k] * phi[y[k]]
                      for k in range(2)), Q()))
                for i,x in enumerate(ctrl) for y in states]
        B = max(abs(v) for _,_,v in vals)
        V = sum((law[y[0]]*law[y[1]] * v*v for x,y,v in vals), Q()) / len(ctrl)
        assert sum((law[y[0]]*law[y[1]] * v for x,y,v in vals), Q()) == 0
        inf = []
        for i in range(3):
            loc = {(x,y):v for x,y,v in vals}
            inf.append(sum((law[y[0]]*law[y[1]] *
                            (v-loc[x[:i]+(-x[i],)+x[i+1:],y])**2 / 4
                            for x,y,v in vals), Q()) / len(ctrl))
        # Exact leaf influence I_Yk=E g_k^2 * Var(phi).
        inf.extend(sum((Q(100) *
                        control_values[i][k]**2 for i in range(len(ctrl))),
                       Q()) / len(ctrl) for k in range(2))
        M = max(inf)
        assert V*V <= 25*B*B*M, ("rare-leaf cubic selector", V, M, B)
        CHECKS += 1


if __name__ == "__main__":
    random_vector_quadratics()
    exhaustive_tripartite()
    rare_leaf_selector()
    print("PASS: exact independent fair-sign / rare-leaf tests =", CHECKS)
    print("Scope: finite falsification only; mathematical proof and priority separate")

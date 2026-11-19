#!/usr/bin/env python3
"""Independent finite-case and coefficient checker for the Forrelation mixture obstruction.

NOT a proof of the arbitrary-N theorem and NOT a Lean certificate.
For N=2, the Gaussian-sign joint distribution is recovered exactly
from eight equal angular sectors. For N=2,4 the uniform moment-generating
function is enumerated directly. No random sampling or third-party packages.
"""

from fractions import Fraction
from itertools import product
from math import cos, exp, isclose, log, pi, sin, sqrt

TOL = 2e-12


def hadamard(n):
    assert n >= 2 and n & (n - 1) == 0
    rows = [[1]]
    while len(rows) < n:
        rows = [r + r for r in rows] + [r + [-v for v in r] for r in rows]
    return rows


def forrelation(f, g, h):
    n = len(f)
    # Entries of h are unnormalised ±1; divide by n sqrt(n).
    return sum(f[i] * h[j][i] * g[j] for i in range(n) for j in range(n)) / (n * sqrt(n))


def binary_entropy(t):
    assert 0 <= t <= 1
    return -sum(x * log(x) for x in (t, 1 - t) if x > 0)


def entropy(dist):
    return -sum(float(v) * log(float(v)) for v in dist.values() if v > 0)


def n2_exact_gaussian_sign_distribution():
    h = hadamard(2)
    counts = {}
    for k in range(8):
        phi = (k + Fraction(1, 2)) * pi / 4
        z = (cos(phi), sin(phi))
        f = tuple(1 if v > 0 else -1 for v in z)
        g = tuple(1 if sum(h[j][i] * z[i] for i in range(2)) > 0 else -1 for j in range(2))
        key = f, g
        counts[key] = counts.get(key, 0) + 1
    # Eight equal angular sectors are a complete exact partition.
    assert len(counts) == 8 and set(counts.values()) == {1}
    p = {key: Fraction(count, 8) for key, count in counts.items()}
    allbits = list(product((-1, 1), repeat=2))
    marg_f = {f: sum((w for (x, y), w in p.items() if x == f), Fraction(0)) for f in allbits}
    marg_g = {g: sum((w for (x, y), w in p.items() if y == g), Fraction(0)) for g in allbits}
    assert all(w == Fraction(1, 4) for w in marg_f.values())
    assert all(w == Fraction(1, 4) for w in marg_g.values())
    stat_integer = sum((w * sum(f[i] * h[j][i] * g[j]
                         for i in range(2) for j in range(2))
                        for (f, g), w in p.items()), Fraction(0))
    assert stat_integer == 2
    mean_stat = float(stat_integer) / (2 * sqrt(2))
    alpha = 2 * sqrt(2) / pi * (pi / 4)
    assert isclose(mean_stat, alpha, abs_tol=TOL)
    mutual_information = 2 * log(4) - entropy(p)
    assert isclose(mutual_information, log(2), abs_tol=TOL)
    assert mutual_information + TOL >= 2 / pi**2 * 2
    print(f"N=2 exact sectors: 8 atoms of mass 1/8, E[S]={mean_stat:.12f}, "
          f"I(F;G)={mutual_information:.12f} nats")
    return p, allbits


def uniform_mgf_test():
    for n in (2, 4):
        h = hadamard(n)
        v = list(product((-1, 1), repeat=n))
        vals = [forrelation(f, g, h) for f in v for g in v]
        assert isclose(sum(vals), 0, abs_tol=TOL)
        for lam in (-8, -3, -1, -0.2, 0.2, 1, 3, 8):
            log_mgf = log(sum(exp(lam * x) for x in vals) / len(vals))
            upper = lam**2 / (2 * n)
            assert log_mgf <= upper + TOL, (n, lam, log_mgf, upper)
        print(f"N={n} exact uniform enumeration: {len(vals)} states, "
              "all 8 logarithmic mgf inequalities PASS")


def robust_example_test(p, allbits):
    u = {(f, g): Fraction(1, 16) for f in allbits for g in allbits}
    t = Fraction(1, 100)
    q = {k: (1 - t) * p.get(k, Fraction(0)) + t * u[k] for k in u}
    tv = sum((abs(q[k] - p.get(k, Fraction(0))) for k in u), Fraction(0)) / 2
    assert tv == Fraction(1, 200)
    marg_f = {f: sum((w for (x, y), w in q.items() if x == f), Fraction(0)) for f in allbits}
    marg_g = {g: sum((w for (x, y), w in q.items() if y == g), Fraction(0)) for g in allbits}
    mutual = entropy(marg_f) + entropy(marg_g) - entropy(q)
    delta = float(tv)
    alpha = sqrt(2) / 2
    # A bound on I(q), valid for *any* q at TV distance delta from P,
    # before using I(q) <= log M for a product-mixture representation of q.
    bound = (2 / 2) * (alpha - 2 * delta)**2 - 2 * delta * 2 * log(2) - 2 * binary_entropy(delta)
    assert mutual + TOL >= bound
    weak_universal_bound = (2 / 2) * (2 / pi - 2 * delta)**2 - 2 * delta * 2 * log(2) - 2 * binary_entropy(delta)
    assert mutual + TOL >= weak_universal_bound
    print(f"N=2 mixture perturbation: TV={tv}, I(q)={mutual:.12f}, "
          f"robust lower bound={bound:.12f}")


def constants_test():
    eta = 0.01
    coefficient = (2 / pi - 2 * eta)**2 / 2 - 2 * eta * log(2)
    offset = 2 * binary_entropy(eta)
    assert isclose(coefficient, 0.176247028226125, abs_tol=TOL)
    assert isclose(offset, 0.11200306870969469, abs_tol=TOL)
    print(f"TV≤1%: log M ≥ {coefficient:.12f} N - {offset:.12f} "
          "(assuming valid product-mixture representation)")


if __name__ == "__main__":
    p, allbits = n2_exact_gaussian_sign_distribution()
    uniform_mgf_test()
    robust_example_test(p, allbits)
    constants_test()
    print("PASS: finite exact cases and numerical coefficients; general proof is paper-level.")

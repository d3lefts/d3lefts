#!/usr/bin/env python3
"""Exact rational certificate for NIGHTFALL shifted-Hilbert 6/25 interpolation.

Checks the tensor Bernstein coefficient nonnegativity of
F(x,v)=3-(1-v)^2*(3-2x^4+50/3*x*v*(1-x^2)+625/36*v^2*(1-x^2))
on a 4x4 rational grid. No floating point, Monte Carlo or sympy.
The Lean source must separately prove each polynomial identity.
"""
from fractions import Fraction as Q
from math import comb
from hashlib import sha256

ZERO = Q(0)
ONE = Q(1)


def const(c):
    return {(0, 0): Q(c)}


def atom(i, j):
    return {(i, j): ONE}


def add(a, b):
    out = dict(a)
    for k, v in b.items():
        out[k] = out.get(k, ZERO) + v
        if not out[k]:
            del out[k]
    return out


def neg(a):
    return {k: -v for k, v in a.items()}


def sub(a, b):
    return add(a, neg(b))


def mul(a, b):
    out = {}
    for (i, j), c in a.items():
        for (k, l), d in b.items():
            ix = (i + k, j + l)
            out[ix] = out.get(ix, ZERO) + c * d
    return {k: v for k, v in out.items() if v}


def scale(a, factor):
    return {k: c * Q(factor) for k, c in a.items() if c}


def power(a, n):
    ans = const(1)
    for _ in range(n):
        ans = mul(ans, a)
    return ans


def eval_poly(p, x, y):
    return sum((c * x**i * y**j for (i, j), c in p.items()), ZERO)


x, v = atom(1, 0), atom(0, 1)
square = sub(const(1), power(x, 2))
inner = add(sub(const(3), scale(power(x, 4), 2)),
            add(scale(mul(mul(x, v), square), Q(50, 3)),
                scale(mul(power(v, 2), square), Q(625, 36))))
F = sub(const(3), mul(power(sub(const(1), v), 2), inner))
X_BOUNDS = tuple(map(Q, ["0", "2/5", "1/2", "3/5", "1"]))
V_BOUNDS = tuple(map(Q, ["0", "1/6", "1/3", "2/3", "1"]))


def substitute(a, b, c, d):
    X = add(const(a), scale(x, b - a))
    V = add(const(c), scale(v, d - c))
    out = const(0)
    for (i, j), coefficient in F.items():
        out = add(out, scale(mul(power(X, i), power(V, j)), coefficient))
    return out


def bernstein_coefficients(p):
    """Unnormalized basis: X^i(1-X)^(4-i) V^j(1-V)^(4-j)."""
    result = []
    for i in range(5):
        for j in range(5):
            coefficient = ZERO
            for k in range(i + 1):
                for l in range(j + 1):
                    coefficient += p.get((k, l), ZERO) * Q(
                        comb(i, k) * comb(j, l), comb(4, k) * comb(4, l)
                    )
            coefficient *= comb(4, i) * comb(4, j)
            result.append(((i, j), coefficient))
    return result


def main():
    all_coefficients, zeros = [], 0
    for i in range(4):
        for j in range(4):
            a, b = X_BOUNDS[i:i + 2]
            c, d = V_BOUNDS[j:j + 2]
            local = substitute(a, b, c, d)
            coefficients = bernstein_coefficients(local)
            assert len(coefficients) == 25
            assert all(z >= 0 for _, z in coefficients), (i, j)
            zeros += sum(z == 0 for _, z in coefficients)
            all_coefficients.extend(
                (i, j, k, l, numerator, denominator)
                for (k, l), z in coefficients
                for numerator, denominator in [(z.numerator, z.denominator)]
            )
            # Separate evaluation of the Bernstein and monomial forms.
            for A in (Q(0), Q(1, 4), Q(1, 2), Q(3, 4), Q(1)):
                for B in (Q(0), Q(1, 4), Q(1, 2), Q(3, 4), Q(1)):
                    left = eval_poly(F, a + (b - a) * A, c + (d - c) * B)
                    right = sum(
                        (z * A**k * (1-A)**(4-k) * B**l * (1-B)**(4-l)
                         for (k, l), z in coefficients), ZERO
                    )
                    assert left == right, (i, j, A, B)
    assert len(all_coefficients) == 400 and zeros == 4
    record = "\n".join(",".join(map(str, item)) for item in all_coefficients)
    print("PASS: 16 exact cells, 400 rational Bernstein coefficients, 396 positive, 4 zero")
    print("PASS: 400 cell-sample monomial/Bernstein exact identities")
    print("sha256=" + sha256(record.encode()).hexdigest())


if __name__ == "__main__":
    main()

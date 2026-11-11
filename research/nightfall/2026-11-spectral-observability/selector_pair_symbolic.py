#!/usr/bin/env python3
"""Exact symbolic all-bias proof of the corrected degree-three pair obstruction.

Checks all four ANOVA values as polynomials in p, then the piecewise maximum.
No third-party dependencies, floats, or input sampling are needed for identities.
"""
from fractions import Fraction
from itertools import product


def add(a, b):
    n = max(len(a), len(b))
    return tuple((a[i] if i < len(a) else 0) + (b[i] if i < len(b) else 0) for i in range(n))


def sub(a, b):
    return add(a, tuple(-v for v in b))


def mul(a, b):
    out = [0] * (len(a) + len(b) - 1)
    for i, u in enumerate(a):
        for j, v in enumerate(b):
            out[i + j] += u * v
    return tuple(out)


def eqpoly(a, b):
    def trim(q):
        q = list(q)
        while len(q) > 1 and q[-1] == 0:
            q.pop()
        return q
    return trim(a) == trim(b)


p, q = (0, 1), (1, -1)


def f(x):
    return 1 if ((x[0] and x[1]) or (x[2] and x[3]) or not any(x)) else -1


def conditional_pair(i, j, a, b):
    rem = [k for k in range(4) if k not in (i, j)]
    result = (0,)
    for s, t in product((0, 1), repeat=2):
        x = [0, 0, 0, 0]
        x[i], x[j] = a, b
        x[rem[0]], x[rem[1]] = s, t
        weight = mul(p if s else q, p if t else q)
        result = add(result, weight if f(x) == 1 else tuple(-v for v in weight))
    return result


def mixed(i, j):
    return add(sub(conditional_pair(i, j, 1, 1), conditional_pair(i, j, 1, 0)),
               sub(conditional_pair(i, j, 0, 0), conditional_pair(i, j, 0, 1)))


for i, j in ((0, 1), (2, 3)):
    delta = mixed(i, j)
    assert eqpoly(delta, (4, -4))
    h = {(a, b): conditional_pair(i, j, a, b) for a, b in product((0, 1), repeat=2)}
    # Center both input bits and compare each ANOVA value symbolically.
    for a, b in product((0, 1), repeat=2):
        cent_a, cent_b = ((1, -1) if a else (0, -1)), ((1, -1) if b else (0, -1))
        formula = mul(delta, mul(cent_a, cent_b))
        # Pair-Hoeffding component: double-centered conditional response.
        e_a = add(mul(p, h[(1, b)]), mul(q, h[(0, b)]))
        e_b = add(mul(p, h[(a, 1)]), mul(q, h[(a, 0)]))
        grand = (0,)
        for u, v in product((0, 1), repeat=2):
            grand = add(grand, mul(mul(p if u else q, p if v else q), h[(u, v)]))
        anova = add(sub(sub(h[(a, b)], e_a), e_b), grand)
        assert eqpoly(anova, formula), (i, j, a, b, anova, formula)
    print(f'pair {i+1}{j+1}: f_pair(a,b)=4(1-p)(a-p)(b-p), all four symbols')

# f has degree <=3: its fourth-order Boolean Mobius coefficient is exactly zero.
assert sum((-1) ** (4-sum(x)) * f(x) for x in product((0, 1), repeat=4)) == 0

# Exact pointwise check of the corrected supremum on both sides of p=1/2.
for t in (Fraction(1, 1000), Fraction(1, 3), Fraction(1, 2),
          Fraction(3, 4), Fraction(9, 10)):
    component = [4 * (1-t) * (a-t) * (b-t) for a, b in product((0, 1), repeat=2)]
    exact_pair_sum = 2 * max(abs(v) for v in component)
    assert exact_pair_sum == 8 * (1-t) * max(t, 1-t) ** 2
    if t > Fraction(1, 2):
        assert exact_pair_sum != 8*(1-t)**3  # the source v3 formula is false here
    print(f'p={t}: total pair mass={exact_pair_sum}')

print('PASS: degree <=3 and all-bias exact formula 8(1-p) max(p,1-p)^2; limit p->0 is 8')

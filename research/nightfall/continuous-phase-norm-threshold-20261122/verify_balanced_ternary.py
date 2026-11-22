"""Exact arithmetic diagnostic for the balanced-ternary sensing construction.

Run with Python 3. This tests finite cases, not the continuity or lower bounds.
"""
from fractions import Fraction as Q
from itertools import product
from math import isqrt
from random import Random


def pos_sqrt(q):
    n, d = isqrt(q.numerator), isqrt(q.denominator)
    assert n * n == q.numerator and d * d == q.denominator
    return Q(n, d)


def replay(x, R):
    d = len(x) - 1
    h = tuple(a * a for a in x[:d])
    m = tuple(pos_sqrt(z) for z in h)
    weights = tuple(3**j for j in range(d))
    K = sum(weights)
    lam = 1 / (2 * R * (K + 1))
    intensities = []
    for i in range(d):
        c = [Q(0)] * (d + 1)
        c[i] = 1
        for j in range(d):
            if j != i and max(m[i], m[j]):
                c[j] = lam * m[i]**2 * weights[j] / max(m[i], m[j])
        c[d] = lam * m[i]**2 / (4 * R)
        intensities.append(sum(a * b for a, b in zip(c, x))**2)
    if not any(m):
        assert not any(h) and not any(intensities)
        return False
    i = min((j for j in range(d) if m[j]), key=m.__getitem__)
    value = (pos_sqrt(intensities[i]) - m[i]) / (lam * m[i]**2)
    integer = round(value)
    tail = (value - integer) * 4 * R
    digits = []
    for _ in range(d):
        digit = (integer + 1) % 3 - 1
        digits.append(digit)
        integer = (integer - digit) // 3
    assert integer == 0 and digits[i] == 0
    digits[i] = 1
    recovered = tuple(a * b for a, b in zip(m, digits)) + (tail,)
    sign = 1 if x[i] > 0 else -1
    assert recovered == tuple(sign * a for a in x)
    return True


def main():
    exact = axes = 0
    for n in range(2, 8):
        R = Q(n)
        for x in product(map(Q, [-1, 0, 1]), repeat=n):
            ok = replay(x, R)
            exact += ok
            axes += not ok
    rng = Random(997999)
    for n in range(2, 17):
        R = Q(n * 5)
        for _ in range(160):
            # In particular exercises very small isolated positive anchors.
            x = tuple(Q(rng.randint(-5, 5), 2**rng.randrange(100))
                      for _ in range(n))
            ok = replay(x, R)
            exact += ok
            axes += not ok
    print(f"PASS: {exact} exact off-axis recoveries, {axes} axis cases")


if __name__ == "__main__":
    main()

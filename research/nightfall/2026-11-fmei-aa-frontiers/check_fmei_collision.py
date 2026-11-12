#!/usr/bin/env python3
"""Exact finite regression for NIGHTFALL's FMEI collision-descent checkpoint.

Stdlib only. Every collision and influence is a Fraction until logarithms
are used to display (not certify) ratios. No global conjecture is tested.
"""
from fractions import Fraction
from itertools import combinations
from math import log2

N = 5
MASK = 0x0ABB0203
TRUTH = tuple(-1 if (MASK >> x) & 1 else 1 for x in range(1 << N))


def hadamard(xs):
    a = list(xs)
    step = 1
    while step < len(a):
        for base in range(0, len(a), 2 * step):
            for k in range(step):
                u, v = a[base + k], a[base + step + k]
                a[base + k] = u + v
                a[base + step + k] = u - v
        step *= 2
    return a


def collision(xs):
    n = len(xs)
    assert n > 0 and (n & (n - 1)) == 0
    return Fraction(sum(v ** 4 for v in hadamard(xs)), n ** 4)


def collision_by_parallelograms(xs):
    """Independent U2 enumeration: E_{x,a,b} product over four corners."""
    n = len(xs)
    return Fraction(sum(xs[x] * xs[x ^ a] * xs[x ^ b] * xs[x ^ a ^ b]
                        for x in range(n) for a in range(n) for b in range(n)), n ** 3)


def restrict(coordinates, bits):
    return tuple(TRUTH[x] for x in range(1 << N)
                 if all((x >> coordinate) & 1 == bit
                        for coordinate, bit in zip(coordinates, bits)))


def all_restriction_collisions(coordinates):
    return tuple(collision(restrict(coordinates, tuple((j >> k) & 1
                             for k in range(len(coordinates)))))
                 for j in range(1 << len(coordinates)))


def influence(i):
    return Fraction(sum(TRUTH[x] != TRUTH[x ^ (1 << i)]
                        for x in range(1 << N)), 1 << N)


def entropy_drop(cs, root):
    """Display only: root H2 minus expected conditional H2."""
    return -log2(float(root)) + sum(log2(float(c)) for c in cs) / len(cs)


def main():
    root = collision(TRUTH)
    assert root == Fraction(143, 2048)
    assert root == collision_by_parallelograms(TRUTH)
    infs = tuple(influence(i) for i in range(N))
    assert infs == (Fraction(5, 16),) * N

    for i in range(N):
        conditional = all_restriction_collisions((i,))
        assert set(conditional) == {Fraction(55, 256), Fraction(5, 32)}
        assert all(c == collision_by_parallelograms(restrict((i,), (bit,)))
                   for bit, c in enumerate(conditional))
        # D_i > 4*I_i iff (c_plus*c_minus/root^2)^2 > 2^(16*I_i).
        # Here 16*I_i=5, so squaring gives ratio^2 > 32.
        ratio = conditional[0] * conditional[1] / root**2
        assert ratio == Fraction(12800, 1859)
        assert ratio**2 > 32
        assert entropy_drop(conditional, root) > 4 * float(infs[i])

    high_ratio_pairs = {(0, 1), (0, 3), (1, 4), (2, 3), (2, 4)}
    pair_rows = []
    for coords in combinations(range(N), 2):
        conditional = all_restriction_collisions(coords)
        for j, c in enumerate(conditional):
            bits = tuple((j >> k) & 1 for k in range(2))
            assert c == collision_by_parallelograms(restrict(coords, bits))
        if coords in high_ratio_pairs:
            assert sorted(conditional) == sorted((Fraction(1),) + (Fraction(11, 32),) * 3)
        else:
            assert sorted(conditional) == sorted((Fraction(11, 32),) + (Fraction(1, 4),) * 3)
        drop = entropy_drop(conditional, root)
        cost = sum(infs[i] for i in coords)
        pair_rows.append((coords, drop / float(cost)))

    best_pair = min(pair_rows, key=lambda x: x[1])
    assert best_pair[0] == (0, 2)
    assert abs(best_pair[1] - 3.1279785086094956) < 1e-12
    print('PASS truth_table=0x0ABB0203 Walsh/U2-identity exact')
    print('PASS single-coordinate influence=5/16 collision=143/2048 each')
    print('PASS all five D_i>4*I_i with exact ratio=12800/1859 and ratio^2>32')
    print('PAIR_RATIOS', ', '.join(f'{ij}:{r:.12f}' for ij, r in pair_rows))
    print('PASS best two-coordinate raw-cost ratio=%.12f' % best_pair[1])
    print('LIMIT: finite counterexample to a local proof lemma, NOT FMEI')


if __name__ == '__main__':
    main()

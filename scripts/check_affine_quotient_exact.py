#!/usr/bin/env python3
"""Exact affine-source quantum phase-oracle quotient regression.

This proves finite *instances* only; the general conjugation identity is algebraic.
The rank-free T2 simulation theorem is not tested or implied.
"""
from itertools import product
from sympy import Matrix, eye, Rational, simplify


def sign(a, s):
    return -1 if ((a & s).bit_count() % 2) else 1


def diagonal(values):
    return Matrix.diag(*values)


def test_affine_quotient():
    # V=F_2^3, H=span(e0,e1), coset s0+H; the label set is
    # 2 distinct pairs with equal characters on H.
    labels = [0, 1, 5, 2, 6]
    s0 = 4
    H = [0, 1, 2, 3]
    quotient = [a & 3 for a in labels]
    assert len(set(labels)) == 5 and sorted(set(quotient)) == [0, 1, 2]
    S0 = diagonal([sign(a, s0) for a in labels])
    assert S0 * S0 == eye(5)
    assert S0 != eye(5)

    # A rational unitary, rational normalized input, and a genuinely
    # noncommuting rank-one projective terminal effect.
    v = Matrix([1, 1, 1, 1, 1])
    U = eye(5) - Rational(2, 5) * (v * v.T)
    psi = Matrix([Rational(3, 5), Rational(4, 5), 0, 0, 0])
    u = Matrix([Rational(4, 5), 0, Rational(3, 5), 0, 0])
    E = u * u.T
    assert U.T * U == eye(5)
    assert (psi.T * psi)[0] == 1 and (u.T * u)[0] == 1
    assert S0 * E != E * S0
    Uprime = U * S0
    Eprime = S0 * E * S0

    changed_states = 0
    changed_wrong_effect = 0
    for h in H:
        s = s0 ^ h
        O = diagonal([sign(a, s) for a in labels])
        Q = diagonal([sign(c, h) for c in quotient])
        assert O == S0 * Q == Q * S0
        direct = O * U * O * psi
        reduced = Q * Uprime * Q * psi
        assert direct == S0 * reduced
        if direct != reduced:
            changed_states += 1
        p_direct = (direct.T * E * direct)[0]
        p_reduced = (reduced.T * Eprime * reduced)[0]
        assert simplify(p_direct - p_reduced) == 0
        assert 0 <= p_direct <= 1
        if simplify(p_direct - (reduced.T * E * reduced)[0]) != 0:
            changed_wrong_effect += 1
        for a in labels:
            assert sign(a, s) * sign(a, s0) == sign(a & 3, h)
    assert changed_states > 0 and changed_wrong_effect > 0
    print('PASS affine quotient 4/4 secrets; exact rational quantum states, effects and query signs')
    print('PASS negative control: dropping fixed final conjugation changes a noncommuting measurement')


def test_duplicate_wyner_floor():
    # r independent random bits; each appears twice in the actual raw oracle table.
    # Exactly 2^r equally weighted distinct tables: H(raw table)=r*ln(2).
    # As a formal statement, conditional-product representations must fix
    # each perfectly duplicated pair (proved in research note).
    for r in range(1, 6):
        words = set()
        for bits in product((0, 1), repeat=r):
            words.add(tuple(q for b in bits for q in (b, b)))
        assert len(words) == (1 << r)
        # Effective quotient labels form the r independent coordinate characters.
        eff = [1 << i for i in range(r)]
        assert len(eff) == len(set(eff))
        if r >= 3:
            from math import factorial
            assert factorial(4) == 24
    print('PASS duplicate bits: support of raw law is exactly 2^r for each r=1,...,5')
    print('NOTE Wyner equality r*ln(2) depends on the separate analytic proof, not this count')




def test_maximal_support_quotient():
    # Nonempty supports, including nonuniform/nonaffine cases.
    supports = [
        {4}, {4, 5, 6, 7}, {0, 1, 2}, set(range(16)), {0, 5, 10},
    ]
    D = list(range(16))
    for support in supports:
        s0 = min(support)
        for a in D:
            for b in D:
                is_constant_ratio = len({sign(a, s) * sign(b, s) for s in support}) == 1
                annihilates_differences = all(sign(a ^ b, s ^ s0) == 1 for s in support)
                assert is_constant_ratio == annihilates_differences
                if is_constant_ratio:
                    assert all(sign(a, s) == sign(a ^ b, s0) * sign(b, s) for s in support)
    # Negative control: uniform distribution on a NONaffine support does
    # not admit the uniform-group Walsh orthogonality step in T2.
    assert sum(sign(1, s) for s in (0, 1, 2)) == 1
    print('PASS maximal support quotient: all 16^2 label pairs across five support types')
    print('PASS negative control: nonaffine uniform source has nonorthogonal Walsh characters')

if __name__ == '__main__':
    test_affine_quotient()
    test_duplicate_wyner_floor()
    test_maximal_support_quotient()

#!/usr/bin/env python3
"""Exact commuting-diagonal sanity tests for the NIGHTFALL quantum ANOVA bridge.

No external packages. These finite examples falsify incorrect formulas but do not
prove the general quantum ANOVA, converse, or scalar influence theorems.
"""
from fractions import Fraction as F
from itertools import product

SIGNS = (1, -1)


def gain(diagonal_b, diagonal_a, q):
    """Exact Personick/SLD gain for diagonal states on binary registers."""
    marg_b, marg_a = {}, {}
    for z in diagonal_b:
        key = tuple(z[i] for i in q)
        marg_b[key] = marg_b.get(key, F(0)) + diagonal_b[z]
        marg_a[key] = marg_a.get(key, F(0)) + diagonal_a[z]
    return sum((marg_a[k] ** 2 / b for k, b in marg_b.items() if b), F(0))


def local_product_example():
    # X1,X2 independent fair signs, f=X1*X2. Local qubit preparations:
    # rho_{i,x}(z)=(1+c_i*x*z)/2, c_1=1, c_2=1/3, in Z eigenbasis.
    c = (F(1), F(1, 3))
    b = {z: F(0) for z in product(SIGNS, repeat=2)}
    a = dict(b)
    for x in product(SIGNS, repeat=2):
        p = F(1, 4)
        f = x[0] * x[1]
        for z in b:
            weight = p
            for i in range(2):
                weight *= (1 + c[i] * x[i] * z[i]) / 2
            b[z] += weight
            a[z] += f * weight
    assert sum(b.values()) == 1 and sum(a.values()) == 0
    assert set(b.values()) == {F(1, 4)}  # product, faithful average
    g1, g2, g12 = gain(b, a, (0,)), gain(b, a, (1,)), gain(b, a, (0, 1))
    assert (g1, g2, g12) == (F(0), F(0), F(1, 9))
    # Here each centered classical local space is one-dimensional,
    # and its geometric Gram eigenvalue is exactly c_i**2.
    alpha = tuple(t * t for t in c)
    delta = min(alpha[0], alpha[1], alpha[0] * alpha[1])
    assert delta == F(1, 9)
    # Variance=1; resampling influences I_1=I_2=1.
    assert g12 - g2 == delta and g12 - g1 == delta
    return g12, delta


def correlated_average_obstruction():
    # Full-rank, pairwise-independent three-bit mean with a 3-way correlator.
    theta, t = F(1, 2), F(1, 2)
    b = {z: (1 + theta * z[0] * z[1] * z[2]) / 8
         for z in product(SIGNS, repeat=3)}
    # Equiprobable binary CQ ensemble rho_+/- = B*(I +/- t*Z1).
    a = {z: t * z[0] * bz for z, bz in b.items()}
    rho_plus = {z: bz + a[z] for z, bz in b.items()}
    rho_minus = {z: bz - a[z] for z, bz in b.items()}
    assert min(rho_plus.values()) > 0 and min(rho_minus.values()) > 0
    assert sum(rho_plus.values()) == sum(rho_minus.values()) == 1
    g1, g23, gall = gain(b, a, (0,)), gain(b, a, (1, 2)), gain(b, a, (0, 1, 2))
    assert (g1, g23, gall) == (F(1, 4), F(1, 16), F(1, 4))
    assert g1 + g23 - gall == F(1, 16)
    return g1 + g23 - gall


if __name__ == '__main__':
    g, delta = local_product_example()
    obstruction = correlated_average_obstruction()
    print(f'PASS quantum_product_parity_gain={g} local_visibility_floor={delta}')
    print(f'PASS correlated_average_supermodularity_violation={obstruction}')
    print('SCOPE: exact diagonal examples only; no general theorem or novelty certification')

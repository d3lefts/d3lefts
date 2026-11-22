#!/usr/bin/env python3
"""Exact Gaussian-rational adversarial identities for a binary-label T=2 circuit.

Finite exact identity check, NOT a general Hilbert theorem, Lean proof or novelty review.
"""
from collections import Counter
from itertools import combinations, product
from sympy import Matrix, I, Rational, conjugate, eye, simplify

D = (0, 1, 2, 3, 4)
R = D[1:]
index = {a: j for j, a in enumerate(D)}
n = len(D)
ones = Matrix([1] * n)
U = Matrix.diag(1, I, -1, -I, 1) * (eye(n) - Rational(2, n) * ones * ones.T)
psi = Matrix([Rational(3, 5), Rational(4, 5) * I, 0, 0, 0])
u = Matrix([Rational(4, 5), 0, Rational(3, 5) * I, 0, 0])
P = (eye(n) + u * u.conjugate().T) / 2
assert U.conjugate().T * U == eye(n)
assert (psi.conjugate().T * psi)[0] == (u.conjugate().T * u)[0] == 1
assert P.conjugate().T == P and P * P != P
m = {(a, b): U[index[b], index[a]] * psi[index[a]]
     for a, b in product(D, repeat=2)}


def c(a, b, ap, bp):
    return conjugate(m[(ap, bp)]) * P[index[bp], index[b]] * m[(a, b)]


def same(x, y, name):
    assert simplify(x - y) == 0, (name, simplify(x-y))


def cross_group(b, ap):
    """The grouped mixed-frame coefficient when a=b' (no c() calls)."""
    F = Matrix([P[index[a], index[b]] * m[(a, b)] for a in D])
    Upsi = U[:, index[ap]] * psi[index[ap]]
    return (Upsi.conjugate().T * F)[0]


def check_six_repeated_equalities():
    Pdiag = Matrix.diag(*(P[i, i] for i in range(n)))
    V = Matrix([m[(a, a)] for a in D])
    for b, bp in product(D, repeat=2):
        same(sum((c(a, b, a, bp) for a in D), 0),
             sum((conjugate(m[(a, bp)]) * P[index[bp], index[b]] * m[(a,b)] for a in D), 0),
             ('a=ap', b, bp))
    for a, ap in product(D, repeat=2):
        direct = sum((c(a, b, ap, b) for b in D), 0)
        rhs = conjugate(psi[index[ap]]) * psi[index[a]] * (
            U[:,index[ap]].conjugate().T * Pdiag * U[:,index[a]])[0]
        same(direct, rhs, ('b=bp', a, ap))
    for ap, bp in product(D, repeat=2):
        direct = sum((c(a, a, ap, bp) for a in D), 0)
        same(direct, conjugate(m[(ap,bp)]) * (P*V)[index[bp]], ('a=b',ap,bp))
    for a, b in product(D, repeat=2):
        direct = sum((c(a, b, ap, ap) for ap in D), 0)
        same(direct, m[(a,b)] * (V.conjugate().T * P)[index[b]], ('ap=bp', a,b))
    for b, ap in product(D, repeat=2):
        same(sum((c(a,b,ap,a) for a in D),0), cross_group(b,ap), ('a=bp',b,ap))
    for a, bp in product(D, repeat=2):
        same(sum((c(a,b,b,bp) for b in D),0), conjugate(cross_group(bp,a)), ('b=ap',a,bp))
    print('PASS six complex first-order repeated-label identities; P nonprojective')


def check_zero_triples():
    hats = {}
    for e in R:
        hats[e] = Matrix([
            sum((m[(a,b)] for a in R if (a ^ b) == e), 0) if b in R else 0
            for b in D
        ])
    assert any(a ^ b in R for a,b in product(R, repeat=2))
    Z=Matrix([(P*hats[e])[index[e]] if e in R else 0 for e in D])
    for d in R:
        lhs = sum((c(a,b,d,bp) for a,b,bp in product(R,repeat=3) if a^b^bp==0),0)
        rhs = conjugate(psi[index[d]]) * (U[:,index[d]].conjugate().T * Z)[0]
        same(lhs,rhs,('a-prime survivor',d))
        lhs = sum((c(a,b,ap,d) for a,b,ap in product(R,repeat=3) if a^b^ap==0),0)
        rhs = sum((conjugate(U[index[d],index[e]] * psi[index[e]]) * (P*hats[e])[index[d]]
                   for e in R),0)
        same(lhs,rhs,('b-prime survivor',d))
    print('PASS both zero-triple survivor identities and conjugate locations')


def check_fourier_and_partition():
    counts=Counter()
    grouped=Counter()
    for a,b,ap,bp in product(D,repeat=4):
        z=a^b^ap^bp
        if not z: continue
        labels=(a,b,ap,bp)
        if len(set(labels))<4:
            kind='repeated'
        elif 0 in labels:
            kind='primitive'
        elif any(a0^a1^a2==0 for a0,a1,a2 in combinations(labels,3)):
            kind='zero_triple'
        else:
            kind='primitive'
        counts[kind]+=1
        grouped[z] += c(a,b,ap,bp)
    assert counts['repeated'] and counts['primitive'] and counts['zero_triple']
    assert sum(counts.values()) == sum(1 for t in product(D,repeat=4) if t[0]^t[1]^t[2]^t[3])
    for s in range(8):
        signs=Matrix.diag(*[(-1 if (a&s).bit_count()%2 else 1) for a in D])
        state=signs*U*signs*psi
        direct=(state.conjugate().T*P*state)[0]
        fourier=sum(((-1 if (z&s).bit_count()%2 else 1)*grouped[z] for z in grouped),0)
        zero=sum((c(a,b,ap,bp) for a,b,ap,bp in product(D,repeat=4) if a^b^ap^bp==0),0)
        same(direct,zero+fourier,('Fourier acceptance',s))
        assert 0<=simplify(direct)<=1
    print('PASS nonzero-XOR disjoint partition:',dict(counts))
    print('PASS full acceptance Fourier expansion for all 8 uniform secrets')


if __name__=='__main__':
    check_six_repeated_equalities()
    check_zero_triples()
    check_fourier_and_partition()

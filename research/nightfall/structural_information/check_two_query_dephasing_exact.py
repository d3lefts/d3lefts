#!/usr/bin/env python3
"""Exact rational check for a genuine two-query diagonal decomposition.
Independent calculations: direct one-query dephasing vs quadruple path sum.
No quantum-circuit universality, simulation theorem, or novelty certification.
"""
from fractions import Fraction as F
from itertools import product

N = 4
Z, ONE = F(0), F(1)
D = (0, 1, 2, 3)

def eye():
    return [[ONE if i == j else Z for j in range(N)] for i in range(N)]

def rotate(i, j, c, s):
    a = eye()
    a[i][i] = c
    a[j][j] = c
    a[i][j] = -s
    a[j][i] = s
    return a

def mv(a, v):
    return [sum((x*y for x, y in zip(row, v)), Z) for row in a]

def mm(a, b):
    return [[sum((a[i][k]*b[k][j] for k in range(N)), Z)
             for j in range(N)] for i in range(N)]

def dot(a, b):
    return sum((x*y for x, y in zip(a, b)), Z)

U = mm(
    rotate(0, 1, F(3, 5), F(4, 5)),
    mm(rotate(1, 3, F(5, 13), F(12, 13)),
       rotate(0, 2, F(3, 5), F(4, 5))))
PSI = [F(3, 5), F(4, 5), Z, Z]
W = [F(3, 5), Z, F(4, 5), Z]
assert dot(PSI, PSI) == ONE and dot(W, W) == ONE
assert mm(U, [[U[j][i] for j in range(N)] for i in range(N)]) == eye()

def chi(r, s):
    return -ONE if (r&s).bit_count() % 2 else ONE

def oracle(v, s):
    return [x*chi(D[i], s) for i, x in enumerate(v)]

def accept(v):
    return dot(W, v)**2

def components(s):
    first = oracle(PSI, s)
    full = oracle(mv(U, first), s)
    f = accept(full)
    firstdiag = Z
    for a in range(N):
        e = [Z]*N
        e[a] = PSI[a]
        firstdiag += accept(oracle(mv(U, e), s))
    second = mv(U, first)
    seconddiag = Z
    for b in range(N):
        e = [Z]*N
        e[b] = second[b]
        seconddiag += accept(e)
    bothdiag = Z
    for a in range(N):
        e = [Z]*N
        e[a] = PSI[a]
        va = mv(U, e)
        for b in range(N):
            t = [Z]*N
            t[b] = va[b]
            bothdiag += accept(t)
    same = firstdiag + seconddiag - bothdiag
    return f, firstdiag, seconddiag, bothdiag, same, f-same

def independently_expanded(s):
    vectors = {}
    for a in range(N):
        e = [Z]*N
        e[a] = PSI[a]
        t = mv(U, e)
        for b in range(N):
            z = [Z]*N
            z[b] = t[b]
            vectors[a, b] = z
    f = first = second = both = Z
    for (a, b), (ap, bp) in product(vectors, vectors):
        term = (chi(D[a]^D[b]^D[ap]^D[bp], s)
                * dot(W, vectors[a, b]) * dot(W, vectors[ap, bp]))
        f += term
        if a == ap: first += term
        if b == bp: second += term
        if a == ap and b == bp: both += term
    return f, first, second, both

def main():
    values = {s: components(s) for s in range(4)}
    assert all(independently_expanded(s) == values[s][:4]
               for s in range(4))
    assert all(0 <= values[s][i] <= 1 for s in range(4) for i in range(4))
    assert any(values[s][5] != 0 for s in range(4))
    print("PASS: exact rational direct-circuit/path decomposition, 4/4 secrets")
    print("Exact coherent remainders:", [str(values[s][5]) for s in range(4)])
    print("No universal T2 theorem is certified by this finite test.")

if __name__ == "__main__":
    main()

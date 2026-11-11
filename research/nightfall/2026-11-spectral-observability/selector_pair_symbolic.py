#!/usr/bin/env python3
"""Independent all-p polynomial check of the four-bit degree-3 pair obstruction.

No SymPy or numerical sampling. Polynomials are exact integer coefficient tuples.
The result proves a polynomial identity, not a universal influence inequality.
"""
from itertools import product


def add(a, b):
    n = max(len(a), len(b))
    return tuple((a[i] if i < len(a) else 0) + (b[i] if i < len(b) else 0) for i in range(n))


def neg(a):
    return tuple(-x for x in a)


def sub(a, b):
    return add(a, neg(b))


def mul(a, b):
    out = [0] * (len(a) + len(b) - 1)
    for i, u in enumerate(a):
        for j, v in enumerate(b):
            out[i + j] += u * v
    return tuple(out)


def powpoly(a, n):
    out = (1,)
    for _ in range(n):
        out = mul(out, a)
    return out


def eqpoly(a, b):
    def trim(q):
        q = list(q)
        while len(q) > 1 and q[-1] == 0:
            q.pop()
        return q
    return trim(a) == trim(b)


p = (0, 1)
q = (1, -1)


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
        result = add(result, weight if f(x) == 1 else neg(weight))
    return result


def mixed(i, j):
    return add(sub(conditional_pair(i,j,1,1), conditional_pair(i,j,1,0)),
               sub(conditional_pair(i,j,0,0), conditional_pair(i,j,0,1)))


for i, j in ((0, 1), (2, 3)):
    delta = mixed(i, j)
    assert eqpoly(delta, (4, -4)), (i, j, delta)
    anchored = mul(delta, powpoly(q, 2))
    assert eqpoly(anchored, (4, -12, 12, -4)), (i, j, anchored)
    print(f'pair {i+1}{j+1}: mixed difference = 4(1-p); '
          'ANOVA value at (1,1) = 4(1-p)^3')

# The unique total-degree-four multilinear coefficient vanishes.
coefficient = 0
for x in product((0, 1), repeat=4):
    coefficient += (-1) ** (4 - sum(x)) * f(x)
assert coefficient == 0
assert {f(x) for x in product((0, 1), repeat=4)} == {-1, 1}
print('PASS: for every 0<p<1, degree <=3 and pair mass = 8(1-p)^3; limit = 8')

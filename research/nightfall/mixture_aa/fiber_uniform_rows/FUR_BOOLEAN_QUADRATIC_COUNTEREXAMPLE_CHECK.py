#!/usr/bin/env python3
"""Exact certificate: plain/fiber row costs differ for a bounded degree-2 function.
No third-party dependencies. All checks use integer arithmetic.
"""
from itertools import product

P = list(product((0, 1), repeat=4))
IDX = {x: j for j, x in enumerate(P)}

def q(x):
    a, b, c, d = x
    return -c + d - 2*a*b + 2*a*c - a*d + b*d + c*d

Q = {x: q(x) for x in P}
assert min(Q.values()) == -2 and max(Q.values()) == 2
# f = (q + 2)/4, so 0 <= f <= 1, degree <= 2.

# In lexicographic x order, PLAIN4[x][i] = 4 * ordinary_weight_i(x).
PLAIN4 = [
    (0,2,1,1), (1,1,1,1), (2,1,1,2), (1,1,0,2),
    (2,0,1,2), (3,1,1,2), (2,0,1,3), (3,1,0,3),
    (0,2,1,1), (1,2,2,0), (2,2,1,1), (1,1,2,2),
    (2,2,1,2), (3,1,2,1), (1,2,1,2), (1,1,2,2),
]
assert max(map(sum, PLAIN4)) == 7
for x in P:
    for y in P:
        assert sum(PLAIN4[IDX[x]][i] for i in range(4) if x[i] != y[i]) >= abs(Q[x]-Q[y])

# Fiber weights: FIBER8[i][z] = 8 * alpha_i(z), z a 3-bit tuple
# indexed lexicographically (000,001,...,111).
FIBER8 = [
    (4,2,4,2,5,6,2,4),
    (0,2,2,2,4,2,4,2),
    (2,0,2,2,2,4,3,4),
    (4,4,4,6,2,4,3,4),
]
def fw8(i, x):
    z = x[:i] + x[i+1:]
    return FIBER8[i][4*z[0] + 2*z[1] + z[2]]
assert max(sum(fw8(i, x) for i in range(4)) for x in P) == 15
for x in P:
    for y in P:
        assert sum(fw8(i, x) for i in range(4) if x[i] != y[i]) >= 2*abs(Q[x]-Q[y])

# Ordinary lower bound, from four one-coordinate comparisons at 1101.
x = (1,1,0,1)
assert sum(abs(Q[x]-Q[x[:i]+(1-x[i],)+x[i+1:]]) for i in range(4)) == 7

# Fiber dual: kappa=1/2 at each anchor; lambda=1/2 on each directed pair.
# Multiply both lambda and kappa by 2: all weights become 1.
anchors = [(1,1,0,0), (1,1,0,1)]
pairs = [
    ((0,1,0,1), (1,1,0,1)),
    ((1,0,0,0), (1,1,0,0)),
    ((1,0,0,1), (1,1,0,1)),
    ((1,1,0,0), (0,1,0,1)),
    ((1,1,0,0), (1,1,1,1)),
    ((1,1,0,1), (1,1,1,1)),
]
assert len(anchors) == 2
for i in range(4):
    for z in product((0, 1), repeat=3):
        load = sum(1 for x,y in pairs if x[i] != y[i] and x[:i]+x[i+1:] == z)
        budget = sum(1 for x in anchors if x[:i]+x[i+1:] == z)
        assert load <= budget
assert sum(abs(Q[x]-Q[y]) for x,y in pairs) == 15
# Dual value = 15/8; plain primal = 7/4; fiber primal = 15/8.
print("EXACT PASS: C_plain = 7/4, C_fiber = 15/8, degree = 2.")

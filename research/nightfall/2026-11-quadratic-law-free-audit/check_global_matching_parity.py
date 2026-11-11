#!/usr/bin/env python3
"""Exact independent finite-model audit for the Lean global quadratic parity theorem.
Uses integer arithmetic and exhaustive corners. Falsification, not a universal proof.
"""
from itertools import product
from random import Random
rng = Random(20261111)
count = 0
for n in range(1, 4):
    for a in (2, 3):
        blocks = list(range(n))
        sides = (0, 1)
        coords = list(product(blocks, sides))
        edges = [(x,y) for x in coords for y in coords if x < y and x[0] != y[0]]
        for iteration in range(45):
            const = rng.randrange(-4,5)
            L = {(i,t): rng.randrange(-5,6) for i in blocks for t in range(a)}
            R = {(i,t): rng.randrange(-5,6) for i in blocks for t in range(a)}
            M = {(i,t,u): rng.randrange(-5,6)
                 for i in blocks for t in range(a) for u in range(a)}
            K = {(edge,t,u): rng.randrange(-5,6)
                 for edge in edges for t in range(a) for u in range(a)}
            rect = {(i,side,bit): rng.randrange(a)
                    for i in blocks for side in sides for bit in sides}
            def f(x):
                result = const + sum(
                    L[(i,x[(i,0)])] + R[(i,x[(i,1)])]
                    + M[(i,x[(i,0)],x[(i,1)])] for i in blocks)
                result += sum(K[(edge,x[edge[0]],x[edge[1]])] for edge in edges)
                return result
            B = max(abs(f(dict(zip(coords,x))))
                    for x in product(range(a),repeat=2*n))
            delta = 0
            for sig in product(sides,repeat=n):
                even = {(i,0): rect[(i,0,sig[i])] for i in blocks}
                even.update({(i,1):rect[(i,1,sig[i])] for i in blocks})
                odd = {(i,0): rect[(i,0,sig[i])] for i in blocks}
                odd.update({(i,1):rect[(i,1,1-sig[i])] for i in blocks})
                delta += f(even)-f(odd)
            rectangle_sum = sum(
                M[(i,rect[(i,0,0)],rect[(i,1,0)])]
                - M[(i,rect[(i,0,0)],rect[(i,1,1)])]
                - M[(i,rect[(i,0,1)],rect[(i,1,0)])]
                + M[(i,rect[(i,0,1)],rect[(i,1,1)])] for i in blocks)
            assert 2*delta == (2**n)*rectangle_sum, (n,a,iteration)
            assert rectangle_sum <= 4*B, (n,a,iteration)
            count += 1
print(f"PASS {count} exact exhaustive-input quadratic matching parity models")

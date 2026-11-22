#!/usr/bin/env python3
"""Four-position repeated-label Möbius reduction, exact source checker.

Universal identity is proved by the five equality partitions of 4 slots.
The enumeration here is an independent finite regression and falsifier.
It does NOT certify the quantum Hilbert-energy lemma or a Lean theorem.
"""
from collections import Counter
from itertools import combinations, product
from math import sqrt

POSITIONS = range(4)
PAIRS = tuple(combinations(POSITIONS, 2))
TRIPLES = tuple(combinations(POSITIONS, 3))

def events(t):
    pair_count = sum(t[i] == t[j] for i, j in PAIRS)
    triple_count = sum(t[i] == t[j] == t[k] for i, j, k in TRIPLES)
    return pair_count, triple_count

def check(D):
    observed = Counter()
    total = 0
    excluded = 0
    for t in product(D, repeat=4):
        z = t[0] ^ t[1] ^ t[2] ^ t[3]
        p, q = events(t)
        formal_coefficient = p - 2*q
        expected = int(len(set(t)) < 4)
        if z == 0:
            excluded += 1
            continue
        assert formal_coefficient == expected, (D, t, p, q, expected)
        partition = tuple(sorted(Counter(t).values(), reverse=True))
        observed[(partition, p, q, formal_coefficient)] += 1
        total += 1
    assert all(k[0] in {(1,1,1,1), (2,1,1), (3,1)} for k in observed)
    assert {(k[0],k[1],k[2],k[3]) for k in observed} == {
        ((1,1,1,1),0,0,0),
        ((2,1,1),1,0,1),
        ((3,1),3,1,1)
    }
    print(f'PASS D={tuple(D)}: {total} nonzero-XOR coefficients, {excluded} zero-XOR excluded')
    return total

if __name__ == '__main__':
    total=0
    for D in ((0,1,2), (0,1,2,3), tuple(range(8))):
        total += check(D)
    # Distinct ordered pair group L2 energy sqrt(2 M eta) times 6.
    # Four triple event corrections, each coefficient -2, each <=2 sqrt(M eta).
    B = 6*sqrt(2) + 4*2*2
    # Four unique-zero-triple cases, each <= (1+2 sqrt(3))*sqrt(M eta).
    C = 4*(1+2*sqrt(3))
    coeff = B+C
    assert coeff < 43
    assert coeff > 42
    print(f'PASS B coefficient {B:.12f}, C {C:.12f}, total {coeff:.12f} < 43')
    print(f'PASS old 145 vs new 43, pure M-dominated squared-factor {(145/43)**2:.12f}')
    print(f'PASS {total} independent formal coefficient regression cases')
    print('Scope: polynomial XOR identity, not an all-dimensional quantum/Lean certificate.')

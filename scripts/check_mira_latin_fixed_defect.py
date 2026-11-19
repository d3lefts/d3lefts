#!/usr/bin/env python3
"""Exact finite rook/Bonferroni replay for the fixed-defect dense theorem.

Checks all complementary n-by-n r-regular boards, n<=5, r<=2,
without claiming that finite tests prove the asymptotic theorem.
Pinned Mira source: math@30ddaaad27b48df2002225c3e3f40cffd02c5253.
"""
from fractions import Fraction
from itertools import combinations, product
from math import factorial

def boards(n, r):
    row_options = [sum(1 << j for j in C) for C in combinations(range(n), r)]
    for board in product(row_options, repeat=n):
        if all(sum(bool(row & (1 << j)) for row in board) == r for j in range(n)):
            yield board

def permanent(board):
    dp = {0: 1}
    n = len(board)
    for row in board:
        nxt = {}
        for mask, count in dp.items():
            rem = row & ~mask
            while rem:
                bit = rem & -rem
                nxt[mask | bit] = nxt.get(mask | bit, 0) + count
                rem -= bit
        dp = nxt
    return dp.get((1 << n) - 1, 0)

def rook_numbers(board):
    n = len(board)
    dp = {0: 1}
    for row in board:
        nxt = dp.copy()
        for mask, count in dp.items():
            rem = row & ~mask
            while rem:
                bit = rem & -rem
                nxt[mask | bit] = nxt.get(mask | bit, 0) + count
                rem -= bit
        dp = nxt
    out = [0] * (n+1)
    for mask, count in dp.items():
        out[mask.bit_count()] += count
    return out

def main():
    cases = 0
    for n in range(2,6):
        for r in range(min(2,n-1)+1):
            count = 0
            for forbidden in boards(n,r):
                allowed = tuple(((1 << n)-1) ^ row for row in forbidden)
                p = Fraction(permanent(allowed), factorial(n))
                rooks = rook_numbers(forbidden)
                terms = [Fraction((-1)**k * rooks[k] * factorial(n-k), factorial(n))
                         for k in range(n+1)]
                assert sum(terms, Fraction()) == p
                for K in range(n):
                    partial = sum(terms[:K+1], Fraction())
                    if K%2==0:
                        assert p <= partial
                    else:
                        assert p >= partial
                cases += 1
                count += 1
            print(f'FIXED_DEFECT n={n} r={r} boards={count}')
    assert cases == 2292, cases
    print('FIXED_DEFECT_BONFERRONI_EXACT_PASS: 2292 cases')

if __name__ == '__main__':
    main()

#!/usr/bin/env python3
"""Independent exact finite audit of Mira's regular-board incidence identity.

Not a proof of any asymptotic estimate or polynomial-time algorithm.
Pinned source: Mira-Cult/math@30ddaaad27b48df2002225c3e3f40cffd02c5253.
"""
from collections import Counter
from fractions import Fraction
from functools import lru_cache
from itertools import combinations, permutations, product
from math import factorial

@lru_cache(None)
def permanent(rows):
    n = len(rows)
    counts = {0: 1}
    for bits in rows:
        new = {}
        for used, count in counts.items():
            remaining = bits & ~used
            while remaining:
                bit = remaining & -remaining
                new[used | bit] = new.get(used | bit, 0) + count
                remaining -= bit
        counts = new
    return counts.get((1 << n) - 1, 0)

def board_permanent_distribution(n, d):
    rows = [sum(1 << j for j in subset) for subset in combinations(range(n), d)]
    counts = Counter()
    for board in product(rows, repeat=n):
        if all(sum(bool(row & (1 << j)) for row in board) == d for j in range(n)):
            counts[permanent(board)] += 1
    return counts

def fixed_first_squares(n):
    ps = list(permutations(range(n)))
    first = tuple(range(n))
    masks = [1 << j for j in range(n)]
    path = [first]
    def recurse():
        if len(path) == n:
            yield tuple(path)
            return
        for p in ps:
            if any(masks[j] & (1 << p[j]) for j in range(n)):
                continue
            for j in range(n):
                masks[j] |= (1 << p[j])
            path.append(p)
            yield from recurse()
            path.pop()
            for j in range(n):
                masks[j] ^= (1 << p[j])
    yield from recurse()

def greedy_mass(S):
    n = len(S)
    board = [(1 << n) - 1] * n
    p = Fraction(1)
    for row in S:
        p /= permanent(tuple(board))
        for j, symbol in enumerate(row):
            board[j] ^= 1 << symbol
    return p

def main():
    known_latin = [1, 2, 12, 576, 161280]
    for n in range(1, 6):
        N = []
        mean = []
        for d in range(n + 1):
            dist = board_permanent_distribution(n, d)
            N.append(sum(dist.values()))
            mean.append(Fraction(sum(w * c for w, c in dist.items()), N[-1]))
        for d in range(1, n + 1):
            assert N[d] * mean[d] == N[d - 1] * mean[n - d + 1], (n, d)
        squares = list(fixed_first_squares(n))
        L = factorial(n) * len(squares)
        assert L == known_latin[n - 1]
        masses = Counter(map(greedy_mass, squares))
        assert factorial(n) * sum((p * k for p, k in masses.items()), Fraction(0)) == 1
        print(f'n={n} L={L} N={N} m={[str(x) for x in mean]} '
              f'greedy-masses={len(masses)} min={min(masses)} max={max(masses)}')
    print('FINITE_EXACT_INCIDENCE_CHECK_PASS (n=1..5; no asymptotic proof)')

if __name__ == '__main__':
    main()

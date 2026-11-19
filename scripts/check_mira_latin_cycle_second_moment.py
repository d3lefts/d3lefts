#!/usr/bin/env python3
"""Independent exact orbit/second-moment Latin audit, n<=5.

Mira Cult source: math@30ddaaad27b48df2002225c3e3f40cffd02c5253
This validates finite identities only, not the asymptotic chi-square
budget or Mira's n^25 exact sampling complexity.
"""
from collections import Counter, defaultdict
from fractions import Fraction
from functools import lru_cache
from itertools import combinations, permutations, product
from math import factorial

@lru_cache(None)
def permanent(board):
    n = len(board)
    dp = {0: 1}
    for row in board:
        nxt = {}
        for used, count in dp.items():
            rem = row & ~used
            while rem:
                bit = rem & -rem
                nxt[used | bit] = nxt.get(used | bit, 0) + count
                rem -= bit
        dp = nxt
    return dp.get((1 << n) - 1, 0)

def cycle_type(p):
    seen, parts = set(), []
    for i in range(len(p)):
        if i in seen:
            continue
        j, size = i, 0
        while j not in seen:
            seen.add(j)
            size += 1
            j = p[j]
        parts.append(size)
    return tuple(sorted(parts))

def boards(n, d):
    row_options = [sum(1 << j for j in comb) for comb in combinations(range(n), d)]
    for board in product(row_options, repeat=n):
        if all(sum(bool(row & (1 << j)) for row in board) == d for j in range(n)):
            yield board

def check(n, d):
    these = list(boards(n, d))
    N = len(these)
    counts = Counter(permanent(board) for board in these)
    mean = Fraction(sum(w * k for w, k in counts.items()), N)
    E2 = Fraction(sum(w*w*k for w, k in counts.items()), N)
    chi = E2/mean**2 - 1
    tv = sum((Fraction(k,N) * abs(Fraction(w,1)/mean-1) for w,k in counts.items()), Fraction())
    tv /= 2
    assert 4*tv*tv <= chi
    perms_by_type = defaultdict(list)
    for p in permutations(range(n)):
        perms_by_type[cycle_type(p)].append(p)
    cycle_sum = 0
    orbit = {}
    for typ, group in perms_by_type.items():
        completions = []
        for p in group:
            required = tuple((1 << i) | (1 << p[i]) for i in range(n))
            completions.append(sum(
                all((row & req) == req for row, req in zip(board, required))
                for board in these))
        assert len(set(completions)) == 1, (n, d, typ)
        cycle_sum += len(group) * completions[0]
        orbit[typ] = completions[0]
    assert Fraction(factorial(n) * cycle_sum, N) == E2
    return N, str(tv), str(chi), orbit

def main():
    for n in range(1,6):
        for d in range(1,n+1):
            N,tv,chi,orbit = check(n,d)
            print(f'CYCLE_MOMENT n={n} d={d} N={N} TV={tv} CHI2={chi}')
            if (n,d)==(4,3):
                assert orbit[(2,2)] == 4 and orbit[(4,)] == 2, orbit
    print('CYCLE_TYPE_MOMENT_EXACT_PASS: n<=5, witness n=4 d=3 (2,2):4 (4,):2')

if __name__ == '__main__':
    main()

#!/usr/bin/env python3
"""Exact q=5 Singer affine-orbit three-block capacity (stdlib only).

Enumerates all affine Singer cuts in Z/31Z and every retained subblock,
then proves no three source subblocks of total size >=14 can have pairwise
disjoint positive integer differences. Verifies an attainable 13-mark union.
"""
from itertools import combinations
from math import gcd

V, K = 31, 6
SOURCE = (0, 1, 3, 8, 12, 18)
WITNESS = ((2, 6, 12, 25, 26, 28), (0, 18, 25, 30), (8, 17, 25))
BIG_OFFSETS = (0, 100, 1000)
# Sorted positive sizes: all total 14, 15 possibilities with k_i <= 6,
# k_i >= 1. Counting alone excludes total >=16.
CRITICAL = ((5, 5, 5), (6, 5, 4), (6, 6, 3),
            (6, 4, 4), (5, 5, 4), (6, 5, 3), (6, 6, 2))


def differences(elements):
    return frozenset(b - a for a, b in combinations(elements, 2))


def pair_sums_unique(elements):
    sums = [a+b for i, a in enumerate(elements) for b in elements[i:]]
    return len(sums) == len(set(sums))


def exhaustive():
    modular = [(a - b) % V for a in SOURCE for b in SOURCE if a != b]
    assert len(modular) == V-1 and set(modular) == set(range(1, V))
    full_sources = {
        tuple(sorted((u*x+c) % V for x in SOURCE))
        for u in range(1, V) if gcd(u, V) == 1 for c in range(V)
    }
    assert len(full_sources) == 310
    # Dedup difference masks only: same difference set is indistinguishable
    # for the collision criterion, and we retain one literal block for replay.
    family = {size: {} for size in range(1, K+1)}
    for source in sorted(full_sources):
        assert len(differences(source)) == K*(K-1)//2
        for size in range(1, K+1):
            for block in combinations(source, size):
                assert pair_sums_unique(block)
                family[size].setdefault(differences(block), block)
    assert tuple(len(family[k]) for k in range(1,7)) == (1, 30, 150, 300, 150, 28)
    # Stronger anchored extension audit: holding an entire 6-mark source fixed,
    # count allowed four- and five-mark successor difference spectra.
    admissible_four_counts = []
    for first in family[6]:
        allowed_four = [d for d in family[4] if first.isdisjoint(d)]
        allowed_five = [d for d in family[5] if first.isdisjoint(d)]
        assert not allowed_five
        admissible_four_counts.append(len(allowed_four))
        assert len(allowed_four) <= 2
        assert not any(a.isdisjoint(b) for a,b in combinations(allowed_four,2))
    assert (admissible_four_counts.count(0),
            admissible_four_counts.count(1),
            admissible_four_counts.count(2)) == (24, 3, 1)

    def exists_three(sizes):
        a, b, c = sizes
        for d1 in family[a]:
            for d2 in family[b]:
                if not d1.isdisjoint(d2):
                    continue
                for d3 in family[c]:
                    if d1.isdisjoint(d3) and d2.isdisjoint(d3):
                        return True
        return False

    # Any Sidon union of three blocks inside length 30 must obey
    # sum_i C(k_i,2) <=30, implying total retained <=15. Each sorted
    # partition of 14 or 15 is covered by CRITICAL (up to permutation).
    all_partitions = {(a,b,c) for total in (14,15)
                      for a in range(1,7) for b in range(1,a+1)
                      for c in range(1,b+1) if a+b+c == total}
    assert all_partitions == set(CRITICAL)
    for sizes in CRITICAL:
        assert sum(sizes) in (14, 15)
        assert not exists_three(sizes), ('unexpected three-block overlap-free packing', sizes)

    for block in WITNESS:
        assert block in [tuple(sub) for full in full_sources for size in (len(block),)
                         for sub in combinations(full, size)]
    assert all(differences(WITNESS[i]).isdisjoint(differences(WITNESS[j]))
               for i in range(3) for j in range(i+1,3))
    union = sorted(x+BIG_OFFSETS[i] for i, block in enumerate(WITNESS) for x in block)
    assert len(union) == 13 and pair_sums_unique(union)
    # Deliberate negative control: adding same fixed source at offsets 0 and
    # 100 makes a mixed-sum collision from identical positive differences.
    corrupted = sorted(SOURCE + tuple(x+100 for x in SOURCE))
    assert not pair_sums_unique(corrupted)
    print('PASS: 31 modular residues; 310 distinct affine Singer cuts')
    print('PASS: deduplicated difference masks by subblock size = 1,30,150,300,150,28')
    print('PASS: anchored full-block successor 5-marks impossible; allowed 4-mask counts 24/3/1')
    print('PASS: no pairwise-difference-disjoint 3-block packing with >=14 marks')
    print('PASS: literal 13-mark witness has all 91 unordered pair sums distinct')
    print('PASS: duplicated full-block negative control correctly rejected')
    print('WITNESS:', union)


if __name__ == '__main__':
    exhaustive()

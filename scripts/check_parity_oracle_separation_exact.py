#!/usr/bin/env python3
"""Exact parity-augmented binary phase-oracle structural-separation audit.

Finite XOR fibers, k-wise marginals, and a sharp squared-risk negative control.
All-r statements require the companion mathematical proof, not this enumeration.
"""
from collections import Counter
from fractions import Fraction
from itertools import combinations, product
from math import factorial


def labels(r):
    return tuple((1 << j) for j in range(r)) + ((1 << r) - 1,)


def fibers(r):
    R = labels(r)
    D = (0,) + R
    m2 = Counter()
    for a, b in product(D, repeat=2):
        if a ^ b:
            m2[a ^ b] += 1
    k4 = Counter()
    for k in range(1, 5):
        for support in combinations(R, k):
            z = 0
            for a in support:
                z ^= a
            if not z:
                continue
            independent = True
            for mask in range(1, 1 << k):
                xor_sum = 0
                for i in range(k):
                    if (mask >> i) & 1:
                        xor_sum ^= support[i]
                if xor_sum == 0:
                    independent = False
                    break
            if independent:
                k4[z] += factorial(4) // factorial(4 - k)
    return max(k4.values(), default=0), max(m2.values(), default=0)


def full_table(r, s):
    return tuple(((a & s).bit_count() & 1) for a in labels(r))


def check_moments(r):
    words = {full_table(r, s) for s in range(1 << r)}
    assert len(words) == (1 << r)
    n = r + 1
    # No one-coordinate source edge: every conditional-product support is atomic.
    for x in words:
        for j in range(n):
            flipped = x[:j] + (x[j] ^ 1,) + x[j+1:]
            assert flipped not in words
    for k in range(r + 1):
        for subset in combinations(range(n), k):
            counts = Counter(tuple(x[j] for j in subset) for x in words)
            assert len(counts) == 2 ** k
            assert set(counts.values()) == {2 ** (r-k)}
    return words


def risk(words):
    # f=1/2 + x_2*x_3/4, depth-2 tree t=(1+x_0*x_1)/2.
    total = Fraction(0)
    for x in words:
        spins = [(-1 if bit else 1) for bit in x]
        f = Fraction(1, 2) + Fraction(spins[2]*spins[3], 4)
        t = Fraction(1 + spins[0]*spins[1], 2)
        total += (f - t) ** 2
    return total / len(words)


def main():
    for r in range(3, 11):
        k4, m2 = fibers(r)
        print(f'r={r:2} K4={k4:2} M2={m2}')
        if r >= 8:
            assert (k4, m2) == (24, 2)
    for r in range(3, 8):
        actual = check_moments(r)
        full = set(product((0, 1), repeat=r+1))
        pa, pb = risk(actual), risk(full)
        if r == 3:
            assert (pa, pb) == (Fraction(1, 16), Fraction(5, 16))
            print('PASS sharp failure at parity order 4 (moment threshold too small)')
        else:
            assert pa == pb == Fraction(5, 16)
            print(f'PASS r={r} exact r-wise moments and depth-2 squared risk transfer')
    print('NOTE: finite test is not a proof of all-r Wyner CI or all-T quantum simulation')


if __name__ == '__main__':
    main()

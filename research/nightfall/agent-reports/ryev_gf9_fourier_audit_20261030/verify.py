#!/usr/bin/env python3
"""Independent GF9 seven-sign branch audit: direct 64-word enumeration + rational Fourier obstruction.
No source imports, no GF9 multiplication, no precomputed lookup from PR #266.
This is an *internal* mathematical checker; it is not an external or Lean proof.
"""
from itertools import product
from collections import Counter

VECTORS = ((0, 0), (1, 0), (0, 1), (1, 1), (1, 2))
# For every nonzero projective direction, choose a character annihilating it.
FUNCTIONALS = ((0, 1), (1, 0), (1, 2), (1, 1))

def neg(a):
    return ((-a[0]) % 3, (-a[1]) % 3)

def projective_labels():
    labels = {(0, 0): 0}
    for label, vector in enumerate(VECTORS[1:], 1):
        labels[vector] = labels[neg(vector)] = label
    assert len(labels) == 9
    return labels

LABELS = projective_labels()
SIGNS = tuple((1,) + rest for rest in product((1, -1), repeat=6))
assert len(SIGNS) == 64

def direct_buckets(coefficients):
    """Count legal square-oracle outputs using relative signs (first raw sign fixed +1)."""
    histogram = [0] * 5
    for signs in SIGNS:
        a = sum(sign * c[0] for sign, c in zip(signs, coefficients)) % 3
        b = sum(sign * c[1] for sign, c in zip(signs, coefficients)) % 3
        histogram[LABELS[(a, b)]] += 1
    assert sum(histogram) == 64
    return histogram

def evaluate_fourier_identity(coefficients, buckets):
    """Compute each Fourier coefficient in two disjoint ways, using integer arithmetic."""
    for j, functional in enumerate(FUNCTIONALS, 1):
        # Character is 1 along its kernel, while the pair of conjugate values
        # off the kernel sums to -1 (primitive cubic roots).
        by_buckets = 3 * (buckets[0] + buckets[j]) - 64
        # Multiplication of independent sign characters: (chi(c)+chi(-c)).
        by_factors = 1
        for c in coefficients:
            by_factors *= 2 if (functional[0]*c[0]+functional[1]*c[1]) % 3 == 0 else -1
        assert by_buckets == by_factors, (coefficients, j, buckets, by_buckets, by_factors)
        assert by_buckets in (-1, 2, -4, 8, -16, 32, -64, 128)

def impossible_five_bucket_13_ceiling():
    """If 64 items fit five buckets of <=13, counts are four 13s and one 12.
    The nontrivial Fourier values include 11 (indeed all 11/14), impossible
    for a product of seven factors from {2,-1}.
    """
    patterns = set(v for v in product((12,13), repeat=5) if sum(v)==64)
    assert len(patterns)==5
    spectrum = {-1,2,-4,8,-16,32,-64,128}
    for b in patterns:
        fourier = [3*(b[0]+b[j])-64 for j in range(1,5)]
        assert 11 in fourier
        assert not set(fourier).issubset(spectrum)
    return len(patterns)

def rank_histories():
    """Cross-check the eight-query adversarial rank/palette recurrence by direct patterns."""
    exceptional = []
    for tail in product(('I', 'D'), repeat=7):
        rank, palette = 1, 1
        for step in tail:
            if step == 'I':
                rank += 1
                palette *= 2
            else:
                palette = (palette + 4) // 5
        residual = palette * 9**(8-rank)
        if residual <= 125:
            exceptional.append(('I' + ''.join(tail), rank, palette, residual))
    assert exceptional == [('IIIIIIID', 7, 13, 117)], exceptional
    assert 14*9 > 5**3
    return exceptional

def audit():
    impossible_five_bucket_13_ceiling()
    exceptional = rank_histories()
    census = Counter()
    first = None
    count = 0
    minmax = 65
    for types in product(range(5), repeat=7):
        coefficients = tuple(VECTORS[t] for t in types)
        b = direct_buckets(coefficients)
        evaluate_fourier_identity(coefficients, b)
        largest = max(b)
        census[largest] += 1
        if largest < minmax:
            minmax, first = largest, (types, tuple(sorted(b, reverse=True)))
        count += 1
    assert count == 5**7 == 78125
    assert minmax == 14, (minmax, first)
    assert census[14] == 2520, census[14]
    assert first[1] == (14,14,14,12,10), first
    assert all(k >= 14 for k in census)
    # Mutations: illegal unpowered sum has 9 possible raw values on a valid input.
    coeffs = (VECTORS[1], VECTORS[2], VECTORS[3], VECTORS[4], VECTORS[1], VECTORS[2], VECTORS[3])
    unpowered = {(
        sum(sign*c[0] for sign,c in zip(s,coeffs))%3,
        sum(sign*c[1] for sign,c in zip(s,coeffs))%3
    ) for s in SIGNS}
    assert len(unpowered)==9 and len(direct_buckets(coeffs))==5
    assert direct_buckets((VECTORS[0],)*7) == [64,0,0,0,0]
    print('PASS: exact direct 64-word / 78125 coefficient-seven tuples')
    print('PASS: four independent integer-character identities per tuple')
    print('PASS: 128 adaptive rank histories; sole exception:', exceptional)
    print('PASS: five hypothetical 13-capacity partitions forbidden analytically')
    print('PASS: zero fiber and forbidden unpowered-nine-output controls')
    print('min_worst_bucket=', minmax,'attainers=',census[14], 'first=', first)
    print('STATUS: internal analytical audit; no human review or global originality')

if __name__ == '__main__':
    audit()

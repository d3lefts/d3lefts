"""Independent exact certificates for finite-field power-sensing information bounds."""
from functools import lru_cache
from math import comb, gcd

def lower_bound(q, n, k):
    d = gcd(n, q - 1)
    alphabet = 1 + (q - 1) // d
    classes = 1 + (q ** k - 1) // d
    global_depth = 0
    while alphabet ** global_depth < classes:
        global_depth += 1
    branch_depth = 0
    while alphabet ** branch_depth < q ** (k - 1):
        branch_depth += 1
    return d, alphabet, classes, global_depth, 1 + branch_depth

def exact_planar_indicator_depth(q):
    # States: zero vector 0; projective directions 1..q+1.
    # A nonzero linear oracle tests one line, returning zero on it and on 0.
    states = frozenset(range(q + 2))
    @lru_cache(None)
    def solve(S):
        if len(S) <= 1:
            return 0
        candidates = []
        for line in range(1, q + 2):
            zero = S.intersection((0, line))
            nonzero = S.difference(zero)
            if not zero or not nonzero:
                continue
            candidates.append(1 + max(solve(frozenset(zero)), solve(frozenset(nonzero))))
        return min(candidates) if candidates else 10**8
    return solve(states)

def test_binomial_identity():
    for d in range(2, 11):
        for r in range(1, 11):
            for k in range(2, 11):
                q = 1 + d * r
                A = 1 + r
                direct = q**k - 1 - d * (A**k - 1)
                independent = sum(comb(k, j) * (d**j - d) * r**j
                                  for j in range(2, k + 1))
                assert direct == independent > 0, (d, r, k)

def test_exact_planar_depth():
    for q in (3, 5, 7):
        assert exact_planar_indicator_depth(q) == q

def test_stronger_branch_bound():
    assert lower_bound(5, 4, 3) == (4, 2, 32, 5, 6)
    assert lower_bound(5, 4, 4) == (4, 2, 157, 8, 8)
    assert lower_bound(25, 4, 3) == (4, 7, 3907, 5, 5)

if __name__ == "__main__":
    test_binomial_identity()
    test_exact_planar_depth()
    test_stronger_branch_bound()
    print("All exact arithmetic, exhaustive planar DP, and branch-bound tests passed.")

"""Finite exact replay for the Route 1 injective-label bridge.

Checks atom normalization, both endpoints, and a complete N=8
Simon transcript enumeration. No analytic or Lean claim.
"""
from collections import Counter, defaultdict
from fractions import Fraction
from itertools import permutations, product
from math import perm


def check_atoms():
    cases = 0
    for A in range(2, 5):
        for j in range(1, A + 1):
            for r in range(1, 6):
                got = defaultdict(Fraction)
                for keys in product(range(r), repeat=j):
                    occ = sorted(set(keys))
                    weight = Fraction(1, r**j * perm(A, len(occ)))
                    for labels in permutations(range(A), len(occ)):
                        mp = dict(zip(occ, labels))
                        got[tuple(mp[key] for key in keys)] += weight
                assert sum(got.values()) == 1
                for labels in product(range(A), repeat=j):
                    ell = len(set(labels))
                    want = Fraction(perm(r, ell), r**j * perm(A, ell))
                    assert got[labels] == want
                    if r == A:
                        assert got[labels] == Fraction(1, A**j)
                    cases += 1
    return cases


def check_simon():
    N = 8
    # Complementary coordinate subspaces for dimensions one and two.
    cover = sorted(set((0, 1)) | set((0, 2, 4, 6)))
    leaves = 0
    tables = 0
    for shift in range(1, N):
        reps = sorted({min(x, x ^ shift) for x in range(N)})
        ix = {x: j for j, x in enumerate(reps)}
        trace_ix = [ix[min(x, x ^ shift)] for x in cover]
        seen = set(trace_ix)
        remaining = [j for j in range(len(reps)) if j not in seen]
        groups = defaultdict(Counter)
        for labels in permutations(range(N), len(reps)):
            trace = tuple(labels[j] for j in trace_ix)
            found = {x ^ y for i, x in enumerate(cover)
                     for j, y in enumerate(cover) if i < j and trace[i] == trace[j]}
            assert found == {shift}
            rest = tuple(labels[j] for j in remaining)
            groups[trace][rest] += 1
            tables += 1
        for trace, obs in groups.items():
            unused = sorted(set(range(N)) - set(trace))
            assert obs == Counter(permutations(unused, len(remaining)))
            leaves += 1
    return tables, leaves


if __name__ == "__main__":
    atoms = check_atoms()
    tables, leaves = check_simon()
    print(f"PASS: {atoms} interpolation atoms; {tables} N=8 tables; {leaves} conditional cover leaves")

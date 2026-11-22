#!/usr/bin/env python3
"""Exact finite tests for classical prime-circulant permanent symmetries.

This is NOT a certificate for the asymptotic Németh–Seberry–Shu disproof.
No external Python packages required. Run: python3 scripts/check_circulant_permanent_invariants.py
"""
from itertools import permutations


def permanent_dp(p: int, support: frozenset[int]) -> int:
    """Independent row-by-row subset DP, using only exact integers."""
    dp = [0] * (1 << p)
    dp[0] = 1
    for mask in range(1, 1 << p):
        i = mask.bit_count() - 1
        total = 0
        cols = mask
        while cols:
            bit = cols & -cols
            col = bit.bit_length() - 1
            if (col - i) % p in support:
                total += dp[mask ^ bit]
            cols ^= bit
        dp[mask] = total
    return dp[-1]


def permanent_brute(p: int, support: frozenset[int]) -> int:
    """Independent permutation enumeration (small p only)."""
    return sum(all((sigma[i] - i) % p in support for i in range(p))
               for sigma in permutations(range(p)))


def masks(p: int):
    for m in range(1 << p):
        yield frozenset(i for i in range(p) if m & (1 << i))


def run_checks() -> None:
    checked = 0
    for p in (2, 3, 5, 7):
        values = {}
        for support in masks(p):
            v = permanent_dp(p, support)
            checked += 1
            assert v % p == len(support) % p, (p, support, v)
            if p <= 5:
                assert v == permanent_brute(p, support), (p, support, v)
            values[support] = v
        # Translation, all nonzero dilations: exact affine invariance.
        for support, v in values.items():
            for a in range(1, p):
                for b in range(p):
                    transformed = frozenset((a * s + b) % p for s in support)
                    assert values[transformed] == v, (p, support, a, b)
        # Negative control: a corrupted value cannot pass the congruence test.
        assert not all((v + 1) % p == len(s) % p for s, v in values.items())
        distinct = len(set(values.values()))
        print(f"p={p}: checked {len(values)} supports, {distinct} distinct exact permanents; affine and mod-p tests PASS")
    assert checked == sum(1 << p for p in (2, 3, 5, 7))
    print(f"PASS: {checked} exact supports; independent brute-force cross-check for p<=5")


if __name__ == '__main__':
    run_checks()

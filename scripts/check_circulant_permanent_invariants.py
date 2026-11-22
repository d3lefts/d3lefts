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



def permanent_from_rows(row_masks: list[int]) -> int:
    """Exact subset DP for an arbitrary (possibly nonabelian) Cayley matrix."""
    n = len(row_masks)
    dp = [0] * (1 << n)
    dp[0] = 1
    for mask in range(1, 1 << n):
        row = mask.bit_count() - 1
        allowed = mask & row_masks[row]
        while allowed:
            b = allowed & -allowed
            dp[mask] += dp[mask ^ b]
            allowed ^= b
    return dp[-1]


def brute_from_rows(row_masks: list[int]) -> int:
    """Different formulation: enumerate bijections, only for selected test cases."""
    n = len(row_masks)
    return sum(all(row_masks[i] & (1 << sigma[i]) for i in range(n))
               for sigma in permutations(range(n)))


def dihedral_multiply(i: int, j: int) -> int:
    """D8 as (rotation mod 4, reflection bit); identity is 0."""
    a, b = i % 4, i // 4
    c, d = j % 4, j // 4
    return (a + (1 if b == 0 else -1) * c) % 4 + 4 * ((b + d) % 2)


def group_check(size: int, prime: int, multiply, label: str) -> None:
    for subset_mask in range(1 << size):
        rows = [0] * size
        for x in range(size):
            for s in range(size):
                if subset_mask & (1 << s):
                    rows[x] |= 1 << multiply(x, s)
        result = permanent_from_rows(rows)
        assert result % prime == subset_mask.bit_count() % prime, (label, subset_mask, result)
        if label.startswith("D8") and subset_mask < 8:
            assert result == brute_from_rows(rows), (label, subset_mask, result)
    print(f"{label}: all {1 << size} supports satisfy the p-group congruence modulo {prime}")


def run_group_checks() -> None:
    group_check(4, 2, lambda x, s: (x + s) % 4, "C4")
    group_check(8, 2, lambda x, s: (x + s) % 8, "C8")
    group_check(8, 2, dihedral_multiply, "D8 (nonabelian)")
    # Scope control: the analogous congruence is false for arbitrary groups.
    counterexamples = []
    for mask in range(1 << 6):
        rows = [sum(1 << ((x + s) % 6) for s in range(6) if mask & (1 << s)) for x in range(6)]
        value = permanent_from_rows(rows)
        if value % 2 != mask.bit_count() % 2:
            counterexamples.append((mask, value))
    assert counterexamples, "Expected a counterexample for non-p-group C6"
    mask, value = counterexamples[0]
    print(f"C6 scope control: S-mask={mask}, permanent={value}, per mod 2 != |S| mod 2")



def permanent_weighted(rows: list[list[int]]) -> int:
    """Exact integer DP for a matrix of arbitrary (including negative) weights."""
    n = len(rows)
    dp = [0] * (1 << n)
    dp[0] = 1
    for mask in range(1, 1 << n):
        i = mask.bit_count() - 1
        active = mask
        while active:
            b = active & -active
            j = b.bit_length() - 1
            dp[mask] += rows[i][j] * dp[mask ^ b]
            active ^= b
    return dp[-1]


def check_weighted_group(size: int, prime: int, multiply, weights: list[int]) -> None:
    rows = [[0] * size for _ in range(size)]
    for i in range(size):
        for g, w in enumerate(weights):
            rows[i][multiply(i, g)] = w
    value = permanent_weighted(rows)
    assert value % prime == sum(weights) % prime, (size, prime, weights, value)


def run_weighted_checks() -> None:
    from itertools import product
    count = 0
    for weights in product(range(-2, 3), repeat=3):
        check_weighted_group(3, 3, lambda i, g: (i + g) % 3, list(weights))
        count += 1
    for weights in product(range(-2, 3), repeat=4):
        check_weighted_group(4, 2, lambda i, g: (i + g) % 4, list(weights))
        count += 1
    for seed in range(24):
        weights = [((seed + 1) * (i + 2) % 7) - 3 for i in range(8)]
        check_weighted_group(8, 2, dihedral_multiply, weights)
        count += 1
    for seed in range(24):
        weights = [((seed + 2) * (i + 3) % 11) - 5 for i in range(9)]
        check_weighted_group(9, 3, lambda i, g: (i + g) % 9, weights)
        count += 1
    print(f"Weighted Cayley congruence: {count} exact integer matrices PASS (C3, C4, C9 and D8)")


if __name__ == '__main__':
    run_checks()
    run_group_checks()
    run_weighted_checks()

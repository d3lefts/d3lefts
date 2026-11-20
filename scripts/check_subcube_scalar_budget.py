#!/usr/bin/env python3
"""Exact finite scalar-budget audit, independent of the Lean algebraic proof.

This checks a three-slice *upper-bound recurrence*, not the maxima across all
binary subspaces at L>3. It does not certify the all-L sharp exponent.
No floating-point operations, Mathlib dependencies, or learned coefficients.
"""
from functools import lru_cache

@lru_cache(None)
def dyadic_candidate(n: int) -> int:
    if n <= 1:
        return n
    if n % 2 == 0:
        return 3 * dyadic_candidate(n // 2)
    return dyadic_candidate(n // 2 + 1) + 2 * dyadic_candidate(n // 2)


def independent_three_slice(prev: list[int]) -> list[int]:
    """Enumerate sorted (a,b,c); the largest pair sum is b+c."""
    d = len(prev) - 1
    attained = [0] * (2 * d + 1)
    for a in range(d + 1):
        for b in range(a, d + 1):
            for c in range(b, d + 1):
                q_min = b + c
                score = prev[a] + prev[b] + prev[c]
                attained[q_min] = max(attained[q_min], score)
    upper = []
    maximum = 0
    for new in attained:
        maximum = max(maximum, new)
        upper.append(maximum)
    return upper


def main() -> None:
    caps = [0, 1]
    for L in range(1, 7):
        caps = independent_three_slice(caps)
        assert len(caps) == (1 << L) + 1
        assert caps == [dyadic_candidate(q) for q in range(len(caps))]
        assert all(caps[q] <= q * q for q in range(len(caps)))
        assert caps[-1] == 3**L
        print(f"SCALAR_DP_LEVEL_PASS L={L} rank_max={1<<L} cap_tail={caps[-8:]}")
    print("SUBCUBE_SCALAR_DYADIC_L6_EXACT_PASS")


if __name__ == "__main__":
    main()

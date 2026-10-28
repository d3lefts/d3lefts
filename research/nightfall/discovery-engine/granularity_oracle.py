"""Independent atomic scorers for the bounded NIGHTFALL granularity study.

Do not import the constructor or boundary-router implementation here. Only
primitive bytes and the exact candidate are accepted.
"""
from __future__ import annotations


def overlap_certificate(bits: bytes, expected_mass: int) -> dict:
    n = len(bits)
    if n < 5 or any(x not in (48,49) for x in bits):
        raise ValueError("invalid binary overlap atoms")
    if sum(x == 49 for x in bits) != expected_mass or not 2 <= expected_mass < n:
        raise ValueError("overlap mass mismatch")
    hist = []
    for shift in range(1, n):
        count = 0
        for index in range(n):
            if bits[index] == 49 and bits[(index+shift)%n] == 49:
                count += 1
        hist.append(count)
    if sum(hist) != expected_mass*(expected_mass-1):
        raise ArithmeticError("pair-count identity failed")
    lower=(expected_mass*(expected_mass-1)+n-2)//(n-1)
    value=max(hist)
    if value < lower:
        raise ArithmeticError("average-correlation lower bound violated")
    return {"max": value, "lower": lower, "hist": hist}


def source_certificate(atoms: bytes, hard_boundaries: tuple[int,...], start: int, end: int) -> bool:
    """Atomic proxy: every source atom must affirm support, within one trust zone."""
    n = len(atoms)
    if any(x not in (48,49) for x in atoms):
        raise ValueError("invalid source support atoms")
    if not 0 <= start < end <= n:
        raise ValueError("invalid source span")
    if any(not 0 < i < n for i in hard_boundaries):
        raise ValueError("invalid trust boundary")
    if any(start < i < end for i in hard_boundaries):
        return False
    for i in range(start, end):
        if atoms[i] != 49:
            return False
    return True

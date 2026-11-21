#!/usr/bin/env python3
"""Exact, stdlib-only audit of triple out-neighborhoods of Paley T_5591.

Orientation: x -> y iff (y-x) mod 5591 is a nonzero quadratic residue.
The affine automorphisms x -> u*x+v, with u a nonzero square, reduce all
ordered distinct triples to (0,1,c) or (0,-1,c) with c not in {0,b}.

Two independent arithmetic implementations are checked for every normalized
case: cyclic bitset intersections (A) and Euler-character membership (B).
No statement about sensitivity exponent or about another author's Lean proof
is inferred from this standalone geometry audit.
"""
from __future__ import annotations
import hashlib
import json
import sys
from collections import Counter
from math import isqrt
from pathlib import Path

P = 5591
EXPECTED_MAX = 717


def is_prime(n: int) -> bool:
    return n >= 2 and all(n % d for d in range(2, isqrt(n) + 1))


def cyclic_shift(mask: int, shift: int, full: int) -> int:
    shift %= P
    if not shift:
        return mask
    return ((mask << shift) & full) | (mask >> (P - shift))


def method_a() -> dict:
    squares = {x*x % P for x in range(1, P)}
    assert len(squares) == (P-1)//2
    mask = sum(1 << x for x in squares)
    full = (1 << P) - 1
    counts = {}
    for b in (1, P-1):
        ab = mask & cyclic_shift(mask, b, full)
        for c in range(P):
            if c in (0,b):
                continue
            counts[(b,c)] = (ab & cyclic_shift(mask, c, full)).bit_count()
    return counts


def method_b() -> dict:
    # Euler's criterion, independently generating membership from modular powers.
    char = [0]*P
    for z in range(1,P):
        char[z] = 1 if pow(z,(P-1)//2,P) == 1 else -1
    assert sum(ch == 1 for ch in char) == (P-1)//2
    counts = {}
    for b in (1,P-1):
        common_ab = [y for y in range(P)
                     if char[y] == 1 and char[(y-b) % P] == 1]
        for c in range(P):
            if c in (0,b):
                continue
            counts[(b,c)] = sum(char[(y-c) % P] == 1 for y in common_ab)
    return counts


def main() -> None:
    assert is_prime(P), "Primality required for Euler's criterion and Paley tournament."
    assert P % 4 == 3
    a = method_a()
    b = method_b()
    assert a == b, "Independent implementations disagree."
    assert len(a) == 2*(P-2)
    maximum = max(a.values())
    assert maximum == EXPECTED_MAX
    witnesses = {str(k): sorted(c for (bb,c),z in a.items()
                                if bb == k and z == maximum) for k in (1,P-1)}
    assert a[(1,838)] == EXPECTED_MAX
    triple = (0,1,838)
    witness_sum = 0
    for x in range(P):
        z = ((x-triple[0])*(x-triple[1])*(x-triple[2])) % P
        if z:
            witness_sum += 1 if pow(z,(P-1)//2,P)==1 else -1
    square = {x*x % P for x in range(1,P)}
    t = sum(all((root-other) % P in square for other in triple if other != root)
            for root in triple)
    assert (witness_sum,t)==(148,0)
    assert 8*a[(1,838)] == P-3+witness_sum-4*t
    # Hasse gives |S| <= 2 sqrt(P) < 150. This arithmetic is exact;
    # invoking Hasse itself is a classical mathematical dependency.
    assert 4*P < 150**2
    assert (P-3+149)//8 == EXPECTED_MAX
    distribution = Counter(a.values())
    result = {
        "statement": "max distinct a,b,c |Out(a) intersect Out(b) intersect Out(c)| = 717",
        "edge_convention": "x -> y iff (y-x) mod 5591 is a nonzero square",
        "prime": P,
        "number_of_reduced_cases": len(a),
        "normal_forms": [[0,1,"c"], [0,P-1,"c"]],
        "minimum_common_outdegree": min(a.values()),
        "maximum_common_outdegree": maximum,
        "witnesses_by_second_vertex": witnesses,
        "distribution": {str(z): distribution[z] for z in sorted(distribution)},
        "implementation_agreement": True,
        "witness_cubic_character_sum": witness_sum,
        "witness_root_correction_t": t,
        "hasse_upper_bound": (P-3+149)//8,
        "audit_status": "exhaustive exact finite computation; not Lean-certified or peer-reviewed",
        "scope": "Paley tournament T_5591 geometry only; no sensitivity exponent improvement claimed",
        "python_version": sys.version.split()[0],
        "checker_sha256": hashlib.sha256(Path(__file__).read_bytes()).hexdigest()
    }
    out = Path(__file__).with_name('nightfall_paley5591_triple_receipt.json')
    out.write_text(json.dumps(result, indent=2, sort_keys=True)+'\n')
    print(json.dumps({key:result[key] for key in (
        'prime','number_of_reduced_cases','minimum_common_outdegree',
        'maximum_common_outdegree','witnesses_by_second_vertex',
        'implementation_agreement','witness_cubic_character_sum',
        'witness_root_correction_t','hasse_upper_bound','checker_sha256')}, indent=2))
    print('Receipt:',out)

if __name__ == '__main__':
    main()
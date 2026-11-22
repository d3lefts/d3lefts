#!/usr/bin/env python3
"""Exact independent replay: 2D intensity block -> Route 1 product coordinates.

Finite checks do not establish Wyner's universal entropy statement.
The accompanying note supplies that combinatorial proof.
Python stdlib only. Two independent representations: direct dot products and
polarization / sufficient statistics. No random seeds or floating point.
"""
from __future__ import annotations

from itertools import combinations, product
from collections import defaultdict
from fractions import Fraction
from hashlib import sha256
import json

SIGNALS = tuple((a, sign * b)
                for a, b, sign in product((1, 3), (1, 3), (-1, 1)))
ROWS = ((1, 0), (0, 1), (1, 1), (1, -1))
assert len(SIGNALS) == 8 and len(ROWS) == 4


def intensity(x, row):
    return sum(a * b for a, b in zip(x, row)) ** 2


def oracle_table():
    return tuple(tuple(intensity(x, row) for row in ROWS) for x in SIGNALS)


def sufficient_stats(values, omitted):
    """Independent algebraic inverse of any 3 of 4 readings; exact rationals."""
    entries = {j: Fraction(values[j]) for j in range(4) if j != omitted}
    if omitted == 0:
        v2 = entries[1]
        u2 = (entries[2] + entries[3]) / 2 - v2
        uv = (entries[2] - entries[3]) / 4
    elif omitted == 1:
        u2 = entries[0]
        v2 = (entries[2] + entries[3]) / 2 - u2
        uv = (entries[2] - entries[3]) / 4
    elif omitted == 2:
        u2, v2 = entries[0], entries[1]
        uv = (u2 + v2 - entries[3]) / 2
    elif omitted == 3:
        u2, v2 = entries[0], entries[1]
        uv = (entries[2] - u2 - v2) / 2
    else:
        raise ValueError("omitted must be one of 0,1,2,3")
    return u2, v2, uv


def adaptive_two_witnesses(table):
    """For each possible first reading, find an outcome no second can resolve."""
    result = {}
    for first in range(4):
        fibers = defaultdict(list)
        for idx, y in enumerate(table):
            fibers[y[first]].append(idx)
        for outcome, candidates in fibers.items():
            witnesses = {}
            for second in range(4):
                if second == first:
                    continue
                pairs = [(x, z) for x, z in combinations(candidates, 2)
                         if table[x][second] == table[z][second]]
                if not pairs:
                    break
                witnesses[str(second)] = pairs[0]
            else:
                result[str(first)] = {"outcome": outcome,
                                      "indistinguishable_by_next": witnesses}
                break
        else:
            raise AssertionError(f"first reading {first} admits an adaptive two-query decoder")
    return result


def exhaustive_two_query_policies(table):
    """Enumerate ALL second-reading choices conditional on the first value."""
    tested = 0
    for first in range(4):
        labels = tuple(sorted({row[first] for row in table}))
        for policy in product(range(4), repeat=len(labels)):
            action = dict(zip(labels, policy))
            transcript = tuple((row[first], row[action[row[first]]]) for row in table)
            assert len(set(transcript)) < len(table), (
                "counterexample: two-reading policy identified every signal", first, policy
            )
            tested += 1
    return tested


def check_no_coordinate_edges(table):
    """No two valid raw words may differ in exactly one coordinate."""
    supports = set(table)
    assert len(supports) == 8
    distances = []
    forbidden_swaps = 0
    for x, y in combinations(table, 2):
        changed = [j for j in range(4) if x[j] != y[j]]
        distances.append(len(changed))
        assert len(changed) >= 2
        for j in changed:
            mixed = list(x)
            mixed[j] = y[j]
            assert tuple(mixed) not in supports
            forbidden_swaps += 1
    return min(distances), forbidden_swaps


def check_product_edges(table, blocks):
    """Finite small-B illustration; all-B statement follows by block locality."""
    states = tuple(sum(pieces, ()) for pieces in product(table, repeat=blocks))
    alphabet = tuple(sorted({x[j] for x in table}) for j in range(4))
    support = set(states)
    assert len(states) == len(support) == 8 ** blocks
    tested = 0
    for word in support:
        for i in range(4 * blocks):
            for other in alphabet[i % 4]:
                if other == word[i]:
                    continue
                modified = word[:i] + (other,) + word[i+1:]
                assert modified not in support, (blocks, word, i, other)
                tested += 1
    return tested


def main():
    table = oracle_table()
    assert len(set(table)) == 8
    triple_tests = 0
    for omitted in range(4):
        for idx, signal in enumerate(SIGNALS):
            u, v = signal
            expected = (Fraction(u*u), Fraction(v*v), Fraction(u*v))
            assert sufficient_stats(table[idx], omitted) == expected
            triple_tests += 1
        kept = [j for j in range(4) if j != omitted]
        assert len({tuple(row[j] for j in kept) for row in table}) == 8
    # Actual identities via second implementation: oracle table is squared dot
    # product, reconstructed (u^2,v^2,uv) identifies the sign class.
    assert len({(u*u, v*v, u*v) for u, v in SIGNALS}) == 8
    pair_witnesses = adaptive_two_witnesses(table)
    policies = exhaustive_two_query_policies(table)
    min_distance, cross_swaps = check_no_coordinate_edges(table)
    smallB = {str(b): check_product_edges(table, b) for b in (1, 2, 3)}
    assert min_distance == 2
    assert policies == 544, policies  # 2*4^2 + 2*4^4
    assert {k: v["outcome"] for k, v in pair_witnesses.items()} == {
        "0": 1, "1": 1, "2": 4, "3": 4}
    report = {
        "schema": "nightfall.phase-route1-finite-check.v1",
        "signals": [list(x) for x in SIGNALS],
        "measurement_rows": [list(x) for x in ROWS],
        "intensity_table": [list(row) for row in table],
        "three_reading_exact_reconstructions": triple_tests,
        "adaptive_depth_two_policies_ruled_out": policies,
        "two_query_adversarial_fibers": pair_witnesses,
        "min_codeword_hamming_distance": min_distance,
        "forbidden_one_coordinate_recombinations_checked": cross_swaps,
        "forbidden_single_coordinate_edits_by_blocks": smallB,
        "single_block_uniform_entropy_bits": 3,
        "general_B_Wyner_proof": "paper combinatorial support-rectangle argument, not computed here",
        "full_route1_lean_certificate": False,
        "external_priority_check_complete": False,
    }
    data = json.dumps(report, sort_keys=True, separators=(",", ":"))
    print(data)
    print("PASS: exact 8-signal frame, all triples, all 544 depth-two policies, "
          "minimum support distance 2, B<=3 product-edge tests. "
          f"report sha256={sha256(data.encode()).hexdigest()}")


if __name__ == "__main__":
    main()

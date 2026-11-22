#!/usr/bin/env python3
"""Exact adversarial checker: eight-signal, four-reading phase → Route 1 bridge.

All integer arithmetic. Compares two independent 2-query methods, enumerates
all three-row decoders, checks rectangle rigidity for one and two blocks,
and supplies an unrestricted-measurement negative control.

This does NOT numerically optimize Wyner common information: the all-B
C_W = 3B theorem requires the rectangle-support entropy proof in the note.
"""
from collections import defaultdict
from functools import lru_cache
from itertools import combinations, product
from math import log2


SIGNALS = tuple(sorted((a, sign * b) for a, b, sign in
                       product((1, 3), (1, 3), (-1, 1))))


def intensity(x: tuple[int, int], row: int) -> int:
    a, b = x
    return (a * a, b * b, (a + b) ** 2, (a - b) ** 2)[row]


CODE = tuple(tuple(intensity(x, j) for j in range(4)) for x in SIGNALS)


def partitions(ids: tuple[int, ...], row: int):
    groups = defaultdict(list)
    for s in ids:
        groups[CODE[s][row]].append(s)
    return tuple(tuple(v) for _, v in sorted(groups.items()))


@lru_cache(None)
def exact_adaptive_depth(ids: tuple[int, ...]) -> int:
    """Independent full minimax decision-tree recursion; allows repeated rows."""
    if len(ids) <= 1:
        return 0
    choices = []
    for j in range(4):
        parts = partitions(ids, j)
        if len(parts) <= 1:
            continue
        choices.append(1 + max(exact_adaptive_depth(part) for part in parts))
    return min(choices) if choices else 10**9


def explicit_hard_outcomes():
    """Independent necessary-condition attack on all adaptive two-row policies."""
    witnesses = {}
    for first in range(4):
        by_value = defaultdict(list)
        for s in range(8):
            by_value[CODE[s][first]].append(s)
        bad = []
        for value, ids in by_value.items():
            if all(
                len({CODE[s][second] for s in ids}) < len(ids)
                for second in range(4)
            ):
                bad.append((value, ids))
        assert bad, f"first row {first} permits a universal second query"
        witnesses[first] = bad[0][0]
    return witnesses


def hamming(a, b):
    return sum(x != y for x, y in zip(a, b))


def product_code(B: int):
    for blocks in product(range(8), repeat=B):
        yield tuple(value for s in blocks for value in CODE[s])


def run():
    assert len(SIGNALS) == len(CODE) == 8
    assert len(set(CODE)) == 8
    triples = []
    for cols in combinations(range(4), 3):
        seen = {tuple(code[i] for i in cols) for code in CODE}
        assert len(seen) == 8
        triples.append(cols)
    assert len(triples) == 4
    first_bad = explicit_hard_outcomes()
    assert first_bad == {0: 1, 1: 1, 2: 4, 3: 4}
    assert exact_adaptive_depth(tuple(range(8))) == 3
    assert all(
        len({(CODE[s][j], CODE[s][k]) for s in range(8)}) < 8
        for j in range(4) for k in range(4)
    )
    min_distance = min(hamming(c, d) for c, d in combinations(CODE, 2))
    assert min_distance == 2
    multi = tuple(product_code(2))
    assert len(multi) == 64 and len(set(multi)) == 64
    assert min(hamming(c, d) for c, d in combinations(multi, 2)) == 2
    # A product law supported on a finite code with no axis-adjacent pairs
    # must be a point mass (otherwise its rectangular support contains an
    # axis-adjacent pair). The all-B entropy conclusion then follows on paper.
    # Negative: an unrestricted extra *legal real* row can do much better.
    unrestricted = tuple((a + 4*b)**2 for a, b in SIGNALS)
    assert len(set(unrestricted)) == 8
    # Negative: a code with one row copied cannot retain all triple decoders.
    bad_code = tuple((c[0], c[1], c[2], c[2]) for c in CODE)
    assert any(
        len({tuple(c[i] for i in cols) for c in bad_code}) < 8
        for cols in combinations(range(4), 3)
    )
    import json
    report = {
        "schema": "nightfall.phase-block-route1-exact.v1",
        "signals": [list(x) for x in SIGNALS],
        "code": [list(c) for c in CODE],
        "triple_decoders": [list(x) for x in triples],
        "adaptive_minimax_depth_fixed_four_rows": 3,
        "first_reading_hard_outcomes": {str(k): v for k, v in first_bad.items()},
        "one_block_min_hamming": min_distance,
        "two_block_codewords": len(multi),
        "two_block_min_hamming": 2,
        "one_block_uniform_entropy_bits": int(log2(8)),
        "two_block_uniform_entropy_bits": int(log2(64)),
        "extra_unrestricted_row_one_query_separates": True,
        "wyner_all_B_proof": "paper_rectangle_support_only_not_numerical_optimization",
        "quantum_to_block_degree": "paper_Beals_et_al_plus_locality_not_end_to_end_Lean",
        "independent_source_review": False,
        "mathematical_theorem_kernel_checked": False,
    }
    print(json.dumps(report, sort_keys=True, separators=(",", ":")))


if __name__ == "__main__":
    run()

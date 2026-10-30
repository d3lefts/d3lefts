#!/usr/bin/env python3
"""Exact audit of PR #243's 3x5 code and an INVALID 4x7 trial.

The pinned CSV has all 729 phase words and every four-query output;
it is a negative control, not a valid compressed decoder. Stdlib only.
"""
import csv
import hashlib
from collections import Counter
from itertools import product
from pathlib import Path

H = (1, 6, 7)
ORIGINAL_3x5 = ((14, 12, 15, 3, 7),
                (15, 4, 9, 6, 8),
                (5, 5, 3, 14, 6))
TRIAL_4x7 = ((0, 8, 15, 4, 0, 15, 1),
             (12, 10, 5, 8, 12, 14, 12),
             (5, 6, 14, 0, 6, 15, 10),
             (6, 5, 1, 1, 4, 0, 6))
CSV_SHA256 = "472fc358afd0e9477c493dc47c75bbb6aecce79f09df2f7851d625ae22fd8397"
CSV_PATH = Path(__file__).with_name("F16_4x7_invalid_163.csv")

def mul(a, b):
    out = 0
    while b:
        if b & 1:
            out ^= a
        b >>= 1
        a <<= 1
        if a & 16:
            a ^= 19
    return out

def cube(a):
    return mul(mul(a, a), a)

def encode(A, phases):
    v = (1,) + tuple(phases)
    return tuple(cube(xor_sum(mul(c, x) for c, x in zip(row, v))) for row in A)

def xor_sum(seq):
    result = 0
    for value in seq:
        result ^= value
    return result

def test():
    orig = {encode(ORIGINAL_3x5, p) for p in product(H, repeat=4)}
    assert len(orig) == 81, "source 3x5 gadget failed"
    table = CSV_PATH.read_bytes()
    assert hashlib.sha256(table).hexdigest() == CSV_SHA256, "frozen full table was modified"
    with CSV_PATH.open(newline="", encoding="utf-8") as source:
        reader = csv.reader(source)
        assert next(reader) == [
            "phase1","phase2","phase3","phase4","phase5","phase6",
            "cube1","cube2","cube3","cube4"
        ]
        rows = [tuple(map(int, row)) for row in reader]
    assert len(rows) == 729
    outputs = []
    for i, phases in enumerate(product(H, repeat=6)):
        target = phases + encode(TRIAL_4x7, phases)
        assert rows[i] == target, f"discrepancy at phase word {i}"
        outputs.append(target[6:])
    bins = Counter(outputs)
    collisions = sum(n * (n - 1) // 2 for n in bins.values())
    classes = Counter(bins.values())
    assert collisions == 163 and len(bins) == 579
    assert classes == {1:442, 2:124, 3:13}, classes
    # Negative control: a one-byte perturbation is detected by the digest.
    altered = bytearray(table)
    altered[-2] ^= 1
    assert hashlib.sha256(altered).hexdigest() != CSV_SHA256
    # Negative control: an actual code collision exists; never report success.
    seen = {}
    smallest_collision = None
    for row in rows:
        key = row[6:]
        if key in seen:
            smallest_collision = (seen[key], row[:6], key)
            break
        seen[key] = row[:6]
    assert smallest_collision is not None
    print({
        "source_PR243_3x5_outputs": len(orig),
        "trial_4x7_input_states": 729,
        "trial_4x7_distinct_outputs": len(bins),
        "trial_4x7_collision_pairs": collisions,
        "trial_4x7_classes": dict(classes),
        "csv_sha256": CSV_SHA256,
        "smallest_in_enumeration_collision": smallest_collision,
        "status": "FAIL — 4x7 matrix not injective",
    })

if __name__ == "__main__":
    test()

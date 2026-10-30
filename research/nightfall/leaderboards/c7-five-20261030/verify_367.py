#!/usr/bin/env python3
"""NIGHTFALL independent integer-only replay of Polak--Schrijver C7^5 = 367.

The 327-word core is reconstructed from their published Section 3 shift and
discretization. The appended 40-word completion was obtained with an exact
integer-independent-set search. This is an incumbent reproduction, NOT 368.
"""
from itertools import combinations, product
from hashlib import sha256
from pathlib import Path
import argparse

N = 382
SHIFTS = (40, 123, 40, 123, 40)
POWERS = tuple(pow(7, i, N) for i in range(5))
APPEND = """
00521 01005 02533 03565 04052 04365 04624 04660 05046 05225
10534 14246 15435 22524 24615 24635 24651 32046 34043 36525
40040 41246 42530 43514 45641 50531 51456 52400 52563 53050
53142 53320 53412 56340 61505 62425 64154 64246 65105 66025
""".split()


def confusable(a, b):
    return all((int(x) - int(y)) % 7 in (0, 1, 6) for x, y in zip(a, b))


def check_code(words):
    assert len(set(words)) == len(words), "duplicate codeword"
    for a, b in combinations(words, 2):
        assert not confusable(a, b), (a, b)
    return len(words) * (len(words) - 1) // 2


def source_and_core():
    source = [
        tuple((t * p + d) % N for p, d in zip(POWERS, SHIFTS))
        for t in range(N)
    ]
    rounded = [
        "".join(str(2 * z // 109) for z in row)
        for row in source
    ]
    assert len(set(rounded)) == 382
    bad = set()
    for i, j in combinations(range(382), 2):
        if confusable(rounded[i], rounded[j]):
            bad.add(i)
            bad.add(j)
    core = {rounded[j] for j in range(382) if j not in bad}
    assert len(core) == 327, len(core)
    check_code(sorted(core))
    return rounded, core


def neighbors(word):
    return {
        "".join(str((int(x) + d) % 7) for x, d in zip(word, delta))
        for delta in product((-1, 0, 1), repeat=5)
    }


def audit(write=None):
    rounded, core = source_and_core()
    occupied = set().union(*(neighbors(word) for word in core))
    free = {"".join(p) for p in product("0123456", repeat=5)} - occupied
    assert len(free) == 71, len(free)
    edges = sum(confusable(a, b) for a, b in combinations(sorted(free), 2))
    assert edges == 85, edges
    assert len(APPEND) == 40 and set(APPEND) <= free
    result = sorted(core | set(APPEND))
    assert len(result) == 367
    comparisons = check_code(result)
    assert comparisons == 67161
    blob = ("\n".join(result) + "\n").encode()
    digest = sha256(blob).hexdigest()
    assert digest == "45e55b09cc3fdcd6cd916a44e7f51586adf5e7d4162bcd55206dc164d6fd2123"
    # Adversarial controls: duplicate and deliberately conflicting word.
    try:
        check_code(result + [result[0]])
    except AssertionError:
        pass
    else:
        raise AssertionError("duplicate mutation not detected")
    mutant = result.copy()
    mutant[1] = result[0][:4] + str((int(result[0][4]) + 1) % 7)
    try:
        check_code(mutant)
    except AssertionError:
        pass
    else:
        raise AssertionError("conflict mutation not detected")
    if write:
        Path(write).write_bytes(blob)
    print("PASS published 327 core / 71 candidate complement / 85 edges")
    print("PASS 40-word completion; 367 distinct words; 67161 exact pair tests")
    print("SHA256", digest)
    print("NO RECORD: published incumbent is 367; required improvement is 368")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--write", default=None, help="optional exact 367-line text output")
    audit(parser.parse_args().write)

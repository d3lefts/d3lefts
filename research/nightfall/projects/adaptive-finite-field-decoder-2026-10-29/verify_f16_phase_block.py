#!/usr/bin/env python3
"""Independent exact audit of NIGHTFALL's F16/F4 three-query gadget.

This checker uses polynomial long division, unlike PhaseBlock.lean's shift/XOR
multiplication. The finite example cannot certify the transfer theorem, priority,
or any claim outside the stated cube-power oracle.
"""
from itertools import product
import hashlib
import json
import random

POLY = 0b10011  # z^4 + z + 1, irreducible over F2
H = (1, 6, 7)
A = ((14, 12, 15, 3, 7),
     (15, 4, 9, 6, 8),
     (5, 5, 3, 14, 6))


def gf_mul(a, b):
    unreduced = 0
    for j in range(4):
        for i in range(4):
            if ((a >> i) & 1) and ((b >> j) & 1):
                unreduced ^= 1 << (i + j)
    for degree in range(6, 3, -1):
        if (unreduced >> degree) & 1:
            unreduced ^= POLY << (degree - 4)
    return unreduced


def cube(x):
    return gf_mul(gf_mul(x, x), x)


def inner(row, phases):
    out = 0
    for c, x in zip(row, phases, strict=True):
        out ^= gf_mul(c, x)
    return out


def code(relative_phases):
    phases = (1,) + tuple(relative_phases)
    return tuple(cube(inner(row, phases)) for row in A)


def audit():
    assert [cube(h) for h in H] == [1, 1, 1]
    assert set(x for x in range(16) if cube(x) == 1) == set(H)
    assert len({cube(x) for x in range(16)}) == 6
    for x in range(1, 16):
        assert any(gf_mul(x, y) == 1 for y in range(1, 16))
    lookup = {}
    for eta in product(H, repeat=4):
        out = code(eta)
        assert out not in lookup, f"collision: {eta} and {lookup[out]}"
        lookup[out] = eta
    assert len(lookup) == 81
    # Root classes and reconstruction for arbitrary signal coordinates.
    roots = {y: tuple(x for x in range(16) if cube(x) == y)
             for y in set(cube(x) for x in range(16))}
    assert all(len(roots[cube(x)]) == 3 for x in range(1, 16))
    one_phase = {cube(1 ^ gf_mul(2, e)): e for e in H}
    assert len(one_phase) == 3
    rng = random.Random(17029)
    trials = 10000
    for _ in range(trials):
        k = rng.choice([2, 3, 4, 5, 6, 8, 12, 17, 25])
        signal = [rng.randrange(16) for _ in range(k)]
        support = [j for j, x in enumerate(signal) if x != 0]
        if not support:
            continue
        reps = {j: roots[cube(signal[j])][0] for j in support}
        anchor = support[0]
        a = next(h for h in H if gf_mul(h, reps[anchor]) == signal[anchor])
        result = [0] * k
        result[anchor] = reps[anchor]
        other = support[1:]
        for start in range(0, len(other), 4):
            block = other[start:start + 4]
            if len(block) == 4:
                rows = A
                # Actual measurement: coefficients are row[c]/u[c], including anchor.
                observations = []
                for row in rows:
                    row_sum = gf_mul(row[0], a)
                    for j, c in zip(block, row[1:], strict=True):
                        rootphase = next(h for h in H if gf_mul(h, reps[j]) == signal[j])
                        row_sum ^= gf_mul(c, rootphase)
                    observations.append(cube(row_sum))
                eta = lookup[tuple(observations)]
                for j, e in zip(block, eta, strict=True):
                    result[j] = gf_mul(e, reps[j])
            else:
                for j in block:
                    rootphase = next(h for h in H if gf_mul(h, reps[j]) == signal[j])
                    mixed = cube(a ^ gf_mul(2, rootphase))
                    e = one_phase[mixed]
                    result[j] = gf_mul(e, reps[j])
        assert all(gf_mul(a, y) == x for x, y in zip(signal, result))
    receipt = {
        "status": "PASS",
        "field": "F2[z]/(z^4+z+1)",
        "subfield_units": H,
        "oracle_exponent": 3,
        "matrix": A,
        "distinct_relative_phase_vectors": len(lookup),
        "random_signal_reconstruction_trials": trials,
        "method": "independent polynomial-multiplication exact replay",
        "scope": "finite block and randomized end-to-end decoding, not a global proof or priority determination",
    }
    raw = json.dumps(receipt, sort_keys=True).encode()
    print(json.dumps(receipt, indent=2))
    print("receipt_sha256:", hashlib.sha256(raw).hexdigest())


if __name__ == "__main__":
    audit()

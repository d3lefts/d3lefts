#!/usr/bin/env python3
"""Independent exact exhaustion of F16/F4 two-query three-phase matrices.

Distinct from the C++ verifier: Russian-peasant GF16 multiplication, arbitrary
precision collision masks, Python's combinatorial iterator. Stdlib only.
This rules out a factorized two-block 4x7 candidate, NOT all 4x7 matrices.
"""
from itertools import product

H = (1, 6, 7)
POLY = 0x13
STATES = [(1, a, b, c) for a, b, c in product(H, repeat=3)]
ROW_COUNT = (16**4 - 1) // 15
PAIR_COUNT = ROW_COUNT * (ROW_COUNT + 1) // 2

def mul(a, b):
    z = 0
    while b:
        if b & 1:
            z ^= a
        b >>= 1
        a <<= 1
        if a & 16:
            a ^= POLY
    return z

def cube(a):
    return mul(mul(a, a), a)

def canonical_rows():
    for row in product(range(16), repeat=4):
        if next((x for x in row if x), None) == 1:
            yield row

def collision_mask(row):
    codes = [cube(mul(row[0], v[0]) ^ mul(row[1], v[1]) ^
                  mul(row[2], v[2]) ^ mul(row[3], v[3]))
             for v in STATES]
    mask = 0
    bit = 0
    for i in range(27):
        for j in range(i + 1, 27):
            if codes[i] == codes[j]:
                mask |= 1 << bit
            bit += 1
    assert bit == 351
    return mask

def verify():
    assert {x for x in range(16) if cube(x) == 1} == set(H)
    assert len({cube(x) for x in range(16)}) == 6
    rows = [(r, collision_mask(r)) for r in canonical_rows()]
    assert len(rows) == ROW_COUNT == 4369
    single_min = min(mask.bit_count() for _, mask in rows)
    best, witness, checked = 352, None, 0
    for i, (a, mask_a) in enumerate(rows):
        for b, mask_b in rows[i:]:
            cost = (mask_a & mask_b).bit_count()
            checked += 1
            if cost < best:
                best, witness = cost, (a, b)
    assert checked == PAIR_COUNT == 9546265
    assert single_min == 51
    assert best == 4, (best, witness)
    assert witness == ((0, 1, 2, 3), (1, 2, 3, 9)), witness
    # Any nonzero row can be multiplied by a nonzero F16 scalar; this
    # multiplies all cube outputs by the same nonzero scalar cube and
    # therefore preserves its collision partition. Every nonzero row
    # consequently has one of the above unique normal forms. Zero rows
    # yield >=51 collisions when paired with any other row.
    # Negative control: the certified near-best pair is still NOT injective.
    assert (collision_mask(witness[0]) &
            collision_mask(witness[1])).bit_count() == 4
    print(f"PASS rows={len(rows)} unordered_pairs={checked} "
          f"single_min={single_min} joint_min={best} "
          f"witness={witness} (INVALID 2-query gadget)")
    return best

if __name__ == "__main__":
    verify()

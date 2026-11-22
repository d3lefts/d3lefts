#!/usr/bin/env python3
"""Exact GF(2) tensor subcube four-distinct XOR fiber stratification.

The cost <=2 set includes zero, all rows and XORs of two rows.
No asymptotic theorem can be inferred from finite enumeration.
"""
from collections import Counter
from itertools import combinations

EXPECTED = {
    1: (3, 4, 0, 0, 0),
    2: (9, 16, 126, 9, 0),
    3: (27, 190, 17550, 81, 72),
    4: (81, 2350, 1663740, 486, 101),
}

def rows(level):
    r = [1]
    width = 1
    for _ in range(level):
        r = r + [x << width for x in r] + [x | (x << width) for x in r]
        width *= 2
    assert len(set(r)) == 3**level
    return r

def stats(level):
    r = rows(level)
    cheap = set(r)
    cheap.add(0)
    cheap.update(a ^ b for a,b in combinations(r, 2))
    counts = Counter(a ^ b ^ c ^ d for a,b,c,d in combinations(r, 4))
    small = max((v for k,v in counts.items() if k in cheap), default=0)
    hard = max((v for k,v in counts.items() if k not in cheap), default=0)
    # Check a distinct-pair witness showing raw A+A fibers grow quickly.
    a,b = r[:2]
    z = a ^ b
    assert len({(a ^ t,b ^ t) for t in r}) == len(r)
    assert all(((a ^ t) in cheap and (b ^ t) in cheap)
               for t in r)
    raw = sum(1 for t in cheap if (z^t) in cheap)
    assert raw >= 3**level
    return (len(r), len(cheap), sum(counts.values()), small, hard), raw

def main():
    for level in range(1,5):
        actual, raw = stats(level)
        assert actual == EXPECTED[level], (level, actual)
        print("PASS L=%d rows=%d cost<=2=%d 4-sets=%d "
              "max(cheap)=%d max(hard)=%d raw-pair-fiber=%d" %
              (level, *actual, raw))
    print("Finite checks only; no polynomial bound for all levels.")

if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""Independent adversarial checker: direct pair sums and exhaustive deletions.

No import of matching builder. Also checks the exceptional 2a collision.
"""
import hashlib
import itertools
import json
import sys


def valid(D, v):
    seen = set()
    for i in range(len(D)):
        for j in range(i, len(D)):
            s = (D[i] + D[j]) % v
            if s in seen:
                return False
            seen.add(s)
    return True


def min_deletions(D, a, v):
    for n in range(len(D) + 1):
        for removed in itertools.combinations(D, n):
            rest = [x for x in D if x not in removed]
            if valid(rest + [a], v):
                return n
    raise AssertionError('no repair')


def check(cert):
    h = hashlib.sha256()
    count = 0
    for v in range(3, 16):
        for mask in range(1, 1 << v):
            if mask.bit_count() > 6:
                continue
            D = [i for i in range(v) if mask & (1 << i)]
            if not valid(D, v):
                continue
            for a in range(v):
                if a in D:
                    continue
                line = f'{v}|{",".join(map(str,D))}|{a}|{min_deletions(D,a,v)}\n'
                h.update(line.encode())
                count += 1
    assert count == cert['cases'] == 20668
    assert h.hexdigest() == cert['canonical_rows_sha256']
    # Negative control: v=13, D={0,1,3,9}, a=7.
    # Triple-only matching gives 1, but 2a=0+1 forces 2 deletions.
    assert min_deletions([0, 1, 3, 9], 7, 13) == 2
    # Even-order group: 2a=2x may require removing a single x.
    assert min_deletions([0, 1], 2, 4) == 1
    print('PASS', count, 'independent exhaustive repair checks; SHA256', h.hexdigest())


if __name__ == '__main__':
    with open(sys.argv[1], encoding='utf8') as f:
        check(json.load(f))

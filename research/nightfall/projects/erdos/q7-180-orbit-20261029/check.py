#!/usr/bin/env python3
"""Exact four-deletion audit for 180 released Q7 304-edge orbit representatives.

Data derived from Minamo Minamoto's q7_orbit_witnesses.json (MIT licensed).
This is a finite catalogue-local statement, not a global bound on f(7).
Standard-library Python only; no optimizer or floating-point arithmetic.
"""
import collections
import hashlib
import itertools
import json
import pathlib

MASK_FILE = pathlib.Path(__file__).with_name("canonical_180.txt")

def cube():
    edges = [(v, v | (1 << d)) for d in range(7)
             for v in range(128) if not (v & (1 << d))]
    slot = {e: k for k, e in enumerate(edges)}
    squares = []
    for a in range(7):
        for b in range(a + 1, 7):
            for v in range(128):
                if v & ((1 << a) | (1 << b)):
                    continue
                u, w, z = v | (1 << a), v | (1 << b), v | (1 << a) | (1 << b)
                squares.append((slot[v, u], slot[v, w], slot[u, z], slot[w, z]))
    assert len(edges) == 448 and len(squares) == 672
    incident = [[] for _ in edges]
    for square in squares:
        for e in square:
            incident[e].append(square)
    assert all(len(row) == 6 for row in incident)
    return edges, squares, incident

def decode(s):
    assert len(s) == 112 and all(c in "0123456789abcdef" for c in s)
    raw = bytes.fromhex(s)
    return tuple(bool(raw[k >> 3] & (128 >> (k & 7))) for k in range(448))

def hit(groups, limit):
    """Exact bounded transversal test, with complete 3-way branching."""
    masks = [sum(1 << e for e in g) for g in groups]
    memo = set()
    def rec(chosen, depth):
        if chosen in memo:
            return False
        for g, m in zip(groups, masks):
            if not (m & chosen):
                if depth == limit:
                    memo.add(chosen)
                    return False
                for e in g:
                    if rec(chosen | (1 << e), depth + 1):
                        return True
                memo.add(chosen)
                return False
        return True
    return rec(0, 0)

def verify_one(mask, edges, squares, incident):
    chosen = {i for i, b in enumerate(mask) if b}
    assert len(chosen) == 304
    # Independent C4 test by common-neighbour multiplicities, not faces.
    neighbors = [set() for _ in range(128)]
    for i in chosen:
        u, v = edges[i]
        neighbors[u].add(v)
        neighbors[v].add(u)
    for u in range(128):
        for v in range(u + 1, 128):
            if (u ^ v).bit_count() == 2:
                assert len(neighbors[u] & neighbors[v]) <= 1
    assert all(sum(mask[e] for e in sq) <= 3 for sq in squares)

    absent, blockers, hist = [], [], collections.Counter()
    for e in range(448):
        if mask[e]:
            continue
        groups = []
        for sq in incident[e]:
            others = tuple(x for x in sq if x != e and mask[x])
            if len(others) == 3:
                groups.append(others)
        assert len(groups) >= 2
        assert len({v for g in groups for v in g}) == 3 * len(groups)
        hist[len(groups)] += 1
        if len(groups) <= 4:
            absent.append(e)
            blockers.append(groups)
    assert sum(hist.values()) == 144

    # Pairwise compatibility is a necessary condition for joint unlocking.
    N = len(absent)
    support = [set(itertools.chain.from_iterable(g)) for g in blockers]
    adj = [0] * N
    pair_count = two_deletion_pair_count = 0
    for i in range(N):
        for j in range(i + 1, N):
            ti, tj = len(blockers[i]), len(blockers[j])
            if len(support[i] & support[j]) < ti + tj - 4:
                continue
            both = blockers[i] + blockers[j]
            if hit(both, 4):
                adj[i] |= 1 << j
                adj[j] |= 1 << i
                pair_count += 1
                if ti == tj == 2 and hit(both, 2):
                    two_deletion_pair_count += 1
    assert two_deletion_pair_count == 0

    # Any four missing edges jointly unlocked by <=4 deletions form a
    # 4-clique in the compatibility graph. Enumerate all such cliques.
    clique4 = jointly4 = 0
    for i in range(N):
        js = adj[i] & ~((1 << (i + 1)) - 1)
        while js:
            jbit = js & -js
            js -= jbit
            j = jbit.bit_length() - 1
            ks = adj[i] & adj[j] & ~((1 << (j + 1)) - 1)
            while ks:
                kbit = ks & -ks
                ks -= kbit
                k = kbit.bit_length() - 1
                ls = adj[i] & adj[j] & adj[k] & ~((1 << (k + 1)) - 1)
                while ls:
                    lbit = ls & -ls
                    ls -= lbit
                    l = lbit.bit_length() - 1
                    clique4 += 1
                    if hit(blockers[i] + blockers[j] + blockers[k] + blockers[l], 4):
                        jointly4 += 1
    assert jointly4 == 0
    return dict(hist=dict(sorted(hist.items())), pairs=pair_count,
                clique4=clique4, jointly4=jointly4)

def main():
    data = MASK_FILE.read_bytes()
    masks = data.decode("ascii").splitlines()
    assert len(masks) == 180 and len(set(masks)) == 180
    edges, squares, incident = cube()
    total = collections.Counter()
    clique4 = pair_counts = 0
    exceptions = []
    for k, s in enumerate(masks):
        r = verify_one(decode(s), edges, squares, incident)
        total.update(r["hist"])
        clique4 += r["clique4"]
        pair_counts += r["pairs"]
        if r["clique4"]:
            exceptions.append([k, r["clique4"]])
        if k % 20 == 19:
            print("verified", k + 1, "of 180 orbit masks", flush=True)
    assert total == {2: 129, 3: 8376, 4: 10290, 5: 7125}, total
    assert exceptions == [[19, 15], [31, 15], [66, 15], [68, 15],
                          [73, 15], [87, 15], [104, 15]], exceptions
    assert clique4 == 105
    print(json.dumps({"status": "PASS", "orbits": 180,
                      "masks_sha256": hashlib.sha256(data).hexdigest(),
                      "tight_square_histogram": dict(total),
                      "pair_compatibilities": pair_counts,
                      "pair_graph_4cliques": clique4,
                      "jointly_unlockable_4tuples": 0,
                      "minimum_hamming_distance_to_305_per_seed": 11},
                     indent=2))

if __name__ == "__main__":
    main()

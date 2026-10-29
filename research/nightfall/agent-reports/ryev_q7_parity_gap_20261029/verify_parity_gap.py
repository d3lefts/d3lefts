#!/usr/bin/env python3
"""RYEV exact cube-square syndrome replay; Python standard library only.
This checks finite controls, not global Q7 <=304 and not a 305 solution.
"""
from collections import Counter
from itertools import combinations
from random import Random
import json


def cube(n):
    edges = [(v, v ^ (1 << d)) for d in range(n)
             for v in range(1 << n) if not ((v >> d) & 1)]
    ix = {tuple(sorted(e)): i for i, e in enumerate(edges)}
    squares = []
    for a, b in combinations(range(n), 2):
        for v in range(1 << n):
            if v & ((1 << a) | (1 << b)):
                continue
            x, y, z, w = v, v ^ (1 << a), v ^ (1 << b), v ^ (1 << a) ^ (1 << b)
            sides = [(x, y), (x, z), (y, w), (z, w)]
            squares.append(tuple(sorted(ix[tuple(sorted(e))] for e in sides)))
    assert len(edges) == n * 2 ** (n - 1)
    assert len(squares) == n * (n - 1) // 2 * 2 ** (n - 2)
    assert len(set(squares)) == len(squares)
    return edges, squares


def even_squares(selected, squares):
    return tuple(i for i, sq in enumerate(squares)
                 if (sum(e in selected for e in sq) & 1) == 0)


def check_q4():
    edges, squares = cube(4)
    signatures = [sum(1 << j for j, sq in enumerate(squares) if i in sq)
                  for i in range(len(edges))]
    basis = {}
    for z in signatures:
        while z:
            lead = z.bit_length()
            if lead not in basis:
                basis[lead] = z
                break
            z ^= basis[lead]
    assert len(basis) == 17
    words = [0]
    for b in basis.values():
        words += [w ^ b for w in words]
    hist = Counter(w.bit_count() for w in words)
    assert len(words) == len(set(words)) == 131072
    assert hist[0] == 1 and hist[1] == hist[2] == 0
    assert hist[3] == len(set(signatures)) == 32
    assert {w for w in words if w.bit_count() == 3} == set(signatures)
    assert hist[4] == 102
    return {"edges": 32, "squares": 24, "rank": 17, "syndromes": 131072,
            "weight3": hist[3], "weight4": hist[4]}


def check_q7():
    edges, squares = cube(7)
    assert len(edges) == 448 and len(squares) == 672
    incidence = [[] for _ in edges]
    for q, square in enumerate(squares):
        for e in square:
            incidence[e].append(q)
    assert all(len(s) == 6 for s in incidence)
    sig = [sum(1 << q for q in inc) for inc in incidence]
    assert len(set(sig)) == 448
    spectrum = Counter((sig[i] ^ sig[j]).bit_count()
                       for i in range(448) for j in range(i))
    assert dict(spectrum) == {10: 4032, 12: 96096}, spectrum

    # Canonical fully-frustrated reference: edge of direction d selected
    # precisely if the lower d vertex bits have odd parity.
    base = {i for i, (u, v) in enumerate(edges)
            if ((u & ((u ^ v) - 1)).bit_count() & 1)}
    assert not even_squares(base, squares)

    rng = Random(1729)
    for _ in range(128):
        chosen = {v for v in range(128) if rng.randrange(2)}
        cut = {i for i, (u, v) in enumerate(edges) if (u in chosen) != (v in chosen)}
        assert not even_squares(base ^ cut, squares)

    adjacent = [[] for _ in range(128)]
    for i, (u, v) in enumerate(edges):
        adjacent[u].append(i)
        adjacent[v].append(i)
    H = set(base)
    turns = 0
    while True:
        low = [v for v in range(128) if sum(e in H for e in adjacent[v]) <= 3]
        if not low:
            break
        vertex = rng.choice(low)
        H.symmetric_difference_update(adjacent[vertex])
        turns += 1
        assert turns <= 448
    deg = [sum(e in H for e in adjacent[v]) for v in range(128)]
    assert min(deg) >= 4
    assert not even_squares(H, squares)
    assert all(sum(e in H for e in sq) in (1, 3) for sq in squares)
    missing = [i for i in range(448) if i not in H]
    assert all(any(sum(j in H for j in squares[q]) == 3 for q in incidence[i])
               for i in missing), "A switched-stable odd graph had an addable edge."
    bad = H | {missing[0]}
    assert even_squares(bad, squares) == tuple(incidence[missing[0]])
    assert any(sum(j in bad for j in sq) == 4 for sq in squares)
    removed = H - {next(iter(H))}
    assert len(even_squares(removed, squares)) == 6
    assert all(sum(e in removed for e in sq) < 4 for sq in squares)

    return {"edges": 448, "squares": 672, "minimal_syndromes": 448,
            "two_edge_weight_spectrum": dict(sorted(spectrum.items())),
            "gauge_controls": 128, "odd_switch_graph_edges": len(H),
            "greedy_star_switches": turns, "minimum_degree": min(deg),
            "blocked_missing_edges": len(missing),
            "invalid_addition_rejected": True}


if __name__ == "__main__":
    result = {"schema": "nightfall-ryev-q7-parity-syndrome-v1",
              "q4": check_q4(), "q7": check_q7()}
    print(json.dumps(result, sort_keys=True, indent=2))

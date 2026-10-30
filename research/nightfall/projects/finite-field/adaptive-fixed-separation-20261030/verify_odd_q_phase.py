#!/usr/bin/env python3
"""Independent exact transfer audit for square-power K-linear sensing over F_(p^2).

Field F_(p^2)=F_p[t]/(t*t-n), for a quadratic nonresidue n.
Proof scope: finite exhaustive evidence (not all-k proof, priority or external review).
"""
from collections import Counter
from itertools import product


def run(p, n, k):
    assert p % 2 == 1
    assert pow(n, (p - 1) // 2, p) == p - 1
    q = p * p

    def mul(a, b):
        u, v = a % p, a // p
        w, z = b % p, b // p
        return (u * w + n * v * z) % p + p * ((u * z + v * w) % p)

    table = [[mul(a, b) for b in range(q)] for a in range(q)]
    squares = [table[a][a] for a in range(q)]
    roots = {y: min(a for a in range(q) if squares[a] == y) for y in set(squares)}
    inverses = {a: next(b for b in range(1, q) if table[a][b] == 1)
                for a in range(1, q)}
    add = lambda a, b: (a % p + b % p) % p + p * ((a // p + b // p) % p)
    hgroup = (1, p - 1)
    lookups = {}

    for b in (1, 2):
        lookup = {}
        for phases in product(hgroup, repeat=b):
            v = 0
            for j, e in enumerate(phases):
                v = add(v, (1 + e) % p * (p ** j))
            y = squares[v]
            assert y not in lookup, (p, b, phases, lookup.get(y))
            lookup[y] = phases
        assert len(lookup) == 2 ** b
        lookups[b] = lookup

    histogram = Counter()
    for x in product(range(q), repeat=k):
        outputs = [squares[a] for a in x]
        support = [j for j, y in enumerate(outputs) if y]
        recovered = [0] * k
        count = k
        if support:
            anchor = support[0]
            recovered[anchor] = roots[outputs[anchor]]
            for pos in range(0, len(support) - 1, 2):
                block = support[1 + pos: 3 + pos]
                anchor_coeff = sum(p ** j for j in range(len(block)))
                coeff = table[anchor_coeff][inverses[roots[outputs[anchor]]]]
                v = table[coeff][x[anchor]]
                for j, i in enumerate(block):
                    coeff = table[p ** j][inverses[roots[outputs[i]]]]
                    v = add(v, table[coeff][x[i]])
                phases = lookups[len(block)][squares[v]]
                for i, e in zip(block, phases, strict=True):
                    recovered[i] = table[e][roots[outputs[i]]]
                count += 1
            assert any(tuple(table[h][v] for v in recovered) == x
                       for h in hgroup), (p, k, x, recovered)
        else:
            assert recovered == [0] * k
        assert count == k + len(support) // 2
        histogram[count] += 1

    assert sum(histogram.values()) == q ** k
    print(f"PASS p={p}, Q={q}, k={k}, signals={q ** k}, "
          f"query_histogram={dict(sorted(histogram.items()))}")


if __name__ == "__main__":
    run(3, 2, 4)
    run(5, 2, 3)
    run(7, 3, 3)
    print("STATUS: exact finite transfer evidence only; all-dimensional proof separate")

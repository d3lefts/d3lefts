#!/usr/bin/env python3
"""Independent, decoder-free F9 transcript-fiber attack.

Rebuilds the same squared-linear oracle using integer-coded GF(9) arithmetic,
independently of verify_two_models.py's tuple representation and decoder.
Every row after the coordinate stage is a deterministic function solely of
the coordinate *squares*. For k<=5, exhaustively verifies the resulting
entire transcript identifies exactly one global +/- class, with zero,
one-point, sparse and full-support signals included.
This is a finite regression, NOT the Lean all-k theorem.
"""
from itertools import product


class Field9:
    def __init__(self, c0, c1):
        # alpha^2 = c0 + c1 alpha, both irreducible choices in F3.
        self.c0, self.c1 = c0, c1
        self.add = [[((a % 3 + b % 3) % 3) +
                     3 * ((a // 3 + b // 3) % 3)
                     for b in range(9)] for a in range(9)]
        self.mul = [[((a % 3 * (b % 3) + c0 * (a // 3) * (b // 3)) % 3) +
                     3 * (((a % 3) * (b // 3) +
                           (a // 3) * (b % 3) +
                           c1 * (a // 3) * (b // 3)) % 3)
                     for b in range(9)] for a in range(9)]
        self.sq = [self.mul[i][i] for i in range(9)]
        self.root = {s: next(v for v in range(9) if self.sq[v] == s)
                     for s in set(self.sq)}
        self.inv = {a: next(b for b in range(9) if self.mul[a][b] == 1)
                    for a in range(1, 9)}
        self.neg = [self.mul[2][a] for a in range(9)]
        assert len(self.root) == 5

    def transcript(self, x):
        k = len(x)
        squares = tuple(self.sq[v] for v in x)
        support = tuple(j for j in range(k) if squares[j] != 0)
        rows = []
        if support:
            anchor = support[0]
            root = self.root
            for off in range(1, len(support), 2):
                block = support[off:off+2]
                basis = (1, 3)[:len(block)]
                total = 0
                row = [0] * k
                for b in basis:
                    total = self.add[total][b]
                row[anchor] = self.mul[total][self.inv[root[squares[anchor]]]]
                for j, b in zip(block, basis):
                    row[j] = self.mul[b][self.inv[root[squares[j]]]]
                rows.append(tuple(row))
        # These rows depend only on squares, never the unknown x signs.
        tail = []
        for row in rows:
            dot = 0
            for a, b in zip(row, x):
                dot = self.add[dot][self.mul[a][b]]
            tail.append(self.sq[dot])
        return squares + tuple(tail), k + len(rows), tuple(rows)


def audit(field):
    total = 0
    for k in range(1, 6):
        fibers = {}
        max_queries = 0
        for x in product(range(9), repeat=k):
            transcript, queries, rows = field.transcript(x)
            assert queries <= k + k // 2, ("budget", k, queries)
            assert len(transcript) == queries
            assert len(rows) == queries - k
            assert field.transcript(tuple(field.neg[a] for a in x))[0] == transcript
            previous = fibers.setdefault(transcript, x)
            assert previous == x or tuple(field.neg[a] for a in previous) == x, (
                "transcript collision", k, previous, x)
            # Explicitly attack legality: the same square prefix must yield
            # identical query rows regardless of the actual sign choices.
            if k <= 4:
                y = tuple(field.neg[a] for a in x)
                assert field.transcript(y)[2] == rows
            max_queries = max(max_queries, queries)
            total += 1
        assert len(fibers) == (9**k + 1) // 2, ("orbit count", k, len(fibers))
        assert max_queries == k + k // 2 or k == 1
        print("GF9", field.c0, field.c1, "k", k,
              "all signals", 9**k, "sign orbits", len(fibers),
              "worst queries", max_queries, "bound", k + k//2)
    return total


def main():
    c = sum(audit(Field9(*poly)) for poly in ((2, 0), (1, 2)))
    assert c == 2 * sum(9**k for k in range(1, 6))
    print("PASS independent squared-oracle transcript-fiber audit:",
          c, "signals; no inequivalent collisions through k=5")
    print("NOT an all-k Lean proof or a scientific novelty certificate")


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""Independent finite GF(2) checker for cactus edge-oracle block decomposition.
No quantum simulator or Lean checker is run. All tests are exact finite algebra.
"""
from itertools import combinations


def rank(vectors):
    pivots = {}
    for x in vectors:
        v = x
        while v:
            p = v.bit_length() - 1
            if p not in pivots:
                pivots[p] = v
                break
            v ^= pivots[p]
    return len(pivots)


class Cactus:
    def __init__(self):
        self.vertices = 1
        self.edges = []
        self.blocks = []

    def cycle(self, at, length):
        assert 0 <= at < self.vertices and length >= 3
        vertices = [at] + list(range(self.vertices, self.vertices + length - 1))
        self.vertices += length - 1
        b = list(range(len(self.edges), len(self.edges) + length))
        self.edges.extend((vertices[i], vertices[(i + 1) % length]) for i in range(length))
        self.blocks.append(("cycle", b))
        return vertices[-1]

    def bridge(self, at):
        assert 0 <= at < self.vertices
        v = self.vertices
        self.vertices += 1
        b = [len(self.edges)]
        self.edges.append((at, v))
        self.blocks.append(("bridge", b))
        return v


def row(u, v):
    return (1 << u) ^ (1 << v)


def validate_case(name, cactus):
    rows = [row(u, v) for u, v in cactus.edges]
    E, V = len(rows), cactus.vertices
    assert E <= 14
    assert rank(rows) == V - 1  # constructed connected cactus
    cycle_indices = [set(block) for typ, block in cactus.blocks if typ == "cycle"]
    kernel_witnesses = 0
    for bits in range(1 << E):
        x = 0
        for j, r in enumerate(rows):
            if (bits >> j) & 1:
                x ^= r
        if x == 0:
            kernel_witnesses += 1
            support = {j for j in range(E) if bits >> j & 1}
            # Every zero sum must be a union of entire constituent cycles.
            assert all(not (support & block) or block <= support for block in cycle_indices)
            assert support == set().union(*(b for b in cycle_indices if b <= support))
    assert kernel_witnesses == (1 << len(cycle_indices))

    block_rank = 0
    for typ, ids in cactus.blocks:
        R = [rows[j] for j in ids]
        block_rank += rank(R)
        # Exact covering radius: BFS in the linear span, based on word length.
        dist = {0: 0}
        frontier = [0]
        for depth in range(1, len(R) + 1):
            nxt = []
            for x in frontier:
                for g in R:
                    y = x ^ g
                    if y not in dist:
                        dist[y] = depth
                        nxt.append(y)
            frontier = nxt
            if not frontier:
                break
        assert len(dist) == 1 << rank(R)
        radius = max(dist.values())
        assert radius == (len(R) // 2 if typ == "cycle" else 1)
        assert rank(R) == (len(R) - 1 if typ == "cycle" else 1)
    assert block_rank == V - 1

    # Theorem F mixed-alphabet representation, for several independent H values.
    # A short cycle becomes one large alphabet coordinate; a long cycle remains bits.
    # Coordinate independence is certified by full GF(2) rank, not Monte Carlo.
    marginal_checks = 0
    for H in (1, 2, 3, 4, 6):
        coords = []
        for typ, ids in cactus.blocks:
            if typ == "cycle" and len(ids) <= H:
                coords.append([rows[j] for j in ids[:-1]])  # one symbol with 2^(ell-1) values
            else:
                coords.extend([[rows[j]] for j in ids])
        for size in range(min(H, len(coords)) + 1):
            for chosen in combinations(coords, size):
                flat = [r for symbol in chosen for r in symbol]
                assert rank(flat) == len(flat), (name, H, size)
                marginal_checks += 1
    return {"name": name, "vertices": V, "edges": E,
            "cycles": len(cycle_indices), "dependencies": kernel_witnesses,
            "marginal_checks": marginal_checks}


def cases():
    a = Cactus(); a.cycle(0, 7); yield "cycle7", a
    a = Cactus(); a.cycle(0, 3); a.cycle(0, 4); yield "bouquet3_4", a
    a = Cactus(); v = a.cycle(0, 3); v = a.bridge(v); a.cycle(v, 5); yield "chain3_bridge5", a
    a = Cactus(); v = 0
    for _ in range(4):
        v = a.cycle(v, 3)
    yield "four_triangles", a
    a = Cactus(); v = 0
    for _ in range(8):
        v = a.bridge(v)
    yield "forest8", a
    a = Cactus(); v = a.cycle(0, 4)
    for _ in range(5):
        v = a.bridge(v)
    yield "lollipop4_5", a


if __name__ == "__main__":
    total = 0
    for name, cactus in cases():
        result = validate_case(name, cactus)
        total += result["marginal_checks"]
        print("CACTUS_EXACT_PASS", result)
    print("CACTUS_FINITE_PASS", "cases=6", "marginal_checks=" + str(total))

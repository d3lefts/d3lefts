#!/usr/bin/env python3
"""Independent finite audit of the exact affine-code product-rectangle theorem.

No Lean imports, external solver, symbolic reduction, or theorem source reuse.
Enumerates *all* linear subspaces and all nonempty coordinate rectangles for
F_2^3, F_2^4 and F_3^3; tests every affine coset intersecting each rectangle.
This is a finite regression check, never an all-dimensional proof.
"""
from itertools import product


def add(u, v, p):
    return tuple((a + b) % p for a, b in zip(u, v))


def extend_span(space, v, p):
    return frozenset(
        add(u, tuple((c * a) % p for a in v), p)
        for u in space for c in range(p)
    )


def all_subspaces(p, m):
    zero = (0,) * m
    words = list(product(range(p), repeat=m))
    queue = [frozenset([zero])]
    seen = set(queue)
    for space in queue:
        for v in words:
            if v not in space:
                nxt = extend_span(space, v, p)
                if nxt not in seen:
                    seen.add(nxt)
                    queue.append(nxt)
    return queue


def run_case(p, m):
    words = list(product(range(p), repeat=m))
    coord_subsets = [
        tuple(j for j in range(p) if mask & (1 << j))
        for mask in range(1, 1 << p)
    ]
    spaces = all_subspaces(p, m)
    tests = 0
    accepted = 0
    for space in spaces:
        free = {
            i for i in range(m)
            if tuple(int(j == i) for j in range(m)) in space
        }
        covered = set()
        cosets = []
        for shift in words:
            if shift not in covered:
                coset = frozenset(add(shift, u, p) for u in space)
                covered.update(coset)
                cosets.append(coset)
        assert covered == set(words)

        for coset in cosets:
            for coords in product(coord_subsets, repeat=m):
                rectangle = [
                    x for x in words
                    if all(x[i] in coords[i] for i in range(m))
                ]
                anchors = coset.intersection(rectangle)
                if not anchors:
                    continue
                x = next(iter(anchors))
                nonfree_fixed = all(
                    all(v == x[i] for v in coords[i])
                    for i in range(m) if i not in free
                )
                rectangle_contained = all(y in coset for y in rectangle)
                if nonfree_fixed != rectangle_contained:
                    raise AssertionError((p, m, space, coset, coords, x))
                tests += 1
                accepted += int(rectangle_contained)
    return len(spaces), tests, accepted


def main():
    expected = {
        (2, 3): (16, 743, 201),
        (2, 4): (67, 11691, 1721),
        (3, 3): (28, 29173, 1756),
    }
    for case, triple in expected.items():
        actual = run_case(*case)
        assert actual == triple, (case, actual, triple)
        print(f"PASS F_{case[0]}^{case[1]}:"
              f" {actual[0]} subspaces, {actual[1]} anchored rectangles,"
              f" {actual[2]} contained rectangles")
    # A deliberately invalid free-axis hypothesis MUST be rejected.
    diagonal = {(0, 0), (1, 1)}
    full_rectangle = set(product(range(2), repeat=2))
    assert not full_rectangle.issubset(diagonal)
    print("PASS negative control: diagonal code is not a full 2D rectangle")


if __name__ == "__main__":
    main()

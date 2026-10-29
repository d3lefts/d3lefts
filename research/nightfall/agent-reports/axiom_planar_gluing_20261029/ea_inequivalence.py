#!/usr/bin/env python3
"""Self-contained F27 graph-equivalence adversarial certificate.

Model: F27 = F3[T]/(T^3-T+1), i.e. T^3=T-1.  Affine equivalence
of planar graphs in F3^6 preserving the *graph component* (not the
entire union of two graphs in F3^9).

The graph's missing-difference subgroup forces any affine equivalence
of two planar graphs to preserve the vertical direction. This reduces
to extended-affine equivalence f -> B f(A^-1 x)+Lx+c, with A,B
invertible F3-linear, L F3-linear. Under such equivalence, the
normalized polarization family N_x=M_x M_x0^-1 transforms by
conjugation, so pairwise commutation is an invariant.

Result: all 676 ordered nonzero-x,z commutators vanish for f=x^2;
432 of 676 have F3-rank 2 for f=x^4 (the other 244 have rank 0).
The companion exhaustive codimension-two checker proves that exactly 26
seven-dimensional affine sections contain 29 of 53 marks. These 26
sections split into two intrinsic 13-section classes with pairwise
intersections 27 within a class and 5 across classes. Therefore every
ambient affine equivalence of full glued unions MUST preserve or exchange
the two planar components. Combining this recovery with the normalized
commutator obstruction rules out full ambient affine equivalence.
Scientific world-priority and independent human review remain open.
"""
import json
from collections import Counter


def vector(n):
    assert 0 <= n < 27
    return (n % 3, (n // 3) % 3, n // 9)


def encode(a):
    return sum((v % 3) * (3 ** i) for i, v in enumerate(a))


def plus(a, b):
    return encode((x + y for x, y in zip(vector(a), vector(b))))


def minus(a):
    return encode((-x for x in vector(a)))


def product(a, b):
    u, v = vector(a), vector(b)
    raw = [0] * 5
    for i, x in enumerate(u):
        for j, y in enumerate(v):
            raw[i + j] += x * y
    # T^3 = T-1: reduce degrees 4 and 3, including coefficient changes.
    for i in (4, 3):
        raw[i - 2] += raw[i]
        raw[i - 3] -= raw[i]
    return encode(raw[:3])


def power(a, exponent):
    result = 1
    while exponent:
        if exponent & 1:
            result = product(result, a)
        a = product(a, a)
        exponent >>= 1
    return result


def polar(a, b, exponent):
    """B_f(a,b)=f(a+b)-f(a)-f(b) over characteristic three."""
    return plus(plus(power(plus(a, b), exponent), minus(power(a, exponent))),
                minus(power(b, exponent)))


def rank3(columns):
    """Rank over F3 of a 3x3 matrix stored by columns."""
    mat = [[columns[j][i] for j in range(3)] for i in range(3)]
    r = 0
    for col in range(3):
        candidate = next((i for i in range(r, 3) if mat[i][col]), None)
        if candidate is None:
            continue
        mat[r], mat[candidate] = mat[candidate], mat[r]
        scale = 1 if mat[r][col] == 1 else 2
        mat[r] = [(scale * v) % 3 for v in mat[r]]
        for i in range(3):
            if i != r:
                factor = mat[i][col]
                mat[i] = [(mat[i][j] - factor * mat[r][j]) % 3
                          for j in range(3)]
        r += 1
    return r


def missing_difference_check(exponent):
    """Exact relative difference set property, 702 differences."""
    graph = [(x, power(x, exponent)) for x in range(27)]
    observed = set()
    for i, (x, fx) in enumerate(graph):
        for j, (y, fy) in enumerate(graph):
            if i == j:
                continue
            v = (plus(x, minus(y)), plus(fx, minus(fy)))
            assert v[0] != 0
            assert v not in observed
            observed.add(v)
    assert observed == {(a, b) for a in range(1, 27) for b in range(27)}
    return len(observed)


def normalized(exponent):
    inverse = {polar(1, y, exponent): y for y in range(27)}
    assert len(inverse) == 27
    return lambda x, y: polar(x, inverse[y], exponent)


def commutator(exponent, x, z, y):
    n = normalized(exponent)
    return plus(n(x, n(z, y)), minus(n(z, n(x, y))))


def audit(exponent):
    # All ordered nonzero arguments including diagonal and x=z.
    assert missing_difference_check(exponent) == 702
    n = normalized(exponent)
    histogram = Counter()
    for x in range(1, 27):
        for z in range(1, 27):
            columns = [vector(plus(n(x, n(z, v)), minus(n(z, n(x, v)))))
                       for v in (1, 3, 9)]
            histogram[rank3(columns)] += 1
    assert sum(histogram.values()) == 26 * 26
    return dict(sorted(histogram.items()))



def component_recovery(exponent):
    """Explicit 26 sections, 29 points each; compare every pair.

    Completeness of the 26-section list is separately proved by the
    exhaustive 8,069,620-quotient C++ verifier (asserts no others).
    """
    points_p = {(x, power(x, exponent), 0) for x in range(27)}
    points_c = {(0, minus(power(z, exponent)), z) for z in range(27)}
    points = points_p | points_c
    assert len(points) == 53 and len(points_p & points_c) == 1
    lines = sorted({frozenset((0, x, minus(x))) for x in range(1, 27)},
                   key=lambda u: tuple(sorted(u)))
    assert len(lines) == 13
    sections = []
    for line in lines:
        p_section = frozenset(v for v in points if v[2] in line)
        c_section = frozenset(v for v in points if v[0] in line)
        assert len(p_section) == 29 and len(c_section) == 29
        assert p_section == points_p | {v for v in points_c if v[2] in line}
        assert c_section == points_c | {v for v in points_p if v[0] in line}
        sections.extend((("P", p_section), ("C", c_section)))
    assert len({s for _, s in sections}) == 26
    shared_same = shared_cross = 0
    for i in range(26):
        for j in range(i+1, 26):
            ka, aa = sections[i]
            kb, bb = sections[j]
            overlap = aa & bb
            if ka == kb:
                assert len(overlap) == 27
                assert overlap == (points_p if ka == "P" else points_c)
                shared_same += 1
            else:
                assert len(overlap) == 5
                shared_cross += 1
    assert shared_same == 2 * 13 * 12 // 2 == 156
    assert shared_cross == 13 * 13 == 169
    return {
        "affine_codim_two_large_sections": len(sections),
        "intersection_29_sections_same_component": {
            "pairs": shared_same, "intersection_size": 27},
        "intersection_29_sections_different_component": {
            "pairs": shared_cross, "intersection_size": 5},
        "intrinsic_components": [27, 27],
    }


def main():
    # Irreducible T^3-T+1: no root in F3. Check T^3=T-1.
    t = 3
    assert power(t, 3) == plus(t, minus(1))
    # A common false positive: x^3 is nonplanar, so M_1 is singular.
    assert len({polar(1, y, 3) for y in range(27)}) == 1

    quadratic = audit(2)
    quartic = audit(4)
    rec_quadratic = component_recovery(2)
    rec_quartic = component_recovery(4)
    assert rec_quadratic == rec_quartic
    assert quadratic == {0: 676}
    assert quartic == {0: 244, 2: 432}
    left = normalized(4)(3, normalized(4)(9, 3))
    right = normalized(4)(9, normalized(4)(3, 3))
    assert (left, right) == (6, 8), (left, right)
    assert commutator(4, 3, 9, 3) == plus(6, minus(8))
    assert commutator(2, 3, 9, 3) == 0

    print(json.dumps({
        "status": "EXACT_GRAPH_EQUIVALENCE_FALSIFIER",
        "field": "F3[T]/(T^3-T+1)",
        "missing_differences_each_graph": 702,
        "quadratic_commutator_ranks": quadratic,
        "quartic_commutator_ranks": quartic,
        "full_union_recovery": rec_quartic,
        "quartic_witness": {
            "x": "T", "z": "T^2", "input": "T",
            "N_T(N_T2(T))": 6, "N_T2(N_T(T))": 8,
            "inequal": True
        },
        "scope": "full ambient F3^9 affine inequivalence, conditional only on separately exhaustively verified 26-section completeness; no novelty/priority clearance"
    }, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()

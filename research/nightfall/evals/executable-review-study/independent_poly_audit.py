#!/usr/bin/env python3
"""Independent implementation of the exact shifted-c/4 Bernstein cell audit.

Instead of expanding polynomial coefficients and splitting via De Casteljau
(as in the existing NIGHTFALL author source), this reconstructs each cell's
tensor Bernstein coefficients from a rational 5x5 interpolation grid and
inverts the tensor basis matrix exactly with Gauss-Jordan elimination.

Independence here means different executable arithmetic implementation;
the work is still author-side and NOT external referee certification.
"""
from __future__ import annotations
from fractions import Fraction as Q
from math import comb

N = 4
GRID = tuple(Q(k, N) for k in range(N + 1))
BOXES = (
    (Q(0), Q(1,4), Q(0), Q(1,2), Q(0)),
    (Q(0), Q(1,2), Q(1,2), Q(1), Q(11,16)),
    (Q(1,4), Q(1,2), Q(0), Q(1,4), Q(1,128)),
    (Q(1,4), Q(1,2), Q(1,4), Q(1,2), Q(21,256)),
    (Q(1,2), Q(3,4), Q(0), Q(1,4), Q(15,256)),
    (Q(1,2), Q(3,4), Q(1,4), Q(1,2), Q(15,128)),
    (Q(1,2), Q(1), Q(1,2), Q(1), Q(25,32)),
    (Q(3,4), Q(1), Q(0), Q(1,2), Q(1693,3072)),
)


def polynomial(x: Q, t: Q) -> Q:
    # Algebraically equivalent but independently factored expression.
    return Q(3) - (1-t)**2 * (Q(3) - 2*x**4 + 16*t*(x+t)*(1-x*x))


def basis(u: Q, i: int) -> Q:
    return Q(comb(N, i)) * u**i * (1-u)**(N-i)


def invert_exact(rows: list[list[Q]]) -> list[list[Q]]:
    n = len(rows)
    if n == 0 or any(len(row) != n for row in rows):
        raise ValueError("expected square rational matrix")
    a = [list(row) + [Q(int(i == j)) for j in range(n)] for i, row in enumerate(rows)]
    for j in range(n):
        pivot = next((i for i in range(j, n) if a[i][j] != 0), None)
        if pivot is None:
            raise ArithmeticError("singular interpolation basis")
        a[j], a[pivot] = a[pivot], a[j]
        scale = a[j][j]
        a[j] = [z / scale for z in a[j]]
        for i in range(n):
            if i != j:
                multiple = a[i][j]
                a[i] = [a[i][k] - multiple*a[j][k] for k in range(2*n)]
    inverse = [row[n:] for row in a]
    for i in range(n):
        for j in range(n):
            actual = sum(rows[i][k]*inverse[k][j] for k in range(n))
            if actual != (i == j):
                raise AssertionError("interpolation inverse exact replay mismatch")
    return inverse


def matmul(a: list[list[Q]], b: list[list[Q]]) -> list[list[Q]]:
    return [[sum((a[i][k]*b[k][j] for k in range(len(b))), Q(0))
             for j in range(len(b[0]))] for i in range(len(a))]


def transpose(m: list[list[Q]]) -> list[list[Q]]:
    return [list(row) for row in zip(*m)]


def coefficients_for_box(box: tuple[Q, Q, Q, Q, Q], inverse: list[list[Q]]) -> list[list[Q]]:
    xlo, xhi, tlo, thi, _ = box
    values = [
        [polynomial(xlo + (xhi-xlo)*u, tlo + (thi-tlo)*v) for v in GRID]
        for u in GRID
    ]
    coefficients = matmul(matmul(inverse, values), transpose(inverse))
    # Deliberately cross-check the reconstructed polynomial at non-grid points.
    for u, v in ((Q(1,7), Q(2,9)), (Q(3,7), Q(5,8))):
        reconstructed = sum(
            coefficients[i][j] * basis(u, i) * basis(v, j)
            for i in range(N+1) for j in range(N+1)
        )
        expected = polynomial(xlo+(xhi-xlo)*u, tlo+(thi-tlo)*v)
        if reconstructed != expected:
            raise AssertionError("interpolation does not reproduce polynomial")
    return coefficients


def verify_coverage() -> Q:
    area = Q(0)
    for box in BOXES:
        a,b,c,d,_ = box
        if not (Q(0) <= a < b <= 1 and Q(0) <= c < d <= 1):
            raise AssertionError("certificate rectangle outside [0,1]^2")
        area += (b-a)*(d-c)
    for index, (a,b,c,d,_) in enumerate(BOXES):
        for e,f,g,h,_ in BOXES[index+1:]:
            if min(b,f)>max(a,e) and min(d,h)>max(c,g):
                raise AssertionError("overlapping positive-area certificate cells")
    if area != 1:
        raise AssertionError(f"certificate rectangles do not cover square: area {area}")
    return area


def audit() -> dict:
    area = verify_coverage()
    basis_matrix = [[basis(u, j) for j in range(N+1)] for u in GRID]
    inverse = invert_exact(basis_matrix)
    result = []
    for i, box in enumerate(BOXES):
        coeff = coefficients_for_box(box, inverse)
        minimum = min(val for row in coeff for val in row)
        if minimum < 0 or minimum != box[-1]:
            raise AssertionError(f"box {i}: computed {minimum}, expected {box[-1]}")
        result.append({"id": i, "min_bernstein": str(minimum),
                       "rect": [str(v) for v in box[:4]]})
    if polynomial(Q(0), Q(0)) != 0:
        raise AssertionError("sharp global lower bound no longer attained")
    return {"schema": "nightfall.exec-review.independent-exact-audit.v1",
            "status": "pass", "cells": len(result), "domain_area": str(area),
            "minimum": "0", "method": "tensor rational interpolation matrix inversion",
            "boxes": result,
            "limitation": "different checker implementation, not independent external reviewer"}


if __name__ == "__main__":
    import json
    print(json.dumps(audit(), indent=2, sort_keys=True))

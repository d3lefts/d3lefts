#!/usr/bin/env python3
"""Exact rational Bernstein certificate for the shifted Hilbert c/4 envelope.

No floating-point calculations; this is an independent finite arithmetic
identity checker, NOT a Lean or source-level terminal theorem. The exact
source Q2 implication still requires the actual-source fourth moment and
sharp original-law section budget.
"""
from collections import defaultdict
from fractions import Fraction as Q
from math import comb
import hashlib
import json

# F(x,v) = 3 -(1-v)^2*(3-2*x^4+16*x*v*(1-x^2)+16*v^2*(1-x^2)).
# Domain: 0 <= x <= 1, 0 <= v <= 1.
# Exact power coefficients c[p,q] for x^p v^q, independently audited.
COEFF = {
    (4,0):2,(4,1):-4,(4,2):2,
    (3,1):16,(3,2):-32,(3,3):16,
    (2,2):16,(2,3):-32,(2,4):16,
    (1,1):-16,(1,2):32,(1,3):-16,
    (0,1):6,(0,2):-19,(0,3):32,(0,4):-16,
}
NX, NV = 31, 24

def bern_coeff(i, j):
    """Degree-elevated power-to-Bernstein map, exact in Q."""
    return sum(
        Q(a * comb(i,p) * comb(j,q), comb(NX,p)*comb(NV,q))
        for (p,q),a in COEFF.items() if p <= i and q <= j
    )

def main():
    B = {(i,j):bern_coeff(i,j)
         for i in range(NX+1) for j in range(NV+1)}
    negatives = [(i,j,b) for (i,j),b in B.items() if b < 0]
    assert not negatives, f"negative Bernstein coefficients: {negatives[:5]}"
    zeros = sorted([k for k,v in B.items() if v == 0])
    assert zeros == [(0,0),(1,0),(2,0),(3,0)], zeros
    positives = [b for b in B.values() if b > 0]
    assert min(positives) == Q(2,31465), min(positives)

    # Independent inverse transform check: expand each Bernstein basis
    # B_i^N(x)=C(N,i)*x^i*(1-x)^(N-i) to the POWER basis. First x then v.
    rows = {}
    for j in range(NV+1):
        row = [Q(0) for _ in range(NX+1)]
        for i in range(NX+1):
            bij = B[i,j]
            for p in range(i,NX+1):
                row[p] += bij*comb(NX,i)*comb(NX-i,p-i)*(-1)**(p-i)
        rows[j] = row
    recovered = defaultdict(Q)
    for j in range(NV+1):
        for q in range(j,NV+1):
            w = comb(NV,j)*comb(NV-j,q-j)*(-1)**(q-j)
            for p in range(NX+1):
                if rows[j][p]:
                    recovered[p,q] += rows[j][p]*w
    got = {k:v for k,v in recovered.items() if v}
    expected = {k:Q(v) for k,v in COEFF.items()}
    assert got == expected, "inverse transform disagrees with stated polynomial"

    # Every Bernstein basis factor is nonnegative on [0,1]^2, so
    # coefficient positivity proves F >= 0 for every real x,v in the square.
    serial = "\n".join(f"{i},{j}:{B[i,j].numerator}/{B[i,j].denominator}"
                       for i in range(NX+1) for j in range(NV+1))
    result = {
        "status":"EXACT_RATIONAL_BERNSTEIN_POLYNOMIAL_CERTIFICATE",
        "degree_x":NX,"degree_v":NV,"coefficients":len(B),
        "nonnegative":len(B),"positive":len(positives),"zero":zeros,
        "minimum_strictly_positive":str(min(positives)),
        "exact_power_reconstruction":True,
        "sha256_bernstein_matrix":hashlib.sha256(serial.encode()).hexdigest(),
        "scope":"scalar polynomial only; not Lean kernel or unconditional Q2",
    }
    print(json.dumps(result, indent=2))

if __name__ == "__main__":
    main()

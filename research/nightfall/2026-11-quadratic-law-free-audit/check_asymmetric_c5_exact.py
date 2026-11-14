#!/usr/bin/env python3
"""Exact asymmetric-law falsifier for shifted c/5. A finite test is NOT a universal proof.

Two-atom centered laws use values (-a,+b) with probabilities
(b/(a+b), a/(a+b)), where a and b can differ. Add a third zero-probability
atom freely: it does not alter any moment, but is explicitly permitted by
the finite original-source theorem. Independent coordinates can have
different (a,b). All computations/comparisons are rational.
"""
from fractions import Fraction as F
from itertools import product

PARAMS = [F(1,6), F(1,4), F(1,3), F(1,2), F(3,4), F(1)]
PAIRS = list(product(PARAMS, PARAMS))
SHIFTS = [F(-1), F(-1,2), F(-1,3), F(-1,6),
          F(0), F(1,6), F(1,3), F(1,2), F(1)]
CHECKED = 0

def exact_claim(t2: F, u: F, c: F = F(1)) -> bool:
    """Test sqrt(t2) <= sqrt(3)*u + c/5 without floating point."""
    assert t2 >= 0 and u >= 0 and c >= 0
    d = t2 - 3*u*u - c*c/25
    return d <= 0 or 25*d*d <= 12*u*u*c*c

def main():
    global CHECKED
    for n in range(1,4):
        for choices in product(PAIRS, repeat=n):
            s = sum((a*b for a,b in choices),F(0))
            atom_laws = [[(-a,b/(a+b)), (b,a/(a+b))]
                         for a,b in choices]
            samples = []
            for picks in product(*atom_laws):
                value = sum((val for val,_ in picks), F(0))
                probability = F(1)
                for _,p in picks:
                    probability *= p
                samples.append((value,probability))
            for h in SHIFTS:
                u = sum((p*abs(h+y) for y,p in samples),F(0))
                t2 = h*h+s
                if not exact_claim(t2,u):
                    raise AssertionError(f"COUNTEREXAMPLE choices={choices} h={h} s={s} u={u}")
                CHECKED+=1
    print(f"PASS {CHECKED} exact asymmetric-law shifted c/5 instances; "
          "NOT a proof of the universal shifted theorem")
    # Explicit skew / zero-atom edge: probabilities [0,3/4,1/4],
    # centered values [0,-1/3,1].
    assert F(3,4)*F(-1,3)+F(1,4) == 0
    assert F(3,4)*F(-1,27)+F(1,4) == F(2,9)
    print("PASS exact asymmetric positive third moment 2/9 with a zero mass atom")

if __name__ == "__main__":
    main()

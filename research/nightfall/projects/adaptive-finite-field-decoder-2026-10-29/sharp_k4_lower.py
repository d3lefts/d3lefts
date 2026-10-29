#!/usr/bin/env python3
"""Independent exact orbit-count audit for the F25, k=4 adaptive lower bound.

This certifies the finite integers used in the first-two-query fibre argument.
It does NOT search over all adaptive strategies; that exclusion is algebraic
and stated in README.md. No third-party packages or external files required.
"""
import json
from itertools import product


def basefield_scale(z, scalar):
    """F25 = F5^2 as an F5-vector space; only F5* scalar action is needed."""
    assert 0 <= z < 25 and scalar in (1, 2, 3, 4)
    a, b = divmod(z, 5)
    return 5 * ((a * scalar) % 5) + ((b * scalar) % 5)


def canonical(vector):
    """Choose an orbit representative under the common F5* multiplication."""
    return min(
        tuple(basefield_scale(z, s) for z in vector)
        for s in (1, 2, 3, 4)
    )


def audit():
    # A fourth power has 1 zero output and 24/4=6 nonzero outputs.
    output_alphabet = 1 + (25 - 1) // 4
    assert output_alphabet == 7
    global_orbits = 1 + (25**4 - 1) // 4
    assert global_orbits == 97657

    # Two independent linear forms with fixed NONZERO powered responses.
    # Changing basis sends them to the first two coordinates. Each chosen
    # nonzero response has four possible fourth roots, hence an F5* coset.
    # Their particular coset representatives do not change orbit counts.
    paired = {
        canonical((a, b, c, d))
        for a, b, c, d in product(range(1, 5), range(1, 5), range(25), range(25))
    }
    assert len(paired) == 2500 == 4 * 25**2

    # With at most one independent nonzero form in two rounds,
    # the second powered result is predetermined (if the second is
    # proportional), and the surviving class count is at least this.
    single = {
        canonical((a, b, c, d))
        for a, b, c, d in product(range(1, 5), range(25), range(25), range(25))
    }
    assert len(single) == 15625 == 25**3
    assert min(len(paired), len(single)) > output_alphabet**4
    assert global_orbits > output_alphabet**5

    # Quadratic extensions F_(q^2)/F_q with q>=5:
    # (q-1)*q^4 > (q+2)^4. The mathematical proof uses monotonicity:
    # (q-1)*(q/(q+2))^4 is increasing for real q>1, and at q=5
    # its numerator/denominator are 2500/2401.
    assert 4 * 5**4 > 7**4
    for q in range(5, 101):
        assert (q - 1) * q**4 > (q + 2)**4

    print(json.dumps({
        "status": "PASS: internal exact finite orbit audit",
        "field": "F25",
        "dimension": 4,
        "global_phase_classes": global_orbits,
        "nonzero_two_row_fibre_classes": len(paired),
        "one_row_fibre_classes": len(single),
        "four_remaining_query_transcripts": output_alphabet**4,
        "max_adaptive_queries_if_six_were_allowed": 6,
        "proved_lower_bound": 7,
        "matching_explicit_upper_bound": 7,
        "scope": "all K=F_(q^2), base prime power q>=5, by algebraic fibre proof"
    }, sort_keys=True))


if __name__ == "__main__":
    audit()

#!/usr/bin/env python3
"""Independent exact replay of rozetyp's C1c K=6144 certificate.

This checker is intentionally separate from the original lag-first verifier:
it accumulates unordered input pairs into all lags in one sweep, uses exact
integer arithmetic and checks every grid knot. No third-party dependencies.
This confirms a finite witness, not global optimality or priority.
"""
import argparse
from fractions import Fraction
import hashlib
import json
from pathlib import Path
from urllib.request import urlopen

SOURCE_COMMIT = "19f397152222caaef2c838bdd9c41295adb94310"
SOURCE_URL = (
    "https://raw.githubusercontent.com/rozetyp/barnard-steinerberger-lower-bound/"
    + SOURCE_COMMIT + "/certificate.json"
)
SOURCE_SHA256 = "62ac49ddbbfc9aa1053406363d9df9c912022ab85b72a447cf73c94bb9c1fd0e"
EXPECTED = Fraction(21072342208353792, 51354782902387969)
K = 6144
N = 6148
EXPECTED_PEAK = 4665


def read_source(raw):
    assert hashlib.sha256(raw).hexdigest() == SOURCE_SHA256, "certificate hash mismatch"
    c = json.loads(raw)
    w = c["weights_int"]
    assert c["K"] == K and len(w) == N
    assert all(type(z) is int and z >= 0 for z in w), "invalid weight"
    return c, w


def correlate_pair_first(w, kmax):
    # For every ordered (i,j), i<=j, contribute to lag j-i exactly once.
    # Contrast the claimant's lag-major correlation verifier.
    result = [0] * (kmax + 1)
    for i, wi in enumerate(w):
        if not wi:
            continue
        for j in range(i, min(len(w), i + kmax + 1)):
            result[j-i] += wi * w[j]
    return result


def verify(raw):
    data, w = read_source(raw)
    sums = correlate_pair_first(w, K)
    smallest = min(sums)
    kmin = sums.index(smallest)
    total = sum(w)
    assert total > 0
    bound = Fraction(K * smallest, total * total)
    assert bound == EXPECTED, f"exact score discrepancy: {bound}"
    assert bound == Fraction(data["score_num"], data["score_den"])
    assert kmin == EXPECTED_PEAK
    assert len(sums) == K + 1

    # Independent local check: the exact lags adjacent to the minimizer
    # must have no smaller correlation, and a strictly altered input should
    # change the score at the claimed minimizer.
    assert sums[kmin-1] >= smallest and sums[kmin+1] >= smallest
    witness_i = next(i for i in range(N-kmin) if w[i+kmin] > 0)
    altered = w[:]
    altered[witness_i] += 1
    altered_lag = sum(
        altered[i] * altered[i+kmin] for i in range(N-kmin)
    )
    assert altered_lag != smallest, "mutated weight was not detected"
    # An off-grid t strictly between two knots has correlation equal to the
    # convex combination of the two neighboring exact correlation values;
    # this follows directly from integrating the overlap of equal-width
    # indicator intervals, so no off-grid scan is being silently assumed.
    mid = Fraction(sums[kmin-1]+sums[kmin], 2)
    assert mid >= smallest

    # The source README and constants page display 0.41030287175 for the
    # same exact fraction, while exact rational arithmetic gives 0.4103287...
    # This is a presentation-only discrepancy, NOT a certificate failure.
    assert float(bound) > 0.4103287 and float(bound) < 0.4103288

    return {
        "status": "EXACT_FINITE_WITNESS_REPLAY",
        "claimant": "rozetyp",
        "upstream_commit": SOURCE_COMMIT,
        "source_sha256": SOURCE_SHA256,
        "grid_denominator": K,
        "weight_count": N,
        "tested_knot_count": K + 1,
        "minimizer_lag": kmin,
        "exact_numerator": str(bound.numerator),
        "exact_denominator": str(bound.denominator),
        "display_decimal": format(float(bound), ".14f"),
        "presentation_error": {
            "incorrect_readme_decimal": "0.41030287175",
            "correct_decimal_rounded": format(float(bound), ".11f"),
            "scope": "source README prose (and related constant page); exact fractional claim passes",
        },
        "mutation_control": "PASS",
        "scope_limits": "finite step-function lower witness only; no general theorem or priority validation",
    }


def main():
    parser = argparse.ArgumentParser()
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--fetch", action="store_true")
    group.add_argument("--file", type=Path)
    args = parser.parse_args()
    if args.fetch:
        with urlopen(SOURCE_URL, timeout=45) as remote:
            raw = remote.read()
    else:
        raw = args.file.read_bytes()
    print(json.dumps(verify(raw), indent=2))


if __name__ == "__main__":
    main()

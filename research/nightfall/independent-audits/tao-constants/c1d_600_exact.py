#!/usr/bin/env python3
"""Independent exact replay of a public C1d 600-cell certificate.

NIGHTFALL scope: one external numerical witness, NOT a universal lower bound
or a certification of the optimization-constants leaderboard. Authorship of
the data: steps-re/c1d-certificate (2026-10-21) / original contributors.

No third-party packages. Source pinned to public Git commit + SHA-256.
Verifier is independently implemented: IEEE-754 bit deconstruction, integer
common-denominator scaling, and symmetric unordered-pair convolution.
"""
import argparse
from fractions import Fraction
import hashlib
import json
import struct
from urllib.request import urlopen

UPSTREAM = (
    "https://raw.githubusercontent.com/steps-re/c1d-certificate/"
    "9a091494facc801eaf6b92b175b63c58b7c3b30b/construction.json"
)
UPSTREAM_SHA256 = "3dd39fae744555179b0356b84e752db724e892bd23dda51403976edfb5b3a28c"
EXPECTED = Fraction(
    698746209786798359455483373677229695641600,
    478522078482569620433992386249161163190849,
)


def binary64_parts(number):
    """Exactly recover signed mantissa * 2**shift, including subnormals."""
    bits = int.from_bytes(struct.pack(">d", number), "big")
    sign = -1 if bits >> 63 else 1
    exp = (bits >> 52) & 2047
    mantissa = bits & ((1 << 52) - 1)
    if exp == 2047:
        raise ValueError("non-finite data")
    if exp:
        mantissa |= 1 << 52
        shift = exp - 1023 - 52
    else:
        shift = -1022 - 52
    return sign * mantissa, shift


def exact_ratio(weights):
    if len(weights) != 600:
        raise ValueError("wrong certificate cell count")
    parts = [binary64_parts(float(x)) for x in weights]
    min_shift = min(e for _, e in parts)
    nums = [m << (e - min_shift) for m, e in parts]
    total = sum(nums)
    if total == 0:
        raise ValueError("zero integral")
    # Pair-first accumulation differs from the source lag-first checker.
    convolution = [0] * (2 * len(nums) - 1)
    for i, vi in enumerate(nums):
        for j in range(i, len(nums)):
            convolution[i + j] += vi * nums[j] * (1 if i == j else 2)
    peak = max(range(len(convolution)), key=lambda i: abs(convolution[i]))
    ratio = Fraction(2 * len(nums) * abs(convolution[peak]), total * total)
    return ratio, peak, len(convolution)


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--file", help="locally downloaded original construction.json")
    p.add_argument("--fetch", action="store_true", help="fetch immutable public source by commit")
    args = p.parse_args()
    if bool(args.file) == bool(args.fetch):
        p.error("choose exactly one of --file or --fetch")
    if args.file:
        with open(args.file, "rb") as f:
            raw = f.read()
    else:
        with urlopen(UPSTREAM, timeout=40) as r:
            raw = r.read()
    found = hashlib.sha256(raw).hexdigest()
    if found != UPSTREAM_SHA256:
        raise RuntimeError(f"source checksum mismatch: {found}")
    data = json.loads(raw)
    ratio, peak, lags = exact_ratio(data["values"])
    if ratio != EXPECTED:
        raise RuntimeError(f"exact rational discrepancy: {ratio} != {EXPECTED}")
    # A negative control using the same source values must fail equality.
    swapped = list(data["values"])
    swapped[0], swapped[1] = swapped[1], swapped[0]
    mutated, _, _ = exact_ratio(swapped)
    if mutated == EXPECTED:
        raise RuntimeError("negative control did not discriminate")
    print(json.dumps({
        "status": "EXACT_SOURCE_SCOPED_REPLAY",
        "claim": "C1d 600-cell step-function upper witness",
        "origin_url": UPSTREAM,
        "source_sha256": found,
        "cell_count": 600,
        "knot_count": lags,
        "peak_zero_based": peak,
        "exact_numerator": str(ratio.numerator),
        "exact_denominator": str(ratio.denominator),
        "decimal": format(float(ratio), ".16f"),
        "negative_swap_changes_result": True,
        "limits": "one witness; no independent priority or universal theorem validation",
    }, indent=2))


if __name__ == "__main__":
    main()

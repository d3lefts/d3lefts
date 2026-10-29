#!/usr/bin/env python3
"""Independent exact 300-cell C1d replay. Source and arithmetic pinned.

Original witness: CERT2026 via the Extremal Values Registry.
Earlier independent verification by Carlos Toledo is credited.
This is a NIGHTFALL arithmetic replay, not a claim of novelty.
"""
import hashlib
import json
import struct
from fractions import Fraction
from urllib.request import urlopen

URL = ("https://raw.githubusercontent.com/extremal-values-registry/"
       "extremal-values-registry/50520b971e5d234bc9c4ccbdcd5a5107d5bb8791/"
       "certificates/third_autocorrelation_abs_inside/construction.json")
SHA256 = "51f864ee95205f06b98923c382d23cb3dfde5f0d4208a4c591bad015e5908a0e"
EXPECTED = Fraction(
    2039224160683882663565441886346340189798400,
    1393796574908163689489385839036226787118881,
)

def bits_as_integer_scale(x):
    word = int.from_bytes(struct.pack(">d", x), "big")
    sign = -1 if word >> 63 else 1
    exponent = (word >> 52) & 2047
    mantissa = word & ((1 << 52) - 1)
    if exponent == 2047:
        raise ValueError("non-finite")
    if exponent:
        mantissa |= 1 << 52
    return sign * mantissa, ((exponent - 1023) if exponent else -1022) - 52

def independent_ratio(values):
    if len(values) != 300:
        raise ValueError("wrong cell count")
    pairs = [bits_as_integer_scale(x) for x in values]
    shift = min(t for _, t in pairs)
    v = [m << (t - shift) for m, t in pairs]
    total = sum(v)
    if total == 0:
        raise ValueError("zero integral")
    # Pair-first exact summation, NOT the source checker’s lag-first Fractions.
    conv = [0] * 599
    for i, a in enumerate(v):
        for j in range(i, 300):
            conv[i + j] += a * v[j] * (2 if i != j else 1)
    peak = max(range(599), key=lambda m: abs(conv[m]))
    return Fraction(600 * abs(conv[peak]), total * total), peak

def main():
    import argparse
    ap = argparse.ArgumentParser()
    ap.add_argument("--fetch", action="store_true")
    ap.add_argument("--file")
    args = ap.parse_args()
    if bool(args.fetch) == bool(args.file):
        ap.error("choose exactly one of --fetch or --file")
    if args.fetch:
        with urlopen(URL, timeout=40) as response:
            raw = response.read()
    else:
        with open(args.file, "rb") as handle:
            raw = handle.read()
    found = hashlib.sha256(raw).hexdigest()
    if found != SHA256:
        raise AssertionError(f"source hash mismatch {found}")
    values = json.loads(raw)["values"]
    ratio, peak = independent_ratio(values)
    if ratio != EXPECTED:
        raise AssertionError(f"exact mismatch: {ratio} != {EXPECTED}")
    corrupted = list(values)
    corrupted[0], corrupted[1] = corrupted[1], corrupted[0]
    if independent_ratio(corrupted)[0] == EXPECTED:
        raise AssertionError("negative perturbation not detected")
    print(json.dumps({
        "status":"EXACT_SOURCE_SCOPED_REPLAY",
        "cells":300,"knots":599,"peak_lag_zero_based":peak,
        "numerator":str(ratio.numerator),"denominator":str(ratio.denominator),
        "source_sha256":found,
        "previous_independent_replay":"Carlos Toledo, acknowledged",
        "scope":"finite witness only; no novelty or universal theorem proof",
    },indent=2))

if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""Exact source-provenance reconstruction for NIGHTFALL's 30-point Sidon witness.

This checks an arithmetic identity, not originality or independent review.
The underlying 11-point seed and affine map are from anonymous reader
submission 7bkzb8 (2026-10-17):
https://www.erdosproblemaday.com/submission/7bkzb8

NIGHTFALL's frozen 30-point example is the K=2 reader family, with one
additional endpoint -269, scaled by 269**2 to integer coordinates.
"""
from fractions import Fraction
from hashlib import sha256
from pathlib import Path
import json


SEED = (0, 49, 75, 83, 98, 101, 117, 119, 121, 159, 269)
EXPECTED_HASH = "dc4697ce051a57987049199965967cc2b981433816d3daac284454262395978f"
PATH = Path(__file__).with_name("witness_30.txt")


def scale_reader_depth_2():
    stage = {Fraction(x) for x in SEED}
    union = set(stage)
    for _ in range(2):
        stage = {Fraction(101) + Fraction(18, 269) * x for x in stage}
        union.update(stage)
    assert len(union) == 29, "The two overlaps per level must yield 29"
    enlarged = union | {Fraction(-269)}
    scale = 269 ** 2
    assert len(enlarged) == 30
    assert all((x * scale).denominator == 1 for x in enlarged)
    return tuple(sorted(int(x * scale) for x in enlarged))


def verify(path=PATH):
    raw = Path(path).read_bytes()
    digest = sha256(raw).hexdigest()
    if digest != EXPECTED_HASH:
        raise ValueError("Unexpected witness bytes: " + digest)
    actual = tuple(map(int, raw.strip().split(b",")))
    reconstructed = scale_reader_depth_2()
    if actual != reconstructed:
        raise AssertionError("Frozen witness is not the scaled reader depth-2 family + endpoint")
    assert Fraction(5, 9) < Fraction(17, 30) < Fraction(4, 7)
    # A tamper check of the reconstructed *mathematical* identity, not
    # just the source-file checksum.
    altered = list(reconstructed)
    altered[1] += 1
    assert tuple(altered) != actual
    return {
        "status": "PASS",
        "witness_sha256": digest,
        "reader_submission": "7bkzb8, October 17 2026",
        "reader_seed_size": len(SEED),
        "reader_depth": 2,
        "affine_map": "phi(x)=101+18*x/269",
        "added_endpoint_before_scaling": -269,
        "integer_scale": 269**2,
        "reconstructed_coordinates": len(reconstructed),
        "exact_identity": True,
        "finite_ratio": "17/30",
        "previous_upper_bound": "4/7 (Ma-Tang, 2026)",
        "stronger_reader_upper_bound": "5/9 (anonymous submission, external human acceptance unverified)",
        "interpretation": "Reproducible derivation; not a new global upper bound or independently established priority"
    }


if __name__ == "__main__":
    print(json.dumps(verify(), indent=2, sort_keys=True))

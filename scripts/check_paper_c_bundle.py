#!/usr/bin/env python3
"""Paper C custody checker: bytes and exact finite receipt, not mathematical priority.

Fails closed on a broken self-contained source archive, stale generated
PDF/TeX/checker, a tampered finite audit receipt or an unscoped model label.
This does not infer theorem validity or external review from hashes.
"""
from __future__ import annotations

import hashlib
import json
import re
from pathlib import Path
from zipfile import BadZipFile, ZipFile

ROOT = Path(__file__).resolve().parent.parent
DIR = ROOT / "papers/specialized-complexity"
NAMED = {
    "MANUSCRIPT.md",
    "Specialized_Complexity_Manuscript.tex",
    "Specialized_Complexity_Manuscript.pdf",
    "replay_f16_specialized.py",
    "replay_f16_receipt.json",
    "ARTIFACT_README.md",
}
MANIFEST = "SOURCE_SHA256SUMS"
BUNDLE = "Specialized_Complexity_Source_and_Audit.zip"


def check(condition: bool, reason: str) -> None:
    if not condition:
        raise AssertionError(reason)


def digest(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def verify() -> None:
    manifest_bytes = (DIR / MANIFEST).read_bytes()
    manifest_text = manifest_bytes.decode("utf-8")
    expected: dict[str, str] = {}
    for line in manifest_text.splitlines():
        match = re.fullmatch(r"([0-9a-f]{64})  ([A-Za-z0-9_.-]+)", line)
        check(match is not None, "Malformed checksum manifest entry")
        h, name = match.groups()
        check(name not in expected, "Duplicate file in manifest")
        expected[name] = h
    check(set(expected) == NAMED, "Manifest omits or adds canonical source artifacts")
    for name, sha in expected.items():
        check(digest((DIR / name).read_bytes()) == sha, "Hash mismatch: " + name)

    pdf = (DIR / "Specialized_Complexity_Manuscript.pdf").read_bytes()
    check(pdf.startswith(b"%PDF-"), "Not a PDF artifact")
    check(len(pdf) > 20000, "Truncated PDF artifact")
    source = (DIR / "MANUSCRIPT.md").read_text("utf-8")
    check("Certificate Geometry, Rank Structure, and Finite-Field Phase Codes" in source,
          "Unexpected or replaced source manuscript")

    try:
        with ZipFile(DIR / BUNDLE) as z:
            files = z.namelist()
            check(len(files) == len(set(files)), "Repeated ZIP entries")
            check(set(files) == NAMED | {MANIFEST},
                  "Incomplete or oversized ZIP / missing PDF")
            for name in NAMED | {MANIFEST}:
                check(z.read(name) == (DIR / name).read_bytes(),
                      "ZIP bytes differ from checked-in artifact: " + name)
    except BadZipFile as exc:
        raise AssertionError("Broken ZIP archive") from exc

    receipt = json.loads((DIR / "replay_f16_receipt.json").read_text("utf-8"))
    check(receipt.get("status") == "PASS", "Finite code receipt is not passing")
    check(receipt.get("model") == "F16 cubic-power oracle; global F4* equivalence",
          "Changed measurement oracle")
    for key, value in {
        "fixed_81_distinct": 81,
        "adaptive_27_distinct": 27,
        "canonical_fixed_rows": 4369,
        "distinct_collision_masks": 439,
        "minimal_fixed_pair_collision_pairs": 4,
        "exhaustive_k4_signals": 65536,
        "k7_support_phase_classes": 5461,
        "fixed_block_min_output_Hamming_distance": 1,
    }.items():
        check(receipt.get(key) == value, "Changed finite certificate count: " + key)
    check(receipt.get("sharp_worst_case_queries") == {"4": 6, "5": 8, "7": 11},
          "Wrong source-specific minimax rates")
    check(receipt.get("first_fibers") == {"0": 1, "1": 5, "8": 5, "10": 6, "12": 5, "15": 5},
          "First-reading partition changed")
    check(receipt.get("k4_query_distribution") == {"4": 61, "5": 1350, "6": 64125},
          "All-signal k4 distribution changed")
    check("no peer-review" in receipt.get("limitations", ""),
          "Source status was silently promoted")
    certificate = receipt.pop("certificate_sha256", "")
    calculated = digest(json.dumps(receipt, sort_keys=True, separators=(",", ":")).encode())
    check(certificate == calculated, "Incorrect self-contained finite receipt digest")
    print("PASS Paper C: all 6 SHA-256 artifacts; ZIP includes exactly 7 exact files;"
          " PDF header; F16 finite receipt hashes, model and scopes.")


if __name__ == "__main__":
    verify()

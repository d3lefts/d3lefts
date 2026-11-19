#!/usr/bin/env python3
"""Exact public calibration oracle for executable-vs-prose scientific review.

This computes *case truth*, not agent performance. No LLM calls or external
reviewers are represented. Real blinded scoring requires separate custody.
"""
from __future__ import annotations

import argparse
from collections import Counter
from fractions import Fraction as Q
import hashlib
import json
from pathlib import Path
import subprocess
import sys

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
CASES = HERE / "public_cases.json"
CERT = "research/nightfall/2026-11-quadratic-law-free-audit/check_shifted_owner_moment_107.py"
BERN = "research/nightfall/formalization/observability/ShiftedC4Bernstein.lean"
PINS = {
    CERT: "f73179e69e19576c0e1e7dac37e1801fe5b33d56",
    BERN: "d29a1e5f0396ca7f29fde24a34325fc324a3d3c0",
}
FAMILIES = frozenset({"shifted_bernstein", "modular_synergy", "diagonal_product", "source_integrity"})


def source_record(relative: str) -> dict:
    if relative not in PINS:
        raise ValueError("unregistered source path")
    path = ROOT / relative
    if not path.is_file() or path.is_symlink() or path.resolve().is_relative_to(ROOT.resolve()) is False:
        raise ValueError("pinned source unavailable/unsafe: " + relative)
    data = path.read_bytes()
    blob = hashlib.sha1(b"blob " + str(len(data)).encode() + b"\0" + data).hexdigest()
    if blob != PINS[relative]:
        raise ValueError("pinned source changed: " + relative)
    return {"path": relative, "git_blob": blob, "sha256": hashlib.sha256(data).hexdigest()}


def exact_polynomial(x: Q, t: Q) -> Q:
    if not (0 <= x <= 1 and 0 <= t <= 1):
        raise ValueError("polynomial coordinates outside [0,1]")
    return 3 - (1-t)**2 * (3-2*x**4+16*t*x*(1-x**2)+16*t**2*(1-x**2))


def check_global_certificate() -> str:
    source_record(CERT)
    source_record(BERN)
    p = subprocess.run([sys.executable, str(ROOT / CERT)], cwd=ROOT,
                       text=True, capture_output=True, timeout=30)
    expected = "PASS exact shifted moment c/4 interpolation: 15 Bernstein nodes, 8 rational boxes"
    if p.returncode != 0 or expected not in p.stdout:
        raise RuntimeError("original exact Bernstein proof checker did not replay")
    # This is author-side source replay, not independent mathematical review.
    return hashlib.sha256(p.stdout.encode()).hexdigest()


def entropy_of_counts(counts: Counter) -> Q:
    total = sum(counts.values())
    if not total:
        raise ValueError("empty probability space")
    h = Q(0)
    for count in counts.values():
        if count <= 0 or total % count:
            raise ValueError("non-dyadic case; refusing floating-point shortcut")
        reciprocal = total // count
        if reciprocal & (reciprocal - 1):
            raise ValueError("non-power-of-two probability")
        h += Q(count, total) * (reciprocal.bit_length()-1)
    return h


def mutual_information(case: dict) -> Q:
    r = case["r"]
    if type(r) is not int or r not in (2, 4, 8):
        raise ValueError("unsupported modular alphabet")
    law = case["law"]
    if law == "independent":
        pairs = [(t, a) for t in range(r) for a in range(r)]
    elif law == "diagonal":
        pairs = [(t, t) for t in range(r)]
    else:
        raise ValueError("unregistered modular source law")
    h_k = entropy_of_counts(Counter((t+a) % r for t, a in pairs))
    if case["condition"] == "joint":
        return h_k  # K is exactly determined by the joint input
    if case["condition"] != "single_T":
        raise ValueError("unregistered conditioning sigma-algebra")
    by_t = Counter(t for t, _ in pairs)
    h_kgiven = sum(
        (Q(num, len(pairs)) * entropy_of_counts(Counter(
            (ta+aa) % r for ta, aa in pairs if ta == t
        )) for t, num in by_t.items()), Q(0))
    return h_k - h_kgiven


def rational_rank(matrix: list[list[Q]]) -> int:
    a = [row[:] for row in matrix]
    if not a or any(len(row) != len(a[0]) for row in a):
        raise ValueError("invalid matrix")
    nrow, ncol, pivot_row = len(a), len(a[0]), 0
    for col in range(ncol):
        p = next((i for i in range(pivot_row, nrow) if a[i][col]), None)
        if p is None:
            continue
        a[pivot_row], a[p] = a[p], a[pivot_row]
        factor = a[pivot_row][col]
        a[pivot_row] = [v / factor for v in a[pivot_row]]
        for i in range(nrow):
            if i != pivot_row:
                factor = a[i][col]
                a[i] = [a[i][j] - factor*a[pivot_row][j] for j in range(ncol)]
        pivot_row += 1
        if pivot_row == nrow:
            break
    return pivot_row


def diagonal_product(case: dict) -> tuple[Q, str]:
    n = case["n"]
    if type(n) is not int or not 1 <= n <= 4:
        raise ValueError("unsupported diagonal dimension")
    m = 2**n
    matrix = [[Q(1, m) if i == j else Q(0) for j in range(m)] for i in range(m)]
    rank = rational_rank(matrix)
    if rank != m:
        raise AssertionError("independent exact rank invariant failed")
    # Every full-2n-coordinate product law separates X from Y; the
    # X-by-Y matrix of one component has rank 1. Rank is subadditive.
    # m diagonal point-mass products attain the bound.
    kind = case["kind"]
    if kind not in ("matrix_rank", "min_components"):
        raise ValueError("invalid diagonal claim")
    return Q(rank), f"exact rank={rank}; each full-coordinate product component has X|Y rank at most one; {m} point masses attain bound"


def validate_cases(payload: dict) -> list[dict]:
    if payload.get("schema") != "nightfall.exec-review.public-calibration.v1":
        raise ValueError("case schema mismatch")
    cases = payload.get("cases")
    if not isinstance(cases, list) or len(cases) != 16:
        raise ValueError("the preregistered public calibration must have exactly 16 claims")
    ids = [x["id"] for x in cases]
    if len(ids) != len(set(ids)):
        raise ValueError("duplicate case identifiers")
    counts = Counter(c["family"] for c in cases)
    if set(counts) != FAMILIES or set(counts.values()) != {4}:
        raise ValueError("exactly four cases from each frozen mechanism family required")
    return cases


def evaluate(case: dict) -> dict:
    kind, family = case["kind"], case["family"]
    if family == "shifted_bernstein":
        if kind == "poly_global_lower":
            bound = Q(case["threshold"])
            value, valid = Q(0), bound <= 0
            witness = "P(0,0)=0, and the pinned 15-node/8-box exact Bernstein certificate proves P>=0"
        elif kind == "poly_value":
            value, required = exact_polynomial(Q(case["x"]), Q(case["t"])), Q(case["value"])
            valid = value == required
            witness = f"exact P({case['x']},{case['t']})={value}"
        else:
            raise ValueError("unknown polynomial assertion")
    elif family == "modular_synergy" and kind == "mutual_info":
        value = mutual_information(case)
        valid = value == Q(case["bits"])
        witness = f"exact dyadic enumeration gives I(K;{case['condition']})={value} bits"
    elif family == "diagonal_product":
        value, witness = diagonal_product(case)
        valid = value == Q(case["value"])
    elif family == "source_integrity" and kind == "git_blob":
        rec = source_record(case["path"])
        value = rec["git_blob"]
        valid = value == case["claimed_blob"]
        witness = "Git object computed from original source bytes (plus independent SHA-256 recorded)"
    else:
        raise ValueError("unsupported claim family or kind")
    return {"id": case["id"], "family": family, "ground_truth": "valid" if valid else "invalid",
            "computed_value": str(value), "certificate_or_counterexample": witness}


def evaluate_all(source: Path = CASES) -> dict:
    cert_digest = check_global_certificate()
    cases = validate_cases(json.loads(source.read_text()))
    judgments = [evaluate(c) for c in cases]
    counts = Counter(j["ground_truth"] for j in judgments)
    if counts != {"valid": 8, "invalid": 8}:
        raise AssertionError("preregistered class balance violated")
    return {"schema": "nightfall.exec-review.oracle.v1",
            "source": "PUBLIC calibration only; no independent model trials, blind holdout or new theorem",
            "case_sha256": hashlib.sha256(source.read_bytes()).hexdigest(),
            "original_checker_stdout_sha256": cert_digest,
            "pinned_sources": [source_record(src) for src in sorted(PINS)],
            "cases": judgments, "counts": dict(counts)}


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--cases", type=Path, default=CASES)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    result = evaluate_all(args.cases)
    encoded = json.dumps(result, indent=2, sort_keys=True) + "\n"
    if args.output:
        args.output.write_text(encoded, encoding="utf-8")
    print(encoded)
    return 0


if __name__ == "__main__":
    sys.exit(main())

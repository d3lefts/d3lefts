#!/usr/bin/env python3
"""Independent exact-rational validation of finite Farkas infeasibility witnesses.

Purpose: tiny re-derivable certificate kernel, not a SAT/MIP solver or Lean checker.
The model is A x <= b, x free over Q.  A certificate is lambda >= 0,
lambda^T A = 0, and lambda^T b < 0.  All inputs are exact rational strings.
"""
from __future__ import annotations
import argparse
from fractions import Fraction
import hashlib
import json
from pathlib import Path

SCHEMA = "nightfall-farkas-infeasibility/v1"


def parse_q(x):
    if isinstance(x, bool) or not isinstance(x, (str, int)):
        raise ValueError("rational must be an integer or exact rational string")
    return Fraction(str(x))


def canonical_model(model):
    return json.dumps(model, sort_keys=True, separators=(",", ":"), ensure_ascii=True).encode()


def validate(payload):
    if not isinstance(payload, dict) or payload.get("schema") != SCHEMA:
        raise ValueError("unknown schema")
    model, cert = payload.get("model"), payload.get("certificate")
    if not isinstance(model, dict) or not isinstance(cert, dict):
        raise ValueError("missing model/certificate")
    A, b = model.get("A"), model.get("b")
    lam = cert.get("lambda")
    if not isinstance(A, list) or not A or not all(isinstance(r, list) for r in A) or not isinstance(b, list) or not isinstance(lam, list):
        raise ValueError("invalid matrix and vectors")
    m, n = len(A), len(A[0])
    if n < 1 or any(len(row) != n for row in A) or len(b) != m or len(lam) != m:
        raise ValueError("nonrectangular or mismatched dimensions")
    digest = hashlib.sha256(canonical_model(model)).hexdigest()
    if cert.get("model_sha256") != digest:
        raise ValueError("model digest mismatch")
    AA = [[parse_q(v) for v in row] for row in A]
    bb = [parse_q(v) for v in b]
    ll = [parse_q(v) for v in lam]
    if any(v < 0 for v in ll):
        raise ValueError("multiplier negative")
    residual = [sum((ll[i] * AA[i][j] for i in range(m)), Fraction(0)) for j in range(n)]
    if any(v != 0 for v in residual):
        raise ValueError("linear combination not identically zero")
    rhs = sum((ll[i] * bb[i] for i in range(m)), Fraction(0))
    if not rhs < 0:
        raise ValueError("combined upper bound does not contradict zero")
    return {"status": "PASS", "rows": m, "variables": n,
            "certificate_rhs": str(rhs), "model_sha256": digest,
            "scope": "exact rational Farkas infeasibility only; not a Lean kernel certificate"}


def self_test():
    model = {"A": [["-1", "0"], ["0", "-1"], ["1", "1"]],
             "b": ["-1", "-1", "1"]}
    import copy
    payload = {"schema": SCHEMA, "model": model,
               "certificate": {"lambda": ["1", "1", "1"],
                               "model_sha256": hashlib.sha256(canonical_model(model)).hexdigest()}}
    assert validate(payload)["certificate_rhs"] == "-1"
    mutants = []
    a = copy.deepcopy(payload); a["certificate"]["lambda"] = ["1", "0", "1"]; mutants.append(a)
    a = copy.deepcopy(payload); a["certificate"]["lambda"] = ["1", "-1", "1"]; mutants.append(a)
    a = copy.deepcopy(payload); a["certificate"]["lambda"] = ["0", "0", "0"]; mutants.append(a)
    a = copy.deepcopy(payload); a["model"]["b"][2] = "2"; mutants.append(a)
    a = copy.deepcopy(payload); a["model"]["b"][2] = "2"; a["certificate"]["model_sha256"] = hashlib.sha256(canonical_model(a["model"])).hexdigest(); mutants.append(a)
    a = copy.deepcopy(payload); a["certificate"]["lambda"][0] = "0.1"; mutants.append(a)
    a = copy.deepcopy(payload); a["certificate"]["lambda"][0] = 0.1; mutants.append(a)
    a = copy.deepcopy(payload); a["model"]["A"][1].pop(); mutants.append(a)
    for i, a in enumerate(mutants):
        try:
            validate(a)
        except (ValueError, ZeroDivisionError):
            pass
        else:
            raise AssertionError("mutation %d accepted" % i)
    # Different checker: exhaustive integer fence selection, not Farkas arithmetic.
    legal = [(x, y) for x in (0, 1) for y in (0, 1) if x >= 1 and y >= 1]
    assert legal == [(1, 1)] and not any(x + y <= 1 for x, y in legal)
    print("PASS: 1 exact rational Farkas witness; 8 negative controls; 4-state independent exhaustive fence check")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("certificate", nargs="?", type=Path)
    ap.add_argument("--self-test", action="store_true")
    args = ap.parse_args()
    if args.self_test:
        self_test()
    if args.certificate:
        print(json.dumps(validate(json.loads(args.certificate.read_text())),
                         indent=2, sort_keys=True))
    if not args.self_test and not args.certificate:
        ap.error("choose certificate or --self-test")


if __name__ == "__main__":
    main()

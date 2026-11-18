#!/usr/bin/env python3
"""Exact original-source robust observation-gain hull certificate (stdlib only).

The source is a complete finite product law with one potentially replaced
coordinate marginal q, another fixed marginal, and a true original mission
table. No optimizer or asserted Gram matrix is trusted. Build the centered
conditional-response vectors from the original table, then check the Gram,
a feasible minimizing law, and a supporting-vector dual inequality.

This proves a robust *squared prediction-error reduction*, not zero-error
authorization, a physical sensor guarantee, or a globally novel theorem.
"""
from __future__ import annotations
import argparse
import copy
from fractions import Fraction as Q
from hashlib import sha256
import json
from pathlib import Path

SCHEMA = "nightfall.robust-observation-hull.v1"
KIND = "finite-product-original-response/v1"


def frac(x):
    if isinstance(x, bool) or not isinstance(x, (str, int)):
        raise ValueError("Only exact integer/rational source values are allowed")
    return Q(str(x))


def canonical(obj):
    return json.dumps(obj, sort_keys=True, separators=(",", ":"), ensure_ascii=True).encode()


def digest(obj):
    return sha256(canonical(obj)).hexdigest()


def dot(u, v, p):
    return sum((p[z] * u[z] * v[z] for z in range(len(p))), Q(0))


def parse_source(src):
    if not isinstance(src, dict) or src.get("kind") != KIND:
        raise ValueError("unknown original source kind")
    if src.get("allowed_replacement_law") != "entire_probability_simplex":
        raise ValueError("unsupported replacement uncertainty")
    if src.get("loss") != "squared_error":
        raise ValueError("not a squared-loss certificate")
    if src.get("sources") != ["authority_epoch", "sensor_y"] or src.get("changed_marginal") != "authority_epoch":
        raise ValueError("unsupported source identity")
    if src.get("observed_target") != "sensor_y":
        raise ValueError("wrong observation target")
    alph = src.get("coordinate_alphabets")
    if not isinstance(alph, list) or len(alph) != 2:
        raise ValueError("source alphabets missing")
    if any(not isinstance(a, list) or not a or len(a) != len(set(a)) or
           any(not isinstance(v, str) for v in a) for a in alph):
        raise ValueError("invalid finite coordinate alphabets")
    m, n = map(len, alph)
    if not 2 <= m <= 10 or not 2 <= n <= 12:
        raise ValueError("unsafe enumeration dimensions")
    raw = src.get("mission_table")
    if not isinstance(raw, list) or len(raw) != m or any(not isinstance(r, list) or len(r) != n for r in raw):
        raise ValueError("mission table dimensions")
    f = [[frac(v) for v in row] for row in raw]
    pi = [frac(v) for v in src.get("fixed_second_marginal", [])]
    old = [frac(v) for v in src.get("original_first_marginal", [])]
    if len(pi) != n or len(old) != m:
        raise ValueError("source probability dimension")
    if any(v < 0 for v in pi + old) or sum(pi, Q(0)) != 1 or sum(old, Q(0)) != 1:
        raise ValueError("not a probability law")
    return f, pi, old


def source_response(f, pi):
    means = [sum((pi[z] * row[z] for z in range(len(pi))), Q(0)) for row in f]
    centered = [[row[z] - means[a] for z in range(len(pi))] for a, row in enumerate(f)]
    m = len(f)
    gram = [[dot(centered[a], centered[b], pi) for b in range(m)] for a in range(m)]
    return means, centered, gram


def evaluate(payload):
    if not isinstance(payload, dict) or payload.get("schema") != SCHEMA:
        raise ValueError("wrong certificate schema")
    src, cert = payload.get("source_model"), payload.get("certificate")
    if not isinstance(src, dict) or not isinstance(cert, dict):
        raise ValueError("missing source model or proof object")
    f, pi, old = parse_source(src)
    if digest(src) != cert.get("source_sha256"):
        raise ValueError("source SHA-256 mismatch")
    means, d, gram = source_response(f, pi)
    raw_gram = cert.get("response_gram")
    if not isinstance(raw_gram, list) or len(raw_gram) != len(gram) or any(
        not isinstance(row, list) or len(row) != len(gram) for row in raw_gram
    ):
        raise ValueError("gram dimensions")
    if [[frac(v) for v in row] for row in raw_gram] != gram:
        raise ValueError("submitted Gram matrix disagrees with original source")

    q = [frac(v) for v in cert.get("minimizer_law", [])]
    h = [frac(v) for v in cert.get("separating_response", [])]
    if len(q) != len(d) or any(x < 0 for x in q) or sum(q, Q(0)) != 1:
        raise ValueError("proposed adversarial law not in simplex")
    if len(h) != len(pi):
        raise ValueError("separation vector wrong dimension")
    response = [sum((q[a] * d[a][z] for a in range(len(q))), Q(0)) for z in range(len(pi))]
    if response != h:
        raise ValueError("separating vector is not the minimizing response")
    lam = frac(cert.get("robust_unobserved_gain"))
    if dot(h, h, pi) != lam:
        raise ValueError("reported robust gain not the squared response norm")
    # Global exact dual: for every source atom a, <h,d_a> >= ||h||².
    # For any q', let v=sum_a q'_a d_a. Then <h,v> >= ||h||² and
    # ||v||²-||h||² = ||v-h||²+2(<h,v>-||h||²) >= 0.
    for da in d:
        if dot(h, da, pi) < lam:
            raise ValueError("claimed minimizer violates global supporting hyperplane")
    norms = [dot(da, da, pi) for da in d]
    post = min(norms)
    if frac(cert.get("robust_observed_gain")) != post:
        raise ValueError("wrong after-observing-source robust value")
    initial_response = [sum((old[a] * d[a][z] for a in range(len(old))), Q(0))
                        for z in range(len(pi))]
    initial_gain = dot(initial_response, initial_response, pi)
    if frac(cert.get("original_law_unobserved_gain")) != initial_gain:
        raise ValueError("old law value mismatch")
    # The example claims one constant total resampling influence I_Y.
    if any(norm != norms[0] for norm in norms) or frac(cert.get("coordinate_influence_y")) != norms[0]:
        raise ValueError("the asserted law-uniform influence is false")
    threshold = frac(cert.get("squared_gain_threshold"))
    if not 0 < threshold <= post:
        raise ValueError("threshold does not separate the two action classes")
    if not lam < threshold:
        raise ValueError("one-observation policy already meets robust threshold")
    # The X-only value is zero under some replacement: any simplex vertex
    # makes X constant. For observing both, the exact minimum is min_a
    # Var_Y(f|X=a), attained at an X-vertex.
    minimum_fixed = 2 if lam < threshold else 1
    if cert.get("minimum_fixed_sensor_count_for_robust_threshold") != minimum_fixed:
        raise ValueError("incorrect minimum number of fixed whole-symbol sensors")
    return {
        "status": "PASS", "sources": len(d), "outcomes": len(pi),
        "source_sha256": digest(src), "robust_gain_without_changed_source": str(lam),
        "robust_gain_after_changed_source": str(post),
        "old_law_gain": str(initial_gain), "uniform_resampling_influence": str(norms[0]),
        "minimum_fixed_sensor_count": minimum_fixed,
        "mechanism": "original-response Gram + feasible interior marginal + exact supporting vector"
    }


def self_test(original):
    assert evaluate(original)["robust_gain_without_changed_source"] == "1/6"
    mutants = []
    def mutate(path, val):
        o = copy.deepcopy(original)
        target = o
        for key in path[:-1]:
            target = target[key]
        target[path[-1]] = val
        mutants.append(o)
    mutate(["certificate", "source_sha256"], "0" * 64)
    mutate(["certificate", "response_gram"], [["2/3", "0"], ["0", "2/3"]])
    mutate(["certificate", "minimizer_law"], ["1", "0"])
    mutate(["certificate", "minimizer_law"], ["-1", "2"])
    mutate(["certificate", "separating_response"], ["1", "0", "-1"])
    mutate(["certificate", "robust_unobserved_gain"], "2/3")
    mutate(["certificate", "robust_unobserved_gain"], "0")
    mutate(["certificate", "robust_observed_gain"], "1/6")
    mutate(["certificate", "original_law_unobserved_gain"], "1/6")
    mutate(["certificate", "coordinate_influence_y"], "1/6")
    mutate(["certificate", "squared_gain_threshold"], "1/8")
    mutate(["certificate", "minimum_fixed_sensor_count_for_robust_threshold"], 1)
    mutate(["source_model", "mission_table"], [["1", "-1", "0"], ["0", "0", "-1"]])
    mutate(["source_model", "fixed_second_marginal"], ["1/2", "1/2", "0"])
    mutate(["source_model", "original_first_marginal"], ["0", "0"])
    mutate(["source_model", "allowed_replacement_law"], "endpoints_only")
    mutate(["source_model", "loss"], "zero_error_authorization")
    mutate(["source_model", "mission_table"], [[1.0, "-1", "0"], ["0", "1", "-1"]])
    for i, bad in enumerate(mutants):
        try:
            evaluate(bad)
        except (ValueError, TypeError, KeyError, ZeroDivisionError):
            pass
        else:
            raise AssertionError(f"accepted invalid model or certificate mutation {i}")
    return len(mutants)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("file", type=Path)
    ap.add_argument("--self-test", action="store_true")
    a = ap.parse_args()
    obj = json.loads(a.file.read_text())
    if a.self_test:
        n = self_test(obj)
        print(f"PASS: {n} model/certificate negative controls rejected")
    print(json.dumps(evaluate(obj), indent=2, sort_keys=True))


if __name__ == "__main__":
    main()

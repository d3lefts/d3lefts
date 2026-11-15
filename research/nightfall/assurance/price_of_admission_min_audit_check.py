#!/usr/bin/env python3
"""Independent exact-rational 2-world baseline for The Price of Admission.

This enumerates randomized 3-way policies (audit, grant unverified, deny)
for indistinguishable safe and unsafe cheap-monitor transcripts. Audit is
assumed independent and perfect. It is a numerical cross-check of the
elementary symbolic lower bound, NOT a novel theorem or implementation
of a general autonomous safety monitor.
"""
import hashlib
import json
from fractions import Fraction


def main():
    required_safe_admission = Fraction(9, 10)
    max_unsafe_admission = Fraction(1, 100)
    independent_audit_price = Fraction(100)
    resolution = 100
    checked = 0
    feasible = 0
    optimal_cost = None
    optimal = []
    for i in range(resolution + 1):
        for j in range(resolution - i + 1):
            checked += 1
            audit = Fraction(i, resolution)
            grant_unaudited = Fraction(j, resolution)
            # For a perfect and safe-world-complete audit, the best possible
            # legitimate grant rate is audit+grant_unaudited.
            if audit + grant_unaudited < required_safe_admission:
                continue
            if grant_unaudited > max_unsafe_admission:
                continue
            feasible += 1
            cost = independent_audit_price * audit
            assert audit >= required_safe_admission - max_unsafe_admission, (
                "Candidate contradicts the proved lower bound"
            )
            if optimal_cost is None or cost < optimal_cost:
                optimal_cost = cost
                optimal = [(audit, grant_unaudited)]
            elif cost == optimal_cost:
                optimal.append((audit, grant_unaudited))
    floor = independent_audit_price * (
        required_safe_admission - max_unsafe_admission
    )
    assert optimal_cost == floor == 89
    assert (Fraction(89, 100), Fraction(1, 100)) in optimal
    assert checked == 5252
    result = {
        "model": "exact two-world cheap-monitor indistinguishability",
        "independent_audit": "perfect",
        "rejection_of_unsafe_without_audit": "not allowed unless denial",
        "safe_admission_min": str(required_safe_admission),
        "unsafe_admission_max": str(max_unsafe_admission),
        "audit_cost": str(independent_audit_price),
        "grid": "one-hundredth",
        "candidates": checked,
        "feasible": feasible,
        "optimal_audit_cost": str(optimal_cost),
        "witness_audit_probability": "89/100",
        "witness_unaudited_grant_probability": "1/100",
        "status": "exact_grid_crosscheck_passed",
        "novelty_claim": False,
    }
    data = json.dumps(result, sort_keys=True, indent=2)
    print(data)
    print("report_sha256=" + hashlib.sha256(data.encode()).hexdigest())


if __name__ == "__main__":
    main()

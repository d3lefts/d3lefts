#!/usr/bin/env python3
"""Independent integer-grid audit of the costed two-world admission theorem.

No use of the Lean model or theorem code.  All randomized mixtures with a
denominator of 100 are exhaustively tested as integer partitions. The Lean
proof covers ALL rational mixtures, not just this grid.
"""
import hashlib
import json


def scan(cap, restrict_enabled=True):
    count, winners, best = 0, [], None
    n_checked = 0
    for audited in range(101):
        for restricted in range(101 - audited):
            for unchecked in range(101 - audited - restricted):
                n_checked += 1
                denied = 100 - audited - restricted - unchecked
                if audited > cap:
                    continue
                if not restrict_enabled and restricted:
                    continue
                if unchecked > 1:
                    continue
                if 2 * audited + restricted + 2 * unchecked < 180:
                    continue
                count += 1
                cost_tenths = 10 * audited + restricted
                candidate = [audited, restricted, unchecked, denied]
                if best is None or cost_tenths < best:
                    best, winners = cost_tenths, [candidate]
                elif cost_tenths == best:
                    winners.append(candidate)
    assert n_checked == 176851
    return {
        "cap_hundredths": cap,
        "restriction_enabled": restrict_enabled,
        "total_randomized_mixtures": n_checked,
        "feasible_mixtures": count,
        "least_cost_tenths": best,
        "optimal_policy_hundredths": winners,
    }


def main():
    with_restriction = scan(79, True)
    impossible_78 = scan(78, True)
    audit_only = scan(100, False)
    audit_only_79 = scan(79, False)
    assert with_restriction["feasible_mixtures"] == 1
    assert with_restriction["least_cost_tenths"] == 810
    assert with_restriction["optimal_policy_hundredths"] == [[79, 20, 1, 0]]
    assert impossible_78["feasible_mixtures"] == 0
    assert audit_only["least_cost_tenths"] == 890
    assert audit_only_79["feasible_mixtures"] == 0
    result = {
        "name": "NIGHTFALL exact audit capacity + restricted effect model",
        "safe_world_service_min": "9/10",
        "unsafe_unchecked_admission_max": "1/100",
        "restricted_safe_world_utility": "1/2",
        "trusted_effect_time_audit_cost": "100 symbolic units",
        "restricted_effect_cost": "10 symbolic units",
        "an_independent_audit_must_finish_before_effect": True,
        "cheap_signal_assumption": "indistinguishable in safe and unsafe histories",
        "strategic_adversarial_robustness": "conditional on cheap-blindspot and trusted effect model",
        "current_prior_art_novelty": "not established: elementary finite linear programming",
        "with_restriction": with_restriction,
        "insufficient_audit_capacity": impossible_78,
        "audit_only_with_capacity_100": audit_only,
        "audit_only_with_capacity_79": audit_only_79,
        "status": "exact_integer_grid_pass",
    }
    payload = json.dumps(result, indent=2, sort_keys=True)
    print(payload)
    print("sha256=" + hashlib.sha256(payload.encode()).hexdigest())


if __name__ == "__main__":
    main()

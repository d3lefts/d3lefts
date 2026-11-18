#!/usr/bin/env python3
"""Public metadata consistency only. Does not attest hidden tests."""
import json
from pathlib import Path

def reject_duplicates(pairs):
    obj = {}
    for key, value in pairs:
        if key in obj:
            raise ValueError("duplicate JSON key")
        obj[key] = value
    return obj

r = json.loads((Path(__file__).with_name("V03_RECEIPT.json")).read_text(), object_pairs_hook=reject_duplicates)
assert r["audit_id"] == "NIGHTFALL-DISPATCHQ-B1-GRADER-V03-20261118"
assert r["status"] == "internal_author_side_calibration_only"
for key in ("prerecorded_source_sha256", "starter_source_sha256", "original_preregistration_sha256",
            "v02_grader_sha256", "v03_grader_sha256", "v03_bounded_launcher_sha256",
            "private_v03_archive_sha256"):
    value = r[key]
    assert isinstance(value, str) and len(value) == 64 and all(c in "0123456789abcdef" for c in value), key
assert r["v02_grader_sha256"] != r["v03_grader_sha256"]
assert (r["v02_total_tests"], r["v03_total_tests"]) == (25, 37)
assert r["score_ceiling_v02"] == r["score_ceiling_v03"] == 100
assert r["preregistered_new_mutation_families"] == r["v02_new_mutations_full_credit"] == 12
assert r["v03_new_mutations_full_credit"] == r["v03_old_mutations_full_credit"] == 0
assert r["v03_total_tested_non_equivalent_mutants"] == r["v03_total_mutants_rejected"] == 24
assert len(r["reference_v03_repeat_scores"]) == 5 and set(r["reference_v03_repeat_scores"]) == {100}
assert sorted(r["starter_v03_repeat_scores"]) == [58, 58, 58, 58, 66]
assert r["reference_contract_witness_controls"] == r["mutant_contract_witness_failures"] == 12
assert r["bounded_launcher_control"]["synthetic_sleep_status"] == "blocked_timeout"
assert r["bounded_launcher_control"]["synthetic_sleep_score_present"] is False
assert r["blind_agent_attempts"] == 0 and r["human_independent_review"] is False
assert r["python_310_private_replay"] is False and r["local_python_version"] == "3.13.5"
print("PASS: receipt internally consistent; NOT a private scorer replay or independent certification.")

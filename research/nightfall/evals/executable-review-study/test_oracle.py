"""Public oracle and scorer calibration tests (no agents run)."""
from collections import Counter
from copy import deepcopy
from fractions import Fraction as Q
import json
import unittest

from oracle import (
    PINS, BERN, CERT, CASES, source_record, exact_polynomial,
    check_global_certificate, entropy_of_counts, mutual_information,
    rational_rank, diagonal_product, evaluate_all, validate_cases, evaluate,
)
from score import score_submission


def submission_for(gold, judgment="valid"):
    return {
        "schema": "nightfall.exec-review.submission.v1",
        "reviewer_id": "synthetic-test-fixture-not-an-agent",
        "condition": "prose_only",
        "case_sha256": gold["case_sha256"],
        "answers": [{"id": x["id"],
                     "verdict": (x["ground_truth"] if judgment == "oracle" else judgment),
                     "reasoning": "synthetic scorer test; not independent review"}
                    for x in gold["cases"]],
    }


class ExactMechanismTests(unittest.TestCase):
    def test_original_source_pins(self):
        self.assertEqual(source_record(BERN)["git_blob"], PINS[BERN])
        self.assertEqual(source_record(CERT)["git_blob"], PINS[CERT])

    def test_original_global_certificate_replays(self):
        self.assertRegex(check_global_certificate(), r"^[0-9a-f]{64}$")

    def test_polynomial_witness_and_exact_arithmetic(self):
        self.assertEqual(exact_polynomial(Q(0), Q(0)), 0)
        self.assertEqual(exact_polynomial(Q(1), Q(0)), 2)
        self.assertGreaterEqual(exact_polynomial(Q(1, 2), Q(1, 2)), 0)

    def test_modular_independent_versus_diagonal(self):
        for law, stat, expected in (
            ("independent", "single_T", 0), ("independent", "joint", 2),
            ("diagonal", "single_T", 1), ("diagonal", "joint", 1),
        ):
            with self.subTest(law=law, stat=stat):
                self.assertEqual(mutual_information({"r": 4, "law": law, "condition": stat}), expected)

    def test_non_dyadic_entropy_fails_closed(self):
        with self.assertRaisesRegex(ValueError, "non-dyadic"):
            entropy_of_counts(Counter({0: 1, 1: 2}))

    def test_diagonal_rank_and_exact_mixture_bound(self):
        for n in (1, 2, 3, 4):
            with self.subTest(n=n):
                self.assertEqual(diagonal_product({"kind": "min_components", "n": n})[0], 2**n)

    def test_genuine_counterexample_checks(self):
        cases = validate_cases(json.loads(CASES.read_text()))
        for cid in ("P02", "P04", "S02", "S04", "D02", "D04", "H02", "H04"):
            case = next(c for c in cases if c["id"] == cid)
            self.assertEqual(evaluate(case)["ground_truth"], "invalid", cid)

    def test_frozen_16_claims_eight_eight(self):
        result = evaluate_all()
        self.assertEqual(result["counts"], {"valid": 8, "invalid": 8})
        self.assertEqual(len(result["cases"]), 16)
        self.assertEqual(len(result["pinned_sources"]), 2)
        self.assertEqual(len({c["id"] for c in result["cases"]}), 16)

    def test_duplicate_id_is_fatal(self):
        payload = json.loads(CASES.read_text())
        payload["cases"][1]["id"] = payload["cases"][0]["id"]
        with self.assertRaisesRegex(ValueError, "duplicate"):
            validate_cases(payload)

    def test_source_path_cannot_escape_whitelist(self):
        with self.assertRaisesRegex(ValueError, "unregistered"):
            source_record("../secrets")


class ScorerBoundaryTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.gold = evaluate_all()

    def test_all_valid_is_8_of_16_with_eight_false_accepts(self):
        report = score_submission(submission_for(self.gold, "valid"), self.gold)
        self.assertEqual((report["correct"], report["false_accept"], report["false_reject"]), (8, 8, 0))

    def test_all_invalid_is_8_of_16_with_eight_false_rejects(self):
        report = score_submission(submission_for(self.gold, "invalid"), self.gold)
        self.assertEqual((report["correct"], report["false_accept"], report["false_reject"]), (8, 0, 8))

    def test_abstention_cannot_be_counted_as_correct(self):
        report = score_submission(submission_for(self.gold, "uncertain"), self.gold)
        self.assertEqual((report["correct"], report["abstain"]), (0, 16))

    def test_perfect_synthetic_fixture_is_not_model_result(self):
        report = score_submission(submission_for(self.gold, "oracle"), self.gold)
        self.assertEqual((report["correct"], report["false_accept"], report["false_reject"]), (16, 0, 0))
        self.assertIs(report["condition_enforced_by_oracle"], False)
        self.assertIs(report["blind_holdout"], False)

    def test_rejects_duplicate_submission_case(self):
        s = submission_for(self.gold)
        s["answers"][1]["id"] = s["answers"][0]["id"]
        with self.assertRaisesRegex(ValueError, "duplicated"):
            score_submission(s, self.gold)

    def test_rejects_changed_case_bank_hash(self):
        s = submission_for(self.gold)
        s["case_sha256"] = "0" * 64
        with self.assertRaisesRegex(ValueError, "frozen"):
            score_submission(s, self.gold)

    def test_rejects_missing_answers(self):
        s = submission_for(self.gold)
        s["answers"].pop()
        with self.assertRaisesRegex(ValueError, "all preregistered"):
            score_submission(s, self.gold)

    def test_wrong_review_condition_fails(self):
        s = submission_for(self.gold)
        s["condition"] = "secret-third-arm"
        with self.assertRaisesRegex(ValueError, "condition"):
            score_submission(s, self.gold)


if __name__ == "__main__":
    unittest.main()

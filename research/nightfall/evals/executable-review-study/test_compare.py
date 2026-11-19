"""Check paired arithmetic; all samples are synthetic scoring fixtures, not agent experiments."""
import unittest
from copy import deepcopy
from fractions import Fraction as Q

from oracle import evaluate_all
from score import score_submission
from compare import compare, mcnemar_two_sided_exact


def make_score(gold, condition, reviewer_id, verdict):
    payload = {
        "schema": "nightfall.exec-review.submission.v1",
        "condition": condition,
        "reviewer_id": reviewer_id,
        "case_sha256": gold["case_sha256"],
        "answers": [{"id": c["id"], "verdict": verdict, "reasoning": "synthetic test only"}
                    for c in gold["cases"]],
    }
    return score_submission(payload, gold)


class PairedScorerTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.gold = evaluate_all()

    def test_identical_naive_reviews_have_null_discordance(self):
        a = make_score(self.gold, "prose_only", "synthetic-p", "valid")
        b = make_score(self.gold, "executable", "synthetic-e", "valid")
        r = compare(a, b)
        self.assertEqual(r["mcnemar_exact_two_sided_p"], "1")
        self.assertEqual(r["false_accept_reduction_fraction"], "0")
        self.assertIs(r["causal_claim_permitted"], False)

    def test_synthetic_extreme_arms_compute_exact_discordance(self):
        a = make_score(self.gold, "prose_only", "synthetic-p", "valid")
        b = make_score(self.gold, "executable", "synthetic-e", "invalid")
        r = compare(a, b)
        self.assertEqual(r["false_accept_reduction_fraction"], "1")
        self.assertEqual(r["false_reject_increase_fraction"], "1")
        self.assertEqual(r["paired_discordant_prose_bad_exec_good"], 8)
        self.assertEqual(r["paired_discordant_prose_good_exec_bad"], 0)
        self.assertEqual(r["mcnemar_exact_two_sided_p"], "1/128")
        self.assertIs(r["verified_equal_budgets"], False)

    def test_reversed_effect_detected(self):
        a = make_score(self.gold, "prose_only", "synthetic-p", "invalid")
        b = make_score(self.gold, "executable", "synthetic-e", "valid")
        r = compare(a, b)
        self.assertEqual(r["false_accept_reduction_fraction"], "-1")

    def test_mcnemar_symmetry_and_zero_discordants(self):
        self.assertEqual(mcnemar_two_sided_exact(0, 0), 1)
        self.assertEqual(mcnemar_two_sided_exact(3, 1), mcnemar_two_sided_exact(1, 3))
        self.assertEqual(mcnemar_two_sided_exact(8, 0), Q(1,128))

    def test_no_same_reviewer_id(self):
        a = make_score(self.gold, "prose_only", "same", "valid")
        b = make_score(self.gold, "executable", "same", "valid")
        with self.assertRaisesRegex(ValueError, "distinct"):
            compare(a, b)

    def test_no_silent_gold_hash_substitution(self):
        a = make_score(self.gold, "prose_only", "synthetic-p", "valid")
        b = make_score(self.gold, "executable", "synthetic-e", "valid")
        b["case_sha256"] = "0"*64
        with self.assertRaisesRegex(ValueError, "same frozen"):
            compare(a, b)

    def test_forged_condition_enforcement_is_rejected(self):
        a = make_score(self.gold, "prose_only", "synthetic-p", "valid")
        b = make_score(self.gold, "executable", "synthetic-e", "valid")
        b["condition_enforced_by_oracle"] = True
        with self.assertRaisesRegex(ValueError, "falsely enforced"):
            compare(a, b)


if __name__ == "__main__":
    unittest.main()

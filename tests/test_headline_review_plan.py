#!/usr/bin/env python3
"""Mutation tests for the unexecuted eight-track independent review preregistration."""
import copy
import importlib.util
import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
def load(name, path):
    sp = importlib.util.spec_from_file_location(name, ROOT / path)
    m = importlib.util.module_from_spec(sp)
    sp.loader.exec_module(m)
    return m
review = load("review_plan", "scripts/check_headline_review_plan.py")
plan = json.loads((ROOT / review.PATH).read_text())
ledger = json.loads((ROOT / review.LEDGER).read_text())


class ReviewPlanTests(unittest.TestCase):
    def test_all_eight_preregistered_but_no_independent_work_claimed(self):
        x = review.validate(plan, ledger)
        self.assertEqual(x["plans"], 8)
        self.assertEqual(x["independent_reviews_executed"], 0)

    def test_forged_review_completed(self):
        x = copy.deepcopy(plan)
        x["trials"][0]["independent_audit_completed"] = True
        with self.assertRaises(ValueError):
            review.validate(x, ledger)

    def test_retrospective_result(self):
        x = copy.deepcopy(plan)
        x["trials"][1]["receipt"] = {"status": "PASS"}
        with self.assertRaises(ValueError):
            review.validate(x, ledger)

    def test_missing_discriminator(self):
        x = copy.deepcopy(plan)
        x["trials"][2]["discriminator"] = ""
        with self.assertRaises(ValueError):
            review.validate(x, ledger)

    def test_missing_track(self):
        x = copy.deepcopy(plan)
        x["trials"].pop()
        with self.assertRaises(ValueError):
            review.validate(x, ledger)

    def test_role_labels_cannot_attest_independence(self):
        x = copy.deepcopy(plan)
        x["independence_not_established"] = False
        with self.assertRaises(ValueError):
            review.validate(x, ledger)


if __name__ == "__main__":
    unittest.main()

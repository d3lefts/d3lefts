#!/usr/bin/env python3
"""Independent mutation suites for source custody and exact finite query cost."""
import copy
import importlib.util
import json
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def load_module(name, path):
    spec = importlib.util.spec_from_file_location(name, ROOT / path)
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


scope = load_module("headline_scope", "scripts/check_headline_trust.py")
cost = load_module("finite_cost", "scripts/check_finite_query_cost.py")
manifest = json.loads((ROOT / scope.REL).read_text())
fixture = json.loads((ROOT / "research/nightfall/verification/route1_finite_cost_smoke.json").read_text())


class HeadlineBoundaryTests(unittest.TestCase):
    def test_eight_tracks_pass_structural_review(self):
        r = scope.validate(manifest)
        self.assertEqual((r["tracks"], r["lean_source_anchors"]), (8, 9))
        self.assertFalse(r["kernel_replayed"])

    def test_all_real_sources_match_and_have_named_declarations(self):
        r = scope.validate(manifest, ROOT)
        self.assertEqual(r["status"], "SOURCE_BOUND_NO_PROMOTION")

    def test_reordered_or_missing_track(self):
        m = copy.deepcopy(manifest)
        m["records"].pop()
        with self.assertRaises(ValueError):
            scope.validate(m)

    def test_forged_promotion(self):
        m = copy.deepcopy(manifest)
        m["records"][0]["independent_kernel_replay_this_change"] = True
        with self.assertRaises(ValueError):
            scope.validate(m)

    def test_novelty_forgery(self):
        m = copy.deepcopy(manifest)
        m["records"][2]["dated_prior_art_cleared"] = True
        with self.assertRaises(ValueError):
            scope.validate(m)

    def test_unsupported_evidence_tier(self):
        m = copy.deepcopy(manifest)
        m["records"][5]["evidence"] = "global-theorem"
        with self.assertRaises(ValueError):
            scope.validate(m)

    def test_source_blob_mutation(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            rel = "research/nightfall/example.lean"
            f = root / rel
            f.parent.mkdir(parents=True)
            f.write_text("theorem sample : True := by trivial\n")
            d = {"path": rel, "declaration": "Nightfall.sample",
                 "git_blob_sha1": scope.git_blob_id(f.read_bytes())}
            scope.check_source(root, d)
            f.write_text("theorem sample : True := by trivial\n-- hidden drift\n")
            with self.assertRaisesRegex(ValueError, "SOURCE_BLOB_DRIFT"):
                scope.check_source(root, d)

    def test_comment_cannot_spoof_declaration(self):
        with self.assertRaises(ValueError):
            scope.check_declaration("-- theorem target : True\n", "Nightfall.target")


class CostModelTests(unittest.TestCase):
    def test_exact_expectation(self):
        res = cost.check_contract(fixture)
        self.assertEqual((res["expected_oracle_calls"], res["worst_case_calls"]), ("3/2", 2))
        self.assertEqual(sum(cost.Fraction(v) for v in res["outcome_masses"].values()), 1)

    def test_false_expected_bound(self):
        s = copy.deepcopy(fixture)
        s["expected_upper_bound"] = "4/3"
        with self.assertRaises(ValueError):
            cost.check_contract(s)

    def test_false_worst_bound(self):
        s = copy.deepcopy(fixture)
        s["worst_upper_bound"] = 1
        with self.assertRaises(ValueError):
            cost.check_contract(s)

    def test_invalid_probability(self):
        s = copy.deepcopy(fixture)
        s["tree"]["p_yes"] = "4/3"
        with self.assertRaises(ValueError):
            cost.check_contract(s)

    def test_nonexact_decimal_fails(self):
        s = copy.deepcopy(fixture)
        s["tree"]["p_yes"] = "0.5"
        with self.assertRaises(ValueError):
            cost.check_contract(s)

    def test_new_unproved_claim_fails(self):
        s = copy.deepcopy(fixture)
        s["general_query_simulation_proven"] = True
        with self.assertRaises(ValueError):
            cost.check_contract(s)

    def test_zero_denominator_fails(self):
        s = copy.deepcopy(fixture)
        s["tree"]["p_yes"] = "1/0"
        with self.assertRaises(ValueError):
            cost.check_contract(s)

    def test_negative_charge_fails(self):
        s = copy.deepcopy(fixture)
        s["tree"]["oracle_calls"] = -1
        with self.assertRaises(ValueError):
            cost.check_contract(s)

    def test_invalid_tree_extra_key_fails(self):
        s = copy.deepcopy(fixture)
        s["tree"]["hidden_proof"] = True
        with self.assertRaises(ValueError):
            cost.check_contract(s)


if __name__ == "__main__":
    unittest.main()

#!/usr/bin/env python3
"""Synthetic-only tests. No AgentDojo inference occurs or results are claimed."""
import copy
import unittest
from score_paired import ARMS, SEEDS, AuditError, audit_manifest, score

COMMIT = "357c80dea9af34323f709c3505d9e6d224654c7e"


def synthetic(attack_gate=False, task_gate=True):
    ids = [f"synthetic-{i:02d}" for i in range(40)]
    manifest = {
        "upstream_commit": COMMIT,
        "task_ids": ids,
        "seeds": list(SEEDS),
        "arms": list(ARMS),
        "evidence_kind": "synthetic_fixture",
    }
    data = []
    for task_id in ids:
        for seed in SEEDS:
            for arm in ARMS:
                data.append({
                    "task_id": task_id,
                    "seed": seed,
                    "arm": arm,
                    "attack_success": (attack_gate if arm == "authority_gate" else True),
                    "user_success": (task_gate if arm == "authority_gate" else True),
                    "blocked_actions": int(arm == "authority_gate"),
                    "run_status": "completed",
                })
    return manifest, data


class ScorerTests(unittest.TestCase):
    def test_exact_paired_grid_and_signal(self):
        manifest, rows = synthetic(attack_gate=False)
        r = score(manifest, rows, 500)
        self.assertEqual(r["completed_trajectories"], 800)
        self.assertEqual(r["task_clusters"], 40)
        self.assertEqual(r["baseline_minus_gate_asr_reduction"], 1)
        self.assertEqual(r["paired_task_bootstrap_95pct"], [1., 1.])
        self.assertEqual(r["predeclared_signal_gate"], "PASS_UNREVIEWED")
        self.assertIn("SYNTHETIC", r["interpretation"])

    def test_no_effect_fails(self):
        m, rows = synthetic(attack_gate=True)
        r = score(m, rows, 200)
        self.assertEqual(r["predeclared_signal_gate"], "INCONCLUSIVE")
        self.assertEqual(r["paired_task_bootstrap_95pct"], [0., 0.])

    def test_utility_harm_fails(self):
        m, rows = synthetic(attack_gate=False, task_gate=False)
        r = score(m, rows, 200)
        self.assertEqual(r["baseline_minus_gate_legitimate_completion_loss"], 1)
        self.assertEqual(r["predeclared_signal_gate"], "FAILS_MINIMUM_EFFECT_OR_UTILITY")

    def test_missing_arm_rejected(self):
        m, rows = synthetic()
        with self.assertRaisesRegex(AuditError, "incomplete"):
            score(m, rows[:-1], 200)

    def test_duplicate_arm_rejected(self):
        m, rows = synthetic()
        with self.assertRaisesRegex(AuditError, "duplicate"):
            score(m, rows + [copy.deepcopy(rows[-1])], 200)

    def test_provider_error_rejected(self):
        m, rows = synthetic()
        rows[5]["run_status"] = "provider_error"
        with self.assertRaisesRegex(AuditError, "failed/incomplete"):
            score(m, rows, 200)

    def test_non_boolean_success_rejected(self):
        m, rows = synthetic()
        rows[6]["attack_success"] = "true"
        with self.assertRaisesRegex(AuditError, "must be bool"):
            score(m, rows, 200)

    def test_ineligible_task_rejected(self):
        m, rows = synthetic()
        rows[0]["task_id"] = "unknown"
        with self.assertRaisesRegex(AuditError, "unexpected"):
            score(m, rows, 200)

    def test_manifest_must_be_real_when_marked_real(self):
        m, rows = synthetic()
        m["evidence_kind"] = "provider_experiment"
        with self.assertRaisesRegex(AuditError, "model revision"):
            score(m, rows, 200)

    def test_reproducible_bootstrap(self):
        m, rows = synthetic()
        self.assertEqual(score(m, rows, 200), score(m, rows, 200))


if __name__ == "__main__":
    unittest.main()

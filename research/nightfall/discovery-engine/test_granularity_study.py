"""Adversarial and reproducibility checks for the held-out granularity study."""
import json
import random
import unittest
from adaptive_resolution import build_hierarchy,refine_after_failure
from granularity_oracle import overlap_certificate,source_certificate
from granularity_study import (ATOMIC,ADAPTIVE,FIXED,POLICIES,fixture,segment,
                               evaluate_case,run_study)


class GranularityStudyTests(unittest.TestCase):
    def test_oracle_and_mutations(self):
        b=b"10010100"
        a=overlap_certificate(b,3)
        self.assertEqual(sum(a["hist"]),6)
        self.assertGreaterEqual(a["max"],a["lower"])
        with self.assertRaises(ValueError):overlap_certificate(b,4)
        with self.assertRaises(ValueError):overlap_certificate(b"10210",2)
        raw=b"111100001111"
        self.assertTrue(source_certificate(raw,(4,8),0,4))
        self.assertFalse(source_certificate(raw,(4,8),3,9))
        self.assertFalse(source_certificate(raw,(4,8),4,8))
        with self.assertRaises(ValueError):source_certificate(raw,(4,8),0,13)

    def test_boundaries_and_provenance(self):
        for domain in ("overlap_proxy","source_spans_proxy"):
            f=fixture(domain,1729)
            for policy in (ATOMIC,FIXED,ADAPTIVE,*POLICIES):
                t=segment(f["raw"],f["hard"],policy)
                self.assertEqual(t.dechunk(f["raw"]),f["raw"])
                for i in f["hard"]:
                    self.assertIn(i,{x.end for x in t.coarse})
                altered=bytearray(f["raw"])
                altered[0]=48 if altered[0]==49 else 49
                with self.assertRaises(ValueError):t.audit(bytes(altered))

    def test_exact_budget_and_replay(self):
        for domain in ("overlap_proxy","source_spans_proxy"):
            f=fixture(domain,2026)
            x=evaluate_case(f,FIXED)
            y=evaluate_case(f,FIXED)
            self.assertEqual(x,y)
            self.assertEqual(x["exact_calls"],8)
            self.assertGreater(x["coarse_ops"],0)
            z=evaluate_case(f,ADAPTIVE)
            self.assertEqual(z["exact_calls"],x["exact_calls"])
            self.assertEqual(z["case_sha256"],x["case_sha256"])

    def test_hidden_labels_cannot_affect_candidate_selection(self):
        source=fixture("source_spans_proxy",2026)
        self.assertNotEqual(source["raw"],source["truth"])
        inverted={**source,"truth":bytes(49 if b==48 else 48 for b in source["truth"])}
        for policy in (ATOMIC,FIXED,ADAPTIVE,*POLICIES):
            a=evaluate_case(source,policy)
            b=evaluate_case(inverted,policy)
            self.assertEqual(a["case_sha256"],b["case_sha256"])
            self.assertEqual(a["selected_slots"],b["selected_slots"])
            self.assertEqual(a["coarse_ops"],b["coarse_ops"])
            self.assertNotEqual(a["annotation_sha256"],b["annotation_sha256"])

    def test_train_heldout_nonleakage(self):
        r=run_study(seed=1729,training=3,testing=3)
        self.assertEqual(r["selection_search_count"],len(POLICIES))
        for domain,policies in r["results"].items():
            for policy in policies.values():
                self.assertEqual(policy["exact_calls"],24)
                self.assertEqual(policy["cases"],3)
            self.assertEqual(len(set(r["raw_identity_sha256"][domain]["train"])&
                                 set(r["raw_identity_sha256"][domain]["test"])),0)
        self.assertEqual(r,run_study(seed=1729,training=3,testing=3))


if __name__=="__main__":
    unittest.main()

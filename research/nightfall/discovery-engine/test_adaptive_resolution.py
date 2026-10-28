"""Lossless hierarchy and adversarial invariance checks; Python standard library."""
import random
import unittest
from dataclasses import replace
from adaptive_resolution import (build_hierarchy, refine_after_failure,
                                  assert_source_provenance, digest)

class ResolutionTests(unittest.TestCase):
    def test_empty(self):
        t = build_hierarchy(b'')
        self.assertEqual(t.dechunk(b''), b'')

    def test_random_losslessness(self):
        random.seed(7)
        for n in range(1, 300):
            raw = random.randbytes(n)
            scores = {i:random.random() for i in range(1,n)}
            t = build_hierarchy(raw,signals=scores,max_fine_bytes=11,max_coarse_children=3)
            self.assertEqual(t.dechunk(raw), raw)
            self.assertEqual(t.dechunk(raw,'fine'), raw)

    def test_adaptive_boundaries(self):
        data = b'AAAAAAAABBBBBBBBCCCCCCCC'
        t = build_hierarchy(data,signals={8:1.0,16:0.7},max_fine_bytes=8)
        self.assertIn(8,[c.end for c in t.coarse])
        self.assertIn(16,[c.end for c in t.fine])
        self.assertNotIn(16,[c.end for c in t.coarse])
        u = refine_after_failure(data,t,16,signals={8:1.0,16:0.7},max_fine_bytes=8)
        self.assertIn(16,[c.end for c in u.coarse])
        self.assertEqual(u.dechunk(data),data)
        self.assertNotEqual(len(u.coarse),len(t.coarse))

    def test_exact_checker_invariant_under_segmentation(self):
        raw = b'0,1,0,1,0,1,0,1; CLAIM: exact witness'
        trees = [build_hierarchy(raw,max_fine_bytes=z) for z in (1,2,4,8,16,64)]
        expected = raw.count(b'0,1')
        for t in trees:
            self.assertEqual(t.dechunk(raw).count(b'0,1'),expected)
            assert_source_provenance(t,submitted_source_sha256=digest(raw),exact_checker_passed=True)
        with self.assertRaises(ValueError):
            assert_source_provenance(trees[-1],submitted_source_sha256='0'*64,exact_checker_passed=True)
        with self.assertRaises(ValueError):
            assert_source_provenance(trees[-1],submitted_source_sha256=digest(raw),exact_checker_passed=False)

    def test_utf8_and_byte_splits(self):
        raw = 'a-世界-b'.encode('utf-8')
        t = build_hierarchy(raw,hard_boundaries={3},max_fine_bytes=2)
        self.assertEqual(t.dechunk(raw),raw)
        self.assertIn(3,[c.start for c in t.coarse])

    def test_corruption_and_stale_source(self):
        raw=b'exact-research-source-binary'
        t=build_hierarchy(raw,max_fine_bytes=4)
        with self.assertRaises(ValueError): t.audit(raw+b'!')
        bad=replace(t,fine=(replace(t.fine[0],digest='f'*64),)+t.fine[1:])
        with self.assertRaises(ValueError): bad.audit(raw)
        bad2=replace(t,coarse=(replace(t.coarse[0],start=1),)+t.coarse[1:])
        with self.assertRaises(ValueError): bad2.audit(raw)

    def test_bad_signal_inputs(self):
        for data in ({0:1},{4:1},{1:1.2},{1:float('nan')}):
            with self.assertRaises(ValueError):build_hierarchy(b'abc',signals=data)
        with self.assertRaises(ValueError):build_hierarchy(b'abc',hard_boundaries={3})

if __name__=='__main__': unittest.main()

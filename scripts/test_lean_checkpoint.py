#!/usr/bin/env python3
"""Resource, identity and evidence controls. No research proof rebuild."""
import json
import os
import sys
import tempfile
import unittest
from pathlib import Path
import lean_checkpoint as c


class Controls(unittest.TestCase):
    def setUp(self):
        self.t = tempfile.TemporaryDirectory()
        self.addCleanup(self.t.cleanup)
        self.root = Path(self.t.name)
        for name in ('A', 'B'):
            (self.root/(name+'.lean')).write_text('theorem t : True := True.intro\n')
        self.plan = {'modules': {'A': {'source': 'A.lean', 'imports': []}, 'B': {'source': 'B.lean', 'imports': ['A']}}, 'terminal': {'module': 'B', 'declarations': ['beta']}}

    def test_topological_order(self):
        self.assertEqual(c.plan_order(self.plan, self.root), ['A', 'B'])

    def test_missing_dependency(self):
        self.plan['modules']['B']['imports'] = ['C']
        with self.assertRaises(RuntimeError):
            c.plan_order(self.plan, self.root)

    def test_cycle(self):
        self.plan['modules']['A']['imports'] = ['B']
        with self.assertRaises(RuntimeError):
            c.plan_order(self.plan, self.root)

    def test_scope(self):
        self.plan['terminal']['declarations'] = []
        with self.assertRaises(RuntimeError):
            c.plan_order(self.plan, self.root)

    def test_standard_axioms(self):
        c.audit("'beta' depends on axioms: [propext, Classical.choice]", ['beta'])
        c.audit("'beta' does not depend on any axioms", ['beta'])

    def test_missing_axiom_audit(self):
        with self.assertRaises(RuntimeError):
            c.audit("'alpha' does not depend on any axioms", ['beta'])

    def test_custom_axiom(self):
        with self.assertRaises(RuntimeError):
            c.audit("'beta' depends on axioms: [unproved]", ['beta'])

    def test_sorry(self):
        with self.assertRaises(RuntimeError):
            c.audit("'beta' depends on axioms: [sorryAx]", ['beta'])

    def test_timeout(self):
        log = self.root/'timeout.log'
        with self.assertRaises(RuntimeError):
            c.bounded([sys.executable, '-c', 'import time; time.sleep(5)'], os.environ, log, 2560, .2, self.root)
        self.assertEqual(c.read(self.root/'timeout.log.json')['status'], 'resource-timeout')

    def test_compiler_failure(self):
        log = self.root/'failure.log'
        with self.assertRaises(RuntimeError):
            c.bounded([sys.executable, '-c', 'raise SystemExit(7)'], os.environ, log, 2560, 5, self.root)
        self.assertEqual(c.read(self.root/'failure.log.json')['exit'], 7)

    def test_artifact_corruption(self):
        obj = self.root/'object'
        obj.mkdir()
        (obj/'A.olean').write_bytes(b'object')
        (obj/'source.lean').write_text('source')
        (obj/'compile.log').write_text('compiled')
        c.write(obj/'compile.log.json', {'exit': 0, 'status': 'passed'})
        identity = {'source': c.digest(obj/'source.lean')}
        c.write(obj/'manifest.json', {'identity': identity, 'artifacts': c.artifact_hashes(obj), 'compile_log': c.digest(obj/'compile.log'), 'compile_status': c.digest(obj/'compile.log.json')})
        self.assertTrue(c.check_entry(obj, identity, 'A'))
        (obj/'A.olean').write_bytes(b'altered')
        with self.assertRaises(RuntimeError):
            c.check_entry(obj, identity, 'A')


if __name__ == '__main__':
    unittest.main(verbosity=2)

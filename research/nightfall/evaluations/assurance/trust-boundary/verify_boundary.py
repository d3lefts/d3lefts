#!/usr/bin/env python3
"""Self-contained TRUST BOUNDARY proof test. No hidden benchmark data.

Demonstrates (1) a candidate can poison in-process unittest scoring;
(2) out-of-process black-box scoring resists *that specific* attack;
(3) a hash of one module is not a source snapshot.
"""
from __future__ import annotations
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import textwrap
import unittest

SCORE_IN_PROCESS = r'''
import json, sys, unittest
from pathlib import Path
sys.path.insert(0, sys.argv[1])
class TestValue(unittest.TestCase):
    def test_answer(self):
        from target import answer
        self.assertEqual(answer(), 1)
# Candidate import changes a mutable test runner in this same process.
import target
result = unittest.TextTestRunner(stream=open('/dev/null', 'w')).run(unittest.defaultTestLoader.loadTestsFromTestCase(TestValue))
print(json.dumps({'score': 100 if result.wasSuccessful() else 0, 'tests_run': result.testsRun}))
'''

# Candidate's initializer is intentionally poisonous, but runs only in child processes.
ATTACK = r'''
import unittest
class FakeRunner:
    def __init__(self,*args,**kwargs): pass
    def run(self,suite):
        class FakeResult:
            def wasSuccessful(self): return True
            testsRun = 1
        return FakeResult()
unittest.TextTestRunner=FakeRunner
from .value import answer
'''

GOOD = 'from .value import answer\n'
BAD_VALUE = 'def answer():\n    return 0\n'

CHILD_WORKER = r'''
import json,sys
sys.path.insert(0,sys.argv[1])
from target import answer
print(json.dumps({'answer':answer()}))
'''


def digest_tree(root):
    """Deterministic full candidate-source manifest digest, rejecting symlinks."""
    root=Path(root)
    h=hashlib.sha256()
    files=[]
    for f in root.rglob('*'):
        if f.is_symlink():raise ValueError('symlink not allowed')
        if f.is_file() and '__pycache__' not in f.parts and f.suffix not in ('.pyc','.pyo'):
            files.append(f)
    for f in sorted(files,key=lambda x:x.relative_to(root).as_posix()):
        key=f.relative_to(root).as_posix().encode()
        blob=f.read_bytes()
        h.update(len(key).to_bytes(8,'big')+key+len(blob).to_bytes(8,'big')+blob)
    return h.hexdigest()


def test_fixture(root, malicious):
    pkg=Path(root)/'target'
    pkg.mkdir(parents=True, exist_ok=True)
    (pkg/'value.py').write_text(BAD_VALUE)
    (pkg/'__init__.py').write_text(ATTACK if malicious else GOOD)
    return root


def score_in_process(root):
    p=subprocess.run([sys.executable,'-I','-c',SCORE_IN_PROCESS,str(root)],text=True,capture_output=True,check=True,timeout=8)
    return json.loads(p.stdout)


def score_out_of_process(root):
    # Trusted assertion runs in this process; all candidate imports occur in a child.
    # This is a process boundary demo, not an OS credential/filesystem sandbox.
    p=subprocess.run([sys.executable,'-I','-c',CHILD_WORKER,str(root)],text=True,capture_output=True,check=True,timeout=8)
    data=json.loads(p.stdout)
    return {'score':100 if data['answer']==1 else 0,'tests_run':1}


class TrustBoundaryTests(unittest.TestCase):
    def test_in_process_false_credit(self):
        with tempfile.TemporaryDirectory() as tmp:
            root=Path(tmp)
            test_fixture(root,malicious=True)
            result=score_in_process(root)
            self.assertEqual(result,{'score':100,'tests_run':1})
            self.assertEqual(score_out_of_process(root),{'score':0,'tests_run':1})

    def test_regular_bad_code_still_fails(self):
        with tempfile.TemporaryDirectory() as tmp:
            root=Path(tmp)
            test_fixture(root,malicious=False)
            self.assertEqual(score_in_process(root)['score'],0)
            self.assertEqual(score_out_of_process(root)['score'],0)

    def test_full_tree_hash_catches_initializer_mutation(self):
        with tempfile.TemporaryDirectory() as tmp:
            root=Path(tmp)
            test_fixture(root,malicious=False)
            before=digest_tree(root)
            file_hash=hashlib.sha256((root/'target/value.py').read_bytes()).hexdigest()
            test_fixture(root,malicious=True)
            after=digest_tree(root)
            self.assertNotEqual(before,after)
            self.assertEqual(file_hash,hashlib.sha256((root/'target/value.py').read_bytes()).hexdigest())

    def test_hash_rejects_symlink(self):
        with tempfile.TemporaryDirectory() as tmp:
            root=Path(tmp)
            test_fixture(root,malicious=False)
            (root/'external').symlink_to('/etc/passwd')
            with self.assertRaises(ValueError):
                digest_tree(root)


if __name__=='__main__':
    suite=unittest.defaultTestLoader.loadTestsFromTestCase(TrustBoundaryTests)
    r=unittest.TextTestRunner(verbosity=2).run(suite)
    print(json.dumps({'audit_id':'nightfall.eval.trust-boundary.v1',
                      'cases':r.testsRun,'passed':r.wasSuccessful(),
                      'claim':'synthetic in-process corruption detected; no agent or hidden-grader certification'},sort_keys=True))
    raise SystemExit(0 if r.wasSuccessful() else 1)
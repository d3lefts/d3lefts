import importlib.util
import os
from pathlib import Path
import tempfile
from types import SimpleNamespace
from unittest.mock import patch
import unittest
import json

SCRIPT = Path(__file__).with_name('paper_vi_dependency_checkpoint.py')
spec = importlib.util.spec_from_file_location('checkpoint', SCRIPT)
c = importlib.util.module_from_spec(spec)
spec.loader.exec_module(c)

class CheckpointTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.oldcwd = Path.cwd()
        root = Path(self.tmp.name)
        self.addCleanup(self.tmp.cleanup)
        self.addCleanup(os.chdir, self.oldcwd)
        os.chdir(root)
        self.context = patch.multiple(c, ROOT=root, ML=root/'mathlib', LIB=root/'mathlib/lib', CACHE=root/'cache', CLOSURE=Path('closure.txt'), BASE=Path('sources'), ROUTE=['B'])
        self.context.start(); self.addCleanup(self.context.stop)
        for name, content in {'closure.txt':'A sources/A.lean\n','sources/A.lean':'import Mathlib\n', 'sources/B.lean':'import A\n', 'docs/lean-compiler-lock.json':'{}\n', 'lean-toolchain':'pinned\n','mathlib/lake-manifest.json':'{}\n'}.items():
            p=Path(name); p.parent.mkdir(parents=True,exist_ok=True);p.write_text(content)
        self.calls=[]
        self.compiler='Lean fixture'
        def check_output(args, **kwargs):
            return self.compiler if args[0]=='lean' else 'mathlib-fixture'
        def fake_compile(args, **kwargs):
            self.calls.append(args[-1]); out=Path(args[args.index('-o')+1]); out.write_bytes(b'compiled:'+Path(args[-1]).read_bytes());out.with_suffix('.olean.private').write_bytes(b'private');out.with_suffix('.ilean').write_bytes(b'index');return SimpleNamespace(returncode=0)
        self.p1=patch.object(c.subprocess,'check_output',side_effect=check_output);self.p1.start();self.addCleanup(self.p1.stop)
        self.p2=patch.object(c.subprocess,'run',side_effect=fake_compile);self.p2.start();self.addCleanup(self.p2.stop)
        c.build()
        self.assertEqual(len(self.calls),2)
    def test_warm_restore_without_compile(self):
        for p in c.LIB.rglob('*'):
            if p.is_file(): p.unlink()
        c.install(Path('receipts'))
        self.assertEqual(len(self.calls),2)
        for name in ['A','B']:
            for suffix in ['.olean','.olean.private','.ilean']:
                self.assertTrue((c.LIB/(name+suffix)).is_file())
    def test_changed_dependency_rejected(self):
        Path('sources/A.lean').write_text('changed')
        with self.assertRaisesRegex(AssertionError,'input mismatch'): c.install(Path('receipts'))
    def test_changed_compiler_rejected(self):
        self.compiler='different Lean'
        with self.assertRaisesRegex(AssertionError,'input mismatch'): c.install(Path('receipts'))
    def test_corrupt_object_rejected(self):
        (c.CACHE/'files/A.olean').write_bytes(b'wrong')
        with self.assertRaisesRegex(AssertionError,'artifact mismatch'): c.install(Path('receipts'))
    def test_missing_object_rejected(self):
        (c.CACHE/'files/A.olean').unlink()
        with self.assertRaisesRegex(AssertionError,'artifact mismatch'): c.install(Path('receipts'))
    def test_unrelated_proof_change_does_not_invalidate(self):
        a=c.canonical(c.inputs());Path('terminal.lean').write_text('changed terminal')
        self.assertEqual(a,c.canonical(c.inputs()));c.install(Path('receipts'));self.assertEqual(len(self.calls),2)
    def test_missing_primary_even_if_manifest_adjusted(self):
        p=c.CACHE/'files/A.olean';p.unlink();manifest=json.loads((c.CACHE/'manifest.json').read_text());del manifest['files/A.olean'];(c.CACHE/'manifest.json').write_bytes(c.canonical(manifest))
        with self.assertRaises(AssertionError): c.install(Path('receipts'))
    def test_stale_split_object_removed(self):
        (c.LIB/'A.olean.stale').write_bytes(b'stale'); c.install(Path('receipts')); self.assertFalse((c.LIB/'A.olean.stale').exists())

if __name__=='__main__': unittest.main(verbosity=2)

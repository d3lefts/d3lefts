"""Intentionally shallow happy-path controls; not a Lean proof replay."""
from pathlib import Path
import unittest
from certcustody import git_blob, verify_checkout

HERE=Path(__file__).resolve().parents[1]
ROOT=HERE/'fixture'
KEY=(ROOT/'fixture.key').read_bytes()

class Smoke(unittest.TestCase):
    def test_git_blob_fixture(self):
        data=(ROOT/'sources/Alpha.lean').read_bytes()
        self.assertEqual(len(git_blob(data)),40)

    def test_frozen_fixture_counts(self):
        result=verify_checkout(ROOT, ROOT/'trusted_receipts.json', KEY)
        self.assertEqual((result['checked'],result['pending']),(1,1))

    def test_sorted_ledger(self):
        result=verify_checkout(ROOT, ROOT/'trusted_receipts.json', KEY)
        self.assertEqual([r['path'] for r in result['entries']],['sources/Alpha.lean','sources/Beta.lean'])

if __name__=='__main__':
    unittest.main()

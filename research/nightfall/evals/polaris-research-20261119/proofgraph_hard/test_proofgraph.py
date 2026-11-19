"""Security-oriented harness unit tests. Fake lake is NEVER a Lean proof check."""
import json
from pathlib import Path
import shutil
import tempfile
import unittest

from grade_proofgraph import grade, load_task, parse_axioms, tree_sha256

HERE = Path(__file__).parent


class ProofGraphHarnessTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.trusted = self.root / "trusted"
        self.submission = self.root / "submission"
        shutil.copytree(HERE / "fixture/trusted", self.trusted)
        shutil.copytree(HERE / "fixture/submission", self.submission)
        self.task = json.loads((HERE / "fixture/task.json").read_text())
        self.manifest = self.root / "task.json"
        self.save_task()
        self.lake = self.root / "fake-lake"
        self.fake_lake()

    def save_task(self):
        self.manifest.write_text(json.dumps(self.task))

    def fake_lake(self, axiom_line="'ProofGraph.terminal' depends on axioms: [propext, Quot.sound]", fail=False, mutate=False):
        source = (
            "#!/usr/bin/env python3\n"
            "import sys, pathlib\n"
            + ("sys.exit(2)\n" if fail else "")
            + ("pathlib.Path('ProofGraph/TrustedTarget.lean').write_text('corrupted')\n" if mutate else "")
            + "if len(sys.argv)>1 and sys.argv[1]=='env':\n"
            + f"    print({axiom_line!r})\n"
        )
        self.lake.write_text(source)
        self.lake.chmod(0o755)

    def run_grade(self):
        return grade(self.manifest, self.trusted, self.submission, str(self.lake))

    def test_fixture_digest_reproducible(self):
        self.assertEqual(tree_sha256(self.trusted), self.task['trusted_tree_sha256'])
        self.assertEqual(load_task(self.manifest, self.trusted)['target_module'], 'ProofGraph.TrustedTarget')

    def test_valid_fake_lake_is_explicitly_not_certified(self):
        r = self.run_grade()
        self.assertEqual(r['status'], 'pass', r)
        self.assertEqual(r['certification'], 'harness-smoke-only')
        self.assertEqual(r['axioms']['ProofGraph.terminal'], ['Quot.sound', 'propext'])

    def test_reject_untrusted_source_mutation(self):
        (self.trusted / 'ProofGraph/TrustedTarget.lean').write_text('theorem terminal : True := by trivial')
        self.assertEqual(self.run_grade()['status'], 'fail')

    def test_reject_unexpected_lemma_file(self):
        (self.submission / 'other.lean').write_text('theorem other : True := True.intro')
        r = self.run_grade()
        self.assertIn('unapproved submission', r['error'])

    def test_reject_missing_submission(self):
        (self.submission / 'ProofGraph/Submission.lean').unlink()
        self.assertIn('submission file set differs', self.run_grade()['error'])

    def test_reject_sorry(self):
        (self.submission / 'ProofGraph/Submission.lean').write_text('theorem t : True := by sorry')
        self.assertIn('forbidden proof token', self.run_grade()['error'])

    def test_reject_axiom_injection(self):
        (self.submission / 'ProofGraph/Submission.lean').write_text('axiom fake : False')
        self.assertIn('forbidden proof token', self.run_grade()['error'])

    def test_reject_symlink(self):
        (self.submission / 'ProofGraph/Submission.lean').unlink()
        (self.submission / 'ProofGraph/Submission.lean').symlink_to(self.trusted / 'ProofGraph/TrustedTarget.lean')
        self.assertIn('symlink', self.run_grade()['error'])

    def test_reject_path_traversal_in_manifest(self):
        self.task['allowed_submission_paths'] = ['../outside.lean']
        self.save_task()
        self.assertIn('noncanonical relative path', self.run_grade()['error'])

    def test_reject_trusted_module_overlay(self):
        self.task['allowed_submission_paths'] = ['ProofGraph/TrustedTarget.lean']
        self.save_task()
        self.assertIn('may not overwrite', self.run_grade()['error'])

    def test_reject_expanded_axiom_allowlist(self):
        self.task['allowed_axioms'].append('NewAxiom')
        self.save_task()
        self.assertIn('axiom allowlist', self.run_grade()['error'])

    def test_reject_nonstandard_axiom_in_report(self):
        self.fake_lake("'ProofGraph.terminal' depends on axioms: [Extra.Axiom]")
        self.assertIn('forbidden axiom dependency', self.run_grade()['error'])

    def test_reject_missing_axiom_report(self):
        self.fake_lake('unrelated output')
        self.assertIn('missing or duplicate axiom report', self.run_grade()['error'])

    def test_reject_failing_lean_command(self):
        self.fake_lake(fail=True)
        self.assertIn('Lean command failed', self.run_grade()['error'])

    def test_reject_build_time_mutation_of_target(self):
        self.fake_lake(mutate=True)
        self.assertIn('trusted source mutated', self.run_grade()['error'])

    def test_no_axiom_grammar(self):
        self.assertEqual(parse_axioms("'ProofGraph.terminal' does not depend on any axioms", ['ProofGraph.terminal']), {'ProofGraph.terminal': []})


if __name__ == '__main__':
    unittest.main()

#!/usr/bin/env python3
"""Independent exact counterexample to subTest score-method identity confusion.

Synthetic unittest only, no model or benchmark grader run. A PR head with
the vulnerable grouping on _testMethodName counts two distinct failing
subTest parents as one failure because both have name 'runTest'.
"""
import io
from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parent))
from contract_scorer import count_method_results


class ScoreIdentityTests(unittest.TestCase):
    def test_distinct_parent_methods_are_separate(self):
        class Toy(unittest.TestCase):
            def test_a(self):
                for k in range(3):
                    with self.subTest(k=k):
                        self.fail("synthetic failing subtest")

            def test_b(self):
                with self.subTest(k=4):
                    self.fail("different parent failure")

            def test_c(self):
                self.assertTrue(True)

            def test_d(self):
                self.skipTest("synthetic unscored skip")

        suite=unittest.defaultTestLoader.loadTestsFromTestCase(Toy)
        total=suite.countTestCases()
        result=unittest.TextTestRunner(stream=io.StringIO()).run(suite)
        self.assertEqual(total,4)
        self.assertEqual(len(result.failures),4)
        # BUGGY grouping treats every _SubTest as the same 'runTest'.
        broken={getattr(t,"_testMethodName",str(t))
                for t,_ in result.failures+result.errors}
        self.assertEqual(broken,{"runTest"})
        # A third skipped method also counts as a nonpass.
        self.assertEqual(count_method_results(result,total),(1,3))

    def test_single_parent_many_subtests_counts_once(self):
        class Toy(unittest.TestCase):
            def test_many(self):
                for k in range(7):
                    with self.subTest(k=k):
                        self.assertEqual(k,-1)
        suite=unittest.defaultTestLoader.loadTestsFromTestCase(Toy)
        result=unittest.TextTestRunner(stream=io.StringIO()).run(suite)
        self.assertEqual(len(result.failures),7)
        self.assertEqual(count_method_results(result,1),(0,1))

    def test_everything_passes(self):
        class Toy(unittest.TestCase):
            def test_a(self):
                for k in range(4):
                    with self.subTest(k=k):
                        self.assertTrue(True)
            def test_b(self):
                self.assertEqual(1,1)
        suite=unittest.defaultTestLoader.loadTestsFromTestCase(Toy)
        result=unittest.TextTestRunner(stream=io.StringIO()).run(suite)
        self.assertEqual(count_method_results(result,2),(2,0))


if __name__=="__main__":
    unittest.main()

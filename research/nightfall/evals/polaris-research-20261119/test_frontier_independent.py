import unittest
from audit_frontier import independent_audit
from generate_frontier_cases import make_case
from grade_correlated_influence import evaluate

class IndependentOracleTests(unittest.TestCase):
    def test_crosscheck_multiple_dimensions_and_seeds(self):
        for n in (7,8,9,10,11,12):
            for seed in (0,3,17):
                case=make_case(seed,n)
                a=independent_audit(case)
                b=evaluate(case)
                for key in a:
                    self.assertEqual(a[key],b[key],(n,seed,key))
                self.assertTrue(b["valid"])

if __name__=="__main__":
    unittest.main()

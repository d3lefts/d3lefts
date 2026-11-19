import unittest
from check_theorembreak import check

class OracleTests(unittest.TestCase):
    def test_valid(self):
        self.assertTrue(check({"a":{"0,0":"1/2","1,1":"1/2"},
                               "b":{"0,1":"1/2","1,0":"1/2"}})["valid"])
    def test_identical_joint_rejected(self):
        d = {"0,0":"1/2","1,1":"1/2"}
        self.assertFalse(check({"a":d,"b":d})["valid"])
    def test_different_marginal_rejected(self):
        self.assertFalse(check({"a":{"0,0":"1"},"b":{"1,1":"1"}})["valid"])
    def test_bad_normalization_rejected(self):
        with self.assertRaises(ValueError):
            check({"a":{"0,0":"1/3"},"b":{"0,0":"1"}})

if __name__ == "__main__":
    unittest.main()

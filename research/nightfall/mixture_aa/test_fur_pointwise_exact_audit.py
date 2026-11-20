"""Exact structural tests for PF(2) plus failure of the naive FUR averaging step."""
import unittest
from fractions import Fraction as Q
from itertools import product
from fur_pointwise_exact_audit import (
    audit, bounded_quadratic, couple_coeffs, direct_moment,
    eval_poly, moment_poly, one_hot_max_obstruction, trial,
)


class ExactFURPointwiseTests(unittest.TestCase):
    def test_degree2_examples_for_all_sampled_dimensions(self):
        result=audit()
        self.assertEqual(result["status"], "finite-exact-tests-pass")
        self.assertEqual(result["num_quadratic_trials"], 16)
        self.assertIs(result["complete_FUR"], False)

    def test_nontrivial_degree2_markov_bound(self):
        for n in (2,3,4,5):
            r=trial(n,71)
            self.assertLessEqual(Q(r["p1"]),Q(r["markov_cap"]))
            self.assertLess(Q(r["markov_cap"]),1)
            self.assertLessEqual(r["degree"],4)

    def test_diagonal_pair_coupling_zero(self):
        f=bounded_quadratic(4,12)
        laws=[couple_coeffs(Q(0),Q(1,2),Q(1,2)) for _ in range(4)]
        P=moment_poly(f,laws)
        self.assertTrue(all(v==0 for v in P))
        self.assertEqual(direct_moment(f,laws,Q(1)),0)

    def test_nonquadratic_parity_has_degree_five(self):
        n=5
        # A degree-five parity polynomial. Mismatch pairs always (0,1):
        # P(t)=Pr[parity(Y)=1]=(1-(1-2pt)^5)/2.
        parity={bits:Q(sum(bits)%2) for bits in product((0,1), repeat=n)}
        laws=[couple_coeffs(Q(1,8),Q(0),Q(1)) for _ in range(n)]
        P=moment_poly(parity,laws)
        self.assertEqual(len(P),6)
        self.assertNotEqual(P[5],0)
        self.assertEqual(eval_poly(P,Q(0)),0)

    def test_one_hot_exposes_expected_max_gap(self):
        for n in (4,16,64,256):
            r=one_hot_max_obstruction(n)
            self.assertEqual(Q(r["expected_max_pair_tv"]),Q(n-1,n))
            self.assertEqual(Q(r["per_coordinate_second_moment_tv"]),Q(2*(n-1),n*n))
            self.assertGreater(Q(r["expected_max_pair_tv"]),
                               Q(r["per_coordinate_second_moment_tv"]))


if __name__=="__main__":
    unittest.main()

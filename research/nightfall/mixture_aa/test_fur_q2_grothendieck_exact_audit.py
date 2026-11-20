"""Adversarial tests of the binary Grothendieck Q2 data, not a proof of K_G."""
from fractions import Fraction as Q
import unittest
from fur_q2_grothendieck_exact_audit import (
    audit, make_quadratic, norms, correlated_instance, one_hot_nontrivial
)


class QuadraticGrothendieckAuditTests(unittest.TestCase):
    def test_bounded_quad_finite_falsification(self):
        report=audit()
        self.assertEqual(report["status"],"exact-finite-falsification-controls-pass")
        self.assertEqual(report["random_correlated_couplings"],16)
        self.assertFalse(report["real_grothendieck_proved_here"])
        self.assertFalse(report["full_FUR_all_alphabets"])

    def test_quadratic_norms_from_bounded_function(self):
        for seed in range(6):
            c,f=make_quadratic(5,seed)
            self.assertGreaterEqual(min(f.values()),0)
            self.assertLessEqual(max(f.values()),1)
            cut,linear=norms(c,5)
            self.assertLessEqual(cut,2)
            self.assertLessEqual(linear,Q(1,2))

    def test_correlated_joint_pair_controls(self):
        for n in (2,3,4,5):
            result=correlated_instance(n,99)
            self.assertFalse(result["pairs_independent"])
            p=Q(result["max_mismatch"])
            err=Q(result["mean_absolute_difference"])
            self.assertLessEqual(max(err-p,0)**2,256*p)

    def test_one_hot_large_n_nontrivial_quadratic(self):
        r=one_hot_nontrivial(2048)
        self.assertEqual(r["global_degree"],2)
        self.assertLess(Q(r["max_fixed_coordinate_mismatch"]),Q(1,1024))
        self.assertGreater(Q(r["expected_max_pairwise_mismatch"]),Q(999,1000))
        self.assertGreater(Q(r["mean_absolute_difference"]),0)

    def test_reject_invalid_one_hot_dimension(self):
        with self.assertRaises(AssertionError):
            one_hot_nontrivial(32)


if __name__=="__main__":
    unittest.main()

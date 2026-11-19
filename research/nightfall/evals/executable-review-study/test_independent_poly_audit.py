"""Mutation attacks and exact cross-checks for the independent interpolation auditor."""
from fractions import Fraction as Q
import unittest
from unittest import mock
import independent_poly_audit as a


class IndependentAuditTests(unittest.TestCase):
    def test_reconstructs_all_eight_pinned_rectangles(self):
        report = a.audit()
        self.assertEqual(report["status"], "pass")
        self.assertEqual(report["domain_area"], "1")
        self.assertEqual(report["cells"], 8)
        self.assertEqual(report["minimum"], "0")

    def test_first_box_is_sharp(self):
        B = [[a.basis(u, j) for j in range(5)] for u in a.GRID]
        inv = a.invert_exact(B)
        coeff = a.coefficients_for_box(a.BOXES[0], inv)
        self.assertEqual(min(val for row in coeff for val in row), Q(0))

    def test_bad_bernstein_minimum_is_detected(self):
        boxes = list(a.BOXES)
        boxes[0] = (*boxes[0][:4], Q(1, 9))
        with mock.patch.object(a, "BOXES", tuple(boxes)):
            with self.assertRaisesRegex(AssertionError, "box 0"):
                a.audit()

    def test_hole_in_certificate_cover_is_detected(self):
        boxes = list(a.BOXES)
        boxes[0] = (Q(0), Q(1, 8), Q(0), Q(1, 2), Q(0))
        with mock.patch.object(a, "BOXES", tuple(boxes)):
            with self.assertRaisesRegex(AssertionError, "do not cover"):
                a.verify_coverage()

    def test_overlap_in_certificate_cover_is_detected(self):
        boxes = list(a.BOXES)
        boxes[0] = (Q(0), Q(3, 8), Q(0), Q(1, 2), Q(0))
        with mock.patch.object(a, "BOXES", tuple(boxes)):
            with self.assertRaisesRegex(AssertionError, "overlapping"):
                a.verify_coverage()


if __name__ == "__main__":
    unittest.main()

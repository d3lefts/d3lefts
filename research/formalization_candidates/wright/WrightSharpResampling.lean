import Mathlib

/-!
Sharp Wright resampling operator: a proof architecture independent of CDFs.

Pointwise: for |a|,|b|<=1/2,
 |a-b| + 2 (|a||b|+ab) <= |a|+|b|.
Consequently for iid centered interval values with z=E|X-1/2|,
 E|X-X'| <= 2 z(1-z), and rho=4-2 sqrt 3 is exact.

This module proves the crucial **pointwise** certificate and the tensorization
identity. A full finite-law sum and measurable fiber transfer are separate gates.
-/

namespace Nightfall.Wright.SharpResampling

open Finset

theorem pointwise_two_sample (a b : ℝ)
    (ha0 : -(1 / 2 : ℝ) ≤ a) (ha1 : a ≤ 1 / 2)
    (hb0 : -(1 / 2 : ℝ) ≤ b) (hb1 : b ≤ 1 / 2) :
    |a - b| + 2 * (|a| * |b| + a * b) ≤ |a| + |b| := by
  rcases le_total a 0 with ha | ha
  · rcases le_total b 0 with hb | hb
    · have h1 : 0 ≤ (-b) * (1 + 2 * a) :=
        mul_nonneg (by linarith) (by linarith)
      have h2 : 0 ≤ (-a) * (1 + 2 * b) :=
        mul_nonneg (by linarith) (by linarith)
      rw [abs_of_nonpos ha, abs_of_nonpos hb]
      apply abs_le.mpr
      constructor <;> nlinarith
    · have hsub : a - b ≤ 0 := by linarith
      rw [abs_of_nonpos ha, abs_of_nonneg hb, abs_of_nonpos hsub]
      ring
  · rcases le_total b 0 with hb | hb
    · have hsub : 0 ≤ a - b := by linarith
      rw [abs_of_nonneg ha, abs_of_nonpos hb, abs_of_nonneg hsub]
      ring
    · have h1 : 0 ≤ b * (1 - 2 * a) :=
        mul_nonneg (by linarith) (by linarith)
      have h2 : 0 ≤ a * (1 - 2 * b) :=
        mul_nonneg (by linarith) (by linarith)
      rw [abs_of_nonneg ha, abs_of_nonneg hb]
      apply abs_le.mpr
      constructor <;> nlinarith

variable {α : Type*} [Fintype α]

/-- Pairwise sums under a product law factor for any finite alphabet,
including symbols of zero mass. -/
theorem pair_sum_factor (p u v : α → ℝ) :
    (∑ i, ∑ j, (p i * u i) * (p j * v j)) =
      (∑ i, p i * u i) * (∑ j, p j * v j) := by
  calc
    (∑ i, ∑ j, (p i * u i) * (p j * v j)) =
        (∑ i, (p i * u i) * (∑ j, p j * v j)) := by
          apply Finset.sum_congr rfl
          intro i hi
          rw [Finset.mul_sum]
    _ = (∑ i, p i * u i) * (∑ j, p j * v j) := by
          rw [Finset.sum_mul]

end Nightfall.Wright.SharpResampling

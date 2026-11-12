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
      have hdiff : |a - b| ≤ -a + -b - 2 * ((-a) * (-b) + a * b) := by
        apply abs_le.mpr
        constructor <;> nlinarith
      nlinarith
    · have hsub : a - b ≤ 0 := by linarith
      rw [abs_of_nonpos ha, abs_of_nonneg hb, abs_of_nonpos hsub]
      nlinarith
  · rcases le_total b 0 with hb | hb
    · have hsub : 0 ≤ a - b := by linarith
      rw [abs_of_nonneg ha, abs_of_nonpos hb, abs_of_nonneg hsub]
      nlinarith
    · have h1 : 0 ≤ b * (1 - 2 * a) :=
        mul_nonneg (by linarith) (by linarith)
      have h2 : 0 ≤ a * (1 - 2 * b) :=
        mul_nonneg (by linarith) (by linarith)
      rw [abs_of_nonneg ha, abs_of_nonneg hb]
      have hdiff : |a - b| ≤ a + b - 2 * (a * b + a * b) := by
        apply abs_le.mpr
        constructor <;> nlinarith
      nlinarith

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

/-- Convenient product-law form of pair-sum factorization. -/
theorem pair_sum_law (p u v : α → ℝ) :
    (∑ i, ∑ j, p i * p j * (u i * v j)) =
      (∑ i, p i * u i) * (∑ j, p j * v j) := by
  calc
    (∑ i, ∑ j, p i * p j * (u i * v j)) =
        (∑ i, ∑ j, (p i * u i) * (p j * v j)) := by
          apply Finset.sum_congr rfl
          intro i _
          apply Finset.sum_congr rfl
          intro j _
          ring
    _ = _ := pair_sum_factor p u v

theorem pair_sum_left (p u : α → ℝ)
    (hp1 : ∑ i, p i = 1) :
    (∑ i, ∑ j, p i * p j * u i) = ∑ i, p i * u i := by
  have h := pair_sum_law p u (fun _ => 1)
  simp only [mul_one] at h
  rw [hp1, mul_one] at h
  exact h

theorem pair_sum_right (p u : α → ℝ)
    (hp1 : ∑ i, p i = 1) :
    (∑ i, ∑ j, p i * p j * u j) = ∑ j, p j * u j := by
  have h := pair_sum_law p (fun _ => 1) u
  simp only [one_mul, mul_one] at h
  rw [hp1, one_mul] at h
  exact h

/-- Weighted version of the pointwise operator; zero masses are permitted. -/
theorem finite_weighted_pairwise
    (p : α → ℝ) (hp : ∀ i, 0 ≤ p i)
    (a : α → ℝ) (ha0 : ∀ i, -(1 / 2 : ℝ) ≤ a i)
    (ha1 : ∀ i, a i ≤ 1 / 2) :
    (∑ i, ∑ j, p i * p j *
      (|a i - a j| + 2 * (|a i| * |a j| + a i * a j))) ≤
    (∑ i, ∑ j, p i * p j * (|a i| + |a j|)) := by
  apply Finset.sum_le_sum
  intro i _
  apply Finset.sum_le_sum
  intro j _
  exact mul_le_mul_of_nonneg_left
    (pointwise_two_sample (a i) (a j) (ha0 i) (ha1 i) (ha0 j) (ha1 j))
    (mul_nonneg (hp i) (hp j))

/-- The actual iid absolute-difference inequality, obtained by factoring
independent double sums. The negative mean-squared correction is retained. -/
theorem iid_absolute_difference_bound
    (p : α → ℝ) (hp : ∀ i, 0 ≤ p i)
    (hp1 : ∑ i, p i = 1)
    (a : α → ℝ) (ha0 : ∀ i, -(1 / 2 : ℝ) ≤ a i)
    (ha1 : ∀ i, a i ≤ 1 / 2) :
    (∑ i, ∑ j, p i * p j * |a i - a j|)
       + 2 * (∑ i, p i * |a i|) ^ 2
       + 2 * (∑ i, p i * a i) ^ 2
       ≤ 2 * (∑ i, p i * |a i|) := by
  have h := finite_weighted_pairwise p hp a ha0 ha1
  have hL : (∑ i, ∑ j, p i * p j *
        (|a i - a j| + 2 * (|a i| * |a j| + a i * a j))) =
      (∑ i, ∑ j, p i * p j * |a i - a j|)
        + 2 * (∑ i, p i * |a i|) ^ 2
        + 2 * (∑ i, p i * a i) ^ 2 := by
    have hterm (i j : α) :
        p i * p j * (|a i - a j| + 2 * (|a i| * |a j| + a i * a j)) =
          p i * p j * |a i - a j| +
          2 * (p i * p j * (|a i| * |a j|)) +
          2 * (p i * p j * (a i * a j)) := by ring
    simp_rw [hterm, Finset.sum_add_distrib]
    rw [pair_sum_law p (fun i => |a i|) (fun i => |a i|)]
    rw [pair_sum_law p a a]
    ring
  have hR : (∑ i, ∑ j, p i * p j * (|a i| + |a j|)) =
      2 * (∑ i, p i * |a i|) := by
    have hterm (i j : α) :
        p i * p j * (|a i| + |a j|) =
          p i * p j * |a i| + p i * p j * |a j| := by ring
    simp_rw [hterm, Finset.sum_add_distrib]
    rw [pair_sum_left p (fun i => |a i|) hp1]
    rw [pair_sum_right p (fun i => |a i|) hp1]
    ring
  rw [hL, hR] at h
  exact h

/-- Dropping the nonnegative mean-square term yields the exact scalar
bound E|X-X'| <= 2z(1-z), with z=E|X-1/2|. -/
theorem iid_absolute_difference_z
    (p : α → ℝ) (hp : ∀ i, 0 ≤ p i)
    (hp1 : ∑ i, p i = 1)
    (a : α → ℝ) (ha0 : ∀ i, -(1 / 2 : ℝ) ≤ a i)
    (ha1 : ∀ i, a i ≤ 1 / 2) :
    (∑ i, ∑ j, p i * p j * |a i - a j|)
       ≤ 2 * (∑ i, p i * |a i|) *
            (1 - (∑ i, p i * |a i|)) := by
  have h := iid_absolute_difference_bound p hp hp1 a ha0 ha1
  nlinarith [sq_nonneg (∑ i, p i * a i)]


end Nightfall.Wright.SharpResampling

import Mathlib

/-!
# Exact 3-4-6 interpolation for finite weighted moments

For nonnegative weights and nonnegative square roots t_i, proves
  (sum p_i t_i^4)^3 <= (sum p_i t_i^3)^2 (sum p_i t_i^6).

The certificate uses an exact positive polynomial identity:
  t^3 (A t - B)^2 (A t + 2 B)
    = A^3 t^6 - 3 A B^2 t^4 + 2 B^3 t^3,
with A = sum p t^3, B = sum p t^4. No analytic
Holder imports, fractional real powers, or approximation are needed.

This is a functional ingredient for the v8 median's moment interpolation.
-/

namespace Nightfall.Wright.Moment346

open Finset

variable {σ : Type*} [Fintype σ]

theorem weighted_moment_346 (p t : σ → ℝ)
    (hp : ∀ i, 0 ≤ p i) (ht : ∀ i, 0 ≤ t i) :
    (∑ i, p i * t i ^ 4) ^ 3 ≤
      (∑ i, p i * t i ^ 3) ^ 2 * (∑ i, p i * t i ^ 6) := by
  let A : ℝ := ∑ i, p i * t i ^ 3
  let B : ℝ := ∑ i, p i * t i ^ 4
  let C : ℝ := ∑ i, p i * t i ^ 6
  have hterm3 (i : σ) : 0 ≤ p i * t i ^ 3 :=
    mul_nonneg (hp i) (pow_nonneg (ht i) _)
  have hterm4 (i : σ) : 0 ≤ p i * t i ^ 4 :=
    mul_nonneg (hp i) (pow_nonneg (ht i) _)
  have hA : 0 ≤ A := Finset.sum_nonneg (fun i _ => hterm3 i)
  have hB : 0 ≤ B := Finset.sum_nonneg (fun i _ => hterm4 i)
  change B ^ 3 ≤ A ^ 2 * C
  by_cases hzero : A = 0
  · have hz3 : ∀ i, p i * t i ^ 3 = 0 := by
      intro i
      have hle : p i * t i ^ 3 ≤ A := by
        change p i * t i ^ 3 ≤ ∑ j, p j * t j ^ 3
        exact Finset.single_le_sum (fun j _ => hterm3 j) (Finset.mem_univ i)
      exact le_antisymm (by simpa [hzero] using hle) (hterm3 i)
    have hz4 : ∀ i, p i * t i ^ 4 = 0 := by
      intro i
      rcases mul_eq_zero.mp (hz3 i) with hpi | hti
      · simp [hpi]
      · by_cases hti0 : t i = 0
        · simp [hti0]
        · exact False.elim ((pow_ne_zero 3 hti0) hti)
    have hB0 : B = 0 := by
      change (∑ i, p i * t i ^ 4) = 0
      simp [hz4]
    simp [hzero, hB0]
  · have hApos : 0 < A := lt_of_le_of_ne hA (Ne.symm hzero)
    have hfactor (i : σ) :
        0 ≤ p i * t i ^ 3 * (A * t i - B) ^ 2 * (A * t i + 2 * B) := by
      have hlast : 0 ≤ A * t i + 2 * B :=
        add_nonneg (mul_nonneg hA (ht i)) (mul_nonneg (by norm_num) hB)
      exact mul_nonneg
        (mul_nonneg (mul_nonneg (hp i) (pow_nonneg (ht i) 3))
          (sq_nonneg _)) hlast
    have hsum : 0 ≤
        ∑ i, p i * t i ^ 3 * (A * t i - B) ^ 2 * (A * t i + 2 * B) :=
      Finset.sum_nonneg (fun i _ => hfactor i)
    have hexpand :
        (∑ i, p i * t i ^ 3 * (A * t i - B) ^ 2 * (A * t i + 2 * B)) =
          A ^ 3 * C - A * B ^ 3 := by
      calc
        _ = ∑ i, (A ^ 3 * (p i * t i ^ 6) -
            (3 * A * B ^ 2) * (p i * t i ^ 4) +
            (2 * B ^ 3) * (p i * t i ^ 3)) := by
              apply Finset.sum_congr rfl
              intro i _
              ring
        _ = A ^ 3 * C - 3 * A * B ^ 2 * B + 2 * B ^ 3 * A := by
              rw [Finset.sum_add_distrib, Finset.sum_sub_distrib]
              rw [← Finset.mul_sum, ← Finset.mul_sum, ← Finset.mul_sum]
        _ = _ := by ring
    have hprod : 0 ≤ A * (A ^ 2 * C - B ^ 3) := by
      nlinarith [hsum, hexpand]
    have hmain : 0 ≤ A ^ 2 * C - B ^ 3 := by
      by_contra hnot
      have hneg : A ^ 2 * C - B ^ 3 < 0 := lt_of_not_ge hnot
      have hpneg : A * (A ^ 2 * C - B ^ 3) < 0 :=
        mul_neg_of_pos_of_neg hApos hneg
      linarith
    linarith

end Nightfall.Wright.Moment346

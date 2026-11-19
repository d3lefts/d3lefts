import StrongSmoothing

/-!
# Binomial-tail exponential-moment certificate

This module connects the exact finite smoother from StrongSmoothing to
a reusable *upper-tail* exponential-moment inequality. It is independent
of probability-space APIs and of the target Hoeffding constants.

The lower-tail counterpart and optimization of the moment parameter
remain further gates for the exact ε,η smoother.
-/

namespace Nightfall.StrongSimulation.Smoothing

open Finset

/-- For λ≥1, powers λ^j increase with j. -/
private theorem pow_le_pow_of_le (λ : ℝ) (hλ : 1 ≤ λ)
    (a b : ℕ) (hab : a ≤ b) : λ ^ a ≤ λ ^ b := by
  have hnonneg : 0 ≤ λ ^ a := pow_nonneg (by linarith) _
  have hpow : (1 : ℝ) ≤ λ ^ (b - a) := one_le_pow₀ hλ
  calc
    λ ^ a = λ ^ a * 1 := by ring
    _ ≤ λ ^ a * λ ^ (b - a) :=
      mul_le_mul_of_nonneg_left hpow hnonneg
    _ = λ ^ b := by
      rw [← pow_add]
      congr 1
      omega

/-- Exact binomial generating function, including zero or unit p. -/
theorem weighted_binomial_mass
    (k : ℕ) (p λ : ℝ) :
    (∑ j ∈ Finset.range (k + 1),
      (p ^ j * (1 - p) ^ (k - j) * (k.choose j : ℝ)) * λ ^ j) =
      (p * λ + (1 - p)) ^ k := by
  have h := add_pow (p * λ) (1 - p) k
  calc
    (∑ j ∈ Finset.range (k + 1),
      (p ^ j * (1 - p) ^ (k - j) * (k.choose j : ℝ)) * λ ^ j) =
      ∑ j ∈ Finset.range (k + 1),
      (p * λ) ^ j * (1 - p) ^ (k - j) * (k.choose j : ℝ) := by
        apply Finset.sum_congr rfl
        intro j hj
        rw [mul_pow]
        ring
    _ = (p * λ + (1 - p)) ^ k := h.symm

/-- Chernoff generating-function inequality for a binomial upper tail.
The inequality is exact and does not divide by λ, so its endpoint λ=1
is also included. -/
theorem upper_tail_moment
    (k r : ℕ) (p λ : ℝ)
    (hp0 : 0 ≤ p) (hp1 : p ≤ 1) (hλ : 1 ≤ λ) :
    λ ^ (r + 1) *
      (∑ j ∈ Finset.Ico (r + 1) (k + 1),
        p ^ j * (1 - p) ^ (k - j) * (k.choose j : ℝ)) ≤
        (p * λ + (1 - p)) ^ k := by
  have hcoeff (j : ℕ) :
      0 ≤ p ^ j * (1 - p) ^ (k - j) * (k.choose j : ℝ) := by
    have h1 : 0 ≤ 1 - p := by linarith
    positivity
  have hterm (j : ℕ) (hj : j ∈ Finset.Ico (r + 1) (k + 1)) :
      λ ^ (r + 1) *
        (p ^ j * (1 - p) ^ (k - j) * (k.choose j : ℝ)) ≤
      (p ^ j * (1 - p) ^ (k - j) * (k.choose j : ℝ)) * λ ^ j := by
    have hle : r + 1 ≤ j := (Finset.mem_Ico.mp hj).1
    have hpow : λ ^ (r + 1) ≤ λ ^ j :=
      pow_le_pow_of_le λ hλ _ _ hle
    have he := mul_le_mul_of_nonneg_right hpow (hcoeff j)
    nlinarith
  calc
    λ ^ (r + 1) *
      (∑ j ∈ Finset.Ico (r + 1) (k + 1),
        p ^ j * (1 - p) ^ (k - j) * (k.choose j : ℝ)) =
      ∑ j ∈ Finset.Ico (r + 1) (k + 1),
        λ ^ (r + 1) *
        (p ^ j * (1 - p) ^ (k - j) * (k.choose j : ℝ)) := by
          rw [Finset.mul_sum]
    _ ≤ ∑ j ∈ Finset.Ico (r + 1) (k + 1),
        (p ^ j * (1 - p) ^ (k - j) * (k.choose j : ℝ)) * λ ^ j :=
        Finset.sum_le_sum (fun j hj => hterm j hj)
    _ ≤ ∑ j ∈ Finset.range (k + 1),
        (p ^ j * (1 - p) ^ (k - j) * (k.choose j : ℝ)) * λ ^ j := by
          apply Finset.sum_le_sum_of_subset_of_nonneg
          · intro j hj
            exact Finset.mem_range.mpr (Finset.mem_Ico.mp hj).2
          · intro j hj _
            exact mul_nonneg (hcoeff j) (pow_nonneg (by linarith) j)
    _ = (p * λ + (1 - p)) ^ k :=
        weighted_binomial_mass k p λ

end Nightfall.StrongSimulation.Smoothing

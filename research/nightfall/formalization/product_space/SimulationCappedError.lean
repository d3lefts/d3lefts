import Mathlib

/-!
# Capped finite-query error union bound

The stopped leaves have a controlled weighted squared-error moment.
The non-stopped (truncated) leaves have a controlled total mass.
This theorem combines the two actual finite-event measures. It does
not assume a decision tree exists: that remains a separate obligation.
-/

namespace Nightfall.QuerySimulation

open Finset

variable {Ω : Type*} [Fintype Ω] [DecidableEq Ω]

theorem finite_capped_leaf_error
    (mu : Ω → ℝ) (stopped : Ω → Bool) (e : Ω → ℝ)
    (ε δ : ℝ)
    (hmu : ∀ x, 0 ≤ mu x) (hε : 0 < ε)
    (hactive : (∑ x : Ω, if stopped x then (0 : ℝ) else mu x) ≤ δ / 2)
    (hmoment : (∑ x : Ω, if stopped x then mu x * e x ^ 2 else 0) ≤
      ε ^ 2 * δ / 2) :
    (∑ x : Ω, if ε ≤ |e x| then mu x else 0) ≤ δ := by
  classical
  have hpoint (x : Ω) :
      ε ^ 2 * (if ε ≤ |e x| then mu x else 0) ≤
      ε ^ 2 * (if stopped x then 0 else mu x) +
        (if stopped x then mu x * e x ^ 2 else 0) := by
    cases hst : stopped x with
    | false =>
        by_cases hb : ε ≤ |e x|
        · simp [hst, hb]
        · have hnonneg : 0 ≤ ε ^ 2 * mu x :=
            mul_nonneg (sq_nonneg _) (hmu x)
          simpa [hst, hb] using hnonneg
    | true =>
        by_cases hb : ε ≤ |e x|
        · have hsq : ε ^ 2 ≤ e x ^ 2 := by
            calc
              ε ^ 2 ≤ |e x| ^ 2 := pow_le_pow_left₀ (le_of_lt hε) hb 2
              _ = e x ^ 2 := by rw [sq_abs]
          have hh := mul_le_mul_of_nonneg_right hsq (hmu x)
          simpa [hst, hb, mul_comm] using hh
        · have hnonneg : 0 ≤ mu x * e x ^ 2 :=
            mul_nonneg (hmu x) (sq_nonneg _)
          simpa [hst, hb] using hnonneg
  have hsum :
      (∑ x : Ω, ε ^ 2 * (if ε ≤ |e x| then mu x else 0)) ≤
      ∑ x : Ω, (ε ^ 2 * (if stopped x then 0 else mu x) +
        (if stopped x then mu x * e x ^ 2 else 0)) := by
    apply Finset.sum_le_sum
    intro x _
    exact hpoint x
  simp only [← Finset.mul_sum, Finset.sum_add_distrib] at hsum
  have he2 : 0 < ε ^ 2 := pow_pos hε 2
  have htotal :
      ε ^ 2 * (∑ x : Ω, if ε ≤ |e x| then mu x else 0) ≤
      ε ^ 2 * δ := by
    calc
      _ ≤ ε ^ 2 * (∑ x : Ω, if stopped x then 0 else mu x) +
          (∑ x : Ω, if stopped x then mu x * e x ^ 2 else 0) := hsum
      _ ≤ ε ^ 2 * (δ / 2) + ε ^ 2 * δ / 2 := by
            exact add_le_add
              (mul_le_mul_of_nonneg_left hactive (le_of_lt he2)) hmoment
      _ = ε ^ 2 * δ := by ring
  exact (mul_le_mul_iff_of_pos_left he2).mp htotal

end Nightfall.QuerySimulation

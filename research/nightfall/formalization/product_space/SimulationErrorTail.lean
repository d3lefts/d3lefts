import Mathlib

/-!
# Exact finite Chebyshev tail for conditional-mean leaves

Standalone finite probability estimate: a nonnegative weighted second moment
controls the mass of outcomes with large absolute error. This is the last
probabilistic step of the greedy AA simulator, independent of probability
normalization. No claim is made that a decision tree or its leaf statistics
are constructed here.
-/

namespace Nightfall.QuerySimulation

open Finset
variable {Ω : Type*} [Fintype Ω] [DecidableEq Ω]

theorem finite_squared_error_tail
    (mu : Ω → ℝ) (e : Ω → ℝ) (ε δ : ℝ)
    (hmu : ∀ x, 0 ≤ mu x) (hε : 0 < ε)
    (hmoment : (∑ x, mu x * e x ^ 2) ≤ ε ^ 2 * δ) :
    (∑ x ∈ Finset.univ.filter (fun x => ε ≤ |e x|), mu x) ≤ δ := by
  classical
  let E : Finset Ω := Finset.univ.filter (fun x => ε ≤ |e x|)
  have hpoint : ∀ x ∈ E, ε ^ 2 * mu x ≤ mu x * e x ^ 2 := by
    intro x hx
    have hx' : ε ≤ |e x| := (Finset.mem_filter.mp hx).2
    have hsq : ε ^ 2 ≤ e x ^ 2 := by
      calc
        ε ^ 2 ≤ |e x| ^ 2 := pow_le_pow_left₀ (le_of_lt hε) hx' 2
        _ = e x ^ 2 := by rw [sq_abs]
    nlinarith [mul_le_mul_of_nonneg_left hsq (hmu x)]
  have hsum : ε ^ 2 * (∑ x ∈ E, mu x) ≤
      (∑ x ∈ E, mu x * e x ^ 2) := by
    rw [Finset.mul_sum]
    exact Finset.sum_le_sum (fun x hx => hpoint x hx)
  have hsubset : (∑ x ∈ E, mu x * e x ^ 2) ≤
      (∑ x, mu x * e x ^ 2) := by
    apply Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ E)
    intro x hx hxnot
    exact mul_nonneg (hmu x) (sq_nonneg _)
  have hh : ε ^ 2 * (∑ x ∈ E, mu x) ≤ ε ^ 2 * δ :=
    (hsum.trans hsubset).trans hmoment
  have he2 : 0 < ε ^ 2 := pow_pos hε 2
  have hres := (mul_le_mul_left he2).mp hh
  exact hres
end Nightfall.QuerySimulation

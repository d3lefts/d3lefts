import Mathlib

/-!
# NIGHTFALL Route 1 density domination

Exact source-independent change-of-measure lemmas for finite input spaces.
For event E and pointwise ν(x) ≤ R Q(x), ν(E) ≤ R Q(E).

This is the rigorously trivial but necessary oracle-distribution bridge for
the query-aware, density-dominated Route1 sufficiency theorem. It does not
claim the unformalized heterogeneous block-alphabet or decoding steps.
There are no unspecified analytic or quantum premises.
-/

namespace Nightfall.Route1DensityDomination

open Finset

variable {Ω : Type*} [Fintype Ω]

/-- A one-sided density bound transfers every nonnegative expectation. -/
theorem weighted_expectation_dominated
    (ν Q : Ω → ℝ) (R : ℝ)
    (hdom : ∀ x, ν x ≤ R * Q x)
    (g : Ω → ℝ) (hg : ∀ x, 0 ≤ g x) :
    (∑ x, ν x * g x) ≤ R * (∑ x, Q x * g x) := by
  calc
    (∑ x, ν x * g x) ≤ ∑ x, (R * Q x) * g x := by
      apply Finset.sum_le_sum
      intro x _
      exact mul_le_mul_of_nonneg_right (hdom x) (hg x)
    _ = R * (∑ x, Q x * g x) := by
      rw [Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro x _
      ring

/-- Pointwise domination transfers **every event**, without any
independence, normalization, support, or algebraic-degree assumption. -/
theorem event_probability_dominated
    (ν Q : Ω → ℝ) (R : ℝ)
    (hdom : ∀ x, ν x ≤ R * Q x)
    (E : Ω → Prop) [DecidablePred E] :
    (∑ x, ν x * (if E x then (1 : ℝ) else 0)) ≤
      R * (∑ x, Q x * (if E x then (1 : ℝ) else 0)) := by
  exact weighted_expectation_dominated ν Q R hdom
    (fun x => if E x then (1 : ℝ) else 0) (by
      intro x
      split_ifs <;> norm_num)

/-- A source query tree with suitably small Q-failure is automatically
valid under any ν pointwise dominated by R Q. -/
theorem transfer_error_bound
    (ν Q : Ω → ℝ) (R δ : ℝ)
    (hdom : ∀ x, ν x ≤ R * Q x)
    (E : Ω → Prop) [DecidablePred E]
    (hsource :
      R * (∑ x, Q x * (if E x then (1 : ℝ) else 0)) ≤ δ) :
    (∑ x, ν x * (if E x then (1 : ℝ) else 0)) ≤ δ :=
  (event_probability_dominated ν Q R hdom E).trans hsource

end Nightfall.Route1DensityDomination

#print axioms Nightfall.Route1DensityDomination.weighted_expectation_dominated
#print axioms Nightfall.Route1DensityDomination.event_probability_dominated
#print axioms Nightfall.Route1DensityDomination.transfer_error_bound

import Mathlib

/-!
# Route 1: deterministic large-coordinate information charge

An unconditional finite-sum inequality for the large-mismatch branch of the
Route 1 argument. A posterior label distribution and per-coordinate squared
discrepancy budgets yield a dimension-independent bound on the expected
ordinary-row cost of the exceptional coordinates.

This module does NOT prove Pinsker, construct the star coupling, construct
posterior distributions, or certify the full Route 1 simulator.
-/

namespace Nightfall.Route1LargeSet

open Finset

variable {Θ ι : Type*} [Fintype Θ] [Fintype ι]

/-- The elementary pointwise Markov certificate. No assumptions on the sign
of the discrepancy are required. -/
theorem threshold_indicator_square (t η : ℝ) (hη : 0 < η) :
    (if η < t then (1 : ℝ) else 0) * η ^ 2 ≤ t ^ 2 := by
  by_cases h : η < t
  · simp only [if_pos h, one_mul]
    have hsum : 0 ≤ t + η := by linarith
    have hmul := mul_le_mul_of_nonneg_right h.le hsum
    nlinarith
  · simp only [if_neg h, zero_mul]
    exact sq_nonneg t

/-- Second moments control the posterior frequency of large coordinates.
All quantities are finite; zero posterior masses are allowed. -/
theorem posterior_large_frequency
    (π : Θ → ℝ) (q : Θ → ι → ℝ) (η B : ℝ)
    (hη : 0 < η) (hπ : ∀ θ, 0 ≤ π θ)
    (hsecond : ∀ i, (∑ θ, π θ * (q θ i) ^ 2) ≤ B)
    (i : ι) :
    (∑ θ, π θ * (if η < q θ i then (1 : ℝ) else 0))
      ≤ B / η ^ 2 := by
  classical
  have hηsq : 0 < η ^ 2 := pow_pos hη _
  have hterm (θ : Θ) :
      (π θ * (if η < q θ i then (1 : ℝ) else 0)) * η ^ 2
        ≤ π θ * (q θ i) ^ 2 := by
    calc
      (π θ * (if η < q θ i then (1 : ℝ) else 0)) * η ^ 2
          = π θ * ((if η < q θ i then (1 : ℝ) else 0) * η ^ 2) := by ring
      _ ≤ π θ * (q θ i) ^ 2 :=
        mul_le_mul_of_nonneg_left
          (threshold_indicator_square (q θ i) η hη) (hπ θ)
  have hsum :
      (∑ θ, π θ * (if η < q θ i then (1 : ℝ) else 0)) * η ^ 2
        ≤ ∑ θ, π θ * (q θ i) ^ 2 := by
    rw [Finset.sum_mul]
    exact Finset.sum_le_sum (fun θ _ => hterm θ)
  exact (le_div_iff₀ hηsq).2 (hsum.trans (hsecond i))

/-- Large-coordinate information charging, with one source-independent
ordinary row. This is the essential exchange of the posterior and coordinate
averages; the bound has no factor of the number of coordinates or labels. -/
theorem weighted_large_charge
    (π : Θ → ℝ) (q : Θ → ι → ℝ) (a : ι → ℝ)
    (η B K : ℝ)
    (hη : 0 < η) (hπ : ∀ θ, 0 ≤ π θ)
    (ha : ∀ i, 0 ≤ a i)
    (hB : 0 ≤ B)
    (hsecond : ∀ i, (∑ θ, π θ * (q θ i) ^ 2) ≤ B)
    (hcost : (∑ i, a i) ≤ K) :
    (∑ θ, π θ * (∑ i, if η < q θ i then a i else 0))
      ≤ K * (B / η ^ 2) := by
  classical
  have hηsq : 0 ≤ η ^ 2 := sq_nonneg _
  have hratio : 0 ≤ B / η ^ 2 := div_nonneg hB hηsq
  have hreorder :
      (∑ θ, π θ * (∑ i, if η < q θ i then a i else 0)) =
        ∑ i, a i * (∑ θ, π θ *
          (if η < q θ i then (1 : ℝ) else 0)) := by
    calc
      (∑ θ, π θ * (∑ i, if η < q θ i then a i else 0)) =
          ∑ θ, ∑ i, π θ * (if η < q θ i then a i else 0) := by
            simp only [Finset.mul_sum]
      _ = ∑ i, ∑ θ, π θ * (if η < q θ i then a i else 0) :=
        Finset.sum_comm
      _ = ∑ i, a i * (∑ θ, π θ *
          (if η < q θ i then (1 : ℝ) else 0)) := by
        apply Finset.sum_congr rfl
        intro i _
        rw [Finset.mul_sum]
        apply Finset.sum_congr rfl
        intro θ _
        by_cases h : η < q θ i <;> simp [h, mul_comm, mul_left_comm, mul_assoc]
  rw [hreorder]
  calc
    (∑ i, a i * (∑ θ, π θ *
      (if η < q θ i then (1 : ℝ) else 0))) ≤
      ∑ i, a i * (B / η ^ 2) := by
        apply Finset.sum_le_sum
        intro i _
        exact mul_le_mul_of_nonneg_left
          (posterior_large_frequency π q η B hη hπ hsecond i) (ha i)
    _ = (∑ i, a i) * (B / η ^ 2) := by rw [Finset.sum_mul]
    _ ≤ K * (B / η ^ 2) := mul_le_mul_of_nonneg_right hcost hratio

end Nightfall.Route1LargeSet

#print axioms Nightfall.Route1LargeSet.threshold_indicator_square
#print axioms Nightfall.Route1LargeSet.posterior_large_frequency
#print axioms Nightfall.Route1LargeSet.weighted_large_charge

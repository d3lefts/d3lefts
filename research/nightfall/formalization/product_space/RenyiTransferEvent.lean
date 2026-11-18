import Mathlib

/-!
# Finite change-of-measure gate for NIGHTFALL query simulation

Standalone general finite-space alpha=infinity event transfer.
Proves the event-dominance part of Step 4 only, not the product
total-influence potential or optional stopping in Steps 2 and 3.

Source: standard finite measure domination, no novelty claim.
-/

namespace Nightfall.RenyiSimulation

open Finset

variable {Ω : Type*} [Fintype Ω] [DecidableEq Ω]

/-- Pointwise domination of finite measures transfers to every event. -/
theorem event_mass_le_of_pointwise (mu nu : Ω → ℝ) (E : Finset Ω)
    (C : ℝ) (hdom : ∀ x, nu x ≤ C * mu x) :
    (∑ x ∈ E, nu x) ≤ C * (∑ x ∈ E, mu x) := by
  calc
    (∑ x ∈ E, nu x) ≤ ∑ x ∈ E, C * mu x := by
      apply Finset.sum_le_sum
      intro x hx
      exact hdom x
    _ = C * (∑ x ∈ E, mu x) := by
      rw [Finset.mul_sum]

/-- Density-ceiling error transfer, alpha=infinity finite-space case. -/
theorem error_probability_transfer_inf (mu nu : Ω → ℝ)
    (error : Ω → Prop) [DecidablePred error]
    (C delta0 delta : ℝ) (hC : 0 ≤ C)
    (hdom : ∀ x, nu x ≤ C * mu x)
    (hproduct : (∑ x ∈ Finset.univ.filter error, mu x) ≤ delta0)
    (hbudget : C * delta0 ≤ delta) :
    (∑ x ∈ Finset.univ.filter error, nu x) ≤ delta := by
  calc
    (∑ x ∈ Finset.univ.filter error, nu x)
        ≤ C * (∑ x ∈ Finset.univ.filter error, mu x) :=
          event_mass_le_of_pointwise mu nu _ C hdom
    _ ≤ C * delta0 := mul_le_mul_of_nonneg_left hproduct hC
    _ ≤ delta := hbudget

end Nightfall.RenyiSimulation

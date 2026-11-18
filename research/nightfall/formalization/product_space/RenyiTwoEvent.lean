import Mathlib

/-!
# Finite order-two Rényi event transfer (honest quantitative slice)

This proves the squared event mass inequality underlying D_2
change of measure from an arbitrary finite reference law mu.
The second moment can be controlled by exp(D_2(nu||mu)) when nu=mu*h.
This module alone does NOT formalize the adaptive query decision tree.
-/
namespace Nightfall.RenyiSimulation

open Finset

variable {Ω : Type*} [Fintype Ω] [DecidableEq Ω]

theorem event_mass_sq_le_second_moment
    (mu density : Ω → ℝ) (E : Finset Ω)
    (hmu : ∀ x, 0 ≤ mu x) :
    (∑ x ∈ E, mu x * density x) ^ 2 ≤
      (∑ x, mu x * density x ^ 2) * (∑ x ∈ E, mu x) := by
  have hcs : (∑ x ∈ E, mu x * density x) ^ 2 ≤
      (∑ x ∈ E, mu x * density x ^ 2) * (∑ x ∈ E, mu x) := by
    apply Finset.sum_sq_le_sum_mul_sum_of_sq_le_mul E
      (r := fun x => mu x * density x)
      (f := fun x => mu x * density x ^ 2)
      (g := mu)
    · intro x hx
      exact mul_nonneg (hmu x) (sq_nonneg _)
    · intro x hx
      exact hmu x
    · intro x hx
      apply le_of_eq
      ring
  have hsubset : (∑ x ∈ E, mu x * density x ^ 2) ≤
      (∑ x, mu x * density x ^ 2) := by
    apply Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ E)
    intro x hx hxnot
    exact mul_nonneg (hmu x) (sq_nonneg _)
  have hmass : 0 ≤ (∑ x ∈ E, mu x) :=
    Finset.sum_nonneg (fun x hx => hmu x)
  exact hcs.trans (mul_le_mul_of_nonneg_right hsubset hmass)

/-- Quantitative error transfer for order-2 density moment, no roots needed. -/
theorem error_probability_transfer_two
    (mu density : Ω → ℝ) (error : Finset Ω)
    (C δ : ℝ) (hmu : ∀ x, 0 ≤ mu x)
    (hdens : ∀ x, 0 ≤ density x) (hC : 0 ≤ C)
    (hδ : 0 ≤ δ)
    (hsecond : (∑ x, mu x * density x ^ 2) ≤ C)
    (hbudget : C * (∑ x ∈ error, mu x) ≤ δ ^ 2) :
    (∑ x ∈ error, mu x * density x) ≤ δ := by
  have hs := event_mass_sq_le_second_moment mu density error hmu
  have hm : 0 ≤ (∑ x ∈ error, mu x) :=
    Finset.sum_nonneg (fun x hx => hmu x)
  have hfirst : 0 ≤ (∑ x ∈ error, mu x * density x) := by
    apply Finset.sum_nonneg
    intro x hx
    exact mul_nonneg (hmu x) (hdens x)
  have hsq : (∑ x ∈ error, mu x * density x) ^ 2 ≤ δ ^ 2 := by
    calc
      _ ≤ (∑ x, mu x * density x ^ 2) *
            (∑ x ∈ error, mu x) := hs
      _ ≤ C * (∑ x ∈ error, mu x) :=
        mul_le_mul_of_nonneg_right hsecond hm
      _ ≤ δ ^ 2 := hbudget
  nlinarith

end Nightfall.RenyiSimulation

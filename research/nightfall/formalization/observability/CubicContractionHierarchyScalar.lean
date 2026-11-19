import Mathlib

/-!
# NIGHTFALL cubic contraction hierarchy: finite scalar core

This file deliberately proves only the scalar telescoping/induction step
in an iterated Poincare argument. No probability law, original-source
conditional expectation, derivative commutation, or Q3 influence bound is
assumed to have been formalized by this file.

The endpoint is intended to be applied when V(k) is the sum of variances
over ordered distinct k-tuples of derivatives, E(k) is the corresponding
sum of squared derivative expectations, and V(d) = 0 for degree <= d.
-/

namespace Nightfall.CubicContractionHierarchy

/-- A nonnegative-cost telescoping bound for a one-step energy recursion. -/
theorem finite_energy_telescoping
    (u e : ℕ → ℝ)
    (hstep : ∀ k : ℕ, u k ≤ e (k + 1) + u (k + 1))
    (d : ℕ) :
    u 0 ≤ (∑ k ∈ Finset.range d, e (k + 1)) + u d := by
  induction d with
  | zero =>
      simp
  | succ d ih =>
      rw [Finset.sum_range_succ]
      have hs := hstep d
      linarith

/--
The exactly finite scalar induction underlying an all-degree conditional
Poincare hierarchy. It does not assert or discharge the recurrence for any law.
-/
theorem scalar_contraction_hierarchy
    (A : ℝ) (hA : 0 ≤ A)
    (V E : ℕ → ℝ)
    (hstep : ∀ k : ℕ, V k ≤ A * (E (k + 1) + V (k + 1)))
    (d : ℕ) (hterminal : V d = 0) :
    V 0 ≤ ∑ k ∈ Finset.range d, A ^ (k + 1) * E (k + 1) := by
  have hscaled :
      ∀ k : ℕ, A ^ k * V k ≤
        A ^ (k + 1) * E (k + 1) + A ^ (k + 1) * V (k + 1) := by
    intro k
    have hs := mul_le_mul_of_nonneg_left (hstep k) (pow_nonneg hA k)
    calc
      A ^ k * V k ≤ A ^ k * (A * (E (k + 1) + V (k + 1))) := hs
      _ = A ^ (k + 1) * E (k + 1) +
            A ^ (k + 1) * V (k + 1) := by
            rw [pow_succ]
            ring
  have ht := finite_energy_telescoping
    (fun k => A ^ k * V k)
    (fun k => A ^ k * E k) hscaled d
  simpa [hterminal] using ht

#check Nightfall.CubicContractionHierarchy.finite_energy_telescoping
#check Nightfall.CubicContractionHierarchy.scalar_contraction_hierarchy
#print axioms Nightfall.CubicContractionHierarchy.finite_energy_telescoping
#print axioms Nightfall.CubicContractionHierarchy.scalar_contraction_hierarchy

end Nightfall.CubicContractionHierarchy

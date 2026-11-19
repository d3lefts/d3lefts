import Mathlib

/-!
# Endpoint Markov inequality, without a Markov hypothesis

The pinned Mathlib Chebyshev extremal theorem controls the derivative of
every polynomial bounded by one on [-1,1] at the endpoint +1.
Applying the same theorem to -P gives the two-sided bound.
The Chebyshev derivative's exact value n² is already in Mathlib.

This is a *proved* analytic inequality; it is NOT yet the scaled
interior inequality needed for all product-source paths. The latter
requires polynomial affine substitution / endpoint-to-interior transfer.
-/
namespace Nightfall.BiasFreeMarkov

open Polynomial

theorem chebyshev_endpoint_derivative_bound
    (P : Polynomial ℝ) (n : ℕ)
    (hdeg : P.degree ≤ n)
    (hbounded : ∀ x ∈ Set.Icc (-1 : ℝ) 1, |P.eval x| ≤ 1) :
    |(derivative P).eval 1| ≤ (n : ℝ) ^ 2 := by
  have hupper := Polynomial.Chebyshev.eval_iterate_derivative_le_of_forall_abs_le_one
    (P := P) (n := n) (k := 1) (x := 1) (by norm_num) hdeg hbounded
  have hnegdeg : (-P).degree ≤ (n : WithBot ℕ) := by simpa using hdeg
  have hnegbound : ∀ x ∈ Set.Icc (-1 : ℝ) 1, |(-P).eval x| ≤ 1 := by
    intro x hx
    simpa using hbounded x hx
  have hlower := Polynomial.Chebyshev.eval_iterate_derivative_le_of_forall_abs_le_one
    (P := -P) (n := n) (k := 1) (x := 1)
    (by norm_num) hnegdeg hnegbound
  have hT := Polynomial.Chebyshev.derivative_T_eval_one
    (R := ℝ) (n := (n : ℤ))
  have hu : (derivative P).eval 1 ≤ (n : ℝ) ^ 2 := by
    simp only [Function.iterate_one] at hupper
    rw [hT] at hupper
    norm_cast at hupper
    simpa only [Nat.cast_pow] using hupper
  have hl : -(n : ℝ) ^ 2 ≤ (derivative P).eval 1 := by
    simp only [Function.iterate_one] at hlower
    rw [hT] at hlower
    simp only [derivative_neg, eval_neg] at hlower
    norm_cast at hlower
    have hlower' : -(derivative P).eval 1 ≤ (n : ℝ) ^ 2 := by
      simpa only [Nat.cast_pow] using hlower
    linarith
  exact abs_le.mpr ⟨hl, hu⟩

end Nightfall.BiasFreeMarkov

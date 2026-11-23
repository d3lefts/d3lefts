import Mathlib

/-!
Quadratic Wyner: source-independent finite coupling transfer core.
This is NOT the complete QW theorem. The source-specific identities,
product-law Q2 bound, information dichotomy and tree terminal remain
independent obligations.
-/
namespace Nightfall.QuadraticWynerTransferCore
open Finset

theorem three_term_squared (x y z : ℝ) :
    (x + y + z) ^ 2 ≤ 4 * x ^ 2 + 2 * y ^ 2 + 4 * z ^ 2 := by
  nlinarith [sq_nonneg (2 * x - y), sq_nonneg (2 * z - y), sq_nonneg (x - z)]

theorem four_point (a b c d : ℝ) :
    (a - d) ^ 2 ≤ 4 * (a - b) ^ 2 + 2 * (b - c) ^ 2 + 4 * (c - d) ^ 2 := by
  have h := three_term_squared (a - b) (b - c) (c - d)
  nlinarith

/-- Arbitrary finite nonnegative masses, including zero atoms. -/
theorem weighted_four_point {Ω : Type} [Fintype Ω]
    (μ : Ω → ℝ) (hμ : ∀ ω, 0 ≤ μ ω)
    (a b c d : Ω → ℝ) :
    (∑ ω, μ ω * (a ω - d ω) ^ 2) ≤
      4 * (∑ ω, μ ω * (a ω - b ω) ^ 2) +
      2 * (∑ ω, μ ω * (b ω - c ω) ^ 2) +
      4 * (∑ ω, μ ω * (c ω - d ω) ^ 2) := by
  classical
  calc
    (∑ ω, μ ω * (a ω - d ω) ^ 2) ≤
        ∑ ω, (4 * μ ω * (a ω - b ω) ^ 2 +
          2 * μ ω * (b ω - c ω) ^ 2 +
          4 * μ ω * (c ω - d ω) ^ 2) := by
      apply Finset.sum_le_sum
      intro ω _
      have h := mul_le_mul_of_nonneg_left (four_point (a ω) (b ω) (c ω) (d ω)) (hμ ω)
      nlinarith
    _ = 4 * (∑ ω, μ ω * (a ω - b ω) ^ 2) +
        2 * (∑ ω, μ ω * (b ω - c ω) ^ 2) +
        4 * (∑ ω, μ ω * (c ω - d ω) ^ 2) := by
      simp only [Finset.sum_add_distrib, mul_assoc, ← Finset.mul_sum]
      ring

/-- Factor-four original-source influence transfer, conditional on the
actual coupled source resampling equalities. -/
theorem quarter_original_influence {Ω : Type} [Fintype Ω]
    (μ : Ω → ℝ) (hμ : ∀ ω, 0 ≤ μ ω)
    (a b c d : Ω → ℝ) (Iq Ip Δ : ℝ)
    (hIq : (∑ ω, μ ω * (a ω - d ω) ^ 2) = 2 * Iq)
    (hIp : (∑ ω, μ ω * (b ω - c ω) ^ 2) = 2 * Ip)
    (hΔ₁ : (∑ ω, μ ω * (a ω - b ω) ^ 2) ≤ Δ)
    (hΔ₂ : (∑ ω, μ ω * (c ω - d ω) ^ 2) ≤ Δ)
    (hsmall : 8 * Δ ≤ Iq) :
    Iq ≤ 4 * Ip := by
  have h := weighted_four_point μ hμ a b c d
  rw [hIq, hIp] at h
  linarith

/-- Variance survival given a separately proved source stability inequality. -/
theorem variance_survival (τ C Δ Vν Vq : ℝ)
    (hτ : 0 < τ) (hC : 2 ≤ C) (hΔ : 0 ≤ Δ)
    (hbound : 32 * C * Δ ≤ τ ^ 2)
    (hstable : (Vν - Vq) ^ 2 ≤ 16 * Δ)
    (hvar : τ < Vν) : τ / 2 < Vq := by
  have h64 : 64 * Δ ≤ τ ^ 2 := by
    nlinarith [mul_nonneg (show 0 ≤ C - 2 by linarith) hΔ]
  by_contra hn
  have hd : τ / 2 < Vν - Vq := by push_neg at hn; linarith
  have hsq : (τ / 2) ^ 2 < (Vν - Vq) ^ 2 := by nlinarith
  nlinarith

/-- Algebraic Q2-to-original-progress implication, conditional on Q2. -/
theorem quadratic_progress (τ C Vq Iq Ip : ℝ)
    (hτ : 0 < τ) (hC : 0 ≤ C)
    (hVq : τ / 2 < Vq) (hQ2 : Vq ^ 2 ≤ C * Iq)
    (htransfer : Iq ≤ 4 * Ip) :
    τ ^ 2 < 16 * C * Ip := by
  have hsq : (τ / 2) ^ 2 < Vq ^ 2 := by nlinarith
  have hmul : C * Iq ≤ 4 * C * Ip := by
    nlinarith [mul_nonneg hC (sub_nonneg.mpr htransfer)]
  nlinarith

#print axioms Nightfall.QuadraticWynerTransferCore.three_term_squared
#print axioms Nightfall.QuadraticWynerTransferCore.four_point
#print axioms Nightfall.QuadraticWynerTransferCore.weighted_four_point
#print axioms Nightfall.QuadraticWynerTransferCore.quarter_original_influence
#print axioms Nightfall.QuadraticWynerTransferCore.variance_survival
#print axioms Nightfall.QuadraticWynerTransferCore.quadratic_progress
end Nightfall.QuadraticWynerTransferCore

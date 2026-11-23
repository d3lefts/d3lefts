import QuadraticWynerTransferCore

/-!
# Quadratic Wyner direct influence domination and generic posterior crux

This proof uses the 4-corner coupled resampling inequality WITHOUT
intermediate square-root or quarter-influence assumptions. It isolates
an explicit interface for the real source-specific coupling:

    Inf_Q,j <= (E_theta original pincr_j) + 4 Delta.

Conditional on that source-specific inequality, variance stability,
and the original C105.416 product Q2 theorem, it yields an influential
ORIGINAL coordinate with the exact QW increment threshold.

No full Wyner theorem follows from this generic statement unless
the actual seed coupling supplies the hypotheses at every posterior.
-/

namespace Nightfall.QuadraticWynerDirectCrux
open Finset
open Nightfall.QuadraticWynerTransferCore

/-- Direct coupled original-reference source influence transfer.
All zero-mass atoms allowed. The four evaluation arrays must be
drawn using one common latent theta and one fresh independent seed. -/
theorem direct_resampling_influence {Ω : Type} [Fintype Ω]
    (μ : Ω → ℝ) (hμ : ∀ ω, 0 ≤ μ ω)
    (a b c d : Ω → ℝ) (Iq Ip Δ : ℝ)
    (hIq : (∑ ω, μ ω * (a ω - d ω) ^ 2) = 2 * Iq)
    (hIp : (∑ ω, μ ω * (b ω - c ω) ^ 2) = 2 * Ip)
    (hΔ₁ : (∑ ω, μ ω * (a ω - b ω) ^ 2) ≤ Δ)
    (hΔ₂ : (∑ ω, μ ω * (c ω - d ω) ^ 2) ≤ Δ) :
    Iq ≤ 2 * Ip + 4 * Δ := by
  have h := weighted_four_point μ hμ a b c d
  rw [hIq, hIp] at h
  linarith

/-- Under |f|<=1, the per-component mean absolute increment
dominates twice the component Efron-Stein influence. The hypothesis
is explicit here; the actual source theorem is already certified
in Route1PolylogSimulation. -/
theorem direct_resampling_increment {Ω : Type} [Fintype Ω]
    (μ : Ω → ℝ) (hμ : ∀ ω, 0 ≤ μ ω)
    (a b c d : Ω → ℝ) (Iq Ip Δ L : ℝ)
    (hIq : (∑ ω, μ ω * (a ω - d ω) ^ 2) = 2 * Iq)
    (hIp : (∑ ω, μ ω * (b ω - c ω) ^ 2) = 2 * Ip)
    (hΔ₁ : (∑ ω, μ ω * (a ω - b ω) ^ 2) ≤ Δ)
    (hΔ₂ : (∑ ω, μ ω * (c ω - d ω) ^ 2) ≤ Δ)
    (hbounded : 2 * Ip ≤ L) :
    Iq ≤ L + 4 * Δ := by
  have h := direct_resampling_influence μ hμ a b c d Iq Ip Δ
    hIq hIp hΔ₁ hΔ₂
  linarith

/-- A genuine coordinate from high source variance, reference
source Q2, finite variance comparison, and the coupled increment
transfer. The actual-source identities are separately required. -/
theorem quadratic_original_increment_of_source_facts
    {ι : Type} [Fintype ι]
    (τ C Δ Vν Vq : ℝ) (Iq L : ι → ℝ)
    (hτ : 0 < τ) (hC : 2 ≤ C) (hΔ : 0 ≤ Δ)
    (hcoupling : 32 * C * Δ ≤ τ ^ 2)
    (hstable : (Vν - Vq) ^ 2 ≤ 16 * Δ)
    (hvar : τ < Vν)
    (hQ2 : ∀ M : ℝ, 0 ≤ M →
      (∀ j, Iq j ≤ M) → Vq ^ 2 ≤ C * M)
    (htransfer : ∀ j, Iq j ≤ L j + 4 * Δ) :
    ∃ j, τ ^ 2 < 8 * C * L j := by
  classical
  have hvq : τ / 2 < Vq :=
    variance_survival τ C Δ Vν Vq hτ hC hΔ hcoupling hstable hvar
  have hCpos : 0 < C := by linarith
  have h4Cpos : 0 < 4 * C := by positivity
  by_contra hn
  push_neg at hn
  have hbound : ∀ j, Iq j ≤ τ ^ 2 / (4 * C) := by
    intro j
    have hLj := hn j
    have htr := htransfer j
    have hC0 : 0 ≤ C := hCpos.le
    have hmul : C * Iq j ≤ C * (L j + 4 * Δ) :=
      mul_le_mul_of_nonneg_left htr hC0
    have hnum : 4 * C * Iq j ≤ τ ^ 2 := by
      nlinarith [hLj, hcoupling, hmul]
    exact (le_div_iff₀ h4Cpos).2 (by nlinarith [hnum])
  have hM : 0 ≤ τ ^ 2 / (4 * C) := by positivity
  have hsmall := hQ2 (τ ^ 2 / (4 * C)) hM hbound
  have hsmall' : Vq ^ 2 ≤ τ ^ 2 / 4 := by
    calc
      Vq ^ 2 ≤ C * (τ ^ 2 / (4 * C)) := hsmall
      _ = τ ^ 2 / 4 := by field_simp; ring
  nlinarith [sq_nonneg (Vq - τ / 2)]

#print axioms Nightfall.QuadraticWynerDirectCrux.direct_resampling_influence
#print axioms Nightfall.QuadraticWynerDirectCrux.direct_resampling_increment
#print axioms Nightfall.QuadraticWynerDirectCrux.quadratic_original_increment_of_source_facts
end Nightfall.QuadraticWynerDirectCrux

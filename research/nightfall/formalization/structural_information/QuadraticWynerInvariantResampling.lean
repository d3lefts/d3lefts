import QuadraticWynerTransferCore

/-!
# Quadratic Wyner: invariant-resampling operator

Reusable invariant: a nonnegative finite source mass mu and a
measure-preserving resampling map R. This abstracts the exact
coordinate-update involution in ProductInfluence without changing
the latent label. We prove source-specific influence transport with
no square roots, no degree lift, and no restriction on atom support.

The actual finite-star QW theorem must instantiate R on a
fixed-latent joint seed/resampling law, prove the pushforward identity
using the true reference marginal, and compose the posterior crux.
-/

namespace Nightfall.QuadraticWynerInvariantResampling
open Finset
open Nightfall.QuadraticWynerTransferCore

/-- A finite nonnegative mass and an invariant resampling operator.
No normalization, positivity floor or involution is needed here. -/
theorem invariant_squared_transfer
    {Ω : Type} [Fintype Ω]
    (μ : Ω → ℝ) (hμ : ∀ ω, 0 ≤ μ ω)
    (R : Ω → Ω)
    (hR : ∀ H : Ω → ℝ,
      (∑ ω, μ ω * H (R ω)) = ∑ ω, μ ω * H ω)
    (F G : Ω → ℝ) :
    (∑ ω, μ ω * (F ω - F (R ω)) ^ 2) ≤
      2 * (∑ ω, μ ω * (G ω - G (R ω)) ^ 2) +
      8 * (∑ ω, μ ω * (F ω - G ω) ^ 2) := by
  have h := weighted_four_point μ hμ F G
    (fun ω => G (R ω)) (fun ω => F (R ω))
  have houter :
      (∑ ω, μ ω * (G (R ω) - F (R ω)) ^ 2) =
      (∑ ω, μ ω * (F ω - G ω) ^ 2) := by
    calc
      (∑ ω, μ ω * (G (R ω) - F (R ω)) ^ 2) =
          ∑ ω, μ ω * (F (R ω) - G (R ω)) ^ 2 := by
        apply Finset.sum_congr rfl
        intro ω _
        ring
      _ = ∑ ω, μ ω * (F ω - G ω) ^ 2 :=
        hR (fun ω => (F ω - G ω) ^ 2)
  rw [houter] at h
  linarith

/-- The Efron-Stein normalization (one half of squared resampling)
follows from the same invariant. A caller must still prove the true
source-operator identification with pinfl. -/
theorem invariant_half_influence_transfer
    {Ω : Type} [Fintype Ω]
    (μ : Ω → ℝ) (hμ : ∀ ω, 0 ≤ μ ω)
    (R : Ω → Ω)
    (hR : ∀ H : Ω → ℝ,
      (∑ ω, μ ω * H (R ω)) = ∑ ω, μ ω * H ω)
    (F G : Ω → ℝ) :
    (∑ ω, μ ω * ((F ω - F (R ω)) ^ 2 / 2)) ≤
      2 * (∑ ω, μ ω * ((G ω - G (R ω)) ^ 2 / 2)) +
      4 * (∑ ω, μ ω * (F ω - G ω) ^ 2) := by
  have h := invariant_squared_transfer μ hμ R hR F G
  have hF :
      (∑ ω, μ ω * ((F ω - F (R ω)) ^ 2 / 2)) =
       (∑ ω, μ ω * (F ω - F (R ω)) ^ 2) / 2 := by
    rw [Finset.sum_div]
    apply Finset.sum_congr rfl
    intro ω _
    ring
  have hG :
      (∑ ω, μ ω * ((G ω - G (R ω)) ^ 2 / 2)) =
       (∑ ω, μ ω * (G ω - G (R ω)) ^ 2) / 2 := by
    rw [Finset.sum_div]
    apply Finset.sum_congr rfl
    intro ω _
    ring
  rw [hF, hG]
  linarith

#print axioms Nightfall.QuadraticWynerInvariantResampling.invariant_squared_transfer
#print axioms Nightfall.QuadraticWynerInvariantResampling.invariant_half_influence_transfer
end Nightfall.QuadraticWynerInvariantResampling

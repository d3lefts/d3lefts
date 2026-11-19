import MixtureSimulation

/-!
# NIGHTFALL latent product sources — certified bias-free separation gate

Uses the already kernel-checked `Mixture.fooling_tv` source. No c>0 atom condition.
This does NOT certify the likelihood-testing/Hellinger/logarithmic-query bound.
-/

namespace Nightfall.ProductSpace.LatentComponent

open Finset
open Nightfall.ProductSpace.Transfer
open Nightfall.ProductSpace.RowBound
open Nightfall.ProductSpace.Mixture

variable {ι α : Type} [Fintype ι] [DecidableEq ι] [Fintype α] [DecidableEq α]

/-- Arbitrary positive TV threshold, without the previous γ≤1/2 restriction. -/
theorem fooling_tv_positive_gap
    (μ ν : ι → α → ℝ)
    (hμ0 : ∀ i s, 0 ≤ μ i s) (hν0 : ∀ i s, 0 ≤ ν i s)
    (hμ1 : ∀ i, ∑ s, μ i s = 1) (hν1 : ∀ i, ∑ s, ν i s = 1)
    (γ : ℝ) (hγ : 0 < γ) (hTV : ∀ i, tvd (μ i) (ν i) ≤ γ)
    (d : ℕ) (hd : 1 ≤ d) (f : (ι → α) → ℝ)
    (hf : ∀ x, 0 ≤ f x ∧ f x ≤ 1) (hdegree : HasProdDegreeLE f d) :
    |pexp μ f - pexp ν f| ≤ 16 * (d : ℝ) ^ 2 * γ := by
  by_cases hhalf : γ ≤ (1 / 2 : ℝ)
  · have hfn : ∀ x, |f x| ≤ 1 := by
      intro x
      exact abs_le.mpr ⟨by linarith [(hf x).1], by linarith [(hf x).2]⟩
    exact fooling_tv μ ν hμ0 hν0 hμ1 hν1 γ hγ hhalf hTV d f hfn hdegree
  · have hpos : (1 / 2 : ℝ) < γ := lt_of_not_ge hhalf
    have hμ := pexp_bounds μ hμ0 hμ1 f hf
    have hν := pexp_bounds ν hν0 hν1 f hf
    have hone : |pexp μ f - pexp ν f| ≤ 1 :=
      abs_le.mpr ⟨by linarith [hμ.1, hν.2], by linarith [hμ.2, hν.1]⟩
    have hdreal : (1 : ℝ) ≤ (d : ℝ) := by exact_mod_cast hd
    have hlarge : (1 : ℝ) ≤ 16 * (d : ℝ) ^ 2 * γ := by
      nlinarith [sq_nonneg ((d : ℝ) - 1)]
    exact hone.trans hlarge

/-- An expectation gap larger than `16 d² γ` must be witnessed by a coordinate-TV gap.
    This is an exact finite-alphabet result, independent of minimum mass and ambient dimension. -/
theorem expectation_gap_forces_coordinate
    (μ ν : ι → α → ℝ)
    (hμ0 : ∀ i s, 0 ≤ μ i s) (hν0 : ∀ i s, 0 ≤ ν i s)
    (hμ1 : ∀ i, ∑ s, μ i s = 1) (hν1 : ∀ i, ∑ s, ν i s = 1)
    (γ : ℝ) (hγ : 0 < γ)
    (d : ℕ) (hd : 1 ≤ d) (f : (ι → α) → ℝ)
    (hf : ∀ x, 0 ≤ f x ∧ f x ≤ 1) (hdegree : HasProdDegreeLE f d)
    (hgap : 16 * (d : ℝ) ^ 2 * γ < |pexp μ f - pexp ν f|) :
    ∃ i : ι, γ < tvd (μ i) (ν i) := by
  by_contra hnone
  push_neg at hnone
  have hbound := fooling_tv_positive_gap μ ν hμ0 hν0 hμ1 hν1 γ hγ hnone d hd f hf hdegree
  linarith

end Nightfall.ProductSpace.LatentComponent

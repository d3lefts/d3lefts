import ActualSourceProjectedJensen
import ActualSourceQuadraticSupportSum

/-!
# Exact pair-projection norm budget from the original-source Jensen operator

No external conditional-section amplitude, pair norm or energy
assumption. The vector being subtracted is the true singleton mean
of the same original source. Source degree two will identify the
difference with precisely the greedily owned pair sector.
-/

namespace Nightfall.Observability.ActualSourceProjectedPairJensen

open Finset
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualSourceInfluenceEnergy
open Nightfall.Observability.ActualSourceConditionalSection
open Nightfall.Observability.ActualSourceMeanSectionJensen
open Nightfall.Observability.ActualSourceProjectedJensen
open Nightfall.Observability.ActualSourceIntegratedSections
open Nightfall.Observability.ActualProductSourceDerivedStar

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

/-- Minkowski/triangle inequality for nonnegative possibly-zero
categorical source weights, via the already checked finite Hilbert
Jensen operator on a two-point auxiliary *proof* index. -/
theorem source_weighted_hilbert_norm_sub_le
    (q : α → ℝ) (hq : ∀ a, 0 ≤ q a)
    (v w : α → ℝ) :
    norm q (fun a => v a - w a) ≤ norm q v + norm q w := by
  classical
  let μ : Bool → ℝ := fun _ => (1 : ℝ)
  let Y : Bool → α → ℝ := fun b a => if b then v a else -w a
  have h := weighted_hilbert_jensen μ q Y
    (by intro b; simp [μ]) hq
  have hL :
      norm q (fun a => ∑ b : Bool, μ b * Y b a) =
      norm q (fun a => v a - w a) := by
    congr 1
    funext a
    simp [μ, Y, Finset.sum_bool, sub_eq_add_neg]
  have hNeg : norm q (fun a => -w a) = norm q w := by
    simp [norm, sqNorm]
  have hR :
      (∑ b : Bool, μ b * norm q (Y b)) =
      norm q v + norm q w := by
    simp [μ, Y, Finset.sum_bool, hNeg, add_comm]
  calc
    norm q (fun a => v a - w a) =
      norm q (fun a => ∑ b : Bool, μ b * Y b a) := hL.symm
    _ ≤ ∑ b : Bool, μ b * norm q (Y b) := h
    _ = norm q v + norm q w := hR

/-- Genuine conditional centered section after subtracting the
original product-law singleton mean. -/
noncomputable def projectedPairNorm
    (p : ι → α → ℝ) (f : (ι → α) → ℝ)
    (i : ι) (S : Finset ι) (x : ι → α) : ℝ :=
  norm (p i) (fun a =>
    averageSourceSection p f i S x a -
      ∑ y : ι → α, originalMass p y *
        sourceCenteredSection p f i y a)

noncomputable def meanProjectedPairNorm
    (p : ι → α → ℝ) (f : (ι → α) → ℝ)
    (i : ι) (S : Finset ι) : ℝ :=
  ∑ x : ι → α, originalMass p x *
    projectedPairNorm p f i S x

/-- Each source pair projection's mean Hilbert norm is controlled by
the true unconditioned section plus its original singleton mean. -/
theorem source_projected_pair_jensen_budget
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (i : ι) (S : Finset ι) :
    meanProjectedPairNorm p f i S ≤
      sourceMeanSectionNorm p f i +
        originalSingletonNorm p f i := by
  classical
  have hm (x : ι → α) : 0 ≤ originalMass p x := by
    unfold originalMass
    exact Finset.prod_nonneg (fun k _ => hp k (x k))
  have hpoint (x : ι → α) :
      projectedPairNorm p f i S x ≤
        projectedSourceNorm p f i S x +
          originalSingletonNorm p f i := by
    have h := source_weighted_hilbert_norm_sub_le (p i) (hp i)
      (fun a => averageSourceSection p f i S x a)
      (fun a => ∑ y : ι → α, originalMass p y *
        sourceCenteredSection p f i y a)
    simpa only [projectedPairNorm, projectedSourceNorm,
      originalSingletonNorm, norm, sqNorm] using h
  calc
    meanProjectedPairNorm p f i S ≤
      ∑ x : ι → α, originalMass p x *
        (projectedSourceNorm p f i S x +
          originalSingletonNorm p f i) := by
      unfold meanProjectedPairNorm
      apply Finset.sum_le_sum
      intro x _
      exact mul_le_mul_of_nonneg_left (hpoint x) (hm x)
    _ = meanProjectedSourceNorm p f i S +
        originalSingletonNorm p f i := by
      simp only [mul_add, Finset.sum_add_distrib,
        meanProjectedSourceNorm]
      rw [← Finset.sum_mul, sum_originalMass' p hp1, one_mul]
    _ ≤ sourceMeanSectionNorm p f i +
        originalSingletonNorm p f i := by
      exact add_le_add_right
        (mean_projected_source_norm_le_unprojected p hp hp1 f i S) _

end Nightfall.Observability.ActualSourceProjectedPairJensen

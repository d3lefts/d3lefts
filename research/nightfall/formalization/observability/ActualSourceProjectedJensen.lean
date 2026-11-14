import ActualSourceMeanSectionJensen
import ActualSourceConditionalSection

/-!
# Integrated original-source conditional Hilbert Jensen

For every genuine subset S of coordinate labels, the L2(p_i) norm
of the source-conditioned *centered* section is L1-controlled by
the original-source centered section. This is not the owned-pair
identification, which requires degree-two ANOVA and a greedy edge
projection; no extra projective norm estimate is assumed here.
-/

namespace Nightfall.Observability.ActualSourceProjectedJensen

open Finset
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualSourceMeanSectionJensen
open Nightfall.Observability.ActualSourceConditionalSection
open Nightfall.Observability.ActualSourceIntegratedSections
open Nightfall.Observability.ActualSourceInfluenceEnergy

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

/-- Source-projected Hilbert norm; the conditional is the actual
finite p-product conditional, including arbitrary zero atoms. -/
noncomputable def projectedSourceNorm
    (p : ι → α → ℝ) (f : (ι → α) → ℝ)
    (i : ι) (S : Finset ι) (x : ι → α) : ℝ :=
  Real.sqrt (∑ a : α, p i a *
    (averageSourceSection p f i S x a)^2)

noncomputable def meanProjectedSourceNorm
    (p : ι → α → ℝ) (f : (ι → α) → ℝ)
    (i : ι) (S : Finset ι) : ℝ :=
  ∑ x : ι → α, originalMass p x *
    projectedSourceNorm p f i S x

/-- Conditional Jensen, using the ORIGINAL product weights p at
both the outer and the refreshed inner samples. -/
theorem source_projected_norm_pointwise_jensen
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (f : (ι → α) → ℝ)
    (i : ι) (S : Finset ι) (x : ι → α) :
    projectedSourceNorm p f i S x ≤
      ∑ y : ι → α, originalMass p y *
        sourceSectionNorm p f i (merge S x y) := by
  classical
  have hm (y : ι → α) : 0 ≤ originalMass p y := by
    unfold originalMass
    exact Finset.prod_nonneg (fun k _ => hp k (y k))
  have h := weighted_hilbert_jensen
    (originalMass p) (p i)
    (fun y a => sourceSection p f i (merge S x y) a)
    hm (hp i)
  simpa only [projectedSourceNorm, sourceSectionNorm,
    ActualSourceMeanSectionJensen.norm,
    ActualSourceMeanSectionJensen.sqNorm,
    averageSourceSection, sourceSection,
    sourceCenteredSection] using h

/-- Integrated conditional contraction, without assuming any
external mean-sectional, noise or influence budget. -/
theorem mean_projected_source_norm_le_unprojected
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (i : ι) (S : Finset ι) :
    meanProjectedSourceNorm p f i S ≤
      sourceMeanSectionNorm p f i := by
  classical
  have hm (x : ι → α) : 0 ≤ originalMass p x := by
    unfold originalMass
    exact Finset.prod_nonneg (fun k _ => hp k (x k))
  calc
    meanProjectedSourceNorm p f i S ≤
      ∑ x : ι → α, originalMass p x *
        (∑ y : ι → α, originalMass p y *
          sourceSectionNorm p f i (merge S x y)) := by
      unfold meanProjectedSourceNorm
      apply Finset.sum_le_sum
      intro x _
      exact mul_le_mul_of_nonneg_left
        (source_projected_norm_pointwise_jensen p hp f i S x) (hm x)
    _ = sourceMeanSectionNorm p f i := by
      unfold sourceMeanSectionNorm
      have hmerge (x y : ι → α) :
          ActualSourceANOVA.merge S x y =
          ActualProductMergeTower.keepSource S x y := by
        funext k
        simp only [ActualSourceANOVA.merge,
          ActualProductMergeTower.keepSource]
      simp_rw [hmerge]
      exact actual_product_merge_tower p hp1 S
        (sourceSectionNorm p f i)

/-- Uniform 8B budget for any owner-selected conditioning sets,
already valid before their ANOVA pair sectors are identified. -/
theorem all_mean_projected_source_norms_le_eight
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (B : ℝ) (hB : 0 ≤ B)
    (hf : ∀ x, |f x| ≤ B)
    (S : ι → Finset ι) :
    (∑ i : ι, meanProjectedSourceNorm p f i (S i)) ≤ 8 * B := by
  calc
    (∑ i : ι, meanProjectedSourceNorm p f i (S i)) ≤
      ∑ i : ι, sourceMeanSectionNorm p f i :=
      Finset.sum_le_sum (fun i _ =>
        mean_projected_source_norm_le_unprojected p hp hp1 f i (S i))
    _ ≤ 8 * B :=
      actual_source_integrated_eight_budget p hp hp1 f hdegree B hB hf

end Nightfall.Observability.ActualSourceProjectedJensen

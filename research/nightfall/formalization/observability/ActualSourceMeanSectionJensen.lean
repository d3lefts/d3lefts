import ActualSourceIntegratedSections
import ActualSourceInfluenceEnergy
import ActualESConditionalJensen

/-!
# Original-product mean-section Jensen, no auxiliary scalar budget

The original finite categorical law p determines both the centering
section U_i and its expected L2(p_i) norm. Weighted Hilbert Jensen
implies the L2 norm of the mean section is at most that expected norm.
No synthetic source distribution or lower atom-mass assumption.
-/

namespace Nightfall.Observability.ActualSourceMeanSectionJensen

open Finset
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.ActualSourceIntegratedSections
open Nightfall.Observability.ActualSourceInfluenceEnergy

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
    [Fintype α] [DecidableEq α] [Nonempty α]

noncomputable def originalSingletonNorm
    (p : ι → α → ℝ) (f : (ι → α) → ℝ) (i : ι) : ℝ :=
  Real.sqrt (∑ a : α, p i a *
    (∑ x : ι → α, originalMass p x *
      sourceCenteredSection p f i x a)^2)

/-- The genuine singleton-mean L2 norm is no greater than the
expected original-source centered-section L2 norm. -/
theorem original_singleton_norm_le_source_mean_section_norm
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (f : (ι → α) → ℝ) (i : ι) :
    originalSingletonNorm p f i ≤ sourceMeanSectionNorm p f i := by
  classical
  have hm (x : ι → α) : 0 ≤ originalMass p x := by
    unfold originalMass
    exact Finset.prod_nonneg (fun j _ => hp j (x j))
  have h := Nightfall.Observability.ActualESConditionalJensen.weighted_hilbert_jensen
    (originalMass p) (p i)
    (fun x a => sourceCenteredSection p f i x a)
    hm (hp i)
  simpa only [originalSingletonNorm, sourceMeanSectionNorm,
    sourceSectionNorm, sourceCenteredSection,
    Nightfall.Observability.ActualESConditionalJensen.norm,
    Nightfall.Observability.ActualESConditionalJensen.sqNorm] using h

/-- The author-analytic 8B section bound supplies the additive
mean-section budget for the same genuine source law, by Jensen. -/
theorem original_singleton_norm_sum_le_eight
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : Nightfall.Observability.ActualSourceANOVA.ESDegreeLE p f 2)
    (B : ℝ) (hB : 0 ≤ B) (hf : ∀ x, |f x| ≤ B) :
    (∑ i : ι, originalSingletonNorm p f i) ≤ 8 * B := by
  calc
    (∑ i : ι, originalSingletonNorm p f i) ≤
      ∑ i : ι, sourceMeanSectionNorm p f i :=
        Finset.sum_le_sum (fun i _ =>
          original_singleton_norm_le_source_mean_section_norm p hp f i)
    _ ≤ 8 * B :=
      actual_source_integrated_eight_budget p hp hp1 f hdegree B hB hf

end Nightfall.Observability.ActualSourceMeanSectionJensen

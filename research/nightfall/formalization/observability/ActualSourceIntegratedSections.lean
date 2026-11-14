import ActualSourceDegreeTwoAllDimensions
import ActualSourceANOVA

/-!
# Integrating the genuine original-source 8B section estimate

The 8B switching/Popoviciu source bound is pointwise in X.
This theorem converts it to a total actual-product first-norm budget,
with no supplied expectation/section oracle. This budget is exactly
the scalar input needed by the Q2 endpoint.
-/

namespace Nightfall.Observability.ActualSourceIntegratedSections

open Finset
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.ActualSourceDegreeTwoAllDimensions

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

/-- Weighted L² norm of the ACTUAL centered conditional coordinate
section, conditional on the other original coordinates. -/
noncomputable def sourceSectionNorm
    (p : ι → α → ℝ) (f : (ι → α) → ℝ)
    (i : ι) (x : ι → α) : ℝ :=
  Real.sqrt (∑ a : α, p i a *
    (f (Function.update x i a) -
      (∑ b : α, p i b * f (Function.update x i b)))^2)

/-- Original finite-law mean of the coordinate section L² norm. -/
noncomputable def sourceMeanSectionNorm
    (p : ι → α → ℝ) (f : (ι → α) → ℝ)
    (i : ι) : ℝ :=
  ∑ x : ι → α, originalMass p x * sourceSectionNorm p f i x

/-- The source degree-two 8B pointwise bound integrates to the exact
same 8B L¹-in-coordinates source expectation budget.
No synthetic law, pair interaction, or moment assumption. -/
theorem actual_source_integrated_eight_budget
    (p : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (B : ℝ) (hB : 0 ≤ B) (hf : ∀ x, |f x| ≤ B) :
    (∑ i : ι, sourceMeanSectionNorm p f i) ≤ 8 * B := by
  classical
  have hmass (x : ι → α) : 0 ≤ originalMass p x := by
    unfold originalMass
    exact Finset.prod_nonneg (fun i _ => hp i (x i))
  have hpoint (x : ι → α) :
      (∑ i : ι, sourceSectionNorm p f i x) ≤ 8 * B := by
    simpa only [sourceSectionNorm] using
      actual_degree_two_source_section_budget_eight_all_current
        p hp hp1 f B hB hf hdegree x
  calc
    (∑ i : ι, sourceMeanSectionNorm p f i) =
      ∑ x : ι → α,
        originalMass p x * (∑ i : ι, sourceSectionNorm p f i x) := by
      unfold sourceMeanSectionNorm
      rw [Finset.sum_comm]
      apply Finset.sum_congr rfl
      intro x _
      rw [Finset.mul_sum]
    _ ≤ ∑ x : ι → α, originalMass p x * (8 * B) := by
      apply Finset.sum_le_sum
      intro x _
      exact mul_le_mul_of_nonneg_left (hpoint x) (hmass x)
    _ = 8 * B := by
      rw [← Finset.sum_mul, sum_originalMass' p hp1, one_mul]

end Nightfall.Observability.ActualSourceIntegratedSections

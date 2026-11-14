import ActualSourceConditionalProjection
import ActualProductSoftStar

/-!
# Exact original-product noise spectrum for Efron–Stein components

This is the missing operator mechanism in the sharp Q2 route:
coordinatewise source refresh preserves each canonical ES component
with multiplier product of its original-coordinate retain factors.
No binary alphabet, minimum atom weight, synthetic source law, or
pre-assumed eigenoperator identity is used.

This file does NOT itself establish the improved singleton 2(1+sqrt2)B
budget or the terminal sharp Q2 inequality. Strict pinned compilation
of the declarations is required before citing any as certified.
-/

namespace Nightfall.Observability.ActualSourceNoiseEfronStein

open Finset
open Nightfall.Observability.ActualProductSoftNoise
open Nightfall.Observability.ActualProductSoftStar
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualSourceConditionalProjection

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- Exact Boolean-mask probability that every source coordinate in S
is retained: an algebraic product calculation, valid even for
unrestricted REAL retain factors (positivity is not needed here). -/
theorem original_mask_subset_weight
    (retain : ι → ℝ) (S : Finset ι) :
    (∑ mask : ι → Bool, maskWeight retain mask *
      (if S ⊆ maskSites mask then (1 : ℝ) else 0)) =
    ∏ i : ι, if i ∈ S then retain i else 1 := by
  classical
  let q : ι → Bool → ℝ := fun i b =>
    (if b then retain i else (1 - retain i)) *
      (if i ∈ S then (if b then (1 : ℝ) else 0) else 1)
  have hindicator (mask : ι → Bool) :
      (if S ⊆ maskSites mask then (1 : ℝ) else 0) =
        ∏ i : ι, if i ∈ S then (if mask i then (1 : ℝ) else 0) else 1 := by
    by_cases hS : S ⊆ maskSites mask
    · rw [if_pos hS]
      symm
      apply Finset.prod_eq_one
      intro i _
      by_cases hi : i ∈ S
      · have him : mask i = true :=
          (Finset.mem_filter.mp (hS hi)).2
        simp [hi, him]
      · simp [hi]
    · rw [if_neg hS]
      have hmiss : ∃ i, i ∈ S ∧ i ∉ maskSites mask := by
        by_contra hn
        push_neg at hn
        exact hS (fun i hi => hn i hi)
      obtain ⟨i, hi, hnot⟩ := hmiss
      have hfalse : mask i = false := by
        cases h : mask i with
        | false => rfl
        | true =>
          exfalso
          exact hnot (by simp [maskSites, h])
      symm
      apply Finset.prod_eq_zero (Finset.mem_univ i)
      simp [hi, hfalse]
  have hpoint (mask : ι → Bool) :
      maskWeight retain mask *
          (if S ⊆ maskSites mask then (1 : ℝ) else 0) =
        ∏ i : ι, q i (mask i) := by
    unfold maskWeight
    rw [hindicator mask, ← Finset.prod_mul_distrib]
    rfl
  have hcoord (i : ι) :
      (∑ b : Bool, q i b) =
        if i ∈ S then retain i else 1 := by
    by_cases hi : i ∈ S
    · simp [q, hi, Fintype.sum_bool]
    · simp [q, hi, Fintype.sum_bool]
  calc
    (∑ mask : ι → Bool, maskWeight retain mask *
      (if S ⊆ maskSites mask then (1 : ℝ) else 0)) =
        ∑ mask : ι → Bool, ∏ i : ι, q i (mask i) := by
          apply Finset.sum_congr rfl
          intro mask _
          exact hpoint mask
    _ = ∏ i : ι, ∑ b : Bool, q i b := by
          rw [← Fintype.prod_sum]
    _ = ∏ i : ι, if i ∈ S then retain i else 1 := by
          apply Finset.prod_congr rfl
          intro i _
          exact hcoord i

/-- Exact source-preserving eigenaction on one genuine ES component. -/
theorem original_soft_noise_es_component_eigen
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ) (retain : ι → ℝ)
    (S : Finset ι) (x : ι → α) :
    softSourceNoise p retain (esComp p S f) x =
      (∏ i : ι, if i ∈ S then retain i else 1) *
        esComp p S f x := by
  classical
  have hcond (mask : ι → Bool) :
      sourceConditional p (maskSites mask) (esComp p S f) x =
        if S ⊆ maskSites mask then esComp p S f x else 0 := by
    rw [← canonical_condExp_eq_sourceConditional p
      (maskSites mask) (esComp p S f) x]
    exact condExp_esComp_eq_ite p hp1 f (maskSites mask) S x
  calc
    softSourceNoise p retain (esComp p S f) x =
      ∑ mask : ι → Bool, maskWeight retain mask *
        (if S ⊆ maskSites mask then esComp p S f x else 0) := by
          unfold softSourceNoise sourceConditionalMixture
          simp only [smul_eq_mul]
          apply Finset.sum_congr rfl
          intro mask _
          rw [hcond mask]
    _ = (∑ mask : ι → Bool, maskWeight retain mask *
          (if S ⊆ maskSites mask then (1 : ℝ) else 0)) *
          esComp p S f x := by
            rw [Finset.sum_mul]
            apply Finset.sum_congr rfl
            intro mask _
            by_cases h : S ⊆ maskSites mask <;> simp [h]
    _ = (∏ i : ι, if i ∈ S then retain i else 1) *
          esComp p S f x := by
            rw [original_mask_subset_weight retain S]

/-- Exact spectral expansion for the ORIGINAL bounded function f;
all ES components and expectations are derived from the same law p. -/
theorem original_soft_noise_es_expansion
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ) (retain : ι → ℝ)
    (x : ι → α) :
    softSourceNoise p retain f x =
      ∑ S : Finset ι,
        (∏ i : ι, if i ∈ S then retain i else 1) *
          esComp p S f x := by
  classical
  have hsum (z : ι → α) :
      f z = ∑ S : Finset ι, esComp p S f z :=
    (es_decomp p hp1 f z).symm
  calc
    softSourceNoise p retain f x =
      softSourceNoise p retain
        (fun z => ∑ S : Finset ι, esComp p S f z) x := by
          congr 1
          funext z
          exact hsum z
    _ = ∑ S : Finset ι,
          softSourceNoise p retain (esComp p S f) x := by
            exact actual_soft_noise_sum p retain
              (fun S : Finset ι => esComp p S f) x
    _ = ∑ S : Finset ι,
          (∏ i : ι, if i ∈ S then retain i else 1) *
            esComp p S f x := by
              apply Finset.sum_congr rfl
              intro S _
              exact original_soft_noise_es_component_eigen
                p hp1 f retain S x

end Nightfall.Observability.ActualSourceNoiseEfronStein

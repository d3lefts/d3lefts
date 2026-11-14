import ActualProductHilbertJensen

/-!
# Genuine-source soft coordinate refresh: certified Markov L¹ bridge

This is the source-law/noise-contraction operator used by the
author-analytic Q2 soft-ownership route. It is *not* a proof of the
variance-squared influence theorem: it does not identify an individual
canonical Efron–Stein pair kernel with its weighted image, discharge the
matching cover, or compose the fourth-moment endpoint.

The source state and the independently refreshed state both carry the
SAME actual finite product law. Every mixture coefficient is derived
from the explicit coordinate retention rates; no synthetic neighbor
independence is assumed. Supports with zero probability are allowed.
Lean pin: leanprover/lean4:v4.36.0-rc2 with the repository's pinned Mathlib.
-/

namespace Nightfall.Observability.ActualProductSoftNoise

open Finset
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.ActualProductHilbertJensen

variable {ι α : Type*} [Fintype ι] [DecidableEq ι] [Fintype α]

/-- Original-law conditional refresh on a supplied finite set of
retained coordinates; all other coordinates are resampled from p. -/
noncomputable def sourceConditional
    {H : Type*} [AddCommMonoid H] [Module ℝ H]
    (p : ι → α → ℝ) (S : Finset ι)
    (G : (ι → α) → H) (x : ι → α) : H :=
  ∑ y : ι → α, (originalMass p y) • G (keepSource S x y)

/-- A mixture of true original-law conditional refresh operations. -/
noncomputable def sourceConditionalMixture
    {H β : Type*} [AddCommMonoid H] [Module ℝ H] [Fintype β]
    (p : ι → α → ℝ) (q : β → ℝ) (S : β → Finset ι)
    (G : (ι → α) → H) (x : ι → α) : H :=
  ∑ b : β, (q b) • sourceConditional p (S b) G x

/-- A genuine source-mixture of conditional-product operators cannot
increase its original-product expected norm. This controls source
Markov noise on vector-valued *actual source* sections.

Crucially, the mixing weights are nonnegative and normalized; without
either assumption this inference would be invalid. -/
theorem actual_source_conditional_mixture_L1
    {H β : Type*} [NormedAddCommGroup H] [NormedSpace ℝ H]
    [Fintype β]
    (p : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (q : β → ℝ) (hq : ∀ b, 0 ≤ q b)
    (hq1 : (∑ b : β, q b) = 1)
    (S : β → Finset ι) (G : (ι → α) → H) :
    (∑ x : ι → α, originalMass p x *
      ‖sourceConditionalMixture p q S G x‖) ≤
    ∑ x : ι → α, originalMass p x * ‖G x‖ := by
  classical
  have hm (x : ι → α) : 0 ≤ originalMass p x := by
    unfold originalMass
    exact Finset.prod_nonneg (fun i _ => hp i (x i))
  have hpoint (x : ι → α) :
      ‖sourceConditionalMixture p q S G x‖ ≤
      ∑ b : β, q b * ‖sourceConditional p (S b) G x‖ := by
    unfold sourceConditionalMixture
    calc
      ‖∑ b : β, (q b) • sourceConditional p (S b) G x‖ ≤
        ∑ b : β, ‖(q b) • sourceConditional p (S b) G x‖ :=
        norm_sum_le _ _
      _ = ∑ b : β, q b * ‖sourceConditional p (S b) G x‖ := by
        apply Finset.sum_congr rfl
        intro b _
        rw [norm_smul, Real.norm_eq_abs, abs_of_nonneg (hq b)]
  have hswap :
      (∑ x : ι → α, originalMass p x *
        (∑ b : β, q b * ‖sourceConditional p (S b) G x‖)) =
      ∑ b : β, q b *
        (∑ x : ι → α, originalMass p x *
          ‖sourceConditional p (S b) G x‖) := by
    calc
      (∑ x : ι → α, originalMass p x *
        (∑ b : β, q b * ‖sourceConditional p (S b) G x‖)) =
        ∑ x : ι → α, ∑ b : β,
          originalMass p x * (q b * ‖sourceConditional p (S b) G x‖) := by
          apply Finset.sum_congr rfl
          intro x _
          rw [Finset.mul_sum]
      _ = ∑ b : β, ∑ x : ι → α,
        originalMass p x * (q b * ‖sourceConditional p (S b) G x‖) :=
          Finset.sum_comm
      _ = ∑ b : β, q b *
        (∑ x : ι → α, originalMass p x *
          ‖sourceConditional p (S b) G x‖) := by
          apply Finset.sum_congr rfl
          intro b _
          rw [Finset.mul_sum]
          apply Finset.sum_congr rfl
          intro x _
          ring
  have hcomponent (b : β) :
      (∑ x : ι → α, originalMass p x *
        ‖sourceConditional p (S b) G x‖) ≤
      ∑ x : ι → α, originalMass p x * ‖G x‖ := by
    simpa only [sourceConditional] using
      (integrated_source_hilbert_jensen p hp hp1 (S b) G)
  calc
    (∑ x : ι → α, originalMass p x *
      ‖sourceConditionalMixture p q S G x‖) ≤
      (∑ x : ι → α, originalMass p x *
        (∑ b : β, q b * ‖sourceConditional p (S b) G x‖)) := by
        apply Finset.sum_le_sum
        intro x _
        exact mul_le_mul_of_nonneg_left (hpoint x) (hm x)
    _ = ∑ b : β, q b *
        (∑ x : ι → α, originalMass p x *
          ‖sourceConditional p (S b) G x‖) := hswap
    _ ≤ ∑ b : β, q b *
        (∑ x : ι → α, originalMass p x * ‖G x‖) := by
        apply Finset.sum_le_sum
        intro b _
        exact mul_le_mul_of_nonneg_left (hcomponent b) (hq b)
    _ = ∑ x : ι → α, originalMass p x * ‖G x‖ := by
        rw [← Finset.sum_mul, hq1, one_mul]

/-- A retention mask draws each original coordinate independently:
true means keep the original coordinate, false means refresh it. -/
noncomputable def maskWeight (λ : ι → ℝ) (mask : ι → Bool) : ℝ :=
  ∏ i : ι, if mask i then λ i else (1 - λ i)

/-- Original coordinates retained by a Boolean mask. -/
noncomputable def maskSites (mask : ι → Bool) : Finset ι :=
  Finset.univ.filter (fun i => mask i = true)

/-- Retention probabilities give nonnegative mask probabilities,
including deterministic retention, full refresh and zero atoms. -/
theorem maskWeight_nonneg
    (λ : ι → ℝ) (hl : ∀ i, 0 ≤ λ i)
    (hu : ∀ i, λ i ≤ 1) (mask : ι → Bool) :
    0 ≤ maskWeight λ mask := by
  unfold maskWeight
  apply Finset.prod_nonneg
  intro i _
  cases h : mask i
  · simpa [h] using (sub_nonneg.mpr (hu i))
  · simpa [h] using (hl i)

/-- Exact normalization, not an assumed mask-sampling oracle. -/
theorem maskWeight_total_one (λ : ι → ℝ) :
    (∑ mask : ι → Bool, maskWeight λ mask) = 1 := by
  classical
  unfold maskWeight
  rw [← Fintype.prod_sum]
  simp [Fintype.sum_bool, sub_add_cancel]

/-- The soft source-noise operator (coordinatewise stay-or-refresh)
is a genuine mixture of actual product-law conditionals. -/
noncomputable def softSourceNoise
    {H : Type*} [AddCommMonoid H] [Module ℝ H]
    (p : ι → α → ℝ) (λ : ι → ℝ)
    (G : (ι → α) → H) (x : ι → α) : H :=
  sourceConditionalMixture p (maskWeight λ) maskSites G x

/-- The soft operator is an actual-source L¹ norm contraction.
This is the key no-synthetic-neighbor operator step of the proposed
Q2 soft-ownership route, **not** its whole variance/influence theorem. -/
theorem actual_soft_source_noise_L1
    {H : Type*} [NormedAddCommGroup H] [NormedSpace ℝ H]
    (p : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (λ : ι → ℝ)
    (hl : ∀ i, 0 ≤ λ i)
    (hu : ∀ i, λ i ≤ 1)
    (G : (ι → α) → H) :
    (∑ x : ι → α, originalMass p x *
      ‖softSourceNoise p λ G x‖) ≤
    ∑ x : ι → α, originalMass p x * ‖G x‖ := by
  exact actual_source_conditional_mixture_L1
    p hp hp1 (maskWeight λ)
    (maskWeight_nonneg λ hl hu)
    (maskWeight_total_one λ)
    maskSites G

end Nightfall.Observability.ActualProductSoftNoise

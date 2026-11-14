import ActualSourceQ2SharpAdditive

/-!
# Q2 sharp additive budget: genuine source-noise polynomial and range

This module proves or attempts the intermediary source-preserving
L-infinity mechanism, not the terminal theorem. No auxiliary
noise-eigenaction, arbitrary polynomial, or synthetic probability
distribution is introduced as an assumption.
-/

namespace Nightfall.Observability.ActualSourceQ2SharpAdditiveSource

open Finset
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.ActualProductSoftNoise
open Nightfall.Observability.ActualProductSourceDerivedStar
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualSourceNoiseEfronStein
open Nightfall.Observability.ActualSourceQ2SharpAdditive
open Nightfall.Observability.ActualSourceSingletonEnergyBridge

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

/-- A normalized finite convex average of values in [-B,B] stays in
[-B,B]. Its weights can vanish. -/
theorem finite_weighted_abs_bound
    {β : Type} [Fintype β]
    (μ : β → ℝ) (hμ : ∀ b, 0 ≤ μ b)
    (hμ1 : (∑ b : β, μ b) = 1)
    (g : β → ℝ) (B : ℝ)
    (hg : ∀ b, |g b| ≤ B) :
    |∑ b : β, μ b * g b| ≤ B := by
  classical
  have hlo :
      (∑ b : β, μ b * (-B)) ≤ ∑ b : β, μ b * g b := by
    apply Finset.sum_le_sum
    intro b _
    exact mul_le_mul_of_nonneg_left (abs_le.mp (hg b)).1 (hμ b)
  have hhi :
      (∑ b : β, μ b * g b) ≤ ∑ b : β, μ b * B := by
    apply Finset.sum_le_sum
    intro b _
    exact mul_le_mul_of_nonneg_left (abs_le.mp (hg b)).2 (hμ b)
  have hlo_eq : (∑ b : β, μ b * (-B)) = -B := by
    rw [← Finset.sum_mul, hμ1, one_mul]
  have hhi_eq : (∑ b : β, μ b * B) = B := by
    rw [← Finset.sum_mul, hμ1, one_mul]
  exact abs_le.mpr ⟨by simpa only [hlo_eq] using hlo,
                    by simpa only [hhi_eq] using hhi⟩

/-- Source-preserving coordinatewise soft refresh is pointwise
L-infinity contractive, not merely averaged L1 contractive. -/
theorem original_uniform_source_noise_bounded
    (p : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (B : ℝ) (hf : ∀ x, |f x| ≤ B)
    (t : ℝ) (ht0 : 0 ≤ t) (ht1 : t ≤ 1)
    (x : ι → α) :
    |softSourceNoise p (fun _ => t) f x| ≤ B := by
  classical
  let retain : ι → ℝ := fun _ => t
  have hm (y : ι → α) : 0 ≤ originalMass p y := by
    unfold originalMass
    exact Finset.prod_nonneg (fun i _ => hp i (y i))
  have hcond (S : Finset ι) (z : ι → α) :
      |sourceConditional p S f z| ≤ B := by
    have h := finite_weighted_abs_bound (originalMass p) hm
      (sum_originalMass' p hp1)
      (fun y : ι → α => f (keepSource S z y)) B
      (fun y => hf (keepSource S z y))
    simpa only [sourceConditional, smul_eq_mul] using h
  have hret0 : ∀ i, 0 ≤ retain i := fun _ => ht0
  have hret1 : ∀ i, retain i ≤ 1 := fun _ => ht1
  have h := finite_weighted_abs_bound
    (maskWeight retain) (maskWeight_nonneg retain hret0 hret1)
    (maskWeight_total_one retain)
    (fun mask : ι → Bool =>
      sourceConditional p (maskSites mask) f x) B
    (fun mask => hcond (maskSites mask) x)
  change |∑ mask : ι → Bool, maskWeight retain mask *
    sourceConditional p (maskSites mask) f x| ≤ B
  exact h

/-- Genuine original-law Hoeffding layer of degree one, as an actual
finite sum over singleton canonical supports. -/
noncomputable def originalFirstSector
    (p : ι → α → ℝ) (f : (ι → α) → ℝ) (x : ι → α) : ℝ :=
  ∑ S : Finset ι, if S.card = 1 then esComp p S f x else 0

noncomputable def originalSecondSector
    (p : ι → α → ℝ) (f : (ι → α) → ℝ) (x : ι → α) : ℝ :=
  ∑ S : Finset ι, if S.card = 2 then esComp p S f x else 0

/-- True original-source degree-two polynomial under homogeneous
source refresh, with no pre-imposed spectral decomposition. -/
theorem original_degree_two_uniform_noise_polynomial
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (t : ℝ) (x : ι → α) :
    softSourceNoise p (fun _ => t) f x =
      esComp p ∅ f x + t * originalFirstSector p f x +
        t^2 * originalSecondSector p f x := by
  classical
  have hzero :
      (∑ S : Finset ι, if S.card = 0 then esComp p S f x else 0) =
        esComp p ∅ f x := by
    apply Finset.sum_eq_single (∅ : Finset ι)
    · intro S _ hS
      have hne : S.card ≠ 0 := by
        intro h
        exact hS (Finset.card_eq_zero.mp h)
      simp [hne]
    · intro h
      exact (h (Finset.mem_univ _)).elim
  have hterm (S : Finset ι) :
      t^S.card * esComp p S f x =
        (if S.card = 0 then esComp p S f x else 0) +
        t * (if S.card = 1 then esComp p S f x else 0) +
        t^2 * (if S.card = 2 then esComp p S f x else 0) := by
    by_cases h0 : S.card = 0
    · simp [h0]
    by_cases h1 : S.card = 1
    · simp [h0, h1]
    by_cases h2 : S.card = 2
    · simp [h0, h1, h2]
    have hgt : 2 < S.card := by omega
    have hz := hdegree S hgt x
    simp [h0, h1, h2, hz]
  calc
    softSourceNoise p (fun _ => t) f x =
        ∑ S : Finset ι,
          (∏ i : ι, if i ∈ S then t else 1) *
            esComp p S f x := by
          exact original_soft_noise_es_expansion p hp1 f (fun _ => t) x
    _ = ∑ S : Finset ι, t^S.card * esComp p S f x := by
          apply Finset.sum_congr rfl
          intro S _
          rw [original_uniform_mask_weight t S]
    _ = ∑ S : Finset ι,
          ((if S.card = 0 then esComp p S f x else 0) +
           t * (if S.card = 1 then esComp p S f x else 0) +
           t^2 * (if S.card = 2 then esComp p S f x else 0)) := by
          apply Finset.sum_congr rfl
          intro S _
          exact hterm S
    _ = esComp p ∅ f x + t * originalFirstSector p f x +
          t^2 * originalSecondSector p f x := by
          simp only [Finset.sum_add_distrib, ← Finset.mul_sum,
            originalFirstSector, originalSecondSector]
          rw [hzero]

/-- The first-degree source layer equals the genuine coordinatewise
singleton sum, including on zero-atom source words. -/
theorem original_first_sector_eq_singleton_sum
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (x : ι → α) :
    originalFirstSector p f x =
      ∑ i : ι, sourceCenteredSingleton p f i (x i) := by
  classical
  have hset :
      (Finset.univ.filter (fun S : Finset ι => S.card = 1)) =
        (Finset.univ.image (fun i : ι => ({i} : Finset ι))) := by
    ext S
    simp only [Finset.mem_filter, Finset.mem_univ, true_and,
      Finset.mem_image]
    constructor
    · intro h
      obtain ⟨i, hi⟩ := Finset.card_eq_one.mp h
      exact ⟨i, hi.symm⟩
    · rintro ⟨i, h⟩
      rw [← h]
      simp
  calc
    originalFirstSector p f x =
        (Finset.univ.filter (fun S : Finset ι => S.card = 1)).sum
          (fun S => esComp p S f x) := by
            unfold originalFirstSector
            rw [Finset.sum_filter]
    _ = (Finset.univ.image (fun i : ι => ({i} : Finset ι))).sum
          (fun S => esComp p S f x) := by rw [hset]
    _ = ∑ i : ι, esComp p ({i} : Finset ι) f x := by
          exact Finset.sum_image
            (s := (Finset.univ : Finset ι))
            (f := fun S : Finset ι => esComp p S f x)
            (g := fun i : ι => ({i} : Finset ι))
            (fun i _ j _ hij => by
              have hh : i ∈ ({j} : Finset ι) := by
                change ({i} : Finset ι) = {j} at hij
                rw [← hij]
                simp
              simpa using hh)
    _ = ∑ i : ι, sourceCenteredSingleton p f i (x i) := by
          apply Finset.sum_congr rfl
          intro i _
          have h := source_es_singleton_at_original_coordinate
            p hp1 f hdegree i x
          simpa using h

end Nightfall.Observability.ActualSourceQ2SharpAdditiveSource

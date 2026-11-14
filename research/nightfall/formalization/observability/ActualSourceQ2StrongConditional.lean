import ActualSourceQ2Terminal
import ActualProductQ2ScalarClosure

/-!
# Stronger Q2 coefficient, explicit remaining source-budget gate

This is a CONDITIONAL strengthening of the strictly certified finite Q2
theorem, not a source-only certification of the 1228.356 coefficient.
The only remaining extra hypothesis is the original-source sharp additive
budget sum_i A_i <= 2(1+sqrt 2) B, defined using p and f themselves.

The 8B original-source section bound, 8B greedy source matching cost,
source owner moment/fourth endpoint and variance partition are compiled
upstream from the SAME source p,f, with no supplied component budgets.

Current scope: finite coordinates, one finite alphabet type, heterogeneous
marginal laws and zero masses allowed, pointwise bounded degree <= 2.
No claim of independent human proof review or historical novelty.
-/

namespace Nightfall.Observability.ActualSourceQ2StrongConditional

open Finset
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualSourceVarianceEnergy
open Nightfall.Observability.ActualSourceInfluenceEnergy
open Nightfall.Observability.ActualSourceOwnedGraph
open Nightfall.Observability.ActualSourceFinitePairMoment
open Nightfall.Observability.ActualSourceMeanSectionJensen
open Nightfall.Observability.ActualSourceIntegratedSections
open Nightfall.Observability.ActualSourceOwnedFirstMomentCap
open Nightfall.Observability.ActualSourceSingletonEnergyBridge
open Nightfall.Observability.ActualSourceOwnedFourthClosure
open Nightfall.Observability.ActualSourceQ2WeakScalarClosure
open Nightfall.Observability.ActualSourceQ2CompositionGate
open Nightfall.Observability.ActualProductQ2ScalarClosure
open Nightfall.Observability.QuadraticHilbertMany
open Nightfall.Observability.QuadraticHilbertMoments

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

theorem actual_source_q2_strong_given_additive_budget
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (B : ℝ) (hB : 0 ≤ B)
    (hf : ∀ x, |f x| ≤ B)
    (hadditive : (∑ i : ι, originalSingletonNorm p f i) ≤
      (2 * (1 + Real.sqrt 2)) * B) :
    ∀ M : ℝ, 0 ≤ M →
      (∀ i, sourceInfluence p f i ≤ M) →
      (sourceVariance p f)^2 ≤
        ((10 + 2 * Real.sqrt 2) * (1 + Real.sqrt 3))^2 * B^2 * M := by
  classical
  intro M hM0 hM
  let T : ℝ := Real.sqrt M
  have hT : 0 ≤ T := Real.sqrt_nonneg M
  have hT2 : T^2 = M := Real.sq_sqrt hM0
  have hV : 0 ≤ sourceVariance p f := by
    unfold sourceVariance
    apply Finset.sum_nonneg
    intro x _
    have hm : 0 ≤ originalMass p x := by
      unfold originalMass
      exact Finset.prod_nonneg (fun k _ => hp k (x k))
    exact mul_nonneg hm (sq_nonneg _)
  obtain ⟨c, hc, hcover, howner, hsumz⟩ :=
    original_source_generated_fourth_and_jensen_package
      p hp hp1 f hdegree B hB hf M hM
  let a : ι → ℝ := fun i => originalSingletonNorm p f i
  let u : ι → ℝ := fun i => sourceMeanSectionNorm p f i
  let s : ι → ℝ := fun i =>
    let J := ownedNeighbors c i
    let j := neighborIndex i J
    moment2 (fun k => p (j k))
      (finitePairIncrement p f i j J.card) J.card
  let z : ι → ℝ := fun i =>
    let J := ownedNeighbors c i
    let j := neighborIndex i J
    let Y := finitePairIncrement p f i j J.card
    ∑ w : Samples α J.card,
      mass (fun k => p (j k)) J.card w *
        Real.sqrt (vecNormSq (sumVector Y J.card w))
  have ha : ∀ i, 0 ≤ a i := by
    intro i
    exact Real.sqrt_nonneg _
  have hz : ∀ i, 0 ≤ z i := by
    intro i
    dsimp [z]
    apply Finset.sum_nonneg
    intro w _
    exact mul_nonneg
      (mass_nonneg
        (fun k => p (neighborIndex i (ownedNeighbors c i) k))
        (fun k b => hp (neighborIndex i (ownedNeighbors c i) k) b)
        (ownedNeighbors c i).card w)
      (Real.sqrt_nonneg _)
  have haT : ∀ i, a i ≤ T := by
    intro i
    exact original_singleton_norm_le_sqrt_influence_cap
      p hp hp1 f hdegree i M hM0 (hM i)
  have hzT : ∀ i, z i ≤ T := by
    intro i
    exact original_owned_first_norm_le_sqrt_source_influence
      p hp hp1 f c i M hM0 (hM i)
  have hJensen : ∀ i, a i ≤ u i := by
    intro i
    exact original_singleton_norm_le_source_mean_section_norm p hp f i
  have hnoise : ∀ i, z i ≤ u i + a i := by
    intro i
    exact (howner i).2.2
  have hsection : (∑ i : ι, u i) ≤ 8 * B :=
    actual_source_integrated_eight_budget
      p hp hp1 f hdegree B hB hf
  have hmoment : ∀ i, s i ≤ z i * (c i + Real.sqrt 3 * T) := by
    intro i
    have h := (howner i).2.1
    have hroot : Real.sqrt (3 * M) = Real.sqrt 3 * T := by
      dsimp [T]
      exact Real.sqrt_mul (by norm_num : (0:ℝ) ≤ 3) M
    dsimp [s, z]
    rw [hroot] at h
    exact h
  have hvariance :
      sourceVariance p f = (∑ i : ι, (a i)^2) + ∑ i : ι, s i := by
    simpa only [a, s] using
      original_source_variance_eq_singleton_plus_owned_moment2
        p hp hp1 f hdegree c
  have hρ : 0 ≤ Real.sqrt (3:ℝ) := Real.sqrt_nonneg 3
  have ha_total : (∑ i : ι, a i) ≤
      (2 * (1 + Real.sqrt 2)) * B := by
    simpa only [a] using hadditive
  have hz_total : (∑ i : ι, z i) ≤
      (8 + 2 * (1 + Real.sqrt 2)) * B := by
    have hsum : (∑ i : ι, z i) ≤
        (∑ i : ι, u i) + (∑ i : ι, a i) := by
      calc
        (∑ i : ι, z i) ≤ ∑ i : ι, (u i + a i) :=
          Finset.sum_le_sum (fun i _ => hnoise i)
        _ = (∑ i : ι, u i) + (∑ i : ι, a i) :=
          Finset.sum_add_distrib
    nlinarith [hsection, ha_total]
  have hα : 0 ≤ (2 * (1 + Real.sqrt 2) : ℝ) := by positivity
  have hnum := q2_scalar_endpoint_squared
    a c z s B T M (2 * (1 + Real.sqrt 2)) (Real.sqrt 3)
    (sourceVariance p f)
    hB hT hV hα hρ ha hc hz haT hzT hmoment
    ha_total hcover hz_total hvariance hT2
  have hcoef :
      (8 + 2 * (1 + Real.sqrt 2)) * (1 + Real.sqrt 3) =
      (10 + 2 * Real.sqrt 2) * (1 + Real.sqrt 3) := by ring
  rw [hcoef] at hnum
  exact hnum

end Nightfall.Observability.ActualSourceQ2StrongConditional


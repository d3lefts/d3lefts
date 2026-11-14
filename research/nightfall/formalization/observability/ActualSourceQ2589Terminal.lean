import ActualSourceQ2625Cubic
import ActualSourceQ2CoupledTerminalGate
import ActualSourceQ2SharpAdditiveFinal
import ActualSourceQ2EnergyDualSource
import Q2589ScalarSite

/-!
# Source-only Q2 589.97569 endpoint: cubic fourth-moment and joint original energy cap

This file targets the genuine finite product p,f with no artificial
budget or moment hypotheses in the unconditional terminal declaration.
-/

namespace Nightfall.Observability.ActualSourceQ2589Terminal

open Finset
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualESGreedyOwnership
open Nightfall.Observability.ActualProductSourcePairCentering
open Nightfall.Observability.ActualSourceOwnedProjectedMomentJensen
open Nightfall.Observability.ActualSourceVarianceEnergy
open Nightfall.Observability.ActualSourceInfluenceEnergy
open Nightfall.Observability.ActualSourceOwnedGraph
open Nightfall.Observability.ActualSourceOwnedFourthClosure
open Nightfall.Observability.ActualSourceOwnedMomentEnergy
open Nightfall.Observability.ActualSourceFinitePairMoment
open Nightfall.Observability.ActualSourceMeanSectionJensen
open Nightfall.Observability.ActualSourceIntegratedSections
open Nightfall.Observability.ActualSourceOwnedFirstMomentCap
open Nightfall.Observability.ActualSourceSingletonEnergyBridge
open Nightfall.Observability.ActualSourceQ2SharpAdditiveFinal
open Nightfall.Observability.ActualSourceQ2625Cubic
open Nightfall.Q2625Golden
open Nightfall.Q2625GoldenTrade
open Nightfall.Q2589ScalarSite
open Nightfall.Observability.ActualSourceQ2EnergyDualSource
open Nightfall.Q2625ScalarEnvelope
open Nightfall.Observability.QuadraticHilbertMany
open Nightfall.Observability.QuadraticHilbertMoments

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

theorem original_source_generated_cubic_jensen_package
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (B : ℝ) (hf : ∀ x, |f x| ≤ B) :
    ∃ c : ι → ℝ,
      (∀ i, 0 ≤ c i) ∧
      (∑ i : ι, c i) ≤ 8*B ∧
      (∀ i : ι,
        let J := ownedNeighbors c i
        let j := neighborIndex i J
        let Y := finitePairIncrement p f i j J.card
        let s := moment2 (fun k => p (j k)) Y J.card
        let z := ∑ w : Samples α J.card,
          mass (fun k => p (j k)) J.card w *
            Real.sqrt (vecNormSq (sumVector Y J.card w))
        (s ≤ sourceInfluence p f i) ∧
        (z ≤ sourceMeanSectionNorm p f i +
          originalSingletonNorm p f i) ∧
        (s^3 ≤ z^2*((c i)^2*s+3*s^2))) := by
  classical
  let base : ι → α := fun _ => Classical.choice (inferInstance : Nonempty α)
  obtain ⟨c, hc, hcost, hcover, _, _, _, _⟩ :=
    actual_source_greedy_graph_hilbert_package
      p hp hp1 f hdegree base B hf
  refine ⟨c, hc, hcost, ?_⟩
  intro i
  have hsource :=
    actual_owned_moment_and_projected_jensen
      p hp hp1 f hdegree c i
  exact ⟨hsource.1, hsource.2,
    actual_source_owned_cubic p hp hp1 f c hc hcover i⟩

private noncomputable def K : ℝ :=
  8*Real.sqrt 3 + 2*(1+Real.sqrt 2)*(Real.sqrt 13-Real.sqrt 3) + 8*gamma

theorem actual_source_q2_589_given_additive_budget
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (B : ℝ) (hB : 0 ≤ B)
    (hf : ∀ x, |f x| ≤ B)
    (hadditive : (∑ i : ι, originalSingletonNorm p f i) ≤
      (2*(1+Real.sqrt 2))*B) :
    ∀ M : ℝ, 0 ≤ M →
      (∀ i : ι, sourceInfluence p f i ≤ M) →
      (sourceVariance p f)^2 ≤ K^2 * B^2 * M := by
  classical
  intro M hM0 hM
  let T : ℝ := Real.sqrt M
  have hT : 0 ≤ T := Real.sqrt_nonneg _
  have hT2 : T^2 = M := Real.sq_sqrt hM0
  have hV : 0 ≤ sourceVariance p f := by
    unfold sourceVariance
    apply Finset.sum_nonneg
    intro x _
    have hm : 0 ≤ originalMass p x := by
      unfold originalMass
      exact Finset.prod_nonneg (fun k _ => hp k (x k))
    exact mul_nonneg hm (sq_nonneg _)
  obtain ⟨c, hc, hcover, howner⟩ :=
    original_source_generated_cubic_jensen_package
      p hp hp1 f hdegree B hf
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
  have ha : ∀ i, 0 ≤ a i := fun i => Real.sqrt_nonneg _
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
  have hJensen : ∀ i, a i ≤ u i := by
    intro i
    exact original_singleton_norm_le_source_mean_section_norm p hp f i
  have hnoise : ∀ i, z i ≤ u i + a i := by
    intro i
    exact (howner i).2.1
  have hsection : (∑ i : ι, u i) ≤ 8*B :=
    actual_source_integrated_eight_budget p hp hp1 f hdegree B hB hf
  have hvariance :
      sourceVariance p f = (∑ i : ι, (a i)^2) + ∑ i : ι, s i := by
    simpa only [a, s] using
      original_source_variance_eq_singleton_plus_owned_moment2
        p hp hp1 f hdegree c
  have hsite : ∀ i, (a i)^2 + s i ≤ T *
      (Real.sqrt 3 * u i + (Real.sqrt 13-Real.sqrt 3)*a i + gamma*c i) := by
    intro i
    have hsource : (a i)^2 + s i ≤ sourceInfluence p f i := by
      simpa only [a, s] using
        (original_singleton_plus_owned_energy_le_influence
          p hp hp1 f hdegree c i)
    have hjoint : (a i)^2 + s i ≤ T^2 := by
      rw [hT2]
      exact hsource.trans (hM i)
    have hscubic : (s i)^3 ≤ (z i)^2 *
        ((c i)^2*(s i)+3*(s i)^2) := by
      exact (howner i).2.2
    have hsnonneg : 0 ≤ s i := by
      dsimp [s, moment2]
      apply Finset.sum_nonneg
      intro w _
      exact mul_nonneg
        (mass_nonneg
          (fun k => p (neighborIndex i (ownedNeighbors c i) k))
          (fun k b => hp (neighborIndex i (ownedNeighbors c i) k) b)
          (ownedNeighbors c i).card w)
        (vecNormSq_nonneg _)
    exact joint_energy_cubic_site_589
      (a i) (u i) (z i) (s i) (c i) T
      hT (ha i) hsnonneg (hz i) (hc i)
      (hJensen i) (hnoise i) hjoint hscubic
  have hfinal := sitewise_budget_to_variance_squared
    a u c s B T M (sourceVariance p f)
      (Real.sqrt 3) (Real.sqrt 13-Real.sqrt 3) gamma
      hB hT hV (by positivity)
      (by exact sub_nonneg.mpr (Real.sqrt_le_sqrt (by norm_num : (3:ℝ) ≤ 13)))
      gamma_nonneg
      hsite hsection (by simpa [a] using hadditive)
      hcover hvariance hT2
  simpa only [K, mul_assoc, mul_comm, mul_left_comm] using hfinal

theorem actual_source_q2_589_unconditional
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (B : ℝ) (hB : 0 ≤ B)
    (hf : ∀ x, |f x| ≤ B) :
    ∀ M : ℝ, 0 ≤ M →
      (∀ i : ι, sourceInfluence p f i ≤ M) →
      (sourceVariance p f)^2 ≤ K^2 * B^2 * M := by
  exact actual_source_q2_620_given_additive_budget
    p hp hp1 f hdegree B hB hf
    (original_source_sharp_additive_budget
      p hp hp1 f hdegree B hB hf)

end Nightfall.Observability.ActualSourceQ2620Terminal

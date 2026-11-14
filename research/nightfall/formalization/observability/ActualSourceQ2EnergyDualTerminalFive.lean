import ActualSourceOwnedFirstMomentCap
import ActualSourceQ2EnergyDualScalar
import ActualSourceQ2EnergyDualScalarFive
import ActualSourceIntegratedFive
import ActualSourceQ2EnergyDualSource
import ActualSourceQ2CompositionGate

/-!
# Energy-dual source Q2 endpoint: 736.67319775828688

All quantities come from the same source p,f. The conditional
sharp additive budget is the ONLY extra premise here. The
source-only terminal theorem discharges it using the separately
Lean-certified source noise interpolation.

The improvement uses the strictly stronger source-only joint energy
condition singleton L2 squared plus owned interaction moment <= actual
coordinate influence, and the SOS site inequality. The joint condition
is PROVED from canonical ANOVA in ActualSourceQ2EnergyDualSource.
-/

namespace Nightfall.Observability.ActualSourceQ2EnergyDualTerminalFive

open Finset
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualSourceVarianceEnergy
open Nightfall.Observability.ActualSourceInfluenceEnergy
open Nightfall.Observability.ActualSourceOwnedGraph
open Nightfall.Observability.ActualSourceFinitePairMoment
open Nightfall.Observability.ActualSourceMeanSectionJensen
open Nightfall.Observability.ActualSourceIntegratedSections
open Nightfall.Observability.ActualSourceIntegratedFive
open Nightfall.Observability.ActualSourceQ2EnergyDualScalarFive
open Nightfall.Observability.ActualSourceOwnedFirstMomentCap
open Nightfall.Observability.ActualSourceSingletonEnergyBridge
open Nightfall.Observability.ActualSourceOwnedFourthClosure
open Nightfall.Observability.ActualSourceQ2EnergyDualScalar
open Nightfall.Observability.ActualSourceQ2EnergyDualSource
open Nightfall.Observability.ActualSourceQ2CompositionGate
open Nightfall.Observability.QuadraticHilbertMany
open Nightfall.Observability.QuadraticHilbertMoments

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

theorem actual_source_q2_energy_dual_five_given_additive_budget
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
      (∀ i : ι, sourceInfluence p f i ≤ M) →
      (sourceVariance p f)^2 ≤
        (403/40+(9/4)*Real.sqrt 2+(7/2)*Real.sqrt 3+Real.sqrt 6)^2 *
          B^2 * M := by
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
  have hsection : (∑ i : ι, u i) ≤ 5 * B :=
    actual_source_integrated_five_budget
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
  have hadd : (∑ i : ι, a i) ≤
      (2 * (1 + Real.sqrt 2)) * B := by
    simpa only [a] using hadditive
  have hjoint : ∀ i, (a i)^2+s i ≤ M := by
    intro i
    have h := original_singleton_plus_owned_energy_le_influence
      p hp hp1 f hdegree c i
    have hsite : (a i)^2+s i ≤ sourceInfluence p f i := by
      simpa only [a, s] using h
    exact hsite.trans (hM i)
  exact energy_dual_scalar_endpoint_five
    a u c z s B T M (sourceVariance p f)
    hB hT hV ha hc hJensen hnoise hmoment hjoint
    hsection hadd hcover hvariance hT2

end Nightfall.Observability.ActualSourceQ2EnergyDualTerminalFive

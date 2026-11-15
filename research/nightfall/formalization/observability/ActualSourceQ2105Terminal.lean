import ActualSourceQ2105Local
import ActualSourceIntegratedSharp

/-!
# Fully unrestricted finite Q2: C105.7417 sharp-section shifted owner
Extends the previous actual-source c/3 shifted Hilbert theorem with
original-source Bernoulli t=(sqrt2-1) integrated section budget.
Nonzero singleton components, arbitrary finite heterogeneous laws,
zero-probability atoms and genuine source influences are retained.
No caller-supplied section or Hilbert moment premise.
-/

namespace Nightfall.Observability.ActualSourceQ2105Terminal

open Finset
open Nightfall.Observability.ActualSourceQ2105Local
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualSourceVarianceEnergy
open Nightfall.Observability.ActualSourceInfluenceEnergy
open Nightfall.Observability.ActualSourceMeanSectionJensen
open Nightfall.Observability.ActualSourceIntegratedSections
open Nightfall.Observability.ActualSourceIntegratedFive
open Nightfall.Observability.ActualSourceIntegratedSharp
open Nightfall.Observability.ActualSourceOwnedGraph
open Nightfall.Observability.ActualSourceOwnedFourthClosure
open Nightfall.Observability.ActualSourceOwnedMomentEnergy
open Nightfall.Observability.ActualSourceSingletonEnergyBridge
open Nightfall.Observability.ActualSourceSingletonProjection
open Nightfall.Observability.ActualSourceFinitePairMoment
open Nightfall.Observability.ActualSourceQ2EnergyDualSource
open Nightfall.Observability.ActualSourceQ2SharpAdditiveFinal
open Nightfall.Observability.ShiftedOwnerSourceJensen
open Nightfall.Observability.ShiftedOwnerScalarMoments
open Nightfall.Observability.ShiftedOwnerScalar
open Nightfall.Observability.ShiftedHilbertManyIncrement
open Nightfall.Observability.QuadraticHilbertMany
open Nightfall.Observability.QuadraticHilbertMoments
open Nightfall.Observability.QuadraticActualMomentEndpoint

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

/-- Unrestricted-source finite Q2 bound with no caller-supplied source,
owner, moment, or section premises. Requires exact-head Lean gate. -/
theorem actual_source_q2_105_unconditional
    (p : ι → α → ℝ)
    (hp : ∀ k b, 0 ≤ p k b)
    (hp1 : ∀ k, (∑ b : α, p k b) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (B : ℝ) (hB : 0 ≤ B)
    (hf : ∀ x, |f x| ≤ B) :
    ∀ M : ℝ, 0 ≤ M →
       (∀ i, sourceInfluence p f i ≤ M) →
       (sourceVariance p f)^2 ≤
         ((2*(1+Real.sqrt 2))*Real.sqrt 3+48/25)^2*B^2*M := by
  classical
  intro M hM0 hM
  let T : ℝ := Real.sqrt M
  have hT : 0 ≤ T := Real.sqrt_nonneg _
  have hT2 : T^2 = M := Real.sq_sqrt hM0
  let base : ι → α := fun _ => Classical.choice (inferInstance : Nonempty α)
  obtain ⟨c,hc,hcost,hcover,_,_,_,_⟩ :=
    actual_source_greedy_graph_hilbert_package
      p hp hp1 f hdegree base B hf
  let e : ι → ℝ := fun i =>
    (originalSingletonNorm p f i)^2+
      (let J := ownedNeighbors c i
       let j := neighborIndex i J
       moment2 (fun k => p (j k))
         (finitePairIncrement p f i j J.card) J.card)
  let u : ι → ℝ := fun i => shiftedOwnedFirstNorm p f c i
  have hsite : ∀ i, e i ≤
      T*(Real.sqrt 3*u i+(6*c i)/25) := by
    intro i
    obtain ⟨hcap,hloc⟩ := actual_source_shifted_site_105
      p hp hp1 f hdegree c hc hcover i
    have hroot := Real.sqrt_le_sqrt (hM i)
    have hfactor : 0 ≤ Real.sqrt 3*u i+(6*c i)/25 := by
      have hu : 0 ≤ u i := by
        dsimp [u, shiftedOwnedFirstNorm]
        exact Finset.sum_nonneg (fun w _ =>
          mul_nonneg (mass_nonneg
            (fun k => p (neighborIndex i (ownedNeighbors c i) k))
            (fun k b => hp (neighborIndex i (ownedNeighbors c i) k) b)
            (ownedNeighbors c i).card w) (Real.sqrt_nonneg _))
      have hcpart : 0 ≤ (6*c i)/25 := by positivity
      exact add_nonneg (mul_nonneg (Real.sqrt_nonneg _) hu) hcpart
    have hreplace :
        Real.sqrt (sourceInfluence p f i) *
        (Real.sqrt 3*u i+(6*c i)/25) ≤
          T*(Real.sqrt 3*u i+(6*c i)/25) :=
      mul_le_mul_of_nonneg_right hroot hfactor
    exact hloc.trans hreplace
  have hvariance : sourceVariance p f = ∑ i : ι, e i := by
    have h := original_source_variance_eq_singleton_plus_owned_moment2
      p hp hp1 f hdegree c
    dsimp [e]
    rw [h, Finset.sum_add_distrib]
  have hU : (∑ i : ι, u i) ≤ (2*(1+Real.sqrt 2))*B := by
    calc
      (∑ i : ι, u i) ≤ ∑ i : ι, sourceMeanSectionNorm p f i := by
        apply Finset.sum_le_sum
        intro i _
        exact shifted_owned_first_norm_le_source_section
          p hp hp1 f hdegree c i
      _ ≤ (2*(1+Real.sqrt 2))*B := actual_source_integrated_sharp_budget
        p hp hp1 f hdegree B hB hf
  have hsum : sourceVariance p f ≤
      T*(Real.sqrt 3*(∑ i : ι, u i)+(6*(∑ i : ι, c i))/25) := by
    calc
      sourceVariance p f = ∑ i : ι, e i := hvariance
      _ ≤ ∑ i : ι, T*(Real.sqrt 3*u i+(6*c i)/25) :=
        Finset.sum_le_sum (fun i _ => hsite i)
      _ = T*(Real.sqrt 3*(∑ i : ι, u i)+(6*(∑ i : ι, c i))/25) := by
        simp only [mul_add, Finset.sum_add_distrib, ← Finset.mul_sum,
          Finset.sum_div]
  have hbudget :
      Real.sqrt 3*(∑ i : ι, u i)+(6*(∑ i : ι, c i))/25 ≤
        ((2*(1+Real.sqrt 2))*Real.sqrt 3+48/25)*B := by
    have h1 := mul_le_mul_of_nonneg_left hU (Real.sqrt_nonneg (3:ℝ))
    have h2 : (6*(∑ i : ι, c i))/25 ≤ 6*(8*B)/25 := by linarith [hcost]
    nlinarith [h1,h2]
  have hVbound : sourceVariance p f ≤
      ((2*(1+Real.sqrt 2))*Real.sqrt 3+48/25)*B*T := by
    calc
      _ ≤ T*(Real.sqrt 3*(∑ i : ι, u i)+(6*(∑ i : ι, c i))/25) := hsum
      _ ≤ T*(((2*(1+Real.sqrt 2))*Real.sqrt 3+48/25)*B) :=
        mul_le_mul_of_nonneg_left hbudget hT
      _ = _ := by ring
  have hV0 : 0 ≤ sourceVariance p f := by
    unfold sourceVariance
    apply Finset.sum_nonneg
    intro x _
    exact mul_nonneg
      (Finset.prod_nonneg (fun i _ => hp i (x i))) (sq_nonneg _)
  have hR : 0 ≤ ((2*(1+Real.sqrt 2))*Real.sqrt 3+48/25)*B*T := by positivity
  have hsq : (sourceVariance p f)^2 ≤
      (((2*(1+Real.sqrt 2))*Real.sqrt 3+48/25)*B*T)^2 := by
    nlinarith [mul_nonneg
      (sub_nonneg.mpr hVbound) (add_nonneg hR hV0)]
  calc
    (sourceVariance p f)^2 ≤
        (((2*(1+Real.sqrt 2))*Real.sqrt 3+48/25)*B*T)^2 := hsq
    _ = ((2*(1+Real.sqrt 2))*Real.sqrt 3+48/25)^2*B^2*M := by rw [← hT2]; ring

end Nightfall.Observability.ActualSourceQ2105Terminal

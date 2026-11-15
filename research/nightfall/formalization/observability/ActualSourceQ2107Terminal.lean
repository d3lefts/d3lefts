import ActualSourceQ2121Terminal
import ShiftedC4Scalar

/-!
# Unrestricted original-source finite Q2 C107.393 with strong shifted moment
Proposed kernel gate only until exact-head CI succeeds.
All original singleton components, heterogeneous finite laws, and
zero-probability atoms retained; no supplied moment/section oracle.
-/

namespace Nightfall.Observability.ActualSourceQ2107Terminal

open Finset
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualSourceVarianceEnergy
open Nightfall.Observability.ActualSourceInfluenceEnergy
open Nightfall.Observability.ActualSourceMeanSectionJensen
open Nightfall.Observability.ActualSourceIntegratedSections
open Nightfall.Observability.ActualSourceIntegratedFive
open Nightfall.Observability.ActualSourceIntegratedSharp
open Nightfall.Observability.ActualSourceQ2128Terminal
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
open Nightfall.ShiftedC4Scalar
open Nightfall.Observability.ShiftedOwnerScalar
open Nightfall.Observability.ShiftedHilbertManyIncrement
open Nightfall.Observability.QuadraticHilbertMany
open Nightfall.Observability.QuadraticHilbertMoments
open Nightfall.Observability.QuadraticActualMomentEndpoint

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

/-- Shifted local site: original canonical singleton, true owned
independent source-neighbor samples, true source first norm and
the original resampling influence. -/
theorem actual_source_shifted_site_107
    (p : ι → α → ℝ)
    (hp : ∀ k b, 0 ≤ p k b)
    (hp1 : ∀ k, (∑ b : α, p k b) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (c : ι → ℝ) (hc : ∀ i, 0 ≤ c i)
    (hcover : ∀ e : Edge ι, ∀ a b : α,
       |sourceDoubleCenteredPair p f (edgeFirst e) (edgeSecond e) a b| ≤
         c (owner edgeFirst edgeSecond c e))
    (i : ι) :
    let J := ownedNeighbors c i
    let j := neighborIndex i J
    let Y := finitePairIncrement p f i j J.card
    let a := originalSingletonNorm p f i
    let s := moment2 (fun k => p (j k)) Y J.card
    let e := a^2+s
    e ≤ sourceInfluence p f i ∧
    e ≤ Real.sqrt (sourceInfluence p f i) *
      (Real.sqrt 3 * shiftedOwnedFirstNorm p f c i + c i/4) := by
  classical
  dsimp
  let J : Finset ι := ownedNeighbors c i
  let j : ℕ → ι := neighborIndex i J
  let Y := finitePairIncrement p f i j J.card
  let a : ℝ := originalSingletonNorm p f i
  let H : α → ℝ := fun b =>
    Real.sqrt (p i b) * sourceCenteredSingleton p f i b
  let s : ℝ := moment2 (fun k => p (j k)) Y J.card
  let e : ℝ := a^2+s
  let u : ℝ := shiftedOwnedFirstNorm p f c i
  let q : ℝ := shiftedMoment4 (fun k => p (j k)) Y H J.card
  have ha : 0 ≤ a := Real.sqrt_nonneg _
  have hs : 0 ≤ s := by
    dsimp [s, moment2]
    apply Finset.sum_nonneg
    intro w _
    exact mul_nonneg (mass_nonneg (fun k => p (j k))
      (fun k b => hp (j k) b) J.card w) (vecNormSq_nonneg _)
  have he : 0 ≤ e := by dsimp [e]; positivity
  have hu : 0 ≤ u := by
    dsimp [u, shiftedOwnedFirstNorm]
    apply Finset.sum_nonneg
    intro w _
    exact mul_nonneg (mass_nonneg (fun k => p (j k))
      (fun k b => hp (j k) b) J.card w) (Real.sqrt_nonneg _)
  have hH : vecNormSq H = a^2 := by
    have htab : a = Real.sqrt (∑ b : α, p i b *
      (sourceCenteredSingleton p f i b)^2) := by
        exact original_singleton_norm_source_table p hp1 f i
    have hnonneg : 0 ≤
        (∑ b : α, p i b * (sourceCenteredSingleton p f i b)^2) :=
      Finset.sum_nonneg (fun b _ => mul_nonneg (hp i b) (sq_nonneg _))
    calc
      vecNormSq H =
          ∑ b : α, p i b * (sourceCenteredSingleton p f i b)^2 := by
            unfold vecNormSq
            apply Finset.sum_congr rfl
            intro b _
            dsimp [H]
            rw [mul_pow, Real.sq_sqrt (hp i b)]
            ring
      _ = a^2 := by rw [htab, Real.sq_sqrt hnonneg]
  have hne : ∀ k, k < J.card → i ≠ j k := by
    intro k hk
    have hm := neighborIndex_mem i J k hk
    exact (original_owner_not_in_neighbors c i) (by simpa [j,J] using hm)
  have hkernel : ∀ k, k < J.card → ∀ b d : α,
      |sourceDoubleCenteredPair p f i (j k) b d| ≤ c i := by
    intro k hk b d
    exact actual_owned_neighbor_kernel_amplitude
      p hp1 f c hcover i k hk b d
  have hY : ∀ k b, (∑ d : α, p (j k) d * Y k d b) = 0 := by
    intro k b
    exact finitePairIncrement_centered p hp1 f i j J.card hne k b
  have hbound : ∀ k b, vecNormSq (Y k b) ≤ (c i)^2 := by
    intro k b
    exact finitePairIncrement_norm_bounded
      p hp hp1 f i j J.card (c i) hkernel k b
  have hsecond := shifted_second_moment
    (fun k => p (j k)) Y H
    (fun k => hp1 (j k)) hY J.card
  have hbudget := moment2_eq_budget (fun k => p (j k)) Y
    (fun k => hp1 (j k)) hY J.card
  have hfourth := arbitrary_law_many_shifted_hilbert_fourth
    (fun k => p (j k)) Y H a (c i)
    (fun k b => hp (j k) b) (fun k => hp1 (j k))
    hY ha (hc i) hH hbound J.card
  have hqstrong : q ≤
      3*e^2-2*a^4+4*a*(c i)*s+(c i)^2*s := by
    dsimp [q,e,s]
    rw [← hbudget] at hfourth
    convert hfourth using 1 <;> ring
  have hint := shifted_product_l1_l2_l4 (fun k => p (j k))
    Y H (fun k b => hp (j k) b) J.card
  have hnorm : (∑ w : Samples α J.card,
      mass (fun k => p (j k)) J.card w *
        vecNormSq (fun b => H b + sumVector Y J.card w b)) = e := by
    calc
      _ = vecNormSq H + moment2 (fun k => p (j k)) Y J.card :=
        hsecond
      _ = e := by dsimp [e,s]; rw [hH]
  have hholder : e^3 ≤ u^2*q := by
    rw [hnorm] at hint
    simpa only [u, shiftedOwnedFirstNorm, q, H, Y, j, J] using hint
  have hshift : Real.sqrt e ≤ Real.sqrt 3*u+(c i)/4 :=
    shifted_c4_from_strong_moments a s (c i) u e q
      ha hs (hc i) hu rfl hholder hqstrong
  have hcap : e ≤ sourceInfluence p f i := by
    simpa only [e,a,s,j,Y,J] using
      (original_singleton_plus_owned_energy_le_influence
        p hp hp1 f hdegree c i)
  have hM0 : 0 ≤ sourceInfluence p f i := le_trans he hcap
  have hsite : e ≤ Real.sqrt (sourceInfluence p f i) *
      (Real.sqrt 3*u+(c i)/4) := by
    have hroot : Real.sqrt e ≤ Real.sqrt (sourceInfluence p f i) :=
      Real.sqrt_le_sqrt hcap
    have hroot0 : 0 ≤ Real.sqrt e := Real.sqrt_nonneg _
    calc
      e = Real.sqrt e * Real.sqrt e := by
        rw [← pow_two, Real.sq_sqrt he]
      _ ≤ Real.sqrt (sourceInfluence p f i) * Real.sqrt e :=
        mul_le_mul_of_nonneg_right hroot hroot0
      _ ≤ Real.sqrt (sourceInfluence p f i) *
          (Real.sqrt 3*u+(c i)/4) :=
        mul_le_mul_of_nonneg_left hshift (Real.sqrt_nonneg _)

  exact ⟨hcap, by simpa only [e,u,a,s,j,Y,J] using hsite⟩

/-- Unrestricted-source finite Q2 bound with no caller-supplied source,
owner, moment, or section premises. Requires exact-head Lean gate. -/
theorem actual_source_q2_107_unconditional
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
         ((2*(1+Real.sqrt 2))*Real.sqrt 3+2)^2*B^2*M := by
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
      T*(Real.sqrt 3*u i+c i/4) := by
    intro i
    obtain ⟨hcap,hloc⟩ := actual_source_shifted_site_107
      p hp hp1 f hdegree c hc hcover i
    have hroot := Real.sqrt_le_sqrt (hM i)
    have hfactor : 0 ≤ Real.sqrt 3*u i+c i/4 := by
      have hu : 0 ≤ u i := by
        dsimp [u, shiftedOwnedFirstNorm]
        exact Finset.sum_nonneg (fun w _ =>
          mul_nonneg (mass_nonneg
            (fun k => p (neighborIndex i (ownedNeighbors c i) k))
            (fun k b => hp (neighborIndex i (ownedNeighbors c i) k) b)
            (ownedNeighbors c i).card w) (Real.sqrt_nonneg _))
      exact add_nonneg (mul_nonneg (Real.sqrt_nonneg _) hu)
        (div_nonneg (hc i) (by norm_num))
    have hreplace :
        Real.sqrt (sourceInfluence p f i) *
        (Real.sqrt 3*u i+c i/4) ≤
          T*(Real.sqrt 3*u i+c i/4) :=
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
      T*(Real.sqrt 3*(∑ i : ι, u i)+(∑ i : ι, c i)/4) := by
    calc
      sourceVariance p f = ∑ i : ι, e i := hvariance
      _ ≤ ∑ i : ι, T*(Real.sqrt 3*u i+c i/4) :=
        Finset.sum_le_sum (fun i _ => hsite i)
      _ = T*(Real.sqrt 3*(∑ i : ι, u i)+(∑ i : ι, c i)/4) := by
        simp only [mul_add, Finset.sum_add_distrib, ← Finset.mul_sum,
          Finset.sum_div]
  have hbudget :
      Real.sqrt 3*(∑ i : ι, u i)+(∑ i : ι, c i)/4 ≤
        ((2*(1+Real.sqrt 2))*Real.sqrt 3+2)*B := by
    have h1 := mul_le_mul_of_nonneg_left hU (Real.sqrt_nonneg (3:ℝ))
    have h2 : (∑ i : ι, c i)/4 ≤ (8*B)/4 := by linarith [hcost]
    nlinarith [h1,h2]
  have hVbound : sourceVariance p f ≤
      ((2*(1+Real.sqrt 2))*Real.sqrt 3+2)*B*T := by
    calc
      _ ≤ T*(Real.sqrt 3*(∑ i : ι, u i)+(∑ i : ι, c i)/4) := hsum
      _ ≤ T*(((2*(1+Real.sqrt 2))*Real.sqrt 3+2)*B) :=
        mul_le_mul_of_nonneg_left hbudget hT
      _ = _ := by ring
  have hV0 : 0 ≤ sourceVariance p f := by
    unfold sourceVariance
    apply Finset.sum_nonneg
    intro x _
    exact mul_nonneg
      (Finset.prod_nonneg (fun i _ => hp i (x i))) (sq_nonneg _)
  have hR : 0 ≤ ((2*(1+Real.sqrt 2))*Real.sqrt 3+2)*B*T := by positivity
  have hsq : (sourceVariance p f)^2 ≤
      (((2*(1+Real.sqrt 2))*Real.sqrt 3+2)*B*T)^2 := by
    nlinarith [mul_nonneg
      (sub_nonneg.mpr hVbound) (add_nonneg hR hV0)]
  calc
    (sourceVariance p f)^2 ≤
        (((2*(1+Real.sqrt 2))*Real.sqrt 3+2)*B*T)^2 := hsq
    _ = ((2*(1+Real.sqrt 2))*Real.sqrt 3+2)^2*B^2*M := by rw [← hT2]; ring

end Nightfall.Observability.ActualSourceQ2107Terminal

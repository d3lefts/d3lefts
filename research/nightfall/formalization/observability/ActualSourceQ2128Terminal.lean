import ActualSourceQ2364Terminal
import ShiftedOwnerScalarMoments
import ShiftedHilbertManyIncrement
import ShiftedOwnerSourceJensen
import QuadraticActualMomentEndpoint

/-!
# Unrestricted singleton Q2, proposed coefficient (5 sqrt 3 + 8/3)^2

This terminal is intentionally SOURCE ONLY: no caller-supplied moment,
section, shifted-norm, owner or additive budgets. The proof is to be
promoted only after the exact-head pinned Lean axiom audit succeeds.
-/

namespace Nightfall.Observability.ActualSourceQ2128Terminal

open Finset
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.ActualProductSourcePairCentering
open Nightfall.Observability.ActualProductSourceDerivedStar
open Nightfall.Observability.ActualESGreedyOwnership
open Nightfall.Observability.ActualSourceOwnedProjectedMomentJensen
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualSourceVarianceEnergy
open Nightfall.Observability.ActualSourceInfluenceEnergy
open Nightfall.Observability.ActualSourceMeanSectionJensen
open Nightfall.Observability.ActualSourceIntegratedSections
open Nightfall.Observability.ActualSourceIntegratedFive
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

/-- The shifted L1-L2-L4 interpolation includes a deterministic shift
without a zero-mean assumption on the sum. -/
theorem shifted_product_l1_l2_l4
    (q : ℕ → α → ℝ) (Y : ℕ → α → α → ℝ)
    (H : α → ℝ) (hq : ∀ k b, 0 ≤ q k b) (n : ℕ) :
    (∑ w : Samples α n, mass q n w *
      vecNormSq (fun a => H a + sumVector Y n w a))^3 ≤
      (∑ w : Samples α n, mass q n w *
        Real.sqrt (vecNormSq (fun a => H a + sumVector Y n w a)))^2 *
          shiftedMoment4 q Y H n := by
  classical
  let v : Samples α n → ℝ := fun w =>
    Real.sqrt (vecNormSq (fun a => H a + sumVector Y n w a))
  have hv2 (w : Samples α n) :
      v w ^ 2 = vecNormSq (fun a => H a + sumVector Y n w a) :=
    Real.sq_sqrt (vecNormSq_nonneg _)
  have hv4 (w : Samples α n) :
      v w ^ 4 = (vecNormSq (fun a => H a + sumVector Y n w a))^2 := by
    calc
      v w ^ 4 = (v w ^ 2)^2 := by ring
      _ = _ := by rw [hv2]
  have h := weighted_l1_l2_l4
    (mass q n) v (mass_nonneg q hq n) (fun w => Real.sqrt_nonneg _)
  have he2 : (∑ w : Samples α n, mass q n w * (v w)^2) =
      ∑ w : Samples α n, mass q n w *
        vecNormSq (fun a => H a + sumVector Y n w a) := by
    apply Finset.sum_congr rfl
    intro w _
    rw [hv2]
  have he4 : (∑ w : Samples α n, mass q n w * (v w)^4) =
      shiftedMoment4 q Y H n := by
    unfold shiftedMoment4
    apply Finset.sum_congr rfl
    intro w _
    rw [hv4]
  simpa only [he2, he4, v] using h

/-- Crude fourth moment follows from the stronger shifted envelope.
The key sum of squares identity is
  e^2 - 2 a s sqrt(e) = (a sqrt(e)-s)^2 + a^2 s.
-/
theorem shifted_fourth_coarse
    (a s c e q : ℝ)
    (ha : 0 ≤ a) (hs : 0 ≤ s) (hc : 0 ≤ c)
    (he : e = a^2+s)
    (hq : q ≤ 3*e^2-2*a^4+4*a*c*s+c^2*s) :
    q ≤ 3*e^2+2*c*e*Real.sqrt e+c^2*e := by
  have he0 : 0 ≤ e := by rw [he]; positivity
  let t : ℝ := Real.sqrt e
  have ht0 : 0 ≤ t := Real.sqrt_nonneg _
  have ht2 : t^2 = e := Real.sq_sqrt he0
  have haux : a^2*t^2 = a^4+a^2*s := by
    rw [ht2, he]
    ring
  have hid : e^2-2*a*s*t = (a*t-s)^2+a^2*s := by
    rw [he]
    nlinarith [haux]
  have hpol : 2*a*s*t ≤ e^2 := by
    nlinarith [hid, sq_nonneg (a*t-s),
      mul_nonneg (sq_nonneg a) hs]
  have hmixed : 2*a*s ≤ e*t := by
    by_cases htzero : t = 0
    · have hezero : e = 0 := by nlinarith [ht2]
      have hazero : a = 0 := by rw [he] at hezero; nlinarith
      rw [hazero]
      simp [hezero]
    · have htpos : 0 < t := lt_of_le_of_ne ht0 (Ne.symm htzero)
      have hpol' : (2*a*s)*t ≤ (e*t)*t := by
        calc
          (2*a*s)*t ≤ e^2 := by nlinarith [hpol]
          _ = (e*t)*t := by
            calc
              e^2 = e*t^2 := by rw [ht2]; ring
              _ = (e*t)*t := by ring
      exact (mul_le_mul_iff_of_pos_right htpos).mp hpol'
  have hcross : 4*a*c*s ≤ 2*c*e*t := by
    nlinarith [mul_nonneg (sub_nonneg.mpr hmixed) hc]
  have hsc : c^2*s ≤ c^2*e := by
    apply mul_le_mul_of_nonneg_left
    · rw [he]; nlinarith [sq_nonneg a]
    · positivity
  dsimp [t] at hcross
  nlinarith [hq, hcross, hsc, sq_nonneg (a^2)]

/-- Shifted local site: original canonical singleton, true owned
independent source-neighbor samples, true source first norm and
the original resampling influence. -/
theorem actual_source_shifted_site_128
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
      (Real.sqrt 3 * shiftedOwnedFirstNorm p f c i + c i/3) := by
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
    have hm : j k ∈ ownedNeighbors c i := by
      simpa only [j, J] using (neighborIndex_mem i J k hk)
    intro heq
    rw [← heq] at hm
    exact (original_owner_not_in_neighbors c i) hm
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
  have hqcoarse : q ≤ 3*e^2+2*(c i)*e*Real.sqrt e+(c i)^2*e :=
    shifted_fourth_coarse a s (c i) e q ha hs (hc i) rfl hqstrong
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
  have hshift := shifted_c3_from_moments e u (c i) q
      he hu (hc i) hholder hqcoarse
  have hcap : e ≤ sourceInfluence p f i := by
    simpa only [e,a,s,j,Y,J] using
      (original_singleton_plus_owned_energy_le_influence
        p hp hp1 f hdegree c i)
  have hM0 : 0 ≤ sourceInfluence p f i := le_trans he hcap
  have hsite := shifted_site_c3 e u (c i) (sourceInfluence p f i)
      he hu (hc i) hM0 hcap hshift
  exact ⟨hcap, by simpa only [e,u,a,s,j,Y,J] using hsite⟩

/-- Unrestricted-source finite Q2 bound with no caller-supplied source,
owner, moment, or section premises. Requires exact-head Lean gate. -/
theorem actual_source_q2_128_unconditional
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
         (5*Real.sqrt 3+8/3)^2*B^2*M := by
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
      T*(Real.sqrt 3*u i+c i/3) := by
    intro i
    obtain ⟨hcap,hloc⟩ := actual_source_shifted_site_128
      p hp hp1 f hdegree c hc hcover i
    have hroot := Real.sqrt_le_sqrt (hM i)
    have hfactor : 0 ≤ Real.sqrt 3*u i+c i/3 := by
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
        (Real.sqrt 3*u i+c i/3) ≤
          T*(Real.sqrt 3*u i+c i/3) :=
      mul_le_mul_of_nonneg_right hroot hfactor
    exact hloc.trans hreplace
  have hvariance : sourceVariance p f = ∑ i : ι, e i := by
    have h := original_source_variance_eq_singleton_plus_owned_moment2
      p hp hp1 f hdegree c
    dsimp [e]
    rw [h, Finset.sum_add_distrib]
  have hU : (∑ i : ι, u i) ≤ 5*B := by
    calc
      (∑ i : ι, u i) ≤ ∑ i : ι, sourceMeanSectionNorm p f i := by
        apply Finset.sum_le_sum
        intro i _
        exact shifted_owned_first_norm_le_source_section
          p hp hp1 f hdegree c i
      _ ≤ 5*B := actual_source_integrated_five_budget
        p hp hp1 f hdegree B hB hf
  have hsum : sourceVariance p f ≤
      T*(Real.sqrt 3*(∑ i : ι, u i)+(∑ i : ι, c i)/3) := by
    calc
      sourceVariance p f = ∑ i : ι, e i := hvariance
      _ ≤ ∑ i : ι, T*(Real.sqrt 3*u i+c i/3) :=
        Finset.sum_le_sum (fun i _ => hsite i)
      _ = T*(Real.sqrt 3*(∑ i : ι, u i)+(∑ i : ι, c i)/3) := by
        simp only [mul_add, Finset.sum_add_distrib, ← Finset.mul_sum,
          Finset.sum_div]
  have hbudget :
      Real.sqrt 3*(∑ i : ι, u i)+(∑ i : ι, c i)/3 ≤
        (5*Real.sqrt 3+8/3)*B := by
    have h1 := mul_le_mul_of_nonneg_left hU (Real.sqrt_nonneg (3:ℝ))
    have h2 : (∑ i : ι, c i)/3 ≤ (8*B)/3 := by linarith [hcost]
    nlinarith [h1,h2]
  have hVbound : sourceVariance p f ≤
      (5*Real.sqrt 3+8/3)*B*T := by
    calc
      _ ≤ T*(Real.sqrt 3*(∑ i : ι, u i)+(∑ i : ι, c i)/3) := hsum
      _ ≤ T*((5*Real.sqrt 3+8/3)*B) :=
        mul_le_mul_of_nonneg_left hbudget hT
      _ = _ := by ring
  have hV0 : 0 ≤ sourceVariance p f := by
    unfold sourceVariance
    apply Finset.sum_nonneg
    intro x _
    exact mul_nonneg
      (Finset.prod_nonneg (fun i _ => hp i (x i))) (sq_nonneg _)
  have hR : 0 ≤ (5*Real.sqrt 3+8/3)*B*T := by positivity
  have hsq : (sourceVariance p f)^2 ≤
      ((5*Real.sqrt 3+8/3)*B*T)^2 := by
    nlinarith [mul_nonneg
      (sub_nonneg.mpr hVbound) (add_nonneg hR hV0)]
  calc
    (sourceVariance p f)^2 ≤
        ((5*Real.sqrt 3+8/3)*B*T)^2 := hsq
    _ = (5*Real.sqrt 3+8/3)^2*B^2*M := by rw [← hT2]; ring

end Nightfall.Observability.ActualSourceQ2128Terminal

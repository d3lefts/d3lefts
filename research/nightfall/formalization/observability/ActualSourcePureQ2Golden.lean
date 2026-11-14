import ActualSourceQ2589Terminal
import ActualSourceIntegratedFive
import Q2FlexibleSectionScalar

/-!
# Original-source pure Q2 golden-ratio coefficient

Zero canonical singleton sector, genuine arbitrary finite independent product
laws (heterogeneous weights and zero-mass atoms permitted). This is NOT an
unrestricted degree-two theorem.

- An unconditional source theorem using the previously certified 5B
  integrated section budget: (5*sqrt(3)+8*gamma)^2 ~ 100.9462739467.
- A conditional source theorem using the not-yet-proved 29B/6 section
  budget: (29*sqrt(3)/6+8*gamma)^2 ~ 95.2288523307.

No new probability lemma is presumed in the unconditional theorem.
-/ 

namespace Nightfall.Observability.ActualSourcePureQ2Golden

open Finset
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualSourceVarianceEnergy
open Nightfall.Observability.ActualSourceInfluenceEnergy
open Nightfall.Observability.ActualSourceOwnedGraph
open Nightfall.Observability.ActualSourceFinitePairMoment
open Nightfall.Observability.ActualSourceMeanSectionJensen
open Nightfall.Observability.ActualSourceIntegratedFive
open Nightfall.Observability.ActualSourceIntegratedSections
open Nightfall.Observability.ActualSourceQ2589Terminal
open Nightfall.Observability.ActualSourceSingletonEnergyBridge
open Nightfall.Observability.QuadraticHilbertMany
open Nightfall.Observability.QuadraticHilbertMoments
open Nightfall.Q2625Golden
open Nightfall.Q2625GoldenTrade
open Nightfall.Q2FlexibleSectionScalar

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

/-- Pure centered independent Hilbert cubic -> golden affine L1 site.
    This proof uses the existing pinned golden-ratio dual theorem,
    rather than postulating a new c/5 shifted Khintchine inequality. -/
theorem pure_golden_site
    (s z c u : ℝ)
    (hs : 0 ≤ s) (hz : 0 ≤ z) (hc : 0 ≤ c) (hu : 0 ≤ u)
    (hzu : z ≤ u)
    (hcubic : s^3 ≤ z^2*(c^2*s+3*s^2)) :
    Real.sqrt s ≤ Real.sqrt 3*u + gamma*c := by
  by_cases hs0 : s = 0
  · rw [hs0, Real.sqrt_zero]
    exact add_nonneg
      (mul_nonneg (Real.sqrt_nonneg _) hu)
      (mul_nonneg gamma_nonneg hc)
  have hspos : 0 < s := lt_of_le_of_ne hs (Ne.symm hs0)
  let t : ℝ := Real.sqrt s
  have htpos : 0 < t := Real.sqrt_pos.mpr hspos
  have htsq : t^2 = s := Real.sq_sqrt hs
  have htrade : s ≤ Real.sqrt 3*t*z + gamma*t*c := by
    exact cubic_to_sharp_affine s z c t
      hs hz hc (le_of_lt htpos) (by rw [htsq]) hcubic
  have hzu' : Real.sqrt 3*t*z ≤ Real.sqrt 3*t*u :=
    mul_le_mul_of_nonneg_left hzu
      (mul_nonneg (Real.sqrt_nonneg _) (le_of_lt htpos))
  have hleft : t*t ≤ Real.sqrt 3*t*z + gamma*t*c := by
    calc
      t*t = s := by nlinarith [htsq]
      _ ≤ Real.sqrt 3*t*z + gamma*t*c := htrade
  have hright : Real.sqrt 3*t*z + gamma*t*c ≤
      t*(Real.sqrt 3*u + gamma*c) := by
    nlinarith [hzu']
  exact (mul_le_mul_iff_of_pos_left htpos).mp (hleft.trans hright)

/-- True finite-source pure Q2 bound with a SPECIFIED original-source
    section coefficient U. This is a parameterized implication; only
    the 5B specialization below discharges that premise from p,f. -/
theorem actual_source_pure_q2_golden_given_section_budget
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (hzero : ∀ i : ι, originalSingletonNorm p f i = 0)
    (B : ℝ) (hB : 0 ≤ B)
    (hf : ∀ x, |f x| ≤ B)
    (U : ℝ) (hU : 0 ≤ U)
    (hsection :
      (∑ i : ι, sourceMeanSectionNorm p f i) ≤ U*B) :
    ∀ M : ℝ, 0 ≤ M →
      (∀ i : ι, sourceInfluence p f i ≤ M) →
      (sourceVariance p f)^2 ≤
        (Real.sqrt 3*U+8*gamma)^2*B^2*M := by
  classical
  intro M hM0 hM
  let T : ℝ := Real.sqrt M
  have hT : 0 ≤ T := Real.sqrt_nonneg _
  have hT2 : T^2 = M := Real.sq_sqrt hM0
  obtain ⟨c,hc,hcover,howner⟩ :=
    original_source_generated_cubic_jensen_package
      p hp hp1 f hdegree B hf
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
  have hs : ∀ i, 0 ≤ s i := by
    intro i
    dsimp [s,moment2]
    apply Finset.sum_nonneg
    intro w _
    exact mul_nonneg
      (mass_nonneg
        (fun k => p (neighborIndex i (ownedNeighbors c i) k))
        (fun k b => hp (neighborIndex i (ownedNeighbors c i) k) b)
        (ownedNeighbors c i).card w)
      (vecNormSq_nonneg _)
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
  have hu : ∀ i, 0 ≤ u i := by
    intro i
    have h := original_singleton_norm_le_source_mean_section_norm p hp f i
    rw [hzero i] at h
    exact h
  have hcap : ∀ i, s i ≤ M := by
    intro i
    have hsource : s i ≤ sourceInfluence p f i := by
      simpa only [s] using (howner i).1
    exact hsource.trans (hM i)
  have hsite : ∀ i, (0:ℝ)^2+s i ≤
      T*(Real.sqrt 3*u i+0*(0:ℝ)+gamma*c i) := by
    intro i
    have hnoise : z i ≤ u i := by
      have h := (howner i).2.1
      rw [hzero i] at h
      simpa only [u,z,add_zero] using h
    have hcubic :
        (s i)^3 ≤ (z i)^2*((c i)^2*(s i)+3*(s i)^2) := by
      simpa only [s,z] using (howner i).2.2
    have hpure := pure_golden_site (s i) (z i) (c i) (u i)
      (hs i) (hz i) (hc i) (hu i) hnoise hcubic
    have hrootle : Real.sqrt (s i) ≤ T := by
      simpa only [T] using (Real.sqrt_le_sqrt (hcap i))
    have heq : (Real.sqrt (s i))^2 = s i := Real.sq_sqrt (hs i)
    have hbound : s i ≤ T*(Real.sqrt 3*u i+gamma*c i) := by
      calc
        s i = Real.sqrt (s i)*Real.sqrt (s i) := by nlinarith [heq]
        _ ≤ T*Real.sqrt (s i) :=
          mul_le_mul_of_nonneg_right hrootle (Real.sqrt_nonneg _)
        _ ≤ T*(Real.sqrt 3*u i+gamma*c i) :=
          mul_le_mul_of_nonneg_left hpure hT
    simpa using hbound
  have hvariance0 :
      sourceVariance p f = ∑ i : ι, s i := by
    have hv := original_source_variance_eq_singleton_plus_owned_moment2
      p hp hp1 f hdegree c
    have hzeroSum :
        (∑ i : ι, (originalSingletonNorm p f i)^2) = 0 := by
      apply Finset.sum_eq_zero
      intro i _
      rw [hzero i]
      ring
    calc
      sourceVariance p f =
          (∑ i : ι, (originalSingletonNorm p f i)^2) +
            ∑ i : ι, s i := by simpa only [s] using hv
      _ = ∑ i : ι, s i := by rw [hzeroSum, zero_add]
  have hV : 0 ≤ sourceVariance p f := by
    rw [hvariance0]
    exact Finset.sum_nonneg (fun i _ => hs i)
  have hvariance :
      sourceVariance p f =
        (∑ _i : ι, (0:ℝ)^2) + ∑ i : ι, s i := by
    simpa using hvariance0
  have hsection' : (∑ i : ι, u i) ≤ U*B := by
    simpa only [u] using hsection
  have hadditive :
      (∑ _i : ι, (0:ℝ)) ≤
        (2*(1+Real.sqrt 2))*B := by
    simp
    positivity
  have hfinal := sitewise_budget_to_variance_squared_flexible
    (fun _ : ι => (0:ℝ)) u c s B T M (sourceVariance p f)
    (Real.sqrt 3) 0 gamma U
    hB hT hV (Real.sqrt_nonneg _) (by norm_num)
    gamma_nonneg hU hsite hsection' hadditive hcover hvariance hT2
  convert hfinal using 1 <;> ring

/-- No extra moment, source-section, or ownership hypotheses:
    all come from the genuine source and the merged 5B theorem.
    The canonical singleton restriction is indispensable. -/
theorem actual_source_pure_q2_golden_101_unconditional
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (hzero : ∀ i : ι, originalSingletonNorm p f i = 0)
    (B : ℝ) (hB : 0 ≤ B)
    (hf : ∀ x, |f x| ≤ B) :
    ∀ M : ℝ, 0 ≤ M →
      (∀ i : ι, sourceInfluence p f i ≤ M) →
      (sourceVariance p f)^2 ≤
        (5*Real.sqrt 3+8*gamma)^2*B^2*M := by
  have hsection :=
    actual_source_integrated_five_budget p hp hp1 f hdegree B hB hf
  intro M hM0 hM
  have h := actual_source_pure_q2_golden_given_section_budget
    p hp hp1 f hdegree hzero B hB hf 5 (by norm_num)
    hsection M hM0 hM
  convert h using 1 <;> ring

/-- The C95.2288523 endpoint, CONDITIONAL on an actual-source
    29B/6 bound. This theorem does NOT derive that section estimate. -/
theorem actual_source_pure_q2_golden_95_given_29_over_6
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (hzero : ∀ i : ι, originalSingletonNorm p f i = 0)
    (B : ℝ) (hB : 0 ≤ B)
    (hf : ∀ x, |f x| ≤ B)
    (hsection :
      (∑ i : ι, sourceMeanSectionNorm p f i) ≤ (29/6:ℝ)*B) :
    ∀ M : ℝ, 0 ≤ M →
      (∀ i : ι, sourceInfluence p f i ≤ M) →
      (sourceVariance p f)^2 ≤
        ((29/6:ℝ)*Real.sqrt 3+8*gamma)^2*B^2*M := by
  intro M hM0 hM
  have h := actual_source_pure_q2_golden_given_section_budget
    p hp hp1 f hdegree hzero B hB hf (29/6:ℝ) (by norm_num)
    hsection M hM0 hM
  convert h using 1 <;> ring

end Nightfall.Observability.ActualSourcePureQ2Golden

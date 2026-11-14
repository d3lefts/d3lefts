import ActualSourceQ2589Terminal
import ActualSourceIntegratedSections
import Q2ShiftedPureC5
import Q2ShiftedConditionalTargets

/-!
# Pure-degree-two source Q2: c/5 owner fifth-moment interpolation

This is a genuinely original-source finite-product theorem candidate,
but RESTRICTED to f with zero canonical singleton components.

It reuses the source-derived owned-neighbor cubic from the merged Q2
theorem.  When singleton h_i=0, the source Jensen estimate z_i<=u_i
does not pay an additive penalty, and the true cubic satisfies the
new c/5 interpolation from Q2ShiftedPureC5.

No new fourth-moment assumption, synthetic product law or opaque axiom
is passed to the theorem. The optional sharp section budget is an
additional explicit premise of the conditional K99 result, but the
K239 result uses the already imported source-derived U=8 budget.
The U=5 (K105) improvement is conditionally stated until this stacked
branch also contains PR #525's separately certified source 5B module.
-/

namespace Nightfall.Observability.ActualSourcePureQ2Fifth

open Finset
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualSourceVarianceEnergy
open Nightfall.Observability.ActualSourceInfluenceEnergy
open Nightfall.Observability.ActualSourceOwnedGraph
open Nightfall.Observability.ActualSourceFinitePairMoment
open Nightfall.Observability.ActualSourceMeanSectionJensen
open Nightfall.Observability.ActualSourceIntegratedSections
open Nightfall.Observability.ActualSourceQ2589Terminal
open Nightfall.Observability.ActualSourceSingletonEnergyBridge
open Nightfall.Observability.QuadraticHilbertMany
open Nightfall.Observability.QuadraticHilbertMoments
open Nightfall.Q2Shifted.PureC5
open Nightfall.Q2Shifted.ConditionalTargets

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

/-- Pure Q2, true finite source p and f: under a supplied section
    coefficient U, the source-owned cubic and new fifth interpolation
    yield (sqrt3 U+8/5)^2. No supplied owner/moment oracle. -/
theorem actual_source_pure_q2_given_section_budget
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
        (Real.sqrt 3*U+8/5)^2*B^2*M := by
  classical
  intro M hM0 hM
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
    have h := original_singleton_norm_le_source_mean_section_norm
      p hp f i
    rw [hzero i] at h
    exact h
  have hcap : ∀ i, s i ≤ M := by
    intro i
    have hsource : s i ≤ sourceInfluence p f i := by
      simpa only [s] using (howner i).1
    exact hsource.trans (hM i)
  have hshift : ∀ i, Real.sqrt (s i) ≤
      Real.sqrt 3*u i + (1/5:ℝ)*c i := by
    intro i
    have hnoise : z i ≤ u i + originalSingletonNorm p f i := by
      simpa only [z,u] using (howner i).2.1
    have hzu : z i ≤ u i := by
      rw [hzero i] at hnoise
      linarith
    have hcubic :
        (s i)^3 ≤ (z i)^2*((c i)^2*(s i)+3*(s i)^2) := by
      simpa only [s,z] using (howner i).2.2
    have hh := fifth_from_centered_cubic (s i) (z i) (c i) (u i)
      (hs i) (hz i) (hc i) (hu i) hcubic hzu
    convert hh using 1 <;> ring
  have hvariance :
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
  have hsection' : (∑ i : ι, u i) ≤ U*B := by
    simpa only [u] using hsection
  have hgoal := conditional_shifted_budget
    s u c B M (sourceVariance p f) U (1/5:ℝ)
    hB hM0 hU (by norm_num) hs hcap hshift
    hsection' hcover hvariance
  convert hgoal using 1 <;> ring

/-- Unconditional *pure Q2 subclass* source result with the existing
    8B source section budget: coefficient 238.9005. -/
theorem actual_source_pure_q2_239_unconditional
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
        (8*Real.sqrt 3+8/5)^2*B^2*M := by
  have hsection :=
    actual_source_integrated_eight_budget p hp hp1 f hdegree B hB hf
  exact actual_source_pure_q2_given_section_budget
    p hp hp1 f hdegree hzero B hB hf 8 (by norm_num)
    (by simpa only [mul_comm] using hsection)

/-- Pure Q2 K105 conditional on a 5B section budget. The 5B
    section theorem is *independently* Lean-certified in merged
    PR #525, but not imported on this stacked base ref. -/
theorem actual_source_pure_q2_105_given_five_section
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (hzero : ∀ i : ι, originalSingletonNorm p f i = 0)
    (B : ℝ) (hB : 0 ≤ B)
    (hf : ∀ x, |f x| ≤ B)
    (hsection : (∑ i : ι, sourceMeanSectionNorm p f i) ≤
      5*B) :
    ∀ M : ℝ, 0 ≤ M →
      (∀ i : ι, sourceInfluence p f i ≤ M) →
      (sourceVariance p f)^2 ≤
        (5*Real.sqrt 3+8/5)^2*B^2*M := by
  exact actual_source_pure_q2_given_section_budget
    p hp hp1 f hdegree hzero B hB hf 5 (by norm_num) hsection

/-- Pure Q2 99.263 with explicit sharp U bound; the sharp section
    theorem has NOT yet been source-certified on the current base. -/
theorem actual_source_pure_q2_99_given_sharp_section
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (hzero : ∀ i : ι, originalSingletonNorm p f i = 0)
    (B : ℝ) (hB : 0 ≤ B)
    (hf : ∀ x, |f x| ≤ B)
    (hsection : (∑ i : ι, sourceMeanSectionNorm p f i) ≤
      2*(1+Real.sqrt 2)*B) :
    ∀ M : ℝ, 0 ≤ M →
      (∀ i : ι, sourceInfluence p f i ≤ M) →
      (sourceVariance p f)^2 ≤
        (2*Real.sqrt 3*(1+Real.sqrt 2)+8/5)^2*B^2*M := by
  have hU : (0:ℝ) ≤ 2*(1+Real.sqrt 2) := by positivity
  exact actual_source_pure_q2_given_section_budget
    p hp hp1 f hdegree hzero B hB hf
    (2*(1+Real.sqrt 2)) hU (by simpa only [mul_assoc] using hsection)

end Nightfall.Observability.ActualSourcePureQ2Fifth

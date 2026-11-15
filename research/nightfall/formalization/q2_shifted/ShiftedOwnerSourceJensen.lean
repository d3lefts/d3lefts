import ActualSourceOwnedProjectedMomentJensen

/-!
# Genuine original-source shifted owned-neighbor Jensen

Unlike the old pair-only bound
  E ||Z_i|| <= u_i + ||h_i||,
this module targets the *shifted* sum
  W_i = h_i + Z_i
under the true original source law. The singleton is included BEFORE
taking the Hilbert norm. The source projected section is exactly W_i,
so original-law conditional Jensen gives E ||W_i|| <= u_i.

No independence of different owners is claimed. The source neighbor
labels within each owner are injectively enumerated, and the original
law is transported using the existing general distinct-prefix theorem.
This module does not claim a shifted fourth-moment or Q2 terminal bound.
-/

namespace Nightfall.Observability.ShiftedOwnerSourceJensen

open Finset
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.ActualProductSourcePairCentering
open Nightfall.Observability.ActualProductSourceDerivedStar
open Nightfall.Observability.ActualSourceInfluenceEnergy
open Nightfall.Observability.ActualSourceConditionalSection
open Nightfall.Observability.ActualSourceMeanSectionJensen
open Nightfall.Observability.ActualSourceProjectedJensen
open Nightfall.Observability.ActualSourceOwnedProjectedMomentJensen
open Nightfall.Observability.ActualSourceOwnedSectionNorm
open Nightfall.Observability.ActualSourceOwnedGraph
open Nightfall.Observability.ActualSourceFiniteSampleLaw
open Nightfall.Observability.ActualSourceFinitePairMoment
open Nightfall.Observability.ActualSourceIntegratedSections
open Nightfall.Observability.ActualSourceSingletonProjection
open Nightfall.Observability.QuadraticHilbertMany
open Nightfall.Observability.QuadraticHilbertMoments

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

/-- Shift the actual source singleton inside the owner Hilbert norm,
before taking the expectation over distinct original neighbor sites. -/
noncomputable def shiftedOwnedFirstNorm
    (p : ι → α → ℝ) (f : (ι → α) → ℝ)
    (c : ι → ℝ) (i : ι) : ℝ :=
  let J := ownedNeighbors c i
  let j := neighborIndex i J
  let Y := finitePairIncrement p f i j J.card
  ∑ w : Samples α J.card,
    mass (fun k => p (j k)) J.card w *
      Real.sqrt (vecNormSq (fun a : α =>
        Real.sqrt (p i a) * sourceCenteredSingleton p f i a +
          sumVector Y J.card w a))

/-- The shifted Hilbert first moment is EXACTLY the original-source
conditional projected section, without a singleton triangle penalty.
This equality includes arbitrary heterogeneous zero-atom marginals. -/
theorem shifted_owned_first_norm_eq_projected_source
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (c : ι → ℝ) (i : ι) :
    shiftedOwnedFirstNorm p f c i =
      meanProjectedSourceNorm p f i (ownedNeighbors c i) := by
  classical
  let J : Finset ι := ownedNeighbors c i
  let j : ℕ → ι := neighborIndex i J
  let Y := finitePairIncrement p f i j J.card
  let F : Samples α J.card → ℝ := fun w =>
    Real.sqrt (vecNormSq (fun a : α =>
      Real.sqrt (p i a) * sourceCenteredSingleton p f i a +
        sumVector Y J.card w a))
  have hdistinct :
      ∀ k l, k < J.card → l < J.card → k ≠ l → j k ≠ j l :=
    fun k l hk hl hne =>
      neighborIndex_injective_on_prefix i J k l hk hl hne
  have hlaw := original_source_distinct_prefix_law
    p hp1 j J.card hdistinct F
  have hpoint (x : ι → α) :
      F (observedActualSample j J.card x) =
        projectedSourceNorm p f i J x := by
    dsimp [F, projectedSourceNorm, vecNormSq]
    congr 1
    apply Finset.sum_congr rfl
    intro a _
    have hsum :=
      original_source_finitePair_observed_sum p f i j J.card x a
    have hpair :=
      original_owned_pair_sum_eq_source_conditional_difference
        p hp1 f hdegree c i x a
    dsimp at hpair
    have hsingle :
        sourceCenteredSingleton p f i a =
          ∑ y : ι → α, originalMass p y *
            sourceCenteredSection p f i y a := by
      simpa only [originalSourceSection, sourceCenteredSection] using
        (actual_source_singleton_eq_mean_section p hp1 f i a)
    have hcombine :
        sourceCenteredSingleton p f i a +
          (∑ k ∈ Finset.range J.card,
            sourceDoubleCenteredPair p f i (j k) a (x (j k))) =
          averageSourceSection p f i J x a := by
      rw [hsingle]
      linarith [hpair]
    have hvector :
        Real.sqrt (p i a) * sourceCenteredSingleton p f i a +
          sumVector Y J.card (observedActualSample j J.card x) a =
        Real.sqrt (p i a) * averageSourceSection p f i J x a := by
      rw [original_source_finitePair_observed_sum p f i j J.card x a]
      calc
        _ = Real.sqrt (p i a) *
          (sourceCenteredSingleton p f i a +
            ∑ k ∈ Finset.range J.card,
              sourceDoubleCenteredPair p f i (j k) a (x (j k))) := by ring
        _ = _ := by rw [hcombine]
    rw [hvector, mul_pow, Real.sq_sqrt (hp i a)]
  calc
    shiftedOwnedFirstNorm p f c i =
        ∑ w : Samples α J.card,
          mass (fun k => p (j k)) J.card w * F w := by rfl
    _ = ∑ x : ι → α,
          originalMass p x * F (observedActualSample j J.card x) :=
      hlaw.symm
    _ = ∑ x : ι → α,
          originalMass p x * projectedSourceNorm p f i J x := by
      apply Finset.sum_congr rfl
      intro x _
      rw [hpoint x]
    _ = meanProjectedSourceNorm p f i (ownedNeighbors c i) := rfl

/-- Genuine-source shifted owner Jensen, no extra singleton term. -/
theorem shifted_owned_first_norm_le_source_section
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (c : ι → ℝ) (i : ι) :
    shiftedOwnedFirstNorm p f c i ≤
      sourceMeanSectionNorm p f i := by
  calc
    shiftedOwnedFirstNorm p f c i =
      meanProjectedSourceNorm p f i (ownedNeighbors c i) :=
        shifted_owned_first_norm_eq_projected_source
          p hp hp1 f hdegree c i
    _ ≤ sourceMeanSectionNorm p f i :=
      mean_projected_source_norm_le_unprojected
        p hp hp1 f i (ownedNeighbors c i)

/-- Source-derived global 8B first-moment budget for the shifted owner
random sums, with NO singleton additive budget and NO supplied section
norm premise. -/
theorem shifted_owned_first_norm_sum_le_eight
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (B : ℝ) (hB : 0 ≤ B)
    (hf : ∀ x, |f x| ≤ B)
    (c : ι → ℝ) :
    (∑ i : ι, shiftedOwnedFirstNorm p f c i) ≤ 8*B := by
  calc
    (∑ i : ι, shiftedOwnedFirstNorm p f c i) ≤
      ∑ i : ι, sourceMeanSectionNorm p f i := by
        apply Finset.sum_le_sum
        intro i _
        exact shifted_owned_first_norm_le_source_section
          p hp hp1 f hdegree c i
    _ ≤ 8*B :=
      actual_source_integrated_eight_budget
        p hp hp1 f hdegree B hB hf

end Nightfall.Observability.ShiftedOwnerSourceJensen

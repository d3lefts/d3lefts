import ActualSourceOwnedProjectedMomentJensen

/-!
# Actual-product shifted owned-neighbor first norm: source Jensen

The original source singleton is inserted BEFORE taking the Hilbert
first norm.  The result is the actual projected centered section,
whose mean is bounded directly by the original source section budget.
This theorem has only original p,f,degree, and owner c as parameters.
It does not require a shifted fourth-moment theorem.
-/

namespace Nightfall.Observability.ActualSourceShiftedJensen

open Finset
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualSourceOwnedGraph
open Nightfall.Observability.ActualSourceFiniteSampleLaw
open Nightfall.Observability.ActualSourceFinitePairMoment
open Nightfall.Observability.ActualSourceOwnedSectionNorm
open Nightfall.Observability.ActualSourceOwnedProjectedMomentJensen
open Nightfall.Observability.ActualSourceProjectedJensen
open Nightfall.Observability.ActualSourceMeanSectionJensen
open Nightfall.Observability.ActualSourceIntegratedSections
open Nightfall.Observability.ActualSourceConditionalSection
open Nightfall.Observability.QuadraticHilbertMany
open Nightfall.Observability.QuadraticHilbertMoments

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

/-- Source-derived, not an oracle: the independent sampled
shifted Hilbert first moment is bounded by the actual unconditioned
mean section norm, with no extra singleton triangle penalty. -/
theorem original_owned_shifted_first_norm_le_source_section
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (c : ι → ℝ) (i : ι) :
    let J := ownedNeighbors c i
    let j := neighborIndex i J
    let Y := finitePairIncrement p f i j J.card
    let H : α → ℝ := fun a =>
      Real.sqrt (p i a) *
        (∑ y : ι → α, originalMass p y *
          sourceCenteredSection p f i y a)
    (∑ w : Samples α J.card,
      mass (fun k => p (j k)) J.card w *
        Real.sqrt (vecNormSq (fun a =>
          H a + sumVector Y J.card w a))) ≤
      sourceMeanSectionNorm p f i := by
  classical
  dsimp
  let J : Finset ι := ownedNeighbors c i
  let j : ℕ → ι := neighborIndex i J
  let Y := finitePairIncrement p f i j J.card
  let H : α → ℝ := fun a =>
    Real.sqrt (p i a) *
      (∑ y : ι → α, originalMass p y *
        sourceCenteredSection p f i y a)
  have hcomponent (x : ι → α) (a : α) :
      H a + sumVector Y J.card (observedActualSample j J.card x) a =
        Real.sqrt (p i a) * averageSourceSection p f i J x a := by
    rw [original_source_finitePair_observed_sum p f i j J.card x a]
    have hpairs := original_owned_pair_sum_eq_source_conditional_difference
      p hp1 f hdegree c i x a
    change (∑ k ∈ Finset.range J.card,
        sourceDoubleCenteredPair p f i (j k) a (x (j k))) =
      averageSourceSection p f i J x a -
        ∑ y : ι → α, originalMass p y *
          sourceCenteredSection p f i y a at hpairs
    rw [hpairs]
    dsimp [H]
    ring
  have hnorm (x : ι → α) :
      vecNormSq (fun a =>
        H a + sumVector Y J.card
          (observedActualSample j J.card x) a) =
        ∑ a : α, p i a * (averageSourceSection p f i J x a)^2 := by
    unfold vecNormSq
    apply Finset.sum_congr rfl
    intro a _
    rw [hcomponent x a, mul_pow, Real.sq_sqrt (hp i a)]
  have hxnorm :
      (∑ x : ι → α, originalMass p x *
        Real.sqrt (vecNormSq (fun a =>
          H a + sumVector Y J.card
            (observedActualSample j J.card x) a))) =
      meanProjectedSourceNorm p f i J := by
    unfold meanProjectedSourceNorm projectedSourceNorm
    apply Finset.sum_congr rfl
    intro x _
    rw [hnorm x]
  have hinj :
      ∀ k l, k < J.card → l < J.card → k ≠ l →
        j k ≠ j l := by
    intro k l hk hl hne
    exact neighborIndex_injective_on_prefix i J k l hk hl hne
  have hlaw :
      (∑ x : ι → α, originalMass p x *
        Real.sqrt (vecNormSq (fun a =>
          H a + sumVector Y J.card
            (observedActualSample j J.card x) a))) =
      ∑ w : Samples α J.card,
        mass (fun k => p (j k)) J.card w *
          Real.sqrt (vecNormSq (fun a =>
            H a + sumVector Y J.card w a)) :=
    original_source_distinct_prefix_law p hp1 j J.card hinj
      (fun w : Samples α J.card =>
        Real.sqrt (vecNormSq (fun a =>
          H a + sumVector Y J.card w a)))
  calc
    (∑ w : Samples α J.card,
      mass (fun k => p (j k)) J.card w *
        Real.sqrt (vecNormSq (fun a =>
          H a + sumVector Y J.card w a))) =
      ∑ x : ι → α, originalMass p x *
        Real.sqrt (vecNormSq (fun a =>
          H a + sumVector Y J.card
            (observedActualSample j J.card x) a)) := hlaw.symm
    _ = meanProjectedSourceNorm p f i J := hxnorm
    _ ≤ sourceMeanSectionNorm p f i :=
      mean_projected_source_norm_le_unprojected p hp hp1 f i J

end Nightfall.Observability.ActualSourceShiftedJensen

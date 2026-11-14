import ActualSourceOwnedSectionNorm
import ActualSourceProjectedPairJensen

/-!
# True original-source owner projection = independent-neighbor Hilbert moment

This is the no-surrogate composition of:
(1) the finite, distinct, greedily owned actual source-neighbor sample law,
(2) the canonical degree-two conditional Efron–Stein projection,
(3) genuine source-weighted Jensen and singleton subtraction.

The owned moment second energy is bounded by actual source influence.
Its first norm is bounded by the *same original source* 8B section
budget plus its Jensen singleton norm. No pair norm, energy, amplitude,
conditional projection or external variance inequality is a premise.
-/

namespace Nightfall.Observability.ActualSourceOwnedProjectedMomentJensen

open Finset
open Nightfall.Observability.ActualESGreedyOwnership
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualSourceInfluenceEnergy
open Nightfall.Observability.ActualSourceConditionalSection
open Nightfall.Observability.ActualSourceMeanSectionJensen
open Nightfall.Observability.ActualSourceProjectedPairJensen
open Nightfall.Observability.ActualSourceQuadraticSupportSum
open Nightfall.Observability.ActualSourceOwnedMomentEnergy
open Nightfall.Observability.ActualSourceOwnedSectionNorm
open Nightfall.Observability.ActualSourceOwnedGraph
open Nightfall.Observability.ActualSourceFiniteSampleLaw
open Nightfall.Observability.ActualSourceFinitePairMoment
open Nightfall.Observability.ActualSourceIntegratedSections
open Nightfall.Observability.ActualSourceSingletonProjection
open Nightfall.Observability.ActualProductSourceDerivedStar
open Nightfall.Observability.ActualProductSourcePairCentering
open Nightfall.Observability.QuadraticHilbertMany
open Nightfall.Observability.QuadraticHilbertMoments

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

/-- A greedy owner cannot simultaneously appear in its own
source-derived distinct-neighbor set. -/
theorem original_owner_not_in_neighbors
    (c : ι → ℝ) (i : ι) :
    i ∉ ownedNeighbors c i := by
  classical
  intro ht
  unfold ownedNeighbors at ht
  obtain ⟨e, he, heq⟩ := Finset.mem_image.mp ht
  have hne := owned_neighbor_ne_owner edgeFirst edgeSecond c
    (Finset.univ : Finset (Edge ι))
    (fun e _ => edgeFirst_ne_edgeSecond e) i e he
  exact hne heq.symm

/-- POINTWISE matched-source projection: the real independently
enumerated neighbor pair sum equals the genuine conditional
centered source section minus its actual singleton mean. -/
theorem original_owned_pair_sum_eq_source_conditional_difference
    (p : ι → α → ℝ)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (c : ι → ℝ) (i : ι) (x : ι → α) (a : α) :
    let J := ownedNeighbors c i
    let j := neighborIndex i J
    (∑ k ∈ Finset.range J.card,
      sourceDoubleCenteredPair p f i (j k) a (x (j k))) =
    averageSourceSection p f i J x a -
      ∑ y : ι → α, originalMass p y *
        sourceCenteredSection p f i y a := by
  classical
  dsimp
  let J : Finset ι := ownedNeighbors c i
  let j : ℕ → ι := neighborIndex i J
  have hJ : i ∉ J := original_owner_not_in_neighbors c i
  have hrep :=
    source_degree_two_projected_section_eq_singleton_add_pairs
      p hp1 f hdegree i J hJ x a
  have hmean :
      sourceCenteredSingleton p f i a =
      ∑ y : ι → α, originalMass p y *
        sourceCenteredSection p f i y a := by
    simpa only [originalSourceSection, sourceCenteredSection] using
      (actual_source_singleton_eq_mean_section p hp1 f i a)
  have hsum :
      (∑ k ∈ Finset.range J.card,
        sourceDoubleCenteredPair p f i (j k) a (x (j k))) =
      ∑ t ∈ J, sourceDoubleCenteredPair p f i t a (x t) :=
    actual_neighbor_range_sum_eq_neighbor_finset i J
      (fun t => sourceDoubleCenteredPair p f i t a (x t))
  calc
    (∑ k ∈ Finset.range J.card,
      sourceDoubleCenteredPair p f i (j k) a (x (j k))) =
        ∑ t ∈ J, sourceDoubleCenteredPair p f i t a (x t) := hsum
    _ = averageSourceSection p f i J x a -
        ∑ y : ι → α, originalMass p y *
          sourceCenteredSection p f i y a := by
        rw [hrep, ← hmean]
        ring

/-- Exact equality of original-source observed pair Hilbert
first norm and the genuine projected-section-minus-singleton norm. -/
theorem original_observed_pair_norm_eq_projected_norm
    (p : ι → α → ℝ)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (c : ι → ℝ) (i : ι) :
    let J := ownedNeighbors c i
    let j := neighborIndex i J
    (∑ x : ι → α, originalMass p x *
      Real.sqrt (∑ a : α, p i a *
        (∑ k ∈ Finset.range J.card,
          sourceDoubleCenteredPair p f i (j k) a (x (j k)))^2)) =
      meanProjectedPairNorm p f i J := by
  classical
  dsimp
  unfold meanProjectedPairNorm
  apply Finset.sum_congr rfl
  intro x _
  apply congrArg (fun t : ℝ => originalMass p x * t)
  unfold projectedPairNorm
  unfold Nightfall.Observability.ActualSourceMeanSectionJensen.norm
    Nightfall.Observability.ActualSourceMeanSectionJensen.sqNorm
  congr 1
  apply Finset.sum_congr rfl
  intro a _
  rw [original_owned_pair_sum_eq_source_conditional_difference
    p hp1 f hdegree c i x a]

/-- Equality of independent recursively sampled first Hilbert moment
and original-law projected pair-section first moment, with no
independence oracle or added source distribution hypothesis. -/
theorem original_owned_independent_first_norm_eq_projected
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (c : ι → ℝ) (i : ι) :
    let J := ownedNeighbors c i
    let j := neighborIndex i J
    let Y := finitePairIncrement p f i j J.card
    (∑ w : Samples α J.card, mass (fun k => p (j k)) J.card w *
       Real.sqrt (vecNormSq (sumVector Y J.card w))) =
      meanProjectedPairNorm p f i J := by
  classical
  dsimp
  let J : Finset ι := ownedNeighbors c i
  let j : ℕ → ι := neighborIndex i J
  let Y := finitePairIncrement p f i j J.card
  have hlaw :
      (∑ x : ι → α, originalMass p x *
        Real.sqrt (vecNormSq
          (sumVector Y J.card (observedActualSample j J.card x)))) =
      ∑ w : Samples α J.card, mass (fun k => p (j k)) J.card w *
        Real.sqrt (vecNormSq (sumVector Y J.card w)) :=
    (actual_owned_neighbor_first_and_second_moments p hp hp1 f c i).1
  calc
    (∑ w : Samples α J.card, mass (fun k => p (j k)) J.card w *
      Real.sqrt (vecNormSq (sumVector Y J.card w))) =
      ∑ x : ι → α, originalMass p x *
        Real.sqrt (vecNormSq
          (sumVector Y J.card (observedActualSample j J.card x))) :=
      hlaw.symm
    _ = ∑ x : ι → α, originalMass p x *
      Real.sqrt (∑ a : α, p i a *
        (∑ k ∈ Finset.range J.card,
          sourceDoubleCenteredPair p f i (j k) a (x (j k)))^2) :=
      original_source_finitePair_first_norm_is_actual_section p hp f i j J.card
    _ = meanProjectedPairNorm p f i J :=
      original_observed_pair_norm_eq_projected_norm p hp1 f hdegree c i

/-- Source-only endpoint: both the exact second-moment energy and the
first-moment Jensen budget of the SAME actual owned-neighbor Hilbert
construction. The degree and original marginals are the only
probabilistic input. -/
theorem actual_owned_moment_and_projected_jensen
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (c : ι → ℝ) (i : ι) :
    let J := ownedNeighbors c i
    let j := neighborIndex i J
    let Y := finitePairIncrement p f i j J.card
    (moment2 (fun k => p (j k)) Y J.card ≤ sourceInfluence p f i) ∧
    ((∑ w : Samples α J.card,
       mass (fun k => p (j k)) J.card w *
         Real.sqrt (vecNormSq (sumVector Y J.card w))) ≤
      sourceMeanSectionNorm p f i + originalSingletonNorm p f i) := by
  classical
  dsimp
  constructor
  · exact original_owned_neighbor_moment2_le_influence p hp hp1 f c i
  · calc
      (∑ w : Samples α (ownedNeighbors c i).card,
        mass (fun k => p (neighborIndex i (ownedNeighbors c i) k))
          (ownedNeighbors c i).card w *
          Real.sqrt (vecNormSq (sumVector
            (finitePairIncrement p f i
              (neighborIndex i (ownedNeighbors c i))
              (ownedNeighbors c i).card)
              (ownedNeighbors c i).card w))) =
        meanProjectedPairNorm p f i (ownedNeighbors c i) :=
          original_owned_independent_first_norm_eq_projected
            p hp hp1 f hdegree c i
      _ ≤ sourceMeanSectionNorm p f i +
        originalSingletonNorm p f i :=
          source_projected_pair_jensen_budget
            p hp hp1 f i (ownedNeighbors c i)

/-- Integrated 16B source budget for actual greedily owned
independent-neighbor Hilbert first norms, no supplied owner estimate. -/
theorem actual_owned_first_norm_sum_le_sixteen
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (B : ℝ) (hB : 0 ≤ B) (hf : ∀ x, |f x| ≤ B)
    (c : ι → ℝ) :
    (∑ i : ι,
      let J := ownedNeighbors c i
      let j := neighborIndex i J
      let Y := finitePairIncrement p f i j J.card
      ∑ w : Samples α J.card, mass (fun k => p (j k)) J.card w *
         Real.sqrt (vecNormSq (sumVector Y J.card w))) ≤ 16 * B := by
  classical
  have hu := actual_source_integrated_eight_budget
    p hp hp1 f hdegree B hB hf
  have ha := original_singleton_norm_sum_le_eight
    p hp hp1 f hdegree B hB hf
  calc
    (∑ i : ι,
      let J := ownedNeighbors c i
      let j := neighborIndex i J
      let Y := finitePairIncrement p f i j J.card
      ∑ w : Samples α J.card, mass (fun k => p (j k)) J.card w *
        Real.sqrt (vecNormSq (sumVector Y J.card w))) ≤
      ∑ i : ι, (sourceMeanSectionNorm p f i +
        originalSingletonNorm p f i) := by
          apply Finset.sum_le_sum
          intro i _
          exact (actual_owned_moment_and_projected_jensen
            p hp hp1 f hdegree c i).2
    _ = (∑ i : ι, sourceMeanSectionNorm p f i) +
      (∑ i : ι, originalSingletonNorm p f i) :=
        Finset.sum_add_distrib
    _ ≤ 16 * B := by linarith

/-- Source-generated greedy ownership, actual Hilbert second moment,
original-law ANOVA projection, and Jensen bound in a SINGLE proposition.
No owner c, energy cap, pair-section norm, matching cost, or
independent-sampling premise is passed by the caller. -/
theorem source_generated_owned_moment_projection_jensen
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (B : ℝ) (hB : 0 ≤ B) (hf : ∀ x, |f x| ≤ B) :
    ∃ c : ι → ℝ,
      (∀ i, 0 ≤ c i) ∧
      (∑ i : ι, c i) ≤ 8 * B ∧
      (∀ i : ι,
        let J := ownedNeighbors c i
        let j := neighborIndex i J
        let Y := finitePairIncrement p f i j J.card
        (moment2 (fun k => p (j k)) Y J.card ≤ sourceInfluence p f i) ∧
        ((∑ w : Samples α J.card,
          mass (fun k => p (j k)) J.card w *
            Real.sqrt (vecNormSq (sumVector Y J.card w))) ≤
          sourceMeanSectionNorm p f i +
            originalSingletonNorm p f i)) ∧
      (∑ i : ι,
        let J := ownedNeighbors c i
        let j := neighborIndex i J
        let Y := finitePairIncrement p f i j J.card
        ∑ w : Samples α J.card, mass (fun k => p (j k)) J.card w *
          Real.sqrt (vecNormSq (sumVector Y J.card w))) ≤ 16 * B := by
  classical
  let base : ι → α := fun _ => Classical.choice (inferInstance : Nonempty α)
  obtain ⟨c, hc, hcost, _, _, _, _, _⟩ :=
    actual_source_greedy_graph_hilbert_package
      p hp hp1 f hdegree base B hf
  refine ⟨c, hc, hcost, ?_, ?_⟩
  · intro i
    exact actual_owned_moment_and_projected_jensen
      p hp hp1 f hdegree c i
  · exact actual_owned_first_norm_sum_le_sixteen
      p hp hp1 f hdegree B hB hf c

end Nightfall.Observability.ActualSourceOwnedProjectedMomentJensen

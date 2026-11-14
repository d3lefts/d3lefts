import ActualSourceOwnedProjectedMomentJensen
import ActualSourceOwnerOrientation

/-!
# Fourth-moment closure at actual greedily owned source coordinates

All kernel amplitudes, neighbor labels, independent sampled moments,
and coordinate influence caps come from the SAME original product p
and source function f. No supplied fourth-moment, energy, or
independence-oracle hypotheses. Any c in the first theorem is an
actual greedy endpoint-cover with its source proof; the terminal
second theorem constructs c directly from p and f.
-/

namespace Nightfall.Observability.ActualSourceOwnedFourthClosure

open Finset
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualSourceInfluenceEnergy
open Nightfall.Observability.ActualSourceMeanSectionJensen
open Nightfall.Observability.ActualSourceIntegratedSections
open Nightfall.Observability.ActualSourceOwnedGraph
open Nightfall.Observability.ActualESGreedyOwnership
open Nightfall.Observability.ActualSourceOwnerOrientation
open Nightfall.Observability.ActualSourceFinitePairMoment
open Nightfall.Observability.ActualSourceOwnedMomentEnergy
open Nightfall.Observability.ActualSourceOwnedProjectedMomentJensen
open Nightfall.Observability.ActualProductSourcePairCentering
open Nightfall.Observability.QuadraticHilbertMany
open Nightfall.Observability.QuadraticHilbertMoments

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

/-- Original-source greedy cover controls the ACTUAL owner-oriented
Hilbert pair kernel at each finite distinct-neighbor sample. -/
theorem actual_owned_neighbor_kernel_amplitude
    (p : ι → α → ℝ)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ) (c : ι → ℝ)
    (hcover : ∀ e : Edge ι, ∀ a b : α,
      |sourceDoubleCenteredPair p f (edgeFirst e) (edgeSecond e) a b| ≤
        c (owner edgeFirst edgeSecond c e))
    (i : ι) (k : ℕ)
    (hk : k < (ownedNeighbors c i).card)
    (a b : α) :
    |sourceDoubleCenteredPair p f i
      (neighborIndex i (ownedNeighbors c i) k) a b| ≤ c i := by
  classical
  let J : Finset ι := ownedNeighbors c i
  let j : ℕ → ι := neighborIndex i J
  have ht : j k ∈ J := neighborIndex_mem i J k hk
  change j k ∈ ownedNeighbors c i at ht
  unfold ownedNeighbors at ht
  obtain ⟨e, he, heq⟩ := Finset.mem_image.mp ht
  have heowner : owner edgeFirst edgeSecond c e = i :=
    (Finset.mem_filter.mp he).2
  have horient := owned_original_pair_amplitude_orientation
    p hp1 f c e (hcover e)
  have h := horient a b
  rw [heowner] at h
  change |sourceDoubleCenteredPair p f i (j k) a b| ≤ c i
  exact heq ▸ h

/-- Genuine owned-coordinate pair moment fourth closure.
The moment energy cap is derived from actual source influence. -/
theorem actual_owned_fourth_from_source_influence
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (c : ι → ℝ)
    (hc : ∀ i, 0 ≤ c i)
    (hcover : ∀ e : Edge ι, ∀ a b : α,
      |sourceDoubleCenteredPair p f (edgeFirst e) (edgeSecond e) a b| ≤
        c (owner edgeFirst edgeSecond c e))
    (i : ι) (M : ℝ)
    (hM : sourceInfluence p f i ≤ M) :
    let J := ownedNeighbors c i
    let j := neighborIndex i J
    let Y := finitePairIncrement p f i j J.card
    moment2 (fun k => p (j k)) Y J.card ≤
      (∑ w : Samples α J.card,
        mass (fun k => p (j k)) J.card w *
          Real.sqrt (vecNormSq (sumVector Y J.card w))) *
            (c i + Real.sqrt (3 * M)) := by
  classical
  dsimp
  let J : Finset ι := ownedNeighbors c i
  let j : ℕ → ι := neighborIndex i J
  have hne : ∀ k, k < J.card → i ≠ j k := by
    intro k hk heq
    apply (original_owner_not_in_neighbors c i)
    rw [heq]
    exact neighborIndex_mem i J k hk
  have hkernel : ∀ k, k < J.card → ∀ a b,
      |sourceDoubleCenteredPair p f i (j k) a b| ≤ c i := by
    intro k hk a b
    exact actual_owned_neighbor_kernel_amplitude
      p hp1 f c hcover i k hk a b
  have hmoment :
      moment2 (fun k => p (j k))
        (finitePairIncrement p f i j J.card) J.card ≤ M :=
    (original_owned_neighbor_moment2_le_influence p hp hp1 f c i).trans hM
  exact finitePairIncrement_fourth_endpoint
    p hp hp1 f i j J.card (c i) M hne (hc i) hkernel hmoment

/-- No supplied greedy owner, second-moment, or fourth-moment
hypothesis: source-generated amplitudes and the actual influence
bound produce a whole-family sharp fourth-moment endpoint. -/
theorem original_source_generated_fourth_and_jensen_package
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (B : ℝ) (hB : 0 ≤ B) (hf : ∀ x, |f x| ≤ B)
    (M : ℝ) (hM : ∀ i, sourceInfluence p f i ≤ M) :
    ∃ c : ι → ℝ,
      (∀ i, 0 ≤ c i) ∧
      (∑ i : ι, c i) ≤ 8 * B ∧
      (∀ i : ι,
        let J := ownedNeighbors c i
        let j := neighborIndex i J
        let Y := finitePairIncrement p f i j J.card
        (moment2 (fun k => p (j k)) Y J.card ≤
          sourceInfluence p f i) ∧
        (moment2 (fun k => p (j k)) Y J.card ≤
          (∑ w : Samples α J.card,
            mass (fun k => p (j k)) J.card w *
              Real.sqrt (vecNormSq (sumVector Y J.card w))) *
                (c i + Real.sqrt (3 * M))) ∧
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
  obtain ⟨c, hc, hcost, hcover, _, _, _, _⟩ :=
    actual_source_greedy_graph_hilbert_package
      p hp hp1 f hdegree base B hf
  refine ⟨c, hc, hcost, ?_, ?_⟩
  · intro i
    obtain ⟨henergy, hjensen⟩ :=
      actual_owned_moment_and_projected_jensen
        p hp hp1 f hdegree c i
    exact ⟨henergy, actual_owned_fourth_from_source_influence
      p hp hp1 f c hc hcover i M (hM i), hjensen⟩
  · exact actual_owned_first_norm_sum_le_sixteen
      p hp hp1 f hdegree B hB hf c

end Nightfall.Observability.ActualSourceOwnedFourthClosure

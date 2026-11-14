import ActualESGreedyOwnership
import ActualSourceMatchingCover
import ActualSourcePairAmplitudes
import ActualSourceFinitePairMoment
import ActualSourceFiniteSampleLaw

/-!
# True-source canonical pair graph and injective owned-neighbor moments

This is a current-pin, actual-source replacement for the legacy
ActualESCanonicalPairGraph + ActualESOwnedSampleLaw import chain.
No Turturean/AaronsonAmbainis bridge or synthetic site stream occurs.

All pair amplitudes, real-product sample laws, energy partitions and
finite Hilbert second moments are built from the SAME original f, p,
and one greedily selected c. It is not yet a terminal Q2 bound.
-/

namespace Nightfall.Observability.ActualSourceOwnedGraph

open Finset
open Nightfall.Observability.ActualESGreedyOwnership
open Nightfall.Observability.ActualSourceMatchingCover
open Nightfall.Observability.ActualSourcePairAmplitudes
open Nightfall.Observability.ActualSourceFinitePairMoment
open Nightfall.Observability.ActualSourceFiniteSampleLaw
open Nightfall.Observability.ActualProductSourcePairCentering
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.QuadraticHilbertMany
open Nightfall.Observability.QuadraticHilbertMoments

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

/-- Every original unordered pair appears once, without fake sites. -/
abbrev Edge (ι : Type) [DecidableEq ι] :=
  {S : Finset ι // S.card = 2}

noncomputable def endpoints (e : Edge ι) :
    {ab : ι × ι // ab.1 ≠ ab.2 ∧ e.1 = {ab.1, ab.2}} := by
  classical
  obtain ⟨i, j, hij, heq⟩ := Finset.card_eq_two.mp e.2
  exact ⟨(i,j), hij, heq⟩

noncomputable def edgeFirst (e : Edge ι) : ι :=
  (endpoints e).1.1
noncomputable def edgeSecond (e : Edge ι) : ι :=
  (endpoints e).1.2

theorem edgeFirst_ne_edgeSecond (e : Edge ι) :
    edgeFirst e ≠ edgeSecond e := (endpoints e).2.1

theorem edge_pair_eq_endpoints (e : Edge ι) :
    (e.1 : Finset ι) = {edgeFirst e, edgeSecond e} :=
  (endpoints e).2.2

theorem edge_simple (e d : Edge ι)
    (h : ({edgeFirst e, edgeSecond e} : Finset ι) =
       {edgeFirst d, edgeSecond d}) : e = d := by
  apply Subtype.ext
  calc
    (e.1 : Finset ι) = {edgeFirst e, edgeSecond e} :=
      edge_pair_eq_endpoints e
    _ = {edgeFirst d, edgeSecond d} := h
    _ = d.1 := (edge_pair_eq_endpoints d).symm

/-- The actual neighbors whose edges a source-greedy owner holds. -/
noncomputable def ownedNeighbors (c : ι → ℝ) (i : ι) : Finset ι :=
  (ownedEdges edgeFirst edgeSecond c
    (Finset.univ : Finset (Edge ι)) i).image
      (other edgeFirst edgeSecond c)

noncomputable def neighborIndex
    (i : ι) (J : Finset ι) (k : ℕ) : ι :=
  if hk : k < J.card then
    ((J.equivFin).symm ⟨k, hk⟩).1
  else i

theorem neighborIndex_mem
    (i : ι) (J : Finset ι)
    (k : ℕ) (hk : k < J.card) :
    neighborIndex i J k ∈ J := by
  simp only [neighborIndex, dif_pos hk]
  exact ((J.equivFin).symm ⟨k, hk⟩).2

theorem neighborIndex_injective_on_prefix
    (i : ι) (J : Finset ι)
    (k l : ℕ) (hk : k < J.card)
    (hl : l < J.card) (hkl : k ≠ l) :
    neighborIndex i J k ≠ neighborIndex i J l := by
  intro heq
  have hv :
      ((J.equivFin).symm ⟨k, hk⟩).1 =
      ((J.equivFin).symm ⟨l, hl⟩).1 := by
    simpa [neighborIndex, hk, hl] using heq
  have hs : (J.equivFin).symm ⟨k, hk⟩ =
      (J.equivFin).symm ⟨l, hl⟩ := Subtype.ext hv
  have hf := (J.equivFin).symm.injective hs
  exact hkl (congrArg Fin.val hf)

/-- The true-source sample law and Hilbert second moment are
automatically valid at any greedily owned original neighbor set;
zero-probability symbols remain legal. -/
theorem actual_owned_neighbor_first_and_second_moments
    (p : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (c : ι → ℝ) (i : ι) :
    let J := ownedNeighbors c i
    let j := neighborIndex i J
    let Y := finitePairIncrement p f i j J.card
    ((∑ x : ι → α, originalMass p x *
      Real.sqrt (vecNormSq
        (sumVector Y J.card (observedActualSample j J.card x)))) =
      ∑ w : Samples α J.card,
        mass (fun k => p (j k)) J.card w *
          Real.sqrt (vecNormSq (sumVector Y J.card w))) ∧
    (moment2 (fun k => p (j k)) Y J.card =
      ∑ k ∈ Finset.range J.card,
        sourcePairEnergy p f i (j k)) := by
  classical
  dsimp
  let J := ownedNeighbors c i
  let j := neighborIndex i J
  let Y := finitePairIncrement p f i j J.card
  have hsourceSimple : ∀ e : Edge ι, ∀ d : Edge ι,
      ({edgeFirst e, edgeSecond e} : Finset ι) =
      {edgeFirst d, edgeSecond d} → e = d :=
    fun e d h => edge_simple e d h
  have hinjOwner (t : ι) (ht : t ∈ J) : i ≠ t := by
    change t ∈ ownedNeighbors c i at ht
    unfold ownedNeighbors at ht
    obtain ⟨e, he, heq⟩ := Finset.mem_image.mp ht
    have hne := owned_neighbor_ne_owner
      edgeFirst edgeSecond c
      (Finset.univ : Finset (Edge ι))
      (fun e _ => edgeFirst_ne_edgeSecond e) i e he
    exact heq ▸ hne
  have hdistinctOwner (k : ℕ) (hk : k < J.card) :
      i ≠ j k :=
    hinjOwner (j k) (neighborIndex_mem i J k hk)
  have hdistinctNeighbor :
      ∀ k l, k < J.card → l < J.card → k ≠ l →
        j k ≠ j l :=
    fun k l hk hl hkl =>
      neighborIndex_injective_on_prefix i J k l hk hl hkl
  constructor
  · exact original_source_distinct_prefix_first_norm
      p hp1 j J.card hdistinctNeighbor Y
  · exact finitePairIncrement_moment2_eq_source_pair_energies
      p hp hp1 f i j J.card hdistinctOwner

/-- One cost c, one real source graph, one distinct owned-neighbor
enumeration, and one original-law Hilbert moment. No hcover or
moment/independence energy inputs are given by the caller. -/
theorem actual_source_greedy_graph_hilbert_package
    (p : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : Nightfall.Observability.ActualSourceANOVA.ESDegreeLE p f 2)
    (base : ι → α)
    (B : ℝ) (hf : ∀ x, |f x| ≤ B) :
    ∃ c : ι → ℝ,
      (∀ i, 0 ≤ c i) ∧
      (∑ i : ι, c i) ≤ 8 * B ∧
      (∀ e : Edge ι, ∀ a b : α,
        |sourceDoubleCenteredPair p f (edgeFirst e) (edgeSecond e) a b| ≤
          c (owner edgeFirst edgeSecond c e)) ∧
      (∀ i : ι,
        Set.InjOn (other edgeFirst edgeSecond c)
          (↑(ownedEdges edgeFirst edgeSecond c
            (Finset.univ : Finset (Edge ι)) i) : Set (Edge ι))) ∧
      (∀ i e, e ∈ ownedEdges edgeFirst edgeSecond c
         (Finset.univ : Finset (Edge ι)) i →
         i ≠ other edgeFirst edgeSecond c e) ∧
      ((∑ i : ι,
        (ownedEdges edgeFirst edgeSecond c
          (Finset.univ : Finset (Edge ι)) i).sum
          (fun e => sourcePairEnergy p f (edgeFirst e) (edgeSecond e))) =
        ∑ e : Edge ι,
          sourcePairEnergy p f (edgeFirst e) (edgeSecond e)) ∧
      (∀ i : ι,
         let J := ownedNeighbors c i
         let j := neighborIndex i J
         let Y := finitePairIncrement p f i j J.card
         ((∑ x : ι → α, originalMass p x *
           Real.sqrt (vecNormSq
             (sumVector Y J.card (observedActualSample j J.card x)))) =
           ∑ w : Samples α J.card, mass (fun k => p (j k)) J.card w *
             Real.sqrt (vecNormSq (sumVector Y J.card w))) ∧
         (moment2 (fun k => p (j k)) Y J.card =
           ∑ k ∈ Finset.range J.card,
             sourcePairEnergy p f i (j k)))) := by
  classical
  obtain ⟨c, hc, hcost, hcover⟩ :=
    source_greedy_attained_endpoint_cover
      p hp hp1 f hdegree base edgeFirst edgeSecond
      (Finset.univ : Finset (Edge ι))
      (fun e _ => edgeFirst_ne_edgeSecond e) B hf
  refine ⟨c, hc, hcost, ?_, ?_, ?_, ?_, ?_⟩
  · intro e a b
    exact (source_pair_amplitude_dominated
      p f (edgeFirst e) (edgeSecond e) a b).trans
        (owner_cost_dominates edgeFirst edgeSecond c e _
          (hcover e (Finset.mem_univ e)))
  · intro i
    exact other_injective_at_owner edgeFirst edgeSecond c
      (Finset.univ : Finset (Edge ι))
      (fun e _ d _ heq => edge_simple e d heq) i
  · intro i e he
    exact owned_neighbor_ne_owner edgeFirst edgeSecond c
      (Finset.univ : Finset (Edge ι))
      (fun e _ => edgeFirst_ne_edgeSecond e) i e he
  · exact owned_energy_partition edgeFirst edgeSecond c
      (Finset.univ : Finset (Edge ι))
      (fun e => sourcePairEnergy p f (edgeFirst e) (edgeSecond e))
  · intro i
    exact actual_owned_neighbor_first_and_second_moments
      p hp hp1 f c i

end Nightfall.Observability.ActualSourceOwnedGraph

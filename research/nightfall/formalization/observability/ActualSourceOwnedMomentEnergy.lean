import ActualSourceOwnedInfluence
import ActualSourceOwnerOrientation

/-!
# Original-source owned-neighbor second-moment cap

The finite Hilbert independent-neighbor second moment uses exactly
those original coordinate labels found in the greedy owned-edge graph.
No synthetic repeated-coordinate draw, supplied second moment, or
source-influence upper bound is needed for this comparison.
-/

namespace Nightfall.Observability.ActualSourceOwnedMomentEnergy

open Finset
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.ActualSourceOwnedGraph
open Nightfall.Observability.ActualSourceFinitePairMoment
open Nightfall.Observability.ActualSourceOwnerOrientation
open Nightfall.Observability.ActualSourceOwnedInfluence
open Nightfall.Observability.ActualSourceInfluenceEnergy
open Nightfall.Observability.ActualESGreedyOwnership
open Nightfall.Observability.QuadraticHilbertMany

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

/-- Finite enumeration lists every actual neighbor once. -/
theorem actual_neighbor_range_sum_eq_neighbor_finset
    (i : ι) (J : Finset ι) (g : ι → ℝ) :
    (∑ k ∈ Finset.range J.card, g (neighborIndex i J k)) =
      ∑ j ∈ J, g j := by
  classical
  let h : Fin J.card → ℝ := fun k => g (((J.equivFin).symm k).1)
  have hfinite :
      (∑ k ∈ Finset.range J.card, g (neighborIndex i J k)) =
      ∑ k : Fin J.card, h k := by
    simpa [h, neighborIndex] using
      (Fin.sum_univ_eq_sum_range
        (fun k : ℕ => g (neighborIndex i J k)) J.card).symm
  have heq :
      (∑ k : Fin J.card, h k) =
      ∑ j : J, g j.1 := by
    exact Fintype.sum_equiv (J.equivFin).symm h
      (fun j : J => g j.1) (fun k => rfl)
  calc
    (∑ k ∈ Finset.range J.card, g (neighborIndex i J k)) =
      ∑ k : Fin J.card, h k := hfinite
    _ = ∑ j : J, g j.1 := heq
    _ = ∑ j ∈ J, g j := by
      exact Finset.sum_attach J g

/-- The source-indexed second moment is exactly the original
greedy owner's sum of pair-sector energies. -/
theorem original_owned_neighbor_moment2_eq_owned_energy
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ) (c : ι → ℝ) (i : ι) :
    let J := ownedNeighbors c i
    let j := neighborIndex i J
    moment2 (fun k => p (j k)) (finitePairIncrement p f i j J.card) J.card =
      (ownedEdges edgeFirst edgeSecond c
         (Finset.univ : Finset (Edge ι)) i).sum
        (fun e => sourcePairEnergy p f (edgeFirst e) (edgeSecond e)) := by
  classical
  dsimp
  let F : Finset (Edge ι) :=
    ownedEdges edgeFirst edgeSecond c
      (Finset.univ : Finset (Edge ι)) i
  let J : Finset ι := ownedNeighbors c i
  let j : ℕ → ι := neighborIndex i J
  let otherSite := other edgeFirst edgeSecond c
  have hne : ∀ k, k < J.card → i ≠ j k := by
    intro k hk
    have ht : j k ∈ J := neighborIndex_mem i J k hk
    change j k ∈ ownedNeighbors c i at ht
    unfold ownedNeighbors at ht
    obtain ⟨e, he, heq⟩ := Finset.mem_image.mp ht
    have hi := owned_neighbor_ne_owner edgeFirst edgeSecond c
      (Finset.univ : Finset (Edge ι))
      (fun e _ => edgeFirst_ne_edgeSecond e) i e he
    exact heq ▸ hi
  have hsecond :
      moment2 (fun k => p (j k)) (finitePairIncrement p f i j J.card) J.card =
      ∑ k ∈ Finset.range J.card, sourcePairEnergy p f i (j k) :=
    finitePairIncrement_moment2_eq_source_pair_energies p hp hp1 f i j J.card hne
  have hsumNeighbors :
      (∑ k ∈ Finset.range J.card, sourcePairEnergy p f i (j k)) =
      ∑ n ∈ J, sourcePairEnergy p f i n :=
    actual_neighbor_range_sum_eq_neighbor_finset i J (sourcePairEnergy p f i)
  have hinj : Set.InjOn otherSite (↑F : Set (Edge ι)) := by
    exact other_injective_at_owner edgeFirst edgeSecond c
      (Finset.univ : Finset (Edge ι))
      (fun e _ d _ heq => edge_simple e d heq) i
  have hsumImage :
      (∑ n ∈ J, sourcePairEnergy p f i n) =
      F.sum (fun e => sourcePairEnergy p f i (otherSite e)) := by
    change ((F.image otherSite).sum (sourcePairEnergy p f i)) = _
    exact Finset.sum_image (s := F) (f := sourcePairEnergy p f i)
      (g := otherSite) (fun e he d hd heq => hinj he hd heq)
  have horient (e : Edge ι) (he : e ∈ F) :
      sourcePairEnergy p f i (otherSite e) =
        sourcePairEnergy p f (edgeFirst e) (edgeSecond e) := by
    have hi : owner edgeFirst edgeSecond c e = i :=
      (Finset.mem_filter.mp he).2
    have h := owned_original_pair_energy_orientation p hp1 f c e
    rw [hi] at h
    exact h.symm
  calc
    moment2 (fun k => p (j k)) (finitePairIncrement p f i j J.card) J.card =
      ∑ k ∈ Finset.range J.card, sourcePairEnergy p f i (j k) := hsecond
    _ = ∑ n ∈ J, sourcePairEnergy p f i n := hsumNeighbors
    _ = F.sum (fun e => sourcePairEnergy p f i (otherSite e)) := hsumImage
    _ = F.sum (fun e => sourcePairEnergy p f (edgeFirst e) (edgeSecond e)) := by
      apply Finset.sum_congr rfl
      intro e he
      exact horient e he

/-- A genuinely owned finite Hilbert moment is at most the
original-law coordinate influence, with no supplied moment cap. -/
theorem original_owned_neighbor_moment2_le_influence
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ) (c : ι → ℝ) (i : ι) :
    let J := ownedNeighbors c i
    let j := neighborIndex i J
    moment2 (fun k => p (j k)) (finitePairIncrement p f i j J.card) J.card ≤
      sourceInfluence p f i := by
  classical
  dsimp
  calc
    moment2
      (fun k => p (neighborIndex i (ownedNeighbors c i) k))
      (finitePairIncrement p f i (neighborIndex i (ownedNeighbors c i))
        (ownedNeighbors c i).card) (ownedNeighbors c i).card =
      (ownedEdges edgeFirst edgeSecond c
         (Finset.univ : Finset (Edge ι)) i).sum
        (fun e => sourcePairEnergy p f (edgeFirst e) (edgeSecond e)) :=
      original_owned_neighbor_moment2_eq_owned_energy p hp hp1 f c i
    _ ≤ sourceInfluence p f i :=
      actual_owned_source_pair_energy_le_influence p hp hp1 f c i

end Nightfall.Observability.ActualSourceOwnedMomentEnergy

import ActualESFiniteNeighborMoment
import ActualESOwnedNeighborEnumeration
import ActualESPairOrientation
import ActualESOwnedSectionCap

/-!
# The finite owned-neighbor Hilbert moment IS the original source energy

Each actual greedy-owned neighbor occurs once in the finite enumeration.
The independent Hilbert moment's exact second moment is the sum of
pair energies on those original coordinates. The enumeration is a
bijection with the owned source edges; orientation is removed using
the canonical Efron–Stein pair symmetries. Hence moment2 equals the
original conditional-section energy, not a synthetic surrogate.

Finally its energy cap is DERIVED from the actual original influence
pinfl(p,f,i). There is no hM energy parameter supplied to that cap.

On strict compilation, this composes the previously independent
Hilbert fourth-moment endpoint with the source's real energy budget.
-/

namespace Nightfall.Observability.ActualESOwnedMomentEnergy

open Finset
open Nightfall.ProductSpace.EfronStein
open Nightfall.ProductSpace.Influence
open Nightfall.Observability.ActualESGreedyOwnership
open Nightfall.Observability.ActualESCanonicalPairGraph
open Nightfall.Observability.ActualESOwnedNeighborEnumeration
open Nightfall.Observability.ActualESOwnedEnergy
open Nightfall.Observability.ActualESFiniteNeighborMoment
open Nightfall.Observability.ActualESPairOrientation
open Nightfall.Observability.ActualESOwnedSectionCap
open Nightfall.Observability.ActualESOwnedSectionEnergy
open Nightfall.Observability.QuadraticHilbertMany

variable {ι α : Type}
  [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

/-- The actual finite enumeration's pair-energy sum equals the
literal greedy-owned source interaction energy, with no omitted
or repeated pair. -/
theorem owned_neighbor_energy_sum_eq_original
    (p : ι → α → ℝ)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (base : ι → α)
    (c : ι → ℝ) (i : ι) :
    (∑ k ∈ Finset.range (Fintype.card (OwnedEdge c i)),
      sourcePairEnergy p f base i (ownedNeighborIndex c i k)) =
      ownedSourceEnergy p f base first second c
        (Finset.univ : Finset (Edge ι)) i := by
  classical
  let S : Finset (Edge ι) :=
    ownedEdges first second c (Finset.univ : Finset (Edge ι)) i
  let n := Fintype.card (OwnedEdge c i)
  let H : OwnedEdge c i → ℝ := fun e =>
    sourcePairEnergy p f base (first e.1) (second e.1)
  have hFinite :
      (∑ k ∈ Finset.range n,
        sourcePairEnergy p f base i (ownedNeighborIndex c i k)) =
      ∑ k : Fin n,
        sourcePairEnergy p f base i (ownedNeighbor c i k) := by
    simpa only [n, ownedNeighborIndex,
      dif_pos, Fin.sum_univ_eq_sum_range] using
      (Fin.sum_univ_eq_sum_range
        (fun k : Fin n =>
          sourcePairEnergy p f base i (ownedNeighbor c i k))).symm
  have hOrient (k : Fin n) :
      sourcePairEnergy p f base i (ownedNeighbor c i k) =
      H (ownedEdgeAt c i k) := by
    let e := (ownedEdgeAt c i k).1
    have he : e ∈ S := (ownedEdgeAt c i k).2
    have howner : owner first second c e = i :=
      (Finset.mem_filter.mp he).2
    have heq := actual_owned_edge_energy_eq_owner_neighbor
      p hp1 f base c e
    rw [howner] at heq
    exact heq.symm
  have hEnum :
      (∑ k : Fin n, H (ownedEdgeAt c i k)) =
        ∑ e : OwnedEdge c i, H e := by
    exact Fintype.sum_equiv
      (Fintype.equivFin (OwnedEdge c i)).symm
      (fun k : Fin n => H (ownedEdgeAt c i k))
      H (fun k => rfl)
  have hAttach :
      (∑ e : OwnedEdge c i, H e) =
        S.sum (fun e => sourcePairEnergy p f base (first e) (second e)) := by
    simpa only [S, H, OwnedEdge] using
      (Finset.sum_attach S
        (fun e : Edge ι =>
          sourcePairEnergy p f base (first e) (second e)))
  calc
    (∑ k ∈ Finset.range (Fintype.card (OwnedEdge c i)),
      sourcePairEnergy p f base i (ownedNeighborIndex c i k)) =
        ∑ k : Fin n,
          sourcePairEnergy p f base i (ownedNeighbor c i k) := hFinite
    _ = ∑ k : Fin n, H (ownedEdgeAt c i k) := by
      apply Finset.sum_congr rfl
      intro k _
      exact hOrient k
    _ = ∑ e : OwnedEdge c i, H e := hEnum
    _ = S.sum (fun e => sourcePairEnergy p f base (first e) (second e)) := hAttach
    _ = ownedSourceEnergy p f base first second c
      (Finset.univ : Finset (Edge ι)) i := rfl

/-- Derived moment2-to-original-source SECTION energy identity. -/
theorem actual_owned_neighbor_moment2_eq_conditional_source_energy
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ) (base : ι → α)
    (c : ι → ℝ) (i : ι) :
    moment2 (fun k => p (ownedNeighborIndex c i k))
      (finitePairIncrement p f base i
        (ownedNeighborIndex c i) (Fintype.card (OwnedEdge c i)))
      (Fintype.card (OwnedEdge c i)) =
      actualOwnedSectionEnergy p f c i := by
  let n := Fintype.card (OwnedEdge c i)
  let j := ownedNeighborIndex c i
  have hne : ∀ k, k < n → i ≠ j k := by
    intro k hk
    exact ownedNeighborIndex_ne_owner c i k hk
  calc
    moment2 (fun k => p (j k))
      (finitePairIncrement p f base i j n) n =
      (∑ k ∈ Finset.range n, sourcePairEnergy p f base i (j k)) :=
      finitePairIncrement_moment2_eq_source_pair_energies
        p hp hp1 f base i j n hne
    _ = ownedSourceEnergy p f base first second c
      (Finset.univ : Finset (Edge ι)) i :=
      owned_neighbor_energy_sum_eq_original p hp1 f base c i
    _ = actualOwnedSectionEnergy p f c i :=
      (actual_owned_section_energy_eq_source_pair_energy
        p hp1 f base c i).symm

/-- The moment energy cap is derived from original actual source
coordinate influence, not a fourth-moment hM hypothesis. -/
theorem actual_owned_neighbor_moment2_le_actual_influence
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (base : ι → α)
    (c : ι → ℝ) (i : ι) :
    moment2 (fun k => p (ownedNeighborIndex c i k))
      (finitePairIncrement p f base i
        (ownedNeighborIndex c i) (Fintype.card (OwnedEdge c i)))
      (Fintype.card (OwnedEdge c i)) ≤ pinfl p f i := by
  rw [actual_owned_neighbor_moment2_eq_conditional_source_energy
    p hp hp1 f base c i]
  exact actual_owned_section_energy_le_source_influence
    p hp hp1 f hdegree base c i

end Nightfall.Observability.ActualESOwnedMomentEnergy

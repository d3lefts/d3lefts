import ActualESCanonicalPairGraph
import ActualESGreedyOwnership

/-!
# Exact finite enumeration of distinct ORIGINAL owned neighbors

The greedy owner map and simple canonical interaction graph generate
a finite subset of actual source pairs. We enumerate that finite
subtype by Fin n. Every listed neighbor is different from the owner;
different enumeration positions designate different original source
coordinates. The total natural-number index is padded by the owner
outside the finite range, and *only* the first n indices are declared
actual neighbors.

No distinct-neighbor hypothesis, arbitrary neighbor map, source energy,
Hilbert moment, or desired influence estimate is passed as an axiom.
-/

namespace Nightfall.Observability.ActualESOwnedNeighborEnumeration

open Finset
open Nightfall.Observability.ActualESGreedyOwnership
open Nightfall.Observability.ActualESCanonicalPairGraph

variable {ι : Type} [Fintype ι] [DecidableEq ι]

/-- Finite type of the canonically indexed edges actually owned by i. -/
abbrev OwnedEdge (c : ι → ℝ) (i : ι) :=
  {e : Edge ι // e ∈
    ownedEdges first second c
      (Finset.univ : Finset (Edge ι)) i}

/-- Enumerate owned original-source edges with a finite exact index. -/
noncomputable def ownedEdgeAt (c : ι → ℝ) (i : ι)
    (k : Fin (Fintype.card (OwnedEdge c i))) : OwnedEdge c i :=
  (Fintype.equivFin (OwnedEdge c i)).symm k

/-- The genuine neighbor of i across each owned edge, with no
replacement or independent-copy coordinate. -/
noncomputable def ownedNeighbor (c : ι → ℝ) (i : ι)
    (k : Fin (Fintype.card (OwnedEdge c i))) : ι :=
  other first second c (ownedEdgeAt c i k).1

theorem ownedNeighbor_ne_owner
    (c : ι → ℝ) (i : ι)
    (k : Fin (Fintype.card (OwnedEdge c i))) :
    i ≠ ownedNeighbor c i k := by
  unfold ownedNeighbor
  exact owned_neighbor_ne_owner first second c
    (Finset.univ : Finset (Edge ι))
    (fun e _ => first_ne_second e)
    i (ownedEdgeAt c i k).1 (ownedEdgeAt c i k).2

/-- Injectivity is derived from the unique two-element source edge,
and the generated one-owner partition. -/
theorem ownedNeighbor_injective
    (c : ι → ℝ) (i : ι) :
    Function.Injective (ownedNeighbor c i) := by
  classical
  have hSimple :
      ∀ e ∈ (Finset.univ : Finset (Edge ι)),
      ∀ d ∈ (Finset.univ : Finset (Edge ι)),
      ({first e, second e} : Finset ι) =
        {first d, second d} → e = d := by
    intro e _ d _ h
    exact canonical_pair_simple e d h
  have hinj := other_injective_at_owner
    first second c (Finset.univ : Finset (Edge ι)) hSimple i
  intro k l hkl
  have heq :
      (ownedEdgeAt c i k).1 = (ownedEdgeAt c i l).1 := by
    apply hinj
      (ownedEdgeAt c i k).2
      (ownedEdgeAt c i l).2
    exact hkl
  have hsub : ownedEdgeAt c i k = ownedEdgeAt c i l :=
    Subtype.ext heq
  exact (Fintype.equivFin (OwnedEdge c i)).symm.injective hsub

/-- Natural-number totalization for the existing recursive Hilbert
moment module. Out-of-range positions are synthetic zeros, never
claimed independent source sites. -/
noncomputable def ownedNeighborIndex
    (c : ι → ℝ) (i : ι) (k : ℕ) : ι :=
  if hk : k < Fintype.card (OwnedEdge c i) then
    ownedNeighbor c i ⟨k, hk⟩ else i

theorem ownedNeighborIndex_ne_owner
    (c : ι → ℝ) (i : ι) (k : ℕ)
    (hk : k < Fintype.card (OwnedEdge c i)) :
    i ≠ ownedNeighborIndex c i k := by
  simpa [ownedNeighborIndex, hk] using
    (ownedNeighbor_ne_owner c i (⟨k, hk⟩ : Fin (Fintype.card (OwnedEdge c i))))

theorem ownedNeighborIndex_injective_on_range
    (c : ι → ℝ) (i : ι) (k l : ℕ)
    (hk : k < Fintype.card (OwnedEdge c i))
    (hl : l < Fintype.card (OwnedEdge c i))
    (heq : ownedNeighborIndex c i k =
      ownedNeighborIndex c i l) :
    k = l := by
  have hFin : (⟨k, hk⟩ : Fin (Fintype.card (OwnedEdge c i))) =
      (⟨l, hl⟩ : Fin (Fintype.card (OwnedEdge c i))) := by
    apply ownedNeighbor_injective c i
    simpa [ownedNeighborIndex, hk, hl] using heq
  exact congrArg Fin.val hFin

end Nightfall.Observability.ActualESOwnedNeighborEnumeration

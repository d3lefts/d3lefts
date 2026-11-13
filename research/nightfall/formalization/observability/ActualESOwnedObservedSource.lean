import ActualESObservedSection
import ActualESOwnedNeighborEnumeration
import ActualESOwnedSectionEnergy

/-!
# Source-identical orientation of the owned-neighbor Hilbert section

This is the last *pointwise representation* interface between the
independent-sample fourth-moment machinery and the real finite product
source. A canonical edge is represented by an unordered two-coordinate
support; its greedy owner may be either chosen endpoint. The
source-derived pair kernel must therefore be oriented at the actual
owner before summing the distinct original neighbor coordinates.

All sums and weights are those of the source function f and original
product law p. No synthetic independent-copy assumption, source-energy
cap, final influence inequality, or new axiom is a hypothesis here.

STATUS: proof candidate; do not claim kernel certification without
a successful source-identical strict Lean receipt. In particular this
is not the terminal Q2 theorem.
-/

namespace Nightfall.Observability.ActualESOwnedObservedSource

open Finset
open Nightfall.ProductSpace.EfronStein
open Nightfall.ProductSpace.Influence
open Nightfall.ProductSpace.Transfer
open Nightfall.Observability.ActualESPairMatching
open Nightfall.Observability.ActualESGreedyOwnership
open Nightfall.Observability.ActualESCanonicalPairGraph
open Nightfall.Observability.ActualESOwnedNeighborEnumeration
open Nightfall.Observability.ActualESOwnedSectionEnergy
open Nightfall.Observability.ActualESFiniteSampleLaw
open Nightfall.Observability.ActualESObservedSection
open Nightfall.Observability.ActualESFiniteNeighborMoment
open Nightfall.Observability.QuadraticHilbertMany
open Nightfall.Observability.QuadraticHilbertMoments

variable {ι α : Type}
  [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

/-- Orientation is derived from the canonical two-element source edge.
This is equality of actual Hoeffding components at every source state,
not merely equality of energies or of expectations. -/
theorem actual_owned_edge_kernel_eq_component
    (p : ι → α → ℝ) (f : (ι → α) → ℝ)
    (base x : ι → α) (c : ι → ℝ)
    (i : ι) (e : Edge ι)
    (he : e ∈ ownedEdges first second c
      (Finset.univ : Finset (Edge ι)) i)
    (a : α) :
    actualPairKernel p f base i (other first second c e)
      a (x (other first second c e)) =
    esComp p e.1 f (Function.update x i a) := by
  classical
  have howner : owner first second c e = i :=
    (Finset.mem_filter.mp he).2
  have hpair : (e.1 : Finset ι) =
      {i, other first second c e} := by
    calc
      (e.1 : Finset ι) = {first e, second e} :=
        canonical_pair_eq_endpoints e
      _ = {owner first second c e, other first second c e} :=
        endpoints_eq_owner_other first second c e
      _ = {i, other first second c e} := by rw [howner]
  have hne : i ≠ other first second c e := by
    have h := owner_ne_other first second c e (first_ne_second e)
    rwa [howner] at h
  have hsource :=
    actual_pair_component_is_kernel p f base
      (Function.update x i a) i (other first second c e) hne
  have hval :
      (Function.update x i a) (other first second c e) =
        x (other first second c e) :=
    Function.update_of_ne hne.symm a x
  have hsource' :
      esComp p ({i, other first second c e} : Finset ι) f
        (Function.update x i a) =
      actualPairKernel p f base i (other first second c e)
        a (x (other first second c e)) := by
    simpa [hval] using hsource
  calc
    actualPairKernel p f base i (other first second c e)
        a (x (other first second c e)) =
      esComp p ({i, other first second c e} : Finset ι) f
        (Function.update x i a) := hsource'.symm
    _ = esComp p e.1 f (Function.update x i a) := by rw [hpair]

/-- The full finite source-observed recursive sum is precisely the
greedy-owned *actual* section, with every original edge used once. -/
theorem actual_owned_neighbor_kernel_sum_eq_section
    (p : ι → α → ℝ) (f : (ι → α) → ℝ)
    (base x : ι → α) (c : ι → ℝ)
    (i : ι) (a : α) :
    (∑ k ∈ Finset.range (Fintype.card (OwnedEdge c i)),
      actualPairKernel p f base i (ownedNeighborIndex c i k)
        a (x (ownedNeighborIndex c i k))) =
    ownedPairSection p f c i x a := by
  classical
  let S : Finset (Edge ι) :=
    ownedEdges first second c (Finset.univ : Finset (Edge ι)) i
  let n := Fintype.card (OwnedEdge c i)
  let H : OwnedEdge c i → ℝ := fun e =>
    esComp p e.1.1 f (Function.update x i a)
  have hfinite :
      (∑ k ∈ Finset.range n,
        actualPairKernel p f base i (ownedNeighborIndex c i k)
          a (x (ownedNeighborIndex c i k))) =
      ∑ k : Fin n,
        actualPairKernel p f base i (ownedNeighbor c i k)
          a (x (ownedNeighbor c i k)) := by
    simpa only [n, ownedNeighborIndex,
      dif_pos, Fin.sum_univ_eq_sum_range] using
      (Fin.sum_univ_eq_sum_range (fun k : Fin n =>
        actualPairKernel p f base i (ownedNeighbor c i k)
          a (x (ownedNeighbor c i k)))).symm
  have horient (k : Fin n) :
      actualPairKernel p f base i (ownedNeighbor c i k)
        a (x (ownedNeighbor c i k)) =
      H (ownedEdgeAt c i k) := by
    let e : Edge ι := (ownedEdgeAt c i k).1
    have he : e ∈ S := (ownedEdgeAt c i k).2
    have h := actual_owned_edge_kernel_eq_component
      p f base x c i e he a
    simpa only [H, ownedNeighbor, e] using h
  have henumerate :
      (∑ k : Fin n, H (ownedEdgeAt c i k)) =
      ∑ e : OwnedEdge c i, H e := by
    exact Fintype.sum_equiv
      (Fintype.equivFin (OwnedEdge c i)).symm
      (fun k : Fin n => H (ownedEdgeAt c i k))
      H (fun k => rfl)
  have hattach :
      (∑ e : OwnedEdge c i, H e) =
      ownedPairSection p f c i x a := by
    unfold ownedPairSection
    simpa only [S, H, OwnedEdge] using
      (Finset.sum_attach S (fun e : Edge ι =>
        esComp p e.1 f (Function.update x i a))).symm
  calc
    (∑ k ∈ Finset.range (Fintype.card (OwnedEdge c i)),
      actualPairKernel p f base i (ownedNeighborIndex c i k)
        a (x (ownedNeighborIndex c i k))) =
      ∑ k : Fin n,
        actualPairKernel p f base i (ownedNeighbor c i k)
          a (x (ownedNeighbor c i k)) := hfinite
    _ = ∑ k : Fin n, H (ownedEdgeAt c i k) := by
      apply Finset.sum_congr rfl
      intro k _
      exact horient k
    _ = ∑ e : OwnedEdge c i, H e := henumerate
    _ = ownedPairSection p f c i x a := hattach

/-- Equality of the recursive Hilbert endpoint's FIRST norm moment
with the genuine conditional L2 owner section of the original source.
The independent-product law is derived from the injective original
neighbor enumeration. No first-moment transport hypothesis is passed. -/
theorem actual_owned_recursive_first_norm_eq_source_section
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (base : ι → α) (c : ι → ℝ) (i : ι) :
    let n := Fintype.card (OwnedEdge c i)
    let j := ownedNeighborIndex c i
    let Y := finitePairIncrement p f base i j n
    (∑ w : Samples α n, mass (fun k => p (j k)) n w *
      Real.sqrt (vecNormSq (sumVector Y n w))) =
    (∑ x : ι → α, prodMass p x *
      norm (p i) (fun a => ownedPairSection p f c i x a)) := by
  classical
  dsimp
  let n := Fintype.card (OwnedEdge c i)
  let j := ownedNeighborIndex c i
  let Y := finitePairIncrement p f base i j n
  have hInj :
      ∀ k l, k < n → l < n → k ≠ l → j k ≠ j l := by
    intro k l hk hl hkl heq
    exact hkl
      (ownedNeighborIndex_injective_on_range c i k l hk hl heq)
  have hlaw :=
    actual_source_observed_hilbert_first_moment
      p hp1 j n hInj Y
  change
    (∑ w : Samples α n, mass (fun k => p (j k)) n w *
      Real.sqrt (vecNormSq (sumVector Y n w))) =
    (∑ x : ι → α, prodMass p x *
      norm (p i) (fun a => ownedPairSection p f c i x a))
  rw [← hlaw]
  apply Finset.sum_congr rfl
  intro x _
  congr 1
  calc
    Real.sqrt (vecNormSq
      (sumVector Y n (observedSample j n x))) =
      norm (p i)
        (fun a => ∑ k ∈ Finset.range n,
          actualPairKernel p f base i (j k) a (x (j k))) :=
        finitePair_observed_norm_eq_source_section p hp f base i j n x
    _ = norm (p i)
      (fun a => ownedPairSection p f c i x a) := by
        have hfun :
            (fun a : α => ∑ k ∈ Finset.range n,
              actualPairKernel p f base i (j k) a (x (j k))) =
            (fun a : α => ownedPairSection p f c i x a) := by
          funext a
          exact actual_owned_neighbor_kernel_sum_eq_section
            p f base x c i a
        rw [hfun]

end Nightfall.Observability.ActualESOwnedObservedSource

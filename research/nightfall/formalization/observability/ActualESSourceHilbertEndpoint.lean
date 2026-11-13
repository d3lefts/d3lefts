import ActualESOwnedMomentEnergy
import ActualESOwnedNeighborEnumeration
import ActualESPairOrientation
import ActualESCanonicalPairGraph
import ActualESFiniteNeighborMoment

/-!
# Actual Efron–Stein source -> generated finite-neighbor fourth endpoint

This is an integrated finite-source theorem statement, rather than
a certificate with supplied energy or matching assumptions.

From only:
  nonnegative normalized source marginals,
  |f| <= B and ESDegreeLE p f 2,
  a genuine upper bound M on the actual source influences,

we construct c_i from the canonical source graph and prove:
  c_i >= 0, sum_i c_i <= 8 B,
  moment2_i <= z_i (c_i + sqrt(3 M)).

Every moment2_i is the exact original greedily owned conditional
section energy, and its cap is derived via the source influence
identity, not assumed. The fourth-moment interpolation is called
from the existing compiled ActualESFiniteNeighborMoment endpoint.

This does not yet assemble the terminal variance inequality: the
remaining interface is the sum of z_i via the conditional Jensen
projection, the sharp section budget and additive projection.
All declarations must pass strict Lean before certification.
-/

namespace Nightfall.Observability.ActualESSourceHilbertEndpoint

open Finset
open Nightfall.ProductSpace.EfronStein
open Nightfall.ProductSpace.Influence
open Nightfall.Observability.ActualESOwnedNeighborEnumeration
open Nightfall.Observability.ActualESPairOrientation
open Nightfall.Observability.ActualESCanonicalPairGraph
open Nightfall.Observability.ActualESGreedyOwnership
open Nightfall.Observability.ActualESOwnedMomentEnergy
open Nightfall.Observability.ActualESFiniteNeighborMoment
open Nightfall.Observability.QuadraticHilbertMany

variable {ι α : Type}
  [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

/-- Derived fourth-moment endpoint for one true original source owner.
The source itself supplies the energy cap via its pinfl, so no hM
moment inequality is present in this theorem's hypotheses. -/
theorem actual_owned_owner_fourth_endpoint
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (base : ι → α)
    (c : ι → ℝ)
    (hc : ∀ i, 0 ≤ c i)
    (hcover : ∀ i e, e ∈ ownedEdges first second c
      (Finset.univ : Finset (Edge ι)) i →
      ∀ s t : α,
        |Nightfall.Observability.ActualESPairMatching.actualPairKernel
          p f base (first e) (second e) s t| ≤ c i)
    (M : ℝ) (hI : ∀ i, pinfl p f i ≤ M)
    (i : ι) :
    moment2 (fun k => p (ownedNeighborIndex c i k))
      (finitePairIncrement p f base i
        (ownedNeighborIndex c i) (Fintype.card (OwnedEdge c i)))
      (Fintype.card (OwnedEdge c i)) ≤
      (∑ w : Samples α (Fintype.card (OwnedEdge c i)),
        mass (fun k => p (ownedNeighborIndex c i k))
          (Fintype.card (OwnedEdge c i)) w *
        Real.sqrt (vecNormSq
          (sumVector (finitePairIncrement p f base i
            (ownedNeighborIndex c i)
            (Fintype.card (OwnedEdge c i)))
            (Fintype.card (OwnedEdge c i)) w))) *
      (c i + Real.sqrt (3 * M)) := by
  classical
  let n := Fintype.card (OwnedEdge c i)
  let j := ownedNeighborIndex c i
  have hne : ∀ k, k < n → i ≠ j k := by
    intro k hk
    exact ownedNeighborIndex_ne_owner c i k hk
  have hkernel : ∀ k, k < n → ∀ a b,
      |Nightfall.Observability.ActualESPairMatching.actualPairKernel
        p f base i (j k) a b| ≤ c i := by
    intro k hk a b
    let e : Edge ι := (ownedEdgeAt c i (⟨k, hk⟩ : Fin n)).1
    have he : e ∈ ownedEdges first second c
        (Finset.univ : Finset (Edge ι)) i :=
      (ownedEdgeAt c i (⟨k, hk⟩ : Fin n)).2
    have howner : owner first second c e = i :=
      (Finset.mem_filter.mp he).2
    have horig : ∀ s t : α,
        |Nightfall.Observability.ActualESPairMatching.actualPairKernel
          p f base (first e) (second e) s t| ≤
        c (owner first second c e) := by
      intro s t
      rw [howner]
      exact hcover i e he s t
    have horient :=
      actual_owner_oriented_kernel_bound
        p f base c e a b horig
    rw [howner] at horient
    simpa [j, ownedNeighborIndex, hk, ownedNeighbor, e] using horient
  have hcap :
      moment2 (fun k => p (j k))
        (finitePairIncrement p f base i j n) n ≤ M := by
    exact
      (actual_owned_neighbor_moment2_le_actual_influence
        p hp hp1 f hdegree base c i).trans (hI i)
  exact finitePairIncrement_fourth_endpoint
    p hp hp1 f base i j n (c i) M
    hne (hc i) hkernel hcap

/-- All endpoints and their 8B total cost are generated from the
real source, with no supplied matching, energy, or amplitude budget.
The premise M>=actual pinfl is only the definition of a common
maximal-influence comparison parameter, not an owned energy bound. -/
theorem actual_source_generated_all_fourth_endpoints
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (base : ι → α)
    (B : ℝ) (hf : ∀ x, |f x| ≤ B)
    (M : ℝ) (hI : ∀ i, pinfl p f i ≤ M) :
    ∃ c : ι → ℝ,
      (∀ i, 0 ≤ c i) ∧
      (∑ i : ι, c i) ≤ 8 * B ∧
      (∀ i,
        moment2 (fun k => p (ownedNeighborIndex c i k))
          (finitePairIncrement p f base i
            (ownedNeighborIndex c i)
            (Fintype.card (OwnedEdge c i)))
          (Fintype.card (OwnedEdge c i)) ≤
        (∑ w : Samples α (Fintype.card (OwnedEdge c i)),
          mass (fun k => p (ownedNeighborIndex c i k))
            (Fintype.card (OwnedEdge c i)) w *
          Real.sqrt (vecNormSq
            (sumVector (finitePairIncrement p f base i
              (ownedNeighborIndex c i)
              (Fintype.card (OwnedEdge c i)))
              (Fintype.card (OwnedEdge c i)) w))) *
          (c i + Real.sqrt (3 * M))) := by
  classical
  obtain ⟨c, hc, hsum, hcover, _, _, _, _⟩ :=
    actual_source_canonical_owned_energy
      p hp hp1 f hdegree base B hf
  refine ⟨c, hc, hsum, ?_⟩
  intro i
  exact actual_owned_owner_fourth_endpoint
    p hp hp1 f hdegree base c hc hcover M hI i

end Nightfall.Observability.ActualESSourceHilbertEndpoint

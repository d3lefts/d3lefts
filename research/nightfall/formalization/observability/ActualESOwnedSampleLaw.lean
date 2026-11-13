import ActualESFiniteSampleLaw
import ActualESCanonicalPairGraph

/-!
# Actual greedily-owned original coordinates: exact sample-law bridge

The owned neighbors are a *Finset* of genuine original coordinate labels,
rather than a stream of synthetic, possibly duplicated input variables.
Finite enumeration uses an equivalence J ≃ Fin J.card, extended with
the owner i after the first J.card entries.

The mean norm of the resulting recursive Hilbert sample table is the
mean norm of the SAME function of the original product source. Thus
the fourth-moment endpoint's first moment has its true source law.

No source-level terminal Q2 theorem is asserted by this file. A
separate canonical owned-section equality must still orient each
source pair kernel at the owner and identify the recursive sumVector
with the exact conditional source section used by Jensen.
-/

namespace Nightfall.Observability.ActualESOwnedSampleLaw

open Finset
open Nightfall.ProductSpace.Transfer
open Nightfall.ProductSpace.Influence
open Nightfall.Observability.ActualESFiniteSampleLaw
open Nightfall.Observability.ActualESFiniteNeighborMoment
open Nightfall.Observability.ActualESGreedyOwnership
open Nightfall.Observability.ActualESCanonicalPairGraph
open Nightfall.Observability.QuadraticHilbertMany

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

/-- The generated, genuinely distinct source neighbors owned by i. -/
noncomputable def greedyOwnedNeighbors (c : ι → ℝ) (i : ι) : Finset ι :=
  ((ownedEdges first second c
    (Finset.univ : Finset (Edge ι)) i)).image
      (other first second c)

/-- Enumerate the first J.card genuine neighbor sites, with the owner
as an irrelevant tail value. The prefix is a bijection with J. -/
noncomputable def indexedNeighbors
    (i : ι) (J : Finset ι) (k : ℕ) : ι :=
  if hk : k < J.card then
    ((J.equivFin).symm ⟨k, hk⟩).1
  else i

theorem indexedNeighbors_mem
    (i : ι) (J : Finset ι)
    (k : ℕ) (hk : k < J.card) :
    indexedNeighbors i J k ∈ J := by
  simp only [indexedNeighbors, dif_pos hk]
  exact ((J.equivFin).symm ⟨k, hk⟩).2

theorem indexedNeighbors_injective_on_prefix
    (i : ι) (J : Finset ι)
    (k l : ℕ) (hk : k < J.card)
    (hl : l < J.card) (hkl : k ≠ l) :
    indexedNeighbors i J k ≠ indexedNeighbors i J l := by
  intro hEq
  have hv :
      ((J.equivFin).symm ⟨k,hk⟩).1 =
        ((J.equivFin).symm ⟨l,hl⟩).1 := by
    simpa [indexedNeighbors, hk, hl] using hEq
  have hs :
      (J.equivFin).symm ⟨k,hk⟩ =
        (J.equivFin).symm ⟨l,hl⟩ := Subtype.ext hv
  have hf := (J.equivFin).symm.injective hs
  exact hkl (congrArg Fin.val hf)

/-- Exact *distribution*, for every observable of the actual greedily
owned coordinate values. This includes every L1/L2/L4 moment. -/
theorem actual_greedy_owned_product_law
    (p : ι → α → ℝ)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (c : ι → ℝ) (i : ι)
    (F : Samples α (greedyOwnedNeighbors c i).card → ℝ) :
    (∑ x : ι → α, prodMass p x *
        F (observedSample
          (indexedNeighbors i (greedyOwnedNeighbors c i))
          (greedyOwnedNeighbors c i).card x)) =
      ∑ w : Samples α (greedyOwnedNeighbors c i).card,
        mass (fun k => p (indexedNeighbors i
          (greedyOwnedNeighbors c i) k))
          (greedyOwnedNeighbors c i).card w * F w := by
  let J := greedyOwnedNeighbors c i
  let j := indexedNeighbors i J
  exact actual_source_observedSample_law p hp1 j J.card
    (fun k l hk hl hkl =>
      indexedNeighbors_injective_on_prefix i J k l hk hl hkl) F

/-- Original source first norm moment = recursive genuine independent
neighbor first moment. The increment vectors are built directly from
the actual canonical source pair kernel, not supplied arbitrary Y. -/
theorem actual_greedy_owned_first_norm_law
    (p : ι → α → ℝ)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ) (base : ι → α)
    (c : ι → ℝ) (i : ι) :
    let J := greedyOwnedNeighbors c i
    let j := indexedNeighbors i J
    let Y := finitePairIncrement p f base i j J.card
    (∑ x : ι → α, prodMass p x *
      Real.sqrt (Nightfall.Observability.QuadraticHilbertMoments.vecNormSq
        (sumVector Y J.card (observedSample j J.card x)))) =
    (∑ w : Samples α J.card, mass (fun k => p (j k)) J.card w *
      Real.sqrt (Nightfall.Observability.QuadraticHilbertMoments.vecNormSq
        (sumVector Y J.card w))) := by
  dsimp
  exact actual_source_observed_hilbert_first_moment
    p hp1
    (indexedNeighbors i (greedyOwnedNeighbors c i))
    (greedyOwnedNeighbors c i).card
    (fun k l hk hl hkl =>
      indexedNeighbors_injective_on_prefix i
        (greedyOwnedNeighbors c i) k l hk hl hkl)
    (finitePairIncrement p f base i
      (indexedNeighbors i (greedyOwnedNeighbors c i))
      (greedyOwnedNeighbors c i).card)

/-- Choose the greedy cover directly from the degree-two source.
The generated costs have total mass <=8B and the exact original-law
identity above, no separately assumed independent neighbor law. -/
theorem exists_actual_source_greedy_first_norm_law
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : Nightfall.ProductSpace.EfronStein.ESDegreeLE p f 2)
    (base : ι → α) (B : ℝ)
    (hf : ∀ x, |f x| ≤ B) :
    ∃ c : ι → ℝ,
       (∀ i, 0 ≤ c i) ∧
       (∑ i : ι, c i) ≤ 8 * B ∧
       (∀ i, let J := greedyOwnedNeighbors c i
         let j := indexedNeighbors i J
         let Y := finitePairIncrement p f base i j J.card
         (∑ x : ι → α, prodMass p x *
           Real.sqrt (Nightfall.Observability.QuadraticHilbertMoments.vecNormSq
             (sumVector Y J.card (observedSample j J.card x)))) =
         (∑ w : Samples α J.card, mass (fun k => p (j k)) J.card w *
           Real.sqrt (Nightfall.Observability.QuadraticHilbertMoments.vecNormSq
             (sumVector Y J.card w)))) := by
  obtain ⟨c, hc, htotal, _, _, _, _, _⟩ :=
    actual_source_canonical_owned_energy p hp hp1 f hdegree base B hf
  exact ⟨c, hc, htotal,
    fun i => actual_greedy_owned_first_norm_law p hp1 f base c i⟩

end Nightfall.Observability.ActualESOwnedSampleLaw

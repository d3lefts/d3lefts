import ActualESOwnedSampleLaw
import ActualSourceDegreeTwoAllDimensions
import ActualSourceVarianceEnergy
import ActualSourceInfluenceEnergy
import ActualSourceFinitePairMoment
import ActualSourceMatchingCover
import ActualSourcePairAmplitudes
import ActualSourcePairEnergyBridge

/-!
# Q2: one-source structural and finite-neighbor moment composition

All assumptions in `actual_source_q2_structural_moment_package` concern ONE
original finite product law and ONE original bounded degree-two function.
The section estimate, variance/influence Parseval identities, actual
greedy cover, energy partition, distinct owned neighbor law, and the
finite-neighbor Hilbert SECOND-moment identity are simultaneously
instantiated from the SAME source. There are no supplied certificates.

Important: this package is NOT a proof of the dimension-free Q2 bound.
The terminal implication remains open until the original-source owner
increment vectors are identified with the same oriented canonical
energies in the greedy partition, with an owner-wise
`s_i ≤ z_i (c_i + sqrt (3 * M))` at M=max genuine influence and
`z_i ≤ u_i + a_i` from actual conditional Jensen. These are not
obtained merely by packaging the existing declarations.
-/

namespace Nightfall.Observability.ActualSourceQ2CompositionGate

open Finset
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualSourceDegreeTwoAllDimensions
open Nightfall.Observability.ActualSourceVarianceEnergy
open Nightfall.Observability.ActualSourceInfluenceEnergy
open Nightfall.Observability.ActualESGreedyOwnership
open Nightfall.Observability.ActualESCanonicalPairGraph
open Nightfall.Observability.ActualESOwnedEnergy
open Nightfall.Observability.ActualESOwnedSampleLaw
open Nightfall.Observability.ActualSourceFinitePairMoment
open Nightfall.Observability.ActualSourceMatchingCover
open Nightfall.Observability.ActualSourcePairAmplitudes
open Nightfall.Observability.ActualSourcePairEnergyBridge
open Nightfall.Observability.QuadraticHilbertMany
open Nightfall.Observability.QuadraticHilbertMoments

variable {ι α : Type}
  [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

/-- The precise *unproved* dimension-free source-level objective.
Using every nonnegative common upper bound of the genuine influences
avoids arbitrary maxima and handles an empty coordinate type. -/
def SourceQ2Target
    (p : ι → α → ℝ) (f : (ι → α) → ℝ) (B : ℝ) : Prop :=
  ∀ M : ℝ, 0 ≤ M →
    (∀ i : ι, sourceInfluence p f i ≤ M) →
    (sourceVariance p f)^2 ≤
      (16 * (1 + Real.sqrt 3))^2 * B^2 * M

/-- A single unconditional, actual-source Q2 *input certificate*.
This theorem proves all displayed identities, not the target above.
It includes the true first norm observation and the true finite
Hilbert second moment over injectively enumerated owned neighbors.
The remaining owner-wise conditional projection and global influence
energy domination are deliberately not smuggled in as assumptions. -/
theorem actual_source_q2_structural_moment_package
    (p : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (base : ι → α)
    (B : ℝ) (hB : 0 ≤ B) (hf : ∀ x, |f x| ≤ B) :
    (∀ x : ι → α,
       (∑ i : ι, Real.sqrt (∑ a : α, p i a *
          (f (Function.update x i a) -
            (∑ b : α, p i b * f (Function.update x i b)))^2)) ≤
       8 * B) ∧
    (sourceVariance p f =
      ∑ S : Finset ι,
        if S ≠ ∅ ∧ S.card ≤ 2 then
          ∑ x : ι → α, originalMass p x * (esComp p S f x)^2
        else 0) ∧
    (∀ i : ι, sourceInfluence p f i =
      ∑ S : Finset ι,
        if i ∈ S ∧ S.card ≤ 2 then
          ∑ x : ι → α, originalMass p x * (esComp p S f x)^2
        else 0) ∧
    (∀ i j : ι, i ≠ j →
      ActualSourceFinitePairMoment.sourcePairEnergy p f i j =
        ∑ x : ι → α, originalMass p x *
          (esComp p ({i,j} : Finset ι) f x)^2) ∧
    (∃ c : ι → ℝ,
       (∀ i, 0 ≤ c i) ∧
       (∑ i : ι, c i) ≤ 8 * B ∧
       (∀ i, 0 ≤ ownedSourceEnergy p f base first second c
         (Finset.univ : Finset (Edge ι)) i) ∧
       ((∑ i : ι, ownedSourceEnergy p f base first second c
         (Finset.univ : Finset (Edge ι)) i) =
         ∑ e : Edge ι,
           ActualESOwnedEnergy.sourcePairEnergy p f base
             (first e) (second e)) ∧
       (∀ i : ι,
         let J := greedyOwnedNeighbors c i
         let j := indexedNeighbors i J
         let Y := ownedIncrement p f base i J
         (∑ x : ι → α, prodMass p x *
           Real.sqrt (vecNormSq
             (sumVector Y J.card (observedSample j J.card x)))) =
         ∑ w : Samples α J.card,
           mass (fun k => p (j k)) J.card w *
             Real.sqrt (vecNormSq (sumVector Y J.card w))) ∧
       (∀ i : ι,
         let J := greedyOwnedNeighbors c i
         let j := indexedNeighbors i J
         moment2 (fun k => p (j k))
           (ActualSourceFinitePairMoment.finitePairIncrement
             p f i j J.card) J.card =
         ∑ k ∈ Finset.range J.card,
           ActualSourceFinitePairMoment.sourcePairEnergy
             p f i (j k))) := by
  classical
  refine ⟨?_, ?_, ?_, ?_, ?_⟩
  · intro x
    exact actual_degree_two_source_section_budget_eight_all_current
      p hp hp1 f B hB hf hdegree x
  · exact actual_degree_two_source_variance_energy
      p hp1 f hdegree
  · intro i
    exact original_source_degree_two_influence_energy
      p hp1 f hdegree i
  · intro i j hij
    exact original_pair_finite_moment_energy_eq_canonical
      p hp1 f i j hij
  · obtain ⟨c, hc, hcost, _hamp, _hinj, _hne, henergy, hpartition⟩ :=
      actual_source_canonical_owned_energy
        p hp hp1 f hdegree base B hf
    refine ⟨c, hc, hcost, henergy, hpartition, ?_, ?_⟩
    · intro i
      exact actual_greedy_owned_first_norm_law
        p hp1 f base c i
    · intro i
      let J := greedyOwnedNeighbors c i
      let j := indexedNeighbors i J
      have howned (t : ι) (ht : t ∈ J) : i ≠ t := by
        change t ∈ greedyOwnedNeighbors c i at ht
        unfold greedyOwnedNeighbors at ht
        obtain ⟨e, he, heq⟩ := Finset.mem_image.mp ht
        have hne := owned_neighbor_ne_owner
          first second c (Finset.univ : Finset (Edge ι))
          (fun e _ => first_ne_second e) i e he
        exact heq ▸ hne
      have hdistinct (k : ℕ) (hk : k < J.card) :
          i ≠ j k := by
        exact howned (j k)
          (indexedNeighbors_mem i J k hk)
      exact finitePairIncrement_moment2_eq_source_pair_energies
        p hp hp1 f i j J.card hdistinct


/-- A SINGLE source-derived greedy cost vector controls original-source
pair amplitudes and the exact owned energy partition, while both finite
neighbor moment laws refer to its genuinely distinct owned sites.
Unlike the earlier package, the cover and pair energies use the SAME
`sourceDoubleCenteredPair` representation. Still not terminal Q2:
the owner-oriented energy/Jensen links remain separate obligations. -/
theorem actual_source_single_greedy_owned_moment_package
    (p : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (base : ι → α)
    (B : ℝ) (hf : ∀ x, |f x| ≤ B) :
    ∃ c : ι → ℝ,
      (∀ i, 0 ≤ c i) ∧
      (∑ i : ι, c i) ≤ 8 * B ∧
      (∀ e : Edge ι, ∀ a b : α,
        |sourceDoubleCenteredPair p f (first e) (second e) a b| ≤
          c (owner first second c e)) ∧
      (∀ i : ι,
        Set.InjOn (other first second c)
          (↑(ownedEdges first second c
            (Finset.univ : Finset (Edge ι)) i) : Set (Edge ι))) ∧
      (∀ i e, e ∈ ownedEdges first second c
          (Finset.univ : Finset (Edge ι)) i →
          i ≠ other first second c e) ∧
      ((∑ i : ι,
        (ownedEdges first second c
          (Finset.univ : Finset (Edge ι)) i).sum
            (fun e => ActualSourceFinitePairMoment.sourcePairEnergy
              p f (first e) (second e))) =
        ∑ e : Edge ι, ActualSourceFinitePairMoment.sourcePairEnergy
          p f (first e) (second e)) ∧
      (∀ i : ι,
        let J := greedyOwnedNeighbors c i
        let j := indexedNeighbors i J
        let Y := ownedIncrement p f base i J
        (∑ x : ι → α, prodMass p x *
          Real.sqrt (vecNormSq
            (sumVector Y J.card (observedSample j J.card x)))) =
        ∑ w : Samples α J.card,
          mass (fun k => p (j k)) J.card w *
            Real.sqrt (vecNormSq (sumVector Y J.card w))) ∧
      (∀ i : ι,
        let J := greedyOwnedNeighbors c i
        let j := indexedNeighbors i J
        moment2 (fun k => p (j k))
          (ActualSourceFinitePairMoment.finitePairIncrement
            p f i j J.card) J.card =
        ∑ k ∈ Finset.range J.card,
          ActualSourceFinitePairMoment.sourcePairEnergy
            p f i (j k)) := by
  classical
  obtain ⟨c, hc, hcost, hcover⟩ :=
    source_greedy_attained_endpoint_cover
      p hp hp1 f hdegree base first second
      (Finset.univ : Finset (Edge ι))
      (fun e _ => first_ne_second e) B hf
  refine ⟨c, hc, hcost, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · intro e a b
    exact (source_pair_amplitude_dominated
      p f (first e) (second e) a b).trans
        (owner_cost_dominates first second c e _
          (hcover e (Finset.mem_univ e)))
  · intro i
    exact other_injective_at_owner first second c
      (Finset.univ : Finset (Edge ι))
      (fun e _ d _ heq => canonical_pair_simple e d heq) i
  · intro i e he
    exact owned_neighbor_ne_owner first second c
      (Finset.univ : Finset (Edge ι))
      (fun e _ => first_ne_second e) i e he
  · exact owned_energy_partition first second c
      (Finset.univ : Finset (Edge ι))
      (fun e => ActualSourceFinitePairMoment.sourcePairEnergy
        p f (first e) (second e))
  · intro i
    exact actual_greedy_owned_first_norm_law
      p hp1 f base c i
  · intro i
    let J := greedyOwnedNeighbors c i
    let j := indexedNeighbors i J
    have howned (t : ι) (ht : t ∈ J) : i ≠ t := by
      change t ∈ greedyOwnedNeighbors c i at ht
      unfold greedyOwnedNeighbors at ht
      obtain ⟨e, he, heq⟩ := Finset.mem_image.mp ht
      have hne := owned_neighbor_ne_owner
        first second c (Finset.univ : Finset (Edge ι))
        (fun e _ => first_ne_second e) i e he
      exact heq ▸ hne
    have hdistinct (k : ℕ) (hk : k < J.card) :
        i ≠ j k := by
      exact howned (j k) (indexedNeighbors_mem i J k hk)
    exact finitePairIncrement_moment2_eq_source_pair_energies
      p hp hp1 f i j J.card hdistinct

end Nightfall.Observability.ActualSourceQ2CompositionGate

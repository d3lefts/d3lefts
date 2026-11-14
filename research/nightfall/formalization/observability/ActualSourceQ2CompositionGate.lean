import ActualSourceOwnerOrientation
import ActualSourcePairEnergyBridge
import ActualSourceDegreeTwoAllDimensions
import ActualSourceVarianceEnergy
import ActualSourceInfluenceEnergy

/-!
# Source-only Q2 composition gate (current pin, no legacy bridge)

Exactly ONE original f, p, B, degree-2 law supplies:
* the 8B centered-section estimate;
* true-product variance and influence Parseval;
* exact finite Hilbert pair energy = current-source canonical pair sector;
* an actual attained 8B greedy cover, unique pair-edge assignment,
  truly distinct owned labels, full pair-energy partition,
  genuine original-source first norm sampling law and exact
  finite Hilbert second moment, using ONE source-generated owner cost c.

All these components are proved simultaneously below, without supplied
cover, moment, energy or sampling assumptions. `SourceQ2Target` is
only the stated final objective, not a theorem. The remaining
original-section conditional Jensen, owner orientation and s_i≤I_i
bridges must still be certified before terminal Q2 follows.
-/

namespace Nightfall.Observability.ActualSourceQ2CompositionGate

open Finset
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualSourceDegreeTwoAllDimensions
open Nightfall.Observability.ActualSourceVarianceEnergy
open Nightfall.Observability.ActualSourceInfluenceEnergy
open Nightfall.Observability.ActualSourcePairEnergyBridge
open Nightfall.Observability.ActualSourceOwnedGraph
open Nightfall.Observability.ActualSourceOwnerOrientation
open Nightfall.Observability.ActualESGreedyOwnership
open Nightfall.Observability.ActualSourceFinitePairMoment
open Nightfall.Observability.ActualProductSourcePairCentering
open Nightfall.Observability.ActualSourceFiniteSampleLaw
open Nightfall.Observability.QuadraticHilbertMany
open Nightfall.Observability.QuadraticHilbertMoments

variable {ι α : Type}
  [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

/-- Explicit *unproved* dimension-free endpoint for all
nonnegative genuine-influence upper bounds M. -/
def SourceQ2Target
    (p : ι → α → ℝ) (f : (ι → α) → ℝ) (B : ℝ) : Prop :=
  ∀ M : ℝ, 0 ≤ M →
    (∀ i : ι, sourceInfluence p f i ≤ M) →
    (sourceVariance p f)^2 ≤
      (16 * (1 + Real.sqrt 3))^2 * B^2 * M

/-- One source generates every certified input to the remaining
owner-oriented source Jensen and influence domination bridge.
This theorem does **not** claim to prove SourceQ2Target. -/
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
      sourcePairEnergy p f i j =
        ∑ x : ι → α, originalMass p x *
          (esComp p ({i,j} : Finset ι) f x)^2) ∧
    (∀ c : ι → ℝ, ∀ e : Edge ι,
      sourcePairEnergy p f (edgeFirst e) (edgeSecond e) =
      sourcePairEnergy p f
        (owner edgeFirst edgeSecond c e)
        (other edgeFirst edgeSecond c e)) ∧
    (∃ c : ι → ℝ,
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
             sourcePairEnergy p f i (j k))))) := by
  classical
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩
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
  · intro c e
    exact owned_original_pair_energy_orientation p hp1 f c e
  · exact actual_source_greedy_graph_hilbert_package
      p hp hp1 f hdegree base B hf

end Nightfall.Observability.ActualSourceQ2CompositionGate

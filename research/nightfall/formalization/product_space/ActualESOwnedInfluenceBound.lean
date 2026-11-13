import ActualESCanonicalPairGraph
import ActualESPairEnergyFubini
import ActualESInfluenceIdentity

/-!
# Generated greedy ownership: exact energy cap from actual pinfl

The full quadratic graph is canonically indexed by two-element
subsets of the original finite coordinate type. Each edge has a
UNIQUE greedy owner, and its true pair energy is integrated against
the original two marginals.

Using a two-site Fubini calculation, each edge energy is exactly the
source Efron–Stein component squared L2 energy. The genuine influence
I_i(f) is exactly the sum of singleton/pair energies containing i.
Every owned pair is one of those terms, and all other terms are
nonnegative, so owned energy <= I_i(f).

No influence-energy comparison, energy cap, Hilbert moment bound, or
desired quadratic inequality is assumed. This theorem requires
the exact ANOVA/Fubini interfaces to compile on one Lean pin.
-/

namespace Nightfall.Observability.ActualESOwnedInfluenceBound

open Finset
open Nightfall.ProductSpace.EfronStein
open Nightfall.ProductSpace.Influence
open Nightfall.Observability.ActualESPairMatching
open Nightfall.Observability.ActualESGreedyOwnership
open Nightfall.Observability.ActualESOwnedEnergy
open Nightfall.Observability.ActualESCanonicalPairGraph
open Nightfall.Observability.ActualESPairEnergyFubini
open Nightfall.Observability.ActualESInfluenceIdentity
open Nightfall.Observability.ActualESOrthogonalEnergy

variable {ι α : Type}
  [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

/-- Every original source canonical component has nonnegative L2
energy under nonnegative product weights. -/
theorem canonical_component_energy_nonneg
    (p : ι → α → ℝ) (hp : ∀ i a, 0 ≤ p i a)
    (f : (ι → α) → ℝ) (S : Finset ι) :
    0 ≤ sourceInner p (esComp p S f) (esComp p S f) := by
  unfold sourceInner
  apply Finset.sum_nonneg
  intro x _
  have hm := prodMass_nonneg' p hp x
  nlinarith [sq_nonneg (esComp p S f x), hm]

/-- The exact source L2 energy of an owned unordered source edge,
regardless of which endpoint was chosen as the first orientation. -/
theorem canonical_source_pair_energy_eq_component
    (p : ι → α → ℝ)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ) (base : ι → α)
    (e : Edge ι) :
    sourcePairEnergy p f base (first e) (second e) =
      sourceInner p (esComp p e.1 f) (esComp p e.1 f) := by
  rw [actual_source_pair_energy_eq_canonical_inner
    p hp1 f base (first e) (second e) (first_ne_second e)]
  rw [← canonical_pair_eq_endpoints e]

/-- Every greedily owned source interaction contains its owner. -/
theorem canonical_owned_edge_contains_owner
    (c : ι → ℝ) (i : ι) (e : Edge ι)
    (he : e ∈ ownedEdges first second c
      (Finset.univ : Finset (Edge ι)) i) :
    i ∈ e.1 := by
  classical
  have howner : owner first second c e = i :=
    (Finset.mem_filter.mp he).2
  have hset : (e.1 : Finset ι) =
      {owner first second c e, other first second c e} := by
    calc
      (e.1 : Finset ι) = {first e, second e} :=
        canonical_pair_eq_endpoints e
      _ = {owner first second c e, other first second c e} :=
        endpoints_eq_owner_other first second c e
  rw [hset, Finset.mem_insert]
  exact Or.inl howner.symm

/-- The source pair energy owned by any coordinate is bounded by
the actual source pinfl in that coordinate, with no energy hypothesis.

This is the exact load-bearing source energy comparison s_i <= I_i.
-/
theorem canonical_owned_pair_energy_le_actual_influence
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (base : ι → α)
    (c : ι → ℝ) (i : ι) :
    ownedSourceEnergy p f base first second c
      (Finset.univ : Finset (Edge ι)) i ≤ pinfl p f i := by
  classical
  let S : Finset (Edge ι) :=
    ownedEdges first second c (Finset.univ : Finset (Edge ι)) i
  let K : Finset (Finset ι) := S.image (fun e : Edge ι => e.1)
  let E : Finset ι → ℝ := fun U =>
    sourceInner p (esComp p U f) (esComp p U f)
  have hEq (e : Edge ι) :
      sourcePairEnergy p f base (first e) (second e) = E e.1 :=
    canonical_source_pair_energy_eq_component p hp1 f base e
  have hcard (U : Finset ι) (hU : U ∈ K) :
      U.card ≤ 2 ∧ i ∈ U := by
    obtain ⟨e, he, rfl⟩ := Finset.mem_image.mp hU
    refine ⟨?_, canonical_owned_edge_contains_owner c i e he⟩
    exact le_of_eq e.2
  have hInjective :
      Set.InjOn (fun e : Edge ι => e.1) (↑S : Set (Edge ι)) := by
    intro e _ d _ heq
    exact Subtype.ext heq
  have hsum :
      ownedSourceEnergy p f base first second c
        (Finset.univ : Finset (Edge ι)) i =
      K.sum E := by
    unfold ownedSourceEnergy
    change S.sum (fun e => sourcePairEnergy p f base (first e) (second e)) = _
    simp_rw [hEq]
    exact (Finset.sum_image hInjective).symm
  have hnonneg (U : Finset ι) : 0 ≤ E U :=
    canonical_component_energy_nonneg p hp f U
  have hK :
      K.sum E =
      K.sum (fun U => if U.card ≤ 2 ∧ i ∈ U then E U else 0) := by
    apply Finset.sum_congr rfl
    intro U hU
    simp [hcard U hU]
  have hle :
      K.sum (fun U => if U.card ≤ 2 ∧ i ∈ U then E U else 0) ≤
      (Finset.univ : Finset (Finset ι)).sum
        (fun U => if U.card ≤ 2 ∧ i ∈ U then E U else 0) := by
    apply Finset.sum_le_sum_of_subset_of_nonneg
    · exact Finset.subset_univ K
    · intro U _ _
      by_cases h : U.card ≤ 2 ∧ i ∈ U
      · simpa [h] using hnonneg U
      · simp [h]
  rw [hsum, hK]
  exact hle.trans_eq
    (actual_quadratic_source_influence_parseval
      p hp1 f hdegree i).symm

end Nightfall.Observability.ActualESOwnedInfluenceBound

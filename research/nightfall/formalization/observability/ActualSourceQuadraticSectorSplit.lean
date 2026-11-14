import ActualSourceOwnedFourthClosure
import ActualProductSourceMarginal

/-!
# Genuine degree-two source variance = singleton and real-pair energies

This is an *exact finite sector reindexing*, not a new orthogonality
assumption. Every singleton is a real coordinate, every pair is a
two-site Finset subtype, and the source law is unchanged.
-/

namespace Nightfall.Observability.ActualSourceQuadraticSectorSplit

open Finset
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualSourceVarianceEnergy
open Nightfall.Observability.ActualSourceInfluenceEnergy
open Nightfall.Observability.ActualSourceOwnedGraph
open Nightfall.Observability.ActualSourceOwnedMomentEnergy
open Nightfall.Observability.ActualSourcePairEnergyBridge
open Nightfall.Observability.ActualSourceQuadraticSupportSum
open Nightfall.Observability.ActualSourceMeanSectionJensen
open Nightfall.Observability.ActualProductSourceMarginal
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.ActualProductSourceDerivedStar
open Nightfall.Observability.ActualSourceSingletonProjection
open Nightfall.Observability.ActualESGreedyOwnership

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

/-- The supports of a nonconstant quadratic ANOVA polynomial
are precisely the one-site and two-site subsets. -/
theorem finite_degree_two_support_partition :
    (Finset.univ.filter
      (fun S : Finset ι => S ≠ ∅ ∧ S.card ≤ 2)) =
      (Finset.univ.filter
        (fun S : Finset ι => S.card = 1)) ∪
      (Finset.univ.filter
        (fun S : Finset ι => S.card = 2)) := by
  classical
  ext S
  simp only [Finset.mem_filter, Finset.mem_univ, true_and,
    Finset.mem_union]
  constructor
  · rintro ⟨hne, hcard⟩
    have hpos : 0 < S.card := by
      by_contra hn
      have hz : S.card = 0 := by omega
      exact hne (Finset.card_eq_zero.mp hz)
    rcases (show S.card = 1 ∨ S.card = 2 by omega) with h1 | h2
    · exact Or.inl h1
    · exact Or.inr h2
  · intro h
    rcases h with h1 | h2
    · constructor
      · intro he
        rw [he] at h1
        simp at h1
      · omega
    · constructor
      · intro he
        rw [he] at h2
        simp at h2
      · omega

theorem source_singleton_support_image :
    (Finset.univ.filter (fun S : Finset ι => S.card = 1)) =
      (Finset.univ : Finset ι).image (fun i => ({i} : Finset ι)) := by
  classical
  ext S
  simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_image]
  constructor
  · intro h
    obtain ⟨i, hi⟩ := Finset.card_eq_one.mp h
    exact ⟨i, Finset.mem_univ _, hi.symm⟩
  · rintro ⟨i, _, rfl⟩
    simp

theorem source_pair_support_image :
    (Finset.univ.filter (fun S : Finset ι => S.card = 2)) =
      (Finset.univ : Finset (Edge ι)).image (fun e => (e.1 : Finset ι)) := by
  classical
  ext S
  simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_image]
  constructor
  · intro h
    exact ⟨⟨S,h⟩, Finset.mem_univ _, rfl⟩
  · rintro ⟨e, _, rfl⟩
    exact e.2

/-- Exact reindexing: no fractional pair multiplicities, no
dimension factor, no synthetic coordinate or missing sector. -/
theorem finite_degree_two_energy_reindex
    (g : Finset ι → ℝ) :
    (∑ S : Finset ι,
      if S ≠ ∅ ∧ S.card ≤ 2 then g S else 0) =
      (∑ i : ι, g {i}) +
        ∑ e : Edge ι, g e.1 := by
  classical
  let F1 : Finset (Finset ι) :=
    Finset.univ.filter (fun S : Finset ι => S.card = 1)
  let F2 : Finset (Finset ι) :=
    Finset.univ.filter (fun S : Finset ι => S.card = 2)
  have hdis : Disjoint F1 F2 := by
    apply Finset.disjoint_left.mpr
    intro S h1 h2
    have hcard1 : S.card = 1 := (Finset.mem_filter.mp h1).2
    have hcard2 : S.card = 2 := (Finset.mem_filter.mp h2).2
    omega
  have h1 : F1.sum g = ∑ i : ι, g {i} := by
    rw [show F1 = (Finset.univ : Finset ι).image
      (fun i => ({i} : Finset ι)) from source_singleton_support_image]
    exact Finset.sum_image (s := (Finset.univ : Finset ι))
      (f := g) (g := fun i : ι => ({i} : Finset ι))
      (fun i hi j hj heq => by
        have hmem : i ∈ ({j} : Finset ι) := by
          rw [← heq]
          simp
        simpa using hmem)
  have h2 : F2.sum g = ∑ e : Edge ι, g e.1 := by
    rw [show F2 = (Finset.univ : Finset (Edge ι)).image
      (fun e => (e.1 : Finset ι)) from source_pair_support_image]
    exact Finset.sum_image (s := (Finset.univ : Finset (Edge ι)))
      (f := g) (g := fun e : Edge ι => (e.1 : Finset ι))
      (fun e he d hd h => Subtype.ext h)
  calc
    (∑ S : Finset ι,
      if S ≠ ∅ ∧ S.card ≤ 2 then g S else 0) =
      (Finset.univ.filter
        (fun S : Finset ι => S ≠ ∅ ∧ S.card ≤ 2)).sum g := by
          simp only [Finset.sum_filter]
    _ = (F1 ∪ F2).sum g := by
      rw [finite_degree_two_support_partition]
      rfl
    _ = F1.sum g + F2.sum g := Finset.sum_union hdis
    _ = (∑ i : ι, g {i}) + ∑ e : Edge ι, g e.1 := by
      rw [h1, h2]

/-- No source-specific pair/variance Parseval premise is supplied:
derive the true singleton plus original-edge decomposition. -/
theorem source_variance_eq_singleton_plus_pair_energy
    (p : ι → α → ℝ)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2) :
    sourceVariance p f =
      (∑ i : ι, ∑ x : ι → α, originalMass p x *
        (esComp p ({i} : Finset ι) f x)^2) +
      (∑ e : Edge ι,
        sourcePairEnergy p f (edgeFirst e) (edgeSecond e)) := by
  classical
  let E : Finset ι → ℝ := fun S =>
    ∑ x : ι → α, originalMass p x * (esComp p S f x)^2
  calc
    sourceVariance p f =
      ∑ S : Finset ι,
        if S ≠ ∅ ∧ S.card ≤ 2 then E S else 0 :=
        actual_degree_two_source_variance_energy p hp1 f hdegree
    _ = (∑ i : ι, E {i}) + ∑ e : Edge ι, E e.1 :=
      finite_degree_two_energy_reindex E
    _ = (∑ i : ι, ∑ x : ι → α, originalMass p x *
          (esComp p ({i} : Finset ι) f x)^2) +
        (∑ e : Edge ι,
          sourcePairEnergy p f (edgeFirst e) (edgeSecond e)) := by
      congr 1
      apply Finset.sum_congr rfl
      intro e _
      have h := original_pair_finite_moment_energy_eq_canonical
        p hp1 f (edgeFirst e) (edgeSecond e)
        (edgeFirst_ne_edgeSecond e)
      rw [edge_pair_eq_endpoints] at h
      exact h.symm

end Nightfall.Observability.ActualSourceQuadraticSectorSplit

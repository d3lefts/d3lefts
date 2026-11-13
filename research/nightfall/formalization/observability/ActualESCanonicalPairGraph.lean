import ActualESOwnedEnergy

/-!
# Canonical simple pair interaction graph for an arbitrary finite source

All possible quadratic interaction edges are indexed by two-element
subsets of the ACTUAL original coordinate type ι. Each edge has two
distinct endpoints and two edge indexes cannot represent the same
unordered coordinate pair. Thus the distinct-neighbor hypothesis of
the generated greedy source cover is discharged *by representation*,
without an auxiliary graph certificate.

Every two-coordinate canonical Hoeffding component appears exactly
once as an edge. The remaining ANOVA/conditional Jensen proof must
identify that complete edge-energy sum with variance/influence and
its source-section projection, respectively. No claim of terminal Q2.
-/

namespace Nightfall.Observability.ActualESCanonicalPairGraph

open Finset
open Nightfall.Observability.ActualESPairMatching
open Nightfall.Observability.ActualESGreedyOwnership
open Nightfall.Observability.ActualESOwnedEnergy

variable {ι α : Type}
  [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

/-- One label for every unordered pair of distinct ORIGINAL coordinates. -/
abbrev Edge (ι : Type) [DecidableEq ι] := {S : Finset ι // S.card = 2}

/-- Choose endpoints of a canonical two-element subset, preserving
the underlying unordered set and its exact cardinality. -/
noncomputable def endpoints (e : Edge ι) :
    {ab : ι × ι // ab.1 ≠ ab.2 ∧ e.1 = {ab.1, ab.2}} := by
  classical
  have h : Nonempty
      {ab : ι × ι // ab.1 ≠ ab.2 ∧ e.1 = {ab.1, ab.2}} := by
    obtain ⟨i, j, hij, hpair⟩ := Finset.card_eq_two.mp e.2
    exact ⟨⟨(i,j), hij, hpair⟩⟩
  exact Classical.choice h

noncomputable def first (e : Edge ι) : ι := (endpoints e).1.1
noncomputable def second (e : Edge ι) : ι := (endpoints e).1.2

theorem first_ne_second (e : Edge ι) :
    first e ≠ second e := (endpoints e).2.1

theorem canonical_pair_eq_endpoints (e : Edge ι) :
    (e.1 : Finset ι) = {first e, second e} :=
  (endpoints e).2.2

/-- No external uniqueness assumption: an edge is exactly its
two-element set. -/
theorem canonical_pair_simple
    (e d : Edge ι)
    (h : ({first e, second e} : Finset ι) =
      {first d, second d}) :
    e = d := by
  apply Subtype.ext
  calc
    (e.1 : Finset ι) = {first e, second e} :=
      canonical_pair_eq_endpoints e
    _ = {first d, second d} := h
    _ = (d.1 : Finset ι) :=
      (canonical_pair_eq_endpoints d).symm

/-- The source supplies its own complete simple quadratic graph.
All amplitude weights, matching bounds, owner costs, injective
neighbor maps and exact pair-energy allocation are derived. -/
theorem actual_source_canonical_owned_energy
    (p : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : Nightfall.ProductSpace.EfronStein.ESDegreeLE p f 2)
    (base : ι → α)
    (B : ℝ) (hf : ∀ x, |f x| ≤ B) :
    ∃ c : ι → ℝ,
      (∀ i, 0 ≤ c i) ∧
      (∑ i : ι, c i) ≤ 8 * B ∧
      (∀ i e, e ∈ ownedEdges first second c
        (Finset.univ : Finset (Edge ι)) i →
          ∀ s t : α,
            |actualPairKernel p f base (first e) (second e) s t| ≤ c i) ∧
      (∀ i, Set.InjOn (other first second c)
        (↑(ownedEdges first second c
          (Finset.univ : Finset (Edge ι)) i) : Set (Edge ι))) ∧
      (∀ i e, e ∈ ownedEdges first second c
        (Finset.univ : Finset (Edge ι)) i →
          i ≠ other first second c e) ∧
      (∀ i, 0 ≤ ownedSourceEnergy p f base first second c
        (Finset.univ : Finset (Edge ι)) i) ∧
      ((∑ i : ι, ownedSourceEnergy p f base first second c
        (Finset.univ : Finset (Edge ι)) i) =
          ∑ e : Edge ι,
            sourcePairEnergy p f base (first e) (second e)) := by
  classical
  exact actual_source_owned_energy_and_distinct_neighbors
    p hp hp1 f hdegree base
    first second (Finset.univ : Finset (Edge ι))
    (fun e _ => first_ne_second e)
    (fun e _ d _ heq => canonical_pair_simple e d heq)
    B hf

end Nightfall.Observability.ActualESCanonicalPairGraph

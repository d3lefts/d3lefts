import Route1DegreeSourceBridge

/-!
# FUR(2): unconditional source-compatible transition-degree lemma

Every sum of arbitrary pairwise coordinate interactions has indicator
interaction degree at most two. In particular, a transition remainder
formed from ordered pairs of active old/new letters has source
RowBound.HasProdDegreeLE at most two and vanishes at the all-inactive word.

This discharges the algebraic-degree part of the paper's FUR(2)
transition construction. It does NOT prove the Taylor identification,
the uniform |H| <= 4 bound, or the complete FUR(2) terminal.
-/

namespace Nightfall.MixtureAA.FUR2PairDegree

open Finset
open Nightfall.Route1LatentDegree
open Nightfall.Route1SourceBridge
open Nightfall.ProductSpace.RowBound

variable {ι α : Type*}
  [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

/-- A two-coordinate summand is supported on its two indices, including
the diagonal case i = j. -/
theorem pair_term_degree_two
    (i j : ι) (b : α → α → ℝ) :
    HasProdDegreeLE (fun x : ι → α => b (x i) (x j)) 2 := by
  have hs : SupportedOn ({i, j} : Finset ι)
      (fun x : ι → α => b (x i) (x j)) := by
    intro x y h
    have hi : x i = y i := h i (by simp)
    have hj : x j = y j := h j (by simp)
    rw [hi, hj]
  have hc : ({i, j} : Finset ι).card ≤ 2 := by
    have h := Finset.card_insert_le i ({j} : Finset ι)
    simpa using h
  exact local_to_source _ 2
    (degree_of_supported ({i, j} : Finset ι)
      (fun x : ι → α => b (x i) (x j)) hs 2 hc)

/-- A completely unrestricted finite sum of pairwise coordinate terms
has source indicator degree at most two, independent of dimension and
alphabet cardinality. -/
theorem pair_sum_degree_two
    (b : ι → ι → α → α → ℝ) :
    HasProdDegreeLE
      (fun x : ι → α => ∑ i, ∑ j, b i j (x i) (x j)) 2 := by
  have hinner (i : ι) :
      DegreeLE (fun x : ι → α => ∑ j, b i j (x i) (x j)) 2 := by
    apply degree_sum
      (fun j (x : ι → α) => b i j (x i) (x j)) 2
    intro j
    exact source_to_local _ 2 (pair_term_degree_two i j (b i j))
  have houter :
      DegreeLE
        (fun x : ι → α => ∑ i, ∑ j, b i j (x i) (x j)) 2 := by
    exact degree_sum
      (fun i (x : ι → α) => ∑ j, b i j (x i) (x j))
      2 hinner
  exact local_to_source _ 2 houter

/-- An arbitrary pairwise transition remainder. When either transition
is inactive, that summand is zero. To represent the paper's unordered
mixed differences, set the D coefficients to zero outside i < j. -/
def transitionRemainder
    (D : ι → ι → (α × α) → (α × α) → ℝ)
    (t : ι → Option (α × α)) : ℝ :=
  ∑ i, ∑ j,
    match t i, t j with
    | some a, some b => D i j a b
    | _, _ => 0

theorem transitionRemainder_inactive
    (D : ι → ι → (α × α) → (α × α) → ℝ) :
    transitionRemainder D (fun _ => none) = 0 := by
  simp [transitionRemainder]

/-- Unconditional degree-two certificate for the auxiliary transition
function, in the actual pinned source RowBound predicate. -/
theorem transitionRemainder_degree_two
    (D : ι → ι → (α × α) → (α × α) → ℝ) :
    HasProdDegreeLE (transitionRemainder D) 2 := by
  let b : ι → ι →
      Option (α × α) → Option (α × α) → ℝ :=
    fun i j a c =>
      match a, c with
      | some u, some v => D i j u v
      | _, _ => 0
  change HasProdDegreeLE
    (fun t : ι → Option (α × α) =>
      ∑ i, ∑ j, b i j (t i) (t j)) 2
  exact pair_sum_degree_two b

end Nightfall.MixtureAA.FUR2PairDegree

#print axioms Nightfall.MixtureAA.FUR2PairDegree.pair_term_degree_two
#print axioms Nightfall.MixtureAA.FUR2PairDegree.pair_sum_degree_two
#print axioms Nightfall.MixtureAA.FUR2PairDegree.transitionRemainder_inactive
#print axioms Nightfall.MixtureAA.FUR2PairDegree.transitionRemainder_degree_two

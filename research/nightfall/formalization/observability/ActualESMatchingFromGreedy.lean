import ActualESGeneralMatching
import WeightedGreedyMatching

/-!
# Arbitrary genuine source matching: import a graph-matching predicate

A matching of an arbitrary finite family of nonloop source edges gives an
injective endpoint map when reindexed by its selected-edge subtype.
This discharges the endpoint-embedding hypothesis of
ActualESGeneralMatching with no assumed matching budget, parity equation,
or synthetic quadratic polynomial.
-/

namespace Nightfall.Observability.ActualESMatchingFromGreedy

open Finset Nightfall.Observability.WeightedGreedy
open Nightfall.Observability.ActualESGeneralMatching

variable {E ι α : Type}
  [Fintype E] [DecidableEq E] [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

theorem selected_matchingCoord_injective
    (u v : E → ι) (S : Finset E)
    (hloop : ∀ e ∈ S, u e ≠ v e)
    (hm : IsMatching u v S) :
    Function.Injective
      (matchingCoord
        (fun e : {e : E // e ∈ S} => u e.1)
        (fun e : {e : E // e ∈ S} => v e.1)) := by
  intro ⟨⟨e, he⟩, s⟩ ⟨⟨f, hf⟩, t⟩ hab
  change (if s then v e else u e) =
    (if t then v f else u f) at hab
  have hef : e = f := by
    by_contra hneq
    obtain ⟨h00, h01, h10, h11⟩ := hm e he f hf hneq
    cases s with
    | false =>
      cases t with
      | false => exact h00 hab
      | true => exact h01 hab
    | true =>
      cases t with
      | false => exact h10 hab
      | true => exact h11 hab
  subst f
  have hst : s = t := by
    cases s with
    | false =>
      cases t with
      | false => rfl
      | true => exact False.elim ((hloop e he) hab)
    | true =>
      cases t with
      | false => exact False.elim ((hloop e he) hab.symm)
      | true => rfl
  apply Prod.ext
  · exact Subtype.ext rfl
  · exact hst

/-- Any selected graph matching in the genuine source inherits the
all-edge oriented-amplitude witness and 4B source rectangle budget.
The matching predicate and the nonloop check are purely combinatorial;
the function-theoretic budget is *derived* from source Hoeffding degree. -/
theorem actual_matching_witness_from_graph
    [Nonempty α]
    (p : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : Nightfall.ProductSpace.EfronStein.ESDegreeLE p f 2)
    (base : ι → α)
    (u v : E → ι)
    (S : Finset E)
    (hloop : ∀ e ∈ S, u e ≠ v e)
    (hm : IsMatching u v S)
    (B : ℝ) (hf : ∀ x, |f x| ≤ B) :
    ∃ a0 a1 b0 b1 : {e : E // e ∈ S} → α,
      (∀ e s t,
        |Nightfall.Observability.ActualESPairMatching.actualPairKernel
          p f base (u e.1) (v e.1) s t| ≤
        Nightfall.Observability.ActualESQuadraticRectangles.sourceRectangle
          f base (u e.1) (v e.1)
          (a0 e) (a1 e) (b0 e) (b1 e)) ∧
      (∑ e : {e : E // e ∈ S},
        Nightfall.Observability.ActualESQuadraticRectangles.sourceRectangle
          f base (u e.1) (v e.1)
          (a0 e) (a1 e) (b0 e) (b1 e)) ≤ 4 * B := by
  exact actual_source_general_matching_amplitude_witness
    p hp hp1 f hdegree base
    (fun e : {e : E // e ∈ S} => u e.1)
    (fun e : {e : E // e ∈ S} => v e.1)
    (selected_matchingCoord_injective u v S hloop hm)
    B hf

end Nightfall.Observability.ActualESMatchingFromGreedy

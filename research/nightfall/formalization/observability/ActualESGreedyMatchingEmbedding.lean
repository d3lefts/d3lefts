import ActualESGeneralMatching
import WeightedGreedyMatching
import WeightedGreedyCover

/-!
# Genuine finite source: greedy matching -> injective endpoint embedding -> 4B budget

The greedy matching selected by `exists_weighted_dominating_matching`
is a Finset of *actual source edges*. This module derives the injective
endpoint map on the subtype of its selected edges and thereby applies
the previously certified `actual_source_general_matching_amplitude_witness`.

The endpoint budget requires the natural source weight hypothesis
that each edge weight is attained or dominated by an actual source
kernel value. This is stated visibly; representing the source
sup-norm as a nonnegative attained finite weight remains an additional
constructive bridge. No matching mass, injected matching
representation or global amplitude bound is supplied as a premise.

Scope: finite common alphabet (including zero mass atoms), source
bounded pointwise by B, source Hoeffding degree at most two.
The theorem is not a terminal quadratic influence inequality.
-/

namespace Nightfall.Observability.ActualESGreedyMatchingEmbedding

open Finset
open Nightfall.ProductSpace.EfronStein
open Nightfall.Observability.WeightedGreedy
open Nightfall.Observability.WeightedGreedyCover
open Nightfall.Observability.ActualESPairMatching
open Nightfall.Observability.ActualESGeneralMatching
open Nightfall.Observability.ActualESQuadraticRectangles

variable {E ι α : Type}
  [Fintype E] [DecidableEq E]
  [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- A combinatorial matching really is an injective embedding of the
two endpoints per selected edge into the ORIGINAL source coordinates.
The finite subtype prevents duplicate selected edges. -/
theorem selected_matchingCoord_injective
    (u v : E → ι) (S : Finset E)
    (hne : ∀ e ∈ S, u e ≠ v e)
    (hmatch : IsMatching u v S) :
    Function.Injective
      (matchingCoord
        (fun e : {t : E // t ∈ S} => u e.val)
        (fun e : {t : E // t ∈ S} => v e.val)) := by
  classical
  intro a b h
  rcases a with ⟨⟨e, he⟩, be⟩
  rcases b with ⟨⟨f, hf⟩, bf⟩
  change (if be then v e else u e) =
    (if bf then v f else u f) at h
  by_cases hef : e = f
  · subst f
    have hneef := hne e he
    cases be <;> cases bf
    · rfl
    · exfalso
      exact hneef (by simpa using h)
    · exfalso
      exact hneef (by simpa using h.symm)
    · rfl
  · have hsep := hmatch e he f hf hef
    rcases hsep with ⟨huu, huv, hvu, hvv⟩
    cases be <;> cases bf
    · exact False.elim (huu (by simpa using h))
    · exact False.elim (huv (by simpa using h))
    · exact False.elim (hvu (by simpa using h))
    · exact False.elim (hvv (by simpa using h))

/-- Apply the genuine source 4B rectangle and kernel-amplitude witness
to an arbitrary graph matching, no packed-coordinate premise. -/
theorem selected_matching_source_amplitude_witness
    [Nonempty α]
    (p : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (base : ι → α)
    (u v : E → ι) (S : Finset E)
    (hne : ∀ e ∈ S, u e ≠ v e)
    (hmatch : IsMatching u v S)
    (B : ℝ) (hf : ∀ x, |f x| ≤ B) :
    ∃ a0 a1 b0 b1 : {e : E // e ∈ S} → α,
      (∀ e s t,
        |actualPairKernel p f base (u e.val) (v e.val) s t| ≤
          sourceRectangle f base (u e.val) (v e.val)
            (a0 e) (a1 e) (b0 e) (b1 e)) ∧
      (∑ e : {e : E // e ∈ S},
        sourceRectangle f base (u e.val) (v e.val)
          (a0 e) (a1 e) (b0 e) (b1 e)) ≤ 4 * B := by
  exact actual_source_general_matching_amplitude_witness
    p hp hp1 f hdegree base
    (fun e : {t : E // t ∈ S} => u e.val)
    (fun e : {t : E // t ∈ S} => v e.val)
    (selected_matchingCoord_injective u v S hne hmatch)
    B hf

/-- If each selected edge weight is bounded by some actual canonical
source kernel value, the genuine source enforces the weighted matching
mass inequality. No matching-mass estimate appears in the hypotheses. -/
theorem selected_matching_weight_sum_le_four
    [Nonempty α]
    (p : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (base : ι → α)
    (u v : E → ι) (w : E → ℝ)
    (S : Finset E)
    (hne : ∀ e ∈ S, u e ≠ v e)
    (hmatch : IsMatching u v S)
    (hweight : ∀ e ∈ S, ∃ a b : α,
      w e ≤ |actualPairKernel p f base (u e) (v e) a b|)
    (B : ℝ) (hf : ∀ x, |f x| ≤ B) :
    (∑ e ∈ S, w e) ≤ 4 * B := by
  obtain ⟨a0, a1, b0, b1, hbound, htotal⟩ :=
    selected_matching_source_amplitude_witness
      p hp hp1 f hdegree base u v S hne hmatch B hf
  have hsum :
      (∑ e : {e : E // e ∈ S}, w e.val) ≤
        (∑ e : {e : E // e ∈ S},
          sourceRectangle f base (u e.val) (v e.val)
            (a0 e) (a1 e) (b0 e) (b1 e)) := by
    apply Finset.sum_le_sum
    intro e _
    obtain ⟨a, b, he⟩ := hweight e.val e.property
    exact he.trans (hbound e a b)
  have hreindex :
      (∑ e ∈ S, w e) =
        (∑ e : {e : E // e ∈ S}, w e.val) := by
    simp
  exact hreindex.trans_le (hsum.trans htotal)

/-- An actual source + greedily chosen dominating matching gives an
8B endpoint cover for the *source-derived* weights, without a supplied
matching budget. A realization witness for each edge weight is explicit
and inspectable; it will later be discharged by the finite amplitude max.
-/
theorem exists_greedy_source_endpoint_cover
    [Nonempty α]
    (p : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (base : ι → α)
    (u v : E → ι) (w : E → ℝ)
    (T : Finset E)
    (hne : ∀ e ∈ T, u e ≠ v e)
    (hweight : ∀ e ∈ T, ∃ a b : α,
      w e ≤ |actualPairKernel p f base (u e) (v e) a b|)
    (B : ℝ) (hf : ∀ x, |f x| ≤ B) :
    ∃ S : Finset E,
      S ⊆ T ∧ IsMatching u v S ∧
      (∀ e ∈ T, ∃ g ∈ S,
        ¬ separated u v e g ∧ w e ≤ w g) ∧
      (∑ i : ι, cost u v w S i) ≤ 8 * B := by
  obtain ⟨S, hsub, hmatch, hdom⟩ :=
    exists_weighted_dominating_matching u v w T
  have hmass := selected_matching_weight_sum_le_four
    p hp hp1 f hdegree base u v w S
    (fun e he => hne e (hsub he))
    hmatch
    (fun e he => hweight e (hsub he))
    B hf
  have htotal : (∑ i : ι, cost u v w S i) ≤ 8 * B := by
    rw [sum_cost_twice]
    nlinarith
  exact ⟨S, hsub, hmatch, hdom, htotal⟩

end Nightfall.Observability.ActualESGreedyMatchingEmbedding

import ActualESMatchingMass
import WeightedGreedyCover

/-!
# Actual Efron–Stein quadratic kernels -> genuine 8B greedy cover

This construction combines (i) global matching mass derived from the
actual source, including unmatched coordinates, and (ii) an independently
constructed weighted maximum-first matching. The result derives the 8B
endpoint budget and bounds every genuine pair kernel by one endpoint.

No matching-mass inequality, 8B budget, or endpoint cover is passed in.
The edge weights are the *actual* finite-table maxima, expressed by an
attainment and dominance witness (automatic on a nonempty finite
full-support product alphabet). This theorem remains a finite-product
structural input, not a terminal variance-influence theorem.
-/

namespace Nightfall.Observability.ActualESGreedyCover

open Finset
open Nightfall.Observability.WeightedGreedy
open Nightfall.Observability.WeightedGreedyCover
open Nightfall.Observability.ActualESMatchingMass
open Nightfall.Observability.ActualESPairMatching

variable {E ι α : Type}
  [Fintype E] [DecidableEq E]
  [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- Genuine source-level matching cover, with the 8B cost generated
rather than supplied. Each edge is a distinct coordinate pair;
possible parallel edge indexes are permitted here, but the later
conditional-section identification requires a simple-graph condition
so the assigned neighbors are distinct. -/
theorem actual_source_greedy_endpoint_cover
    [Nonempty α]
    (p : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : Nightfall.ProductSpace.EfronStein.ESDegreeLE p f 2)
    (base : ι → α)
    (u v : E → ι) (T : Finset E)
    (hends : ∀ e ∈ T, u e ≠ v e)
    (w : E → ℝ)
    (hwitness : ∀ e ∈ T, ∃ s t : α,
      w e = |actualPairKernel p f base (u e) (v e) s t|)
    (hwmax : ∀ e ∈ T, ∀ s t : α,
      |actualPairKernel p f base (u e) (v e) s t| ≤ w e)
    (B : ℝ) (hf : ∀ x, |f x| ≤ B) :
    ∃ c : ι → ℝ,
      (∀ i, 0 ≤ c i) ∧
      (∑ i : ι, c i) ≤ 8 * B ∧
      (∀ e ∈ T, ∀ s t : α,
        |actualPairKernel p f base (u e) (v e) s t| ≤
          max (c (u e)) (c (v e))) := by
  have hw : ∀ e ∈ T, 0 ≤ w e := by
    intro e he
    obtain ⟨s, t, heq⟩ := hwitness e he
    rw [heq]
    exact abs_nonneg _
  have hmass : ∀ S : Finset E,
      S ⊆ T → IsMatching u v S → S.sum w ≤ 4 * B := by
    intro S hsub hmatch
    exact source_matching_mass_le_four
      p hp hp1 f hdegree base u v S hmatch
      (fun e he => hends e (hsub he)) w
      (fun e he => hwitness e (hsub he))
      B hf
  obtain ⟨c, hc, htotal, hdom⟩ :=
    matching_budget_to_endpoint_budget u v w T B hw hmass
  refine ⟨c, hc, htotal, ?_⟩
  intro e he s t
  exact (hwmax e he s t).trans (hdom e he)

end Nightfall.Observability.ActualESGreedyCover

import ActualSourceGeneralMatching
import ActualSourceAmplitudeRectangles
import WeightedGreedyMatching
import WeightedGreedyCover

/-!
# Actual-source 4B maximal matching amplitude and 8B greedy cover
Port of #424 + #430 to active Lean 4.36. Every pair-table weight is
constructed from the genuine original f and original product law.
The 4B/8B bounds are not supplied as premises. This module does not
yet compose the source energy/moment endpoint into terminal Q2.
-/

namespace Nightfall.Observability.ActualSourceMatchingCover

open Finset
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualSourceGeneralMatching
open Nightfall.Observability.ActualSourceQuadraticRectangles
open Nightfall.Observability.ActualSourceAmplitudeRectangles
open Nightfall.Observability.ActualSourcePairAmplitudes
open Nightfall.Observability.WeightedGreedy
open Nightfall.Observability.WeightedGreedyCover

variable {E ι α : Type} [Fintype E] [DecidableEq E]
  [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

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


/-- Exact global bound on the sum of the *attained original-source*
canonical pair amplitudes along every disjoint matching. The oriented
corners come from the source pair tables, not from supplied witnesses. -/
theorem source_attained_matching_amplitudes_le_four
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
    (∑ e ∈ S, pairAmplitudeWeight p f (u e) (v e)) ≤ 4 * B := by
  classical
  let uS : {e : E // e ∈ S} → ι := fun e => u e.val
  let vS : {e : E // e ∈ S} → ι := fun e => v e.val
  have hcorners (e : {t : E // t ∈ S}) :
      ∃ a0 a1 b0 b1 : α,
        pairAmplitudeWeight p f (uS e) (vS e) ≤
          sourceRectangle f base (uS e) (vS e) a0 a1 b0 b1 :=
    original_source_pair_amplitude_oriented_rectangle
      p hp hp1 f hdegree base (uS e) (vS e)
      (hne e.val e.property)
  choose a0 a1 b0 b1 hcorner using hcorners
  let left : {e : E // e ∈ S} → Bool → α := fun e bit =>
    if bit then a1 e else a0 e
  let right : {e : E // e ∈ S} → Bool → α := fun e bit =>
    if bit then b1 e else b0 e
  have htotal :
      (∑ e : {t : E // t ∈ S},
        sourceRectangle f base (uS e) (vS e)
          (a0 e) (a1 e) (b0 e) (b1 e)) ≤ 4 * B := by
    simpa [left, right] using
      (actual_source_general_matching_rectangles_le_four
        p hp1 f hdegree base uS vS
        (selected_matchingCoord_injective u v S hne hmatch)
        left right B hf)
  have hsum :
      (∑ e : {t : E // t ∈ S},
        pairAmplitudeWeight p f (uS e) (vS e)) ≤
      (∑ e : {t : E // t ∈ S},
        sourceRectangle f base (uS e) (vS e)
          (a0 e) (a1 e) (b0 e) (b1 e)) := by
    exact Finset.sum_le_sum (fun e _ => hcorner e)
  have hreindex :
      (∑ e ∈ S, pairAmplitudeWeight p f (u e) (v e)) =
      (∑ e : {t : E // t ∈ S},
        pairAmplitudeWeight p f (uS e) (vS e)) := by
    simpa only [uS, vS] using
      (Finset.sum_attach S
        (fun e : E => pairAmplitudeWeight p f (u e) (v e))).symm
  exact hreindex.trans_le (hsum.trans htotal)

/-- Global actual-source 8B weighted endpoint-cover cost, with no
supplied matching, endpoint cost, or maximal amplitude assumptions. -/
theorem source_greedy_attained_endpoint_cover
    [Nonempty α]
    (p : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (base : ι → α)
    (u v : E → ι) (T : Finset E)
    (hne : ∀ e ∈ T, u e ≠ v e)
    (B : ℝ) (hf : ∀ x, |f x| ≤ B) :
    ∃ c : ι → ℝ,
      (∀ i, 0 ≤ c i) ∧
      (∑ i : ι, c i) ≤ 8 * B ∧
      (∀ e ∈ T,
        pairAmplitudeWeight p f (u e) (v e) ≤
          max (c (u e)) (c (v e))) := by
  let w : E → ℝ := fun e =>
    pairAmplitudeWeight p f (u e) (v e)
  have hw : ∀ e ∈ T, 0 ≤ w e := by
    intro e _
    exact pairAmplitudeWeight_nonneg p f (u e) (v e)
  have hmass : ∀ S : Finset E, S ⊆ T →
      IsMatching u v S → (S.sum w) ≤ 4 * B := by
    intro S hs hmatch
    exact source_attained_matching_amplitudes_le_four
      p hp hp1 f hdegree base u v S
      (fun e he => hne e (hs he))
      hmatch B hf
  exact matching_budget_to_endpoint_budget u v w T B hw hmass

end Nightfall.Observability.ActualSourceMatchingCover

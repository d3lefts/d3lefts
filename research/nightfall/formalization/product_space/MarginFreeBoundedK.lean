import MarginFreeProductDisintegration
import MarginFreeLargeGaps

/-!
# Bounded-coordinate two-product identification, source level

This terminal builds a bounded-size nonadaptive observation set from
the *actual coordinate marginals*, including zero atoms. Its high-TV
branch applies the existing source Hellinger/Bhattacharyya certificate
to observed product measures, with all unqueried symbols pinned to a
dummy alphabet element. Its low-TV branch is the independently certified
observed-source disintegration theorem.

The existence of an optimal likelihood decision from overlap, the
pairwise tournament, and the quantum-oracle/BDST product simulator are
separate certification interfaces.
-/

namespace Nightfall.MarginFreeBoundedK

open Finset
open Nightfall.ProductSpace.Transfer
open Nightfall.ProductSpace.RowBound
open Nightfall.ProductSpace.Influence
open Nightfall.MarginFreeTVHellinger
open Nightfall.MarginFreeBhattacharyya
open Nightfall.MarginFreeLargeGaps
open Nightfall.MarginFreeDisintegration
open Nightfall.ComponentIdentification

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- A transcript obtained by revealing only S has Bayes overlap at most ζ
if the K=|S| individual coordinates have TV at least γ and
log(1/ζ) ≤ Kγ²/2. This avoids subtype product-law isomorphisms and
allows every unqueried coordinate to be a fixed dummy symbol. -/
theorem high_tv_observed_bayes_error
    (S : Finset ι) (a0 : α) (p q : ι → α → ℝ)
    (hp0 : ∀ i a, 0 ≤ p i a) (hq0 : ∀ i a, 0 ≤ q i a)
    (hp1 : ∀ i, ∑ a, p i a = 1)
    (hq1 : ∀ i, ∑ a, q i a = 1)
    (γ ζ : ℝ) (hγ : 0 < γ) (hζ : 0 < ζ)
    (hlarge : ∀ i ∈ S, γ ≤ tvd (p i) (q i))
    (hbudget : Real.log (1 / ζ) ≤ (S.card : ℝ) * (γ ^ 2 / 2)) :
    (∑ x : ι → α,
      min (prodMass (observedLaw S a0 p) x)
        (prodMass (observedLaw S a0 q) x)) ≤ ζ := by
  let P := observedLaw S a0 p
  let Q := observedLaw S a0 q
  have hP0 := observedLaw_nonneg S a0 p hp0
  have hQ0 := observedLaw_nonneg S a0 q hq0
  have hP1 := observedLaw_sum_one S a0 p hp1
  have hQ1 := observedLaw_sum_one S a0 q hq1
  let BC : ι → ℝ := fun i => ∑ a : α, Real.sqrt (P i a * Q i a)
  let H : ι → ℝ := fun i => 1 - BC i
  have hH1 (i : ι) : H i ≤ 1 := by
    have hb : 0 ≤ BC i := by
      dsimp [BC]
      exact Finset.sum_nonneg (fun a _ => Real.sqrt_nonneg _)
    dsimp [H]
    linarith
  have hH0 (i : ι) : 0 ≤ H i := by
    have htv := tv_sq_le_two_hellinger
      (P i) (Q i) (hP0 i) (hQ0 i) (hP1 i) (hQ1 i)
    dsimp [H, BC]
    nlinarith [sq_nonneg
      (1 - ∑ a : α, min (P i a) (Q i a))]
  have hHbig (i : ι) (hi : i ∈ S) : γ ^ 2 / 2 ≤ H i := by
    have ht : γ ≤ 1 - ∑ a : α, min (P i a) (Q i a) := by
      simpa [P, Q, observedLaw, hi, tvd] using hlarge i hi
    have ht0 : 0 ≤ 1 - ∑ a : α, min (P i a) (Q i a) :=
      (le_of_lt hγ).trans ht
    have hmult : 0 ≤
        ((1 - ∑ a : α, min (P i a) (Q i a)) - γ) *
        ((1 - ∑ a : α, min (P i a) (Q i a)) + γ) :=
      mul_nonneg (sub_nonneg.mpr ht)
        (add_nonneg ht0 (le_of_lt hγ))
    have htv := tv_sq_le_two_hellinger
      (P i) (Q i) (hP0 i) (hQ0 i) (hP1 i) (hQ1 i)
    dsimp [H, BC]
    nlinarith [hmult, htv]
  have hsumS : (S.card : ℝ) * (γ ^ 2 / 2) ≤ ∑ i ∈ S, H i := by
    calc
      (S.card : ℝ) * (γ ^ 2 / 2) =
          ∑ _i ∈ S, (γ ^ 2 / 2 : ℝ) := by simp
      _ ≤ ∑ i ∈ S, H i :=
        Finset.sum_le_sum (fun i hi => hHbig i hi)
  have hsum : (S.card : ℝ) * (γ ^ 2 / 2) ≤ ∑ i : ι, H i := by
    calc
      _ ≤ ∑ i ∈ S, H i := hsumS
      _ ≤ ∑ i ∈ (Finset.univ : Finset ι), H i := by
        apply Finset.sum_le_sum_of_subset_of_nonneg
        · exact Finset.subset_univ S
        · intro i hi _
          exact hH0 i
  have haff := bayes_error_le_product_affinity P Q hP0 hQ0
  calc
    (∑ x : ι → α,
      min (prodMass (observedLaw S a0 p) x)
        (prodMass (observedLaw S a0 q) x)) ≤
      ∏ i : ι, BC i := by
        simpa [P, Q, BC, prodMass] using haff
    _ = ∏ i : ι, (1 - H i) := by
      apply Finset.prod_congr rfl
      intro i _
      dsimp [H]
      ring
    _ ≤ Real.exp (-(∑ i : ι, H i)) :=
      prod_one_sub_le_exp Finset.univ H (fun i _ => hH1 i)
    _ ≤ Real.exp (-Real.log (1 / ζ)) := by
      apply Real.exp_le_exp.mpr
      linarith
    _ = ζ := by
      rw [one_div, Real.log_inv, neg_neg, Real.exp_log hζ]

/-- Coordinates whose one-coordinate total variation strictly exceeds
the low-TV threshold. Defined *before* observing any input responses. -/
noncomputable def largeTVCoords
    (p q : ι → α → ℝ) (γ : ℝ) : Finset ι :=
  Finset.univ.filter (fun i => γ < tvd (p i) (q i))

theorem largeTVCoords_small_complement
    (p q : ι → α → ℝ) (γ : ℝ) :
    ∀ i, i ∉ largeTVCoords p q γ → tvd (p i) (q i) ≤ γ := by
  classical
  intro i hi
  by_contra hn
  have h : γ < tvd (p i) (q i) := lt_of_not_ge hn
  apply hi
  simp [largeTVCoords, h]

theorem largeTVCoords_large_members
    (p q : ι → α → ℝ) (γ : ℝ) :
    ∀ i ∈ largeTVCoords p q γ, γ ≤ tvd (p i) (q i) := by
  classical
  intro i hi
  have h : γ < tvd (p i) (q i) := by
    simpa [largeTVCoords] using hi
  exact le_of_lt h

/-- FINITE ACTUAL-SOURCE BOUNDED-K CERTIFICATE.

Given the separately sourced low-TV center-concentration hypotheses,
the theorem *constructs an observation set* A of at most K coordinates
whose Bayes overlap is at most the larger of the high-TV exponential
test budget ζ and the low-TV failure/margin budget.

No minimum atom probability, adaptive query, or hidden error premise
about the selected test enters the proof.
-/
theorem bounded_K_component_overlap
    (a0 : α) (p q : ι → α → ℝ)
    (hp0 : ∀ i a, 0 ≤ p i a) (hq0 : ∀ i a, 0 ≤ q i a)
    (hp1 : ∀ i, ∑ a, p i a = 1)
    (hq1 : ∀ i, ∑ a, q i a = 1)
    (γ ζ ε : ℝ) (hγ : 0 < γ) (hζ : 0 < ζ) (hε : 0 ≤ ε)
    (K : ℕ)
    (hK : Real.log (1 / ζ) ≤ (K : ℝ) * (γ ^ 2 / 2))
    (d : ℕ) (hd : 1 ≤ d) (f : (ι → α) → ℝ)
    (hf : ∀ x, 0 ≤ f x ∧ f x ≤ 1)
    (hdegree : HasProdDegreeLE f d)
    (hbudget : 16 * (d : ℝ) ^ 2 * γ ≤ ε)
    (u v ρP ρQ : ℝ)
    (hu : 0 ≤ u ∧ u ≤ 1) (hv : 0 ≤ v ∧ v ≤ 1)
    (hsep : 3 * ε < |u - v|)
    (hfailP : ∑ y ∈ (Finset.univ : Finset (ι → α)).filter
      (fun y => ε < |f y - u|), prodMass p y ≤ ρP)
    (hfailQ : ∑ y ∈ (Finset.univ : Finset (ι → α)).filter
      (fun y => ε < |f y - v|), prodMass q y ≤ ρQ) :
    ∃ A : Finset ι, A.card ≤ K ∧
      (∑ x : ι → α, min (prodMass (observedLaw A a0 p) x)
        (prodMass (observedLaw A a0 q) x)) ≤
        max ζ ((ρP + ρQ) / (|u - v| - 3 * ε)) := by
  classical
  let L := largeTVCoords p q γ
  by_cases hcard : K ≤ L.card
  · obtain ⟨S, hSL, hSCard⟩ :=
      Finset.exists_subset_card_eq (s := L) hcard
    have hlarge : ∀ i ∈ S, γ ≤ tvd (p i) (q i) := by
      intro i hi
      exact largeTVCoords_large_members p q γ i (hSL hi)
    have hbudgetS : Real.log (1 / ζ) ≤
        (S.card : ℝ) * (γ ^ 2 / 2) := by
      simpa [hSCard] using hK
    refine ⟨S, by omega, ?_⟩
    exact (high_tv_observed_bayes_error S a0 p q
      hp0 hq0 hp1 hq1 γ ζ hγ hζ hlarge hbudgetS).trans
      (le_max_left _ _)
  · have hLK : L.card ≤ K := by omega
    have hsmall : ∀ i, i ∉ L → tvd (p i) (q i) ≤ γ := by
      intro i hi
      exact largeTVCoords_small_complement p q γ i hi
    refine ⟨L, hLK, ?_⟩
    exact (observed_component_low_tv L a0 p q
      hp0 hq0 hp1 hq1 γ ε hγ hε hsmall
      d hd f hf hdegree hbudget
      u v ρP ρQ hu hv hsep hfailP hfailQ).trans
      (le_max_right _ _)

end Nightfall.MarginFreeBoundedK

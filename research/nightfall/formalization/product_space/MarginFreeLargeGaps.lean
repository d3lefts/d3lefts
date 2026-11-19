import Mathlib
import MarginFreeTVHellinger

/-!
# Nonadaptive large-TV component identification: actual source distributions

For finite product measures, including zero atoms, if every coordinate
has overlap-deficit TV at least γ and the number of such coordinates is
large enough, the exact two-sided Bayes classification error is ≤ δ.

The proof composes the genuine finite-product Bhattacharyya tensorization,
the source-level TV² ≤ 2H² inequality and the Lean-checked exponential
product bound; no Hellinger premise is passed in by the caller.
-/

namespace Nightfall.MarginFreeLargeGaps

open Finset
open Nightfall.ComponentIdentification
open Nightfall.MarginFreeBhattacharyya
open Nightfall.MarginFreeTVHellinger

variable {ι α : Type*} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- Fully sourced high-TV branch: K independent coordinates each with
TV >= γ yield two-sided Bayes error <= δ for Kγ²/2 >= log(1/δ).
No positive minimum atom is assumed. -/
theorem high_tv_product_bayes_error
    (p q : ι → α → ℝ)
    (hp0 : ∀ i a, 0 ≤ p i a) (hq0 : ∀ i a, 0 ≤ q i a)
    (hp1 : ∀ i, ∑ a, p i a = 1)
    (hq1 : ∀ i, ∑ a, q i a = 1)
    (γ δ : ℝ) (hγ : 0 < γ) (hδ : 0 < δ)
    (hlarge : ∀ i, γ ≤ 1 - ∑ a : α, min (p i a) (q i a))
    (hK : Real.log (1 / δ) ≤ (Fintype.card ι : ℝ) * (γ ^ 2 / 2)) :
    (∑ x : ι → α, min (∏ i : ι, p i (x i)) (∏ i : ι, q i (x i))) ≤ δ := by
  let BC : ι → ℝ := fun i => ∑ a : α, Real.sqrt (p i a * q i a)
  have h1 : ∀ i ∈ (Finset.univ : Finset ι), (1 - BC i) ≤ 1 := by
    intro i _
    have hb : 0 ≤ BC i := by
      dsimp [BC]
      exact Finset.sum_nonneg (fun a _ => Real.sqrt_nonneg _)
    linarith
  have hη : ∀ i ∈ (Finset.univ : Finset ι), γ ^ 2 / 2 ≤ 1 - BC i := by
    intro i _
    have hTV := tv_sq_le_two_hellinger
      (p i) (q i) (hp0 i) (hq0 i) (hp1 i) (hq1 i)
    have ht : 0 ≤ 1 - ∑ a : α, min (p i a) (q i a) :=
      (le_of_lt hγ).trans (hlarge i)
    have hmult : 0 ≤
        ((1 - ∑ a : α, min (p i a) (q i a)) - γ) *
        ((1 - ∑ a : α, min (p i a) (q i a)) + γ) :=
      mul_nonneg (sub_nonneg.mpr (hlarge i)) (add_nonneg ht (le_of_lt hγ))
    dsimp [BC]
    nlinarith [hmult, hTV]
  have hk' : Real.log (1 / δ) ≤
      ((Finset.univ : Finset ι).card : ℝ) * (γ ^ 2 / 2) := by
    simpa only [Finset.card_univ] using hK
  have hh := hellinger_K_le (Finset.univ : Finset ι)
    (fun i => 1 - BC i) γ δ hδ h1 hη hk'
  have hprodid :
      (∏ i : ι, (1 - (1 - BC i))) = (∏ i : ι, BC i) := by
    apply Finset.prod_congr rfl
    intro i _
    ring
  rw [hprodid] at hh
  exact (bayes_error_le_product_affinity p q hp0 hq0).trans hh

end Nightfall.MarginFreeLargeGaps

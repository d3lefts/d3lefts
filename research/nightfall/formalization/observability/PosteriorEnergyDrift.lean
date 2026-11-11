import Mathlib

/-!
# Posterior Efron--Stein energy drift: exact interaction accounting

For a finite product's orthogonal ANOVA decomposition, let `w S` denote the
nonnegative variance of interaction component `S`. Revealing coordinates `Q`
leaves the expected total influence `sum_S |S \ Q| w S`; the expected influence
of a fresh coordinate `i` is `sum_{S : i in S \ Q} w S`.

This file proves the exact subtraction identity at the ANOVA energy level,
for arbitrary interaction order and arbitrary real component energies.
It does not assert that the energy expressions have been derived from every
actual product observable or from arbitrary measurable posterior sections.
-/

namespace Nightfall.Observability.PosteriorEnergy

open Finset

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-- Expected posterior sum of squared-resampling coordinate influences,
expressed in orthogonal ANOVA interaction energies. -/
noncomputable def remainingTotal (w : Finset ι → ℝ) (Q : Finset ι) : ℝ :=
  ∑ S : Finset ι, ((S \ Q).card : ℝ) * w S

/-- Expected influence of a fresh coordinate i after revealing Q. -/
noncomputable def remainingInf (w : Finset ι → ℝ) (Q : Finset ι) (i : ι) : ℝ :=
  ∑ S : Finset ι, (if i ∈ S \ Q then w S else 0)

/-- Revealing i removes exactly one active coordinate from every
interaction containing it. -/
theorem card_remaining_insert (S Q : Finset ι) (i : ι) :
    ((S \ insert i Q).card : ℝ) + (if i ∈ S \ Q then 1 else 0) =
      ((S \ Q).card : ℝ) := by
  have heq : S \ insert i Q = (S \ Q).erase i := by
    ext j
    simp only [Finset.mem_sdiff, Finset.mem_insert, Finset.mem_erase]
    tauto
  rw [heq]
  by_cases h : i ∈ S \ Q
  · simp only [if_pos h]
    have hc : ((S \ Q).erase i).card + 1 = (S \ Q).card := by
      rw [Finset.card_erase_of_mem h]
      omega
    exact_mod_cast hc
  · simp only [if_neg h]
    rw [Finset.erase_eq_of_not_mem h]
    simp

/-- Exact expected posterior total-influence descent in ANOVA energies.
Unlike a variance-only decrement, it remains valid for pair interactions. -/
theorem remainingTotal_insert_add_influence
    (w : Finset ι → ℝ) (Q : Finset ι) (i : ι) :
    remainingTotal w (insert i Q) + remainingInf w Q i =
      remainingTotal w Q := by
  unfold remainingTotal remainingInf
  rw [← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro S _
  have h := card_remaining_insert S Q i
  by_cases hi : i ∈ S \ Q
  · simp only [if_pos hi] at h ⊢
    calc
      ↑(S \ insert i Q).card * w S + w S =
        (↑(S \ insert i Q).card + 1) * w S := by ring
      _ = ↑(S \ Q).card * w S := by rw [h]
  · simp only [if_neg hi] at h ⊢
    rw [add_zero] at h ⊢
    rw [h]

theorem remainingTotal_insert_eq_sub
    (w : Finset ι → ℝ) (Q : Finset ι) (i : ι) :
    remainingTotal w (insert i Q) =
      remainingTotal w Q - remainingInf w Q i := by
  linarith [remainingTotal_insert_add_influence w Q i]

theorem remainingInf_nonneg
    (w : Finset ι → ℝ) (Q : Finset ι) (i : ι)
    (hw : ∀ S, 0 ≤ w S) : 0 ≤ remainingInf w Q i := by
  unfold remainingInf
  apply Finset.sum_nonneg
  intro S _
  split_ifs with h
  · exact hw S
  · exact le_refl 0

theorem remainingTotal_nonneg
    (w : Finset ι → ℝ) (Q : Finset ι)
    (hw : ∀ S, 0 ≤ w S) : 0 ≤ remainingTotal w Q := by
  unfold remainingTotal
  apply Finset.sum_nonneg
  intro S _
  exact mul_nonneg (Nat.cast_nonneg _) (hw S)

theorem remainingTotal_empty (w : Finset ι → ℝ) :
    remainingTotal w ∅ = ∑ S : Finset ι, (S.card : ℝ) * w S := by
  simp [remainingTotal]

theorem remainingInf_revealed
    (w : Finset ι → ℝ) (Q : Finset ι) (i : ι) (hi : i ∈ Q) :
    remainingInf w Q i = 0 := by
  unfold remainingInf
  apply Finset.sum_eq_zero
  intro S _
  have hnot : i ∉ S \ Q := by simp [hi]
  simp [hnot]

end Nightfall.Observability.PosteriorEnergy

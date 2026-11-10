import Mathlib

/-!
NIGHTFALL: Exact activation of ANOVA interaction energies.

Source: Wright, Certificate Engine v3, adaptive versus nonadaptive
observation. This formalizes finite combinatorial energy-activation
identities given an interaction-energy table. It does not formalize the
analytic Hoeffding--Efron--Stein decomposition, arbitrary products, or
conditional expectations. Classical ANOVA/Sobol algebra, no novelty claim.
-/

namespace Nightfall.Adaptive

open Finset

variable {α : Type*} [Fintype α] [DecidableEq α]

/-- Variance explained by a set of observations under a given ANOVA
interaction-energy table. The probability-space derivation of the table
is a separate obligation. -/
def explainedEnergy (energy : Finset α → ℝ) (S : Finset α) : ℝ :=
  ∑ T : Finset α, if T ⊆ S then energy T else 0

theorem explainedEnergy_mono (energy : Finset α → ℝ)
    (hnonneg : ∀ T, 0 ≤ energy T) {S U : Finset α}
    (hsub : S ⊆ U) :
    explainedEnergy energy S ≤ explainedEnergy energy U := by
  unfold explainedEnergy
  apply Finset.sum_le_sum
  intro T _
  by_cases hs : T ⊆ S
  · have hu : T ⊆ U := Finset.Subset.trans hs hsub
    simp [hs, hu]
  · by_cases hu : T ⊆ U
    · simpa [hs, hu] using hnonneg T
    · simp [hs, hu]

/-- One-step gain equals the energies of newly activated interactions. -/
theorem explainedEnergy_gain_raw (energy : Finset α → ℝ)
    (S : Finset α) (i : α) :
    explainedEnergy energy (insert i S) - explainedEnergy energy S =
      ∑ T : Finset α,
        if T ⊆ insert i S ∧ ¬ T ⊆ S then energy T else 0 := by
  unfold explainedEnergy
  rw [← Finset.sum_sub_distrib]
  apply Finset.sum_congr rfl
  intro T _
  by_cases hs : T ⊆ S
  · have hi : T ⊆ insert i S := Finset.Subset.trans hs (Finset.subset_insert i S)
    simp [hs, hi]
  · by_cases hi : T ⊆ insert i S
    · simp [hs, hi]
    · simp [hs, hi]

private theorem subset_insert_iff_erase (S T : Finset α) (i : α) :
    T ⊆ insert i S ↔ T.erase i ⊆ S := by
  constructor
  · intro h j hj
    have hne : j ≠ i := (Finset.mem_erase.mp hj).1
    have hmem : j ∈ T := (Finset.mem_erase.mp hj).2
    rcases Finset.mem_insert.mp (h hmem) with heq | hS
    · exact False.elim (hne heq)
    · exact hS
  · intro h j hj
    by_cases hji : j = i
    · exact Finset.mem_insert.mpr (Or.inl hji)
    · exact Finset.mem_insert.mpr
        (Or.inr (h (Finset.mem_erase.mpr ⟨hji, hj⟩)))

/-- Incremental explained-variance identity under finite ANOVA energies. -/
theorem explainedEnergy_gain (energy : Finset α → ℝ)
    (S : Finset α) (i : α) (hi : i ∉ S) :
    explainedEnergy energy (insert i S) - explainedEnergy energy S =
      ∑ T : Finset α,
        if i ∈ T ∧ T.erase i ⊆ S then energy T else 0 := by
  rw [explainedEnergy_gain_raw]
  apply Finset.sum_congr rfl
  intro T _
  have hiff :
      (T ⊆ insert i S ∧ ¬ T ⊆ S) ↔
      (i ∈ T ∧ T.erase i ⊆ S) := by
    constructor
    · intro ⟨hnew, hold⟩
      have hit : i ∈ T := by
        by_contra hn
        apply hold
        intro j hj
        rcases Finset.mem_insert.mp (hnew hj) with heq | hS
        · subst j
          exact False.elim (hn hj)
        · exact hS
      exact ⟨hit, (subset_insert_iff_erase S T i).mp hnew⟩
    · intro ⟨hit, hrest⟩
      constructor
      · exact (subset_insert_iff_erase S T i).mpr hrest
      · intro hsubset
        exact hi (hsubset hit)
  simp only [hiff]

/-- Explained energy is supermodular for nonnegative interaction energies. -/
theorem explainedEnergy_supermodular (energy : Finset α → ℝ)
    (hnonneg : ∀ T, 0 ≤ energy T) {S U : Finset α} (hsub : S ⊆ U)
    (i : α) (hi : i ∉ U) :
    explainedEnergy energy (insert i S) - explainedEnergy energy S ≤
    explainedEnergy energy (insert i U) - explainedEnergy energy U := by
  have hnot : i ∉ S := by
    intro hs
    exact hi (hsub hs)
  rw [explainedEnergy_gain energy S i hnot,
      explainedEnergy_gain energy U i hi]
  apply Finset.sum_le_sum
  intro T _
  by_cases hs : i ∈ T ∧ T.erase i ⊆ S
  · have hu : i ∈ T ∧ T.erase i ⊆ U :=
      ⟨hs.1, Finset.Subset.trans hs.2 hsub⟩
    simp [hs, hu]
  · by_cases hu : i ∈ T ∧ T.erase i ⊆ U
    · simpa [hs, hu] using hnonneg T
    · simp [hs, hu]

end Nightfall.Adaptive

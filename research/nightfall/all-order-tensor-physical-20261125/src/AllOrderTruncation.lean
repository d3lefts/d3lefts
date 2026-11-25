import AllOrderFourier
import Mathlib.Analysis.SpecialFunctions.Sqrt
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum

namespace Nightfall.AllOrder
open Finset
variable {I A : Type*} [Fintype I] [DecidableEq I] [Fintype A] [DecidableEq A]

noncomputable def rowNorm (c : (I → A) → ℝ) (i : I) (a : A) : ℝ :=
    Real.sqrt (∑ b : I → A with b i = a, (c b)^2)

theorem rowNorm_nonneg (c : (I → A) → ℝ) (i : I) (a : A) : 0 ≤ rowNorm c i a := Real.sqrt_nonneg _

theorem rowNorm_sq (c : (I → A) → ℝ) (i : I) (a : A) :
    (rowNorm c i a)^2 = ∑ b : I → A with b i = a, (c b)^2 := by
  unfold rowNorm
  apply Real.sq_sqrt
  exact Finset.sum_nonneg fun _ _ => sq_nonneg _

noncomputable def heavyLabels (c : (I → A) → ℝ) (i : I) (t : ℝ) : Finset A :=
  univ.filter (fun a => t < rowNorm c i a)

/-- Threshold heavy labels cost at most m when the row mixed norm is at most m*t. -/
theorem heavy_card (c : (I → A) → ℝ) (i : I) (t : ℝ) (m : ℕ) (ht : 0 < t)
    (hr : (∑ a, rowNorm c i a) ≤ (m : ℝ)*t) : (heavyLabels c i t).card ≤ m := by
  classical
  have h1 : (heavyLabels c i t).card • t ≤ ∑ a ∈ heavyLabels c i t, rowNorm c i a := by
    apply Finset.card_nsmul_le_sum
    intro a ha
    exact le_of_lt (Finset.mem_filter.mp ha).2
  have h2 : (∑ a ∈ heavyLabels c i t, rowNorm c i a) ≤ ∑ a, rowNorm c i a :=
    Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _) (fun a _ _ => rowNorm_nonneg c i a)
  rw [nsmul_eq_mul] at h1
  have h := (h1.trans h2).trans hr
  exact_mod_cast (le_of_mul_le_mul_right h ht)

noncomputable def lightPaths (c : (I → A) → ℝ) (i : I) (t : ℝ) : Finset (I → A) :=
  univ.filter (fun b => b i ∉ heavyLabels c i t)

/-- Single-slot truncation bound without sorting or assuming distinct norms. -/
theorem light_slot_energy (c : (I → A) → ℝ) (i : I) (t M : ℝ) (ht : 0 ≤ t)
    (hr : (∑ a, rowNorm c i a) ≤ M) :
    (∑ b ∈ lightPaths c i t, (c b)^2) ≤ t*M := by
  classical
  have hsplit : (∑ b ∈ lightPaths c i t, (c b)^2) =
      ∑ a ∈ (univ : Finset A).filter (fun a => a ∉ heavyLabels c i t),
        ∑ b : I → A with b i = a, (c b)^2 := by
    rw [Finset.sum_fiberwise_eq_sum_filter (s := univ) (g := fun b : I → A => b i)]
    simp [lightPaths]
  rw [hsplit]
  simp_rw [← rowNorm_sq]
  calc
    _ ≤ ∑ a ∈ (univ : Finset A).filter (fun a => a ∉ heavyLabels c i t), t * rowNorm c i a := by
      apply Finset.sum_le_sum
      intro a ha
      have hle : rowNorm c i a ≤ t := by
        have hnot := (Finset.mem_filter.mp ha).2
        simpa [heavyLabels, not_lt] using hnot
      rw [pow_two]
      exact mul_le_mul_of_nonneg_right hle (rowNorm_nonneg c i a)
    _ = t * ∑ a ∈ (univ : Finset A).filter (fun a => a ∉ heavyLabels c i t), rowNorm c i a := by rw [Finset.mul_sum]
    _ ≤ t * M := mul_le_mul_of_nonneg_left ((Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _) (fun a _ _ => rowNorm_nonneg c i a)).trans hr) ht

/-- The exact union of selected original query labels. -/
noncomputable def selectedLabels (c : (I → A) → ℝ) (t : ℝ) : Finset A :=
  univ.biUnion (fun i => heavyLabels c i t)

theorem selected_card (c : (I → A) → ℝ) (t : ℝ) (m : ℕ) (ht : 0 < t)
    (hr : ∀ i, (∑ a, rowNorm c i a) ≤ (m : ℝ)*t) :
    (selectedLabels c t).card ≤ Fintype.card I * m := by
  classical
  unfold selectedLabels
  calc
    _ ≤ ∑ i : I, (heavyLabels c i t).card := Finset.card_biUnion_le
    _ ≤ ∑ _ : I, m := Finset.sum_le_sum fun i _ => heavy_card c i t m ht (hr i)
    _ = _ := by simp

noncomputable def residualPaths (c : (I → A) → ℝ) (t : ℝ) : Finset (I → A) :=
  univ.biUnion (fun i => lightPaths c i t)

/-- A path omitted by the threshold truncation is charged to at least one
    light slot; squared coefficient mass pays for the union, not the number of tuples. -/
theorem residual_energy (c : (I → A) → ℝ) (t M : ℝ) (ht : 0 ≤ t)
    (hr : ∀ i, (∑ a, rowNorm c i a) ≤ M) :
    (∑ b ∈ residualPaths c t, (c b)^2) ≤ (Fintype.card I : ℝ) * (t*M) := by
  classical
  unfold residualPaths
  calc
    _ ≤ ∑ i : I, ∑ b ∈ lightPaths c i t, (c b)^2 := by
      generalize (Finset.univ : Finset I) = U
      induction U using Finset.induction_on with
      | empty => simp
      | @insert i U hi ih =>
        rw [Finset.biUnion_insert, Finset.sum_insert hi]
        have h := Finset.sum_union_inter (s₁ := lightPaths c i t)
          (s₂ := U.biUnion (fun j => lightPaths c j t)) (f := fun b => (c b)^2)
        have hn : 0 ≤ ∑ b ∈ lightPaths c i t ∩ U.biUnion (fun j => lightPaths c j t), (c b)^2 :=
          Finset.sum_nonneg fun _ _ => sq_nonneg _
        linarith
    _ ≤ ∑ _ : I, t*M := Finset.sum_le_sum fun i _ => light_slot_energy c i t M ht (hr i)
    _ = _ := by simp

/-- Every retained path uses only original labels in the charged query set. -/
theorem retained_uses_selected (c : (I → A) → ℝ) (t : ℝ) (b : I → A)
    (hb : b ∉ residualPaths c t) (i : I) : b i ∈ selectedLabels c t := by
  classical
  have hh : b i ∈ heavyLabels c i t := by
    by_contra h
    apply hb
    exact Finset.mem_biUnion.mpr ⟨i, Finset.mem_univ i, Finset.mem_filter.mpr ⟨Finset.mem_univ b, h⟩⟩
  exact Finset.mem_biUnion.mpr ⟨i, Finset.mem_univ i, hh⟩

#print axioms rowNorm_sq
#print axioms heavy_card
#print axioms light_slot_energy
#print axioms selected_card
#print axioms residual_energy
#print axioms retained_uses_selected
end Nightfall.AllOrder

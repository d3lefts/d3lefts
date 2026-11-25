import Mathlib.Analysis.Real.Sqrt
import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.NormNum

/-! Exact double-slot charge and coefficient arithmetic for the 28 bound. -/
namespace Nightfall.StructuralInformation.T2DoubleLightCharge
open Finset
variable {T : Type*} [DecidableEq T]

theorem double_light_energy (S A B C D : Finset T) (w : T → ℝ) (η : ℝ)
    (hw : ∀ t, 0 ≤ w t)
    (ha : ∑ t ∈ A, w t ≤ η) (hb : ∑ t ∈ B, w t ≤ η)
    (hc : ∑ t ∈ C, w t ≤ η) (hd : ∑ t ∈ D, w t ≤ η)
    (hdouble : ∀ t ∈ S, 2 ≤ (if t ∈ A then (1 : ℝ) else 0) +
      (if t ∈ B then 1 else 0) + (if t ∈ C then 1 else 0) + (if t ∈ D then 1 else 0)) :
    ∑ t ∈ S, w t ≤ 2*η := by
  classical
  have hcharge : ∀ X : Finset T,
      (∑ t ∈ S, (if t ∈ X then w t else 0)) ≤ ∑ t ∈ X, w t := by
    intro X
    rw [← Finset.sum_filter]
    exact Finset.sum_le_sum_of_subset_of_nonneg (fun t ht => (Finset.mem_filter.mp ht).2)
      (fun t _ _ => hw t)
  have h : 2 * (∑ t ∈ S, w t) ≤
      ∑ t ∈ S, ((if t ∈ A then w t else 0) + (if t ∈ B then w t else 0) +
        (if t ∈ C then w t else 0) + (if t ∈ D then w t else 0)) := by
    rw [Finset.mul_sum]
    apply Finset.sum_le_sum
    intro t ht
    have h := mul_le_mul_of_nonneg_right (hdouble t ht) (hw t)
    simpa only [add_mul, ite_mul, one_mul, zero_mul] using h
  simp only [Finset.sum_add_distrib] at h
  linarith [hcharge A, hcharge B, hcharge C, hcharge D]

theorem pair_energy_coefficient_le_28 :
    12 + 6 * Real.sqrt 2 + 4 * Real.sqrt 3 ≤ (28 : ℝ) := by
  have hs₂ : Real.sqrt (2 : ℝ) ≤ (3 / 2 : ℝ) := by
    nlinarith [Real.sq_sqrt (by norm_num : (0 : ℝ) ≤ 2), Real.sqrt_nonneg (2 : ℝ)]
  have hs₃ : Real.sqrt (3 : ℝ) ≤ (7 / 4 : ℝ) := by
    nlinarith [Real.sq_sqrt (by norm_num : (0 : ℝ) ≤ 3), Real.sqrt_nonneg (3 : ℝ)]
  linarith

#print axioms double_light_energy
#print axioms pair_energy_coefficient_le_28
end Nightfall.StructuralInformation.T2DoubleLightCharge

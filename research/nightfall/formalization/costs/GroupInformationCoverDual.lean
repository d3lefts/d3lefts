import Mathlib

/-!
# NIGHTFALL — group information-cover LP certificates (Pillar 5)

General exact primal/dual weak duality, with *the very group incidence matrix*
used by the source A2 oracle. Demands are reciprocal one-coordinate KL rates.
No stochastic KL chain rule, Bayes-risk reduction, sequential stopping, or
matching asymptotic expected-cost construction is claimed by this module.
-/

namespace Nightfall.InformationCover

open Finset

variable {I Q : Type*} [Fintype I] [Fintype Q]

/-- Each paid group q returns fresh reports for the members of G q. -/
noncomputable def load (G : Q → I → Prop) (x : Q → ℝ) (i : I) : ℝ := by
  classical
  exact ∑ q, if G q i then x q else 0

/-- Total dual price assigned to a group. -/
noncomputable def groupPrice (G : Q → I → Prop) (y : I → ℝ) (q : Q) : ℝ := by
  classical
  exact ∑ i, if G q i then y i else 0

/-- Exact, source-model group fractional-cover weak duality.
The only hypotheses are nonnegative primal/dual variables and the
original group-incidence primal/dual constraints. -/
theorem group_information_cover_weak_duality
    (G : Q → I → Prop)
    (demand : I → ℝ) (c : Q → ℝ)
    (x : Q → ℝ) (y : I → ℝ)
    (hx : ∀ q, 0 ≤ x q)
    (hy : ∀ i, 0 ≤ y i)
    (hcover : ∀ i, demand i ≤ load G x i)
    (hdual : ∀ q, groupPrice G y q ≤ c q) :
    (∑ i, demand i * y i) ≤ ∑ q, c q * x q := by
  classical
  calc
    (∑ i, demand i * y i) ≤ ∑ i, (load G x i) * y i := by
      apply Finset.sum_le_sum
      intro i hi
      exact mul_le_mul_of_nonneg_right (hcover i) (hy i)
    _ = ∑ i, ∑ q, if G q i then x q * y i else 0 := by
      apply Finset.sum_congr rfl
      intro i hi
      unfold load
      rw [Finset.sum_mul]
      apply Finset.sum_congr rfl
      intro q hq
      by_cases h : G q i <;> simp [h]
    _ = ∑ q, ∑ i, if G q i then y i * x q else 0 := by
      rw [Finset.sum_comm]
      apply Finset.sum_congr rfl
      intro q hq
      apply Finset.sum_congr rfl
      intro i hi
      by_cases h : G q i <;> simp [h, mul_comm]
    _ = ∑ q, (groupPrice G y q) * x q := by
      apply Finset.sum_congr rfl
      intro q hq
      unfold groupPrice
      rw [Finset.sum_mul]
      apply Finset.sum_congr rfl
      intro i hi
      by_cases h : G q i <;> simp [h]
    _ ≤ ∑ q, c q * x q := by
      apply Finset.sum_le_sum
      intro q hq
      exact mul_le_mul_of_nonneg_right (hdual q) (hx q)

/-- The exact dual certificate appearing in A2:
Σ_i (y_i / d_i) ≤ Σ_q c_q x_q, whenever each coordinate is supplied
at least 1/d_i units of (expected) group exposure.
No positivity hypothesis on d_i is necessary for this algebraic implication;
the stochastic oracle supplies positivity when interpreting d_i as KL. -/
theorem reciprocal_KL_cover_weak_duality
    (G : Q → I → Prop) (d : I → ℝ) (c : Q → ℝ)
    (x : Q → ℝ) (y : I → ℝ)
    (hx : ∀ q, 0 ≤ x q)
    (hy : ∀ i, 0 ≤ y i)
    (hcover : ∀ i, 1 / d i ≤ load G x i)
    (hdual : ∀ q, groupPrice G y q ≤ c q) :
    (∑ i, y i / d i) ≤ ∑ q, c q * x q := by
  have h := group_information_cover_weak_duality
    G (fun i => 1 / d i) c x y hx hy hcover hdual
  calc
    (∑ i, y i / d i) = ∑ i, (1 / d i) * y i := by
      apply Finset.sum_congr rfl
      intro i hi
      simp [div_eq_mul_inv, mul_comm]
    _ ≤ ∑ q, c q * x q := h

end Nightfall.InformationCover

#print axioms Nightfall.InformationCover.group_information_cover_weak_duality
#print axioms Nightfall.InformationCover.reciprocal_KL_cover_weak_duality
#print Nightfall.InformationCover.reciprocal_KL_cover_weak_duality

import Mathlib

/-!
NIGHTFALL product-space influence: positive-coefficient weight optimization.
This isolates the substantive variational step in Certificate Engine Lemma 4.1.
All coordinate weights β_i and A_i are strictly positive. A complete
formalization must extend this to zero coefficients and establish the
reciprocal-weight premise from the transferred antipodal inequality.
-/

namespace Nightfall.ProductSpace

open Finset

/-- Optimal removal of fixed positive reciprocal weights. This is the
positive-support case of Wright's localized weight-removal lemma after
its Cauchy–Schwarz reduction, with V = V_A V_B and A_i = X_i Y_i. -/
theorem localized_weight_optimization_positive
    {n : ℕ} (β A : Fin n → ℝ) (V : ℝ)
    (hβ : ∀ i, 0 < β i)
    (hA : ∀ i, 0 < A i)
    (hV : 0 ≤ V)
    (hweighted : ∀ w : Fin n → ℝ, (∀ i, 0 < w i) →
      V ^ 2 ≤ (∑ i, w i * A i) * (∑ i, β i / w i)) :
    V ≤ ∑ i, Real.sqrt (β i) * Real.sqrt (A i) := by
  let w : Fin n → ℝ := fun i => Real.sqrt (β i) / Real.sqrt (A i)
  have hw : ∀ i, 0 < w i := by
    intro i
    exact div_pos (Real.sqrt_pos.2 (hβ i)) (Real.sqrt_pos.2 (hA i))
  have hleft : (∑ i, w i * A i) =
      ∑ i, Real.sqrt (β i) * Real.sqrt (A i) := by
    apply Finset.sum_congr rfl
    intro i _
    dsimp [w]
    have hs : Real.sqrt (A i) ≠ 0 := ne_of_gt (Real.sqrt_pos.2 (hA i))
    calc
      Real.sqrt (β i) / Real.sqrt (A i) * A i =
          Real.sqrt (β i) / Real.sqrt (A i) * (Real.sqrt (A i) ^ 2) := by
            rw [Real.sq_sqrt (le_of_lt (hA i))]
      _ = Real.sqrt (β i) * Real.sqrt (A i) := by
            field_simp
  have hright : (∑ i, β i / w i) =
      ∑ i, Real.sqrt (β i) * Real.sqrt (A i) := by
    apply Finset.sum_congr rfl
    intro i _
    dsimp [w]
    have hs : Real.sqrt (A i) ≠ 0 := ne_of_gt (Real.sqrt_pos.2 (hA i))
    have ht : Real.sqrt (β i) ≠ 0 := ne_of_gt (Real.sqrt_pos.2 (hβ i))
    calc
      β i / (Real.sqrt (β i) / Real.sqrt (A i)) =
          (Real.sqrt (β i) ^ 2) / (Real.sqrt (β i) / Real.sqrt (A i)) := by
            rw [Real.sq_sqrt (le_of_lt (hβ i))]
      _ = Real.sqrt (β i) * Real.sqrt (A i) := by
            field_simp
  have hsnonneg : 0 ≤ ∑ i, Real.sqrt (β i) * Real.sqrt (A i) := by
    apply Finset.sum_nonneg
    intro i _
    exact mul_nonneg (Real.sqrt_nonneg _) (Real.sqrt_nonneg _)
  have hq := hweighted w hw
  rw [hleft, hright] at hq
  nlinarith

end Nightfall.ProductSpace

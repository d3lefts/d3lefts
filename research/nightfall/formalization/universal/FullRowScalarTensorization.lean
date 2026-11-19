import Mathlib

/-!
# NIGHTFALL: scalar certificate-preserving direct-sum gate

This unconditional finite-sum REAL-ALGEBRA lemma formalizes the
coefficient-preserving aggregation of nonnegative component budgets.
It is NOT an end-to-end theorem deriving the original-source full-row
LP equality or canonical ANOVA disjointness. Those are analytic
source-level obligations and are separately replayed by the exact
rational original-product checker.

No universal real-valued fractional-row influence inequality is proved.
-/

namespace Nightfall.FullRowTensorization

open scoped BigOperators
open Finset

private theorem nonnegative_le_from_squares
    (a b : ℝ) (ha : 0 ≤ a) (hb : 0 ≤ b)
    (hsq : a ^ 2 ≤ b ^ 2) : a ≤ b := by
  by_contra hn
  have hba : b < a := lt_of_not_ge hn
  have hplus : 0 < a + b := by linarith
  have hprod : 0 < (a - b) * (a + b) :=
    mul_pos (sub_pos.mpr hba) hplus
  nlinarith

/-- If each independent block satisfies the SAME proposed quadratic
real-row coefficient with its actual maximum influence ≤M, the
aggregated variance and row cost satisfy that coefficient with no
dimension/degree/output-alphabet loss. **Component inequalities are
explicit hypotheses**, not derived from any arbitrary f here. -/
theorem scalar_full_row_direct_sum
    {ι : Type*} [Fintype ι]
    (K V : ι → ℝ) (M : ℝ)
    (hK : ∀ i, 0 ≤ K i)
    (hV : ∀ i, 0 ≤ V i)
    (hM : 0 ≤ M)
    (hcomponent : ∀ i, 4 * V i ^ 2 ≤ K i ^ 2 * M) :
    4 * (∑ i : ι, V i) ^ 2 ≤
      (∑ i : ι, K i) ^ 2 * M := by
  have hpoint (i : ι) :
      2 * V i ≤ K i * Real.sqrt M := by
    have ha : (0 : ℝ) ≤ 2 * V i := by
      exact mul_nonneg (by norm_num) (hV i)
    have hb : (0 : ℝ) ≤ K i * Real.sqrt M := by
      exact mul_nonneg (hK i) (Real.sqrt_nonneg M)
    have hsq : (2 * V i) ^ 2 ≤
        (K i * Real.sqrt M) ^ 2 := by
      calc
        (2 * V i) ^ 2 = 4 * V i ^ 2 := by ring
        _ ≤ K i ^ 2 * M := hcomponent i
        _ = (K i * Real.sqrt M) ^ 2 := by
          rw [mul_pow, Real.sq_sqrt hM]
    exact nonnegative_le_from_squares _ _ ha hb hsq
  have hsum :
      2 * (∑ i : ι, V i) ≤
      (∑ i : ι, K i) * Real.sqrt M := by
    calc
      2 * (∑ i : ι, V i) =
          ∑ i : ι, 2 * V i := by rw [Finset.mul_sum]
      _ ≤ ∑ i : ι, K i * Real.sqrt M :=
        Finset.sum_le_sum (by
          intro i hi
          exact hpoint i)
      _ = (∑ i : ι, K i) * Real.sqrt M := by
        rw [Finset.sum_mul]
  have ha : (0 : ℝ) ≤
      2 * (∑ i : ι, V i) := by
    exact mul_nonneg (by norm_num)
      (Finset.sum_nonneg (by intro i hi; exact hV i))
  have hb : (0 : ℝ) ≤
      (∑ i : ι, K i) * Real.sqrt M := by
    exact mul_nonneg
      (Finset.sum_nonneg (by intro i hi; exact hK i))
      (Real.sqrt_nonneg M)
  have hsq : (2 * (∑ i : ι, V i)) ^ 2 ≤
      ((∑ i : ι, K i) * Real.sqrt M) ^ 2 := by
    have hprod := mul_nonneg (sub_nonneg.mpr hsum)
      (add_nonneg ha hb)
    nlinarith
  calc
    4 * (∑ i : ι, V i) ^ 2 =
      (2 * (∑ i : ι, V i)) ^ 2 := by ring
    _ ≤ ((∑ i : ι, K i) * Real.sqrt M) ^ 2 := hsq
    _ = (∑ i : ι, K i) ^ 2 * M := by
      rw [mul_pow, Real.sq_sqrt hM]

#print axioms Nightfall.FullRowTensorization.scalar_full_row_direct_sum

end Nightfall.FullRowTensorization

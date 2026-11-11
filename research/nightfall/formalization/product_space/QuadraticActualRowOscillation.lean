import QuadraticHoeffdingBridge

/-!
# Actual-function degree-two oscillation directly from product-space rows

No quadratic polynomial representation, matching graph, fourth-moment
hypothesis, or positive atom floor is assumed.  The cost is deliberately
weaker than the 16B pointwise bound for explicit quadratic polynomials:
for normalized |f| <= 1 it is 8*pi^2.  The theorem provides a genuine
source-function link for the L1 Hilbert-section budget and is not the
variance-squared influence theorem.
-/

namespace Nightfall.Observability.QuadraticActualRows

open Finset
open Nightfall.ProductSpace
open Nightfall.ProductSpace.RowBound
open Nightfall.ProductSpace.EfronStein

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- An arbitrary bounded Hoeffding-degree-two finite-product observable
has a single nonnegative row of cost 4*pi^2 at each x that controls
*all pairs* of replacements at every coordinate, with cost 2*a_i.
No intermediate function-level quadratic representation is required. -/
theorem actual_degree_two_row_controls_all_sections
    (p : ι → α → ℝ)
    (hp1 : ∀ i, ∑ a, p i a = 1)
    (f : (ι → α) → ℝ)
    (hf : ∀ x, |f x| ≤ 1)
    (hdegree : ESDegreeLE p f 2)
    (x : ι → α) :
    ∃ a : ι → ℝ,
      (∀ i, 0 ≤ a i) ∧
      (∑ i : ι, a i) ≤ 4 * Real.pi ^ 2 ∧
      (∀ i s t,
        |f (Function.update x i s) - f (Function.update x i t)| ≤
          2 * a i) := by
  classical
  obtain ⟨a, ha0, hsum, hcov⟩ :=
    RowBound.product_row_bound 2 f hf
      ((prodDegree_iff_esDegree p hp1 f 2).mpr hdegree) x
  have hfour : Real.pi ^ 2 * (2 : ℝ) ^ 2 = 4 * Real.pi ^ 2 := by ring
  rw [hfour] at hsum
  refine ⟨a, ha0, hsum, ?_⟩
  have hsingle (i : ι) (s : α) :
      |f x - f (Function.update x i s)| ≤ a i := by
    calc
      |f x - f (Function.update x i s)| ≤
          ∑ j ∈ RowBound.disagree x (Function.update x i s), a j :=
            hcov (Function.update x i s)
      _ ≤ ∑ j ∈ ({i} : Finset ι), a j := by
          apply Finset.sum_le_sum_of_subset_of_nonneg
            (Nightfall.ProductSpace.Influence.disagree_update_single x i s)
          intro j _ _
          exact ha0 j
      _ = a i := by simp
  intro i s t
  calc
    |f (Function.update x i s) - f (Function.update x i t)| ≤
        |f (Function.update x i s) - f x| +
        |f x - f (Function.update x i t)| :=
          abs_sub_le _ _ _
    _ = |f x - f (Function.update x i s)| +
        |f x - f (Function.update x i t)| := by
          rw [abs_sub_comm (f (Function.update x i s)) (f x)]
    _ ≤ a i + a i := add_le_add (hsingle i s) (hsingle i t)
    _ = 2 * a i := by ring

/-- All simultaneous coordinatewise replacement differences, including
the pair of maximizing and minimizing actual coordinate values,
have total amplitude <= 8*pi^2 for every input configuration.
This is the previously missing genuine-f section-oscillation interface.
-/
theorem actual_degree_two_total_section_budget
    (p : ι → α → ℝ)
    (hp1 : ∀ i, ∑ a, p i a = 1)
    (f : (ι → α) → ℝ)
    (hf : ∀ x, |f x| ≤ 1)
    (hdegree : ESDegreeLE p f 2)
    (x y z : ι → α) :
    (∑ i : ι,
      (f (Function.update x i (y i)) -
       f (Function.update x i (z i)))) ≤
       8 * Real.pi ^ 2 := by
  classical
  obtain ⟨a, ha0, hcost, hsection⟩ :=
    actual_degree_two_row_controls_all_sections p hp1 f hf hdegree x
  calc
    (∑ i : ι, (f (Function.update x i (y i)) -
      f (Function.update x i (z i)))) ≤
        ∑ i : ι, 2 * a i := by
          apply Finset.sum_le_sum
          intro i _
          exact (le_abs_self _).trans (hsection i (y i) (z i))
    _ = 2 * (∑ i : ι, a i) := by rw [Finset.mul_sum]
    _ ≤ 2 * (4 * Real.pi ^ 2) :=
      mul_le_mul_of_nonneg_left hcost (by norm_num)
    _ = 8 * Real.pi ^ 2 := by ring

end Nightfall.Observability.QuadraticActualRows

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
  have hsum' : (∑ i : ι, a i) ≤ 4 * Real.pi ^ 2 := by
    calc
      (∑ i : ι, a i) ≤ Real.pi ^ 2 * ((2 : ℕ) : ℝ) ^ 2 := hsum
      _ = 4 * Real.pi ^ 2 := by norm_num; ring
  refine ⟨a, ha0, hsum', ?_⟩
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


/-- Stronger actual-function bridge: each whole-coordinate centered
resampling section is pointwise bounded by the SAME low-cost row
certificate. Uses arbitrary nonnegative normalized coordinate laws,
not fair-sign symmetry. This L-infinity control is a conservative
precursor to the Hilbert L2 section budget. -/
theorem actual_degree_two_centered_sections_from_rows
    (p : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, ∑ a, p i a = 1)
    (f : (ι → α) → ℝ)
    (hf : ∀ x, |f x| ≤ 1)
    (hdegree : ESDegreeLE p f 2)
    (x : ι → α) :
    ∃ a : ι → ℝ,
      (∀ i, 0 ≤ a i) ∧
      (∑ i : ι, a i) ≤ 4 * Real.pi ^ 2 ∧
      (∀ i s,
        |f (Function.update x i s) -
          (∑ t : α, p i t * f (Function.update x i t))| ≤
          2 * a i) := by
  classical
  obtain ⟨a, ha0, hcost, hsection⟩ :=
    actual_degree_two_row_controls_all_sections p hp1 f hf hdegree x
  refine ⟨a, ha0, hcost, ?_⟩
  intro i s
  have heq :
      f (Function.update x i s) -
        (∑ t : α, p i t * f (Function.update x i t)) =
      ∑ t : α, p i t *
        (f (Function.update x i s) - f (Function.update x i t)) := by
    calc
      _ = (∑ t : α, p i t) * f (Function.update x i s) -
        (∑ t : α, p i t * f (Function.update x i t)) := by
          rw [hp1 i]
          ring
      _ = ∑ t : α, p i t *
        (f (Function.update x i s) - f (Function.update x i t)) := by
          simp only [mul_sub, Finset.sum_sub_distrib, Finset.sum_mul]
  rw [heq]
  calc
    |∑ t : α, p i t *
        (f (Function.update x i s) - f (Function.update x i t))| ≤
      ∑ t : α, |p i t *
        (f (Function.update x i s) - f (Function.update x i t))| :=
          Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ t : α, p i t * (2 * a i) := by
          apply Finset.sum_le_sum
          intro t _
          rw [abs_mul, abs_of_nonneg (hp i t)]
          exact mul_le_mul_of_nonneg_left (hsection i s t) (hp i t)
    _ = 2 * a i := by
          rw [← Finset.sum_mul, hp1 i, one_mul]

/-- A genuinely source-derived Hilbert L2 section budget for every bounded,
degree-two finite-product observable, without a positive-atom assumption.

For each fixed configuration x, the square-root quantities are the
L2(p_i) norms of the actual centered coordinate resampling sections.
Unlike the earlier pointwise row estimate, this theorem carries the
coordinate probability weights and the Hilbert norm into the conclusion.

This remains a SECTION estimate, not the variance-squared influence
theorem; the matching/ownership and independent moment synthesis remain
necessary. -/
theorem actual_degree_two_hilbert_section_budget
    (p : ι → α → ℝ)
    (hp : ∀ i s, 0 ≤ p i s)
    (hp1 : ∀ i, ∑ s, p i s = 1)
    (f : (ι → α) → ℝ)
    (hf : ∀ x, |f x| ≤ 1)
    (hdegree : ESDegreeLE p f 2)
    (x : ι → α) :
    (∑ i : ι,
      Real.sqrt (∑ s : α, p i s *
        (f (Function.update x i s) -
         (∑ t : α, p i t * f (Function.update x i t))) ^ 2)) ≤
      8 * Real.pi ^ 2 := by
  classical
  obtain ⟨a, ha0, hcost, hcenter⟩ :=
    actual_degree_two_centered_sections_from_rows
      p hp hp1 f hf hdegree x
  let D : ι → α → ℝ := fun i s =>
    f (Function.update x i s) -
      (∑ t : α, p i t * f (Function.update x i t))
  let E : ι → ℝ := fun i =>
    ∑ s : α, p i s * (D i s) ^ 2
  change (∑ i : ι, Real.sqrt (E i)) ≤ 8 * Real.pi ^ 2
  have hD (i : ι) (s : α) : |D i s| ≤ 2 * a i :=
    hcenter i s
  have hDsq (i : ι) (s : α) : (D i s) ^ 2 ≤ (2 * a i) ^ 2 := by
    obtain ⟨hl, hu⟩ := abs_le.mp (hD i s)
    have hminus : 0 ≤ 2 * a i - D i s := sub_nonneg.mpr hu
    have hplus : 0 ≤ 2 * a i + D i s := by linarith
    nlinarith [mul_nonneg hminus hplus]
  have hEnonneg (i : ι) : 0 ≤ E i := by
    dsimp [E]
    apply Finset.sum_nonneg
    intro s _
    exact mul_nonneg (hp i s) (sq_nonneg _)
  have hEle (i : ι) : E i ≤ (2 * a i) ^ 2 := by
    dsimp [E]
    calc
      (∑ s : α, p i s * (D i s) ^ 2) ≤
        ∑ s : α, p i s * (2 * a i) ^ 2 := by
          apply Finset.sum_le_sum
          intro s _
          exact mul_le_mul_of_nonneg_left (hDsq i s) (hp i s)
      _ = (2 * a i) ^ 2 := by
        rw [← Finset.sum_mul, hp1 i, one_mul]
  have hroot (i : ι) : Real.sqrt (E i) ≤ 2 * a i := by
    have hsq := hEle i
    have hsqr : (Real.sqrt (E i)) ^ 2 = E i :=
      Real.sq_sqrt (hEnonneg i)
    have hrl : 0 ≤ Real.sqrt (E i) := Real.sqrt_nonneg _
    have har : 0 ≤ 2 * a i := by nlinarith [ha0 i]
    nlinarith
  calc
    (∑ i : ι, Real.sqrt (E i)) ≤
        ∑ i : ι, 2 * a i := by
          apply Finset.sum_le_sum
          intro i _
          exact hroot i
    _ = 2 * (∑ i : ι, a i) := by rw [Finset.mul_sum]
    _ ≤ 2 * (4 * Real.pi ^ 2) :=
      mul_le_mul_of_nonneg_left hcost (by norm_num)
    _ = 8 * Real.pi ^ 2 := by ring


end Nightfall.Observability.QuadraticActualRows

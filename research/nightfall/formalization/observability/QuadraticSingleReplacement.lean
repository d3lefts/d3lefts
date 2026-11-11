import QuadraticSwitchingIdentity

/-!
# Actual independent single-coordinate switching for degree-two functions

Unlike the abstract first-switch coefficient, this proves the identity
directly for the finite product observable, summing f(x with its i-th
coordinate replaced by y_i) - f(x).  Arbitrary finite alphabets and
arbitrary dense oriented nonloop pair interactions are supported.
-/

namespace Nightfall.Observability.QuadraticSwitching
open Finset

variable {ι α E : Type*}
  [Fintype ι] [DecidableEq ι] [Fintype E]

def singleSwitched (x y : ι → α) (j : ι) : ι → α :=
  fun i => if i = j then y i else x i

theorem single_term_replace_sum
    (h : ι → α → ℝ) (x y : ι → α) (j : ι) :
    (∑ i : ι, h i ((singleSwitched x y j) i)) =
      (∑ i : ι, h i (x i)) + (h j (y j) - h j (x j)) := by
  classical
  calc
    (∑ i : ι, h i ((singleSwitched x y j) i)) =
      ∑ i : ι, (h i (x i) +
        if i = j then h j (y j) - h j (x j) else 0) := by
          apply Finset.sum_congr rfl
          intro i _
          by_cases hij : i = j
          · subst i
            dsimp [singleSwitched]
            simp <;> ring
          · simp [singleSwitched, hij]
    _ = (∑ i : ι, h i (x i)) + (h j (y j) - h j (x j)) := by
          rw [Finset.sum_add_distrib]
          simp

theorem pair_term_one_replace
    (k : α → α → ℝ) (u v : ι) (hne : u ≠ v)
    (x y : ι → α) (j : ι) :
    k ((singleSwitched x y j) u) ((singleSwitched x y j) v) -
      k (x u) (x v) =
      (if u = j then k (y u) (x v) - k (x u) (x v) else 0) +
      (if v = j then k (x u) (y v) - k (x u) (x v) else 0) := by
  by_cases hu : u = j
  · have hv : v ≠ j := by
      intro h
      exact hne (hu.trans h.symm)
    simp [singleSwitched, hu, hv] <;> ring
  · by_cases hv : v = j
    · simp [singleSwitched, hu, hv] <;> ring
    · simp [singleSwitched, hu, hv]

theorem pair_term_replace_sum
    (k : α → α → ℝ) (u v : ι) (hne : u ≠ v)
    (x y : ι → α) :
    (∑ j : ι,
      (k ((singleSwitched x y j) u) ((singleSwitched x y j) v) -
        k (x u) (x v))) =
      k (y u) (x v) + k (x u) (y v) -
        2 * k (x u) (x v) := by
  calc
    (∑ j : ι,
      (k ((singleSwitched x y j) u) ((singleSwitched x y j) v) -
        k (x u) (x v))) =
      ∑ j : ι,
        ((if u = j then k (y u) (x v) - k (x u) (x v) else 0) +
         (if v = j then k (x u) (y v) - k (x u) (x v) else 0)) := by
          apply Finset.sum_congr rfl
          intro j _
          exact pair_term_one_replace k u v hne x y j
    _ = (k (y u) (x v) - k (x u) (x v)) +
        (k (x u) (y v) - k (x u) (x v)) := by
          rw [Finset.sum_add_distrib]
          simp
    _ = k (y u) (x v) + k (x u) (y v) -
        2 * k (x u) (x v) := by ring

theorem quadratic_one_replace_diff
    (u v : E → ι) (c : ℝ) (h : ι → α → ℝ)
    (k : E → α → α → ℝ) (x y : ι → α) (j : ι) :
    quadratic u v c h k (singleSwitched x y j) -
      quadratic u v c h k x =
      (h j (y j) - h j (x j)) +
      (∑ e : E,
        (k e ((singleSwitched x y j) (u e))
              ((singleSwitched x y j) (v e)) -
         k e (x (u e)) (x (v e)))) := by
  dsimp [quadratic]
  rw [single_term_replace_sum h x y j]
  rw [Finset.sum_sub_distrib]
  ring

/-- The actual sum of all one-coordinate replacement differences equals
the first-order coefficient of the unbiased simultaneous switch; no
independent-law or symmetry premise is passed to the theorem. -/
theorem quadratic_actual_switch_sum
    (u v : E → ι) (hne : ∀ e, u e ≠ v e)
    (c : ℝ) (h : ι → α → ℝ)
    (k : E → α → α → ℝ) (x y : ι → α) :
    (∑ j : ι,
      (quadratic u v c h k (singleSwitched x y j) -
       quadratic u v c h k x)) =
      firstSwitch u v h k x y := by
  calc
    (∑ j : ι,
      (quadratic u v c h k (singleSwitched x y j) -
       quadratic u v c h k x)) =
      ∑ j : ι,
        ((h j (y j) - h j (x j)) +
         (∑ e : E,
           (k e ((singleSwitched x y j) (u e))
             ((singleSwitched x y j) (v e)) -
           k e (x (u e)) (x (v e))))) := by
           apply Finset.sum_congr rfl
           intro j _
           exact quadratic_one_replace_diff u v c h k x y j
    _ = (∑ j : ι, (h j (y j) - h j (x j))) +
        (∑ e : E, ∑ j : ι,
          (k e ((singleSwitched x y j) (u e))
              ((singleSwitched x y j) (v e)) -
          k e (x (u e)) (x (v e)))) := by
           rw [Finset.sum_add_distrib, Finset.sum_comm]
    _ = (∑ j : ι, (h j (y j) - h j (x j))) +
        (∑ e : E, (k e (y (u e)) (x (v e)) +
          k e (x (u e)) (y (v e)) -
          2 * k e (x (u e)) (x (v e)))) := by
           apply congrArg (fun t : ℝ =>
             (∑ j : ι, (h j (y j) - h j (x j))) + t)
           apply Finset.sum_congr rfl
           intro e _
           exact pair_term_replace_sum (k e) (u e) (v e) (hne e) x y
    _ = firstSwitch u v h k x y := rfl

end Nightfall.Observability.QuadraticSwitching

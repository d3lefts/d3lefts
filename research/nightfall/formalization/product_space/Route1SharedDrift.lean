import Mathlib

/-! Finite arithmetic for amortizing one shared-information drift across many tasks. -/

namespace Nightfall.Route1SharedDrift

/-- A selected task can use the common information drop once; the remaining tasks
contribute nonnegative private drops. The common potential is not summed over tasks. -/
theorem selected_task_drift_le_total
    {K : Type*} [Fintype K] (p c : K → ℝ) (J J' mass : ℝ) (k : K)
    (hprivate : ∀ i, 0 ≤ p i - c i) (_hcommon : 0 ≤ J - J')
    (hbudget : mass ≤ p k - c k + (J - J')) :
    mass ≤ ((∑ i, p i) + J) - ((∑ i, c i) + J') := by
  classical
  have hselected : p k - c k ≤ ∑ i, (p i - c i) := by
    exact Finset.single_le_sum (fun i _ => hprivate i) (Finset.mem_univ k)
  rw [Finset.sum_sub_distrib] at hselected
  linarith

/-- Layerwise inequalities telescope. In a weighted tree, take `P t` to be the
sum of the weighted vertex potentials on layer `t` and `M t` to be the mass
charged on that layer. No bound on the number of tasks enters this summation. -/
theorem layer_drift_telescope (P M : ℕ → ℝ) (n : ℕ)
    (h : ∀ t < n, M t ≤ P t - P (t + 1)) :
    (∑ t ∈ Finset.range n, M t) ≤ P 0 - P n := by
  induction n with
  | zero => simp
  | succ n ih =>
    rw [Finset.sum_range_succ]
    have hprefix := ih (fun t ht => h t (by omega))
    have hlast := h n (by omega)
    linarith

#print axioms selected_task_drift_le_total
#print axioms layer_drift_telescope

end Nightfall.Route1SharedDrift

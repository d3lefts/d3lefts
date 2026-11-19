import Mathlib

/-!
# Exact one-query discrepancy for index-controlled isometric oracles

The per-query Hilbert-state bound is an indexed direct-sum inequality. If the
symbol-controlled operator at index i preserves the norm of its local state,
then replacing x_i by y_i changes only the coordinates with x_i ≠ y_i.
At those indices the difference is at most twice the original local norm.

This proof does not posit a global query-hybrid estimate. The caller still
must identify the physical query-register Hilbert norm with this direct-sum
norm, and connect these gates to the coherent oracle of #912.
-/

namespace Nightfall.QuantumOracleMismatch

open Finset

variable {ι α V : Type*} [Fintype ι] [DecidableEq α] [NormedAddCommGroup V]

/-- A symbol-controlled isometry costs at most four times the norm-squared
budget concentrated on the indices where two input strings differ. -/
theorem indexwise_oracle_discrepancy_sq
    (O : ι → α → V → V) (x y : ι → α) (ψ : ι → V)
    (hO : ∀ i a v, ‖O i a v‖ = ‖v‖) :
    (∑ i : ι,
      dist (O i (x i) (ψ i)) (O i (y i) (ψ i)) ^ 2) ≤
      4 * (∑ i : ι, if x i = y i then (0 : ℝ) else ‖ψ i‖ ^ 2) := by
  classical
  have hpoint (i : ι) :
      dist (O i (x i) (ψ i)) (O i (y i) (ψ i)) ^ 2
      ≤ if x i = y i then (0 : ℝ) else 4 * ‖ψ i‖ ^ 2 := by
    by_cases hi : x i = y i
    · simp [hi]
    · have hdist :
        dist (O i (x i) (ψ i)) (O i (y i) (ψ i))
          ≤ 2 * ‖ψ i‖ := by
        rw [dist_eq_norm]
        calc
          ‖O i (x i) (ψ i) - O i (y i) (ψ i)‖
            ≤ ‖O i (x i) (ψ i)‖ + ‖O i (y i) (ψ i)‖ := norm_sub_le _ _
          _ = 2 * ‖ψ i‖ := by rw [hO, hO]; ring
      have hd0 :
          0 ≤ dist (O i (x i) (ψ i)) (O i (y i) (ψ i)) := dist_nonneg
      have hn0 : 0 ≤ ‖ψ i‖ := norm_nonneg _
      have hsq :
          dist (O i (x i) (ψ i)) (O i (y i) (ψ i)) ^ 2
              ≤ 4 * ‖ψ i‖ ^ 2 := by nlinarith
      simpa [hi] using hsq
  calc
    (∑ i : ι,
        dist (O i (x i) (ψ i)) (O i (y i) (ψ i)) ^ 2)
      ≤ ∑ i : ι, if x i = y i then (0 : ℝ) else 4 * ‖ψ i‖ ^ 2 :=
        Finset.sum_le_sum (fun i _ => hpoint i)
    _ = 4 * (∑ i : ι, if x i = y i then (0 : ℝ) else ‖ψ i‖ ^ 2) := by
        rw [Finset.mul_sum]
        apply Finset.sum_congr rfl
        intro i _
        split_ifs <;> ring

/-- Square-root form of the actual one-query mismatch norm bound.
The query-index weights are the actual squared local state norms,
not an externally supplied probability vector. -/
theorem indexwise_oracle_discrepancy
    (O : ι → α → V → V) (x y : ι → α) (ψ : ι → V)
    (hO : ∀ i a v, ‖O i a v‖ = ‖v‖) :
    Real.sqrt (∑ i : ι,
      dist (O i (x i) (ψ i)) (O i (y i) (ψ i)) ^ 2)
      ≤ 2 * Real.sqrt
        (∑ i : ι, if x i = y i then (0 : ℝ) else ‖ψ i‖ ^ 2) := by
  have hsq := indexwise_oracle_discrepancy_sq O x y ψ hO
  calc
    Real.sqrt (∑ i : ι,
      dist (O i (x i) (ψ i)) (O i (y i) (ψ i)) ^ 2)
      ≤ Real.sqrt (4 *
        (∑ i : ι, if x i = y i then (0 : ℝ) else ‖ψ i‖ ^ 2)) :=
          Real.sqrt_le_sqrt hsq
    _ = 2 * Real.sqrt
        (∑ i : ι, if x i = y i then (0 : ℝ) else ‖ψ i‖ ^ 2) := by
          rw [Real.sqrt_mul (by norm_num : (0 : ℝ) ≤ 4)]
          norm_num

end Nightfall.QuantumOracleMismatch

#print axioms Nightfall.QuantumOracleMismatch.indexwise_oracle_discrepancy_sq
#print axioms Nightfall.QuantumOracleMismatch.indexwise_oracle_discrepancy

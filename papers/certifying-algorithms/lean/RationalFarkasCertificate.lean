import Mathlib

/-!
# Independent exact certificate soundness for rational linear systems

A rational Farkas witness is a small proof object, not a trusted solver.
For constraints A x ≤ b, nonnegative row multipliers w with wᵀ A = 0
and wᵀ b < 0 prove that no rational feasible x exists.

This soundness theorem can serve exact lower-bound verification in
finite permission/recertification optimization, even when the optimizer
is untrusted. It does NOT certify any external model encoding, a solver,
integer feasibility from an arbitrary relaxation, or a scientific claim.
-/

namespace Nightfall.CertifyingAlgorithms

open Finset

/-- Multiply each exact rational inequality by a nonnegative rational
multiplier, then sum. No independence or numerical tolerance. -/
theorem rational_linear_combination_bound
    {m n : ℕ}
    (A : Fin m → Fin n → ℚ) (b : Fin m → ℚ)
    (w : Fin m → ℚ) (x : Fin n → ℚ)
    (hw : ∀ i, 0 ≤ w i)
    (hx : ∀ i, (∑ j : Fin n, A i j * x j) ≤ b i) :
    (∑ i : Fin m, w i * (∑ j : Fin n, A i j * x j)) ≤
      (∑ i : Fin m, w i * b i) := by
  exact Finset.sum_le_sum (fun i _ => mul_le_mul_of_nonneg_left (hx i) (hw i))

/-- Exact rational Farkas infeasibility certificate. The certificate
consists of w ≥ 0, cancellation wᵀ A = 0, and negative wᵀ b. -/
theorem rational_farkas_infeasibility
    {m n : ℕ}
    (A : Fin m → Fin n → ℚ) (b : Fin m → ℚ)
    (w : Fin m → ℚ)
    (hw : ∀ i, 0 ≤ w i)
    (hcancel : ∀ j, (∑ i : Fin m, w i * A i j) = 0)
    (hnegative : (∑ i : Fin m, w i * b i) < 0) :
    ¬ ∃ x : Fin n → ℚ, ∀ i,
      (∑ j : Fin n, A i j * x j) ≤ b i := by
  rintro ⟨x, hx⟩
  have hle := rational_linear_combination_bound A b w x hw hx
  have hzero :
      (∑ i : Fin m, w i * (∑ j : Fin n, A i j * x j)) = 0 := by
    calc
      _ = ∑ i : Fin m, ∑ j : Fin n, (w i * A i j) * x j := by
        apply Finset.sum_congr rfl
        intro i _
        rw [Finset.mul_sum]
        apply Finset.sum_congr rfl
        intro j _
        ring
      _ = ∑ j : Fin n, ∑ i : Fin m, (w i * A i j) * x j := by
        rw [Finset.sum_comm]
      _ = ∑ j : Fin n, (∑ i : Fin m, w i * A i j) * x j := by
        apply Finset.sum_congr rfl
        intro j _
        rw [Finset.sum_mul]
      _ = 0 := by simp [hcancel]
  linarith

end Nightfall.CertifyingAlgorithms

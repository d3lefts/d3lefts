import Mathlib

/-!
# One-sided dyadic ceiling rounding: exact local error and anchor budget

For any nonnegative finite source mass p and positive integer grid N,
ceil(N p)/N never deletes positive mass and moves less than 1/N upward.
All this moved mass can be debited from a distinguished anchor. If the
anchor exceeds the sum of one-grid-unit budgets of the other atoms, the
residual anchor stays strictly positive.

This is a real-valued Lean construction, independent of a minimum atom
margin. It does NOT yet provide the universal anchor-selection lemma, the
full stochastic source-to-rounded coupling, a bucket decoder, or BDST.
-/

namespace Nightfall.StrongDyadicRounding

open Finset

/-- Upward rounding to the dyadic grid with denominator N. -/
noncomputable def upperGrid (N : ℕ) (p : ℝ) : ℝ :=
  (Nat.ceil ((N : ℝ) * p) : ℝ) / (N : ℝ)

/-- The rounding increment (nonnegative for N>0). -/
noncomputable def increment (N : ℕ) (p : ℝ) : ℝ := upperGrid N p - p

theorem upperGrid_ge (N : ℕ) (hN : 0 < N) (p : ℝ) :
    p ≤ upperGrid N p := by
  have hpos : (0 : ℝ) < (N : ℝ) := by exact_mod_cast hN
  unfold upperGrid
  apply (le_div_iff₀ hpos).2
  simpa only [mul_comm] using (Nat.le_ceil ((N : ℝ) * p))

theorem upperGrid_lt (N : ℕ) (hN : 0 < N)
    (p : ℝ) (hp : 0 ≤ p) :
    upperGrid N p < p + 1 / (N : ℝ) := by
  have hpos : (0 : ℝ) < (N : ℝ) := by exact_mod_cast hN
  have hceil : ((Nat.ceil ((N : ℝ) * p) : ℕ) : ℝ) <
      (N : ℝ) * p + 1 :=
    Nat.ceil_lt_add_one (mul_nonneg hpos.le hp)
  unfold upperGrid
  apply (div_lt_iff₀ hpos).2
  have hcalc : (p + 1 / (N : ℝ)) * (N : ℝ) =
      (N : ℝ) * p + 1 := by
    field_simp [ne_of_gt hpos]
    ring
  rw [hcalc]
  exact hceil

theorem increment_nonneg (N : ℕ) (hN : 0 < N)
    (p : ℝ) : 0 ≤ increment N p := by
  unfold increment
  exact sub_nonneg.mpr (upperGrid_ge N hN p)

theorem increment_lt (N : ℕ) (hN : 0 < N)
    (p : ℝ) (hp : 0 ≤ p) :
    increment N p < 1 / (N : ℝ) := by
  unfold increment
  have h := upperGrid_lt N hN p hp
  linarith

variable {α : Type*} [Fintype α] [DecidableEq α]

/-- Non-anchor mass increases by less than one grid unit each.
If the anchor mass exceeds the full available grid-unit budget,
the residual is strictly positive. No lower bound on other atoms. -/
theorem anchor_survives
    (N : ℕ) (hN : 0 < N) (p : α → ℝ)
    (hp : ∀ b, 0 ≤ p b) (a : α)
    (hroom :
      (∑ b ∈ (Finset.univ.erase a), (1 : ℝ) / (N : ℝ)) < p a) :
    0 < p a - ∑ b ∈ (Finset.univ.erase a), increment N (p b) := by
  have hbudget :
      (∑ b ∈ (Finset.univ.erase a), increment N (p b)) ≤
        ∑ b ∈ (Finset.univ.erase a), (1 : ℝ) / (N : ℝ) := by
    exact Finset.sum_le_sum (fun b _ => le_of_lt (increment_lt N hN (p b) (hp b)))
  linarith

end Nightfall.StrongDyadicRounding

#print axioms Nightfall.StrongDyadicRounding.upperGrid_ge
#print axioms Nightfall.StrongDyadicRounding.upperGrid_lt
#print axioms Nightfall.StrongDyadicRounding.increment_nonneg
#print axioms Nightfall.StrongDyadicRounding.increment_lt
#print axioms Nightfall.StrongDyadicRounding.anchor_survives

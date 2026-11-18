import Mathlib

/-!
# Capped stopping-time accounting for the product-space AA simulator

This is the quantitative scalar drift lemma used after conditional
Hoeffding decomposition and greedy-coordinate selection. Here
J n is *expected total influence* after n capped queries and p n
is the probability the process has not stopped. Those semantic
identifications are separate proof obligations, not part of this file.
-/

namespace Nightfall.QuerySimulation

/-- Quantitative capped-drift inequality: nonnegative remaining potential and
a per-step decrement imply a tail bound, even for adaptive queries.
This avoids invoking an unbounded stopping-time theorem. -/
theorem capped_drift_budget
    (J active : ℕ → ℝ) (a : ℝ) (ha : 0 ≤ a)
    (hJ : ∀ n, 0 ≤ J n)
    (hactive : ∀ n, active (n+1) ≤ active n)
    (hstep : ∀ n, J (n+1) + a * active n ≤ J n) :
    ∀ n : ℕ, (n : ℝ) * a * active n ≤ J 0 := by
  have invariant : ∀ n : ℕ,
      J n + (n : ℝ) * a * active n ≤ J 0 := by
    intro n
    induction n with
    | zero =>
      simpa using le_refl (J 0)
    | succ n ih =>
      have h1 := hstep n
      have h2 := hactive n
      have h3 : 0 ≤ (n : ℝ) * a :=
        mul_nonneg (Nat.cast_nonneg n) ha
      have h4 : (n : ℝ) * a * active (n+1) ≤ (n : ℝ) * a * active n :=
        mul_le_mul_of_nonneg_left h2 h3
      push_cast
      nlinarith
  intro n
  have h := invariant n
  linarith [hJ n]

/-- If the capped drift uses a uniform tail target, the active fraction
is no larger than a target that covers the initial potential. -/
theorem capped_drift_tail
    (J active : ℕ → ℝ) (a bound : ℝ) (n : ℕ)
    (ha : 0 < a) (hn : 0 < n)
    (hJ : ∀ k, 0 ≤ J k)
    (hactive : ∀ k, active (k+1) ≤ active k)
    (hstep : ∀ k, J (k+1) + a * active k ≤ J k)
    (hbudget : J 0 ≤ (n : ℝ) * a * bound) :
    active n ≤ bound := by
  have hh := capped_drift_budget J active a (le_of_lt ha) hJ hactive hstep n
  have hp : 0 < (n : ℝ) * a := mul_pos (Nat.cast_pos.mpr hn) ha
  nlinarith

/-- A truncation-error allowance and a conditional-mean error allowance
compose into a total error budget. -/
theorem add_error_budgets
    (truncation approximation δ : ℝ)
    (htrunc : truncation ≤ δ/2)
    (happrox : approximation ≤ δ/2) :
    truncation + approximation ≤ δ := by
  linarith

end Nightfall.QuerySimulation

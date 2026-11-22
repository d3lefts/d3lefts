import Mathlib

/-!
# Hilbert observability: exact nonasymptotic greedy posterior-rate terminal

This certifies the *hard-budget recurrence and 20172*r*B²/η coefficient*
from a quadratic posterior-potential drift. It does NOT supply that drift
from arbitrary measurable product Hilbert-valued observables: the
source-to-matching D1 and posterior source-to-drift D2 maps remain explicit
missing premises. In particular this is not an end-to-end Theorem D.
-/

namespace Nightfall.HilbertAdaptiveDrift

/-- Reciprocal potential increases by at least κ under the exact quadratic
potential drop. Positive potentials are required; hitting zero gives a
trivial risk guarantee instead. -/
theorem reciprocal_step
    (p q κ : ℝ) (hp : 0 < p) (hq : 0 < q) (hk : 0 ≤ κ)
    (hstep : q ≤ p - κ * p ^ 2) :
    1 / p + κ ≤ 1 / q := by
  have hcost : 0 ≤ κ * p ^ 2 := mul_nonneg hk (sq_nonneg p)
  have hmono : q ≤ p := by linarith
  have hcp : κ * p * q ≤ κ * p ^ 2 := by
    nlinarith [mul_nonneg (mul_nonneg hk hp.le)
      (sub_nonneg.mpr hmono)]
  have hdiff : κ * p * q ≤ p - q := by linarith
  have hdiv : q / p ≤ 1 - κ * q :=
    (div_le_iff₀ hp).mpr (by nlinarith [hdiff])
  apply (le_div_iff₀ hq).mpr
  calc
    (1 / p + κ) * q = q / p + κ * q := by ring
    _ ≤ (1 - κ * q) + κ * q := add_le_add_right hdiv _
    _ = 1 := by ring

/-- Every nonnegative trajectory with a uniform quadratic decrease
has p_n ≤ 1/(nκ) for all n≥1, including all zero-hitting trajectories.
No extra initial-potential cap is assumed. -/
theorem quadratic_drift_depth_bound
    (p : ℕ → ℝ) (κ : ℝ) (hk : 0 < κ)
    (hp : ∀ n, 0 ≤ p n)
    (hstep : ∀ n, p (n + 1) ≤ p n - κ * (p n) ^ 2)
    (n : ℕ) :
    (n : ℝ) * κ * p n ≤ 1 := by
  have hrec : ∀ m : ℕ, 0 < p m → (m : ℝ) * κ ≤ 1 / p m := by
    intro m
    induction m with
    | zero =>
        intro hm
        simpa using (le_of_lt (one_div_pos.mpr hm))
    | succ m ih =>
        intro hm1
        have hcost : 0 ≤ κ * (p m) ^ 2 :=
          mul_nonneg hk.le (sq_nonneg _)
        have hprev : 0 < p m := by
          have hs := hstep m
          linarith
        have hinv := ih hprev
        have hnext := reciprocal_step (p m) (p (m + 1))
          κ hprev hm1 hk.le (hstep m)
        have hcast : (((m + 1 : ℕ) : ℝ) * κ) =
            (m : ℝ) * κ + κ := by push_cast; ring
        rw [hcast]
        linarith
  by_cases hz : p n = 0
  · simp [hz]
  · have hpos : 0 < p n :=
      lt_of_le_of_ne (hp n) (Ne.symm hz)
    have hi := hrec n hpos
    have hmul : ((n : ℝ) * κ) * p n ≤ 1 :=
      (le_div_iff₀ hpos).mp hi
    nlinarith

/-- This is the exact hard (not expected) number-of-observations
reciprocal-telescoping step used in D2. -/
theorem hard_budget_from_quadratic_drift
    (p : ℕ → ℝ) (κ η : ℝ)
    (hk : 0 < κ) (hη : 0 < η)
    (hp : ∀ n, 0 ≤ p n)
    (hstep : ∀ n, p (n + 1) ≤ p n - κ * (p n) ^ 2)
    (n : ℕ) (hbudget : 1 ≤ (n : ℝ) * κ * η) :
    p n ≤ η := by
  have hcap := quadratic_drift_depth_bound p κ hk hp hstep n
  have hcoeff0 : 0 ≤ (n : ℝ) * κ :=
    mul_nonneg (Nat.cast_nonneg _) hk.le
  have hcoeff : 0 < (n : ℝ) * κ := by
    by_contra h
    have hz : (n : ℝ) * κ = 0 :=
      le_antisymm (le_of_not_gt h) hcoeff0
    rw [hz] at hbudget
    norm_num at hbudget
  by_contra hnot
  have hgt : η < p n := lt_of_not_ge hnot
  have hx := mul_lt_mul_of_pos_left hgt hcoeff
  nlinarith

/-- Source D2's rank-linear integer budget: conditional only on the true
posterior potential satisfying its source-required quadratic drift.
No monotonicity, first-moment, or residual-risk estimate is smuggled in. -/
theorem rank_20172_budget_from_posterior_drift
    (p : ℕ → ℝ) (r : ℕ) (B η : ℝ)
    (hr : 0 < r) (hB : 0 < B) (hη : 0 < η)
    (hp : ∀ n, 0 ≤ p n)
    (hstep : ∀ n, p (n + 1) ≤
      p n - (p n) ^ 2 / (20172 * (r : ℝ) * B ^ 2))
    (n : ℕ)
    (hbudget : 20172 * (r : ℝ) * B ^ 2 ≤ (n : ℝ) * η) :
    p n ≤ η := by
  let C : ℝ := 20172 * (r : ℝ) * B ^ 2
  have hC : 0 < C := by
    dsimp [C]
    positivity
  let κ : ℝ := 1 / C
  have hk : 0 < κ := by
    dsimp [κ]
    positivity
  have hstep' : ∀ m, p (m + 1) ≤ p m - κ * (p m) ^ 2 := by
    intro m
    simpa [κ, C, div_eq_mul_inv, mul_assoc, mul_comm, mul_left_comm]
      using hstep m
  have hb : 1 ≤ ((n : ℝ) * η) / C :=
    (le_div_iff₀ hC).mpr (by simpa [C] using hbudget)
  have hb' : 1 ≤ (n : ℝ) * κ * η := by
    simpa [κ, div_eq_mul_inv, mul_assoc, mul_comm, mul_left_comm] using hb
  exact hard_budget_from_quadratic_drift p κ η hk hη hp hstep' n hb'

end Nightfall.HilbertAdaptiveDrift

#print axioms Nightfall.HilbertAdaptiveDrift.reciprocal_step
#print axioms Nightfall.HilbertAdaptiveDrift.quadratic_drift_depth_bound
#print axioms Nightfall.HilbertAdaptiveDrift.hard_budget_from_quadratic_drift
#print axioms Nightfall.HilbertAdaptiveDrift.rank_20172_budget_from_posterior_drift

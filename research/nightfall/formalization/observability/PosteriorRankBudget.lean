import Mathlib

/-!
# NIGHTFALL v7: finite posterior-kernel weighted stopping budget

This module extends the merged unit-drift proof to an actual finite-state,
time-inhomogeneous transition kernel, with state-dependent nonnegative
progress weights.  The weights are intended to be the v7
alpha/kappa * (r/s)^(q-1) rank-coherence certificates.  Their analytic
lower bound from the scalar influence premise, the posterior ANOVA
identity, and the infinite-product measurable lift are NOT assumed
proved by this module.
-/

namespace Nightfall.Observability.V7

open Finset

variable {State : Type*} [Fintype State]

def expectedPotential (mass : ℕ → State → ℝ)
    (potential : ℕ → State → ℝ) (t : ℕ) : ℝ :=
  ∑ s : State, mass t s * potential t s

def expectedProgress (mass : ℕ → State → ℝ)
    (progress : ℕ → State → ℝ) (t : ℕ) : ℝ :=
  ∑ s : State, mass t s * progress t s

/-- Exact change of measure for a finite state-dependent transition kernel.
No conservation or positivity of the kernel is needed for the identity itself. -/
theorem potential_flow_identity
    (mass : ℕ → State → ℝ)
    (kernel : ℕ → State → State → ℝ)
    (potential : ℕ → State → ℝ)
    (hflow : ∀ t b, mass (t + 1) b =
      ∑ a : State, mass t a * kernel t a b)
    (t : ℕ) :
    expectedPotential mass potential (t + 1) =
      ∑ a : State, mass t a *
        (∑ b : State, kernel t a b * potential (t + 1) b) := by
  classical
  unfold expectedPotential
  simp_rw [hflow t]
  calc
    (∑ b : State, (∑ a : State, mass t a * kernel t a b) *
        potential (t + 1) b) =
      ∑ b : State, ∑ a : State,
        mass t a * (kernel t a b * potential (t + 1) b) := by
          apply Finset.sum_congr rfl
          intro b _
          rw [Finset.sum_mul]
          apply Finset.sum_congr rfl
          intro a _
          ring
    _ = ∑ a : State, ∑ b : State,
          mass t a * (kernel t a b * potential (t + 1) b) :=
            Finset.sum_comm
    _ = ∑ a : State, mass t a *
          (∑ b : State, kernel t a b * potential (t + 1) b) := by
            apply Finset.sum_congr rfl
            intro a _
            rw [Finset.mul_sum]

/-- Local conditional expected decrease induces genuine expected decrease
for a finite posterior distribution over states. -/
theorem expected_kernel_drift
    (mass : ℕ → State → ℝ)
    (kernel : ℕ → State → State → ℝ)
    (potential progress : ℕ → State → ℝ)
    (hpos : ∀ t a, 0 ≤ mass t a)
    (hflow : ∀ t b, mass (t + 1) b =
      ∑ a : State, mass t a * kernel t a b)
    (hloc : ∀ t a,
      (∑ b : State, kernel t a b * potential (t + 1) b) +
        progress t a ≤ potential t a)
    (t : ℕ) :
    expectedPotential mass potential (t + 1) +
      expectedProgress mass progress t ≤
        expectedPotential mass potential t := by
  classical
  calc
    expectedPotential mass potential (t + 1) +
        expectedProgress mass progress t =
      (∑ a : State, mass t a *
        (∑ b : State, kernel t a b * potential (t + 1) b)) +
      ∑ a : State, mass t a * progress t a := by
        rw [potential_flow_identity mass kernel potential hflow t]
        rfl
    _ = ∑ a : State, mass t a *
        ((∑ b : State, kernel t a b * potential (t + 1) b) +
          progress t a) := by
          simp only [mul_add, Finset.sum_add_distrib]
    _ ≤ ∑ a : State, mass t a * potential t a := by
          apply Finset.sum_le_sum
          intro a _
          exact mul_le_mul_of_nonneg_left (hloc t a) (hpos t a)
    _ = expectedPotential mass potential t := rfl

/-- State-dependent (not worst-rank) progress telescopes along the whole
finite posterior tree.  This is the algebraic target of v7 Theorem 3.1. -/
theorem posterior_weighted_budget
    (mass : ℕ → State → ℝ)
    (kernel : ℕ → State → State → ℝ)
    (potential progress : ℕ → State → ℝ)
    (hpos : ∀ t a, 0 ≤ mass t a)
    (hpotential : ∀ t a, 0 ≤ potential t a)
    (hflow : ∀ t b, mass (t + 1) b =
      ∑ a : State, mass t a * kernel t a b)
    (hloc : ∀ t a,
      (∑ b : State, kernel t a b * potential (t + 1) b) +
        progress t a ≤ potential t a)
    (n : ℕ) :
    (∑ t ∈ Finset.range n, expectedProgress mass progress t) ≤
      expectedPotential mass potential 0 := by
  classical
  have htel : ∀ n : ℕ,
      expectedPotential mass potential n +
          (∑ t ∈ Finset.range n, expectedProgress mass progress t) ≤
        expectedPotential mass potential 0 := by
    intro m
    induction m with
    | zero => simp
    | succ m ih =>
        have hs := expected_kernel_drift mass kernel potential progress
          hpos hflow hloc m
        rw [Finset.sum_range_succ]
        linarith
  have hp : 0 ≤ expectedPotential mass potential n := by
    unfold expectedPotential
    apply Finset.sum_nonneg
    intro a _
    exact mul_nonneg (hpos n a) (hpotential n a)
  have h := htel n
  linarith

end Nightfall.Observability.V7

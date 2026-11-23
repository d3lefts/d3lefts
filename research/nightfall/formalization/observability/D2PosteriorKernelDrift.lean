import PosteriorRankBudget
import HilbertAdaptiveDrift
import SourceTotalVariance

/-!
# D2: genuine finite-state posterior kernel -> hard rank-linear query bound

Uses *existing* original-source weighted square shifting (SourceTotalVariance),
finite-state posterior transition accounting (PosteriorRankBudget) and
certified reciprocal-potential hard budget (HilbertAdaptiveDrift).

The new step is that local state-dependent quadratic decrease, plus genuine
normalization of each evolving state law, gives the *averaged* quadratic drift,
by the exact weighted second-moment inequality (no Jensen as an axiom).

This is not a theorem asserting the state-local quadratic decrease for
arbitrary rank-r Hilbert original-product observables, nor a construction of
the actual revealing-coordinate Markov kernel. They remain explicit premises.
-/

namespace Nightfall.Observability.D2PosteriorKernelDrift

open Finset
open Nightfall.Observability.V7
open Nightfall.HilbertAdaptiveDrift
open Nightfall.CubicQ3.SourceVariance

variable {State : Type*} [Fintype State]

/-- Source-normalized finite weighted Jensen for the square, derived
from the exact weighted variance identity, not a free convexity bound. -/
theorem weighted_square_ge_square_mean
    (mass value : State → ℝ)
    (hmass0 : ∀ a, 0 ≤ mass a)
    (hmass1 : (∑ a : State, mass a) = 1) :
    (∑ a : State, mass a * value a) ^ 2 ≤
      ∑ a : State, mass a * (value a) ^ 2 := by
  let m : ℝ := ∑ a : State, mass a * value a
  have hvar : 0 ≤
      ∑ a : State, mass a * (value a - m) ^ 2 := by
    apply Finset.sum_nonneg
    intro a _
    exact mul_nonneg (hmass0 a) (sq_nonneg _)
  have hs := weighted_square_shift mass value m hmass1
  rw [hs] at hvar
  dsimp [m] at *
  nlinarith

/-- Exact finite causal posterior-kernel reduction of pointwise
quadratic drift to averaged quadratic drift.
No boundedness or 'all paths have same influence' shortcut is used. -/
theorem expected_quadratic_drift_from_kernel
    (mass : ℕ → State → ℝ)
    (kernel : ℕ → State → State → ℝ)
    (potential : ℕ → State → ℝ)
    (kappa : ℝ)
    (hk : 0 ≤ kappa)
    (hmass0 : ∀ t a, 0 ≤ mass t a)
    (hmass1 : ∀ t, (∑ a : State, mass t a) = 1)
    (hflow : ∀ t b, mass (t + 1) b =
      ∑ a : State, mass t a * kernel t a b)
    (hloc : ∀ t a,
      (∑ b : State, kernel t a b * potential (t + 1) b) +
        kappa * (potential t a) ^ 2 ≤ potential t a)
    (t : ℕ) :
    expectedPotential mass potential (t + 1) ≤
      expectedPotential mass potential t -
        kappa * (expectedPotential mass potential t) ^ 2 := by
  have hkernel := expected_kernel_drift mass kernel potential
    (fun t a => kappa * (potential t a) ^ 2)
    hmass0 hflow hloc t
  have hj := weighted_square_ge_square_mean
    (mass t) (potential t) (hmass0 t) (hmass1 t)
  have hprogress :
      kappa * (expectedPotential mass potential t) ^ 2 ≤
      expectedProgress mass
        (fun t a => kappa * (potential t a) ^ 2) t := by
    unfold expectedProgress expectedPotential
    calc
      kappa * (∑ a : State, mass t a * potential t a) ^ 2 ≤
          kappa * (∑ a : State, mass t a * (potential t a) ^ 2) :=
            mul_le_mul_of_nonneg_left hj hk
      _ = ∑ a : State, mass t a * (kappa * (potential t a) ^ 2) := by
          rw [Finset.mul_sum]
          apply Finset.sum_congr rfl
          intro a _
          ring
  linarith

/-- Compose the *source-local* kernel drift (if proved for the physical
greedy policy) all the way to the existing hard 20172*r*B²/η budget.
Every step after the source-local drift is now kernel-checked. -/
theorem finite_state_rank_budget_from_local_kernel_drift
    (mass : ℕ → State → ℝ)
    (kernel : ℕ → State → State → ℝ)
    (potential : ℕ → State → ℝ)
    (r : ℕ) (B eta : ℝ) (n : ℕ)
    (hr : 0 < r) (hB : 0 < B) (heta : 0 < eta)
    (hmass0 : ∀ t a, 0 ≤ mass t a)
    (hmass1 : ∀ t, (∑ a : State, mass t a) = 1)
    (hpotential : ∀ t a, 0 ≤ potential t a)
    (hflow : ∀ t b, mass (t + 1) b =
      ∑ a : State, mass t a * kernel t a b)
    (hloc : ∀ t a,
      (∑ b : State, kernel t a b * potential (t + 1) b) +
        (potential t a) ^ 2 / (20172 * (r : ℝ) * B ^ 2) ≤
          potential t a)
    (hbudget : 20172 * (r : ℝ) * B ^ 2 ≤ (n : ℝ) * eta) :
    expectedPotential mass potential n ≤ eta := by
  let C : ℝ := 20172 * (r : ℝ) * B ^ 2
  have hC : 0 < C := by
    dsimp [C]
    positivity
  let kappa : ℝ := 1 / C
  have hk : 0 ≤ kappa := by
    dsimp [kappa]
    positivity
  have hloc' : ∀ t a,
      (∑ b : State, kernel t a b * potential (t + 1) b) +
        kappa * (potential t a) ^ 2 ≤ potential t a := by
    intro t a
    simpa [kappa, C, div_eq_mul_inv, mul_assoc, mul_comm, mul_left_comm]
      using hloc t a
  have hstep : ∀ t,
      expectedPotential mass potential (t + 1) ≤
        expectedPotential mass potential t -
          (expectedPotential mass potential t) ^ 2 /
            (20172 * (r : ℝ) * B ^ 2) := by
    intro t
    have h := expected_quadratic_drift_from_kernel mass kernel
      potential kappa hk hmass0 hmass1 hflow hloc' t
    simpa [kappa, C, div_eq_mul_inv, mul_assoc, mul_comm, mul_left_comm]
      using h
  have hp : ∀ t, 0 ≤ expectedPotential mass potential t := by
    intro t
    unfold expectedPotential
    apply Finset.sum_nonneg
    intro a _
    exact mul_nonneg (hmass0 t a) (hpotential t a)
  exact rank_20172_budget_from_posterior_drift
    (expectedPotential mass potential) r B eta hr hB heta
    hp hstep n hbudget

/-- A genuine finite stochastic transition kernel preserves total state
probability. This derives the normalization required by weighted Jensen
from an initial mass law and per-state probability-one transitions. -/
theorem state_mass_normalization_from_stochastic_kernel
    (mass : ℕ → State → ℝ)
    (kernel : ℕ → State → State → ℝ)
    (hinit : (∑ a : State, mass 0 a) = 1)
    (hrow : ∀ t a, (∑ b : State, kernel t a b) = 1)
    (hflow : ∀ t b, mass (t + 1) b =
      ∑ a : State, mass t a * kernel t a b) :
    ∀ t, (∑ a : State, mass t a) = 1 := by
  intro t
  induction t with
  | zero => exact hinit
  | succ t ih =>
      calc
        (∑ b : State, mass (t + 1) b) =
            ∑ b : State, ∑ a : State,
              mass t a * kernel t a b := by
          apply Finset.sum_congr rfl
          intro b _
          rw [hflow t b]
        _ = ∑ a : State, mass t a *
              (∑ b : State, kernel t a b) := by
          rw [Finset.sum_comm]
          apply Finset.sum_congr rfl
          intro a _
          rw [Finset.mul_sum]
        _ = ∑ a : State, mass t a := by
          apply Finset.sum_congr rfl
          intro a _
          rw [hrow t a]
          ring
        _ = 1 := ih

/-- Nonnegative initial masses and nonnegative Markov transition entries
propagate genuine posterior-state nonnegativity through all time steps. -/
theorem state_mass_nonnegative_from_stochastic_kernel
    (mass : ℕ → State → ℝ)
    (kernel : ℕ → State → State → ℝ)
    (hinit : ∀ a, 0 ≤ mass 0 a)
    (hkernel : ∀ t a b, 0 ≤ kernel t a b)
    (hflow : ∀ t b, mass (t + 1) b =
      ∑ a : State, mass t a * kernel t a b) :
    ∀ t a, 0 ≤ mass t a := by
  intro t
  induction t with
  | zero =>
      intro a
      exact hinit a
  | succ t ih =>
      intro b
      rw [hflow t b]
      apply Finset.sum_nonneg
      intro a _
      exact mul_nonneg (ih a) (hkernel t a b)

/-- Complete finite-state stochastic-kernel algebraic terminal:
initial probability, stochastic rows, true mass flow, nonnegative
posterior potentials and the *source-local* quadratic drift give the
hard 20172*r*B²/eta bound without assuming normalized intermediate
masses or averaged drift. Physical greedy state construction and
Hilbert D1 source-local quadratic decrease remain outside this theorem. -/
theorem finite_stochastic_kernel_rank_budget
    (mass : ℕ → State → ℝ)
    (kernel : ℕ → State → State → ℝ)
    (potential : ℕ → State → ℝ)
    (r : ℕ) (B eta : ℝ) (n : ℕ)
    (hr : 0 < r) (hB : 0 < B) (heta : 0 < eta)
    (hinit0 : ∀ a, 0 ≤ mass 0 a)
    (hinit1 : (∑ a : State, mass 0 a) = 1)
    (hkernel0 : ∀ t a b, 0 ≤ kernel t a b)
    (hrow : ∀ t a, (∑ b : State, kernel t a b) = 1)
    (hflow : ∀ t b, mass (t + 1) b =
      ∑ a : State, mass t a * kernel t a b)
    (hpotential : ∀ t a, 0 ≤ potential t a)
    (hloc : ∀ t a,
      (∑ b : State, kernel t a b * potential (t + 1) b) +
        (potential t a) ^ 2 / (20172 * (r : ℝ) * B ^ 2) ≤
          potential t a)
    (hbudget : 20172 * (r : ℝ) * B ^ 2 ≤ (n : ℝ) * eta) :
    expectedPotential mass potential n ≤ eta := by
  exact finite_state_rank_budget_from_local_kernel_drift
    mass kernel potential r B eta n hr hB heta
    (state_mass_nonnegative_from_stochastic_kernel
      mass kernel hinit0 hkernel0 hflow)
    (state_mass_normalization_from_stochastic_kernel
      mass kernel hinit1 hrow hflow)
    hpotential hflow hloc hbudget

end Nightfall.Observability.D2PosteriorKernelDrift

#print axioms Nightfall.Observability.D2PosteriorKernelDrift.weighted_square_ge_square_mean
#print axioms Nightfall.Observability.D2PosteriorKernelDrift.expected_quadratic_drift_from_kernel
#print axioms Nightfall.Observability.D2PosteriorKernelDrift.finite_state_rank_budget_from_local_kernel_drift

#print axioms Nightfall.Observability.D2PosteriorKernelDrift.state_mass_normalization_from_stochastic_kernel
#print axioms Nightfall.Observability.D2PosteriorKernelDrift.state_mass_nonnegative_from_stochastic_kernel
#print axioms Nightfall.Observability.D2PosteriorKernelDrift.finite_stochastic_kernel_rank_budget

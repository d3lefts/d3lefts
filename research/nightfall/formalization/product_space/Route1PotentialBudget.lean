import Mathlib

/-!
# NIGHTFALL Route 1: finite two-potential stopping-time budget

This module certifies only the algebraic stopping-time composition. It does NOT
construct the posterior state process, prove entropy/Phi drift from the original
mixture law, prove Pinsker or the M-free information lemma, or certify the final
Route 1 polylog-M simulator.

At each stage k, 'active k' can be a probability of continuing. Expected
weighted drops in two nonnegative potentials need only dominate one of two
positive thresholds times the active probability. The resulting sum of active
probabilities is bounded by the initial weighted potential. This is the
finite-horizon supermartingale budget in the precise scalar form required by
Route 1.
-/

namespace Nightfall.Route1PotentialBudget

open Finset

/-- Finite-horizon telescoping: if active mass plus next potential never exceeds
current potential, expected active-stage count is bounded by initial mass. -/
theorem finite_active_telescope
    (N : ℕ) (pot active : ℕ → ℝ)
    (hfinal : 0 ≤ pot N)
    (hdrop : ∀ k, k < N → active k + pot (k + 1) ≤ pot k) :
    (∑ k ∈ Finset.range N, active k) ≤ pot 0 := by
  have hprefix : ∀ n : ℕ, n ≤ N →
      (∑ k ∈ Finset.range n, active k) + pot n ≤ pot 0 := by
    intro n
    induction n with
    | zero =>
        intro _
        simp
    | succ n ih =>
        intro hn
        have hnlt : n < N := by omega
        have hprev := ih (by omega)
        have hstep := hdrop n hnlt
        rw [Finset.sum_range_succ]
        linarith
  have hN := hprefix N (le_refl N)
  linarith

/-- If either of two nonnegative resource drops pays for an active stage,
both resources together pay for it after weighting by coefficients which
dominate the reciprocal thresholds. -/
theorem disjunctive_weighted_progress
    (a b s g h u v : ℝ)
    (ha : 0 ≤ a) (hb : 0 ≤ b) (hs : 0 ≤ s)
    (hu : 0 ≤ u) (hv : 0 ≤ v)
    (hug : 1 ≤ u * g) (hvh : 1 ≤ v * h)
    (hor : g * s ≤ a ∨ h * s ≤ b) :
    s ≤ u * a + v * b := by
  rcases hor with hfirst | hsecond
  · have hmul := mul_le_mul_of_nonneg_left hfirst hu
    have hscale := mul_nonneg (sub_nonneg.mpr hug) hs
    have hother := mul_nonneg hv hb
    nlinarith
  · have hmul := mul_le_mul_of_nonneg_left hsecond hv
    have hscale := mul_nonneg (sub_nonneg.mpr hvh) hs
    have hother := mul_nonneg hu ha
    nlinarith

/-- Abstract Route 1 two-potential theorem. The assumptions explicitly
include the original-source expected drift obligations. No unconditional
statistical/probabilistic claim is hidden in this theorem. -/
theorem adaptive_two_potential_budget
    (N : ℕ) (Phi Ent active fallPhi fallEnt : ℕ → ℝ)
    (g h u v : ℝ)
    (hu : 0 ≤ u) (hv : 0 ≤ v)
    (hug : 1 ≤ u * g) (hvh : 1 ≤ v * h)
    (hPhiFinal : 0 ≤ Phi N) (hEntFinal : 0 ≤ Ent N)
    (hPhiDrop : ∀ k, k < N →
      fallPhi k + Phi (k + 1) ≤ Phi k)
    (hEntDrop : ∀ k, k < N →
      fallEnt k + Ent (k + 1) ≤ Ent k)
    (hFallNonneg : ∀ k, k < N →
      0 ≤ fallPhi k ∧ 0 ≤ fallEnt k)
    (hActiveNonneg : ∀ k, k < N → 0 ≤ active k)
    (hEither : ∀ k, k < N →
      g * active k ≤ fallPhi k ∨
      h * active k ≤ fallEnt k) :
    (∑ k ∈ Finset.range N, active k) ≤
      u * Phi 0 + v * Ent 0 := by
  apply finite_active_telescope N
    (fun k => u * Phi k + v * Ent k) active
  · exact add_nonneg (mul_nonneg hu hPhiFinal)
        (mul_nonneg hv hEntFinal)
  · intro k hk
    have hnonneg := hFallNonneg k hk
    have hpay := disjunctive_weighted_progress
      (fallPhi k) (fallEnt k) (active k) g h u v
      hnonneg.1 hnonneg.2 (hActiveNonneg k hk)
      hu hv hug hvh (hEither k hk)
    have hph := mul_le_mul_of_nonneg_left
      (hPhiDrop k hk) hu
    have hen := mul_le_mul_of_nonneg_left
      (hEntDrop k hk) hv
    nlinarith

end Nightfall.Route1PotentialBudget

#print axioms Nightfall.Route1PotentialBudget.finite_active_telescope
#print axioms Nightfall.Route1PotentialBudget.disjunctive_weighted_progress
#print axioms Nightfall.Route1PotentialBudget.adaptive_two_potential_budget

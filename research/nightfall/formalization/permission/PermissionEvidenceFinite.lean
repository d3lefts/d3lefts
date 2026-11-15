import Mathlib

/-!
# NIGHTFALL: finite permission evidence / observation-cost certificates

This module separates:
* an arbitrary finite monitor transcript's safe/unsafeMass likelihood domination;
* exact optimal cost within the all-negative exhaustion-certificate model;
* an epoch-by-epoch evidence + effect-guard accounting lower bound;
* a rational ten-action independent-reset expectation.

The finite monitor result does NOT claim an actual cloud guard is unbypassable.
The generic inspection result assumes source-candidate elimination is the sole
authorized observation oracle. It is not a KL information-theoretic proof.
Classical predecessors and bounds are recorded in Price of Permission #591.
-/

namespace Nightfall.PricePermission

open Finset

section FiniteNoisyEvidence

variable {Ω : Type*} [Fintype Ω]

/-- An observer whose safe-world mass is bounded pointwise by κ times
the unsafeMass-world mass cannot achieve a safe acceptance probability
greater than κ times its unsafeMass acceptance probability.
For finite support-equivalent distributions a finite κ exists.
The domination premise is explicit here, not silently inferred. -/
theorem finite_transcript_permission_domination
    (safe unsafeMass : Ω → ℝ) (κ : ℝ)
    (hdom : ∀ ω, safe ω ≤ κ * unsafeMass ω)
    (grant : Ω → Prop) [DecidablePred grant] :
    (∑ ω : Ω, if grant ω then safe ω else 0) ≤
      κ * (∑ ω : Ω, if grant ω then unsafeMass ω else 0) := by
  classical
  calc
    (∑ ω : Ω, if grant ω then safe ω else 0) ≤
        ∑ ω : Ω, κ * (if grant ω then unsafeMass ω else 0) := by
          apply Finset.sum_le_sum
          intro ω _
          by_cases h : grant ω
          · simpa [h] using hdom ω
          · simp [h]
    _ = κ * (∑ ω : Ω, if grant ω then unsafeMass ω else 0) := by
          rw [Finset.mul_sum]

/-- In the finite-overlap model, zero unsafeMass grants force zero safe grants.
Unlike a statistical test with small positive error, no nontrivial
finite-time zero-false-permit rule exists under this domination. -/
theorem zero_error_forces_zero_availability
    (safe unsafeMass : Ω → ℝ) (κ : ℝ)
    (hsafe : ∀ ω, 0 ≤ safe ω)
    (hdom : ∀ ω, safe ω ≤ κ * unsafeMass ω)
    (grant : Ω → Prop) [DecidablePred grant]
    (hzero : (∑ ω : Ω, if grant ω then unsafeMass ω else 0) = 0) :
    (∑ ω : Ω, if grant ω then safe ω else 0) = 0 := by
  classical
  have hupper := finite_transcript_permission_domination safe unsafeMass κ hdom grant
  rw [hzero, mul_zero] at hupper
  have hlower : 0 ≤ (∑ ω : Ω, if grant ω then safe ω else 0) := by
    apply Finset.sum_nonneg
    intro ω _
    by_cases h : grant ω
    · simpa [h] using hsafe ω
    · simp [h]
  exact le_antisymm hupper hlower

/-- Error-availability tradeoff following from an explicit finite
likelihood-ratio envelope. A fresh epoch does not erase this tradeoff. -/
theorem false_permit_availability_tradeoff
    (safe unsafeMass : Ω → ℝ) (κ α β : ℝ)
    (hκ : 0 ≤ κ)
    (hdom : ∀ ω, safe ω ≤ κ * unsafeMass ω)
    (grant : Ω → Prop) [DecidablePred grant]
    (hfalse : (∑ ω : Ω, if grant ω then unsafeMass ω else 0) ≤ α)
    (havail : 1 - β ≤ (∑ ω : Ω, if grant ω then safe ω else 0)) :
    1 - β ≤ κ * α := by
  have hbound := finite_transcript_permission_domination safe unsafeMass κ hdom grant
  have hm := mul_le_mul_of_nonneg_left hfalse hκ
  linarith

end FiniteNoisyEvidence

section ExhaustionPermission

variable {ι : Type*} [DecidableEq ι]

private theorem positive_cost_subset_monotone
    (cost : ι → ℝ) (hc : ∀ i, 0 ≤ cost i)
    (a b : Finset ι) (hab : a ⊆ b) :
    (∑ i ∈ a, cost i) ≤ ∑ i ∈ b, cost i := by
  exact Finset.sum_le_sum_of_subset_of_nonneg hab
    (by intro i _ _; exact hc i)

/-- Any all-negative *exhaustion certificate* must pay at least the
less expensive of the safe and unsafeMass candidate sets. -/
theorem permission_exhaustion_lower_bound
    (candidates safe inspected : Finset ι)
    (cost : ι → ℝ) (hc : ∀ i, 0 ≤ cost i)
    (hcert : safe ⊆ inspected ∨ (candidates \ safe) ⊆ inspected) :
    min (∑ i ∈ safe, cost i) (∑ i ∈ candidates \ safe, cost i) ≤
      ∑ i ∈ inspected, cost i := by
  rcases hcert with hs | hu
  · exact (min_le_left _ _).trans
      (positive_cost_subset_monotone cost hc safe inspected hs)
  · exact (min_le_right _ _).trans
      (positive_cost_subset_monotone cost hc (candidates \ safe) inspected hu)

/-- The finite all-negative oracle lower bound is attained by inspecting
all candidates in whichever permission class has lower total cost. -/
theorem permission_exhaustion_attained
    (candidates safe : Finset ι) (cost : ι → ℝ)
    (hs : safe ⊆ candidates) :
    ∃ inspected : Finset ι,
      inspected ⊆ candidates ∧
      (safe ⊆ inspected ∨ (candidates \ safe) ⊆ inspected) ∧
      (∑ i ∈ inspected, cost i) =
        min (∑ i ∈ safe, cost i) (∑ i ∈ candidates \ safe, cost i) := by
  by_cases h : (∑ i ∈ safe, cost i) ≤ ∑ i ∈ candidates \ safe, cost i
  · refine ⟨safe, hs, Or.inl (subset_refl safe), ?_⟩
    exact (min_eq_left h).symm
  · have hrev : (∑ i ∈ candidates \ safe, cost i) ≤
        ∑ i ∈ safe, cost i := le_of_lt (lt_of_not_ge h)
    refine ⟨candidates \ safe, Finset.sdiff_subset, Or.inr
      (subset_refl (candidates \ safe)), ?_⟩
    exact (min_eq_right hrev).symm

end ExhaustionPermission

section EpochCost

/-- If a fresh authenticated epoch costs at least c in evidence and
each consequential effect requires a guard costing at least g,
then these costs add. No claim of guard unbypassability is made. -/
theorem epoch_and_effect_cost_lower_bound
    (epochs actions : ℕ) (evidence : Fin epochs → ℝ)
    (guards : Fin actions → ℝ) (c g : ℝ)
    (he : ∀ i, c ≤ evidence i) (hg : ∀ i, g ≤ guards i) :
    (epochs : ℝ) * c + (actions : ℝ) * g ≤
      (∑ i : Fin epochs, evidence i) + (∑ i : Fin actions, guards i) := by
  have hE : (∑ i : Fin epochs, c) ≤ ∑ i : Fin epochs, evidence i := by
    apply Finset.sum_le_sum
    intro i _
    exact he i
  have hG : (∑ i : Fin actions, g) ≤ ∑ i : Fin actions, guards i := by
    apply Finset.sum_le_sum
    intro i _
    exact hg i
  simpa [Finset.sum_const_zero, nsmul_eq_mul] using add_le_add hE hG

/-- The number of actual fresh epochs is one plus the number of
authenticated resets, for a fixed history of independent epoch events. -/
theorem fresh_epoch_pathwise_cost_floor
    (changes : ℕ) (evidencePaid guardPaid c g : ℝ)
    (he : (1 + (changes : ℝ))*c ≤ evidencePaid)
    (hg : 10*g ≤ guardPaid) :
    (1 + (changes : ℝ))*c + 10*g ≤ evidencePaid + guardPaid := by
  linarith

/-- Explicit binomial distribution over 0..9 authenticated resets,
with q=1/4, one unit of exact-permission evidence per fresh epoch,
and a three-unit mandatory guard per each of ten actions.
The finite expected-cost calculation is exact rational arithmetic. -/
private def tenActionPermissionCost : ℚ :=
  ∑ k ∈ Finset.range 10,
    (Nat.choose 9 k : ℚ) * (1/4:ℚ)^k * (3/4:ℚ)^(9-k) *
      ((1 + (k:ℚ)) + 10*3)

/-- Exact ten-action joint mission-conditioned reuse cost, not an
unrestricted claim about adversarial change processes. -/
theorem ten_action_permission_cached_expected :
    tenActionPermissionCost = 133/4 := by
  norm_num [tenActionPermissionCost, Finset.sum_range_succ, Nat.choose]

/-- Exact no-reuse baseline for the same fixed-action oracle. -/
theorem ten_action_permission_no_cache :
    (10:ℚ)*(1+3) = 40 := by
  norm_num

/-- The already-audited source-identification-plus-guard benchmark. -/
theorem ten_action_identification_cached_expected :
    (1+(10-1)*(1/4:ℚ))*(81/8)+10*3 = 2013/32 := by
  norm_num

end EpochCost

end Nightfall.PricePermission

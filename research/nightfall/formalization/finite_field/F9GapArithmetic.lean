import Mathlib

/-!
NIGHTFALL F9 adaptive/nonadaptive square-power phase retrieval.

This file kernel-proves the *entire discrete arithmetic implication* from
the actual oracle complexity inequalities to an all-length unbounded gap.
It does **NOT** kernel-prove the square-oracle decoder, complement obstruction,
nor the 2025 intersecting-code asymptotic theorem. They remain separate
mathematical dependencies; calling this a terminal proof of the whole F9
asymptotic theorem would be incorrect.

Source model and analytic proofs:
research/nightfall/projects/finite-field/adaptive-fixed-separation-20261030/THEOREM.md
-/

namespace Nightfall.FiniteField.F9GapArithmetic

def adaptiveUpper (k : ℕ) : ℕ := k + (k + 1 - 1) / 2
def fixedLower (k : ℕ) : ℕ := 2 * k - 1

theorem f9_fixed_vs_adaptive_gap
    (k fixed adaptive : ℕ) (hk : 2 ≤ k)
    (hfixed : fixedLower k ≤ fixed)
    (hadaptive : adaptive ≤ adaptiveUpper k) :
    adaptive + (k - 1) / 2 ≤ fixed := by
  dsimp [fixedLower, adaptiveUpper] at *
  omega

theorem f9_gap_unbounded
    (fixed adaptive : ℕ → ℕ)
    (hfixed : ∀ k, 2 ≤ k → fixedLower k ≤ fixed k)
    (hadaptive : ∀ k, 2 ≤ k → adaptive k ≤ adaptiveUpper k) :
    ∀ threshold : ℕ, ∃ k : ℕ,
      threshold ≤ fixed k - adaptive k := by
  intro threshold
  let k := 2 * threshold + 3
  have hk : 2 ≤ k := by dsimp [k]; omega
  have hgap : adaptive k + (k - 1) / 2 ≤ fixed k :=
    f9_fixed_vs_adaptive_gap k (fixed k) (adaptive k)
      hk (hfixed k hk) (hadaptive k hk)
  refine ⟨k, ?_⟩
  dsimp [k] at *
  omega

-- A *finite-dimensional* rate transfer when a stronger uniform coding bound
-- is separately established. The published 17/8 bound is asymptotic, not
-- a uniform all-k claim; consequently this theorem is not invoked as a
-- certification of the 5/8 liminf.
theorem conditional_uniform_code_rate
    (k fixed adaptive : ℕ)
    (hcode : 17 * k ≤ 8 * fixed)
    (hdecoder : adaptive ≤ k + (k + 1) / 2)
    (horder : adaptive ≤ fixed) :
    5 * k ≤ 8 * (fixed - adaptive) + 4 := by
  omega

#print axioms Nightfall.FiniteField.F9GapArithmetic.f9_fixed_vs_adaptive_gap
#print axioms Nightfall.FiniteField.F9GapArithmetic.f9_gap_unbounded
#print axioms Nightfall.FiniteField.F9GapArithmetic.conditional_uniform_code_rate

end Nightfall.FiniteField.F9GapArithmetic

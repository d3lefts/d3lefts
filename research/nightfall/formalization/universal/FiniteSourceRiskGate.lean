import Mathlib

/-!
# Exact finite source-calibrated authorization risk

For any finite world space, finite observation space, arbitrary dependent
evidence, and a nonnegative normalized source mass, the rule that grants a
cell only if its exact source violates mass is <= beta times its cell mass
guarantees conditional violation risk <= beta.

All mass and conditional claims use the SAME original source p. There is
no independence, bounded interaction order, or external calibration budget.
The grant rule presumes the true source probabilities and exact safety labels
are known; source authentication and computation are NOT proved.
-/

namespace Nightfall.FiniteSourceRiskGate

open scoped Classical

variable {World Observation : Type*}
variable [Fintype World] [Fintype Observation] [DecidableEq Observation]

noncomputable def cellMass
    (p : World → ℝ) (O : World → Observation)
    (y : Observation) : ℝ :=
  ∑ x : World, if O x = y then p x else 0

noncomputable def cellUnsafeMass
    (p : World → ℝ) (violates : World → Bool)
    (O : World → Observation) (y : Observation) : ℝ :=
  ∑ x : World, if O x = y then
    (if violates x = true then p x else 0) else 0

/-- Reindex a finite world sum by observation fibers, without assuming
that observation cells are equally probable or independent. -/
theorem sum_over_observation_cells
    (w : World → ℝ) (O : World → Observation)
    (Grant : Observation → Prop) :
    (∑ y : Observation, if Grant y then
      (∑ x : World, if O x = y then w x else 0) else 0) =
    ∑ x : World, if Grant (O x) then w x else 0 := by
  classical
  calc
    (∑ y : Observation, if Grant y then
      (∑ x : World, if O x = y then w x else 0) else 0) =
      ∑ y : Observation, ∑ x : World,
        if Grant y ∧ O x = y then w x else 0 := by
          apply Finset.sum_congr rfl
          intro y _
          by_cases hy : Grant y <;> simp [hy]
    _ = ∑ x : World, ∑ y : Observation,
          if Grant y ∧ O x = y then w x else 0 := by
            rw [Finset.sum_comm]
    _ = ∑ x : World, if Grant (O x) then w x else 0 := by
          apply Finset.sum_congr rfl
          intro x _
          calc
            (∑ y : Observation, if Grant y ∧ O x = y then w x else 0) =
              ∑ y : Observation, if O x = y then
                (if Grant y then w x else 0) else 0 := by
                  apply Finset.sum_congr rfl
                  intro y _
                  by_cases hy : Grant y <;> by_cases he : O x = y <;> simp [hy, he]
            _ = if Grant (O x) then w x else 0 := by simp

/-- Local exact source-calibration per observation cell implies
global risk-mass calibration; no independence is needed. -/
theorem finite_cell_calibration_implies_risk_bound
    (p : World → ℝ) (violates : World → Bool)
    (O : World → Observation) (Grant : Observation → Prop)
    (beta : ℝ)
    (hcell : ∀ y, Grant y →
      cellUnsafeMass p violates O y ≤ beta * cellMass p O y) :
    (∑ x : World, if Grant (O x) then
      (if violates x = true then p x else 0) else 0) ≤
    beta * (∑ x : World, if Grant (O x) then p x else 0) := by
  classical
  have hpoint (y : Observation) :
      (if Grant y then cellUnsafeMass p violates O y else 0) ≤
        beta * (if Grant y then cellMass p O y else 0) := by
    by_cases hg : Grant y
    · simpa [hg] using hcell y hg
    · simp [hg]
  have hsum :
      (∑ y : Observation, if Grant y then
        cellUnsafeMass p violates O y else 0) ≤
      beta * (∑ y : Observation, if Grant y then
        cellMass p O y else 0) := by
    calc
      _ ≤ ∑ y : Observation,
        beta * (if Grant y then cellMass p O y else 0) :=
          Finset.sum_le_sum (fun y _ => hpoint y)
      _ = beta * (∑ y : Observation, if Grant y then
        cellMass p O y else 0) := by rw [Finset.mul_sum]
  have hbad :
      (∑ y : Observation, if Grant y then
        cellUnsafeMass p violates O y else 0) =
      ∑ x : World, if Grant (O x) then
        (if violates x = true then p x else 0) else 0 := by
    simpa only [cellUnsafeMass] using
      (sum_over_observation_cells
        (w := fun x => if violates x = true then p x else 0) O Grant)
  have hgrant :
      (∑ y : Observation, if Grant y then
        cellMass p O y else 0) =
      ∑ x : World, if Grant (O x) then p x else 0 := by
    simpa only [cellMass] using
      (sum_over_observation_cells (w := p) O Grant)
  rw [← hbad, ← hgrant]
  exact hsum

/-- The actual finite source p and violates predicate define the grant rule.
The theorem has NO supplied posterior calibration assumption. -/
theorem exact_source_threshold_gate_risk_mass_bound
    (p : World → ℝ) (violates : World → Bool)
    (O : World → Observation) (beta : ℝ)
    (hp : ∀ x, 0 ≤ p x)
    (hnorm : (∑ x : World, p x) = 1) :
    (∑ x : World,
      if cellUnsafeMass p violates O (O x) ≤ beta * cellMass p O (O x)
      then (if violates x = true then p x else 0) else 0) ≤
    beta * (∑ x : World,
      if cellUnsafeMass p violates O (O x) ≤ beta * cellMass p O (O x)
      then p x else 0) := by
  exact finite_cell_calibration_implies_risk_bound p violates O
    (fun y => cellUnsafeMass p violates O y ≤ beta * cellMass p O y)
    beta (fun y h => h)

/-- Provided authorization has positive source probability, the
*conditional* violation rate among accepted worlds is at most beta. -/
theorem exact_source_threshold_gate_conditional_risk
    (p : World → ℝ) (violates : World → Bool)
    (O : World → Observation) (beta : ℝ)
    (hp : ∀ x, 0 ≤ p x)
    (hnorm : (∑ x : World, p x) = 1)
    (hgrant : 0 < (∑ x : World,
      if cellUnsafeMass p violates O (O x) ≤ beta * cellMass p O (O x)
      then p x else 0)) :
    (∑ x : World,
      if cellUnsafeMass p violates O (O x) ≤ beta * cellMass p O (O x)
      then (if violates x = true then p x else 0) else 0) /
    (∑ x : World,
      if cellUnsafeMass p violates O (O x) ≤ beta * cellMass p O (O x)
      then p x else 0) ≤ beta := by
  apply (div_le_iff₀ hgrant).2
  exact exact_source_threshold_gate_risk_mass_bound p violates O beta hp hnorm

end Nightfall.FiniteSourceRiskGate

import Mathlib

/-!
# DQ2 physical-binary conditional sections: exact score identities

Pointwise weighted two-atom algebra for the actual conditional law. The all-site
heat-bath Poincare step and full quadratic comparison are separate obligations.
-/

namespace Nightfall.DQ2

noncomputable def binaryConditionalMean (pMinus pPlus : ℝ) : ℝ :=
  (pPlus - pMinus) / (pMinus + pPlus)

/-- Genuine binary conditional score has zero section mean. -/
theorem binary_section_score_mean_zero
    (pMinus pPlus : ℝ) (h : pMinus + pPlus ≠ 0) :
    pPlus * (1 - binaryConditionalMean pMinus pPlus) +
      pMinus * (-1 - binaryConditionalMean pMinus pPlus) = 0 := by
  let m := binaryConditionalMean pMinus pPlus
  have hsum : (pMinus + pPlus) * m = pPlus - pMinus := by
    dsimp [m, binaryConditionalMean]
    field_simp [h]
  change pPlus * (1 - m) + pMinus * (-1 - m) = 0
  nlinarith [hsum]

/-- Conditional variance is the normalized two-atom harmonic product. -/
theorem binary_section_variance_eq
    (pMinus pPlus : ℝ) (h : pMinus + pPlus ≠ 0) :
    1 - (binaryConditionalMean pMinus pPlus) ^ 2 =
      4 * pMinus * pPlus / (pMinus + pPlus) ^ 2 := by
  unfold binaryConditionalMean
  field_simp [h]
  ring

theorem binary_section_variance_pos
    (pMinus pPlus : ℝ) (hm : 0 < pMinus) (hp : 0 < pPlus) :
    0 < 1 - (binaryConditionalMean pMinus pPlus) ^ 2 := by
  have h : pMinus + pPlus ≠ 0 := ne_of_gt (add_pos hm hp)
  rw [binary_section_variance_eq pMinus pPlus h]
  apply div_pos
  · positivity
  · positivity

/-- Native conditional residual second moment, before total mass division. -/
theorem binary_section_score_energy
    (pMinus pPlus : ℝ) (h : pMinus + pPlus ≠ 0) :
    pPlus * (1 - binaryConditionalMean pMinus pPlus) ^ 2 +
      pMinus * (-1 - binaryConditionalMean pMinus pPlus) ^ 2 =
    (pMinus + pPlus) * (1 - (binaryConditionalMean pMinus pPlus) ^ 2) := by
  let m := binaryConditionalMean pMinus pPlus
  have hsum : (pMinus + pPlus) * m = pPlus - pMinus := by
    dsimp [m, binaryConditionalMean]
    field_simp [h]
  have hm := congrArg (fun z : ℝ => m * z) hsum
  change pPlus * (1 - m) ^ 2 + pMinus * (-1 - m) ^ 2 =
    (pMinus + pPlus) * (1 - m ^ 2)
  nlinarith [hm]

/-- Actual spin/conditional-score cross-correlation on each section. -/
theorem binary_section_spin_score
    (pMinus pPlus : ℝ) (h : pMinus + pPlus ≠ 0) :
    pPlus * (1 - binaryConditionalMean pMinus pPlus) +
      pMinus * (1 + binaryConditionalMean pMinus pPlus) =
    (pMinus + pPlus) * (1 - (binaryConditionalMean pMinus pPlus) ^ 2) := by
  let m := binaryConditionalMean pMinus pPlus
  have hsum : (pMinus + pPlus) * m = pPlus - pMinus := by
    dsimp [m, binaryConditionalMean]
    field_simp [h]
  have hm := congrArg (fun z : ℝ => m * z) hsum
  change pPlus * (1 - m) + pMinus * (1 + m) =
    (pMinus + pPlus) * (1 - m ^ 2)
  nlinarith [hm]

#print axioms Nightfall.DQ2.binary_section_score_mean_zero
#print axioms Nightfall.DQ2.binary_section_variance_eq
#print axioms Nightfall.DQ2.binary_section_variance_pos
#print axioms Nightfall.DQ2.binary_section_score_energy
#print axioms Nightfall.DQ2.binary_section_spin_score

end Nightfall.DQ2

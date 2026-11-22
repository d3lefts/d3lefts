import SubcubeSharpScalar

set_option maxRecDepth 8000

namespace Nightfall.StructuralInformation.SubcubeSecantScalar

open Nightfall.StructuralInformation.SubcubeSharpScalar

/-- Critical secant exponent: twice the independently certified rank-one exponent. -/
noncomputable def beta : ℝ := 2 * alpha

theorem beta_ge_one : (1 : ℝ) ≤ beta := by
  unfold beta
  linarith [alpha_gt_one]

theorem three_le_two_rpow_beta : (3 : ℝ) ≤ (2 : ℝ)^beta := by
  have hle : alpha ≤ beta := by
    unfold beta
    linarith [alpha_gt_one]
  have h := Real.rpow_le_rpow_of_exponent_le
    (by norm_num : (1 : ℝ) ≤ 2) hle
  rw [two_rpow_alpha] at h
  exact h

/-- Existing certified generic three-slice inequality transfers to the
    secant degree 2 * log₂ 3 without a new convexity argument. -/
theorem triple_beta (q a b c : ℝ)
    (hq : 0 ≤ q) (ha : 0 ≤ a) (hb : 0 ≤ b) (hc : 0 ≤ c)
    (hab : a+b ≤ q) (hac : a+c ≤ q) (hbc : b+c ≤ q) :
    a^beta + b^beta + c^beta ≤ q^beta :=
  triple_rpow beta q a b c beta_ge_one three_le_two_rpow_beta
    hq ha hb hc hab hac hbc

#print axioms Nightfall.StructuralInformation.SubcubeSecantScalar.beta_ge_one
#print axioms Nightfall.StructuralInformation.SubcubeSecantScalar.three_le_two_rpow_beta
#print axioms Nightfall.StructuralInformation.SubcubeSecantScalar.triple_beta

end Nightfall.StructuralInformation.SubcubeSecantScalar

import Mathlib

/-!
# Exact algebraic floor-four certificate for biased complete quadratic forms

WARNING: these declarations certify the scalar formulas and approach
to coefficient four GIVEN the explicitly displayed source variance
and influence formulas. They do not yet formalize the product-law
expectations over an arbitrary even number of Boolean coordinates.
The source-level witness itself is proved analytically in the related
research passport and independently replayed by exact enumeration.
-/

namespace Nightfall.Observability.Q2MeanFieldFourAlgebra

/-- Squared-variance / (amplitude² * maximum influence) ratio for
the even-n complete quadratic with coordinate mean 1/sqrt(2).
The probability/source law derivation is a separate obligation. -/
noncomputable def ratio (n : ℝ) : ℝ :=
  ((n - 1) * (2*n - 1)^2) / n^3

/-- Pure algebra: the candidate source variance and coordinate
influence values yield exactly the claimed dimension-n ratio. -/
theorem exact_moment_ratio_identity (n : ℝ) (hn : 0 < n) :
    (n*(n-1)*(2*n-1)/8)^2 =
      ratio n * (n^2/4)^2 * (n*(n-1)/4) := by
  have hn0 : n ≠ 0 := ne_of_gt hn
  dsimp [ratio]
  field_simp
  ring

/-- The exact deficit from coefficient four is 8/n-5/n²+1/n³. -/
theorem exact_four_deficit (n : ℝ) (hn : 0 < n) :
    ratio n = 4-8/n+5/n^2-1/n^3 := by
  have hn0 : n ≠ 0 := ne_of_gt hn
  dsimp [ratio]
  field_simp
  ring

/-- All positive dimensions n≥1 achieve at least 4-9/n.
This is the analytic certificate enabling the even-n limit 4. -/
theorem approaches_four_from_below (n : ℝ) (hn : 1 ≤ n) :
    4-9/n ≤ ratio n := by
  have hn0 : 0 < n := by linarith
  have hdiff :
      ratio n-(4-9/n) = (n^2+5*n-1)/n^3 := by
    dsimp [ratio]
    field_simp
    ring
  have hnum : 0 ≤ n^2+5*n-1 := by
    nlinarith [sq_nonneg (n-1)]
  have hden : 0 ≤ n^3 := pow_nonneg (le_of_lt hn0) _
  have hq : 0 ≤ (n^2+5*n-1)/n^3 :=
    div_nonneg hnum hden
  linarith [hdiff, hq]

end Nightfall.Observability.Q2MeanFieldFourAlgebra

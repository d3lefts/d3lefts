import Mathlib

/-! Only arithmetic identities for the finite counterexample.
    This file does NOT prove concentration, the classical query lower bound,
    Markov polynomial stability, or component identification. -/
namespace Nightfall.LatentComponent

private theorem center_gap_identity (m : ℝ) :
    ((3 / 5 : ℝ) + 10 / m) - ((2 / 5 : ℝ) - 10 / m) =
      (1 / 5 : ℝ) + 20 / m := by
  ring

theorem center_gap_gt_two_eps (m : ℝ) (hm : 0 < m) :
    2 * (1 / 10 : ℝ) <
      ((3 / 5 : ℝ) + 10 / m) - ((2 / 5 : ℝ) - 10 / m) := by
  rw [center_gap_identity]
  have hpos : 0 < (20 : ℝ) / m := div_pos (by norm_num) hm
  linarith

theorem bias_difference_identity (m : ℝ) :
    ((1 / 2 : ℝ) + 20 / m) - ((1 / 2 : ℝ) - 20 / m) = 40 / m := by
  ring

theorem bernoulli_variance_le_quarter (m : ℝ) :
    ((1 / 2 : ℝ) - 20 / m) * ((1 / 2 : ℝ) + 20 / m) ≤ 1 / 4 := by
  have hs : 0 ≤ ((20 : ℝ) / m) ^ 2 := sq_nonneg _
  nlinarith [hs]

end Nightfall.LatentComponent

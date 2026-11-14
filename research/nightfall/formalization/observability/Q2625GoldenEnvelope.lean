import Mathlib

/-!
# Golden-ratio polynomial envelope for Q2
The statement is unconditional real arithmetic. A factorization witnesses
global maximality of the scalar tradeoff on the nonnegative half-line.
This is NOT the source-specific Q2 theorem.
-/

namespace Nightfall.Q2625GoldenEnvelope

/-- Exact nonnegative-square factorization behind the golden ratio
q(t) <= (5√5-11)/2 on nonnegative t, after clearing 1+t. -/
theorem golden_polynomial_envelope
    (t : ℝ) (ht : 0 ≤ t) :
    t^2 * (1-t) ≤ (1+t) * ((5*Real.sqrt 5-11)/2) := by
  let r : ℝ := Real.sqrt 5
  have hr0 : 0 ≤ r := Real.sqrt_nonneg _
  have hr2 : r^2 = 5 := Real.sq_sqrt (by norm_num)
  have hrlo : 2 ≤ r := by nlinarith
  have hfactor :
      (1+t) * ((5*r-11)/2) - t^2*(1-t) =
        (t+r-2) * (t-(r-1)/2)^2 := by
    have hr3 : r^3 = 5*r := by nlinarith [hr2]
    have htr2 : t*r^2 = 5*t := by nlinarith [hr2]
    nlinarith [hr2, hr3, htr2]
  have hnonneg : 0 ≤ (t+r-2) * (t-(r-1)/2)^2 :=
    mul_nonneg (by linarith) (sq_nonneg _)
  change t^2*(1-t) ≤ (1+t)*((5*r-11)/2)
  nlinarith [hfactor, hnonneg]

end Nightfall.Q2625GoldenEnvelope

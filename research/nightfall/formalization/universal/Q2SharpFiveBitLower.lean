import Mathlib

/-!
# NIGHTFALL: five-bit exact degree-two lower-bound witness

All finite calculations are on the actual 32 equiprobable fair input
assignments, with the actual fair-resampling influence.

This is a LOWER BOUND on the best possible universal degree-two
coefficient C: C >= 9/4. The proposed C=4 survives.
No upper-bound theorem, priority claim, or sharp constant is asserted.
-/

namespace Nightfall.Q2SharpFiveBitLower

def bit (x : Fin 5 → Bool) (i : Fin 5) : ℤ :=
  if x i then 1 else -1

def flip (i : Fin 5) (x : Fin 5 → Bool) : Fin 5 → Bool :=
  Function.update x i (!(x i))

/-- Degree-at-most-two real polynomial, integer-valued on the fair cube.
Its 12 nonzero Walsh coefficients are all +1 or -1. -/
def witness (x : Fin 5 → Bool) : ℤ :=
  let a := bit x 0
  let b := bit x 1
  let c := bit x 2
  let d := bit x 3
  let e := bit x 4
  a + c + d + e + a*b - a*c + a*d - b*c - b*d + b*e + c*e - d*e

/-- Enumerates all 32 original source input assignments. -/
def fairMean : ℚ :=
  (∑ x : Fin 5 → Bool, (witness x : ℚ)) / 32

def fairVariance : ℚ :=
  (∑ x : Fin 5 → Bool, ((witness x : ℚ) - fairMean)^2) / 32

/-- True coordinate-resampling influence. For a fair bit,
E_(X,X'_i)[(f(X)-f(X_i<-X'_i))²/2] equals the 1/4 averaged flip square.
Thus with 32 input states the denominator is 4*32=128. -/
def fairResamplingInfluence (i : Fin 5) : ℚ :=
  (∑ x : Fin 5 → Bool,
    ((witness x - witness (flip i x) : ℤ) : ℚ)^2) / 128

theorem witness_range : ∀ x : Fin 5 → Bool,
    (-4 : ℤ) ≤ witness x ∧ witness x ≤ 4 := by
  decide

theorem witness_attains_bounds :
    (∃ x : Fin 5 → Bool, witness x = -4) ∧
    (∃ x : Fin 5 → Bool, witness x = 4) := by
  decide

theorem witness_mean_zero : fairMean = 0 := by
  decide

theorem witness_variance_twelve : fairVariance = 12 := by
  decide

theorem witness_source_influence_four :
    ∀ i : Fin 5, fairResamplingInfluence i = 4 := by
  decide

/-- Actual half-range B=4, variance V=12, max original resampling
influence M=4 give the **exact** ratio V²/(B² M) = 9/4. -/
theorem witness_exact_nine_four :
    fairVariance^2 = (9 / 4 : ℚ) * (4 : ℚ)^2 * 4 := by
  rw [witness_variance_twelve]
  norm_num

/-- A proposed stronger coefficient-two inequality is genuinely
false, already for this degree-two fair-product polynomial. -/
theorem refutes_coefficient_two :
    ¬ fairVariance^2 ≤ (2 : ℚ) * (4 : ℚ)^2 * 4 := by
  rw [witness_variance_twelve]
  norm_num

#print axioms Nightfall.Q2SharpFiveBitLower.witness_range
#print axioms Nightfall.Q2SharpFiveBitLower.witness_attains_bounds
#print axioms Nightfall.Q2SharpFiveBitLower.witness_mean_zero
#print axioms Nightfall.Q2SharpFiveBitLower.witness_variance_twelve
#print axioms Nightfall.Q2SharpFiveBitLower.witness_source_influence_four
#print axioms Nightfall.Q2SharpFiveBitLower.witness_exact_nine_four
#print axioms Nightfall.Q2SharpFiveBitLower.refutes_coefficient_two

end Nightfall.Q2SharpFiveBitLower

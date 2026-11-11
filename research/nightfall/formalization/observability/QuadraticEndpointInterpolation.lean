import Mathlib

/-!
# Scalar endpoint interpolation from genuine Hilbert moment data

This theorem closes ONLY the nontrivial scalar inequality after an
L1-L2-L4 interpolation and an independently proved fourth-moment bound
have been supplied. The interpolation premise is explicit, not silently
asserted as a theorem about an actual product observable.
-/

namespace Nightfall.Observability.QuadraticEndpointInterpolation

/-- If s=E||Z||², z=E||Z|| and the genuine L1/L2/L4
interpolation and independent-increment fourth-moment estimate hold,
then s <= z*(c+sqrt(3 M)) whenever s <= M. -/
theorem energy_of_interpolated_hilbert_moment
    (s z c M : ℝ)
    (hs : 0 ≤ s) (hz : 0 ≤ z) (hc : 0 ≤ c)
    (hM : s ≤ M)
    (hinter :
      s ^ 3 ≤ z ^ 2 * (c ^ 2 * s + 3 * s ^ 2)) :
    s ≤ z * (c + Real.sqrt (3 * M)) := by
  have hM0 : 0 ≤ M := le_trans hs hM
  have hroot : (Real.sqrt (3 * M)) ^ 2 = 3 * M :=
    Real.sq_sqrt (mul_nonneg (by norm_num) hM0)
  have hroot0 : 0 ≤ Real.sqrt (3 * M) := Real.sqrt_nonneg _
  by_cases hzero : s = 0
  · rw [hzero]
    exact mul_nonneg hz (add_nonneg hc hroot0)
  have hspos : 0 < s := lt_of_le_of_ne hs (Ne.symm hzero)
  have hfactor :
      z ^ 2 * (c ^ 2 * s + 3 * s ^ 2) =
      s * (z ^ 2 * (c ^ 2 + 3 * s)) := by ring
  have hcube : s ^ 3 = s * s ^ 2 := by ring
  rw [hfactor, hcube] at hinter
  have hsq : s ^ 2 ≤ z ^ 2 * (c ^ 2 + 3 * s) :=
    (mul_le_mul_left hspos).mp hinter
  have hupper : c ^ 2 + 3 * s ≤
      (c + Real.sqrt (3 * M)) ^ 2 := by
    nlinarith [hroot, mul_nonneg hc hroot0, hM]
  have hstep := mul_le_mul_of_nonneg_left hupper (sq_nonneg z)
  have hsquare : s ^ 2 ≤
      (z * (c + Real.sqrt (3 * M))) ^ 2 := by
    nlinarith [hsq, hstep]
  have hrhs : 0 ≤ z * (c + Real.sqrt (3 * M)) :=
    mul_nonneg hz (add_nonneg hc hroot0)
  nlinarith [hsquare]

end Nightfall.Observability.QuadraticEndpointInterpolation

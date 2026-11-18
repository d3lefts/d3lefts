import Mathlib

/-!
# Exact sharp L1/L2 Rademacher inequality for two vectors

This is the two-vector case of the Hilbert-valued Khintchine inequality, in
fact valid for every real normed vector space. The coefficient sqrt(2) is sharp.
The full finite-family inequality for *arbitrarily many* Rademacher signs is
a separate analytic theorem and IS NOT proved here. No inductive reuse of the
two-term estimate alone is claimed to preserve the sharp constant.
-/

namespace Nightfall.CubicQ3.TwoSign

/-- Pairwise signed average has a universal sharp √2 L1/L2 constant.
This holds for arbitrary real normed spaces, not just Hilbert spaces.
It is exactly the two-coefficient Khintchine--Kahane step. -/
theorem sharp_two_sign_rademacher
    {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]
    (u v : E) :
    Real.sqrt (‖u‖ ^ 2 + ‖v‖ ^ 2) ≤
      Real.sqrt (2 : ℝ) * ((‖u + v‖ + ‖u - v‖) / 2) := by
  let s : ℝ := ‖u + v‖ + ‖u - v‖
  have hs : 0 ≤ s := add_nonneg (norm_nonneg _) (norm_nonneg _)
  have hnormu : ‖u + u‖ = (2 : ℝ) * ‖u‖ := by
    calc
      ‖u + u‖ = ‖(2 : ℝ) • u‖ := by rw [two_smul]
      _ = ‖(2 : ℝ)‖ * ‖u‖ := norm_smul _ _
      _ = (2 : ℝ) * ‖u‖ := by norm_num
  have hnormv : ‖v + v‖ = (2 : ℝ) * ‖v‖ := by
    calc
      ‖v + v‖ = ‖(2 : ℝ) • v‖ := by rw [two_smul]
      _ = ‖(2 : ℝ)‖ * ‖v‖ := norm_smul _ _
      _ = (2 : ℝ) * ‖v‖ := by norm_num
  have hu : 2 * ‖u‖ ≤ s := by
    calc
      (2 : ℝ) * ‖u‖ = ‖u + u‖ := hnormu.symm
      _ = ‖(u + v) + (u - v)‖ := by
        congr 1
        abel
      _ ≤ ‖u + v‖ + ‖u - v‖ := norm_add_le _ _
      _ = s := rfl
  have hv : 2 * ‖v‖ ≤ s := by
    calc
      (2 : ℝ) * ‖v‖ = ‖v + v‖ := hnormv.symm
      _ = ‖(u + v) - (u - v)‖ := by
        congr 1
        abel
      _ ≤ ‖u + v‖ + ‖u - v‖ := norm_sub_le _ _
      _ = s := rfl
  have hnu : 0 ≤ ‖u‖ := norm_nonneg _
  have hnv : 0 ≤ ‖v‖ := norm_nonneg _
  have hsqU : (2 * ‖u‖) ^ 2 ≤ s ^ 2 := by
    have hp := mul_nonneg (sub_nonneg.mpr hu)
      (add_nonneg hs (mul_nonneg (by norm_num) hnu))
    nlinarith
  have hsqV : (2 * ‖v‖) ^ 2 ≤ s ^ 2 := by
    have hp := mul_nonneg (sub_nonneg.mpr hv)
      (add_nonneg hs (mul_nonneg (by norm_num) hnv))
    nlinarith
  have hE : 0 ≤ ‖u‖ ^ 2 + ‖v‖ ^ 2 := by positivity
  have htarget : 2 * (‖u‖ ^ 2 + ‖v‖ ^ 2) ≤ s ^ 2 := by
    nlinarith [hsqU, hsqV]
  have hrootE : (Real.sqrt (‖u‖ ^ 2 + ‖v‖ ^ 2)) ^ 2 =
      ‖u‖ ^ 2 + ‖v‖ ^ 2 := Real.sq_sqrt hE
  have hroot2 : (Real.sqrt (2 : ℝ)) ^ 2 = 2 :=
    Real.sq_sqrt (by norm_num)
  have hz : 0 ≤ Real.sqrt (2 : ℝ) *
      Real.sqrt (‖u‖ ^ 2 + ‖v‖ ^ 2) :=
    mul_nonneg (Real.sqrt_nonneg _) (Real.sqrt_nonneg _)
  have hle : Real.sqrt (2 : ℝ) *
      Real.sqrt (‖u‖ ^ 2 + ‖v‖ ^ 2) ≤ s := by
    nlinarith [htarget]
  have hmul := mul_le_mul_of_nonneg_left hle
    (Real.sqrt_nonneg (2 : ℝ))
  dsimp [s] at *
  nlinarith [hroot2]

/-- The pair u=v=1 saturates the constant, so it cannot be improved even for
real scalars. This is a concrete exact equality, not a numerical search. -/
theorem sharp_two_sign_scalar_extremizer :
    Real.sqrt ((1 : ℝ) ^ 2 + (1 : ℝ) ^ 2) =
      Real.sqrt (2 : ℝ) *
      ((|(1 : ℝ) + 1| + |(1 : ℝ) - 1|) / 2) := by
  norm_num

end Nightfall.CubicQ3.TwoSign

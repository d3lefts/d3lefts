import Mathlib

/-!
NIGHTFALL Q2 rational two-fifths scalar certificate.
This proves a quadratic-switch algebra lemma and C<100 arithmetic only.
No independent-Hilbert c/5 premise, source mask identity, or terminal
original-source theorem is being assumed or certified here.
-/

namespace Nightfall.Q2RationalTwoFifths

theorem quadratic_switch_linear_range_two_fifths
    (A Dy Dz Qy Qz Py Pz Fy Fz B : ℝ)
    (hPy : Py = A + (2/5:ℝ)*Dy + (4/25:ℝ)*Qy)
    (hPz : Pz = A + (2/5:ℝ)*Dz + (4/25:ℝ)*Qz)
    (hFy : Fy = A + Dy + Qy)
    (hFz : Fz = A + Dz + Qz)
    (hbPy : |Py| ≤ B) (hbPz : |Pz| ≤ B)
    (hbFy : |Fy| ≤ B) (hbFz : |Fz| ≤ B) :
    Dy - Dz ≤ (29/3:ℝ)*B := by
  have hidentity : 6*(Dy-Dz) = 25*(Py-Pz)-4*(Fy-Fz) := by
    rw [hPy, hPz, hFy, hFz]
    ring
  have hp : Py-Pz ≤ 2*B := by
    have h1 := (abs_le.mp hbPy).2
    have h2 := (abs_le.mp hbPz).1
    linarith
  have hf : -(Fy-Fz) ≤ 2*B := by
    have h1 := (abs_le.mp hbFy).1
    have h2 := (abs_le.mp hbFz).2
    linarith
  linarith

/-- Conditional coefficient at rational section budget 29B/6 and c/5. -/
theorem rational_c5_coefficient_lt_hundred :
    ((29/6:ℝ)*Real.sqrt 3 + 8/5)^2 < 100 := by
  have hr0 : 0 ≤ Real.sqrt (3:ℝ) := Real.sqrt_nonneg _
  have hr2 : (Real.sqrt (3:ℝ))^2 = 3 :=
    Real.sq_sqrt (by norm_num)
  have hr : Real.sqrt (3:ℝ) < 26/15 := by
    nlinarith
  have hnonneg : 0 ≤ (29/6:ℝ)*Real.sqrt 3+8/5 := by
    positivity
  have hlt10 : (29/6:ℝ)*Real.sqrt 3+8/5 < 10 := by
    nlinarith
  nlinarith

end Nightfall.Q2RationalTwoFifths

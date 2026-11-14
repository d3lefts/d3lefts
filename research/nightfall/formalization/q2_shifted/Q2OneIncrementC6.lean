import Mathlib

/-!
# Q2 reverse first moment: exact one-increment c/6 gate

This module certifies a **single-increment** implication with an exact rational
square-gap proof. It does NOT tensorize this implication to sums of independent
increments. In particular it does not assert the unrestricted original-source
degree-two coefficient is below 100.

Let Y be one centered Hilbert-valued increment, ||Y|| <= c a.s., h fixed,
a=||h||, R=||h+Y||, u=E R, e=E R^2. Triangle inequality gives
0 <= R <= a+c; therefore e <= (a+c)u. Jensen gives a <= u.
The declaration below closes precisely this nontrivial scalar endpoint.

To prove the one-step statement for a concrete finite probability law, its
R/e assumptions must be supplied from the *actual* law. There is no source
transport or independently-centered multi-increment proof in this file.
-/

namespace Nightfall.Q2OneStep

/-- Exact sum-of-squares certificate for the target c/6 local correction.
The identity is
  (sqrt(3)*u+c/6)^2-(u^2+c*u)
    =2*(u-c/9)^2+c^2/324+(sqrt(3)-5/3)*u*c/3.
All three terms on the right are nonnegative for u,c>=0. -/
theorem c6_square_gap (u c : ℝ) (hu : 0 ≤ u) (hc : 0 ≤ c) :
    u^2 + c*u ≤ (Real.sqrt 3*u+c/6)^2 := by
  have hs : (Real.sqrt (3:ℝ))^2 = 3 :=
    Real.sq_sqrt (by norm_num)
  have hroot : (5/3:ℝ) ≤ Real.sqrt 3 := by
    have hn : 0 ≤ Real.sqrt (3:ℝ) := Real.sqrt_nonneg _
    nlinarith
  have hterm1 : 0 ≤ 2*(u-c/9)^2+c^2/324 := by positivity
  have hterm2 : 0 ≤ (Real.sqrt 3-5/3)*u*c/3 := by
    have hdiff : 0 ≤ Real.sqrt (3:ℝ)-5/3 := by linarith
    positivity
  have hid :
      (Real.sqrt 3*u+c/6)^2-(u^2+c*u) =
        2*(u-c/9)^2+c^2/324+(Real.sqrt 3-5/3)*u*c/3 := by
    calc
      (Real.sqrt 3*u+c/6)^2-(u^2+c*u)
          = ((Real.sqrt 3)^2-1)*u^2+((Real.sqrt 3)/3-1)*u*c+c^2/36 := by ring
      _ = 2*u^2+((Real.sqrt 3)/3-1)*u*c+c^2/36 := by rw [hs]; ring
      _ = 2*(u-c/9)^2+c^2/324+(Real.sqrt 3-5/3)*u*c/3 := by ring
  linarith

/-- A Hilbert one-increment reverse-Khintchine c/6 endpoint, once the
actual distribution's range and Jensen inequalities have been established.
No second independent increment is permitted by these hypotheses. -/
theorem single_increment_c6
    (a u e c : ℝ)
    (ha : 0 ≤ a) (hc : 0 ≤ c)
    (hJensen : a ≤ u) (he : 0 ≤ e)
    (hRangeSecond : e ≤ (a+c)*u) :
    Real.sqrt e ≤ Real.sqrt 3*u+c/6 := by
  have hu : 0 ≤ u := le_trans ha hJensen
  have hcap : (a+c)*u ≤ (u+c)*u :=
    mul_le_mul_of_nonneg_right (by linarith) hu
  have heupper : e ≤ u^2+c*u := by
    nlinarith [hRangeSecond, hcap]
  have hsquare := c6_square_gap u c hu hc
  have hR : 0 ≤ Real.sqrt 3*u+c/6 := by positivity
  have hS : (Real.sqrt e)^2 = e := Real.sq_sqrt he
  nlinarith

end Nightfall.Q2OneStep

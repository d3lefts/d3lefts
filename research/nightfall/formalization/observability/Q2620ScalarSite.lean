import Mathlib

/-!
# Strict joint-cap Q2 site: the 620.020 target

This uses the same-coordinate budget a^2+s<=T^2, rather than separate
caps. It is a scalar theorem; the source bridge is distinct.
-/

namespace Nightfall.Q2620ScalarSite

theorem coupled_joint_site
    (a u z s c T gamma : ℝ)
    (hT : 0 ≤ T) (ha : 0 ≤ a) (hc : 0 ≤ c)
    (hg : 0 ≤ gamma)
    (hJensen : a ≤ u) (hnoise : z ≤ u + a)
    (hjoint : a^2 + s ≤ T^2)
    (htrade : s ≤ Real.sqrt 3 * T * z + gamma * T * c) :
    a^2+s ≤ T*(Real.sqrt 3*u+2*a+gamma*c) := by
  let rho : ℝ := Real.sqrt 3
  let q : ℝ := 2-rho
  have hrho0 : 0 ≤ rho := by dsimp [rho]; positivity
  have hrho2 : rho^2 = 3 := by
    dsimp [rho]
    exact Real.sq_sqrt (by norm_num)
  have hq : 0 ≤ q := by
    dsimp [q]
    nlinarith [hrho2]
  have hrT : 0 ≤ rho*T := mul_nonneg hrho0 hT
  have hgc : 0 ≤ gamma*T*c := mul_nonneg (mul_nonneg hg hT) hc
  by_cases hsmall : a ≤ q*T
  · have hsq : a^2 ≤ q*T*a := by
      nlinarith [mul_nonneg ha (sub_nonneg.mpr hsmall)]
    have hz := mul_le_mul_of_nonneg_left hnoise hrT
    dsimp [rho, q] at *
    nlinarith [hsq, hz, htrade]
  · have hlarge : q*T ≤ a := le_of_lt (lt_of_not_ge hsmall)
    have hmult := mul_le_mul_of_nonneg_left hlarge
      (mul_nonneg (by linarith : 0 ≤ rho+2) hT)
    have hux := mul_le_mul_of_nonneg_left hJensen hrT
    have hrho2T : rho^2*T^2 = 3*T^2 := by
      nlinarith [congrArg (fun v : ℝ => v*T^2) hrho2]
    dsimp [rho, q] at *
    nlinarith [hmult, hux, hjoint, hrho2T, hgc]

end Nightfall.Q2620ScalarSite

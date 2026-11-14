import Mathlib

/-!
# Q2 620 sitewise closure — exact joint-energy scalar certificate

No probability premise is hidden. The joint cap a²+s≤T² and
the cubic-derived tradeoff are explicit hypotheses here.
The source terminal imports them from original finite product p,f.
-/

namespace Nightfall.Q2620ScalarSite

theorem coupled_joint_site_620
    (a u z s c T gamma : ℝ)
    (hT : 0 ≤ T) (ha : 0 ≤ a)
    (hc : 0 ≤ c) (hgamma : 0 ≤ gamma)
    (hJensen : a ≤ u) (hnoise : z ≤ u + a)
    (hjoint : a^2 + s ≤ T^2)
    (htrade : s ≤ Real.sqrt 3 * T * z + gamma * T * c) :
    a^2 + s ≤ T * (Real.sqrt 3 * u + 2*a + gamma*c) := by
  let r : ℝ := Real.sqrt 3
  let q : ℝ := 2 - r
  have hr : 0 ≤ r := Real.sqrt_nonneg _
  have hr2 : r^2 = 3 := Real.sq_sqrt (by norm_num)
  have hrle : r ≤ 2 := by nlinarith
  have hq : 0 ≤ q := by dsimp [q]; linarith
  have hqsum : q + r = 2 := by dsimp [q]; ring
  have hqprod : (2*r + q)*q = 1 := by
    dsimp [q]
    nlinarith [hr2]
  have htrade' : s ≤ r*T*z + gamma*T*c := by simpa only [r] using htrade
  have hrT : 0 ≤ r*T := mul_nonneg hr hT
  have hnoise' : r*T*z ≤ r*T*(u+a) :=
    mul_le_mul_of_nonneg_left hnoise hrT
  have htarget : T*(r*u + 2*a + gamma*c) =
      (2*r + q)*T*a + r*T*(u-a) + gamma*T*c := by
    have htwo : (2:ℝ) = r+q := by linarith [hqsum]
    rw [htwo]
    ring
  by_cases hsmall : a ≤ q*T
  · have hsmallprod : 0 ≤ a*(q*T-a) :=
      mul_nonneg ha (sub_nonneg.mpr hsmall)
    have hsmallbound : a^2 ≤ q*T*a := by nlinarith [hsmallprod]
    have htotal : a^2+s ≤ q*T*a + r*T*(u+a) + gamma*T*c := by
      linarith [hsmallbound, htrade', hnoise']
    have hsplit : q*T*a+r*T*(u+a)+gamma*T*c =
        T*(r*u+2*a+gamma*c) := by
      have htwo : (2:ℝ) = r+q := by linarith [hqsum]
      rw [htwo]
      ring
    exact htotal.trans (le_of_eq hsplit)
  · have hlarge : q*T ≤ a := le_of_lt (lt_of_not_ge hsmall)
    have hcoef : 0 ≤ 2*r+q := by nlinarith [hr, hq]
    have hlargeprod : 0 ≤ (2*r+q)*T*(a-q*T) :=
      mul_nonneg (mul_nonneg hcoef hT) (sub_nonneg.mpr hlarge)
    have hqmul : (2*r+q)*q*T^2 = T^2 := by rw [hqprod]; ring
    have hupos : 0 ≤ r*T*(u-a) :=
      mul_nonneg hrT (sub_nonneg.mpr hJensen)
    have hgcpos : 0 ≤ gamma*T*c :=
      mul_nonneg (mul_nonneg hgamma hT) hc
    have hgoal : T^2 ≤ T*(r*u+2*a+gamma*c) := by
      nlinarith [hlargeprod, hqmul, hupos, hgcpos, htarget]
    exact hjoint.trans (by simpa only [r] using hgoal)

end Nightfall.Q2620ScalarSite

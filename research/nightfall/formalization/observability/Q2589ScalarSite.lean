import Q2625GoldenTrade

/-!
# Q2 589.97569: homogeneous golden-cubic and joint-energy scalar site

Uses the fourth-moment cubic at the TRUE owned moment s, choosing
T_local=sqrt(s) instead of the global T=sqrt(M), retaining the joint
a^2+s<=M coupling. The only input beyond algebra is the source-proved cubic inequality.
No novel fourth-moment estimate or caller-supplied
source premise occurs here: this is a purely exact deterministic lemma.
-/

namespace Nightfall.Q2589ScalarSite

open Nightfall.Q2625Golden
open Nightfall.Q2625GoldenTrade

/-- Joint energy and original cubic give a stronger, sharp scalar site:
coefficient sqrt(13)-sqrt(3) instead of 2 on singleton norm. -/
theorem joint_energy_cubic_site_589
    (a u z s c T : ℝ)
    (hT : 0 ≤ T) (ha : 0 ≤ a)
    (hs : 0 ≤ s) (hz : 0 ≤ z) (hc : 0 ≤ c)
    (hau : a ≤ u) (hzu : z ≤ u+a)
    (hjoint : a^2+s ≤ T^2)
    (hcubic : s^3 ≤ z^2*(c^2*s+3*s^2)) :
    a^2+s ≤ T * (Real.sqrt 3*u +
      (Real.sqrt 13-Real.sqrt 3)*a + gamma*c) := by
  let r : ℝ := Real.sqrt 3
  let R : ℝ := Real.sqrt 13
  let t : ℝ := Real.sqrt s
  have hr0 : 0 ≤ r := Real.sqrt_nonneg _
  have hR0 : 0 ≤ R := Real.sqrt_nonneg _
  have ht0 : 0 ≤ t := Real.sqrt_nonneg _
  have hr2 : r^2 = 3 := Real.sq_sqrt (by norm_num)
  have hR2 : R^2 = 13 := Real.sq_sqrt (by norm_num)
  have ht2 : t^2 = s := Real.sq_sqrt hs
  have hgamma : 0 ≤ gamma := gamma_nonneg
  have hTt : t ≤ T := by
    have hsT : t^2 ≤ T^2 := by rw [ht2]; nlinarith [sq_nonneg a, hjoint]
    nlinarith
  have htrade : s ≤ r*t*z + gamma*t*c := by
    have h := cubic_to_sharp_affine s z c t
      hs hz hc ht0 (by rw [ht2]) hcubic
    simpa only [r] using h
  have hnoise : r*t*z ≤ r*t*(u+a) :=
    mul_le_mul_of_nonneg_left hzu (mul_nonneg hr0 ht0)
  have hlower : a^2+s ≤ a^2+r*t*(u+a)+gamma*t*c := by
    nlinarith [htrade, hnoise]
  have hsos : 13*(a^2+t^2)-(a+2*r*t)^2 =
      (2*r*a-t)^2 := by
    have hpoly : 13*(a^2+t^2)-(a+2*r*t)^2 =
        (2*r*a-t)^2+4*(3-r^2)*(a^2+t^2) := by ring
    rw [hr2] at hpoly
    nlinarith [hpoly]
  have hnormsq : (a+2*r*t)^2 ≤ (R*T)^2 := by
    have hh : a^2+t^2 ≤ T^2 := by rw [ht2]; exact hjoint
    rw [mul_pow, hR2]
    nlinarith [hsos, sq_nonneg (2*r*a-t)]
  have hlin : a+2*r*t ≤ R*T := by
    have hp : 0 ≤ a+2*r*t := by positivity
    have hq : 0 ≤ R*T := mul_nonneg hR0 hT
    nlinarith [hnormsq]
  have h0 : 0 ≤ r*(T-t)*(u-a) :=
    mul_nonneg (mul_nonneg hr0 (sub_nonneg.mpr hTt))
      (sub_nonneg.mpr hau)
  have h1 : 0 ≤ gamma*(T-t)*c :=
    mul_nonneg (mul_nonneg hgamma (sub_nonneg.mpr hTt)) hc
  have h2 : 0 ≤ a*(R*T-a-2*r*t) :=
    mul_nonneg ha (by linarith [hlin])
  have hidentity :
      T*(r*u+(R-r)*a+gamma*c) -
      (a^2+r*t*(u+a)+gamma*t*c) =
      r*(T-t)*(u-a)+gamma*(T-t)*c+
        a*(R*T-a-2*r*t) := by ring
  have hupper : a^2+r*t*(u+a)+gamma*t*c ≤
      T*(r*u+(R-r)*a+gamma*c) := by
    nlinarith [hidentity, h0, h1, h2]
  exact hlower.trans (by simpa only [r,R] using hupper)

end Nightfall.Q2589ScalarSite

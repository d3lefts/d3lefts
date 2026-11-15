import Mathlib

/-!
A positive shifted c/5 case: one bounded centered Hilbert increment.

Actual-Hilbert argument external to this scalar file:
W=h+Y, E Y=0, ||Y||<=c, u=E||W||, e=E||W||².
Jensen gives ||h||<=u, while ||W||<=||h||+c<=u+c.
Hence e<=u(u+c). The lemma proves the c/5 conclusion from this
genuine one-increment condition. No multiple-increment tensorization
or original-source Q2 theorem is asserted.
-/

namespace Nightfall.Q2Shifted.OneJump

theorem c5_from_one_increment_energy
    (e u c : ℝ) (he : 0 ≤ e) (hu : 0 ≤ u) (hc : 0 ≤ c)
    (hbound : e ≤ u*(u+c)) :
    Real.sqrt e ≤ Real.sqrt 3*u+c/5 := by
  have hr0 : 0 ≤ Real.sqrt (3:ℝ) := Real.sqrt_nonneg _
  have hr2 : (Real.sqrt (3:ℝ))^2 = 3 :=
    Real.sq_sqrt (by norm_num)
  have hr : (5/3:ℝ) ≤ Real.sqrt 3 := by
    nlinarith
  have hx : (Real.sqrt (3:ℝ)*u)^2 = 3*u^2 := by
    calc
      _ = (Real.sqrt (3:ℝ))^2*u^2 := by ring
      _ = 3*u^2 := by rw [hr2]
  have hp : 0 ≤ (Real.sqrt 3-(5/3:ℝ))*u*c := by
    exact mul_nonneg (mul_nonneg (sub_nonneg.mpr hr) hu) hc
  have hid :
      (Real.sqrt 3*u+c/5)^2-u*(u+c) =
        2*(u-c/12)^2+(47/1800:ℝ)*c^2 +
        (2/5:ℝ)*(Real.sqrt 3-5/3)*u*c := by
    nlinarith [hx]
  have hsq : u*(u+c) ≤ (Real.sqrt 3*u+c/5)^2 := by
    nlinarith [sq_nonneg (u-c/12), sq_nonneg c, hp]
  have hroot2 : (Real.sqrt e)^2 = e := Real.sq_sqrt he
  have hright : 0 ≤ Real.sqrt 3*u+c/5 := by positivity
  have hleft : 0 ≤ Real.sqrt e := Real.sqrt_nonneg _
  nlinarith

end Nightfall.Q2Shifted.OneJump

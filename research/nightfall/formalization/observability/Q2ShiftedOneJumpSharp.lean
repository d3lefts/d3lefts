import Mathlib

/-!
The sharp scalar component of a shifted one-increment Hilbert lemma.
For W=h+Y where E Y=0 and ||Y||<=c, the elementary probabilistic
ingredient is e=E||W||²<=u(u+c), with u=E||W|| (Jensen).

This file certifies the exact optimal coefficient in that consequence,
not the Hilbert Jensen argument or the multi-increment probability claim.
-/

namespace Nightfall.Q2Shifted.OneJumpSharp

noncomputable def beta : ℝ := (Real.sqrt 3-Real.sqrt 2)/2
noncomputable def kappa : ℝ := (Real.sqrt 6-2)/4

theorem beta_nonneg : 0 ≤ beta := by
  unfold beta
  have h := Real.sqrt_le_sqrt (show (2:ℝ) ≤ 3 by norm_num)
  linarith

theorem beta_lt_fifth : beta < (1/5:ℝ) := by
  have h3 : (Real.sqrt (3:ℝ))^2 = 3 := Real.sq_sqrt (by norm_num)
  have h2 : (Real.sqrt (2:ℝ))^2 = 2 := Real.sq_sqrt (by norm_num)
  have hroot3 : 0 ≤ Real.sqrt (3:ℝ) := Real.sqrt_nonneg _
  have hroot2 : 0 ≤ Real.sqrt (2:ℝ) := Real.sqrt_nonneg _
  have h2lower : 7/5 < Real.sqrt (2:ℝ) := by nlinarith
  have h3upper : Real.sqrt (3:ℝ) < 9/5 := by nlinarith
  unfold beta
  linarith

theorem one_increment_sharp_scalar
    (e u c : ℝ) (he : 0 ≤ e) (hu : 0 ≤ u) (hc : 0 ≤ c)
    (hbound : e ≤ u*(u+c)) :
    Real.sqrt e ≤ Real.sqrt 3*u+beta*c := by
  have hr3 : (Real.sqrt (3:ℝ))^2 = 3 := Real.sq_sqrt (by norm_num)
  have hr2 : (Real.sqrt (2:ℝ))^2 = 2 := Real.sq_sqrt (by norm_num)
  have hr6 : (Real.sqrt (6:ℝ))^2 = 6 := Real.sq_sqrt (by norm_num)
  have hs3 : 0 ≤ Real.sqrt (3:ℝ) := Real.sqrt_nonneg _
  have hs2 : 0 ≤ Real.sqrt (2:ℝ) := Real.sqrt_nonneg _
  have hs6 : 0 ≤ Real.sqrt (6:ℝ) := Real.sqrt_nonneg _
  have hs32 : Real.sqrt (3:ℝ)*Real.sqrt (2:ℝ) = Real.sqrt 6 := by
    nlinarith [sq_nonneg (Real.sqrt (3:ℝ)*Real.sqrt (2:ℝ))]
  have hcros : 2*Real.sqrt (3:ℝ)*beta-1 = -4*kappa := by
    unfold beta kappa
    nlinarith [hs32]
  have hbetasq : beta^2 = 2*kappa^2 := by
    unfold beta kappa
    nlinarith [hr3,hr2,hr6,hs32]
  have hident : (Real.sqrt 3*u+beta*c)^2-u*(u+c) =
      2*(u-kappa*c)^2 := by
    calc
      _ = 2*u^2+(2*Real.sqrt 3*beta-1)*u*c+beta^2*c^2 := by
        nlinarith [hr3]
      _ = 2*u^2-4*kappa*u*c+2*kappa^2*c^2 := by
        rw [hcros, hbetasq]
        ring
      _ = 2*(u-kappa*c)^2 := by ring
  have hsq : u*(u+c) ≤ (Real.sqrt 3*u+beta*c)^2 := by
    nlinarith [sq_nonneg (u-kappa*c)]
  have heq : (Real.sqrt e)^2 = e := Real.sq_sqrt he
  have hleft : 0 ≤ Real.sqrt e := Real.sqrt_nonneg _
  have hright : 0 ≤ Real.sqrt 3*u+beta*c :=
    add_nonneg (mul_nonneg (Real.sqrt_nonneg _) hu)
               (mul_nonneg beta_nonneg hc)
  nlinarith

theorem one_increment_implies_c5
    (e u c : ℝ) (he : 0 ≤ e) (hu : 0 ≤ u) (hc : 0 ≤ c)
    (hbound : e ≤ u*(u+c)) :
    Real.sqrt e ≤ Real.sqrt 3*u+c/5 := by
  have hb := one_increment_sharp_scalar e u c he hu hc hbound
  have hf := beta_lt_fifth
  nlinarith [mul_nonneg (sub_nonneg.mpr beta_nonneg) hc]

end Nightfall.Q2Shifted.OneJumpSharp

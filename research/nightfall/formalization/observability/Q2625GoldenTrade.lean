import Q2625Golden

/-!
# Exact fourth-moment cubic -> capped golden-ratio affine envelope

Pure real algebra. All genuine-source connection remains elsewhere.
-/

namespace Nightfall.Q2625GoldenTrade

open Nightfall.Q2625Golden

theorem cubic_to_sharp_affine
    (s z c T : ℝ)
    (hs : 0 ≤ s) (hz : 0 ≤ z) (hc : 0 ≤ c) (hT : 0 ≤ T)
    (hcap : s ≤ T^2)
    (hcubic : s^3 ≤ z^2 * (c^2*s + 3*s^2)) :
    s ≤ Real.sqrt 3 * T * z + gamma * T * c := by
  have hr : 0 < Real.sqrt (3 : ℝ) := Real.sqrt_pos.2 (by norm_num)
  have hr2 : (Real.sqrt (3 : ℝ))^2 = 3 :=
    Real.sq_sqrt (by norm_num)
  have hg : 0 ≤ gamma := gamma_nonneg
  have hright : 0 ≤ Real.sqrt (3 : ℝ) * T * z + gamma * T * c := by
    positivity
  by_cases hs0 : s = 0
  · simp [hs0]
    exact hright
  have hspos : 0 < s := lt_of_le_of_ne hs (Ne.symm hs0)
  by_cases hT0 : T = 0
  · have hzero : s = 0 := by
      rw [hT0] at hcap
      nlinarith
    exact (hs0 hzero).elim
  have hTpos : 0 < T := lt_of_le_of_ne hT (Ne.symm hT0)
  let Y : ℝ := Real.sqrt 3 * T * z
  have hY : 0 ≤ Y := by
    dsimp [Y]
    positivity
  have hY2 : Y^2 = 3*T^2*z^2 := by
    dsimp [Y]
    rw [mul_pow, mul_pow, hr2]
  have hcubic2 : s^2 ≤ z^2*(c^2+3*s) := by
    by_contra hn
    have hd : 0 < s^2-z^2*(c^2+3*s) := by linarith
    have hprod := mul_pos hspos hd
    nlinarith [hprod, hcubic]
  have hmul := mul_le_mul_of_nonneg_left hcubic2
    (mul_nonneg (by norm_num : (0:ℝ) ≤ 3) (sq_nonneg T))
  have hbase : 3*T^2*s^2 ≤ Y^2*c^2+3*Y^2*s := by
    nlinarith [hmul, hY2]
  have hcapmul := mul_le_mul_of_nonneg_left hcap
    (mul_nonneg (by norm_num : (0:ℝ) ≤ 3) (sq_nonneg Y))
  have hlower : 3*T^2*(s^2-Y^2) ≤ Y^2*c^2 := by
    nlinarith [hbase, hcapmul]
  by_contra hnot
  have hD : gamma*T*c < s-Y := by
    change ¬s ≤ Y + gamma*T*c at hnot
    linarith
  have hD0 : 0 ≤ s-Y := by
    nlinarith [hD, mul_nonneg (mul_nonneg hg hT) hc]
  have hYpos : 0 < Y := by
    by_contra hn
    have hYzero : Y = 0 := le_antisymm (le_of_not_gt hn) hY
    rw [hYzero] at hbase
    have hp : 0 < 3*T^2*s^2 := by positivity
    nlinarith
  have hgold := homogeneous_golden_dual s Y hs hY
  have hgoldmul := mul_le_mul_of_nonneg_left hgold
    (mul_nonneg (sq_nonneg T) hD0)
  have hgold2 :
      T^2*Y^2*(s-Y)^2 ≤
        3*gamma^2*T^2*s^2*(s^2-Y^2) := by
    nlinarith [hgoldmul]
  have hlowmul := mul_le_mul_of_nonneg_left hlower
    (mul_nonneg (sq_nonneg gamma) (sq_nonneg s))
  have hchain : T^2*Y^2*(s-Y)^2 ≤
      gamma^2*s^2*Y^2*c^2 := by
    nlinarith [hgold2, hlowmul]
  have hcap2 : s^2 ≤ T^4 := by
    have hprod := mul_nonneg (sub_nonneg.mpr hcap)
      (add_nonneg hs (sq_nonneg T))
    nlinarith [hprod]
  have hgc : 0 ≤ gamma*T*c := mul_nonneg (mul_nonneg hg hT) hc
  have hDpos : 0 < s-Y := lt_of_le_of_lt hgc hD
  have hprod2 := mul_pos (sub_pos.mpr hD)
    (add_pos_of_nonneg_of_pos hgc hDpos)
  have hDsq : (gamma*T*c)^2 < (s-Y)^2 := by
    nlinarith [hprod2]
  have hstrict := mul_lt_mul_of_pos_left hDsq
    (mul_pos (sq_pos_of_pos hTpos) (sq_pos_of_pos hYpos))
  have hcapbound := mul_le_mul_of_nonneg_left hcap2
    (mul_nonneg (sq_nonneg gamma)
      (mul_nonneg (sq_nonneg Y) (sq_nonneg c)))
  nlinarith [hchain, hstrict, hcapbound]

end Nightfall.Q2625GoldenTrade

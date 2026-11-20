import Mathlib

set_option maxRecDepth 8000
set_option maxHeartbeats 4000000

namespace Nightfall.StructuralInformation.SubcubeSharpScalar

/-- The analytic exponent associated with the three-slice tensor geometry. -/
noncomputable def alpha : ℝ := Real.log 3 / Real.log 2

theorem alpha_gt_one : (1:ℝ) < alpha := by
  unfold alpha
  have hl : 0 < Real.log 2 := Real.log_pos (by norm_num)
  apply (lt_div_iff₀ hl).2
  rw [one_mul]
  exact Real.log_lt_log (by norm_num) (by norm_num)

theorem two_rpow_alpha : (2:ℝ) ^ alpha = 3 := by
  unfold alpha
  rw [Real.rpow_def_of_pos (by norm_num : (0:ℝ) < 2)]
  have hl : Real.log 2 ≠ 0 := ne_of_gt (Real.log_pos (by norm_num))
  rw [mul_div_cancel₀ _ hl, Real.exp_log (by norm_num)]

/-- If one entry is the largest, the triple power sum is controlled by the
    sum of its two largest entries; equality is possible at the dyadic split. -/
theorem scalar_sorted (p a b : ℝ)
    (hp : 1 ≤ p) (h2 : (3:ℝ) ≤ (2:ℝ)^p)
    (hb0 : 0 ≤ b) (hba : b ≤ a) :
    a ^ p + 2 * b ^ p ≤ (a+b) ^ p := by
  have hp0 : p ≠ 0 := ne_of_gt (by linarith : 0 < p)
  by_cases hzero : a+b=0
  · have ha : a=0 := by linarith
    have hb : b=0 := by linarith
    simp [ha, hb, Real.zero_rpow hp0]
  let t : ℝ := a+b
  have ht : 0 < t := by
    have htn : 0 ≤ t := by dsimp [t]; linarith
    exact lt_of_le_of_ne htn (Ne.symm hzero)
  let w : ℝ := (a-b)/t
  let v : ℝ := (2*b)/t
  have hw : 0 ≤ w := div_nonneg (sub_nonneg.mpr hba) ht.le
  have hv : 0 ≤ v := div_nonneg (by positivity) ht.le
  have hweights : w+v=1 := by
    dsimp [w, v]
    apply (div_eq_iff ht.ne').2
    dsimp [t]
    ring
  have hwt : w*t=a-b := by
    dsimp [w]
    exact div_mul_cancel₀ _ ht.ne'
  have hvt : v*(t/2)=b := by
    dsimp [v]
    field_simp [ht.ne']
    ring
  have hpow :
      3 * (t/2)^p ≤ t^p := by
    calc
      3 * (t/2)^p ≤ (2:ℝ)^p * (t/2)^p :=
        mul_le_mul_of_nonneg_right h2 (Real.rpow_nonneg (by positivity) p)
      _ = t^p := by
        rw [mul_comm, ← Real.mul_rpow (by positivity) (by positivity)]
        congr 1
        ring
  have hconvA :
      (w • t + v • (t/2))^p ≤ w • (t^p) + v • ((t/2)^p) :=
    (convexOn_rpow hp).2
      (by exact le_of_lt ht) (by positivity) hw hv hweights
  have hconvB :
      (w • (0:ℝ) + v • (t/2))^p ≤ w • ((0:ℝ)^p) + v • ((t/2)^p) :=
    (convexOn_rpow hp).2
      (by simp) (by positivity) hw hv hweights
  have hA : a^p ≤ w*t^p + v*(t/2)^p := by
    simpa only [smul_eq_mul, hwt, hvt, sub_add_cancel] using hconvA
  have hB : b^p ≤ v*(t/2)^p := by
    simpa only [smul_eq_mul, mul_zero, zero_add, Real.zero_rpow hp0, zero_mul, hvt] using hconvB
  have hbound : w*t^p + 3*v*(t/2)^p ≤ t^p := by
    calc
      w*t^p + 3*v*(t/2)^p ≤ w*t^p + v*t^p := by
        apply add_le_add_left
        nlinarith [mul_le_mul_of_nonneg_left hpow hv]
      _ = t^p := by rw [← add_mul, hweights, one_mul]
  change a^p + 2*b^p ≤ t^p
  linarith

/-- The exact three-slice scalar inequality for every nonnegative triple
    satisfying the pairwise direct-sum dimension constraints. -/
theorem triple_rpow (p q a b c : ℝ)
    (hp : 1 ≤ p) (h2 : (3:ℝ) ≤ (2:ℝ)^p)
    (hq : 0 ≤ q) (ha : 0 ≤ a) (hb : 0 ≤ b) (hc : 0 ≤ c)
    (hab : a+b ≤ q) (hac : a+c ≤ q) (hbc : b+c ≤ q) :
    a^p + b^p + c^p ≤ q^p := by
  have hp0 : 0 ≤ p := by linarith
  have sorted (x y z : ℝ)
      (hx : 0 ≤ x) (hy : 0 ≤ y) (hz : 0 ≤ z)
      (hyx : y ≤ x) (hzy : z ≤ y) (hpair : x+y ≤ q) :
      x^p + y^p + z^p ≤ q^p := by
    have h0 := scalar_sorted p x y hp h2 hy hyx
    have h1 := Real.rpow_le_rpow hz hzy hp0
    have h2' := Real.rpow_le_rpow (add_nonneg hx hy) hpair hp0
    linarith
  rcases le_total a b with hab' | hba
  · rcases le_total b c with hbc' | hcb
    · have h := sorted c b a hc hb ha hbc' hab' hbc
      linarith
    · rcases le_total a c with hac' | hca
      · have h := sorted b c a hb hc ha hcb hac' hbc
        linarith
      · have h := sorted b a c hb ha hc hab' hca hab
        linarith
  · rcases le_total a c with hac' | hca
    · have h := sorted c a b hc ha hb hac' hba hac
      linarith
    · rcases le_total b c with hbc' | hcb
      · have h := sorted a c b ha hc hb hca hbc' hac
        linarith
      · have h := sorted a b c ha hb hc hba hcb hab
        linarith

theorem triple_alpha (q a b c : ℝ)
    (hq : 0 ≤ q) (ha : 0 ≤ a) (hb : 0 ≤ b) (hc : 0 ≤ c)
    (hab : a+b ≤ q) (hac : a+c ≤ q) (hbc : b+c ≤ q) :
    a^alpha + b^alpha + c^alpha ≤ q^alpha := by
  exact triple_rpow alpha q a b c (le_of_lt alpha_gt_one)
    (by rw [two_rpow_alpha]) hq ha hb hc hab hac hbc

#print axioms Nightfall.StructuralInformation.SubcubeSharpScalar.alpha_gt_one
#print axioms Nightfall.StructuralInformation.SubcubeSharpScalar.two_rpow_alpha
#print axioms Nightfall.StructuralInformation.SubcubeSharpScalar.scalar_sorted
#print axioms Nightfall.StructuralInformation.SubcubeSharpScalar.triple_alpha

end Nightfall.StructuralInformation.SubcubeSharpScalar

import ShiftedC4Bernstein

/-!
# Exact c/4 shifted Hilbert scalar interpolation
Uses only (i) Holder e^3 ≤ u^2 q, (ii) the exact unrelaxed
fourth-moment upper bound q ≤ 3e²−2a⁴+4acs+c²s, and (iii) the
Lean-proved Bernstein nonnegativity in ShiftedC4Bernstein.
No probabilistic or finite-product law assertion occurs here.
-/

namespace Nightfall.ShiftedC4Scalar

open Nightfall.ShiftedC4Bernstein

theorem shifted_c4_from_strong_moments
    (a s c u e q : ℝ)
    (ha : 0 ≤ a) (hs : 0 ≤ s) (hc : 0 ≤ c) (hu : 0 ≤ u)
    (he : e = a^2+s)
    (hholder : e^3 ≤ u^2*q)
    (hfourth : q ≤ 3*e^2-2*a^4+4*a*c*s+c^2*s) :
    Real.sqrt e ≤ Real.sqrt 3*u+c/4 := by
  have he0 : 0 ≤ e := by rw [he]; positivity
  let t : ℝ := Real.sqrt e
  have ht0 : 0 ≤ t := Real.sqrt_nonneg _
  have ht2 : t^2 = e := Real.sq_sqrt he0
  have he2 : e = t^2 := ht2.symm
  by_cases hsmall : t ≤ c/4
  · have hnonneg : 0 ≤ Real.sqrt 3*u := by positivity
    change t ≤ Real.sqrt 3*u+c/4
    linarith
  have htpos : 0 < t := by
    have hdiff : c/4 < t := lt_of_not_ge hsmall
    have hdiv : 0 ≤ c/4 := by positivity
    linarith
  have h4t : c < 4*t := by
    have hdiff : c/4 < t := lt_of_not_ge hsmall
    linarith
  let x : ℝ := a/t
  let v : ℝ := c/(4*t)
  have hx0 : 0 ≤ x := by dsimp [x]; positivity
  have hasq : a^2 ≤ t^2 := by rw [ht2, he]; nlinarith [hs]
  have hxa : a ≤ t := by nlinarith
  have hx1 : x ≤ 1 := by
    dsimp [x]
    exact (div_le_iff₀ htpos).mpr (by linarith)
  have hv0 : 0 ≤ v := by dsimp [v]; positivity
  have hv1 : v ≤ 1 := by
    dsimp [v]
    exact (div_le_iff₀ (by positivity : (0:ℝ) < 4*t)).mpr (by linarith)
  let Q : ℝ := 3-2*x^4+16*x*v*(1-x^2)+16*v^2*(1-x^2)
  have hpoly : (1-v)^2*Q ≤ 3 := by
    exact shifted_c4_polynomial x v hx0 hx1 hv0 hv1
  have hax : a = x*t := by
    dsimp [x]
    field_simp [ne_of_gt htpos]
  have hcv : c = 4*v*t := by
    dsimp [v]
    have hden : (4:ℝ)*t ≠ 0 := by positivity
    field_simp [hden, ne_of_gt htpos]
    ring
  have hs2 : s = t^2-a^2 := by rw [ht2, he]; ring
  have hmoment : 3*e^2-2*a^4+4*a*c*s+c^2*s = t^4*Q := by
    calc
      _ = 3*t^4-2*a^4+4*a*c*(t^2-a^2)+c^2*(t^2-a^2) := by
        rw [he2, hs2]
        ring
      _ = t^4*Q := by
        rw [hax, hcv]
        dsimp [Q]
        ring
  have hqbound : q ≤ t^4*Q := hfourth.trans (le_of_eq hmoment)
  have hholdert : t^6 ≤ u^2*q := by
    calc
      t^6 = e^3 := by rw [he2]; ring
      _ ≤ u^2*q := hholder
  have hprod : t^2*t^4 ≤ (u^2*Q)*t^4 := by
    calc
      t^2*t^4 = t^6 := by ring
      _ ≤ u^2*q := hholdert
      _ ≤ u^2*(t^4*Q) := mul_le_mul_of_nonneg_left hqbound (sq_nonneg u)
      _ = (u^2*Q)*t^4 := by ring
  have hcore : t^2 ≤ u^2*Q :=
    (mul_le_mul_iff_of_pos_right (pow_pos htpos 4)).mp hprod
  have hnonneg : 0 ≤ (1-v)^2 := sq_nonneg _
  have hmul := mul_le_mul_of_nonneg_left hcore hnonneg
  have hpolyScaled := mul_le_mul_of_nonneg_left hpoly (sq_nonneg u)
  have hsquared : (t*(1-v))^2 ≤ (Real.sqrt 3*u)^2 := by
    calc
      (t*(1-v))^2 = (1-v)^2*t^2 := by ring
      _ ≤ (1-v)^2*(u^2*Q) := hmul
      _ = u^2*((1-v)^2*Q) := by ring
      _ ≤ u^2*3 := hpolyScaled
      _ = (Real.sqrt 3*u)^2 := by
        rw [mul_pow, Real.sq_sqrt (by norm_num : (0:ℝ) ≤ 3)]
        ring
  have hleft : 0 ≤ t*(1-v) := by
    exact mul_nonneg ht0 (sub_nonneg.mpr hv1)
  have hright : 0 ≤ Real.sqrt 3*u := by positivity
  have hlinear : t*(1-v) ≤ Real.sqrt 3*u := by
    nlinarith [hsquared]
  have hre : t*(1-v) = t-c/4 := by
    rw [hcv]
    ring
  rw [hre] at hlinear
  change t ≤ Real.sqrt 3*u+c/4
  linarith

end Nightfall.ShiftedC4Scalar

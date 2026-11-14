import ShiftedOwnerBernstein

/-!
# Conditional c/4 shifted-moment interpolation

The exact Bernstein polynomial is proved in ShiftedOwnerBernstein.
This file combines it with Holder and a PRE-SUPPLIED shifted fourth
moment estimate. It is not an original-source Hilbert moment theorem.
-/

namespace Nightfall.Observability.ShiftedOwnerQuarterMoments

open Nightfall.Observability.ShiftedOwnerBernstein

/-- For e=t^2=a^2+s, this is the exact scalar moment-to-L1
interpolation; the shifted moment fourth inequality is a hypothesis,
not an assumed axiom or a derived source-law bound. -/
theorem shifted_c4_from_moments
    (t a s c u q : ℝ)
    (ht : 0 ≤ t) (ha : 0 ≤ a) (hs : 0 ≤ s)
    (hc : 0 ≤ c) (hu : 0 ≤ u)
    (henergy : t^2 = a^2+s)
    (hholder : t^6 ≤ u^2*q)
    (hfourth : q ≤ 3*t^4-2*a^4+4*a*c*s+c^2*s) :
    t ≤ Real.sqrt 3*u+c/4 := by
  have hr : 0 ≤ Real.sqrt 3 := Real.sqrt_nonneg _
  by_cases htzero : t = 0
  · rw [htzero]
    have hh : 0 ≤ Real.sqrt 3*u+c/4 := by positivity
    linarith
  · have htpos : 0 < t := lt_of_le_of_ne ht (Ne.symm htzero)
    by_cases hlarge : 4*t ≤ c
    · nlinarith [mul_nonneg hr hu]
    · have hclt : c < 4*t := lt_of_not_ge hlarge
      let x : ℝ := a/t
      let d : ℝ := c/t
      have htne : t ≠ 0 := ne_of_gt htpos
      have hx0 : 0 ≤ x := div_nonneg ha ht.le
      have ha2 : a^2 ≤ t^2 := by linarith [henergy]
      have hat : a ≤ t := by nlinarith [ha2]
      have hx1 : x ≤ 1 := by
        dsimp [x]
        exact (div_le_iff₀ htpos).2 (by linarith)
      have hd0 : 0 ≤ d := div_nonneg hc ht.le
      have hd4 : d ≤ 4 := by
        dsimp [d]
        exact (div_le_iff₀ htpos).2 (by linarith)
      let F : ℝ := 3-2*x^4+4*x*(1-x^2)*d+(1-x^2)*d^2
      have hsEq : s = t^2-a^2 := by linarith [henergy]
      have hnormalized :
          t^4*F = 3*t^4-2*a^4+4*a*c*s+c^2*s := by
        dsimp [F,x,d]
        rw [hsEq]
        field_simp
        ring
      have hnormQ : q ≤ t^4*F := by
        rw [hnormalized]
        exact hfourth
      have hboundQ : t^6 ≤ u^2*(t^4*F) :=
        hholder.trans
          (mul_le_mul_of_nonneg_left hnormQ (sq_nonneg u))
      have hcancel : t^2*t^4 ≤ (u^2*F)*t^4 := by
        calc
          t^2*t^4 = t^6 := by ring
          _ ≤ u^2*(t^4*F) := hboundQ
          _ = (u^2*F)*t^4 := by ring
      have hnorm : t^2 ≤ u^2*F :=
        (mul_le_mul_iff_of_pos_right (pow_pos htpos 4)).mp hcancel
      have hpoly := shifted_quarter_polynomial x d hx0 hx1 hd0 hd4
      have hquarter : 0 ≤ 1-d/4 := by linarith
      have hsq : (t*(1-d/4))^2 ≤ 3*u^2 := by
        calc
          (t*(1-d/4))^2 = t^2*(1-d/4)^2 := by ring
          _ ≤ (u^2*F)*(1-d/4)^2 :=
            mul_le_mul_of_nonneg_right hnorm (sq_nonneg _)
          _ = u^2*((1-d/4)^2*F) := by ring
          _ ≤ u^2*3 :=
            mul_le_mul_of_nonneg_left (by simpa only [F] using hpoly) (sq_nonneg u)
          _ = 3*u^2 := by ring
      have hroot : (Real.sqrt 3*u)^2 = 3*u^2 := by
        calc
          (Real.sqrt 3*u)^2 = (Real.sqrt 3)^2*u^2 := by ring
          _ = 3*u^2 := by rw [Real.sq_sqrt (by norm_num)]
      have hpositive : 0 ≤ t*(1-d/4) :=
        mul_nonneg ht hquarter
      have hpositive2 : 0 ≤ Real.sqrt 3*u := mul_nonneg hr hu
      have hsq' : (t*(1-d/4))^2 ≤ (Real.sqrt 3*u)^2 := by
        rw [hroot]
        exact hsq
      have hlinear : t*(1-d/4) ≤ Real.sqrt 3*u := by
        nlinarith [hsq']
      have hrewrite : t*(1-d/4) = t-c/4 := by
        dsimp [d]
        field_simp
        ring
      linarith [hlinear]

end Nightfall.Observability.ShiftedOwnerQuarterMoments

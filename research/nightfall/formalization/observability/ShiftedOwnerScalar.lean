import Mathlib

/-!
# Shifted-owner scalar fourth-moment interpolation: c/3

This is a strict, source-independent REAL ALGEBRA lemma.
The input hfourth is the interpolation consequence of the fourth
moment of an actual shifted independent Hilbert sum. This file does
NOT assert a source-level Hilbert fourth moment, Jensen projection,
or original-law Q2 terminal bound. Those are separate gates.

No sorry, opaque axioms, or admit.
-/

namespace Nightfall.Observability.ShiftedOwnerScalar

/-- Exact scalar interpolation, in division-free fourth-moment form.

If t = sqrt(e) and Holder and the moment bound give
t^4 <= u^2 * (3t^2+2ct+c^2), then t <= sqrt(3)*u + c/3.
This proof uses the exact SOS identity
27 t^4 - (3t-c)^2(3t^2+2ct+c^2) = c^3(4t-c).
-/
theorem shifted_c3_of_fourth_interpolation
    (t u c : ℝ)
    (ht : 0 ≤ t) (hu : 0 ≤ u) (hc : 0 ≤ c)
    (hfourth : t^4 ≤ u^2 * (3*t^2+2*c*t+c^2)) :
    t ≤ Real.sqrt 3*u+c/3 := by
  have hr0 : (0:ℝ) ≤ Real.sqrt 3 := Real.sqrt_nonneg _
  have hr2 : (Real.sqrt 3)^2 = (3:ℝ) :=
    Real.sq_sqrt (by norm_num)
  by_cases hsmall : 3*t ≤ c
  · nlinarith [mul_nonneg hr0 hu]
  · have hct : c < 3*t := lt_of_not_ge hsmall
    have htpos : 0 < t := by linarith
    let D : ℝ := 3*t^2+2*c*t+c^2
    have hDpos : 0 < D := by
      dsimp [D]
      positivity
    have hd : 0 ≤ c^3 * (4*t-c) := by
      apply mul_nonneg
      · positivity
      · linarith
    have hid : 27*t^4 - (3*t-c)^2*D = c^3*(4*t-c) := by
      dsimp [D]
      ring
    have h1 : (3*t-c)^2*D ≤ 27*t^4 := by
      nlinarith [hid, hd]
    have hfourth' : t^4 ≤ u^2*D := by
      simpa only [D] using hfourth
    have h2 : 27*t^4 ≤ 27*u^2*D := by
      calc
        27*t^4 ≤ 27*(u^2*D) :=
          mul_le_mul_of_nonneg_left hfourth' (by norm_num)
        _ = 27*u^2*D := by ring
    have hsqD : (3*t-c)^2*D ≤ (27*u^2)*D := by
      nlinarith [h1, h2]
    have hsq : (3*t-c)^2 ≤ 27*u^2 :=
      (mul_le_mul_iff_of_pos_right hDpos).mp hsqD
    have hroot : (3*Real.sqrt 3*u)^2 = 27*u^2 := by
      calc
        (3*Real.sqrt 3*u)^2 =
            9*(Real.sqrt 3)^2*u^2 := by ring
        _ = 27*u^2 := by rw [hr2]; ring
    have hsquared : (3*t-c)^2 ≤ (3*Real.sqrt 3*u)^2 := by
      rw [hroot]
      exact hsq
    have hleft : 0 ≤ 3*t-c := by linarith
    have hright : 0 ≤ 3*Real.sqrt 3*u := by positivity
    have hlinear : 3*t-c ≤ 3*Real.sqrt 3*u := by
      nlinarith [hsquared]
    linarith

/-- An exact algebraic consequence of the local shifted bound and a
single shared source-energy cap; still a CONDITIONAL local statement. -/
theorem shifted_site_c3
    (e u c M : ℝ)
    (he : 0 ≤ e) (hu : 0 ≤ u) (hc : 0 ≤ c) (hM : 0 ≤ M)
    (henergy : e ≤ M)
    (hshift : Real.sqrt e ≤ Real.sqrt 3*u+c/3) :
    e ≤ Real.sqrt M*(Real.sqrt 3*u+c/3) := by
  have hrootE : 0 ≤ Real.sqrt e := Real.sqrt_nonneg _
  have hrootM : 0 ≤ Real.sqrt M := Real.sqrt_nonneg _
  have hroots : Real.sqrt e ≤ Real.sqrt M :=
    Real.sqrt_le_sqrt henergy
  have hsquare : (Real.sqrt e)^2 = e := Real.sq_sqrt he
  calc
    e = Real.sqrt e * Real.sqrt e := by rw [← pow_two, hsquare]
    _ ≤ Real.sqrt M * Real.sqrt e := by
      exact mul_le_mul_of_nonneg_right hroots hrootE
    _ ≤ Real.sqrt M * (Real.sqrt 3*u+c/3) := by
      exact mul_le_mul_of_nonneg_left hshift hrootM

end Nightfall.Observability.ShiftedOwnerScalar

import Mathlib

/-!
# NIGHTFALL Q2: c/5 shifted interpolation under a STRONGER moment envelope

This theorem does NOT assert the unrestricted source Hilbert c/5 bound.
It proves an exact c/5 conclusion under the *symmetric-type*
fourth moment assumption q <= 3 t^4 + c^2 t^2 and genuine Holder.

The rational SOS identity is:
75 t^4 - (5t-c)^2 (3t^2+c^2)
  = c [6t^3 + (c-2t)^2(6t-c)] >= 0
for 0 <= c <= 5t. It is stronger than the older c/4 polynomial.
-/

namespace Nightfall.Q299

/-- A c/5 shift bound is kernel-provable given a symmetric-type
fourth-moment upper bound. The unrestricted asymmetric original-law
Hilbert moment is *not* assumed to meet this stronger envelope. -/
theorem shifted_c5_from_symmetric_type_moments
    (t u c q : ℝ)
    (ht : 0 ≤ t) (hu : 0 ≤ u) (hc : 0 ≤ c)
    (hholder : t^6 ≤ u^2*q)
    (hfourth : q ≤ 3*t^4+c^2*t^2) :
    t ≤ Real.sqrt 3*u+c/5 := by
  have hr0 : 0 ≤ Real.sqrt 3 := Real.sqrt_nonneg _
  have hr2 : (Real.sqrt 3)^2 = (3:ℝ) :=
    Real.sq_sqrt (by norm_num)
  by_cases hsmall : 5*t ≤ c
  · nlinarith [mul_nonneg hr0 hu]
  · have hct : c < 5*t := lt_of_not_ge hsmall
    have htpos : 0 < t := by linarith
    let D : ℝ := 3*t^2+c^2
    have hDpos : 0 < D := by
      dsimp [D]
      positivity
    have hq : q ≤ t^2*D := by
      calc
        q ≤ 3*t^4+c^2*t^2 := hfourth
        _ = t^2*D := by dsimp [D]; ring
    have hfourth' : t^4 ≤ u^2*D := by
      have hstep : t^6 ≤ u^2*(t^2*D) :=
        hholder.trans (mul_le_mul_of_nonneg_left hq (sq_nonneg u))
      have hcancel : t^4*t^2 ≤ (u^2*D)*t^2 := by
        calc
          t^4*t^2 = t^6 := by ring
          _ ≤ u^2*(t^2*D) := hstep
          _ = (u^2*D)*t^2 := by ring
      exact
        (mul_le_mul_iff_of_pos_right (sq_pos_of_pos htpos)).mp hcancel
    have hgap : 0 ≤ 6*t-c := by linarith
    have hsosnonneg :
        0 ≤ c*(6*t^3+(c-2*t)^2*(6*t-c)) := by
      apply mul_nonneg hc
      apply add_nonneg
      · positivity
      · exact mul_nonneg (sq_nonneg _) hgap
    have hsos :
        75*t^4-(5*t-c)^2*D =
          c*(6*t^3+(c-2*t)^2*(6*t-c)) := by
      dsimp [D]
      ring
    have hbound : (5*t-c)^2*D ≤ 75*t^4 := by
      nlinarith [hsos,hsosnonneg]
    have hbound2 : (5*t-c)^2*D ≤ (75*u^2)*D := by
      calc
        (5*t-c)^2*D ≤ 75*t^4 := hbound
        _ ≤ 75*(u^2*D) :=
          mul_le_mul_of_nonneg_left hfourth' (by norm_num)
        _ = (75*u^2)*D := by ring
    have hsq : (5*t-c)^2 ≤ 75*u^2 :=
      (mul_le_mul_iff_of_pos_right hDpos).mp hbound2
    have hroot : (5*Real.sqrt 3*u)^2 = 75*u^2 := by
      calc
        (5*Real.sqrt 3*u)^2 =
          25*(Real.sqrt 3)^2*u^2 := by ring
        _ = 75*u^2 := by rw [hr2]; ring
    have hsquared : (5*t-c)^2 ≤ (5*Real.sqrt 3*u)^2 := by
      rw [hroot]
      exact hsq
    have hleft : 0 ≤ 5*t-c := by linarith
    have hright : 0 ≤ 5*Real.sqrt 3*u := by positivity
    have hlinear : 5*t-c ≤ 5*Real.sqrt 3*u := by
      nlinarith [hsquared]
    linarith

/-- Exact polynomial-identity certificate making the stronger
moment regime explicit; does not assert asymmetric independent
increments satisfy the new moment premise. -/
theorem symmetric_type_sos_identity (t c : ℝ) :
    75*t^4-(5*t-c)^2*(3*t^2+c^2) =
      c*(6*t^3+(c-2*t)^2*(6*t-c)) := by
  ring

end Nightfall.Q299

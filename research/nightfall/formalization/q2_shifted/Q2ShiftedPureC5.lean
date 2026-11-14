import Mathlib

/-!
# Genuine c/5 interpolation when the shifted third-moment term vanishes

Unlike the general c/5 claim (not proved), this module uses the
correctly restricted symmetric/zero-singleton fourth moment, with no
mixed odd term. Its only moment premise in the second declaration is
the actual L1-L2-L4 Holder and odd-term-free fourth inequality.

Source law/owner transport and source sharp-section budget remain
separate. This file does not prove unconditional general-product C99.
-/

namespace Nightfall.Q2Shifted.PureC5

/-- Exact polynomial form of c/5 interpolation.
    The positive SOS is
      25*[3*t^4-(t-c/5)^2*(3*t^2+c^2)]
      =c*[6*t^3+(c-2*t)^2*(6*t-c)].
    This works for c<5t; c>=5t is immediate. -/
theorem fifth_interpolation_of_fourth
    (t u c : ℝ)
    (ht : 0 ≤ t) (hu : 0 ≤ u) (hc : 0 ≤ c)
    (hfourth : t^4 ≤ u^2*(3*t^2+c^2)) :
    t ≤ Real.sqrt 3*u+c/5 := by
  have hr0 : 0 ≤ Real.sqrt 3 := Real.sqrt_nonneg _
  have hr2 : (Real.sqrt 3)^2 = (3:ℝ) :=
    Real.sq_sqrt (by norm_num)
  by_cases hlarge : 5*t ≤ c
  · have hnonneg : 0 ≤ Real.sqrt 3*u := mul_nonneg hr0 hu
    linarith
  · have hcsmall : c < 5*t := lt_of_not_ge hlarge
    have htpos : 0 < t := by linarith
    let D : ℝ := 3*t^2+c^2
    have hDpos : 0 < D := by
      dsimp [D]
      positivity
    have hpositive : 0 ≤ c*(6*t^3+(c-2*t)^2*(6*t-c)) := by
      apply mul_nonneg hc
      apply add_nonneg
      · positivity
      · exact mul_nonneg (sq_nonneg _) (by linarith)
    have hid :
        25*(3*t^4-(t-c/5)^2*D) =
          c*(6*t^3+(c-2*t)^2*(6*t-c)) := by
      dsimp [D]
      ring
    have hpoly : (t-c/5)^2*D ≤ 3*t^4 := by
      nlinarith [hid, hpositive]
    have hh : t^4 ≤ u^2*D := by simpa only [D] using hfourth
    have hh3 : 3*t^4 ≤ 3*u^2*D := by
      exact mul_le_mul_of_nonneg_left hh (by norm_num)
    have hprod : (t-c/5)^2*D ≤ (3*u^2)*D := by
      nlinarith [hpoly, hh3]
    have hsquare : (t-c/5)^2 ≤ 3*u^2 :=
      (mul_le_mul_iff_of_pos_right hDpos).mp hprod
    have hrid : (Real.sqrt 3*u)^2 = 3*u^2 := by
      calc
        (Real.sqrt 3*u)^2 = (Real.sqrt 3)^2*u^2 := by ring
        _ = 3*u^2 := by rw [hr2]
    have hleft : 0 ≤ t-c/5 := by linarith
    have hright : 0 ≤ Real.sqrt 3*u := mul_nonneg hr0 hu
    nlinarith [hsquare, hrid]

/-- True c/5 statement under an **explicit odd-term-free fourth-moment
    assumption**, e.g. when h=0 or the sum is symmetric. Holder is an
    explicit premise; the source law is not verified in this module. -/
theorem fifth_of_zero_odd_term_moments
    (t a s u c q : ℝ)
    (ht : 0 ≤ t) (ha : 0 ≤ a) (hs : 0 ≤ s)
    (hu : 0 ≤ u) (hc : 0 ≤ c)
    (henergy : t^2 = a^2+s)
    (hholder : t^6 ≤ u^2*q)
    (hfourth : q ≤ 3*t^4-2*a^4+c^2*s) :
    t ≤ Real.sqrt 3*u+c/5 := by
  by_cases htzero : t = 0
  · rw [htzero]
    have hnonneg : 0 ≤ Real.sqrt 3*u := by positivity
    linarith
  · have htpos : 0 < t := lt_of_le_of_ne ht (Ne.symm htzero)
    let D : ℝ := 3*t^2+c^2
    have hsle : s ≤ t^2 := by nlinarith [henergy, sq_nonneg a]
    have hsq : 0 ≤ a^4 := by positivity
    have hc2 : 0 ≤ c^2 := sq_nonneg c
    have hmul : c^2*s ≤ c^2*t^2 :=
      mul_le_mul_of_nonneg_left hsle hc2
    have hquartic : q ≤ t^2*D := by
      dsimp [D]
      nlinarith [hfourth, hmul, hsq]
    have hu2 : 0 ≤ u^2 := sq_nonneg u
    have hbig : t^6 ≤ u^2*(t^2*D) :=
      hholder.trans (mul_le_mul_of_nonneg_left hquartic hu2)
    have ht2pos : 0 < t^2 := sq_pos_of_pos htpos
    have hsimp : t^4 ≤ u^2*D := by
      have hcancel : (t^4)*t^2 ≤ (u^2*D)*t^2 := by
        calc
          t^4*t^2 = t^6 := by ring
          _ ≤ u^2*(t^2*D) := hbig
          _ = (u^2*D)*t^2 := by ring
      exact (mul_le_mul_iff_of_pos_right ht2pos).mp hcancel
    exact fifth_interpolation_of_fourth t u c ht hu hc
      (by simpa only [D] using hsimp)

/-- Pure centered owner sum (no singleton): its existing, actual
    independent-increment fourth moment has q <= 3s²+c²s.
    This is the correct probability-law-compatible c/5 operator after
    obtaining the true moment and Holder inequalities. -/
theorem fifth_for_pure_centered_sum
    (s u c q : ℝ)
    (hs : 0 ≤ s) (hu : 0 ≤ u) (hc : 0 ≤ c)
    (hholder : s^3 ≤ u^2*q)
    (hfourth : q ≤ 3*s^2+c^2*s) :
    Real.sqrt s ≤ Real.sqrt 3*u+c/5 := by
  have ht : 0 ≤ Real.sqrt s := Real.sqrt_nonneg _
  have he : (Real.sqrt s)^2 = s := Real.sq_sqrt hs
  have hh : (Real.sqrt s)^6 ≤ u^2*q := by
    calc
      (Real.sqrt s)^6 = s^3 := by rw [← he]; ring
      _ ≤ u^2*q := hholder
  have hq : q ≤ 3*(Real.sqrt s)^4-2*(0:ℝ)^4+c^2*s := by
    calc
      q ≤ 3*s^2+c^2*s := hfourth
      _ = 3*(Real.sqrt s)^4-2*(0:ℝ)^4+c^2*s := by
        rw [← he]
        ring
  exact fifth_of_zero_odd_term_moments
    (Real.sqrt s) 0 s u c q ht (by norm_num) hs hu hc
    (by rw [he]; ring) hh hq

end Nightfall.Q2Shifted.PureC5

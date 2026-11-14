import Mathlib

/-!
# NIGHTFALL shifted-owner Q2: exact scalar endpoint

This file is a self-contained deterministic Lean target. It does not assume
any source-level Q2 conclusion, Hilbert moment bound, or original-law Jensen
theorem. The Hilbert fourth-moment and original-product gluing are separate
certification gates.

The first theorem converts a corrected fourth-moment interpolation to a
linear L1+amplitude bound. The second derives its input from the exact
shifted fourth-moment envelope and an L1/L2/L4 interpolation premise.
-/

namespace Nightfall.Q2Shifted

/-- A fully algebraic shifted-moment correction with coefficient c/3.
    The exact identity behind the proof is
    3*r^4 - (r-c/3)^2*(3*r^2+2*c*r+c^2) = c^3*(4*r-c)/9. -/
theorem shifted_interpolation_third
    (r u c : ℝ)
    (hr : 0 ≤ r) (hu : 0 ≤ u) (hc : 0 ≤ c)
    (hinterp : r^4 ≤ u^2 * (3*r^2+2*c*r+c^2)) :
    r ≤ Real.sqrt 3 * u + c/3 := by
  have hroot : (Real.sqrt (3:ℝ))^2 = 3 :=
    Real.sq_sqrt (by norm_num)
  have hroot0 : 0 ≤ Real.sqrt (3:ℝ) := Real.sqrt_nonneg _
  by_cases hlarge : 3*r ≤ c
  · have hnonneg : 0 ≤ Real.sqrt (3:ℝ)*u :=
      mul_nonneg hroot0 hu
    linarith
  · have hcsmall : c < 3*r := lt_of_not_ge hlarge
    have hrpos : 0 < r := by nlinarith
    let A : ℝ := 3*r^2+2*c*r+c^2
    have hApos : 0 < A := by
      dsimp [A]
      have hr2 : 0 < r^2 := sq_pos_of_pos hrpos
      nlinarith [mul_nonneg hc hr, sq_nonneg c]
    have hpoly :
        3*r^4-(r-c/3)^2*A = c^3*(4*r-c)/9 := by
      dsimp [A]
      ring
    have hfour : 0 ≤ 4*r-c := by linarith
    have hnonneg : 0 ≤ c^3*(4*r-c)/9 := by positivity
    have hbound : (r-c/3)^2*A ≤ 3*r^4 := by
      linarith
    have hupper : 3*r^4 ≤ (3*u^2)*A := by
      have hh := mul_le_mul_of_nonneg_left hinterp (by norm_num : (0:ℝ) ≤ 3)
      dsimp [A] at *
      nlinarith [hh]
    have hsqmul : (r-c/3)^2*A ≤ (3*u^2)*A :=
      le_trans hbound hupper
    have hsq : (r-c/3)^2 ≤ 3*u^2 := by
      by_contra hn
      have hstrict : 3*u^2 < (r-c/3)^2 := lt_of_not_ge hn
      have hmul := mul_lt_mul_of_pos_right hstrict hApos
      nlinarith [hmul, hsqmul]
    have hleft : 0 ≤ r-c/3 := by linarith
    have hright : 0 ≤ Real.sqrt (3:ℝ)*u :=
      mul_nonneg hroot0 hu
    nlinarith [hsq]

/-- Exact shifted Hilbert fourth-moment *scalar* closure.

    Mathematical meaning: r^2=a^2+s is the shifted second moment,
    q is its fourth moment, and r^6<=u^2*q comes from weighted
    L1/L2/L4 interpolation. The Hilbert moment envelope hq and the
    interpolation are explicit premises here, NOT yet source-derived
    in this declaration. -/
theorem shifted_fourth_moment_scalar
    (a s r u c q : ℝ)
    (ha : 0 ≤ a) (hs : 0 ≤ s) (hr : 0 ≤ r)
    (hu : 0 ≤ u) (hc : 0 ≤ c)
    (henergy : r^2 = a^2+s)
    (hq : q ≤ 3*r^4-2*a^4+4*a*c*s+c^2*s)
    (hinterp : r^6 ≤ u^2*q) :
    r ≤ Real.sqrt 3*u+c/3 := by
  by_cases hrzero : r = 0
  · rw [hrzero]
    have hnonneg : 0 ≤ Real.sqrt (3:ℝ)*u :=
      mul_nonneg (Real.sqrt_nonneg _) hu
    linarith
  have hrpos : 0 < r := lt_of_le_of_ne hr (Ne.symm hrzero)
  have hSOS :
      2*r^3-4*a*s =
        2*r*(r-2*a)^2+4*a*(r-a)^2 := by
    have hzero : r^2-a^2-s=0 := by linarith
    calc
      2*r^3-4*a*s =
        2*r*(r-2*a)^2+4*a*(r-a)^2+
          4*a*(r^2-a^2-s) := by ring
      _ = 2*r*(r-2*a)^2+4*a*(r-a)^2 := by rw [hzero]; ring
  have h4 : 4*a*s ≤ 2*r^3 := by
    have h1 := mul_nonneg hr (sq_nonneg (r-2*a))
    have h2 := mul_nonneg ha (sq_nonneg (r-a))
    nlinarith [hSOS, h1, h2]
  have hsle : s ≤ r^2 := by nlinarith [henergy, sq_nonneg a]
  have hsc : c^2*s ≤ c^2*r^2 :=
    mul_le_mul_of_nonneg_left hsle (sq_nonneg c)
  have hcs : 4*a*c*s ≤ 2*c*r^3 := by
    have h := mul_le_mul_of_nonneg_left h4 hc
    nlinarith [h]
  have hfour :
      q ≤ r^2*(3*r^2+2*c*r+c^2) := by
    nlinarith [hq, hsc, hcs, sq_nonneg (a^2)]
  have hu2 : 0 ≤ u^2 := sq_nonneg u
  have hbig : r^6 ≤ u^2*(r^2*(3*r^2+2*c*r+c^2)) :=
    le_trans hinterp (mul_le_mul_of_nonneg_left hfour hu2)
  have hr2pos : 0 < r^2 := sq_pos_of_pos hrpos
  have hsmall : r^4 ≤ u^2*(3*r^2+2*c*r+c^2) := by
    by_contra hn
    have hstrict : u^2*(3*r^2+2*c*r+c^2) < r^4 :=
      lt_of_not_ge hn
    have hmul := mul_lt_mul_of_pos_left hstrict hr2pos
    nlinarith [hbig, hmul]
  exact shifted_interpolation_third r u c hr hu hc hsmall

end Nightfall.Q2Shifted
